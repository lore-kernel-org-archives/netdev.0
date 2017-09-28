From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v3 net-next 1/8] flow_dissector: Change skbuf argument to be non const
Date: Thu, 28 Sep 2017 14:48:16 -0700
Message-ID: <20170928214823.2426-1-tom@quantonium.net>
Cc: netdev@vger.kernel.org, rohit@quantonium.net,
        Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:51875 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750805AbdI1Vsh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 17:48:37 -0400
Received: by mail-pg0-f47.google.com with SMTP id k193so1638596pgc.8
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 14:48:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change the skbuf argument of __skb_flow_dissect to be non constant so
that the function can call functions that take non constant skbuf
arguments. This is needed if we are to call socket lookup or BPF in the
flow dissector path.

The changes include unraveling the call chain into __skb_flow_dissect so
that those also use non constant skbufs.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 include/linux/skbuff.h    | 12 ++++++------
 include/net/ip_fib.h      |  4 ++--
 include/net/route.h       |  4 ++--
 net/core/flow_dissector.c | 10 +++++-----
 net/ipv4/fib_semantics.c  |  2 +-
 net/ipv4/route.c          |  6 +++---
 net/sched/sch_sfq.c       |  2 +-
 7 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 19e64bfb1a66..5a6e765e120f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1155,8 +1155,8 @@ __skb_set_sw_hash(struct sk_buff *skb, __u32 hash, bool is_l4)
 }
 
 void __skb_get_hash(struct sk_buff *skb);
-u32 __skb_get_hash_symmetric(const struct sk_buff *skb);
-u32 skb_get_poff(const struct sk_buff *skb);
+u32 __skb_get_hash_symmetric(struct sk_buff *skb);
+u32 skb_get_poff(struct sk_buff *skb);
 u32 __skb_get_poff(const struct sk_buff *skb, void *data,
 		   const struct flow_keys *keys, int hlen);
 __be32 __skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto,
@@ -1172,13 +1172,13 @@ void skb_flow_dissector_init(struct flow_dissector *flow_dissector,
 			     const struct flow_dissector_key *key,
 			     unsigned int key_count);
 
