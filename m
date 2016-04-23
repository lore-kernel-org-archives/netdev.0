From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 1/3] ila: Add struct definitions and helpers
Date: Sat, 23 Apr 2016 11:46:55 -0700
Message-ID: <1461437217-1568717-2-git-send-email-tom@herbertland.com>
References: <1461437217-1568717-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:46495 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751742AbcDWSrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Apr 2016 14:47:07 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u3NIiB9X009214
	for <netdev@vger.kernel.org>; Sat, 23 Apr 2016 11:47:06 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 22g4v9saxm-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Sat, 23 Apr 2016 11:47:06 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 c5702864098311e6a32a0002c9521c9e-a3bbbc50 for <netdev@vger.kernel.org>;	Sat,
 23 Apr 2016 11:47:04 -0700
In-Reply-To: <1461437217-1568717-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add structures for identifiers, locators, and an ila address which
is composed of a locator and identifier and in6_addr can be cast to
it. This includes a three bit type field and enums for the types defined
in ILA I-D.

In ILA lwt don't allow user to set a translation for a non-ILA
address (type of identifier is zero meaning it is an IID). This also
requires that the destination prefix is at least 65 bytes (64
bit locator and first byte of identifier).

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/ila/ila.h        |  67 ++++++++++++++++++++++--
 net/ipv6/ila/ila_common.c |  11 ++--
 net/ipv6/ila/ila_lwt.c    |  39 +++++++++-----
 net/ipv6/ila/ila_xlat.c   | 126 +++++++++++++++++++++++-----------------------
 4 files changed, 161 insertions(+), 82 deletions(-)

diff --git a/net/ipv6/ila/ila.h b/net/ipv6/ila/ila.h
index 28542cb..f532967 100644
--- a/net/ipv6/ila/ila.h
+++ b/net/ipv6/ila/ila.h
@@ -23,9 +23,70 @@
 #include <net/protocol.h>
 #include <uapi/linux/ila.h>
 
+struct ila_locator {
+	union {
+		__u8            v8[8];
+		__be16          v16[4];
+		__be32          v32[2];
+		__be64		v64;
+	};
+};
+
+struct ila_identifier {
+	union {
+		struct {
+#if defined(__LITTLE_ENDIAN_BITFIELD)
+			u8 __space:5;
+			u8 type:3;
+#elif defined(__BIG_ENDIAN_BITFIELD)
+			u8 type:3;
+			u8 __space:5;
+#else
+#error  "Adjust your <asm/byteorder.h> defines"
+#endif
+			u8 __space2[7];
+		};
+		__u8            v8[8];
+		__be16          v16[4];
+		__be32          v32[2];
+		__be64		v64;
+	};
+};
+
+enum {
+	ILA_ATYPE_IID = 0,
+	ILA_ATYPE_LUID,
+	ILA_ATYPE_VIRT_V4,
+	ILA_ATYPE_VIRT_UNI_V6,
+	ILA_ATYPE_VIRT_MULTI_V6,
+	ILA_ATYPE_RSVD_1,
+	ILA_ATYPE_RSVD_2,
+	ILA_ATYPE_RSVD_3,
+};
+
+struct ila_addr {
+	union {
+		struct in6_addr addr;
+		struct {
+			struct ila_locator loc;
+			struct ila_identifier ident;
+		};
+	};
+};
+
+static inline struct ila_addr *ila_a2i(struct in6_addr *addr)
+{
+	return (struct ila_addr *)addr;
+}
+
+static inline bool ila_addr_is_ila(struct ila_addr *iaddr)
+{
+	return (iaddr->ident.type != ILA_ATYPE_IID);
+}
+
 struct ila_params {
-	__be64 locator;
-	__be64 locator_match;
+	struct ila_locator locator;
+	struct ila_locator locator_match;
 	__wsum csum_diff;
 };
 
@@ -38,7 +99,7 @@ static inline __wsum compute_csum_diff8(const __be32 *from, const __be32 *to)
 	return csum_partial(diff, sizeof(diff), 0);
 }
 
-void update_ipv6_locator(struct sk_buff *skb, struct ila_params *p);
+void ila_update_ipv6_locator(struct sk_buff *skb, struct ila_params *p);
 
 int ila_lwt_init(void);
 void ila_lwt_fini(void);
