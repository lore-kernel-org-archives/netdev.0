From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 11/14] netfilter: bridge: remove skb->nf_bridge
Date: Wed,  1 Apr 2015 22:36:37 +0200
Message-ID: <1427920600-20366-12-git-send-email-fw@strlen.de>
References: <1427920600-20366-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1427920600-20366-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of carrying around the nf_bridge metadata using
sk_buff, add a br_netfilter private storage table and do lookups
on demand.

sk_buff now only stores a 2bit bridge netfilter state to avoid the
nf_bridge_info lookups in the hot-path (i.e., if state field is zero
we know that there is no nf_bridge_info structure since skb isn't
bridged).

The nf_bridge_info data is stored in an rhashtable.
Key is the address of the skb that the nf_bridge_info is storing
data for.  Each clone has its own nf_bridge_info copy.

The deep copy on skb_clone() is best-effort: if allocation fails
the next processing step in the bridge netfilter chain will drop
the skb if it cannot find the needed metadata supposedly associated
with the skb.

SLAB_DESTROY_BY_RCU is used to avoid excess memory usage, we cannot
wait for rcu grace periods in packet processing path.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/netfilter.h        |   8 ++
 include/linux/netfilter_bridge.h |  49 ++++++++-
 include/linux/skbuff.h           |  51 ++-------
 net/bridge/br_netfilter.c        | 231 ++++++++++++++++++++++++++++++---------
 net/core/skbuff.c                |   2 +-
 net/netfilter/core.c             |  49 +++++++++
 6 files changed, 289 insertions(+), 101 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 2517ece..2385135 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -339,4 +339,12 @@ extern struct nfq_ct_hook __rcu *nfq_ct_hook;
 static inline void nf_ct_attach(struct sk_buff *new, struct sk_buff *skb) {}
 #endif
 
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
+struct nf_br_hook {
+	void (*nf_br_destroy)(struct sk_buff *);
+	struct nf_bridge_info* (*nf_br_find)(const struct sk_buff *);
+	bool (*nf_br_copy)(struct sk_buff *dst, const struct sk_buff *src);
+};
+#endif
+
 #endif /*__LINUX_NETFILTER_H*/
diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index f2d7abc..621a2e4 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -3,6 +3,7 @@
 
 #include <uapi/linux/netfilter_bridge.h>
 #include <linux/skbuff.h>
