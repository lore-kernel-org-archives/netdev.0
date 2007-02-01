From: Shinta Sugimoto <shinta@sfc.wide.ad.jp>
Subject: [RFC][PATCH][XFRM][4/5] extension to XFRM for dynamic endpoint update (MIGRATE)
Date: Thu, 01 Feb 2007 13:10:41 +0900
Message-ID: <20070201114558.E2C3.SHINTA@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Francis Dupont <Francis.Dupont@point6.net>,
	Masahide Nakamura <nakam@linux-ipv6.org>,
	usagi-core@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sfc.wide.ad.jp ([203.178.142.146]:42353 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161160AbXBAEch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jan 2007 23:32:37 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Shinta Sugimoto <shinta@sfc.wide.ad.jp>

diff --git a/include/linux/pfkeyv2.h b/include/linux/pfkeyv2.h
index 265bafa..26a518b 100644
--- a/include/linux/pfkeyv2.h
+++ b/include/linux/pfkeyv2.h
@@ -251,7 +251,8 @@ #define SADB_X_SPDSETIDX	20
 #define SADB_X_SPDEXPIRE	21
 #define SADB_X_SPDDELETE2	22
 #define SADB_X_NAT_T_NEW_MAPPING	23
-#define SADB_MAX		23
+#define SADB_X_MIGRATE		24
+#define SADB_MAX		24
 
 /* Security Association flags */
 #define SADB_SAFLAGS_PFS	1
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 5dd5094..c13c50a 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -2345,6 +2345,159 @@ out:
 	return err;
 }
 