diff --git a/net/ipv6/ila/ila_common.c b/net/ipv6/ila/ila_common.c
index 3061305..c3078d0 100644
--- a/net/ipv6/ila/ila_common.c
+++ b/net/ipv6/ila/ila_common.c
@@ -15,17 +15,20 @@
 
 static __wsum get_csum_diff(struct ipv6hdr *ip6h, struct ila_params *p)
 {
-	if (*(__be64 *)&ip6h->daddr == p->locator_match)
+	struct ila_addr *iaddr = ila_a2i(&ip6h->daddr);
+
+	if (iaddr->loc.v64 == p->locator_match.v64)
 		return p->csum_diff;
 	else
-		return compute_csum_diff8((__be32 *)&ip6h->daddr,
+		return compute_csum_diff8((__be32 *)&iaddr->loc,
 					  (__be32 *)&p->locator);
 }
 
-void update_ipv6_locator(struct sk_buff *skb, struct ila_params *p)
+void ila_update_ipv6_locator(struct sk_buff *skb, struct ila_params *p)
 {
 	__wsum diff;
 	struct ipv6hdr *ip6h = ipv6_hdr(skb);
+	struct ila_addr *iaddr = ila_a2i(&ip6h->daddr);
 	size_t nhoff = sizeof(struct ipv6hdr);
 
 	/* First update checksum */
@@ -68,7 +71,7 @@ void update_ipv6_locator(struct sk_buff *skb, struct ila_params *p)
 	}
 
 	/* Now change destination address */
-	*(__be64 *)&ip6h->daddr = p->locator;
+	iaddr->loc = p->locator;
 }
 
 static int __init ila_init(void)
diff --git a/net/ipv6/ila/ila_lwt.c b/net/ipv6/ila/ila_lwt.c
index 2ae3c4f..71c79fc 100644
--- a/net/ipv6/ila/ila_lwt.c
+++ b/net/ipv6/ila/ila_lwt.c
@@ -26,7 +26,7 @@ static int ila_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 	if (skb->protocol != htons(ETH_P_IPV6))
 		goto drop;
 
-	update_ipv6_locator(skb, ila_params_lwtunnel(dst->lwtstate));
+	ila_update_ipv6_locator(skb, ila_params_lwtunnel(dst->lwtstate));
 
 	return dst->lwtstate->orig_output(net, sk, skb);
 
@@ -42,7 +42,7 @@ static int ila_input(struct sk_buff *skb)
 	if (skb->protocol != htons(ETH_P_IPV6))
 		goto drop;
 
-	update_ipv6_locator(skb, ila_params_lwtunnel(dst->lwtstate));
+	ila_update_ipv6_locator(skb, ila_params_lwtunnel(dst->lwtstate));
 
 	return dst->lwtstate->orig_input(skb);
 
