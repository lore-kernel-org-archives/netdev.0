From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 14/15] netfilter: nf_conntrack: add efficient mark to zone mapping
Date: Fri, 21 Aug 2015 06:32:43 +0200
Message-ID: <1440131564-8807-15-git-send-email-pablo@netfilter.org>
References: <1440131564-8807-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48184 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752322AbbHUE1b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2015 00:27:31 -0400
In-Reply-To: <1440131564-8807-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>

This work adds the possibility of deriving the zone id from the skb->mark
field in a scalable manner. This allows for having only a single template
serving hundreds/thousands of different zones, for example, instead of the
need to have one match for each zone as an extra CT jump target.

Note that we'd need to have this information attached to the template as at
the time when we're trying to lookup a possible ct object, we already need
to know zone information for a possible match when going into
__nf_conntrack_find_get(). This work provides a minimal implementation for
a possible mapping.

In order to not add/expose an extra ct->status bit, the zone structure has
been extended to carry a flag for deriving the mark.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_zones.h     |   45 +++++++++++++++++++--
 include/uapi/linux/netfilter/xt_CT.h           |    4 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    3 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    4 +-
 net/netfilter/nf_conntrack_core.c              |   50 ++++++++----------------
 net/netfilter/nf_conntrack_netlink.c           |    5 +--
 net/netfilter/xt_CT.c                          |    5 ++-
 7 files changed, 72 insertions(+), 44 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_zones.h b/include/net/netfilter/nf_conntrack_zones.h
index 3942ddf..5316c7b 100644
--- a/include/net/netfilter/nf_conntrack_zones.h
+++ b/include/net/netfilter/nf_conntrack_zones.h
@@ -10,9 +10,12 @@
 
 #define NF_CT_DEFAULT_ZONE_DIR	(NF_CT_ZONE_DIR_ORIG | NF_CT_ZONE_DIR_REPL)
 
+#define NF_CT_FLAG_MARK		1
+
 struct nf_conntrack_zone {
 	u16	id;
-	u16	dir;
+	u8	flags;
+	u8	dir;
 };
 
 extern const struct nf_conntrack_zone nf_ct_zone_dflt;
@@ -32,9 +35,45 @@ nf_ct_zone(const struct nf_conn *ct)
 }
 
 static inline const struct nf_conntrack_zone *