-bool __skb_flow_dissect(const struct sk_buff *skb,
+bool __skb_flow_dissect(struct sk_buff *skb,
 			struct flow_dissector *flow_dissector,
 			void *target_container,
 			void *data, __be16 proto, int nhoff, int hlen,
 			unsigned int flags);
 
-static inline bool skb_flow_dissect(const struct sk_buff *skb,
+static inline bool skb_flow_dissect(struct sk_buff *skb,
 				    struct flow_dissector *flow_dissector,
 				    void *target_container, unsigned int flags)
 {
@@ -1186,7 +1186,7 @@ static inline bool skb_flow_dissect(const struct sk_buff *skb,
 				  NULL, 0, 0, 0, flags);
 }
 
-static inline bool skb_flow_dissect_flow_keys(const struct sk_buff *skb,
+static inline bool skb_flow_dissect_flow_keys(struct sk_buff *skb,
 					      struct flow_keys *flow,
 					      unsigned int flags)
 {
@@ -1225,7 +1225,7 @@ static inline __u32 skb_get_hash_flowi6(struct sk_buff *skb, const struct flowi6
 	return skb->hash;
 }
 
-__u32 skb_get_hash_perturb(const struct sk_buff *skb, u32 perturb);
+__u32 skb_get_hash_perturb(struct sk_buff *skb, u32 perturb);
 
 static inline __u32 skb_get_hash_raw(const struct sk_buff *skb)
 {
diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 1a7f7e424320..a376dfe1ad44 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -374,11 +374,11 @@ int fib_sync_up(struct net_device *dev, unsigned int nh_flags);
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 int fib_multipath_hash(const struct fib_info *fi, const struct flowi4 *fl4,
-		       const struct sk_buff *skb);
+		       struct sk_buff *skb);
 #endif
 void fib_select_multipath(struct fib_result *res, int hash);
 void fib_select_path(struct net *net, struct fib_result *res,
-		     struct flowi4 *fl4, const struct sk_buff *skb);
+		     struct flowi4 *fl4, struct sk_buff *skb);
 
 /* Exported by fib_trie.c */
 void fib_trie_init(void);
diff --git a/include/net/route.h b/include/net/route.h
index 57dfc6850d37..cb95b79f0117 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -114,10 +114,10 @@ int ip_rt_init(void);
 void rt_cache_flush(struct net *net);
 void rt_flush_dev(struct net_device *dev);
 struct rtable *ip_route_output_key_hash(struct net *net, struct flowi4 *flp,
-					const struct sk_buff *skb);
+					struct sk_buff *skb);
 struct rtable *ip_route_output_key_hash_rcu(struct net *net, struct flowi4 *flp,
 					    struct fib_result *res,
-					    const struct sk_buff *skb);
+					    struct sk_buff *skb);
 
 static inline struct rtable *__ip_route_output_key(struct net *net,
 						   struct flowi4 *flp)
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 0a977373d003..76f5e5bc3177 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -424,7 +424,7 @@ static bool skb_flow_dissect_allowed(int *num_hdrs)
  *
  * Caller must take care of zeroing target container memory.
  */
-bool __skb_flow_dissect(const struct sk_buff *skb,
+bool __skb_flow_dissect(struct sk_buff *skb,
 			struct flow_dissector *flow_dissector,
 			void *target_container,
 			void *data, __be16 proto, int nhoff, int hlen,
@@ -1015,7 +1015,7 @@ u32 flow_hash_from_keys(struct flow_keys *keys)
 }
 EXPORT_SYMBOL(flow_hash_from_keys);
 
-static inline u32 ___skb_get_hash(const struct sk_buff *skb,
+static inline u32 ___skb_get_hash(struct sk_buff *skb,
 				  struct flow_keys *keys, u32 keyval)
 {
 	skb_flow_dissect_flow_keys(skb, keys,
@@ -1053,7 +1053,7 @@ EXPORT_SYMBOL(make_flow_keys_digest);
 
 static struct flow_dissector flow_keys_dissector_symmetric __read_mostly;
 
-u32 __skb_get_hash_symmetric(const struct sk_buff *skb)
+u32 __skb_get_hash_symmetric(struct sk_buff *skb)
 {
 	struct flow_keys keys;
 
@@ -1090,7 +1090,7 @@ void __skb_get_hash(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(__skb_get_hash);
 
-__u32 skb_get_hash_perturb(const struct sk_buff *skb, u32 perturb)
+__u32 skb_get_hash_perturb(struct sk_buff *skb, u32 perturb)
 {
 	struct flow_keys keys;
 
@@ -1158,7 +1158,7 @@ u32 __skb_get_poff(const struct sk_buff *skb, void *data,
  * truncate packets without needing to push actual payload to the user
  * space and can analyze headers only, instead.
  */
-u32 skb_get_poff(const struct sk_buff *skb)
+u32 skb_get_poff(struct sk_buff *skb)
 {
 	struct flow_keys keys;
 
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 57a5d48acee8..dc610646bc4c 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1759,7 +1759,7 @@ void fib_select_multipath(struct fib_result *res, int hash)
 #endif
 
 void fib_select_path(struct net *net, struct fib_result *res,
-		     struct flowi4 *fl4, const struct sk_buff *skb)
+		     struct flowi4 *fl4, struct sk_buff *skb)
 {
 	bool oif_check;
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 94d4cd2d5ea4..94c5b81d8f2b 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1791,7 +1791,7 @@ static void ip_multipath_l3_keys(const struct sk_buff *skb,
 
 /* if skb is set it will be used and fl4 can be NULL */
 int fib_multipath_hash(const struct fib_info *fi, const struct flowi4 *fl4,
-		       const struct sk_buff *skb)
+		       struct sk_buff *skb)
 {
 	struct net *net = fi->fib_net;
 	struct flow_keys hash_keys;
@@ -2270,7 +2270,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
  */
 
 struct rtable *ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
-					const struct sk_buff *skb)
+					struct sk_buff *skb)
 {
 	__u8 tos = RT_FL_TOS(fl4);
 	struct fib_result res;
@@ -2295,7 +2295,7 @@ EXPORT_SYMBOL_GPL(ip_route_output_key_hash);
 
 struct rtable *ip_route_output_key_hash_rcu(struct net *net, struct flowi4 *fl4,
 					    struct fib_result *res,
-					    const struct sk_buff *skb)
+					    struct sk_buff *skb)
 {
 	struct net_device *dev_out = NULL;
 	int orig_oif = fl4->flowi4_oif;
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 74ea863b8240..0d2d3a8d03f0 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -158,7 +158,7 @@ static inline struct sfq_head *sfq_dep_head(struct sfq_sched_data *q, sfq_index
 }
 
 static unsigned int sfq_hash(const struct sfq_sched_data *q,
-			     const struct sk_buff *skb)
+			     struct sk_buff *skb)
 {
 	return skb_get_hash_perturb(skb, q->perturbation) & (q->divisor - 1);
 }
-- 
2.11.0
