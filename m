From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH v5 09/14] netlabel: Add functionality to set the security
	attributes of a packet
Date: Fri, 05 Sep 2008 19:24:14 -0400
Message-ID: <20080905232414.31840.18800.stgit@flek.lan>
References: <20080905231853.31840.57880.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080905231853.31840.57880.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch builds upon the new NetLabel address selector functionality by
providing the NetLabel KAPI and CIPSO engine support needed to enable the
new packet-based labeling.  The only new addition to the NetLabel KAPI at
this point is shown below:

 * int netlbl_skbuff_setattr(skb, family, secattr)

... and is designed to be called from a Netfilter hook after the packet's
IP header has been populated such as in the FORWARD or LOCAL_OUT hooks.

This patch also provides the necessary SELinux hooks to support this new
functionality.  Smack support is not currently included due to uncertainty
regarding the permissions needed to expand the Smack network access controls.

Signed-off-by: Paul Moore <paul.moore@hp.com>
Acked-by: James Morris <jmorris@namei.org>
---

 include/net/cipso_ipv4.h            |   16 +++
 include/net/netlabel.h              |    9 +
 net/ipv4/cipso_ipv4.c               |  222 +++++++++++++++++++++++++++++------
 net/netlabel/netlabel_kapi.c        |   60 +++++++++
 security/selinux/hooks.c            |   50 ++++++++
 security/selinux/include/netlabel.h |    9 +
 security/selinux/include/objsec.h   |    1 
 security/selinux/netlabel.c         |   50 ++++++++
 8 files changed, 375 insertions(+), 42 deletions(-)

diff --git a/include/net/cipso_ipv4.h b/include/net/cipso_ipv4.h
index 5fe6556..2ce093b 100644
--- a/include/net/cipso_ipv4.h
+++ b/include/net/cipso_ipv4.h
@@ -208,6 +208,10 @@ int cipso_v4_sock_setattr(struct sock *sk,
 			  const struct cipso_v4_doi *doi_def,
 			  const struct netlbl_lsm_secattr *secattr);
 int cipso_v4_sock_getattr(struct sock *sk, struct netlbl_lsm_secattr *secattr);
+int cipso_v4_skbuff_setattr(struct sk_buff *skb,
+			    const struct cipso_v4_doi *doi_def,
+			    const struct netlbl_lsm_secattr *secattr);
+int cipso_v4_skbuff_delattr(struct sk_buff *skb);
 int cipso_v4_skbuff_getattr(const struct sk_buff *skb,
 			    struct netlbl_lsm_secattr *secattr);
 int cipso_v4_validate(unsigned char **option);
@@ -232,6 +236,18 @@ static inline int cipso_v4_sock_getattr(struct sock *sk,
 	return -ENOSYS;
 }
 