-nf_ct_zone_tmpl(const struct nf_conn *tmpl)
+nf_ct_zone_init(struct nf_conntrack_zone *zone, u16 id, u8 dir, u8 flags)
+{
+	zone->id = id;
+	zone->flags = flags;
+	zone->dir = dir;
+
+	return zone;
+}
+
+static inline const struct nf_conntrack_zone *
+nf_ct_zone_tmpl(const struct nf_conn *tmpl, const struct sk_buff *skb,
+		struct nf_conntrack_zone *tmp)
+{
+	const struct nf_conntrack_zone *zone;
+
+	if (!tmpl)
+		return &nf_ct_zone_dflt;
+
+	zone = nf_ct_zone(tmpl);
+	if (zone->flags & NF_CT_FLAG_MARK)
+		zone = nf_ct_zone_init(tmp, skb->mark, zone->dir, 0);
+
+	return zone;
+}
+
+static inline int nf_ct_zone_add(struct nf_conn *ct, gfp_t flags,
+				 const struct nf_conntrack_zone *info)
 {
-	return tmpl ? nf_ct_zone(tmpl) : &nf_ct_zone_dflt;
+#ifdef CONFIG_NF_CONNTRACK_ZONES
+	struct nf_conntrack_zone *nf_ct_zone;
+
+	nf_ct_zone = nf_ct_ext_add(ct, NF_CT_EXT_ZONE, flags);
+	if (!nf_ct_zone)
+		return -ENOMEM;
+
+	nf_ct_zone_init(nf_ct_zone, info->id, info->dir,
+			info->flags);
+#endif
+	return 0;
 }
 
 static inline bool nf_ct_zone_matches_dir(const struct nf_conntrack_zone *zone,
diff --git a/include/uapi/linux/netfilter/xt_CT.h b/include/uapi/linux/netfilter/xt_CT.h
index 452005f..9e52041 100644
--- a/include/uapi/linux/netfilter/xt_CT.h
+++ b/include/uapi/linux/netfilter/xt_CT.h
@@ -8,9 +8,11 @@ enum {
 	XT_CT_NOTRACK_ALIAS	= 1 << 1,
 	XT_CT_ZONE_DIR_ORIG	= 1 << 2,
 	XT_CT_ZONE_DIR_REPL	= 1 << 3,
+	XT_CT_ZONE_MARK		= 1 << 4,
 
 	XT_CT_MASK		= XT_CT_NOTRACK | XT_CT_NOTRACK_ALIAS |
-				  XT_CT_ZONE_DIR_ORIG | XT_CT_ZONE_DIR_REPL,
+				  XT_CT_ZONE_DIR_ORIG | XT_CT_ZONE_DIR_REPL |
+				  XT_CT_ZONE_MARK,
 };
 
 struct xt_ct_target_info {
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index 8a2f41c..cdde3ec 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -135,9 +135,10 @@ icmp_error_message(struct net *net, struct nf_conn *tmpl, struct sk_buff *skb,
 	const struct nf_conntrack_l4proto *innerproto;
 	const struct nf_conntrack_tuple_hash *h;
 	const struct nf_conntrack_zone *zone;
+	struct nf_conntrack_zone tmp;
 
 	NF_CT_ASSERT(skb->nfct == NULL);
-	zone = nf_ct_zone_tmpl(tmpl);
+	zone = nf_ct_zone_tmpl(tmpl, skb, &tmp);
 
 	/* Are they talking about one of our connections? */
 	if (!nf_ct_get_tuplepr(skb,
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 2029141..0e6fae1 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -150,6 +150,7 @@ icmpv6_error_message(struct net *net, struct nf_conn *tmpl,
 	struct nf_conntrack_tuple intuple, origtuple;
 	const struct nf_conntrack_tuple_hash *h;
 	const struct nf_conntrack_l4proto *inproto;
+	struct nf_conntrack_zone tmp;
 
 	NF_CT_ASSERT(skb->nfct == NULL);
 
@@ -176,7 +177,8 @@ icmpv6_error_message(struct net *net, struct nf_conn *tmpl,
 
 	*ctinfo = IP_CT_RELATED;
 
-	h = nf_conntrack_find_get(net, nf_ct_zone_tmpl(tmpl), &intuple);
+	h = nf_conntrack_find_get(net, nf_ct_zone_tmpl(tmpl, skb, &tmp),
+				  &intuple);
 	if (!h) {
 		pr_debug("icmpv6_error: no match\n");
 		return -NF_ACCEPT;
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index acc0622..48521d6 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -301,25 +301,15 @@ struct nf_conn *nf_ct_tmpl_alloc(struct net *net,
 	tmpl->status = IPS_TEMPLATE;
 	write_pnet(&tmpl->ct_net, net);
 
-#ifdef CONFIG_NF_CONNTRACK_ZONES
-	if (zone) {
-		struct nf_conntrack_zone *nf_ct_zone;
-
-		nf_ct_zone = nf_ct_ext_add(tmpl, NF_CT_EXT_ZONE, GFP_ATOMIC);
-		if (!nf_ct_zone)
-			goto out_free;
-		nf_ct_zone->id = zone->id;
-		nf_ct_zone->dir = zone->dir;
-	}
-#endif
+	if (nf_ct_zone_add(tmpl, flags, zone) < 0)
+		goto out_free;
+
 	atomic_set(&tmpl->ct_general.use, 0);
 
 	return tmpl;
-#ifdef CONFIG_NF_CONNTRACK_ZONES
 out_free:
 	kfree(tmpl);
 	return NULL;
-#endif
 }
 EXPORT_SYMBOL_GPL(nf_ct_tmpl_alloc);
 
@@ -850,10 +840,9 @@ __nf_conntrack_alloc(struct net *net,
 	 * SLAB_DESTROY_BY_RCU.
 	 */
 	ct = kmem_cache_alloc(net->ct.nf_conntrack_cachep, gfp);
-	if (ct == NULL) {
-		atomic_dec(&net->ct.count);
-		return ERR_PTR(-ENOMEM);
-	}
+	if (ct == NULL)
+		goto out;
+
 	spin_lock_init(&ct->lock);
 	ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple = *orig;
 	ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode.pprev = NULL;
@@ -867,29 +856,20 @@ __nf_conntrack_alloc(struct net *net,
 	memset(&ct->__nfct_init_offset[0], 0,
 	       offsetof(struct nf_conn, proto) -
 	       offsetof(struct nf_conn, __nfct_init_offset[0]));
-#ifdef CONFIG_NF_CONNTRACK_ZONES
-	if (zone) {
-		struct nf_conntrack_zone *nf_ct_zone;
-
-		nf_ct_zone = nf_ct_ext_add(ct, NF_CT_EXT_ZONE, GFP_ATOMIC);
-		if (!nf_ct_zone)
-			goto out_free;
-		nf_ct_zone->id = zone->id;
-		nf_ct_zone->dir = zone->dir;
-	}
-#endif
+
+	if (zone && nf_ct_zone_add(ct, GFP_ATOMIC, zone) < 0)
+		goto out_free;
+
 	/* Because we use RCU lookups, we set ct_general.use to zero before
 	 * this is inserted in any list.
 	 */
 	atomic_set(&ct->ct_general.use, 0);
 	return ct;
-
-#ifdef CONFIG_NF_CONNTRACK_ZONES
 out_free:
-	atomic_dec(&net->ct.count);
 	kmem_cache_free(net->ct.nf_conntrack_cachep, ct);
+out:
+	atomic_dec(&net->ct.count);
 	return ERR_PTR(-ENOMEM);
-#endif
 }
 
 struct nf_conn *nf_conntrack_alloc(struct net *net,
@@ -937,6 +917,7 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 	struct nf_conntrack_expect *exp = NULL;
 	const struct nf_conntrack_zone *zone;
 	struct nf_conn_timeout *timeout_ext;
+	struct nf_conntrack_zone tmp;
 	unsigned int *timeouts;
 
 	if (!nf_ct_invert_tuple(&repl_tuple, tuple, l3proto, l4proto)) {
@@ -944,7 +925,7 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 		return NULL;
 	}
 
-	zone = nf_ct_zone_tmpl(tmpl);
+	zone = nf_ct_zone_tmpl(tmpl, skb, &tmp);
 	ct = __nf_conntrack_alloc(net, zone, tuple, &repl_tuple, GFP_ATOMIC,
 				  hash);
 	if (IS_ERR(ct))
@@ -1042,6 +1023,7 @@ resolve_normal_ct(struct net *net, struct nf_conn *tmpl,
 	const struct nf_conntrack_zone *zone;
 	struct nf_conntrack_tuple tuple;
 	struct nf_conntrack_tuple_hash *h;
+	struct nf_conntrack_zone tmp;
 	struct nf_conn *ct;
 	u32 hash;
 
@@ -1053,7 +1035,7 @@ resolve_normal_ct(struct net *net, struct nf_conn *tmpl,
 	}
 
 	/* look for tuple match */
-	zone = nf_ct_zone_tmpl(tmpl);
+	zone = nf_ct_zone_tmpl(tmpl, skb, &tmp);
 	hash = hash_conntrack_raw(&tuple);
 	h = __nf_conntrack_find_get(net, zone, &tuple, hash);
 	if (!h) {
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 4eaf925..94a6654 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -956,9 +956,8 @@ static int
 ctnetlink_parse_zone(const struct nlattr *attr,
 		     struct nf_conntrack_zone *zone)
 {
-	zone->id  = NF_CT_DEFAULT_ZONE_ID;
-	zone->dir = NF_CT_DEFAULT_ZONE_DIR;
-
+	nf_ct_zone_init(zone, NF_CT_DEFAULT_ZONE_ID,
+			NF_CT_DEFAULT_ZONE_DIR, 0);
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	if (attr)
 		zone->id = ntohs(nla_get_be16(attr));
diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index 536cb67..3465098 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -208,7 +208,8 @@ static int xt_ct_tg_check(const struct xt_tgchk_param *par,
 
 #ifndef CONFIG_NF_CONNTRACK_ZONES
 	if (info->zone || info->flags & (XT_CT_ZONE_DIR_ORIG |
-					 XT_CT_ZONE_DIR_REPL))
+					 XT_CT_ZONE_DIR_REPL |
+					 XT_CT_ZONE_MARK))
 		goto err1;
 #endif
 
@@ -219,6 +220,8 @@ static int xt_ct_tg_check(const struct xt_tgchk_param *par,
 	memset(&zone, 0, sizeof(zone));
 	zone.id = info->zone;
 	zone.dir = xt_ct_flags_to_dir(info);
+	if (info->flags & XT_CT_ZONE_MARK)
+		zone.flags |= NF_CT_FLAG_MARK;
 
 	ct = nf_ct_tmpl_alloc(par->net, &zone, GFP_KERNEL);
 	ret = PTR_ERR(ct);
-- 
1.7.10.4
