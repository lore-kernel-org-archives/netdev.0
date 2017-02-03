From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 25/27] netfilter: merge ctinfo into nfct pointer storage area
Date: Fri,  3 Feb 2017 13:25:36 +0100
Message-ID: <1486124738-3013-26-git-send-email-pablo@netfilter.org>
References: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58890 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753296AbdBCM2r (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 07:28:47 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 1A34CDA881
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:46 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id F3C75DA849
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:45 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 9AA8ADA809
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:43 +0100 (CET)
In-Reply-To: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

After this change conntrack operations (lookup, creation, matching from
ruleset) only access one instead of two sk_buff cache lines.

This works for normal conntracks because those are allocated from a slab
that guarantees hw cacheline or 8byte alignment (whatever is larger)
so the 3 bits needed for ctinfo won't overlap with nf_conn addresses.

Template allocation now does manual address alignment (see previous change)
on arches that don't have sufficent kmalloc min alignment.

Some spots intentionally use skb->_nfct instead of skb_nfct() helpers,
this is to avoid undoing the skb_nfct() use when we remove untracked
conntrack object in the future.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/skbuff.h                  | 21 +++++++++------------
 include/net/netfilter/nf_conntrack.h    | 11 ++++++-----
 net/ipv6/netfilter/nf_dup_ipv6.c        |  2 +-
 net/netfilter/core.c                    |  2 +-
 net/netfilter/nf_conntrack_core.c       | 11 ++++++-----
 net/netfilter/nf_conntrack_standalone.c |  3 +++
 net/netfilter/xt_CT.c                   |  4 ++--
 7 files changed, 28 insertions(+), 26 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 276431e047af..ac0bc085b139 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -585,7 +585,6 @@ static inline bool skb_mstamp_after(const struct skb_mstamp *t1,
  *	@cloned: Head may be cloned (check refcnt to be sure)
  *	@ip_summed: Driver fed us an IP checksum
  *	@nohdr: Payload reference only, must not modify header
- *	@nfctinfo: Relationship of this skb to the connection
  *	@pkt_type: Packet class
  *	@fclone: skbuff clone status
  *	@ipvs_property: skbuff is owned by ipvs
@@ -594,7 +593,7 @@ static inline bool skb_mstamp_after(const struct skb_mstamp *t1,
  *	@nf_trace: netfilter packet trace flag
  *	@protocol: Packet protocol from driver
  *	@destructor: Destruct function
- *	@nfct: Associated connection, if any
+ *	@_nfct: Associated connection, if any (with nfctinfo bits)
  *	@nf_bridge: Saved data about a bridged frame - see br_netfilter.c
  *	@skb_iif: ifindex of device we arrived on
  *	@tc_index: Traffic control index
@@ -668,7 +667,7 @@ struct sk_buff {
 	struct	sec_path	*sp;
 #endif
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
-	struct nf_conntrack	*nfct;
+	unsigned long		 _nfct;
 #endif
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	struct nf_bridge_info	*nf_bridge;
@@ -721,7 +720,6 @@ struct sk_buff {
 	__u8			pkt_type:3;
 	__u8			pfmemalloc:1;
 	__u8			ignore_df:1;
-	__u8			nfctinfo:3;
 
 	__u8			nf_trace:1;
 	__u8			ip_summed:2;
@@ -836,6 +834,7 @@ static inline bool skb_pfmemalloc(const struct sk_buff *skb)
 #define SKB_DST_NOREF	1UL
 #define SKB_DST_PTRMASK	~(SKB_DST_NOREF)
 
+#define SKB_NFCT_PTRMASK	~(7UL)
 /**
  * skb_dst - returns skb dst_entry
  * @skb: buffer
@@ -3556,7 +3555,7 @@ static inline void skb_remcsum_process(struct sk_buff *skb, void *ptr,
 static inline struct nf_conntrack *skb_nfct(const struct sk_buff *skb)
 {
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
-	return skb->nfct;
+	return (void *)(skb->_nfct & SKB_NFCT_PTRMASK);
 #else
 	return NULL;
 #endif
@@ -3590,8 +3589,8 @@ static inline void nf_bridge_get(struct nf_bridge_info *nf_bridge)
 static inline void nf_reset(struct sk_buff *skb)
 {
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
-	nf_conntrack_put(skb->nfct);
-	skb->nfct = NULL;
+	nf_conntrack_put(skb_nfct(skb));
+	skb->_nfct = 0;
 #endif
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	nf_bridge_put(skb->nf_bridge);
@@ -3611,10 +3610,8 @@ static inline void __nf_copy(struct sk_buff *dst, const struct sk_buff *src,
 			     bool copy)
 {
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
-	dst->nfct = src->nfct;
-	nf_conntrack_get(src->nfct);
-	if (copy)
-		dst->nfctinfo = src->nfctinfo;
+	dst->_nfct = src->_nfct;
+	nf_conntrack_get(skb_nfct(src));
 #endif
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	dst->nf_bridge  = src->nf_bridge;
@@ -3629,7 +3626,7 @@ static inline void __nf_copy(struct sk_buff *dst, const struct sk_buff *src,
 static inline void nf_copy(struct sk_buff *dst, const struct sk_buff *src)
 {
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
-	nf_conntrack_put(dst->nfct);
+	nf_conntrack_put(skb_nfct(dst));
 #endif
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	nf_bridge_put(dst->nf_bridge);
diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 06d3d2d24fe0..f540f9ad2af4 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -76,7 +76,7 @@ struct nf_conn {
 	/* Usage count in here is 1 for hash table, 1 per skb,
 	 * plus 1 for any connection(s) we are `master' for
 	 *
-	 * Hint, SKB address this struct and refcnt via skb->nfct and
+	 * Hint, SKB address this struct and refcnt via skb->_nfct and
 	 * helpers nf_conntrack_get() and nf_conntrack_put().
 	 * Helper nf_ct_put() equals nf_conntrack_put() by dec refcnt,
 	 * beware nf_ct_get() is different and don't inc refcnt.
@@ -164,13 +164,15 @@ int nf_conntrack_tuple_taken(const struct nf_conntrack_tuple *tuple,
 			     const struct nf_conn *ignored_conntrack);
 
 #define NFCT_INFOMASK	7UL
+#define NFCT_PTRMASK	~(NFCT_INFOMASK)
 
 /* Return conntrack_info and tuple hash for given skb. */
 static inline struct nf_conn *
 nf_ct_get(const struct sk_buff *skb, enum ip_conntrack_info *ctinfo)
 {
-	*ctinfo = skb->nfctinfo;
-	return (struct nf_conn *)skb->nfct;
+	*ctinfo = skb->_nfct & NFCT_INFOMASK;
+
+	return (struct nf_conn *)(skb->_nfct & NFCT_PTRMASK);
 }
 
 /* decrement reference count on a conntrack */
@@ -347,8 +349,7 @@ void nf_ct_tmpl_free(struct nf_conn *tmpl);
 static inline void
 nf_ct_set(struct sk_buff *skb, struct nf_conn *ct, enum ip_conntrack_info info)
 {
-	skb->nfct = &ct->ct_general;
-	skb->nfctinfo = info;
+	skb->_nfct = (unsigned long)ct | info;
 }
 
 #define NF_CT_STAT_INC(net, count)	  __this_cpu_inc((net)->ct.stat->count)
diff --git a/net/ipv6/netfilter/nf_dup_ipv6.c b/net/ipv6/netfilter/nf_dup_ipv6.c
index ff04f6a7f45b..888ecd106e5f 100644
--- a/net/ipv6/netfilter/nf_dup_ipv6.c
+++ b/net/ipv6/netfilter/nf_dup_ipv6.c
@@ -59,7 +59,7 @@ void nf_dup_ipv6(struct net *net, struct sk_buff *skb, unsigned int hooknum,
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	nf_reset(skb);
 	nf_ct_set(skb, nf_ct_untracked_get(), IP_CT_NEW);
-	nf_conntrack_get(skb->nfct);
+	nf_conntrack_get(skb_nfct(skb));
 #endif
 	if (hooknum == NF_INET_PRE_ROUTING ||
 	    hooknum == NF_INET_LOCAL_IN) {
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index ce6adfae521a..a87a6f8a74d8 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -375,7 +375,7 @@ void nf_ct_attach(struct sk_buff *new, const struct sk_buff *skb)
 {
 	void (*attach)(struct sk_buff *, const struct sk_buff *);
 
-	if (skb->nfct) {
+	if (skb->_nfct) {
 		rcu_read_lock();
 		attach = rcu_dereference(ip_ct_attach);
 		if (attach)
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 768968fba7f6..47c4ea53daa6 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1239,7 +1239,7 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 	return &ct->tuplehash[IP_CT_DIR_ORIGINAL];
 }
 
-/* On success, returns conntrack ptr, sets skb->nfct and ctinfo */
+/* On success, returns conntrack ptr, sets skb->_nfct | ctinfo */
 static inline struct nf_conn *
 resolve_normal_ct(struct net *net, struct nf_conn *tmpl,
 		  struct sk_buff *skb,
@@ -1323,7 +1323,7 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 			NF_CT_STAT_INC_ATOMIC(net, ignore);
 			return NF_ACCEPT;
 		}
-		skb->nfct = NULL;
+		skb->_nfct = 0;
 	}
 
 	/* rcu_read_lock()ed by nf_hook_thresh */
@@ -1352,7 +1352,7 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 			goto out;
 		}
 		/* ICMP[v6] protocol trackers may assign one conntrack. */
-		if (skb->nfct)
+		if (skb->_nfct)
 			goto out;
 	}
 repeat:
@@ -1383,7 +1383,7 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 		 * the netfilter core what to do */
 		pr_debug("nf_conntrack_in: Can't track with proto module\n");
 		nf_conntrack_put(&ct->ct_general);
-		skb->nfct = NULL;
+		skb->_nfct = 0;
 		NF_CT_STAT_INC_ATOMIC(net, invalid);
 		if (ret == -NF_DROP)
 			NF_CT_STAT_INC_ATOMIC(net, drop);
@@ -1878,7 +1878,8 @@ int nf_conntrack_init_start(void)
 	nf_conntrack_max = max_factor * nf_conntrack_htable_size;
 
 	nf_conntrack_cachep = kmem_cache_create("nf_conntrack",
-						sizeof(struct nf_conn), 0,
+						sizeof(struct nf_conn),
+						NFCT_INFOMASK + 1,
 						SLAB_DESTROY_BY_RCU | SLAB_HWCACHE_ALIGN, NULL);
 	if (!nf_conntrack_cachep)
 		goto err_cachep;
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index d009ae663453..2256147dcaad 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -642,6 +642,9 @@ static int __init nf_conntrack_standalone_init(void)
 	if (ret < 0)
 		goto out_start;
 
+	BUILD_BUG_ON(SKB_NFCT_PTRMASK != NFCT_PTRMASK);
+	BUILD_BUG_ON(NFCT_INFOMASK <= IP_CT_NUMBER);
+
 #ifdef CONFIG_SYSCTL
 	nf_ct_netfilter_header =
 		register_net_sysctl(&init_net, "net", nf_ct_netfilter_table);
diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index 51f00e1e1208..b008db0184b8 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -23,7 +23,7 @@
 static inline int xt_ct_target(struct sk_buff *skb, struct nf_conn *ct)
 {
 	/* Previously seen (loopback)? Ignore. */
-	if (skb->nfct != NULL)
+	if (skb->_nfct != 0)
 		return XT_CONTINUE;
 
 	/* special case the untracked ct : we want the percpu object */
@@ -409,7 +409,7 @@ static unsigned int
 notrack_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	/* Previously seen (loopback)? Ignore. */
-	if (skb->nfct != NULL)
+	if (skb->_nfct != 0)
 		return XT_CONTINUE;
 
 	nf_ct_set(skb, nf_ct_untracked_get(), IP_CT_NEW);
-- 
2.1.4
