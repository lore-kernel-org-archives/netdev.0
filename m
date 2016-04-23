From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 3/3] ila: add checksum neutral ILA translations
Date: Sat, 23 Apr 2016 11:46:57 -0700
Message-ID: <1461437217-1568717-4-git-send-email-tom@herbertland.com>
References: <1461437217-1568717-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:48767 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752000AbcDWSrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Apr 2016 14:47:09 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u3NIl0jG018646
	for <netdev@vger.kernel.org>; Sat, 23 Apr 2016 11:47:08 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22g6r4135h-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Sat, 23 Apr 2016 11:47:08 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 c7426f76098311e6a32a0002c9521c9e-a3bbbc50 for <netdev@vger.kernel.org>;	Sat,
 23 Apr 2016 11:47:07 -0700
In-Reply-To: <1461437217-1568717-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support checksum neutral ILA as described in the ILA draft. The low
order 16 bits of the identifier are used to contain the checksum
adjustment value.

The csum-mode parameter is added to described checksum processing. There
are three values:
 - adjust transport checksum (previous behavior)
 - do checksum neutral mapping
 - do nothing

On output the csum-mode in the ila_params is checked and acted on. If
mode is checksum neutral mapping then to mapping and set C-bit.

On input, C-bit is checked. If it is set checksum-netural mapping is
done (regardless of csum-mode in ila params) and C-bit will be cleared.
If it is not set then action in csum-mode is taken.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/uapi/linux/ila.h  |  7 +++++
 net/ipv6/ila/ila.h        | 16 ++++++++--
 net/ipv6/ila/ila_common.c | 74 +++++++++++++++++++++++++++++++++++++++++++++--
 net/ipv6/ila/ila_lwt.c    | 14 +++++++--
 net/ipv6/ila/ila_xlat.c   | 16 +++++-----
 5 files changed, 112 insertions(+), 15 deletions(-)

diff --git a/include/uapi/linux/ila.h b/include/uapi/linux/ila.h
index abde7bb..8ac61b8 100644
--- a/include/uapi/linux/ila.h
+++ b/include/uapi/linux/ila.h
@@ -14,6 +14,7 @@ enum {
 	ILA_ATTR_LOCATOR_MATCH,			/* u64 */
 	ILA_ATTR_IFINDEX,			/* s32 */
 	ILA_ATTR_DIR,				/* u32 */
+	ILA_ATTR_CSUM_MODE,			/* u8 */
 
 	__ILA_ATTR_MAX,
 };
