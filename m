From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 2/3] ila: xlat changes
Date: Fri, 15 Apr 2016 13:34:11 -0700
Message-ID: <1460752452-3328784-3-git-send-email-tom@herbertland.com>
References: <1460752452-3328784-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:13966 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751142AbcDOUeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 16:34:25 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u3FKVjLl031076
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 13:34:25 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22b5qsgead-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 13:34:25 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 70b1b68e034911e6acee0002c99331b0-bbd6c50 for <netdev@vger.kernel.org>;	Fri,
 15 Apr 2016 13:34:24 -0700
In-Reply-To: <1460752452-3328784-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change model of xlat to be used only for input where lookup is done on
the locator part of an address (comparing to locator_match as key
in rhashtable). This is needed for checksum neutral translation
which obfuscates the low order 16 bits of the identifier. It also
permits hosts to be in muliple ILA domains (each locator can map
to a different SIR address). A check is also added to disallow
translating non-ILA addresses (check of type in identifier).

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/ila/ila_xlat.c | 102 ++++++++++++++++--------------------------------
 1 file changed, 34 insertions(+), 68 deletions(-)

diff --git a/net/ipv6/ila/ila_xlat.c b/net/ipv6/ila/ila_xlat.c
index 075c782..d17d429 100644
--- a/net/ipv6/ila/ila_xlat.c
+++ b/net/ipv6/ila/ila_xlat.c
@@ -11,9 +11,7 @@
 
 struct ila_xlat_params {
 	struct ila_params ip;
-	struct ila_identifier identifier;
 	int ifindex;
-	unsigned int dir;
 };
 
 struct ila_map {
@@ -66,35 +64,29 @@ static __always_inline void __ila_hash_secret_init(void)
 	net_get_random_once(&hashrnd, sizeof(hashrnd));
 }
 