+#ifdef CONFIG_NET_KEY_MIGRATE
+static int parse_sockaddr_pair(struct sockaddr *sa,
+			       xfrm_address_t *saddr,
+			       xfrm_address_t *daddr,
+			       u16 *family)
+{
+	switch (sa->sa_family) {
+	case AF_INET:
+	 	{
+			struct sockaddr_in *sin;
+			sin = (struct sockaddr_in *)sa;
+			if ((sin+1)->sin_family != AF_INET)
+				return -EINVAL;
+			memcpy(&saddr->a4, &sin->sin_addr,
+			       sizeof(struct in_addr));
+			sin++;
+			memcpy(&daddr->a4, &sin->sin_addr,
+			       sizeof(struct in_addr));
+			*family = AF_INET;
+			break;
+		}
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case AF_INET6:
+		{
+			struct sockaddr_in6 *sin6;
+			sin6 = (struct sockaddr_in6 *)sa;
+			if ((sin6+1)->sin6_family != AF_INET6)
+				return -EINVAL;
+			memcpy(&saddr->a6, &sin6->sin6_addr,
+			       sizeof(struct in6_addr));
+			sin6++;
+			memcpy(&daddr->a6, &sin6->sin6_addr,
+			       sizeof(struct in6_addr));
+			*family = AF_INET6;
+			break;
+		}
+#endif
+	default:
+		return -EINVAL;
+	}
+	return 0;
+}
+
+/*
+ *   Update locators stored in a given IPsec security association.
+ *   Note that SPD as well as SAD is also updated.
+ */
+static int pfkey_migrate(struct sock *sk, struct sk_buff *skb,
+			 struct sadb_msg *hdr, void **ext_hdrs)
+{
+	int i, len, err = -EINVAL;
+	u8 dir;
+	struct sadb_address *sa;
+	struct sadb_x_policy *pol;
+	struct sadb_x_ipsecrequest *rq;
+	struct xfrm_selector sel;
+	struct xfrm_migrate m[XFRM_MAX_DEPTH];
+	struct xfrm_migrate *mp;
+
+	if (!present_and_same_family(ext_hdrs[SADB_EXT_ADDRESS_SRC - 1],
+	    ext_hdrs[SADB_EXT_ADDRESS_DST - 1]) ||
+	    !ext_hdrs[SADB_X_EXT_POLICY - 1]) {
+		err = -EINVAL;
+		goto out;
+	} 
+
+	pol = ext_hdrs[SADB_X_EXT_POLICY - 1];
+	if (!pol) {
+		err = -EINVAL;
+		goto out;
+	}
+	if (pol->sadb_x_policy_dir >= IPSEC_DIR_MAX) {
+		printk("pfkey: invalid policy dir (%d) specified.\n",
+		       pol->sadb_x_policy_dir);
+		err = -EINVAL;
+		goto out;
+	}
+	dir = pol->sadb_x_policy_dir - 1;
+	memset(&sel, 0, sizeof(sel));
+
+	/* set source address info of selector */
+	sa = ext_hdrs[SADB_EXT_ADDRESS_SRC - 1];
+	sel.family = pfkey_sadb_addr2xfrm_addr(sa, &sel.saddr);
+	sel.prefixlen_s = sa->sadb_address_prefixlen;
+	/* allow IPSEC_PROTO_ANY to match all protocols */
+	//sel.proto = pfkey_proto_to_xfrm(sa->sadb_address_proto);
+	sel.proto = sa->sadb_address_proto;
+	sel.sport = ((struct sockaddr_in *)(sa+1))->sin_port;
+	if (sel.sport)
+		sel.sport_mask = ~0;
+
+	/* set destination address info of selector */
+	sa = ext_hdrs[SADB_EXT_ADDRESS_DST - 1],
+	pfkey_sadb_addr2xfrm_addr(sa, &sel.daddr);
+	sel.prefixlen_d = sa->sadb_address_prefixlen;
+	/* allow IPSEC_PROTO_ANY to match all protocols */
+	//sel.proto = pfkey_proto_to_xfrm(sa->sadb_address_proto);
+	sel.proto = sa->sadb_address_proto;
+	sel.dport = ((struct sockaddr_in *)(sa+1))->sin_port;
+	if (sel.dport)
+		sel.dport_mask = ~0;
+
+	rq = (struct sadb_x_ipsecrequest *)(pol + 1);
+
+	/* extract ipsecrequests */
+	i = 0;
+	len = pol->sadb_x_policy_len * 8 - sizeof(struct sadb_x_policy);
+
+	while (len >= sizeof(struct sadb_x_ipsecrequest)) {
+		if (!(i % 2)) {
+			/* old endoints */
+			mp = &m[i/2];
+			parse_sockaddr_pair((struct sockaddr *)(rq + 1),
+					    &mp->old_saddr,
+					    &mp->old_daddr,
+					    &mp->old_family);
+		} else {
+			/* new endoints */
+			mp = &m[(i-1)/2];
+			parse_sockaddr_pair((struct sockaddr *)(rq + 1),
+					    &mp->new_saddr,
+					    &mp->new_daddr,
+					    &mp->new_family);
+		}
+		mp->proto = rq->sadb_x_ipsecrequest_proto;
+		mp->mode = rq->sadb_x_ipsecrequest_mode - 1;
+		mp->reqid = rq->sadb_x_ipsecrequest_reqid;
+
+		len -= rq->sadb_x_ipsecrequest_len;
+		rq = (struct sadb_x_ipsecrequest *)((u8 *)rq + rq->sadb_x_ipsecrequest_len);
+		i++;
+	}
+
+	if (!i || i % 2) {
+		printk("pfkey: invalid number (%d) of ipsecrequest(s).\n", i);
+		err = -EINVAL;
+		goto out;
+	}
+
+	return xfrm_migrate(&sel, dir, XFRM_POLICY_TYPE_MAIN, m, i/2);
+ 
+ out:
+	return err;
+}
+#else
+static int pfkey_migrate(struct sock *sk, struct sk_buff *skb,
+			 struct sadb_msg *hdr, void **ext_hdrs)
+{
+	return -ENOPROTOOPT;
+}
+#endif
+
+
 static int pfkey_spdget(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hdr, void **ext_hdrs)
 {
 	unsigned int dir;
@@ -2473,6 +2626,8 @@ static pfkey_handler pfkey_funcs[SADB_MA
 	[SADB_X_SPDFLUSH]	= pfkey_spdflush,
 	[SADB_X_SPDSETIDX]	= pfkey_spdadd,
 	[SADB_X_SPDDELETE2]	= pfkey_spdget,
+	[SADB_X_NAT_T_NEW_MAPPING] = NULL,
+	[SADB_X_MIGRATE]	= pfkey_migrate,
 };
 
 static int pfkey_process(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hdr)
@@ -3118,6 +3273,265 @@ #endif
 	return pfkey_broadcast(skb, GFP_ATOMIC, BROADCAST_REGISTERED, NULL);
 }
 
