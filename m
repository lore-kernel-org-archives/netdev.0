From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 4/4] netfilter: merge ctinfo into nfct pointer storage area
Date: Wed,  4 Jan 2017 16:35:50 +0100
Message-ID: <1483544150-10686-5-git-send-email-fw@strlen.de>
References: <1483544150-10686-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: <netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:43808 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934498AbdADP6n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 10:58:43 -0500
In-Reply-To: <1483544150-10686-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Merge conntrack related status bits into skb->_nfct.
After this change conntrack operations (lookup, creation, matching from
ruleset) only accesses one instead of two sk_buff cache lines.

This works for normal conntracks because we use a slab cache that
guarantees hw cacheline or 8byte alignemnt (whatever is larger) so
the 3 bits needed for ctinfo won't overlap with nf_conn addresses.

For the conntrack templates we need an 8 byte kmalloc minalign, in case
we have arches where this isn't true a build-bug on test will catch this.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/skbuff.h                         | 30 +++++++++++++++-----------
 include/net/ip_vs.h                            |  4 ++--
 include/net/netfilter/nf_conntrack.h           | 10 ++++++---
 include/net/netfilter/nf_conntrack_core.h      |  2 +-
 net/core/skbuff.c                              |  2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c              |  7 +++---
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |  6 +++---
 net/ipv4/netfilter/nf_defrag_ipv4.c            |  4 ++--
 net/ipv4/netfilter/nf_dup_ipv4.c               |  7 +++---
 net/ipv6/netfilter/ip6t_SYNPROXY.c             |  7 +++---
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c | 12 +++++------
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c      |  4 ++--
 net/ipv6/netfilter/nf_dup_ipv6.c               |  8 ++++---
 net/netfilter/core.c                           |  2 +-
 net/netfilter/nf_conntrack_core.c              | 22 +++++++++----------
 net/netfilter/nf_conntrack_standalone.c        |  4 ++++
 net/netfilter/nf_nat_helper.c                  |  2 +-
 net/netfilter/nft_ct.c                         |  3 +--
 net/netfilter/xt_CT.c                          | 13 ++++++-----
 net/openvswitch/conntrack.c                    | 22 +++++++++----------
 net/sched/cls_flow.c                           |  2 +-
 21 files changed, 91 insertions(+), 82 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index b53c0cfd417e..fee935fea6f9 100644
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
@@ -3555,6 +3554,15 @@ static inline void skb_remcsum_process(struct sk_buff *skb, void *ptr,
 
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 void nf_conntrack_destroy(struct nf_conntrack *nfct);
+static inline struct nf_conntrack *skb_nfct(const struct sk_buff *skb)
+{
+	struct nf_conntrack *nfct;
+
+	nfct = (void *) (skb->_nfct & SKB_NFCT_PTRMASK);
+
+	return nfct;
+}
+
 static inline void nf_conntrack_put(struct nf_conntrack *nfct)
 {
 	if (nfct && atomic_dec_and_test(&nfct->use))
@@ -3581,8 +3589,8 @@ static inline void nf_bridge_get(struct nf_bridge_info *nf_bridge)
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
@@ -3602,10 +3610,8 @@ static inline void __nf_copy(struct sk_buff *dst, const struct sk_buff *src,
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
@@ -3620,7 +3626,7 @@ static inline void __nf_copy(struct sk_buff *dst, const struct sk_buff *src,
 static inline void nf_copy(struct sk_buff *dst, const struct sk_buff *src)
 {
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
-	nf_conntrack_put(dst->nfct);
+	nf_conntrack_put(skb_nfct(dst));
 #endif
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	nf_bridge_put(dst->nf_bridge);
@@ -3653,7 +3659,7 @@ static inline bool skb_irq_freeable(const struct sk_buff *skb)
 		!skb->sp &&
 #endif
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
-		!skb->nfct &&
+		!skb->_nfct &&
 #endif
 		!skb->_skb_refdst &&
 		!skb_has_frag_list(skb);
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 2a344ebd7ebe..cef639dd2d6e 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1559,8 +1559,8 @@ static inline void ip_vs_notrack(struct sk_buff *skb)
 		nf_conntrack_put(&ct->ct_general);
 		untracked = nf_ct_untracked_get();
 		nf_conntrack_get(&untracked->ct_general);
-		skb->nfct = &untracked->ct_general;
-		skb->nfctinfo = IP_CT_NEW;
+		skb->_nfct = (unsigned long)
+			&nf_ct_untracked_get()->ct_general | IP_CT_NEW;
 	}
 #endif
 }
diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 5916aa9ab3f0..ccc18981f46b 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -75,7 +75,7 @@ struct nf_conn {
 	/* Usage count in here is 1 for hash table, 1 per skb,
 	 * plus 1 for any connection(s) we are `master' for
 	 *
-	 * Hint, SKB address this struct and refcnt via skb->nfct and
+	 * Hint, SKB address this struct and refcnt via skb->_nfct and
 	 * helpers nf_conntrack_get() and nf_conntrack_put().
 	 * Helper nf_ct_put() equals nf_conntrack_put() by dec refcnt,
 	 * beware nf_ct_get() is different and don't inc refcnt.
@@ -162,12 +162,16 @@ void nf_conntrack_alter_reply(struct nf_conn *ct,
 int nf_conntrack_tuple_taken(const struct nf_conntrack_tuple *tuple,
 			     const struct nf_conn *ignored_conntrack);
 
+#define NFCT_INFOMASK	7UL
+#define NFCT_PTRMASK	~(NFCT_INFOMASK)
+
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
diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
index 62e17d1319ff..10223ca4c96e 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -62,7 +62,7 @@ int __nf_conntrack_confirm(struct sk_buff *skb);
 /* Confirm a connection: returns NF_DROP if packet must be dropped. */
 static inline int nf_conntrack_confirm(struct sk_buff *skb)
 {
-	struct nf_conn *ct = (struct nf_conn *)skb->nfct;
+	struct nf_conn *ct = (struct nf_conn *)(skb->_nfct & NFCT_PTRMASK);
 	int ret = NF_ACCEPT;
 
 	if (ct && !nf_ct_is_untracked(ct)) {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5a03730fbc1a..cac3ebfb4b45 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -655,7 +655,7 @@ static void skb_release_head_state(struct sk_buff *skb)
 		skb->destructor(skb);
 	}
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
-	nf_conntrack_put(skb->nfct);
+	nf_conntrack_put(skb_nfct(skb));
 #endif
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	nf_bridge_put(skb->nf_bridge);
diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index 30c0de53e254..5decabf56538 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -57,8 +57,7 @@ synproxy_send_tcp(struct net *net,
 		goto free_nskb;
 
 	if (nfct) {
-		nskb->nfct = nfct;
-		nskb->nfctinfo = ctinfo;
+		nskb->_nfct = (unsigned long) nfct | ctinfo;
 		nf_conntrack_get(nfct);
 	}
 
@@ -107,7 +106,7 @@ synproxy_send_client_synack(struct net *net,
 
 	synproxy_build_options(nth, opts);
 
-	synproxy_send_tcp(net, skb, nskb, skb->nfct, IP_CT_ESTABLISHED_REPLY,
+	synproxy_send_tcp(net, skb, nskb, skb_nfct(skb), IP_CT_ESTABLISHED_REPLY,
 			  niph, nth, tcp_hdr_size);
 }
 
@@ -230,7 +229,7 @@ synproxy_send_client_ack(struct net *net,
 
 	synproxy_build_options(nth, opts);
 
-	synproxy_send_tcp(net, skb, nskb, skb->nfct, IP_CT_ESTABLISHED_REPLY,
+	synproxy_send_tcp(net, skb, nskb, skb_nfct(skb), IP_CT_ESTABLISHED_REPLY,
 			  niph, nth, tcp_hdr_size);
 }
 
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index 2e95ece3b257..e8aa492a13b0 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -137,7 +137,7 @@ icmp_error_message(struct net *net, struct nf_conn *tmpl, struct sk_buff *skb,
 	enum ip_conntrack_info ctinfo;
 	struct nf_conntrack_zone tmp;
 
-	NF_CT_ASSERT(skb->nfct == NULL);
+	NF_CT_ASSERT(skb->_nfct == 0);
 	zone = nf_ct_zone_tmpl(tmpl, skb, &tmp);
 
 	/* Are they talking about one of our connections? */
@@ -172,8 +172,8 @@ icmp_error_message(struct net *net, struct nf_conn *tmpl, struct sk_buff *skb,
 		ctinfo += IP_CT_IS_REPLY;
 
 	/* Update skb to refer to this connection */
-	skb->nfct = &nf_ct_tuplehash_to_ctrack(h)->ct_general;
-	skb->nfctinfo = ctinfo;
+	skb->_nfct = (unsigned long)
+		&nf_ct_tuplehash_to_ctrack(h)->ct_general | ctinfo;
 	return NF_ACCEPT;
 }
 
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index 49bd6a54404f..441584b92a9e 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -45,7 +45,7 @@ static enum ip_defrag_users nf_ct_defrag_user(unsigned int hooknum,
 {
 	u16 zone_id = NF_CT_DEFAULT_ZONE_ID;
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
-	if (skb->nfct) {
+	if (skb->_nfct) {
 		enum ip_conntrack_info ctinfo;
 		const struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 
@@ -75,7 +75,7 @@ static unsigned int ipv4_conntrack_defrag(void *priv,
 #if !IS_ENABLED(CONFIG_NF_NAT)
 	/* Previously seen (loopback)?  Ignore.  Do this before
 	   fragment check. */
-	if (skb->nfct && !nf_ct_is_template((struct nf_conn *)skb->nfct))
+	if (skb->_nfct && !nf_ct_is_template((struct nf_conn *) skb_nfct(skb)));
 		return NF_ACCEPT;
 #endif
 #endif
diff --git a/net/ipv4/netfilter/nf_dup_ipv4.c b/net/ipv4/netfilter/nf_dup_ipv4.c
index a981ef7151ca..71fd5c4e5376 100644
--- a/net/ipv4/netfilter/nf_dup_ipv4.c
+++ b/net/ipv4/netfilter/nf_dup_ipv4.c
@@ -53,6 +53,7 @@ static bool nf_dup_ipv4_route(struct net *net, struct sk_buff *skb,
 void nf_dup_ipv4(struct net *net, struct sk_buff *skb, unsigned int hooknum,
 		 const struct in_addr *gw, int oif)
 {
+	struct nf_conn *untracked;
 	struct iphdr *iph;
 
 	if (this_cpu_read(nf_skb_duplicated))
@@ -68,10 +69,10 @@ void nf_dup_ipv4(struct net *net, struct sk_buff *skb, unsigned int hooknum,
 
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	/* Avoid counting cloned packets towards the original connection. */
+	untracked = nf_ct_untracked_get();
 	nf_reset(skb);
-	skb->nfct     = &nf_ct_untracked_get()->ct_general;
-	skb->nfctinfo = IP_CT_NEW;
-	nf_conntrack_get(skb->nfct);
+	nf_conntrack_get(&untracked->ct_general);
+	skb->_nfct = (unsigned long) untracked | IP_CT_NEW;
 #endif
 	/*
 	 * If we are in PREROUTING/INPUT, decrease the TTL to mitigate potential
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index 98c8dd38575a..7412be3f10ce 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -71,8 +71,7 @@ synproxy_send_tcp(struct net *net,
 	skb_dst_set(nskb, dst);
 
 	if (nfct) {
-		nskb->nfct = nfct;
-		nskb->nfctinfo = ctinfo;
+		nskb->_nfct = (unsigned long) nfct | ctinfo;
 		nf_conntrack_get(nfct);
 	}
 
@@ -121,7 +120,7 @@ synproxy_send_client_synack(struct net *net,
 
 	synproxy_build_options(nth, opts);
 
-	synproxy_send_tcp(net, skb, nskb, skb->nfct, IP_CT_ESTABLISHED_REPLY,
+	synproxy_send_tcp(net, skb, nskb, skb_nfct(skb), IP_CT_ESTABLISHED_REPLY,
 			  niph, nth, tcp_hdr_size);
 }
 
@@ -244,7 +243,7 @@ synproxy_send_client_ack(struct net *net,
 
 	synproxy_build_options(nth, opts);
 
-	synproxy_send_tcp(net, skb, nskb, skb->nfct, IP_CT_ESTABLISHED_REPLY,
+	synproxy_send_tcp(net, skb, nskb, skb_nfct(skb), IP_CT_ESTABLISHED_REPLY,
 			  niph, nth, tcp_hdr_size);
 }
 
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 56f4eebb5efe..b6f97a4e6dbd 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -153,7 +153,7 @@ icmpv6_error_message(struct net *net, struct nf_conn *tmpl,
 	enum ip_conntrack_info ctinfo;
 	struct nf_conntrack_zone tmp;
 
-	NF_CT_ASSERT(skb->nfct == NULL);
+	NF_CT_ASSERT(skb->_nfct == 0);
 
 	/* Are they talking about one of our connections? */
 	if (!nf_ct_get_tuplepr(skb,
@@ -189,8 +189,8 @@ icmpv6_error_message(struct net *net, struct nf_conn *tmpl,
 	}
 
 	/* Update skb to refer to this connection */
-	skb->nfct = &nf_ct_tuplehash_to_ctrack(h)->ct_general;
-	skb->nfctinfo = ctinfo;
+	skb->_nfct = (unsigned long)
+		&nf_ct_tuplehash_to_ctrack(h)->ct_general | ctinfo;
 	return NF_ACCEPT;
 }
 
@@ -222,9 +222,9 @@ icmpv6_error(struct net *net, struct nf_conn *tmpl,
 	type = icmp6h->icmp6_type - 130;
 	if (type >= 0 && type < sizeof(noct_valid_new) &&
 	    noct_valid_new[type]) {
-		skb->nfct = &nf_ct_untracked_get()->ct_general;
-		skb->nfctinfo = IP_CT_NEW;
-		nf_conntrack_get(skb->nfct);
+		skb->_nfct = (unsigned long)
+			&nf_ct_untracked_get()->ct_general | IP_CT_NEW;
+		nf_conntrack_get(skb_nfct(skb));
 		return NF_ACCEPT;
 	}
 
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index 8e0bdd058787..e6c74e136f7a 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -37,7 +37,7 @@ static enum ip6_defrag_users nf_ct6_defrag_user(unsigned int hooknum,
 {
 	u16 zone_id = NF_CT_DEFAULT_ZONE_ID;
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
-	if (skb->nfct) {
+	if (skb->_nfct) {
 		enum ip_conntrack_info ctinfo;
 		const struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 
@@ -61,7 +61,7 @@ static unsigned int ipv6_defrag(void *priv,
 
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	/* Previously seen (loopback)?	*/
-	if (skb->nfct && !nf_ct_is_template((struct nf_conn *)skb->nfct))
+	if (skb->_nfct && !nf_ct_is_template((struct nf_conn *)(skb_nfct(skb))))
 		return NF_ACCEPT;
 #endif
 
diff --git a/net/ipv6/netfilter/nf_dup_ipv6.c b/net/ipv6/netfilter/nf_dup_ipv6.c
index 5f52e5f90e7e..6d7a119d5eee 100644
--- a/net/ipv6/netfilter/nf_dup_ipv6.c
+++ b/net/ipv6/netfilter/nf_dup_ipv6.c
@@ -50,6 +50,8 @@ static bool nf_dup_ipv6_route(struct net *net, struct sk_buff *skb,
 void nf_dup_ipv6(struct net *net, struct sk_buff *skb, unsigned int hooknum,
 		 const struct in6_addr *gw, int oif)
 {
+	struct nf_conn *untracked;
+
 	if (this_cpu_read(nf_skb_duplicated))
 		return;
 	skb = pskb_copy(skb, GFP_ATOMIC);
@@ -57,10 +59,10 @@ void nf_dup_ipv6(struct net *net, struct sk_buff *skb, unsigned int hooknum,
 		return;
 
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
+	untracked = nf_ct_untracked_get();
 	nf_reset(skb);
-	skb->nfct     = &nf_ct_untracked_get()->ct_general;
-	skb->nfctinfo = IP_CT_NEW;
-	nf_conntrack_get(skb->nfct);
+	nf_conntrack_get(&untracked->ct_general);
+	skb->_nfct = (unsigned long) untracked | IP_CT_NEW;
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
index adb7af3a4c4c..1fddcb728250 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -694,7 +694,7 @@ static int nf_ct_resolve_clash(struct net *net, struct sk_buff *skb,
 		/* Assign conntrack already in hashes to this skbuff. Don't
 		 * modify skb->nfctinfo to ensure consistent stateful filtering.
 		 */
-		skb->nfct = &ct->ct_general;
+		skb->_nfct = (unsigned long)ct | oldinfo;
 		return NF_ACCEPT;
 	}
 	NF_CT_STAT_INC(net, drop);
@@ -1223,7 +1223,7 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 	return &ct->tuplehash[IP_CT_DIR_ORIGINAL];
 }
 
-/* On success, returns conntrack ptr, sets skb->nfct and ctinfo */
+/* On success, returns conntrack ptr, sets skb->_nfct | ctinfo */
 static inline struct nf_conn *
 resolve_normal_ct(struct net *net, struct nf_conn *tmpl,
 		  struct sk_buff *skb,
@@ -1282,8 +1282,7 @@ resolve_normal_ct(struct net *net, struct nf_conn *tmpl,
 		}
 		*set_reply = 0;
 	}
-	skb->nfct = &ct->ct_general;
-	skb->nfctinfo = *ctinfo;
+	skb->_nfct = (unsigned long) &ct->ct_general | *ctinfo;
 	return ct;
 }
 
@@ -1308,7 +1307,7 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 			NF_CT_STAT_INC_ATOMIC(net, ignore);
 			return NF_ACCEPT;
 		}
-		skb->nfct = NULL;
+		skb->_nfct = 0;
 	}
 
 	/* rcu_read_lock()ed by nf_hook_thresh */
@@ -1337,7 +1336,7 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 			goto out;
 		}
 		/* ICMP[v6] protocol trackers may assign one conntrack. */
-		if (skb->nfct)
+		if (skb->_nfct)
 			goto out;
 	}
 repeat:
@@ -1357,7 +1356,7 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 		goto out;
 	}
 
-	NF_CT_ASSERT(skb->nfct);
+	NF_CT_ASSERT(skb->_nfct);
 
 	/* Decide what timeout policy we want to apply to this flow. */
 	timeouts = nf_ct_timeout_lookup(net, ct, l4proto);
@@ -1368,7 +1367,7 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 		 * the netfilter core what to do */
 		pr_debug("nf_conntrack_in: Can't track with proto module\n");
 		nf_conntrack_put(&ct->ct_general);
-		skb->nfct = NULL;
+		skb->_nfct = 0;
 		NF_CT_STAT_INC_ATOMIC(net, invalid);
 		if (ret == -NF_DROP)
 			NF_CT_STAT_INC_ATOMIC(net, drop);
@@ -1526,9 +1525,8 @@ static void nf_conntrack_attach(struct sk_buff *nskb, const struct sk_buff *skb)
 		ctinfo = IP_CT_RELATED;
 
 	/* Attach to new skbuff, and increment count */
-	nskb->nfct = &ct->ct_general;
-	nskb->nfctinfo = ctinfo;
-	nf_conntrack_get(nskb->nfct);
+	nskb->_nfct = (unsigned long) &ct->ct_general | ctinfo;
+	nf_conntrack_get(skb_nfct(nskb));
 }
 
 /* Bring out ya dead! */
@@ -1864,7 +1862,7 @@ int nf_conntrack_init_start(void)
 	nf_conntrack_max = max_factor * nf_conntrack_htable_size;
 
 	nf_conntrack_cachep = kmem_cache_create("nf_conntrack",
-						sizeof(struct nf_conn), 0,
+						sizeof(struct nf_conn), NFCT_INFOMASK + 1,
 						SLAB_DESTROY_BY_RCU | SLAB_HWCACHE_ALIGN, NULL);
 	if (!nf_conntrack_cachep)
 		goto err_cachep;
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index d009ae663453..c1e5fea20fb2 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -642,6 +642,10 @@ static int __init nf_conntrack_standalone_init(void)
 	if (ret < 0)
 		goto out_start;
 
+	BUILD_BUG_ON(SKB_NFCT_PTRMASK != NFCT_PTRMASK);
+	BUILD_BUG_ON(NFCT_INFOMASK <= IP_CT_NUMBER);
+	BUILD_BUG_ON(NFCT_INFOMASK >= ARCH_KMALLOC_MINALIGN);
+
 #ifdef CONFIG_SYSCTL
 	nf_ct_netfilter_header =
 		register_net_sysctl(&init_net, "net", nf_ct_netfilter_table);
diff --git a/net/netfilter/nf_nat_helper.c b/net/netfilter/nf_nat_helper.c
index 2840abb5bb99..211661cb2c90 100644
--- a/net/netfilter/nf_nat_helper.c
+++ b/net/netfilter/nf_nat_helper.c
@@ -60,7 +60,7 @@ static void mangle_contents(struct sk_buff *skb,
 		__skb_trim(skb, skb->len + rep_len - match_len);
 	}
 
-	if (nf_ct_l3num((struct nf_conn *)skb->nfct) == NFPROTO_IPV4) {
+	if (nf_ct_l3num((struct nf_conn *)skb_nfct(skb)) == NFPROTO_IPV4) {
 		/* fix IP hdr checksum information */
 		ip_hdr(skb)->tot_len = htons(skb->len);
 		ip_send_check(ip_hdr(skb));
diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index d774d7823688..e05865c98ae0 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -554,8 +554,7 @@ static void nft_notrack_eval(const struct nft_expr *expr,
 
 	ct = nf_ct_untracked_get();
 	atomic_inc(&ct->ct_general.use);
-	skb->nfct = &ct->ct_general;
-	skb->nfctinfo = IP_CT_NEW;
+	skb->_nfct = (unsigned long)ct | IP_CT_NEW;
 }
 
 static struct nft_expr_type nft_notrack_type;
diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index 95c750358747..f18ceb47dbf0 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -23,15 +23,14 @@
 static inline int xt_ct_target(struct sk_buff *skb, struct nf_conn *ct)
 {
 	/* Previously seen (loopback)? Ignore. */
-	if (skb->nfct != NULL)
+	if (skb->_nfct != 0)
 		return XT_CONTINUE;
 
 	/* special case the untracked ct : we want the percpu object */
 	if (!ct)
 		ct = nf_ct_untracked_get();
 	atomic_inc(&ct->ct_general.use);
-	skb->nfct = &ct->ct_general;
-	skb->nfctinfo = IP_CT_NEW;
+	skb->_nfct = (unsigned long) &ct->ct_general | IP_CT_NEW;
 
 	return XT_CONTINUE;
 }
@@ -407,12 +406,12 @@ static unsigned int
 notrack_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	/* Previously seen (loopback)? Ignore. */
-	if (skb->nfct != NULL)
+	if (skb->_nfct != 0)
 		return XT_CONTINUE;
 
-	skb->nfct = &nf_ct_untracked_get()->ct_general;
-	skb->nfctinfo = IP_CT_NEW;
-	nf_conntrack_get(skb->nfct);
+	skb->_nfct = (unsigned long)
+			&nf_ct_untracked_get()->ct_general | IP_CT_NEW;
+	nf_conntrack_get(skb_nfct(skb));
 
 	return XT_CONTINUE;
 }
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 6b78bab27755..63c86d130008 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -157,7 +157,7 @@ static void __ovs_ct_update_key(struct sw_flow_key *key, u8 state,
 	ovs_ct_get_labels(ct, &key->ct.labels);
 }
 
-/* Update 'key' based on skb->nfct.  If 'post_ct' is true, then OVS has
+/* Update 'key' based on skb->_nfct.  If 'post_ct' is true, then OVS has
  * previously sent the packet to conntrack via the ct action.  If
  * 'keep_nat_flags' is true, the existing NAT flags retained, else they are
  * initialized from the connection status.
@@ -421,11 +421,11 @@ ovs_ct_get_info(const struct nf_conntrack_tuple_hash *h)
 
 /* Find an existing connection which this packet belongs to without
  * re-attributing statistics or modifying the connection state.  This allows an
- * skb->nfct lost due to an upcall to be recovered during actions execution.
+ * skb->_nfct lost due to an upcall to be recovered during actions execution.
  *
  * Must be called with rcu_read_lock.
  *
- * On success, populates skb->nfct and skb->nfctinfo, and returns the
+ * On success, populates skb->_nfct and returns the
  * connection.  Returns NULL if there is no existing entry.
  */
 static struct nf_conn *
@@ -460,12 +460,11 @@ ovs_ct_find_existing(struct net *net, const struct nf_conntrack_zone *zone,
 
 	ct = nf_ct_tuplehash_to_ctrack(h);
 
-	skb->nfct = &ct->ct_general;
-	skb->nfctinfo = ovs_ct_get_info(h);
+	skb->_nfct = (unsigned long)ct | ovs_ct_get_info(h);
 	return ct;
 }
 
-/* Determine whether skb->nfct is equal to the result of conntrack lookup. */
+/* Determine whether skb->_nfct is equal to the result of conntrack lookup. */
 static bool skb_nfct_cached(struct net *net,
 			    const struct sw_flow_key *key,
 			    const struct ovs_conntrack_info *info,
@@ -476,7 +475,7 @@ static bool skb_nfct_cached(struct net *net,
 
 	ct = nf_ct_get(skb, &ctinfo);
 	/* If no ct, check if we have evidence that an existing conntrack entry
-	 * might be found for this skb.  This happens when we lose a skb->nfct
+	 * might be found for this skb.  This happens when we lose a skb->_nfct
 	 * due to an upcall.  If the connection was not confirmed, it is not
 	 * cached and needs to be run through conntrack again.
 	 */
@@ -721,11 +720,10 @@ static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
 
 		/* Associate skb with specified zone. */
 		if (tmpl) {
-			if (skb->nfct)
-				nf_conntrack_put(skb->nfct);
+			if (skb->_nfct)
+				nf_conntrack_put(skb_nfct(skb));
 			nf_conntrack_get(&tmpl->ct_general);
-			skb->nfct = &tmpl->ct_general;
-			skb->nfctinfo = IP_CT_NEW;
+			skb->_nfct = (unsigned long)tmpl | IP_CT_NEW;
 		}
 
 		err = nf_conntrack_in(net, info->family,
@@ -819,7 +817,7 @@ static int ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
 		if (err)
 			return err;
 
-		ct = (struct nf_conn *)skb->nfct;
+		ct = (struct nf_conn *)skb_nfct(skb);
 		if (ct)
 			nf_ct_deliver_cached_events(ct);
 	}
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 6575aba87630..3d6b9286c203 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -129,7 +129,7 @@ static u32 flow_get_mark(const struct sk_buff *skb)
 static u32 flow_get_nfct(const struct sk_buff *skb)
 {
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
-	return addr_fold(skb->nfct);
+	return addr_fold(skb_nfct(skb));
 #else
 	return 0;
 #endif
-- 
2.7.3