+#include <linux/rhashtable.h>
 
 enum nf_br_hook_priorities {
 	NF_BR_PRI_FIRST = INT_MIN,
@@ -30,6 +31,22 @@ enum brnf_state {
 	BRNF_STATE_BRIDGED_DNAT,
 };
 
+struct nf_bridge_info {
+	struct rhash_head	node;
+	enum {
+		BRNF_PROTO_UNCHANGED,
+		BRNF_PROTO_8021Q,
+		BRNF_PROTO_PPPOE
+	} orig_proto;
+	bool			pkt_otherhost;
+	unsigned long		owner;
+	struct net_device	*physindev;
+	struct net_device	*physoutdev;
+	char			neigh_header[8];
+};
+
+struct nf_bridge_info *nf_bridge_find(const struct sk_buff *skb);
+
 int br_handle_frame_finish(struct sk_buff *skb);
 
 static inline void br_drop_fake_rtable(struct sk_buff *skb)
@@ -42,24 +59,48 @@ static inline void br_drop_fake_rtable(struct sk_buff *skb)
 
 static inline int nf_bridge_get_physinif(const struct sk_buff *skb)
 {
-	return skb->nf_bridge ? skb->nf_bridge->physindev->ifindex : 0;
+	struct nf_bridge_info *nf_bridge;
+
+	if (skb->nf_bridge_state == 0)
+		return 0;
+
+	nf_bridge = nf_bridge_find(skb);
+	return nf_bridge ? nf_bridge->physindev->ifindex : 0;
 }
 
 static inline int nf_bridge_get_physoutif(const struct sk_buff *skb)
 {
-	return skb->nf_bridge ? skb->nf_bridge->physoutdev->ifindex : 0;
+	struct nf_bridge_info *nf_bridge;
+
+	if (skb->nf_bridge_state == 0)
+		return 0;
+
+	nf_bridge = nf_bridge_find(skb);
+	return nf_bridge ? nf_bridge->physoutdev->ifindex : 0;
 }
 
 static inline struct net_device *
 nf_bridge_get_physindev(const struct sk_buff *skb)
 {
-	return skb->nf_bridge ? skb->nf_bridge->physindev : NULL;
+	struct nf_bridge_info *nf_bridge;
+
+	if (skb->nf_bridge_state == 0)
+		return NULL;
+
+	nf_bridge = nf_bridge_find(skb);
+	return nf_bridge ? nf_bridge->physindev : NULL;
 }
 
 static inline struct net_device *
 nf_bridge_get_physoutdev(const struct sk_buff *skb)
 {
-	return skb->nf_bridge ? skb->nf_bridge->physoutdev : NULL;
+	struct nf_bridge_info *nf_bridge;
+
+	if (skb->nf_bridge_state == 0)
+		return NULL;
+
+	nf_bridge = nf_bridge_find(skb);
+	return nf_bridge ? nf_bridge->physoutdev : NULL;
 }
 #else
 #define br_drop_fake_rtable(skb)	        do { } while (0)
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c060db5..c596e4e 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -163,21 +163,6 @@ struct nf_conntrack {
 };
 #endif
 
-#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
-struct nf_bridge_info {
-	atomic_t		use;
-	enum {
-		BRNF_PROTO_UNCHANGED,
-		BRNF_PROTO_8021Q,
-		BRNF_PROTO_PPPOE
-	} orig_proto;
-	bool			pkt_otherhost;
-	struct net_device	*physindev;
-	struct net_device	*physoutdev;
-	char			neigh_header[8];
-};
-#endif
-
 struct sk_buff_head {
 	/* These two members must be first. */
 	struct sk_buff	*next;
@@ -482,7 +467,6 @@ static inline u32 skb_mstamp_us_delta(const struct skb_mstamp *t1,
  *	@protocol: Packet protocol from driver
  *	@destructor: Destruct function
  *	@nfct: Associated connection, if any
- *	@nf_bridge: Saved data about a bridged frame - see br_netfilter.c
  *	@skb_iif: ifindex of device we arrived on
  *	@tc_index: Traffic control index
  *	@tc_verd: traffic control verdict
@@ -550,9 +534,6 @@ struct sk_buff {
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 	struct nf_conntrack	*nfct;
 #endif
-#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
-	struct nf_bridge_info	*nf_bridge;
-#endif
 	unsigned int		len,
 				data_len;
 	__u16			mac_len,
@@ -3164,17 +3145,10 @@ static inline void nf_conntrack_get(struct nf_conntrack *nfct)
 }
 #endif
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
-static inline void nf_bridge_put(struct nf_bridge_info *nf_bridge)
-{
-	if (nf_bridge && atomic_dec_and_test(&nf_bridge->use))
-		kfree(nf_bridge);
-}
-static inline void nf_bridge_get(struct nf_bridge_info *nf_bridge)
-{
-	if (nf_bridge)
-		atomic_inc(&nf_bridge->use);
-}
-#endif /* CONFIG_BRIDGE_NETFILTER */
+void nf_bridge_destroy(struct sk_buff *skb);
+bool nf_bridge_copy(struct sk_buff *dst, const struct sk_buff *src);
+#endif
+
 static inline void nf_reset(struct sk_buff *skb)
 {
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
@@ -3183,8 +3157,7 @@ static inline void nf_reset(struct sk_buff *skb)
 #endif
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	if (skb->nf_bridge_state) {
-		nf_bridge_put(skb->nf_bridge);
-		skb->nf_bridge = NULL;
+		nf_bridge_destroy(skb);
 		skb->nf_bridge_state = 0;
 	}
 #endif
@@ -3208,12 +3181,8 @@ static inline void __nf_copy(struct sk_buff *dst, const struct sk_buff *src,
 		dst->nfctinfo = src->nfctinfo;
 #endif
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
-	if (src->nf_bridge_state) {
-		dst->nf_bridge = src->nf_bridge;
-		nf_bridge_get(src->nf_bridge);
-	} else {
-		dst->nf_bridge = NULL;
-	}
+	if (src->nf_bridge_state)
+		nf_bridge_copy(dst, src);
 #endif
 #if IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TRACE) || defined(CONFIG_NF_TABLES)
 	if (copy)
@@ -3227,10 +3196,8 @@ static inline void nf_copy(struct sk_buff *dst, const struct sk_buff *src)
 	nf_conntrack_put(dst->nfct);
 #endif
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
-	if (dst->nf_bridge_state) {
-		nf_bridge_put(dst->nf_bridge);
-		dst->nf_bridge = NULL;
-	}
+	if (dst->nf_bridge_state)
+		nf_bridge_destroy(dst);
 #endif
 	__nf_copy(dst, src, true);
 }
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 832164e..3f1f920 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -25,12 +25,14 @@
 #include <linux/if_vlan.h>
 #include <linux/if_pppox.h>
 #include <linux/ppp_defs.h>
+#include <linux/netfilter.h>
 #include <linux/netfilter_bridge.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/netfilter_ipv6.h>
 #include <linux/netfilter_arp.h>
 #include <linux/in_route.h>
 #include <linux/inetdevice.h>
+#include <linux/rhashtable.h>
 
 #include <net/ip.h>
 #include <net/ipv6.h>
@@ -124,9 +126,77 @@ struct brnf_frag_data {
 static DEFINE_PER_CPU(struct brnf_frag_data, brnf_frag_data_storage);
 #endif
 
+extern const struct nf_br_hook __rcu *nf_br_hook;
+static struct kmem_cache *nf_bridge_cachep __read_mostly;
+static struct rhashtable nf_bridge_info_table;
+
+static const struct rhashtable_params nf_bridge_info_params = {
+	.head_offset = offsetof(struct nf_bridge_info, node),
+	.key_offset = offsetof(struct nf_bridge_info, owner),
+	.key_len = FIELD_SIZEOF(struct nf_bridge_info, owner),
+	.hashfn = jhash,
+	.nulls_base = (3U << RHT_BASE_SHIFT),
+};
+
+/* must be called with rcu read lock held */
 static struct nf_bridge_info *nf_bridge_info_get(const struct sk_buff *skb)
 {
-	return skb->nf_bridge;
+	unsigned long key = (unsigned long)skb;
+	struct nf_bridge_info *nf_bridge;
+
+	nf_bridge = rhashtable_lookup_fast(&nf_bridge_info_table, &key,
+					   nf_bridge_info_params);
+
+	WARN_ON_ONCE(!nf_bridge && skb->nf_bridge_state);
+
+	return nf_bridge;
+}
+
+static void nf_bridge_info_free(struct nf_bridge_info *info)
+{
+	kmem_cache_free(nf_bridge_cachep, info);
+}
+
+/* must be called with rcu read lock held */
+static bool nf_bridge_info_copy(struct sk_buff *dst, const struct sk_buff *src)
+{
+	struct nf_bridge_info *info, *newinfo;
+
+	info = nf_bridge_info_get(src);
+	if (WARN_ON_ONCE(!info))
+		return false;
+
+	newinfo = kmem_cache_alloc(nf_bridge_cachep, GFP_ATOMIC);
+	if (!newinfo)
+		return false;
+
+	memcpy(newinfo, info, sizeof(*newinfo));
+
+	newinfo->owner = (unsigned long)dst;
+
+	if (rhashtable_insert_fast(&nf_bridge_info_table, &newinfo->node,
+				   nf_bridge_info_params) == 0)
+		return true;
+
+	nf_bridge_info_free(newinfo);
+	return false;
+}
+
+static void nf_bridge_info_del(struct sk_buff *skb)
+{
+	struct nf_bridge_info *nf_bridge = nf_bridge_info_get(skb);
+
+	if (nf_bridge) {
+		int err = rhashtable_remove_fast(&nf_bridge_info_table,
+						 &nf_bridge->node,
+						 nf_bridge_info_params);
+		WARN_ON(err);
+
+		if (err == 0)
+			nf_bridge_info_free(nf_bridge);
+	} else {
+		WARN_ON_ONCE(1);
+	}
 }
 
 static inline struct rtable *bridge_parent_rtable(const struct net_device *dev)
@@ -147,31 +217,25 @@ static inline struct net_device *bridge_parent(const struct net_device *dev)
 
 static inline struct nf_bridge_info *nf_bridge_alloc(struct sk_buff *skb)
 {
-	skb->nf_bridge = kzalloc(sizeof(struct nf_bridge_info), GFP_ATOMIC);
+	struct nf_bridge_info *nf_bridge;
 
-	if (likely(skb->nf_bridge)) {
-		atomic_set(&(skb->nf_bridge->use), 1);
-		skb->nf_bridge_state = BRNF_STATE_SEEN;
-	}
+	nf_bridge = kmem_cache_alloc(nf_bridge_cachep, GFP_ATOMIC);
+	if (!nf_bridge)
+		return NULL;
 
-	return skb->nf_bridge;
-}
+	skb->nf_bridge_state = BRNF_STATE_SEEN;
 
-static inline struct nf_bridge_info *nf_bridge_unshare(struct sk_buff *skb)
-{
-	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
+	nf_bridge->orig_proto = BRNF_PROTO_UNCHANGED;
+	nf_bridge->pkt_otherhost = false;
+	nf_bridge->owner = (unsigned long)skb;
+	nf_bridge->physoutdev = NULL;
 
-	if (atomic_read(&nf_bridge->use) > 1) {
-		struct nf_bridge_info *tmp = nf_bridge_alloc(skb);
+	if (rhashtable_insert_fast(&nf_bridge_info_table, &nf_bridge->node,
+				   nf_bridge_info_params) == 0)
+		return nf_bridge;
 
-		if (tmp) {
-			memcpy(tmp, nf_bridge, sizeof(struct nf_bridge_info));
-			atomic_set(&tmp->use, 1);
-		}
-		nf_bridge_put(nf_bridge);
-		nf_bridge = tmp;
-	}
-	return nf_bridge;
+	kmem_cache_free(nf_bridge_cachep, nf_bridge);
+	return NULL;
 }
 
 static unsigned int nf_bridge_encap_header_len(const struct sk_buff *skb)
@@ -263,9 +327,10 @@ drop:
 	return -1;
 }
 
-static void nf_bridge_update_protocol(struct sk_buff *skb)
+static void nf_bridge_update_protocol(struct sk_buff *skb,
+				      const struct nf_bridge_info *nf_bridge)
 {
-	switch (skb->nf_bridge->orig_proto) {
+	switch (nf_bridge->orig_proto) {
 	case BRNF_PROTO_8021Q:
 		skb->protocol = htons(ETH_P_8021Q);
 		break;
@@ -285,6 +350,11 @@ static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
 	struct nf_bridge_info *nf_bridge = nf_bridge_info_get(skb);
 	struct rtable *rt;
 
+	if (WARN_ON_ONCE(!nf_bridge)) {
+		kfree_skb(skb);
+		return 0;
+	}
+
 	if (nf_bridge->pkt_otherhost) {
 		skb->pkt_type = PACKET_OTHERHOST;
 		nf_bridge->pkt_otherhost = false;
@@ -299,7 +369,7 @@ static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
 	skb_dst_set_noref(skb, &rt->dst);
 
 	skb->dev = nf_bridge->physindev;
-	nf_bridge_update_protocol(skb);
+	nf_bridge_update_protocol(skb, nf_bridge);
 	nf_bridge_push_encap_header(skb);
 	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
 		       br_handle_frame_finish, 1);
@@ -326,6 +396,9 @@ static int br_nf_pre_routing_finish_bridge(struct sk_buff *skb)
 		struct nf_bridge_info *nf_bridge = nf_bridge_info_get(skb);
 		int ret;
 
+		if (!nf_bridge)
+			goto free_skb;
+
 		if (neigh->hh.hh_len) {
 			neigh_hh_bridge(&neigh->hh, skb);
 			skb->dev = nf_bridge->physindev;
@@ -414,6 +487,9 @@ static int br_nf_pre_routing_finish(struct sk_buff *skb)
 	int err;
 	int frag_max_size;
 
+	if (WARN_ON_ONCE(!nf_bridge))
+		goto free_skb;
+
 	frag_max_size = IPCB(skb)->frag_max_size;
 	BR_INPUT_SKB_CB(skb)->frag_max_size = frag_max_size;
 
@@ -454,7 +530,7 @@ free_skb:
 			if (skb_dst(skb)->dev == dev) {
 bridged_dnat:
 				skb->dev = nf_bridge->physindev;
-				nf_bridge_update_protocol(skb);
+				nf_bridge_update_protocol(skb, nf_bridge);
 				nf_bridge_push_encap_header(skb);
 				NF_HOOK_THRESH(NFPROTO_BRIDGE,
 					       NF_BR_PRE_ROUTING,
@@ -476,7 +552,7 @@ bridged_dnat:
 	}
 
 	skb->dev = nf_bridge->physindev;
-	nf_bridge_update_protocol(skb);
+	nf_bridge_update_protocol(skb, nf_bridge);
 	nf_bridge_push_encap_header(skb);
 	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
 		       br_handle_frame_finish, 1);
@@ -503,6 +579,12 @@ static struct net_device *setup_pre_routing(struct sk_buff *skb)
 {
 	struct nf_bridge_info *nf_bridge = nf_bridge_info_get(skb);
 
+	if (!nf_bridge) {
+		nf_bridge = nf_bridge_alloc(skb);
+		if (!nf_bridge)
+			return NULL;
+	}
+
 	if (skb->pkt_type == PACKET_OTHERHOST) {
 		skb->pkt_type = PACKET_HOST;
 		nf_bridge->pkt_otherhost = true;
@@ -610,9 +692,6 @@ static unsigned int br_nf_pre_routing_ipv6(const struct nf_hook_ops *ops,
 	if (hdr->nexthdr == NEXTHDR_HOP && check_hbh_len(skb))
 		return NF_DROP;
 
-	nf_bridge_put(skb->nf_bridge);
-	if (!nf_bridge_alloc(skb))
-		return NF_DROP;
 	if (!setup_pre_routing(skb))
 		return NF_DROP;
 
@@ -666,9 +745,6 @@ static unsigned int br_nf_pre_routing(const struct nf_hook_ops *ops,
 	if (br_parse_ip_options(skb))
 		return NF_DROP;
 
-	nf_bridge_put(skb->nf_bridge);
-	if (!nf_bridge_alloc(skb))
-		return NF_DROP;
 	if (!setup_pre_routing(skb))
 		return NF_DROP;
 
@@ -701,12 +777,17 @@ static unsigned int br_nf_local_in(const struct nf_hook_ops *ops,
 /* PF_BRIDGE/FORWARD *************************************************/
 static int br_nf_forward_finish(struct sk_buff *skb)
 {
-	struct nf_bridge_info *nf_bridge = nf_bridge_info_get(skb);
 	struct net_device *in;
 
 	if (!IS_ARP(skb) && !IS_VLAN_ARP(skb)) {
+		struct nf_bridge_info *nf_bridge = nf_bridge_info_get(skb);
 		int frag_max_size;
 
+		if (WARN_ON_ONCE(!nf_bridge)) {
+			kfree_skb(skb);
+			return 0;
+		}
+
 		if (skb->protocol == htons(ETH_P_IP)) {
 			frag_max_size = IPCB(skb)->frag_max_size;
 			BR_INPUT_SKB_CB(skb)->frag_max_size = frag_max_size;
@@ -717,7 +798,7 @@ static int br_nf_forward_finish(struct sk_buff *skb)
 			skb->pkt_type = PACKET_OTHERHOST;
 			nf_bridge->pkt_otherhost = false;
 		}
-		nf_bridge_update_protocol(skb);
+		nf_bridge_update_protocol(skb, nf_bridge);
 	} else {
 		in = *((struct net_device **)(skb->cb));
 	}
@@ -747,11 +828,6 @@ static unsigned int br_nf_forward_ip(const struct nf_hook_ops *ops,
 	if (!skb->nf_bridge_state)
 		return NF_ACCEPT;
 
-	/* Need exclusive nf_bridge_info since we might have multiple
-	 * different physoutdevs. */
-	if (!nf_bridge_unshare(skb))
-		return NF_DROP;
-
 	nf_bridge = nf_bridge_info_get(skb);
 	if (!nf_bridge)
 		return NF_DROP;
@@ -851,9 +927,10 @@ static int br_nf_push_frag_xmit(struct sk_buff *skb)
 	return br_dev_queue_push_xmit(skb);
 }
 
-static unsigned int nf_bridge_mtu_reduction(const struct sk_buff *skb)
+static unsigned int
+nf_bridge_mtu_reduction(const struct nf_bridge_info *nf_bridge)
 {
-	if (skb->nf_bridge->orig_proto == BRNF_PROTO_PPPOE)
+	if (nf_bridge->orig_proto == BRNF_PROTO_PPPOE)
 		return PPPOE_SES_HLEN;
 	return 0;
 }
@@ -863,13 +940,16 @@ static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 	int ret;
 	int frag_max_size;
 	unsigned int mtu_reserved, mtu;
-
-	skb->nf_bridge_state = BRNF_STATE_NONE;
+	struct nf_bridge_info *nf_bridge;
 
 	if (skb_is_gso(skb) || skb->protocol != htons(ETH_P_IP))
 		return br_dev_queue_push_xmit(skb);
 
-	mtu_reserved = nf_bridge_mtu_reduction(skb);
+	nf_bridge = nf_bridge_info_get(skb);
+	if (!nf_bridge)
+		goto err_out;
+
+	mtu_reserved = nf_bridge_mtu_reduction(nf_bridge);
 	mtu = min(skb->dev->mtu, IP_MAX_MTU) - mtu_reserved;
 
 	/* This is wrong! We should preserve the original fragment
@@ -895,7 +975,7 @@ static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 		if (br_parse_ip_options(skb))
 			goto err_out;
 
-		nf_bridge_update_protocol(skb);
+		nf_bridge_update_protocol(skb, nf_bridge);
 
 		data = this_cpu_ptr(&brnf_frag_data_storage);
 		data->encap_size = nf_bridge_encap_header_len(skb);
@@ -918,9 +998,7 @@ static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 #else
 static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 {
-	skb->nf_bridge_state = BRNF_STATE_NONE;
-
-        return br_dev_queue_push_xmit(skb);
+	return br_dev_queue_push_xmit(skb);
 }
 #endif
 
@@ -931,16 +1009,22 @@ static unsigned int br_nf_post_routing(const struct nf_hook_ops *ops,
 				       const struct net_device *out,
 				       int (*okfn)(struct sk_buff *))
 {
-	struct nf_bridge_info *nf_bridge = nf_bridge_info_get(skb);
+	struct nf_bridge_info *nf_bridge;
 	struct net_device *realoutdev = bridge_parent(skb->dev);
 	u_int8_t pf;
 
-	/* if nf_bridge is set, but ->physoutdev is NULL, this packet came in
-	 * on a bridge, but was delivered locally and is now being routed:
-	 *
+	if (!skb->nf_bridge_state) /* locally generated */
+		return NF_ACCEPT;
+
+	nf_bridge = nf_bridge_info_get(skb);
+	if (!nf_bridge)
+		return NF_DROP;
+
+	/* if ->physoutdev is NULL, this packet came in on a bridge, but
+	 * was delivered locally and is now being routed.
 	 * POST_ROUTING was already invoked from the ip stack.
 	 */
-	if (!nf_bridge || !nf_bridge->physoutdev)
+	if (!nf_bridge->physoutdev)
 		return NF_ACCEPT;
 
 	if (!realoutdev)
@@ -1000,6 +1084,11 @@ static void br_nf_pre_routing_finish_bridge_slow(struct sk_buff *skb)
 {
 	struct nf_bridge_info *nf_bridge = nf_bridge_info_get(skb);
 
+	if (!nf_bridge) {
+		kfree_skb(skb);
+		return;
+	}
+
 	skb_pull(skb, ETH_HLEN);
 	skb->nf_bridge_state = BRNF_STATE_SEEN;
 
@@ -1016,6 +1105,12 @@ static const struct nf_br_ops br_ops = {
 	.br_dev_dnat_hook = br_nf_pre_routing_finish_bridge_slow,
 };
 
+static const struct nf_br_hook br_hook = {
+	.nf_br_destroy = nf_bridge_info_del,
+	.nf_br_find = nf_bridge_info_get,
+	.nf_br_copy = nf_bridge_info_copy,
+};
+
 void br_netfilter_enable(void)
 {
 }
@@ -1140,24 +1235,45 @@ static int __init br_netfilter_init(void)
 {
 	int ret;
 
+	nf_bridge_cachep = kmem_cache_create("nf_bridge_info",
+					     sizeof(struct nf_bridge_info),
+					     0, SLAB_DESTROY_BY_RCU, NULL);
+
+	ret = rhashtable_init(&nf_bridge_info_table, &nf_bridge_info_params);
+	if (ret < 0) {
+		kmem_cache_destroy(nf_bridge_cachep);
+		return ret;
+	}
+
 	ret = nf_register_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
-	if (ret < 0)
+	if (ret < 0) {
+		rhashtable_destroy(&nf_bridge_info_table);
+		kmem_cache_destroy(nf_bridge_cachep);
 		return ret;
+	}
 
 #ifdef CONFIG_SYSCTL
 	brnf_sysctl_header = register_net_sysctl(&init_net, "net/bridge", brnf_table);
 	if (brnf_sysctl_header == NULL) {
 		printk(KERN_WARNING
 		       "br_netfilter: can't register to sysctl.\n");
+		rhashtable_destroy(&nf_bridge_info_table);
+		kmem_cache_destroy(nf_bridge_cachep);
 		nf_unregister_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
 		return -ENOMEM;
 	}
 #endif
 	RCU_INIT_POINTER(nf_br_ops, &br_ops);
+	RCU_INIT_POINTER(nf_br_hook, &br_hook);
 	printk(KERN_NOTICE "Bridge firewalling registered\n");
 	return 0;
 }
 
+static void __exit nf_bridge_info_free_destroy(void *a, void *unused)
+{
+	nf_bridge_info_free(a);
+}
+
 static void __exit br_netfilter_fini(void)
 {
 	RCU_INIT_POINTER(nf_br_ops, NULL);
@@ -1165,6 +1281,13 @@ static void __exit br_netfilter_fini(void)
 #ifdef CONFIG_SYSCTL
 	unregister_net_sysctl_table(brnf_sysctl_header);
 #endif
+	RCU_INIT_POINTER(nf_br_hook, NULL);
+
+	synchronize_net();
+
+	rhashtable_free_and_destroy(&nf_bridge_info_table,
+				    nf_bridge_info_free_destroy, NULL);
+	kmem_cache_destroy(nf_bridge_cachep);
 }
 
 module_init(br_netfilter_init);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 16ccbec..ae249048 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -678,7 +678,7 @@ static void skb_release_head_state(struct sk_buff *skb)
 #endif
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	if (skb->nf_bridge_state)
-		nf_bridge_put(skb->nf_bridge);
+		nf_bridge_destroy(skb);
 #endif
 }
 
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index fea9ef5..85efbfc 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -269,6 +269,55 @@ EXPORT_SYMBOL_GPL(nfq_ct_nat_hook);
 
 #endif /* CONFIG_NF_CONNTRACK */
 
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
+struct nf_br_hook __rcu *nf_br_hook __read_mostly;
+EXPORT_SYMBOL_GPL(nf_br_hook);
+
+void nf_bridge_destroy(struct sk_buff *skb)
+{
+	struct nf_br_hook *h;
+
+	rcu_read_lock();
+	h = rcu_dereference(nf_br_hook);
+	if (h)
+		h->nf_br_destroy(skb);
+	rcu_read_unlock();
+}
+EXPORT_SYMBOL(nf_bridge_destroy);
+
+struct nf_bridge_info *nf_bridge_find(const struct sk_buff *skb)
+{
+	struct nf_bridge_info *info = NULL;
+	struct nf_br_hook *h;
+
+	rcu_read_lock();
+	h = rcu_dereference(nf_br_hook);
+	if (h)
+		info = h->nf_br_find(skb);
+	rcu_read_unlock();
+
+	return info;
+}
+EXPORT_SYMBOL_GPL(nf_bridge_find);
+
+bool nf_bridge_copy(struct sk_buff *dst, const struct sk_buff *src)
+{
+	struct nf_br_hook *h;
+	bool ret = false;
+
+	rcu_read_lock();
+	h = rcu_dereference(nf_br_hook);
+	if (!h)
+		goto out;
+
+	ret = h->nf_br_copy(dst, src);
+ out:
+	rcu_read_unlock();
+	return ret;
+}
+EXPORT_SYMBOL(nf_bridge_copy);
+#endif
+
 #ifdef CONFIG_NF_NAT_NEEDED
 void (*nf_nat_decode_session_hook)(struct sk_buff *, struct flowi *);
 EXPORT_SYMBOL(nf_nat_decode_session_hook);
-- 
2.0.5