-static inline u32 ila_identifier_hash(struct ila_identifier ident)
+static inline u32 ila_locator_hash(struct ila_locator loc)
 {
-	u32 *v = (u32 *)ident.v32;
+	u32 *v = (u32 *)loc.v32;
 
 	return jhash_2words(v[0], v[1], hashrnd);
 }
 
 static inline spinlock_t *ila_get_lock(struct ila_net *ilan,
-				       struct ila_identifier ident)
+				       struct ila_locator loc)
 {
-	return &ilan->locks[ila_identifier_hash(ident) & ilan->locks_mask];
+	return &ilan->locks[ila_locator_hash(loc) & ilan->locks_mask];
 }
 
 static inline int ila_cmp_wildcards(struct ila_map *ila,
-				    struct ila_addr *iaddr, int ifindex,
-				    unsigned int dir)
+				    struct ila_addr *iaddr, int ifindex)
 {
-	return (ila->xp.ip.locator_match.v64 &&
-		ila->xp.ip.locator_match.v64 != iaddr->loc.v64) ||
-	       (ila->xp.ifindex && ila->xp.ifindex != ifindex) ||
-	       !(ila->xp.dir & dir);
+	return (ila->xp.ifindex && ila->xp.ifindex != ifindex);
 }
 
 static inline int ila_cmp_params(struct ila_map *ila,
 				 struct ila_xlat_params *xp)
 {
-	return (ila->xp.ip.locator_match.v64 != xp->ip.locator_match.v64) ||
-	       (ila->xp.ifindex != xp->ifindex) ||
-	       (ila->xp.dir != xp->dir);
+	return (ila->xp.ifindex != xp->ifindex);
 }
 
 static int ila_cmpfn(struct rhashtable_compare_arg *arg,
@@ -102,16 +94,13 @@ static int ila_cmpfn(struct rhashtable_compare_arg *arg,
 {
 	const struct ila_map *ila = obj;
 
-	return (ila->xp.identifier.v64 != *(__be64 *)arg->key);
+	return (ila->xp.ip.locator_match.v64 != *(__be64 *)arg->key);
 }
 
 static inline int ila_order(struct ila_map *ila)
 {
 	int score = 0;
 
-	if (ila->xp.ip.locator_match.v64)
-		score += 1 << 0;
-
 	if (ila->xp.ifindex)
 		score += 1 << 1;
 
@@ -121,7 +110,7 @@ static inline int ila_order(struct ila_map *ila)
 static const struct rhashtable_params rht_params = {
 	.nelem_hint = 1024,
 	.head_offset = offsetof(struct ila_map, node),
-	.key_offset = offsetof(struct ila_map, xp.identifier),
+	.key_offset = offsetof(struct ila_map, xp.ip.locator_match),
 	.key_len = sizeof(u64), /* identifier */
 	.max_size = 1048576,
 	.min_size = 256,
@@ -140,11 +129,9 @@ static struct genl_family ila_nl_family = {
 };
 
 static struct nla_policy ila_nl_policy[ILA_ATTR_MAX + 1] = {
-	[ILA_ATTR_IDENTIFIER] = { .type = NLA_U64, },
 	[ILA_ATTR_LOCATOR] = { .type = NLA_U64, },
 	[ILA_ATTR_LOCATOR_MATCH] = { .type = NLA_U64, },
 	[ILA_ATTR_IFINDEX] = { .type = NLA_U32, },
-	[ILA_ATTR_DIR] = { .type = NLA_U32, },
 };
 
 static int parse_nl_config(struct genl_info *info,
@@ -152,10 +139,6 @@ static int parse_nl_config(struct genl_info *info,
 {
 	memset(xp, 0, sizeof(*xp));
 
-	if (info->attrs[ILA_ATTR_IDENTIFIER])
-		xp->identifier.v64 = (__force __be64)nla_get_u64(
-			info->attrs[ILA_ATTR_IDENTIFIER]);
-
 	if (info->attrs[ILA_ATTR_LOCATOR])
 		xp->ip.locator.v64 = (__force __be64)nla_get_u64(
 			info->attrs[ILA_ATTR_LOCATOR]);
@@ -167,24 +150,20 @@ static int parse_nl_config(struct genl_info *info,
 	if (info->attrs[ILA_ATTR_IFINDEX])
 		xp->ifindex = nla_get_s32(info->attrs[ILA_ATTR_IFINDEX]);
 
-	if (info->attrs[ILA_ATTR_DIR])
-		xp->dir = nla_get_u32(info->attrs[ILA_ATTR_DIR]);
-
 	return 0;
 }
 
 /* Must be called with rcu readlock */
 static inline struct ila_map *ila_lookup_wildcards(struct ila_addr *iaddr,
 						   int ifindex,
-						   unsigned int dir,
 						   struct ila_net *ilan)
 {
 	struct ila_map *ila;
 
-	ila = rhashtable_lookup_fast(&ilan->rhash_table, &iaddr->ident,
+	ila = rhashtable_lookup_fast(&ilan->rhash_table, &iaddr->loc,
 				     rht_params);
 	while (ila) {
-		if (!ila_cmp_wildcards(ila, iaddr, ifindex, dir))
+		if (!ila_cmp_wildcards(ila, iaddr, ifindex))
 			return ila;
 		ila = rcu_access_pointer(ila->next);
 	}
@@ -198,7 +177,8 @@ static inline struct ila_map *ila_lookup_by_params(struct ila_xlat_params *xp,
 {
 	struct ila_map *ila;
 
-	ila = rhashtable_lookup_fast(&ilan->rhash_table, &xp->identifier,
+	ila = rhashtable_lookup_fast(&ilan->rhash_table,
+				     &xp->ip.locator_match,
 				     rht_params);
 	while (ila) {
 		if (!ila_cmp_params(ila, xp))
@@ -226,14 +206,14 @@ static void ila_free_cb(void *ptr, void *arg)
 	}
 }
 
-static int ila_xlat_addr(struct sk_buff *skb, int dir);
+static int ila_xlat_addr(struct sk_buff *skb);
 
 static unsigned int
 ila_nf_input(void *priv,
 	     struct sk_buff *skb,
 	     const struct nf_hook_state *state)
 {
-	ila_xlat_addr(skb, ILA_DIR_IN);
+	ila_xlat_addr(skb);
 	return NF_ACCEPT;
 }
 
@@ -250,7 +230,7 @@ static int ila_add_mapping(struct net *net, struct ila_xlat_params *xp)
 {
 	struct ila_net *ilan = net_generic(net, ila_net_id);
 	struct ila_map *ila, *head;
-	spinlock_t *lock = ila_get_lock(ilan, xp->identifier);
+	spinlock_t *lock = ila_get_lock(ilan, xp->ip.locator_match);
 	int err = 0, order;
 
 	if (!ilan->hooks_registered) {
@@ -271,20 +251,19 @@ static int ila_add_mapping(struct net *net, struct ila_xlat_params *xp)
 
 	ila->xp = *xp;
 
-	if (xp->ip.locator_match.v64) {
-		/* Precompute checksum difference for translation since we
-		 * know both the old identifier and the new one.
-		 */
-		ila->xp.ip.csum_diff = compute_csum_diff8(
-			(__be32 *)&xp->ip.locator_match,
-			(__be32 *)&xp->ip.locator);
-	}
+	/* Precompute checksum difference for translation since we
+	 * know both the old identifier and the new one.
+	 */
+	ila->xp.ip.csum_diff = compute_csum_diff8(
+		(__be32 *)&xp->ip.locator_match,
+		(__be32 *)&xp->ip.locator);
 
 	order = ila_order(ila);
 
 	spin_lock(lock);
 
-	head = rhashtable_lookup_fast(&ilan->rhash_table, &xp->identifier,
+	head = rhashtable_lookup_fast(&ilan->rhash_table,
+				      &xp->ip.locator_match,
 				      rht_params);
 	if (!head) {
 		/* New entry for the rhash_table */
@@ -335,13 +314,13 @@ static int ila_del_mapping(struct net *net, struct ila_xlat_params *xp)
 {
 	struct ila_net *ilan = net_generic(net, ila_net_id);
 	struct ila_map *ila, *head, *prev;
-	spinlock_t *lock = ila_get_lock(ilan, xp->identifier);
+	spinlock_t *lock = ila_get_lock(ilan, xp->ip.locator_match);
 	int err = -ENOENT;
 
 	spin_lock(lock);
 
 	head = rhashtable_lookup_fast(&ilan->rhash_table,
-				      &xp->identifier, rht_params);
+				      &xp->ip.locator_match, rht_params);
 	ila = head;
 
 	prev = NULL;
@@ -423,14 +402,11 @@ static int ila_nl_cmd_del_mapping(struct sk_buff *skb, struct genl_info *info)
 
 static int ila_fill_info(struct ila_map *ila, struct sk_buff *msg)
 {
-	if (nla_put_u64(msg, ILA_ATTR_IDENTIFIER,
-			(__force u64)ila->xp.identifier.v64) ||
-	    nla_put_u64(msg, ILA_ATTR_LOCATOR,
+	if (nla_put_u64(msg, ILA_ATTR_LOCATOR,
 			(__force u64)ila->xp.ip.locator.v64) ||
 	    nla_put_u64(msg, ILA_ATTR_LOCATOR_MATCH,
 			(__force u64)ila->xp.ip.locator_match.v64) ||
-	    nla_put_s32(msg, ILA_ATTR_IFINDEX, ila->xp.ifindex) ||
-	    nla_put_u32(msg, ILA_ATTR_DIR, ila->xp.dir))
+	    nla_put_s32(msg, ILA_ATTR_IFINDEX, ila->xp.ifindex))
 		return -1;
 
 	return 0;
@@ -619,22 +595,24 @@ static struct pernet_operations ila_net_ops = {
 	.size = sizeof(struct ila_net),
 };
 
-static int ila_xlat_addr(struct sk_buff *skb, int dir)
+static int ila_xlat_addr(struct sk_buff *skb)
 {
 	struct ila_map *ila;
 	struct ipv6hdr *ip6h = ipv6_hdr(skb);
 	struct net *net = dev_net(skb->dev);
 	struct ila_net *ilan = net_generic(net, ila_net_id);
 	struct ila_addr *iaddr = ila_a2i(&ip6h->daddr);
-	size_t nhoff;
 
 	/* Assumes skb contains a valid IPv6 header that is pulled */
 
-	nhoff = sizeof(struct ipv6hdr);
+	if (!ila_addr_is_ila(iaddr)) {
+		/* Type indicates this is not an ILA address */
+		return 0;
+	}
 
 	rcu_read_lock();
 
-	ila = ila_lookup_wildcards(iaddr, skb->dev->ifindex, dir, ilan);
+	ila = ila_lookup_wildcards(iaddr, skb->dev->ifindex, ilan);
 	if (ila)
 		ila_update_ipv6_locator(skb, &ila->xp.ip);
 
@@ -643,18 +621,6 @@ static int ila_xlat_addr(struct sk_buff *skb, int dir)
 	return 0;
 }
 
-int ila_xlat_incoming(struct sk_buff *skb)
-{
-	return ila_xlat_addr(skb, ILA_DIR_IN);
-}
-EXPORT_SYMBOL(ila_xlat_incoming);
-
-int ila_xlat_outgoing(struct sk_buff *skb)
-{
-	return ila_xlat_addr(skb, ILA_DIR_OUT);
-}
-EXPORT_SYMBOL(ila_xlat_outgoing);
-
 int ila_xlat_init(void)
 {
 	int ret;
-- 
2.8.0.rc2