+static inline int cipso_v4_skbuff_setattr(struct sk_buff *skb,
+				      const struct cipso_v4_doi *doi_def,
+				      const struct netlbl_lsm_secattr *secattr)
+{
+	return -ENOSYS;
+}
+
+static inline int cipso_v4_skbuff_delattr(struct sk_buff *skb)
+{
+	return -ENOSYS;
+}
+
 static inline int cipso_v4_skbuff_getattr(const struct sk_buff *skb,
 					  struct netlbl_lsm_secattr *secattr)
 {
diff --git a/include/net/netlabel.h b/include/net/netlabel.h
index 0729f8c..3f67e6d 100644
--- a/include/net/netlabel.h
+++ b/include/net/netlabel.h
@@ -382,6 +382,9 @@ int netlbl_sock_setattr(struct sock *sk,
 			const struct netlbl_lsm_secattr *secattr);
 int netlbl_sock_getattr(struct sock *sk,
 			struct netlbl_lsm_secattr *secattr);
+int netlbl_skbuff_setattr(struct sk_buff *skb,
+			  u16 family,
+			  const struct netlbl_lsm_secattr *secattr);
 int netlbl_skbuff_getattr(const struct sk_buff *skb,
 			  u16 family,
 			  struct netlbl_lsm_secattr *secattr);
@@ -451,6 +454,12 @@ static inline int netlbl_sock_getattr(struct sock *sk,
 {
 	return -ENOSYS;
 }
+static inline int netlbl_skbuff_setattr(struct sk_buff *skb,
+				      u16 family,
+				      const struct netlbl_lsm_secattr *secattr)
+{
+	return -ENOSYS;
+}
 static inline int netlbl_skbuff_getattr(const struct sk_buff *skb,
 					u16 family,
 					struct netlbl_lsm_secattr *secattr)
diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index bf87edd..e13d6db 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -13,7 +13,7 @@
  */
 
 /*
- * (c) Copyright Hewlett-Packard Development Company, L.P., 2006
+ * (c) Copyright Hewlett-Packard Development Company, L.P., 2006, 2008
  *
  * This program is free software;  you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -1665,48 +1665,27 @@ void cipso_v4_error(struct sk_buff *skb, int error, u32 gateway)
 }
 
 /**
- * cipso_v4_sock_setattr - Add a CIPSO option to a socket
- * @sk: the socket
+ * cipso_v4_genopt - Generate a CIPSO option
+ * @buf: the option buffer
+ * @buf_len: the size of opt_buf
  * @doi_def: the CIPSO DOI to use
- * @secattr: the specific security attributes of the socket
+ * @secattr: the security attributes
  *
  * Description:
- * Set the CIPSO option on the given socket using the DOI definition and
- * security attributes passed to the function.  This function requires
- * exclusive access to @sk, which means it either needs to be in the
- * process of being created or locked.  Returns zero on success and negative
- * values on failure.
+ * Generate a CIPSO option using the DOI definition and security attributes
+ * passed to the function.  Returns the length of the option on success and
+ * negative values on failure.
  *
  */
-int cipso_v4_sock_setattr(struct sock *sk,
-			  const struct cipso_v4_doi *doi_def,
-			  const struct netlbl_lsm_secattr *secattr)
+static int cipso_v4_genopt(unsigned char *buf, u32 buf_len,
+			   const struct cipso_v4_doi *doi_def,
+			   const struct netlbl_lsm_secattr *secattr)
 {
-	int ret_val = -EPERM;
+	int ret_val;
 	u32 iter;
-	unsigned char *buf;
-	u32 buf_len = 0;
-	u32 opt_len;
-	struct ip_options *opt = NULL;
-	struct inet_sock *sk_inet;
-	struct inet_connection_sock *sk_conn;
-
-	/* In the case of sock_create_lite(), the sock->sk field is not
-	 * defined yet but it is not a problem as the only users of these
-	 * "lite" PF_INET sockets are functions which do an accept() call
-	 * afterwards so we will label the socket as part of the accept(). */
-	if (sk == NULL)
-		return 0;
 
-	/* We allocate the maximum CIPSO option size here so we are probably
-	 * being a little wasteful, but it makes our life _much_ easier later
-	 * on and after all we are only talking about 40 bytes. */
-	buf_len = CIPSO_V4_OPT_LEN_MAX;
-	buf = kmalloc(buf_len, GFP_ATOMIC);
-	if (buf == NULL) {
-		ret_val = -ENOMEM;
-		goto socket_setattr_failure;
-	}
+	if (buf_len <= CIPSO_V4_HDR_LEN)
+		return -ENOSPC;
 
 	/* XXX - This code assumes only one tag per CIPSO option which isn't
 	 * really a good assumption to make but since we only support the MAC
@@ -1734,8 +1713,7 @@ int cipso_v4_sock_setattr(struct sock *sk,
 						   buf_len - CIPSO_V4_HDR_LEN);
 			break;
 		default:
-			ret_val = -EPERM;
-			goto socket_setattr_failure;
+			return -EPERM;
 		}
 
 		iter++;
@@ -1743,9 +1721,58 @@ int cipso_v4_sock_setattr(struct sock *sk,
 		 iter < CIPSO_V4_TAG_MAXCNT &&
 		 doi_def->tags[iter] != CIPSO_V4_TAG_INVALID);
 	if (ret_val < 0)
-		goto socket_setattr_failure;
+		return ret_val;
 	cipso_v4_gentag_hdr(doi_def, buf, ret_val);
-	buf_len = CIPSO_V4_HDR_LEN + ret_val;
+	return CIPSO_V4_HDR_LEN + ret_val;
+}
+
+/**
+ * cipso_v4_sock_setattr - Add a CIPSO option to a socket
+ * @sk: the socket
+ * @doi_def: the CIPSO DOI to use
+ * @secattr: the specific security attributes of the socket
+ *
+ * Description:
+ * Set the CIPSO option on the given socket using the DOI definition and
+ * security attributes passed to the function.  This function requires
+ * exclusive access to @sk, which means it either needs to be in the
+ * process of being created or locked.  Returns zero on success and negative
+ * values on failure.
+ *
+ */
+int cipso_v4_sock_setattr(struct sock *sk,
+			  const struct cipso_v4_doi *doi_def,
+			  const struct netlbl_lsm_secattr *secattr)
+{
+	int ret_val = -EPERM;
+	unsigned char *buf = NULL;
+	u32 buf_len;
+	u32 opt_len;
+	struct ip_options *opt = NULL;
+	struct inet_sock *sk_inet;
+	struct inet_connection_sock *sk_conn;
+
+	/* In the case of sock_create_lite(), the sock->sk field is not
+	 * defined yet but it is not a problem as the only users of these
+	 * "lite" PF_INET sockets are functions which do an accept() call
+	 * afterwards so we will label the socket as part of the accept(). */
+	if (sk == NULL)
+		return 0;
+
+	/* We allocate the maximum CIPSO option size here so we are probably
+	 * being a little wasteful, but it makes our life _much_ easier later
+	 * on and after all we are only talking about 40 bytes. */
+	buf_len = CIPSO_V4_OPT_LEN_MAX;
+	buf = kmalloc(buf_len, GFP_ATOMIC);
+	if (buf == NULL) {
+		ret_val = -ENOMEM;
+		goto socket_setattr_failure;
+	}
+
+	ret_val = cipso_v4_genopt(buf, buf_len, doi_def, secattr);
+	if (ret_val < 0)
+		goto socket_setattr_failure;
+	buf_len = ret_val;
 
 	/* We can't use ip_options_get() directly because it makes a call to
 	 * ip_options_get_alloc() which allocates memory with GFP_KERNEL and
@@ -1854,6 +1881,123 @@ int cipso_v4_sock_getattr(struct sock *sk, struct netlbl_lsm_secattr *secattr)
 }
 
 /**
+ * cipso_v4_skbuff_setattr - Set the CIPSO option on a packet
+ * @skb: the packet
+ * @secattr: the security attributes
+ *
+ * Description:
+ * Set the CIPSO option on the given packet based on the security attributes.
+ * Returns a pointer to the IP header on success and NULL on failure.
+ *
+ */
+int cipso_v4_skbuff_setattr(struct sk_buff *skb,
+			    const struct cipso_v4_doi *doi_def,
+			    const struct netlbl_lsm_secattr *secattr)
+{
+	int ret_val;
+	struct iphdr *iph;
+	struct ip_options *opt = &IPCB(skb)->opt;
+	unsigned char buf[CIPSO_V4_OPT_LEN_MAX];
+	u32 buf_len = CIPSO_V4_OPT_LEN_MAX;
+	u32 opt_len;
+	int len_delta;
+
+	buf_len = cipso_v4_genopt(buf, buf_len, doi_def, secattr);
+	if (buf_len < 0)
+		return buf_len;
+	opt_len = (buf_len + 3) & ~3;
+
+	/* we overwrite any existing options to ensure that we have enough
+	 * room for the CIPSO option, the reason is that we _need_ to guarantee
+	 * that the security label is applied to the packet - we do the same
+	 * thing when using the socket options and it hasn't caused a problem,
+	 * if we need to we can always revisit this choice later */
+
+	len_delta = opt_len - opt->optlen;
+	/* if we don't ensure enough headroom we could panic on the skb_push()
+	 * call below so make sure we have enough, we are also "mangling" the
+	 * packet so we should probably do a copy-on-write call anyway */
+	ret_val = skb_cow(skb, skb_headroom(skb) + len_delta);
+	if (ret_val < 0)
+		return ret_val;
+
+	if (len_delta > 0) {
+		/* we assume that the header + opt->optlen have already been
+		 * "pushed" in ip_options_build() or similar */
+		iph = ip_hdr(skb);
+		skb_push(skb, len_delta);
+		memmove((char *)iph - len_delta, iph, iph->ihl << 2);
+		skb_reset_network_header(skb);
+		iph = ip_hdr(skb);
+	} else if (len_delta < 0) {
+		iph = ip_hdr(skb);
+		memset(iph + 1, IPOPT_NOP, opt->optlen);
+	} else
+		iph = ip_hdr(skb);
+
+	if (opt->optlen > 0)
+		memset(opt, 0, sizeof(*opt));
+	opt->optlen = opt_len;
+	opt->cipso = sizeof(struct iphdr);
+	opt->is_changed = 1;
+
+	/* we have to do the following because we are being called from a
+	 * netfilter hook which means the packet already has had the header
+	 * fields populated and the checksum calculated - yes this means we
+	 * are doing more work than needed but we do it to keep the core
+	 * stack clean and tidy */
+	memcpy(iph + 1, buf, buf_len);
+	if (opt_len > buf_len)
+		memset((char *)(iph + 1) + buf_len, 0, opt_len - buf_len);
+	if (len_delta != 0) {
+		iph->ihl = 5 + (opt_len >> 2);
+		iph->tot_len = htons(skb->len);
+	}
+	ip_send_check(iph);
+
+	return 0;
+}
+
+/**
+ * cipso_v4_skbuff_delattr - Delete any CIPSO options from a packet
+ * @skb: the packet
+ *
+ * Description:
+ * Removes any and all CIPSO options from the given packet.  Returns zero on
+ * success, negative values on failure.
+ *
+ */
+int cipso_v4_skbuff_delattr(struct sk_buff *skb)
+{
+	int ret_val;
+	struct iphdr *iph;
+	struct ip_options *opt = &IPCB(skb)->opt;
+	unsigned char *cipso_ptr;
+
+	if (opt->cipso == 0)
+		return 0;
+
+	/* since we are changing the packet we should make a copy */
+	ret_val = skb_cow(skb, skb_headroom(skb));
+	if (ret_val < 0)
+		return ret_val;
+
+	/* the easiest thing to do is just replace the cipso option with noop
+	 * options since we don't change the size of the packet, although we
+	 * still need to recalculate the checksum */
+
+	iph = ip_hdr(skb);
+	cipso_ptr = (unsigned char *)iph + opt->cipso;
+	memset(cipso_ptr, IPOPT_NOOP, cipso_ptr[1]);
+	opt->cipso = 0;
+	opt->is_changed = 1;
+
+	ip_send_check(iph);
+
+	return 0;
+}
+
+/**
  * cipso_v4_skbuff_getattr - Get the security attributes from the CIPSO option
  * @skb: the packet
  * @secattr: the security attributes
diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index a0c69e5..7d3575b 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -474,6 +474,66 @@ int netlbl_sock_getattr(struct sock *sk, struct netlbl_lsm_secattr *secattr)
 }
 
 /**
+ * netlbl_skbuff_setattr - Label a packet using the correct protocol
+ * @skb: the packet
+ * @family: protocol family
+ * @secattr: the security attributes
+ *
+ * Description:
+ * Attach the correct label to the given packet using the security attributes
+ * specified in @secattr.  Returns zero on success, negative values on failure.
+ *
+ */
+int netlbl_skbuff_setattr(struct sk_buff *skb,
+			  u16 family,
+			  const struct netlbl_lsm_secattr *secattr)
+{
+	int ret_val;
+	struct iphdr *hdr4;
+	struct netlbl_domaddr4_map *af4_entry;
+
+	rcu_read_lock();
+	switch (family) {
+	case AF_INET:
+		hdr4 = ip_hdr(skb);
+		af4_entry = netlbl_domhsh_getentry_af4(secattr->domain,
+						       hdr4->daddr);
+		if (af4_entry == NULL) {
+			ret_val = -ENOENT;
+			goto skbuff_setattr_return;
+		}
+		switch (af4_entry->type) {
+		case NETLBL_NLTYPE_CIPSOV4:
+			ret_val = cipso_v4_skbuff_setattr(skb,
+						   af4_entry->type_def.cipsov4,
+						   secattr);
+			break;
+		case NETLBL_NLTYPE_UNLABELED:
+			/* just delete the protocols we support for right now
+			 * but we could remove other protocols if needed */
+			ret_val = cipso_v4_skbuff_delattr(skb);
+			break;
+		default:
+			ret_val = -ENOENT;
+		}
+		break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case AF_INET6:
+		/* since we don't support any IPv6 labeling protocols right
+		 * now we can optimize everything away until we do */
+		ret_val = 0;
+		break;
+#endif /* IPv6 */
+	default:
+		ret_val = 0;
+	}
+
+skbuff_setattr_return:
+	rcu_read_unlock();
+	return ret_val;
+}
+
+/**
  * netlbl_skbuff_getattr - Determine the security attributes of a packet
  * @skb: the packet
  * @family: protocol family
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index a09956d..b8da37a 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -4395,13 +4395,15 @@ static unsigned int selinux_ip_forward(struct sk_buff *skb, int ifindex,
 	u32 peer_sid;
 	struct avc_audit_data ad;
 	u8 secmark_active;
+	u8 netlbl_active;
 	u8 peerlbl_active;
 
 	if (!selinux_policycap_netpeer)
 		return NF_ACCEPT;
 
 	secmark_active = selinux_secmark_enabled();
-	peerlbl_active = netlbl_enabled() || selinux_xfrm_enabled();
+	netlbl_active = netlbl_enabled();
+	peerlbl_active = netlbl_active || selinux_xfrm_enabled();
 	if (!secmark_active && !peerlbl_active)
 		return NF_ACCEPT;
 
@@ -4428,6 +4430,14 @@ static unsigned int selinux_ip_forward(struct sk_buff *skb, int ifindex,
 				 SECCLASS_PACKET, PACKET__FORWARD_IN, &ad))
 			return NF_DROP;
 
+	if (netlbl_active)
+		/* we do this in the LOCAL_OUT path and not the POST_ROUTING
+		 * path because we want to make sure we apply the necessary
+		 * labeling before IPsec is applied so we can leverage AH
+		 * protection */
+		if (selinux_netlbl_skbuff_setsid(skb, family, peer_sid) != 0)
+			return NF_DROP;
+
 	return NF_ACCEPT;
 }
 
@@ -4451,6 +4461,37 @@ static unsigned int selinux_ipv6_forward(unsigned int hooknum,
 }
 #endif	/* IPV6 */
 
+static unsigned int selinux_ip_output(struct sk_buff *skb,
+				      u16 family)
+{
+	u32 sid;
+
+	if (!netlbl_enabled())
+		return NF_ACCEPT;
+
+	/* we do this in the LOCAL_OUT path and not the POST_ROUTING path
+	 * because we want to make sure we apply the necessary labeling
+	 * before IPsec is applied so we can leverage AH protection */
+	if (skb->sk) {
+		struct sk_security_struct *sksec = skb->sk->sk_security;
+		sid = sksec->sid;
+	} else
+		sid = SECINITSID_KERNEL;
+	if (selinux_netlbl_skbuff_setsid(skb, family, sid) != 0)
+		return NF_DROP;
+
+	return NF_ACCEPT;
+}
+
+static unsigned int selinux_ipv4_output(unsigned int hooknum,
+					struct sk_buff *skb,
+					const struct net_device *in,
+					const struct net_device *out,
+					int (*okfn)(struct sk_buff *))
+{
+	return selinux_ip_output(skb, PF_INET);
+}
+
 static int selinux_ip_postroute_iptables_compat(struct sock *sk,
 						int ifindex,
 						struct avc_audit_data *ad,
@@ -5688,6 +5729,13 @@ static struct nf_hook_ops selinux_ipv4_ops[] = {
 		.pf =		PF_INET,
 		.hooknum =	NF_INET_FORWARD,
 		.priority =	NF_IP_PRI_SELINUX_FIRST,
+	},
+	{
+		.hook =		selinux_ipv4_output,
+		.owner =	THIS_MODULE,
+		.pf =		PF_INET,
+		.hooknum =	NF_INET_LOCAL_OUT,
+		.priority =	NF_IP_PRI_SELINUX_FIRST,
 	}
 };
 
diff --git a/security/selinux/include/netlabel.h b/security/selinux/include/netlabel.h
index d4e3ac8..b3e6ae0 100644
--- a/security/selinux/include/netlabel.h
+++ b/security/selinux/include/netlabel.h
@@ -48,6 +48,9 @@ int selinux_netlbl_skbuff_getsid(struct sk_buff *skb,
 				 u16 family,
 				 u32 *type,
 				 u32 *sid);
+int selinux_netlbl_skbuff_setsid(struct sk_buff *skb,
+				 u16 family,
+				 u32 sid);
 
 void selinux_netlbl_sock_graft(struct sock *sk, struct socket *sock);
 int selinux_netlbl_socket_post_create(struct socket *sock);
@@ -88,6 +91,12 @@ static inline int selinux_netlbl_skbuff_getsid(struct sk_buff *skb,
 	*sid = SECSID_NULL;
 	return 0;
 }
+static inline int selinux_netlbl_skbuff_setsid(struct sk_buff *skb,
+					       u16 family,
+					       u32 sid)
+{
+	return 0;
+}
 
 static inline void selinux_netlbl_sock_graft(struct sock *sk,
 					     struct socket *sock)
diff --git a/security/selinux/include/objsec.h b/security/selinux/include/objsec.h
index 91070ab..f46dd1c 100644
--- a/security/selinux/include/objsec.h
+++ b/security/selinux/include/objsec.h
@@ -117,6 +117,7 @@ struct sk_security_struct {
 		NLBL_UNSET = 0,
 		NLBL_REQUIRE,
 		NLBL_LABELED,
+		NLBL_REQSKB,
 	} nlbl_state;
 #endif
 };
diff --git a/security/selinux/netlabel.c b/security/selinux/netlabel.c
index 0207bd2..1b19357 100644
--- a/security/selinux/netlabel.c
+++ b/security/selinux/netlabel.c
@@ -9,7 +9,7 @@
  */
 
 /*
- * (c) Copyright Hewlett-Packard Development Company, L.P., 2007
+ * (c) Copyright Hewlett-Packard Development Company, L.P., 2007, 2008
  *
  * This program is free software;  you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -85,8 +85,15 @@ static int selinux_netlbl_sock_setsid(struct sock *sk, u32 sid)
 	if (rc != 0)
 		goto sock_setsid_return;
 	rc = netlbl_sock_setattr(sk, &secattr);
-	if (rc == 0)
+	switch (rc) {
+	case 0:
 		sksec->nlbl_state = NLBL_LABELED;
+		break;
+	case -EDESTADDRREQ:
+		sksec->nlbl_state = NLBL_REQSKB;
+		rc = 0;
+		break;
+	}
 
 sock_setsid_return:
 	netlbl_secattr_destroy(&secattr);
@@ -181,6 +188,45 @@ int selinux_netlbl_skbuff_getsid(struct sk_buff *skb,
 }
 
 /**
+ * selinux_netlbl_skbuff_setsid - Set the NetLabel on a packet given a sid
+ * @skb: the packet
+ * @family: protocol family
+ * @sid: the SID
+ *
+ * Description
+ * Call the NetLabel mechanism to set the label of a packet using @sid.
+ * Returns zero on auccess, negative values on failure.
+ *
+ */
+int selinux_netlbl_skbuff_setsid(struct sk_buff *skb,
+				 u16 family,
+				 u32 sid)
+{
+	int rc;
+	struct netlbl_lsm_secattr secattr;
+	struct sock *sk;
+
+	/* if this is a locally generated packet check to see if it is already
+	 * being labeled by it's parent socket, if it is just exit */
+	sk = skb->sk;
+	if (sk != NULL) {
+		struct sk_security_struct *sksec = sk->sk_security;
+		if (sksec->nlbl_state != NLBL_REQSKB)
+			return 0;
+	}
+
+	netlbl_secattr_init(&secattr);
+	rc = security_netlbl_sid_to_secattr(sid, &secattr);
+	if (rc != 0)
+		goto skbuff_setsid_return;
+	rc = netlbl_skbuff_setattr(skb, family, &secattr);
+
+skbuff_setsid_return:
+	netlbl_secattr_destroy(&secattr);
+	return rc;
+}
+
+/**
  * selinux_netlbl_sock_graft - Netlabel the new socket
  * @sk: the new connection
  * @sock: the new socket

