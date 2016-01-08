From: Huw Davies <huw@codeweavers.com>
Subject: [RFC PATCH v2 14/18] calipso: Allow the lsm to label the skbuff directly.
Date: Fri,  8 Jan 2016 09:52:50 +0000
Message-ID: <1452246774-13241-15-git-send-email-huw@codeweavers.com>
Cc: Paul Moore <pmoore@redhat.com>
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.codeweavers.com ([216.251.189.131]:38370 "EHLO
	mail.codeweavers.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754277AbcAHJxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 04:53:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some cases, the lsm needs to add the label to the skbuff directly.
A NF_INET_LOCAL_OUT IPv6 hook is added to selinux to match the IPv4
behaviour.  This allows selinux to label the skbuffs that it requires.

Signed-off-by: Huw Davies <huw@codeweavers.com>
---
 include/net/ipv6.h              |   2 +-
 include/net/netlabel.h          |  11 +++
 net/ipv6/calipso.c              | 180 ++++++++++++++++++++++++++++++++++++++++
 net/ipv6/exthdrs_core.c         |   2 +-
 net/netlabel/netlabel_calipso.c |  82 ++++++++++++++++++
 net/netlabel/netlabel_calipso.h |   7 ++
 net/netlabel/netlabel_kapi.c    |  32 ++++++-
 security/selinux/hooks.c        |  15 ++++
 8 files changed, 325 insertions(+), 6 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 5f9c252..71b5045 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -920,7 +920,7 @@ enum {
 int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset, int target,
 		  unsigned short *fragoff, int *fragflg);
 
-int ipv6_find_tlv(struct sk_buff *skb, int offset, int type);
+int ipv6_find_tlv(const struct sk_buff *skb, int offset, int type);
 
 struct in6_addr *fl6_update_dst(struct flowi6 *fl6,
 				const struct ipv6_txoptions *opt,
diff --git a/include/net/netlabel.h b/include/net/netlabel.h
index a2408c3..0697ba2 100644
--- a/include/net/netlabel.h
+++ b/include/net/netlabel.h
@@ -231,6 +231,10 @@ struct netlbl_lsm_secattr {
  * @sock_delattr: remove the socket's attr
  * @req_setattr: set the req socket's attr
  * @req_delattr: remove the req socket's attr
+ * @optptr: find option in packet
+ * @getattr: retrieve attr from memory block
+ * @skbuff_setattr: set the skbuff's attr
+ * @skbuff_delattr: remove the skbuff's attr
  *
  * Description:
  * This structure is filled out by the CALIPSO engine and passed
@@ -258,6 +262,13 @@ struct netlbl_calipso_ops {
 			   const struct calipso_doi *doi_def,
 			   const struct netlbl_lsm_secattr *secattr);
 	void (*req_delattr)(struct request_sock *req);
+	unsigned char *(*optptr)(const struct sk_buff *skb);
+	int (*getattr)(const unsigned char *calipso,
+		       struct netlbl_lsm_secattr *secattr);
+	int (*skbuff_setattr)(struct sk_buff *skb,
+			      const struct calipso_doi *doi_def,
+			      const struct netlbl_lsm_secattr *secattr);
+	int (*skbuff_delattr)(struct sk_buff *skb);
 };
 
 /*
diff --git a/net/ipv6/calipso.c b/net/ipv6/calipso.c
index 8d832e2..1616464 100644
--- a/net/ipv6/calipso.c
+++ b/net/ipv6/calipso.c
@@ -56,6 +56,12 @@
  */
 #define CALIPSO_HDR_LEN (2 + 8)
 
+ /* Maximium size of u32 aligned buffer required to hold calipso
+  * option.  Max of 3 initial pad bytes starting from buffer + 3.
+  * i.e. the worst case is when the previous tlv finishes on 4n + 3.
+  */
+#define CALIPSO_MAX_BUFFER (6 + CALIPSO_OPT_LEN_MAX)
+
 /* List of available DOI definitions */
 static DEFINE_SPINLOCK(calipso_doi_list_lock);
 static LIST_HEAD(calipso_doi_list);
@@ -970,6 +976,176 @@ static void calipso_req_delattr(struct request_sock *req)
 	kfree(new);
 }
 
+/* skbuff functions.
+ */
+
+/**
+ * calipso_optptr - Find the CALIPSO option in the packet
+ * @skb: the packet
+ *
+ * Description:
+ * Parse the packet's IP header looking for a CALIPSO option.  Returns a pointer
+ * to the start of the CALIPSO option on success, NULL if one if not found.
+ *
+ */
+static unsigned char *calipso_optptr(const struct sk_buff *skb)
+{
+	const struct ipv6hdr *ip6_hdr = ipv6_hdr(skb);
+	int offset;
+
+	if (ip6_hdr->nexthdr != NEXTHDR_HOP)
+		return NULL;
+
+	offset = ipv6_find_tlv(skb, sizeof(*ip6_hdr), IPV6_TLV_CALIPSO);
+	if (offset >= 0)
+		return (unsigned char *)ip6_hdr + offset;
+
+	return NULL;
+}
+
+/**
+ * calipso_skbuff_setattr - Set the CALIPSO option on a packet
+ * @skb: the packet
+ * @doi_def: the CALIPSO DOI to use
+ * @secattr: the security attributes
+ *
+ * Description:
+ * Set the CALIPSO option on the given packet based on the security attributes.
+ * Returns a pointer to the IP header on success and NULL on failure.
+ *
+ */
+static int calipso_skbuff_setattr(struct sk_buff *skb,
+				  const struct calipso_doi *doi_def,
+				  const struct netlbl_lsm_secattr *secattr)
+{
+	int ret_val;
+	struct ipv6hdr *ip6_hdr;
+	struct ipv6_opt_hdr *hop;
+	unsigned char buf[CALIPSO_MAX_BUFFER];
+	int len_delta;
+	unsigned int start, end, next_opt, pad;
+
+	ip6_hdr = ipv6_hdr(skb);
+	if (ip6_hdr->nexthdr == NEXTHDR_HOP) {
+		hop = (struct ipv6_opt_hdr *)(ip6_hdr + 1);
+		ret_val = calipso_opt_find(hop, &start, &end);
+		if (ret_val && ret_val != -ENOENT)
+			return ret_val;
+		if (end != ipv6_optlen(hop))
+			next_opt = end;
+		else
+			next_opt = 0;
+		len_delta = -(int)end;
+	} else {
+		start = 0;
+		next_opt = 0;
+		len_delta = 0;
+	}
+
+	memset(buf, 0, sizeof(buf));
+	ret_val = calipso_genopt(buf, start & 3, sizeof(buf), doi_def, secattr);
+	if (ret_val < 0)
+		return ret_val;
+
+	end = start + ret_val;
+
+	if (WARN_ON_ONCE(end & 3))
+		return -EINVAL;
+
+	pad = ((end & 7) + (next_opt & 7)) & 7;
+	len_delta += end + pad;
+
+	if (WARN_ON_ONCE(len_delta & 7))
+		return -EINVAL;
+
+	ret_val = skb_cow(skb, skb_headroom(skb) + len_delta);
+	if (ret_val < 0)
+		return ret_val;
+
+	if (len_delta) {
+		if (len_delta > 0)
+			skb_push(skb, len_delta);
+		else
+			skb_pull(skb, -len_delta);
+		memmove((char *)ip6_hdr - len_delta, ip6_hdr,
+			sizeof(*ip6_hdr) + start);
+		skb_reset_network_header(skb);
+		ip6_hdr = ipv6_hdr(skb);
+	}
+
+	hop = (struct ipv6_opt_hdr *)(ip6_hdr + 1);
+	if (start == 0) {
+		struct ipv6_opt_hdr *new_hop = (struct ipv6_opt_hdr *)buf;
+
+		new_hop->nexthdr = ip6_hdr->nexthdr;
+		new_hop->hdrlen = len_delta / 8 - 1;
+		ip6_hdr->nexthdr = NEXTHDR_HOP;
+	} else {
+		hop->hdrlen += len_delta / 8;
+	}
+	memcpy((char *)hop + start, buf + (start & 3), end - start);
+	calipso_pad_write((unsigned char *)hop, end, pad);
+
+	return 0;
+}
+
+/**
+ * calipso_skbuff_delattr - Delete any CALIPSO options from a packet
+ * @skb: the packet
+ *
+ * Description:
+ * Removes any and all CALIPSO options from the given packet.  Returns zero on
+ * success, negative values on failure.
+ *
+ */
+static int calipso_skbuff_delattr(struct sk_buff *skb)
+{
+	int ret_val;
+	struct ipv6hdr *ip6_hdr;
+	struct ipv6_opt_hdr *old_hop;
+	u32 old_hop_len, start = 0, end = 0, delta, size, pad;
+
+	if (!calipso_optptr(skb))
+		return 0;
+
+	/* since we are changing the packet we should make a copy */
+	ret_val = skb_cow(skb, skb_headroom(skb));
+	if (ret_val < 0)
+		return ret_val;
+
+	ip6_hdr = ipv6_hdr(skb);
+	old_hop = (struct ipv6_opt_hdr *)(ip6_hdr + 1);
+	old_hop_len = ipv6_optlen(old_hop);
+
+	ret_val = calipso_opt_find(old_hop, &start, &end);
+	if (ret_val)
+		return ret_val;
+
+	if (start == sizeof(*old_hop) && end == old_hop_len) {
+		/* There's no other option in the header so we delete
+		 * the whole thing.
+		 */
+		delta = old_hop_len;
+		size = sizeof(*ip6_hdr);
+		ip6_hdr->nexthdr = old_hop->nexthdr;
+	} else {
+		delta = (end - start) & ~7;
+		if (delta)
+			old_hop->hdrlen -= delta / 8;
+		pad = (end - start) & 7;
+		size = sizeof(*ip6_hdr) + start + pad;
+		calipso_pad_write((unsigned char *)old_hop, start, pad);
+	}
+
+	if (delta) {
+		skb_pull(skb, delta);
+		memmove((char *)ip6_hdr + delta, ip6_hdr, size);
+		skb_reset_network_header(skb);
+	}
+
+	return 0;
+}
+
 static const struct netlbl_calipso_ops ops = {
 	.doi_add          = calipso_doi_add,
 	.doi_free         = calipso_doi_free,
@@ -982,6 +1158,10 @@ static const struct netlbl_calipso_ops ops = {
 	.sock_delattr     = calipso_sock_delattr,
 	.req_setattr      = calipso_req_setattr,
 	.req_delattr      = calipso_req_delattr,
+	.optptr           = calipso_optptr,
+	.getattr          = calipso_getattr,
+	.skbuff_setattr   = calipso_skbuff_setattr,
+	.skbuff_delattr   = calipso_skbuff_delattr,
 };
 
 /**
diff --git a/net/ipv6/exthdrs_core.c b/net/ipv6/exthdrs_core.c
index 5c5d23e..b522479 100644
--- a/net/ipv6/exthdrs_core.c
+++ b/net/ipv6/exthdrs_core.c
@@ -112,7 +112,7 @@ int ipv6_skip_exthdr(const struct sk_buff *skb, int start, u8 *nexthdrp,
 }
 EXPORT_SYMBOL(ipv6_skip_exthdr);
 
-int ipv6_find_tlv(struct sk_buff *skb, int offset, int type)
+int ipv6_find_tlv(const struct sk_buff *skb, int offset, int type)
 {
 	const unsigned char *nh = skb_network_header(skb);
 	int packet_len = skb_tail_pointer(skb) - skb_network_header(skb);
diff --git a/net/netlabel/netlabel_calipso.c b/net/netlabel/netlabel_calipso.c
index 8e1256e..f96ba60 100644
--- a/net/netlabel/netlabel_calipso.c
+++ b/net/netlabel/netlabel_calipso.c
@@ -622,3 +622,85 @@ void calipso_req_delattr(struct request_sock *req)
 	if (ops)
 		ops->req_delattr(req);
 }
+
+/**
+ * calipso_optptr - Find the CALIPSO option in the packet
+ * @skb: the packet
+ *
+ * Description:
+ * Parse the packet's IP header looking for a CALIPSO option.  Returns a pointer
+ * to the start of the CALIPSO option on success, NULL if one if not found.
+ *
+ */
+unsigned char *calipso_optptr(const struct sk_buff *skb)
+{
+	unsigned char *ret_val = NULL;
+	const struct netlbl_calipso_ops *ops = netlbl_calipso_ops_get();
+
+	if (ops)
+		ret_val = ops->optptr(skb);
+	return ret_val;
+}
+
+/**
+ * calipso_getattr - Get the security attributes from a memory block.
+ * @calipso: the CALIPSO option
+ * @secattr: the security attributes
+ *
+ * Description:
+ * Inspect @calipso and return the security attributes in @secattr.
+ * Returns zero on success and negative values on failure.
+ *
+ */
+int calipso_getattr(const unsigned char *calipso,
+		    struct netlbl_lsm_secattr *secattr)
+{
+	int ret_val = -ENOMSG;
+	const struct netlbl_calipso_ops *ops = netlbl_calipso_ops_get();
+
+	if (ops)
+		ret_val = ops->getattr(calipso, secattr);
+	return ret_val;
+}
+
+/**
+ * calipso_skbuff_setattr - Set the CALIPSO option on a packet
+ * @skb: the packet
+ * @doi_def: the CALIPSO DOI to use
+ * @secattr: the security attributes
+ *
+ * Description:
+ * Set the CALIPSO option on the given packet based on the security attributes.
+ * Returns a pointer to the IP header on success and NULL on failure.
+ *
+ */
+int calipso_skbuff_setattr(struct sk_buff *skb,
+			   const struct calipso_doi *doi_def,
+			   const struct netlbl_lsm_secattr *secattr)
+{
+	int ret_val = -ENOMSG;
+	const struct netlbl_calipso_ops *ops = netlbl_calipso_ops_get();
+
+	if (ops)
+		ret_val = ops->skbuff_setattr(skb, doi_def, secattr);
+	return ret_val;
+}
+
+/**
+ * calipso_skbuff_delattr - Delete any CALIPSO options from a packet
+ * @skb: the packet
+ *
+ * Description:
+ * Removes any and all CALIPSO options from the given packet.  Returns zero on
+ * success, negative values on failure.
+ *
+ */
+int calipso_skbuff_delattr(struct sk_buff *skb)
+{
+	int ret_val = -ENOMSG;
+	const struct netlbl_calipso_ops *ops = netlbl_calipso_ops_get();
+
+	if (ops)
+		ret_val = ops->skbuff_delattr(skb);
+	return ret_val;
+}
diff --git a/net/netlabel/netlabel_calipso.h b/net/netlabel/netlabel_calipso.h
index 9b8ef26..34a5f82 100644
--- a/net/netlabel/netlabel_calipso.h
+++ b/net/netlabel/netlabel_calipso.h
@@ -139,5 +139,12 @@ int calipso_req_setattr(struct request_sock *req,
 			const struct calipso_doi *doi_def,
 			const struct netlbl_lsm_secattr *secattr);
 void calipso_req_delattr(struct request_sock *req);
+unsigned char *calipso_optptr(const struct sk_buff *skb);
+int calipso_getattr(const unsigned char *calipso,
+		    struct netlbl_lsm_secattr *secattr);
+int calipso_skbuff_setattr(struct sk_buff *skb,
+			   const struct calipso_doi *doi_def,
+			   const struct netlbl_lsm_secattr *secattr);
+int calipso_skbuff_delattr(struct sk_buff *skb);
 
 #endif
diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index 71ebef0..bace474 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -1148,13 +1148,17 @@ int netlbl_skbuff_setattr(struct sk_buff *skb,
 {
 	int ret_val;
 	struct iphdr *hdr4;
+#if IS_ENABLED(CONFIG_IPV6)
+	struct ipv6hdr *hdr6;
+#endif
 	struct netlbl_dommap_def *entry;
 
 	rcu_read_lock();
 	switch (family) {
 	case AF_INET:
 		hdr4 = ip_hdr(skb);
-		entry = netlbl_domhsh_getentry_af4(secattr->domain,hdr4->daddr);
+		entry = netlbl_domhsh_getentry_af4(secattr->domain,
+						   hdr4->daddr);
 		if (entry == NULL) {
 			ret_val = -ENOENT;
 			goto skbuff_setattr_return;
@@ -1175,9 +1179,26 @@ int netlbl_skbuff_setattr(struct sk_buff *skb,
 		break;
 #if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
-		/* since we don't support any IPv6 labeling protocols right
-		 * now we can optimize everything away until we do */
-		ret_val = 0;
+		hdr6 = ipv6_hdr(skb);
+		entry = netlbl_domhsh_getentry_af6(secattr->domain,
+						   &hdr6->daddr);
+		if (entry == NULL) {
+			ret_val = -ENOENT;
+			goto skbuff_setattr_return;
+		}
+		switch (entry->type) {
+		case NETLBL_NLTYPE_CALIPSO:
+			ret_val = calipso_skbuff_setattr(skb, entry->calipso,
+							 secattr);
+			break;
+		case NETLBL_NLTYPE_UNLABELED:
+			/* just delete the protocols we support for right now
+			 * but we could remove other protocols if needed */
+			ret_val = calipso_skbuff_delattr(skb);
+			break;
+		default:
+			ret_val = -ENOENT;
+		}
 		break;
 #endif /* IPv6 */
 	default:
@@ -1216,6 +1237,9 @@ int netlbl_skbuff_getattr(const struct sk_buff *skb,
 		break;
 #if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
+		ptr = calipso_optptr(skb);
+		if (ptr && calipso_getattr(ptr, secattr) == 0)
+			return 0;
 		break;
 #endif /* IPv6 */
 	}
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index d0cfaa9..6124da6 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -4929,6 +4929,15 @@ static unsigned int selinux_ipv4_output(void *priv,
 	return selinux_ip_output(skb, PF_INET);
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static unsigned int selinux_ipv6_output(void *priv,
+					struct sk_buff *skb,
+					const struct nf_hook_state *state)
+{
+	return selinux_ip_output(skb, PF_INET6);
+}
+#endif	/* IPV6 */
+
 static unsigned int selinux_ip_postroute_compat(struct sk_buff *skb,
 						int ifindex,
 						u16 family)
@@ -6159,6 +6168,12 @@ static struct nf_hook_ops selinux_nf_ops[] = {
 		.hooknum =	NF_INET_FORWARD,
 		.priority =	NF_IP6_PRI_SELINUX_FIRST,
 	},
+	{
+		.hook =		selinux_ipv6_output,
+		.pf =		NFPROTO_IPV6,
+		.hooknum =	NF_INET_LOCAL_OUT,
+		.priority =	NF_IP6_PRI_SELINUX_FIRST,
+	},
 #endif	/* IPV6 */
 };
 
-- 
1.8.0