@@ -64,11 +64,26 @@ static int ila_build_state(struct net_device *dev, struct nlattr *nla,
 	size_t encap_len = sizeof(*p);
 	struct lwtunnel_state *newts;
 	const struct fib6_config *cfg6 = cfg;
+	struct ila_addr *iaddr;
 	int ret;
 
 	if (family != AF_INET6)
 		return -EINVAL;
 
+	if (cfg6->fc_dst_len < sizeof(struct ila_locator) + 1) {
+		/* Need to have full locator and at least type field
+		 * included in destination
+		 */
+		return -EINVAL;
+	}
+
+	iaddr = (struct ila_addr *)&cfg6->fc_dst;
+
+	if (!ila_addr_is_ila(iaddr)) {
+		/* Don't allow setting a translation for a non-ILA address */
+		return -EINVAL;
+	}
+
 	ret = nla_parse_nested(tb, ILA_ATTR_MAX, nla,
 			       ila_nl_policy);
 	if (ret < 0)
@@ -84,16 +99,14 @@ static int ila_build_state(struct net_device *dev, struct nlattr *nla,
 	newts->len = encap_len;
 	p = ila_params_lwtunnel(newts);
 
-	p->locator = (__force __be64)nla_get_u64(tb[ILA_ATTR_LOCATOR]);
+	p->locator.v64 = (__force __be64)nla_get_u64(tb[ILA_ATTR_LOCATOR]);
 
-	if (cfg6->fc_dst_len > sizeof(__be64)) {
-		/* Precompute checksum difference for translation since we
-		 * know both the old locator and the new one.
-		 */
-		p->locator_match = *(__be64 *)&cfg6->fc_dst;
-		p->csum_diff = compute_csum_diff8(
-			(__be32 *)&p->locator_match, (__be32 *)&p->locator);
-	}
+	/* Precompute checksum difference for translation since we
+	 * know both the old locator and the new one.
+	 */
+	p->locator_match = iaddr->loc;
+	p->csum_diff = compute_csum_diff8(
+		(__be32 *)&p->locator_match, (__be32 *)&p->locator);
 
 	newts->type = LWTUNNEL_ENCAP_ILA;
 	newts->flags |= LWTUNNEL_STATE_OUTPUT_REDIRECT |
@@ -109,7 +122,7 @@ static int ila_fill_encap_info(struct sk_buff *skb,
 {
 	struct ila_params *p = ila_params_lwtunnel(lwtstate);
 
-	if (nla_put_u64(skb, ILA_ATTR_LOCATOR, (__force u64)p->locator))
+	if (nla_put_u64(skb, ILA_ATTR_LOCATOR, (__force u64)p->locator.v64))
 		goto nla_put_failure;
 
 	return 0;
@@ -129,7 +142,7 @@ static int ila_encap_cmp(struct lwtunnel_state *a, struct lwtunnel_state *b)
 	struct ila_params *a_p = ila_params_lwtunnel(a);
 	struct ila_params *b_p = ila_params_lwtunnel(b);
 
-	return (a_p->locator != b_p->locator);
+	return (a_p->locator.v64 != b_p->locator.v64);
 }
 
 static const struct lwtunnel_encap_ops ila_encap_ops = {
diff --git a/net/ipv6/ila/ila_xlat.c b/net/ipv6/ila/ila_xlat.c
index 0b03533..075c782 100644
--- a/net/ipv6/ila/ila_xlat.c
+++ b/net/ipv6/ila/ila_xlat.c
@@ -11,13 +11,13 @@
 
 struct ila_xlat_params {
 	struct ila_params ip;
-	__be64 identifier;
+	struct ila_identifier identifier;
 	int ifindex;
 	unsigned int dir;
 };
 
 struct ila_map {
-	struct ila_xlat_params p;
+	struct ila_xlat_params xp;
 	struct rhash_head node;
 	struct ila_map __rcu *next;
 	struct rcu_head rcu;
@@ -66,31 +66,35 @@ static __always_inline void __ila_hash_secret_init(void)
 	net_get_random_once(&hashrnd, sizeof(hashrnd));
 }
 
-static inline u32 ila_identifier_hash(__be64 identifier)
+static inline u32 ila_identifier_hash(struct ila_identifier ident)
 {
-	u32 *v = (u32 *)&identifier;
+	u32 *v = (u32 *)ident.v32;
 
 	return jhash_2words(v[0], v[1], hashrnd);
 }
 
-static inline spinlock_t *ila_get_lock(struct ila_net *ilan, __be64 identifier)
+static inline spinlock_t *ila_get_lock(struct ila_net *ilan,
+				       struct ila_identifier ident)
 {
-	return &ilan->locks[ila_identifier_hash(identifier) & ilan->locks_mask];
+	return &ilan->locks[ila_identifier_hash(ident) & ilan->locks_mask];
 }
 
-static inline int ila_cmp_wildcards(struct ila_map *ila, __be64 loc,
-				    int ifindex, unsigned int dir)
+static inline int ila_cmp_wildcards(struct ila_map *ila,
+				    struct ila_addr *iaddr, int ifindex,
+				    unsigned int dir)
 {
-	return (ila->p.ip.locator_match && ila->p.ip.locator_match != loc) ||
-	       (ila->p.ifindex && ila->p.ifindex != ifindex) ||
-	       !(ila->p.dir & dir);
+	return (ila->xp.ip.locator_match.v64 &&
+		ila->xp.ip.locator_match.v64 != iaddr->loc.v64) ||
+	       (ila->xp.ifindex && ila->xp.ifindex != ifindex) ||
+	       !(ila->xp.dir & dir);
 }
 
-static inline int ila_cmp_params(struct ila_map *ila, struct ila_xlat_params *p)
+static inline int ila_cmp_params(struct ila_map *ila,
+				 struct ila_xlat_params *xp)
 {
-	return (ila->p.ip.locator_match != p->ip.locator_match) ||
-	       (ila->p.ifindex != p->ifindex) ||
-	       (ila->p.dir != p->dir);
+	return (ila->xp.ip.locator_match.v64 != xp->ip.locator_match.v64) ||
+	       (ila->xp.ifindex != xp->ifindex) ||
+	       (ila->xp.dir != xp->dir);
 }
 
 static int ila_cmpfn(struct rhashtable_compare_arg *arg,
@@ -98,17 +102,17 @@ static int ila_cmpfn(struct rhashtable_compare_arg *arg,
 {
 	const struct ila_map *ila = obj;
 
-	return (ila->p.identifier != *(__be64 *)arg->key);
+	return (ila->xp.identifier.v64 != *(__be64 *)arg->key);
 }
 
 static inline int ila_order(struct ila_map *ila)
 {
 	int score = 0;
 
-	if (ila->p.ip.locator_match)
+	if (ila->xp.ip.locator_match.v64)
 		score += 1 << 0;
 
-	if (ila->p.ifindex)
+	if (ila->xp.ifindex)
 		score += 1 << 1;
 
 	return score;
@@ -117,7 +121,7 @@ static inline int ila_order(struct ila_map *ila)
 static const struct rhashtable_params rht_params = {
 	.nelem_hint = 1024,
 	.head_offset = offsetof(struct ila_map, node),
-	.key_offset = offsetof(struct ila_map, p.identifier),
+	.key_offset = offsetof(struct ila_map, xp.identifier),
 	.key_len = sizeof(u64), /* identifier */
 	.max_size = 1048576,
 	.min_size = 256,
@@ -144,42 +148,43 @@ static struct nla_policy ila_nl_policy[ILA_ATTR_MAX + 1] = {
 };
 
 static int parse_nl_config(struct genl_info *info,
-			   struct ila_xlat_params *p)
+			   struct ila_xlat_params *xp)
 {
-	memset(p, 0, sizeof(*p));
+	memset(xp, 0, sizeof(*xp));
 
 	if (info->attrs[ILA_ATTR_IDENTIFIER])
-		p->identifier = (__force __be64)nla_get_u64(
+		xp->identifier.v64 = (__force __be64)nla_get_u64(
 			info->attrs[ILA_ATTR_IDENTIFIER]);
 
 	if (info->attrs[ILA_ATTR_LOCATOR])
-		p->ip.locator = (__force __be64)nla_get_u64(
+		xp->ip.locator.v64 = (__force __be64)nla_get_u64(
 			info->attrs[ILA_ATTR_LOCATOR]);
 
 	if (info->attrs[ILA_ATTR_LOCATOR_MATCH])
-		p->ip.locator_match = (__force __be64)nla_get_u64(
+		xp->ip.locator_match.v64 = (__force __be64)nla_get_u64(
 			info->attrs[ILA_ATTR_LOCATOR_MATCH]);
 
 	if (info->attrs[ILA_ATTR_IFINDEX])
-		p->ifindex = nla_get_s32(info->attrs[ILA_ATTR_IFINDEX]);
+		xp->ifindex = nla_get_s32(info->attrs[ILA_ATTR_IFINDEX]);
 
 	if (info->attrs[ILA_ATTR_DIR])
-		p->dir = nla_get_u32(info->attrs[ILA_ATTR_DIR]);
+		xp->dir = nla_get_u32(info->attrs[ILA_ATTR_DIR]);
 
 	return 0;
 }
 
 /* Must be called with rcu readlock */
-static inline struct ila_map *ila_lookup_wildcards(__be64 id, __be64 loc,
+static inline struct ila_map *ila_lookup_wildcards(struct ila_addr *iaddr,
 						   int ifindex,
 						   unsigned int dir,
 						   struct ila_net *ilan)
 {
 	struct ila_map *ila;
 
-	ila = rhashtable_lookup_fast(&ilan->rhash_table, &id, rht_params);
+	ila = rhashtable_lookup_fast(&ilan->rhash_table, &iaddr->ident,
+				     rht_params);
 	while (ila) {
-		if (!ila_cmp_wildcards(ila, loc, ifindex, dir))
+		if (!ila_cmp_wildcards(ila, iaddr, ifindex, dir))
 			return ila;
 		ila = rcu_access_pointer(ila->next);
 	}
@@ -188,15 +193,15 @@ static inline struct ila_map *ila_lookup_wildcards(__be64 id, __be64 loc,
 }
 
 /* Must be called with rcu readlock */
-static inline struct ila_map *ila_lookup_by_params(struct ila_xlat_params *p,
+static inline struct ila_map *ila_lookup_by_params(struct ila_xlat_params *xp,
 						   struct ila_net *ilan)
 {
 	struct ila_map *ila;
 
-	ila = rhashtable_lookup_fast(&ilan->rhash_table, &p->identifier,
+	ila = rhashtable_lookup_fast(&ilan->rhash_table, &xp->identifier,
 				     rht_params);
 	while (ila) {
-		if (!ila_cmp_params(ila, p))
+		if (!ila_cmp_params(ila, xp))
 			return ila;
 		ila = rcu_access_pointer(ila->next);
 	}
@@ -241,11 +246,11 @@ static struct nf_hook_ops ila_nf_hook_ops[] __read_mostly = {
 	},
 };
 
-static int ila_add_mapping(struct net *net, struct ila_xlat_params *p)
+static int ila_add_mapping(struct net *net, struct ila_xlat_params *xp)
 {
 	struct ila_net *ilan = net_generic(net, ila_net_id);
 	struct ila_map *ila, *head;
-	spinlock_t *lock = ila_get_lock(ilan, p->identifier);
+	spinlock_t *lock = ila_get_lock(ilan, xp->identifier);
 	int err = 0, order;
 
 	if (!ilan->hooks_registered) {
@@ -264,22 +269,22 @@ static int ila_add_mapping(struct net *net, struct ila_xlat_params *p)
 	if (!ila)
 		return -ENOMEM;
 
-	ila->p = *p;
+	ila->xp = *xp;
 
-	if (p->ip.locator_match) {
+	if (xp->ip.locator_match.v64) {
 		/* Precompute checksum difference for translation since we
 		 * know both the old identifier and the new one.
 		 */
-		ila->p.ip.csum_diff = compute_csum_diff8(
-			(__be32 *)&p->ip.locator_match,
-			(__be32 *)&p->ip.locator);
+		ila->xp.ip.csum_diff = compute_csum_diff8(
+			(__be32 *)&xp->ip.locator_match,
+			(__be32 *)&xp->ip.locator);
 	}
 
 	order = ila_order(ila);
 
 	spin_lock(lock);
 
-	head = rhashtable_lookup_fast(&ilan->rhash_table, &p->identifier,
+	head = rhashtable_lookup_fast(&ilan->rhash_table, &xp->identifier,
 				      rht_params);
 	if (!head) {
 		/* New entry for the rhash_table */
@@ -289,7 +294,7 @@ static int ila_add_mapping(struct net *net, struct ila_xlat_params *p)
 		struct ila_map *tila = head, *prev = NULL;
 
 		do {
-			if (!ila_cmp_params(tila, p)) {
+			if (!ila_cmp_params(tila, xp)) {
 				err = -EEXIST;
 				goto out;
 			}
@@ -326,23 +331,23 @@ out:
 	return err;
 }
 
-static int ila_del_mapping(struct net *net, struct ila_xlat_params *p)
+static int ila_del_mapping(struct net *net, struct ila_xlat_params *xp)
 {
 	struct ila_net *ilan = net_generic(net, ila_net_id);
 	struct ila_map *ila, *head, *prev;
-	spinlock_t *lock = ila_get_lock(ilan, p->identifier);
+	spinlock_t *lock = ila_get_lock(ilan, xp->identifier);
 	int err = -ENOENT;
 
 	spin_lock(lock);
 
 	head = rhashtable_lookup_fast(&ilan->rhash_table,
-				      &p->identifier, rht_params);
+				      &xp->identifier, rht_params);
 	ila = head;
 
 	prev = NULL;
 
 	while (ila) {
-		if (ila_cmp_params(ila, p)) {
+		if (ila_cmp_params(ila, xp)) {
 			prev = ila;
 			ila = rcu_dereference_protected(ila->next,
 							lockdep_is_held(lock));
@@ -404,14 +409,14 @@ static int ila_nl_cmd_add_mapping(struct sk_buff *skb, struct genl_info *info)
 static int ila_nl_cmd_del_mapping(struct sk_buff *skb, struct genl_info *info)
 {
 	struct net *net = genl_info_net(info);
-	struct ila_xlat_params p;
+	struct ila_xlat_params xp;
 	int err;
 
-	err = parse_nl_config(info, &p);
+	err = parse_nl_config(info, &xp);
 	if (err)
 		return err;
 
-	ila_del_mapping(net, &p);
+	ila_del_mapping(net, &xp);
 
 	return 0;
 }
@@ -419,13 +424,13 @@ static int ila_nl_cmd_del_mapping(struct sk_buff *skb, struct genl_info *info)
 static int ila_fill_info(struct ila_map *ila, struct sk_buff *msg)
 {
 	if (nla_put_u64(msg, ILA_ATTR_IDENTIFIER,
-			(__force u64)ila->p.identifier) ||
+			(__force u64)ila->xp.identifier.v64) ||
 	    nla_put_u64(msg, ILA_ATTR_LOCATOR,
-			(__force u64)ila->p.ip.locator) ||
+			(__force u64)ila->xp.ip.locator.v64) ||
 	    nla_put_u64(msg, ILA_ATTR_LOCATOR_MATCH,
-			(__force u64)ila->p.ip.locator_match) ||
-	    nla_put_s32(msg, ILA_ATTR_IFINDEX, ila->p.ifindex) ||
-	    nla_put_u32(msg, ILA_ATTR_DIR, ila->p.dir))
+			(__force u64)ila->xp.ip.locator_match.v64) ||
+	    nla_put_s32(msg, ILA_ATTR_IFINDEX, ila->xp.ifindex) ||
+	    nla_put_u32(msg, ILA_ATTR_DIR, ila->xp.dir))
 		return -1;
 
 	return 0;
@@ -457,11 +462,11 @@ static int ila_nl_cmd_get_mapping(struct sk_buff *skb, struct genl_info *info)
 	struct net *net = genl_info_net(info);
 	struct ila_net *ilan = net_generic(net, ila_net_id);
 	struct sk_buff *msg;
-	struct ila_xlat_params p;
+	struct ila_xlat_params xp;
 	struct ila_map *ila;
 	int ret;
 
-	ret = parse_nl_config(info, &p);
+	ret = parse_nl_config(info, &xp);
 	if (ret)
 		return ret;
 
@@ -471,7 +476,7 @@ static int ila_nl_cmd_get_mapping(struct sk_buff *skb, struct genl_info *info)
 
 	rcu_read_lock();
 
-	ila = ila_lookup_by_params(&p, ilan);
+	ila = ila_lookup_by_params(&xp, ilan);
 	if (ila) {
 		ret = ila_dump_info(ila,
 				    info->snd_portid,
@@ -620,21 +625,18 @@ static int ila_xlat_addr(struct sk_buff *skb, int dir)
 	struct ipv6hdr *ip6h = ipv6_hdr(skb);
 	struct net *net = dev_net(skb->dev);
 	struct ila_net *ilan = net_generic(net, ila_net_id);
-	__be64 identifier, locator_match;
+	struct ila_addr *iaddr = ila_a2i(&ip6h->daddr);
 	size_t nhoff;
 
 	/* Assumes skb contains a valid IPv6 header that is pulled */
 
-	identifier = *(__be64 *)&ip6h->daddr.in6_u.u6_addr8[8];
-	locator_match = *(__be64 *)&ip6h->daddr.in6_u.u6_addr8[0];
 	nhoff = sizeof(struct ipv6hdr);
 
 	rcu_read_lock();
 
-	ila = ila_lookup_wildcards(identifier, locator_match,
-				   skb->dev->ifindex, dir, ilan);
+	ila = ila_lookup_wildcards(iaddr, skb->dev->ifindex, dir, ilan);
 	if (ila)
-		update_ipv6_locator(skb, &ila->p.ip);
+		ila_update_ipv6_locator(skb, &ila->xp.ip);
 
 	rcu_read_unlock();
 
-- 
2.8.0.rc2