@@ -34,4 +35,10 @@ enum {
 #define ILA_DIR_IN	(1 << 0)
 #define ILA_DIR_OUT	(1 << 1)
 
+enum {
+	ILA_CSUM_ADJUST_TRANSPORT,
+	ILA_CSUM_NEUTRAL_MAP,
+	ILA_CSUM_NO_ACTION,
+};
+
 #endif /* _UAPI_LINUX_ILA_H */
diff --git a/net/ipv6/ila/ila.h b/net/ipv6/ila/ila.h
index f532967..d08fd2d 100644
--- a/net/ipv6/ila/ila.h
+++ b/net/ipv6/ila/ila.h
@@ -36,11 +36,13 @@ struct ila_identifier {
 	union {
 		struct {
 #if defined(__LITTLE_ENDIAN_BITFIELD)
-			u8 __space:5;
+			u8 __space:4;
+			u8 csum_neutral:1;
 			u8 type:3;
 #elif defined(__BIG_ENDIAN_BITFIELD)
 			u8 type:3;
-			u8 __space:5;
+			u8 csum_neutral:1;
+			u8 __space:4;
 #else
 #error  "Adjust your <asm/byteorder.h> defines"
 #endif
@@ -64,6 +66,8 @@ enum {
 	ILA_ATYPE_RSVD_3,
 };
 
+#define CSUM_NEUTRAL_FLAG	htonl(0x10000000)
+
 struct ila_addr {
 	union {
 		struct in6_addr addr;
@@ -88,6 +92,7 @@ struct ila_params {
 	struct ila_locator locator;
 	struct ila_locator locator_match;
 	__wsum csum_diff;
+	u8 csum_mode;
 };
 
 static inline __wsum compute_csum_diff8(const __be32 *from, const __be32 *to)
@@ -99,8 +104,15 @@ static inline __wsum compute_csum_diff8(const __be32 *from, const __be32 *to)
 	return csum_partial(diff, sizeof(diff), 0);
 }
 
+static inline bool ila_csum_neutral_set(struct ila_identifier ident)
+{
+	return !!(ident.csum_neutral);
+}
+
 void ila_update_ipv6_locator(struct sk_buff *skb, struct ila_params *p);
 
+void ila_init_saved_csum(struct ila_params *p);
+
 int ila_lwt_init(void);
 void ila_lwt_fini(void);
 int ila_xlat_init(void);
diff --git a/net/ipv6/ila/ila_common.c b/net/ipv6/ila/ila_common.c
index c3078d0..0e94042 100644
--- a/net/ipv6/ila/ila_common.c
+++ b/net/ipv6/ila/ila_common.c
@@ -17,21 +17,50 @@ static __wsum get_csum_diff(struct ipv6hdr *ip6h, struct ila_params *p)
 {
 	struct ila_addr *iaddr = ila_a2i(&ip6h->daddr);
 
-	if (iaddr->loc.v64 == p->locator_match.v64)
+	if (p->locator_match.v64)
 		return p->csum_diff;
 	else
 		return compute_csum_diff8((__be32 *)&iaddr->loc,
 					  (__be32 *)&p->locator);
 }
 
-void ila_update_ipv6_locator(struct sk_buff *skb, struct ila_params *p)
+static void ila_csum_do_neutral(struct ila_addr *iaddr,
+				struct ila_params *p)
+{
+	__sum16 *adjust = (__force __sum16 *)&iaddr->ident.v16[3];
+	__wsum diff, fval;
+
+	/* Check if checksum adjust value has been cached */
+	if (p->locator_match.v64) {
+		diff = p->csum_diff;
+	} else {
+		diff = compute_csum_diff8((__be32 *)iaddr,
+					  (__be32 *)&p->locator);
+	}
+
+	fval = (__force __wsum)(ila_csum_neutral_set(iaddr->ident) ?
+			~CSUM_NEUTRAL_FLAG : CSUM_NEUTRAL_FLAG);
+
+	diff = csum_add(diff, fval);
+
+	*adjust = ~csum_fold(csum_add(diff, csum_unfold(*adjust)));
+
+	/* Flip the csum-neutral bit. Either we are doing a SIR->ILA
+	 * translation with ILA_CSUM_NEUTRAL_MAP as the csum_method
+	 * and the C-bit is not set, or we are doing an ILA-SIR
+	 * tranlsation and the C-bit is set.
+	 */
+	iaddr->ident.csum_neutral ^= 1;
+}
+
+static void ila_csum_adjust_transport(struct sk_buff *skb,
+				      struct ila_params *p)
 {
 	__wsum diff;
 	struct ipv6hdr *ip6h = ipv6_hdr(skb);
 	struct ila_addr *iaddr = ila_a2i(&ip6h->daddr);
 	size_t nhoff = sizeof(struct ipv6hdr);
 
-	/* First update checksum */
 	switch (ip6h->nexthdr) {
 	case NEXTHDR_TCP:
 		if (likely(pskb_may_pull(skb, nhoff + sizeof(struct tcphdr)))) {
@@ -74,6 +103,45 @@ void ila_update_ipv6_locator(struct sk_buff *skb, struct ila_params *p)
 	iaddr->loc = p->locator;
 }
 
+void ila_update_ipv6_locator(struct sk_buff *skb, struct ila_params *p)
+{
+	struct ipv6hdr *ip6h = ipv6_hdr(skb);
+	struct ila_addr *iaddr = ila_a2i(&ip6h->daddr);
+
+	/* First deal with the transport checksum */
+	if (ila_csum_neutral_set(iaddr->ident)) {
+		/* C-bit is set in the locator indicating that this
+		 * is a locator being translated to a SIR address.
+		 * Perform (receiver) checksum-neutral translation.
+		 */
+		ila_csum_do_neutral(iaddr, p);
+	} else {
+		switch (p->csum_mode) {
+		case ILA_CSUM_ADJUST_TRANSPORT:
+			ila_csum_adjust_transport(skb, p);
+			break;
+		case ILA_CSUM_NEUTRAL_MAP:
+			ila_csum_do_neutral(iaddr, p);
+			break;
+		case ILA_CSUM_NO_ACTION:
+			break;
+		}
+	}
+
+	/* Now change destination address */
+	iaddr->loc = p->locator;
+}
+
+void ila_init_saved_csum(struct ila_params *p)
+{
+	if (!p->locator_match.v64)
+		return;
+
+	p->csum_diff = compute_csum_diff8(
+				(__be32 *)&p->locator_match,
+				(__be32 *)&p->locator);
+}
+
 static int __init ila_init(void)
 {
 	int ret;
diff --git a/net/ipv6/ila/ila_lwt.c b/net/ipv6/ila/ila_lwt.c
index 71c79fc..e81e39a 100644
--- a/net/ipv6/ila/ila_lwt.c
+++ b/net/ipv6/ila/ila_lwt.c
@@ -53,6 +53,7 @@ drop:
 
 static struct nla_policy ila_nl_policy[ILA_ATTR_MAX + 1] = {
 	[ILA_ATTR_LOCATOR] = { .type = NLA_U64, },
+	[ILA_ATTR_CSUM_MODE] = { .type = NLA_U8, },
 };
 
 static int ila_build_state(struct net_device *dev, struct nlattr *nla,
@@ -79,8 +80,10 @@ static int ila_build_state(struct net_device *dev, struct nlattr *nla,
 
 	iaddr = (struct ila_addr *)&cfg6->fc_dst;
 
-	if (!ila_addr_is_ila(iaddr)) {
-		/* Don't allow setting a translation for a non-ILA address */
+	if (!ila_addr_is_ila(iaddr) || ila_csum_neutral_set(iaddr->ident)) {
+		/* Don't allow translation for a non-ILA address or checksum
+		 * neutral flag to be set.
+		 */
 		return -EINVAL;
 	}
 
@@ -108,6 +111,11 @@ static int ila_build_state(struct net_device *dev, struct nlattr *nla,
 	p->csum_diff = compute_csum_diff8(
 		(__be32 *)&p->locator_match, (__be32 *)&p->locator);
 
+	if (tb[ILA_ATTR_CSUM_MODE])
+		p->csum_mode = nla_get_u8(tb[ILA_ATTR_CSUM_MODE]);
+
+	ila_init_saved_csum(p);
+
 	newts->type = LWTUNNEL_ENCAP_ILA;
 	newts->flags |= LWTUNNEL_STATE_OUTPUT_REDIRECT |
 			LWTUNNEL_STATE_INPUT_REDIRECT;
@@ -124,6 +132,8 @@ static int ila_fill_encap_info(struct sk_buff *skb,
 
 	if (nla_put_u64(skb, ILA_ATTR_LOCATOR, (__force u64)p->locator.v64))
 		goto nla_put_failure;
+	if (nla_put_u64(skb, ILA_ATTR_CSUM_MODE, (__force u8)p->csum_mode))
+		goto nla_put_failure;
 
 	return 0;
 
diff --git a/net/ipv6/ila/ila_xlat.c b/net/ipv6/ila/ila_xlat.c
index d17d429..c0323a2 100644
--- a/net/ipv6/ila/ila_xlat.c
+++ b/net/ipv6/ila/ila_xlat.c
@@ -132,6 +132,7 @@ static struct nla_policy ila_nl_policy[ILA_ATTR_MAX + 1] = {
 	[ILA_ATTR_LOCATOR] = { .type = NLA_U64, },
 	[ILA_ATTR_LOCATOR_MATCH] = { .type = NLA_U64, },
 	[ILA_ATTR_IFINDEX] = { .type = NLA_U32, },
+	[ILA_ATTR_CSUM_MODE] = { .type = NLA_U8, },
 };
 
 static int parse_nl_config(struct genl_info *info,
@@ -147,6 +148,9 @@ static int parse_nl_config(struct genl_info *info,
 		xp->ip.locator_match.v64 = (__force __be64)nla_get_u64(
 			info->attrs[ILA_ATTR_LOCATOR_MATCH]);
 
+	if (info->attrs[ILA_ATTR_CSUM_MODE])
+		xp->ip.csum_mode = nla_get_u8(info->attrs[ILA_ATTR_CSUM_MODE]);
+
 	if (info->attrs[ILA_ATTR_IFINDEX])
 		xp->ifindex = nla_get_s32(info->attrs[ILA_ATTR_IFINDEX]);
 
@@ -249,14 +253,9 @@ static int ila_add_mapping(struct net *net, struct ila_xlat_params *xp)
 	if (!ila)
 		return -ENOMEM;
 
-	ila->xp = *xp;
+	ila_init_saved_csum(&xp->ip);
 
-	/* Precompute checksum difference for translation since we
-	 * know both the old identifier and the new one.
-	 */
-	ila->xp.ip.csum_diff = compute_csum_diff8(
-		(__be32 *)&xp->ip.locator_match,
-		(__be32 *)&xp->ip.locator);
+	ila->xp = *xp;
 
 	order = ila_order(ila);
 
@@ -406,7 +405,8 @@ static int ila_fill_info(struct ila_map *ila, struct sk_buff *msg)
 			(__force u64)ila->xp.ip.locator.v64) ||
 	    nla_put_u64(msg, ILA_ATTR_LOCATOR_MATCH,
 			(__force u64)ila->xp.ip.locator_match.v64) ||
-	    nla_put_s32(msg, ILA_ATTR_IFINDEX, ila->xp.ifindex))
+	    nla_put_s32(msg, ILA_ATTR_IFINDEX, ila->xp.ifindex) ||
+	    nla_put_u32(msg, ILA_ATTR_CSUM_MODE, ila->xp.ip.csum_mode))
 		return -1;
 
 	return 0;
-- 
2.8.0.rc2