+#ifdef CONFIG_NET_KEY_MIGRATE
+static int set_sadb_address(struct sk_buff *skb, int sasize, int type,
+			    struct xfrm_selector *sel)
+{
+	struct sadb_address *addr;
+	struct sockaddr_in *sin;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	struct sockaddr_in6 *sin6;
+#endif
+	addr = (struct sadb_address *)skb_put(skb, sizeof(struct sadb_address) + sasize);
+	addr->sadb_address_len = (sizeof(struct sadb_address) + sasize)/8;
+	addr->sadb_address_exttype = type;
+	addr->sadb_address_proto = sel->proto;
+	addr->sadb_address_reserved = 0;
+
+	switch (type) {
+	case SADB_EXT_ADDRESS_SRC:
+		if (sel->family == AF_INET) {
+			addr->sadb_address_prefixlen = sel->prefixlen_s;
+			sin = (struct sockaddr_in *)(addr + 1);
+			sin->sin_family = AF_INET;
+			memcpy(&sin->sin_addr.s_addr, &sel->saddr,
+			       sizeof(struct in_addr));
+			sin->sin_port = 0;
+			memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
+		}
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		else if (sel->family == AF_INET6) {
+			addr->sadb_address_prefixlen = sel->prefixlen_s;
+			sin6 = (struct sockaddr_in6 *)(addr + 1);
+			sin6->sin6_family = AF_INET6;
+			sin6->sin6_port = 0;
+			sin6->sin6_flowinfo = 0;
+			memcpy(&sin6->sin6_addr.s6_addr, &sel->saddr,
+			       sizeof(struct in6_addr));
+		}
+#endif
+		break;
+	case SADB_EXT_ADDRESS_DST:
+        	if (sel->family == AF_INET) {
+			addr->sadb_address_prefixlen = sel->prefixlen_d;
+			sin = (struct sockaddr_in *)(addr + 1);
+			sin->sin_family = AF_INET;
+			memcpy(&sin->sin_addr.s_addr, &sel->daddr,
+			       sizeof(struct in_addr));
+			sin->sin_port = 0;
+			memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
+		}
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		else if (sel->family == AF_INET6) {
+			addr->sadb_address_prefixlen = sel->prefixlen_d;
+			sin6 = (struct sockaddr_in6 *)(addr + 1);
+			sin6->sin6_family = AF_INET6;
+			sin6->sin6_port = 0;
+			sin6->sin6_flowinfo = 0;
+			memcpy(&sin6->sin6_addr.s6_addr, &sel->daddr,
+			       sizeof(struct in6_addr));
+		}
+#endif
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int set_ipsecrequest(struct sk_buff *skb,
+			    uint8_t proto,
+			    uint8_t mode,
+			    int level,
+			    uint32_t reqid,
+			    uint8_t family,
+			    xfrm_address_t *src,
+			    xfrm_address_t *dst)
+{
+	struct sadb_x_ipsecrequest *rq;
+	struct sockaddr_in *sin;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	struct sockaddr_in6 *sin6;
+#endif
+	int sasize;
+	int size_req;
+
+	sasize = pfkey_sockaddr_size(family);
+	if (!sasize)
+		return -EINVAL;
+	size_req = sizeof(struct sadb_x_ipsecrequest) + sasize * 2;
+
+	rq = (struct sadb_x_ipsecrequest *)skb_put(skb, size_req);
+	memset(rq, 0, size_req);
+	rq->sadb_x_ipsecrequest_len = size_req;
+	rq->sadb_x_ipsecrequest_proto = proto;
+	rq->sadb_x_ipsecrequest_mode = mode;
+	rq->sadb_x_ipsecrequest_level = level;
+	rq->sadb_x_ipsecrequest_reserved1 = 0;
+	rq->sadb_x_ipsecrequest_reqid = reqid;
+	rq->sadb_x_ipsecrequest_reserved2 = 0;
+
+	switch (family) {
+	case AF_INET:
+		sin = (struct sockaddr_in *)(rq + 1);
+		sin->sin_family = AF_INET;
+		memcpy(&sin->sin_addr.s_addr, src, sizeof(struct in_addr));
+		sin++;
+		sin->sin_family = AF_INET;
+		memcpy(&sin->sin_addr.s_addr, dst, sizeof(struct in_addr));
+		break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case AF_INET6:	
+		sin6 = (struct sockaddr_in6 *)(rq + 1);
+		sin6->sin6_family = AF_INET6;
+		sin6->sin6_port = 0;
+		sin6->sin6_flowinfo = 0;
+		sin6->sin6_scope_id = 0;
+		memcpy(&sin6->sin6_addr.s6_addr, src, sizeof(struct in6_addr));
+		sin6++;
+		sin6->sin6_family = AF_INET6;
+		sin6->sin6_port = 0;
+		sin6->sin6_flowinfo = 0;
+		sin6->sin6_scope_id = 0;
+		memcpy(&sin6->sin6_addr.s6_addr, dst, sizeof(struct in6_addr));
+		break;
+#endif
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+#endif
+
+#ifdef CONFIG_NET_KEY_MIGRATE
+static int pfkey_send_migrate(struct xfrm_selector *sel,
+			      u8 dir,
+			      u8 type,
+			      struct xfrm_migrate *m,
+			      int num_bundles) 
+{
+	int i;
+	int sasize_sel;
+	int sasize_lp_old;
+	int sasize_lp_new;
+	int size = 0;
+	int size_pol = 0;
+	struct sk_buff *skb;
+	struct sadb_msg *hdr;
+	struct sadb_x_policy *pol;
+	struct xfrm_migrate *mp;
+
+	if (type != XFRM_POLICY_TYPE_MAIN)
+		return 0;
+
+	if (num_bundles <= 0 || num_bundles > XFRM_MAX_DEPTH)
+		return -EINVAL;
+
+	/* selector */
+	sasize_sel = pfkey_sockaddr_size(sel->family);
+	if (!sasize_sel)
+		return -EINVAL;
+	size += (sizeof(struct sadb_address) + sasize_sel) * 2;
+
+	/* policy info */
+	size_pol += sizeof(struct sadb_x_policy);
+
+	/* ipsecrequests */
+	for (i=0, mp=m; i<num_bundles; i++, mp++) {
+		/* old locator pair */
+		sasize_lp_old = pfkey_sockaddr_size(mp->old_family);
+		if (!sasize_lp_old) {
+			printk("pfkey: invalid sockaddr size specified\n");
+			return -EINVAL;
+		}
+		size_pol += sizeof(struct sadb_x_ipsecrequest) + sasize_lp_old * 2;
+		/* new locator pair */
+		sasize_lp_new = pfkey_sockaddr_size(mp->new_family);
+		if (!sasize_lp_new) {
+			printk("pfkey: invalid sockaddr size specified\n");
+			return -EINVAL;
+		}
+		size_pol += sizeof(struct sadb_x_ipsecrequest) + sasize_lp_new * 2;
+	}
+
+	size += sizeof(struct sadb_msg) + size_pol;
+
+	/* alloc buffer */
+	skb = alloc_skb(size, GFP_ATOMIC);
+	if (skb == NULL)
+		return -ENOMEM;
+
+	hdr = (struct sadb_msg *)skb_put(skb, sizeof(struct sadb_msg));
+	hdr->sadb_msg_version = PF_KEY_V2;
+	hdr->sadb_msg_type = SADB_X_MIGRATE;
+	hdr->sadb_msg_satype = pfkey_proto2satype(m->proto);
+	hdr->sadb_msg_len = size/8;
+	hdr->sadb_msg_errno = 0;
+	hdr->sadb_msg_reserved = 0;
+	hdr->sadb_msg_seq = 0;
+	hdr->sadb_msg_pid = 0;
+
+	/* selector src */
+	set_sadb_address(skb, sasize_sel, SADB_EXT_ADDRESS_SRC, sel);
+
+	/* selector dst */
+	set_sadb_address(skb, sasize_sel, SADB_EXT_ADDRESS_DST, sel);
+
+	/* policy information */
+	pol = (struct sadb_x_policy *)skb_put(skb, sizeof(struct sadb_x_policy));
+	pol->sadb_x_policy_len = size_pol/8;
+	pol->sadb_x_policy_exttype = SADB_X_EXT_POLICY;
+	pol->sadb_x_policy_type = IPSEC_POLICY_IPSEC;
+	pol->sadb_x_policy_dir = dir + 1;
+	pol->sadb_x_policy_id = 0;
+	pol->sadb_x_policy_priority = 0;
+
+	for (i=0, mp=m; i<num_bundles; i++, mp++) {
+		/* old ipsecrequest */
+		if (set_ipsecrequest(skb,
+				     mp->proto,
+				     mp->mode + 1,
+				     (mp->reqid ?  IPSEC_LEVEL_UNIQUE : IPSEC_LEVEL_REQUIRE),
+				     mp->reqid,
+				     mp->old_family,
+				     &mp->old_saddr,
+				     &mp->old_daddr) < 0) {
+			printk("pfkey: failed to set old ipsecrequest\n");
+			return -EINVAL;
+		}
+
+		/* new ipsecrequest */
+		if (set_ipsecrequest(skb,
+				     mp->proto,
+				     mp->mode + 1,
+				     (mp->reqid ? IPSEC_LEVEL_UNIQUE : IPSEC_LEVEL_REQUIRE),
+				     mp->reqid,
+				     mp->new_family,
+				     &mp->new_saddr,
+				     &mp->new_daddr) < 0) {
+			printk("pfkey: failed to set new ipsecrequest\n");
+			return -EINVAL;
+		}
+	}
+
+	/* broadcast migrate message to sockets */
+	pfkey_broadcast(skb, GFP_ATOMIC, BROADCAST_ALL, NULL);
+
+	return 0;
+}
+#else
+static int pfkey_send_migrate(struct xfrm_selector *sel,
+			      u8 dir,
+			      u8 type,
+			      struct xfrm_migrate *m,
+			      int num_bundles) 
+{
+	return -ENOPROTOOPT;
+}
+#endif
+
 static int pfkey_sendmsg(struct kiocb *kiocb,
 			 struct socket *sock, struct msghdr *msg, size_t len)
 {
@@ -3287,6 +3701,7 @@ static struct xfrm_mgr pfkeyv2_mgr =
 	.compile_policy	= pfkey_compile_policy,
 	.new_mapping	= pfkey_send_new_mapping,
 	.notify_policy	= pfkey_send_policy_notify,
+	.migrate	= pfkey_send_migrate,
 };
 
 static void __exit ipsec_pfkey_exit(void)

