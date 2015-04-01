From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 10/14] netfilter: bridge: move bridge netfilter state into sk_buff
Date: Wed,  1 Apr 2015 22:36:36 +0200
Message-ID: <1427920600-20366-11-git-send-email-fw@strlen.de>
References: <1427920600-20366-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:42849 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752756AbbDAUhB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 16:37:01 -0400
In-Reply-To: <1427920600-20366-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb->nf_bridge is only used when interface is part of a bridge and
bridge netfilter is used with 'call-iptables' sysctl set to 1 and
the skb was received on a bridge port. IOW, almost noone uses it.

This moves the skb bridge netfilter state (2 bits) to the skb itself.

This means we can now determine if an skb is subject to bridge
netfilter by looking at skb->nf_bridge_state in addition to
skb->nf_bridge pointer.

This makes it possible to remove the skb->nf_bridge in a followup
patch, while still allowing fast-path users to termine if slow-path
operations are needed by looking at skb->nf_bridge_state.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/netfilter_bridge.h          | 14 ++++++++++--
 include/linux/skbuff.h                    | 28 ++++++++++++++++-------
 net/bridge/br_device.c                    | 19 +++++++++++-----
 net/bridge/br_netfilter.c                 | 37 +++++++++++++------------------
 net/bridge/br_private.h                   |  2 +-
 net/core/skbuff.c                         |  3 ++-
 net/ipv4/netfilter/nf_defrag_ipv4.c       |  3 +--
 net/ipv4/netfilter/nf_reject_ipv4.c       |  2 +-
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c |  3 +--
 net/ipv6/netfilter/nf_reject_ipv6.c       |  2 +-
 net/netfilter/nf_log_common.c             |  2 +-
 net/netfilter/nf_queue.c                  |  4 ++--
 net/netfilter/nfnetlink_queue_core.c      |  6 ++---
 net/netfilter/xt_physdev.c                |  2 +-
 14 files changed, 75 insertions(+), 52 deletions(-)

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index 61251e4..f2d7abc 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -16,9 +16,19 @@ enum nf_br_hook_priorities {
 };
 
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
+enum brnf_state {
+	BRNF_STATE_NONE,
+	BRNF_STATE_SEEN = 1,
 
-#define BRNF_BRIDGED_DNAT		0x02
-#define BRNF_NF_BRIDGE_PREROUTING	0x08
+	/* IPV4/IPV6 PRE_ROUTING called from bridge netfilter */
+	BRNF_STATE_PREROUTING,
+
+	/* skb that is 'transmitted' via bridge must to be injected
+	 * back into br forwarding for delivery to the correct bridge output
+	 * port due to DNAT to a destination on the same (bridged) network.
+	 */
+	BRNF_STATE_BRIDGED_DNAT,
+};
 
 int br_handle_frame_finish(struct sk_buff *skb);
 
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 0991259..c060db5 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -172,7 +172,6 @@ struct nf_bridge_info {
 		BRNF_PROTO_PPPOE
 	} orig_proto;
 	bool			pkt_otherhost;
-	unsigned int		mask;
 	struct net_device	*physindev;
 	struct net_device	*physoutdev;
 	char			neigh_header[8];
@@ -474,6 +473,9 @@ static inline u32 skb_mstamp_us_delta(const struct skb_mstamp *t1,
  *	@pkt_type: Packet class
  *	@fclone: skbuff clone status
  *	@ipvs_property: skbuff is owned by ipvs
+ *	@inner_protocol_type: encapsulation type
+ *	@remcsum_offload: udp remote checksum offload
+ *	@nf_bridge_state: bridge netfilter skb state
  *	@peeked: this packet has been seen already, so stats have been
  *		done for it, don't do them again
  *	@nf_trace: netfilter packet trace flag
@@ -614,8 +616,8 @@ struct sk_buff {
 	__u8			ipvs_property:1;
 	__u8			inner_protocol_type:1;
 	__u8			remcsum_offload:1;
-	/* 3 or 5 bit hole */
-
+	__u8			nf_bridge_state:2;
+	/* 1 or 3 bit hole */
 #ifdef CONFIG_NET_SCHED
 	__u16			tc_index;	/* traffic control index */
 #ifdef CONFIG_NET_CLS_ACT
@@ -3180,8 +3182,11 @@ static inline void nf_reset(struct sk_buff *skb)
 	skb->nfct = NULL;
 #endif
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
-	nf_bridge_put(skb->nf_bridge);
-	skb->nf_bridge = NULL;
+	if (skb->nf_bridge_state) {
+		nf_bridge_put(skb->nf_bridge);
+		skb->nf_bridge = NULL;
+		skb->nf_bridge_state = 0;
+	}
 #endif
 }
 
@@ -3203,8 +3208,12 @@ static inline void __nf_copy(struct sk_buff *dst, const struct sk_buff *src,
 		dst->nfctinfo = src->nfctinfo;
 #endif
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
-	dst->nf_bridge  = src->nf_bridge;
-	nf_bridge_get(src->nf_bridge);
+	if (src->nf_bridge_state) {
+		dst->nf_bridge = src->nf_bridge;
+		nf_bridge_get(src->nf_bridge);
+	} else {
+		dst->nf_bridge = NULL;
+	}
 #endif
 #if IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TRACE) || defined(CONFIG_NF_TABLES)
 	if (copy)
@@ -3218,7 +3227,10 @@ static inline void nf_copy(struct sk_buff *dst, const struct sk_buff *src)
 	nf_conntrack_put(dst->nfct);
 #endif
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
-	nf_bridge_put(dst->nf_bridge);
+	if (dst->nf_bridge_state) {
+		nf_bridge_put(dst->nf_bridge);
+		dst->nf_bridge = NULL;
+	}
 #endif
 	__nf_copy(dst, src, true);
 }
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 4ff77a1..99b78ff 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -36,16 +36,23 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct net_bridge_fdb_entry *dst;
 	struct net_bridge_mdb_entry *mdst;
 	struct pcpu_sw_netstats *brstats = this_cpu_ptr(br->stats);
-	const struct nf_br_ops *nf_ops;
 	u16 vid = 0;
 
 	rcu_read_lock();
-	nf_ops = rcu_dereference(nf_br_ops);
-	if (nf_ops && nf_ops->br_dev_xmit_hook(skb)) {
-		rcu_read_unlock();
-		return NETDEV_TX_OK;
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
+	if (skb->nf_bridge_state == BRNF_STATE_BRIDGED_DNAT) {
+		const struct nf_br_ops *nf_ops;
+
+		nf_ops = rcu_dereference(nf_br_ops);
+		if (nf_ops) {
+			nf_ops->br_dev_dnat_hook(skb);
+		} else {
+			/* br_netfilter module removed while skb in qdisc */
+			kfree_skb(skb);
+		}
+		goto out;
 	}
-
+#endif
 	u64_stats_update_begin(&brstats->syncp);
 	brstats->tx_packets++;
 	brstats->tx_bytes += skb->len;
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 40009b1..832164e 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -148,8 +148,11 @@ static inline struct net_device *bridge_parent(const struct net_device *dev)
 static inline struct nf_bridge_info *nf_bridge_alloc(struct sk_buff *skb)
 {
 	skb->nf_bridge = kzalloc(sizeof(struct nf_bridge_info), GFP_ATOMIC);
-	if (likely(skb->nf_bridge))
+
+	if (likely(skb->nf_bridge)) {
 		atomic_set(&(skb->nf_bridge->use), 1);
+		skb->nf_bridge_state = BRNF_STATE_SEEN;
+	}
 
 	return skb->nf_bridge;
 }
@@ -286,7 +289,7 @@ static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
 		skb->pkt_type = PACKET_OTHERHOST;
 		nf_bridge->pkt_otherhost = false;
 	}
-	nf_bridge->mask ^= BRNF_NF_BRIDGE_PREROUTING;
+	skb->nf_bridge_state = BRNF_STATE_SEEN;
 
 	rt = bridge_parent_rtable(nf_bridge->physindev);
 	if (!rt) {
@@ -337,8 +340,7 @@ static int br_nf_pre_routing_finish_bridge(struct sk_buff *skb)
 							 nf_bridge->neigh_header,
 							 ETH_HLEN-ETH_ALEN);
 			/* tell br_dev_xmit to continue with forwarding */
-			nf_bridge->mask |= BRNF_BRIDGED_DNAT;
-			/* FIXME Need to refragment */
+			skb->nf_bridge_state = BRNF_STATE_BRIDGED_DNAT;
 			ret = neigh->output(neigh, skb);
 		}
 		neigh_release(neigh);
@@ -419,7 +421,7 @@ static int br_nf_pre_routing_finish(struct sk_buff *skb)
 		skb->pkt_type = PACKET_OTHERHOST;
 		nf_bridge->pkt_otherhost = false;
 	}
-	nf_bridge->mask ^= BRNF_NF_BRIDGE_PREROUTING;
+	skb->nf_bridge_state = BRNF_STATE_SEEN;
 	if (dnat_took_place(skb)) {
 		if ((err = ip_route_input(skb, iph->daddr, iph->saddr, iph->tos, dev))) {
 			struct in_device *in_dev = __in_dev_get_rcu(dev);
@@ -506,7 +508,7 @@ static struct net_device *setup_pre_routing(struct sk_buff *skb)
 		nf_bridge->pkt_otherhost = true;
 	}
 
-	nf_bridge->mask |= BRNF_NF_BRIDGE_PREROUTING;
+	skb->nf_bridge_state = BRNF_STATE_PREROUTING;
 	nf_bridge->physindev = skb->dev;
 	skb->dev = brnf_get_logical_dev(skb, skb->dev);
 
@@ -742,7 +744,7 @@ static unsigned int br_nf_forward_ip(const struct nf_hook_ops *ops,
 	struct net_device *parent;
 	u_int8_t pf;
 
-	if (!skb->nf_bridge)
+	if (!skb->nf_bridge_state)
 		return NF_ACCEPT;
 
 	/* Need exclusive nf_bridge_info since we might have multiple
@@ -862,6 +864,8 @@ static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 	int frag_max_size;
 	unsigned int mtu_reserved, mtu;
 
+	skb->nf_bridge_state = BRNF_STATE_NONE;
+
 	if (skb_is_gso(skb) || skb->protocol != htons(ETH_P_IP))
 		return br_dev_queue_push_xmit(skb);
 
@@ -914,6 +918,8 @@ static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 #else
 static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 {
+	skb->nf_bridge_state = BRNF_STATE_NONE;
+
         return br_dev_queue_push_xmit(skb);
 }
 #endif
@@ -975,10 +981,8 @@ static unsigned int ip_sabotage_in(const struct nf_hook_ops *ops,
 				   const struct net_device *out,
 				   int (*okfn)(struct sk_buff *))
 {
-	if (skb->nf_bridge &&
-	    !(skb->nf_bridge->mask & BRNF_NF_BRIDGE_PREROUTING)) {
+	if (skb->nf_bridge_state != BRNF_STATE_PREROUTING)
 		return NF_STOP;
-	}
 
 	return NF_ACCEPT;
 }
@@ -997,7 +1001,7 @@ static void br_nf_pre_routing_finish_bridge_slow(struct sk_buff *skb)
 	struct nf_bridge_info *nf_bridge = nf_bridge_info_get(skb);
 
 	skb_pull(skb, ETH_HLEN);
-	nf_bridge->mask &= ~BRNF_BRIDGED_DNAT;
+	skb->nf_bridge_state = BRNF_STATE_SEEN;
 
 	BUILD_BUG_ON(sizeof(nf_bridge->neigh_header) != (ETH_HLEN - ETH_ALEN));
 
@@ -1008,17 +1012,8 @@ static void br_nf_pre_routing_finish_bridge_slow(struct sk_buff *skb)
 	br_handle_frame_finish(skb);
 }
 
-static int br_nf_dev_xmit(struct sk_buff *skb)
-{
-	if (skb->nf_bridge && (skb->nf_bridge->mask & BRNF_BRIDGED_DNAT)) {
-		br_nf_pre_routing_finish_bridge_slow(skb);
-		return 1;
-	}
-	return 0;
-}
-
 static const struct nf_br_ops br_ops = {
-	.br_dev_xmit_hook =	br_nf_dev_xmit,
+	.br_dev_dnat_hook = br_nf_pre_routing_finish_bridge_slow,
 };
 
 void br_netfilter_enable(void)
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index b46fa0c..7f22f09 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -764,7 +764,7 @@ static inline int br_vlan_enabled(struct net_bridge *br)
 #endif
 
 struct nf_br_ops {
-	int (*br_dev_xmit_hook)(struct sk_buff *skb);
+	void (*br_dev_dnat_hook)(struct sk_buff *skb);
 };
 extern const struct nf_br_ops __rcu *nf_br_ops;
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index cdb939b..16ccbec 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -677,7 +677,8 @@ static void skb_release_head_state(struct sk_buff *skb)
 	nf_conntrack_put(skb->nfct);
 #endif
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
-	nf_bridge_put(skb->nf_bridge);
+	if (skb->nf_bridge_state)
+		nf_bridge_put(skb->nf_bridge);
 #endif
 }
 
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index 7e5ca6f..5b2096e 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -51,8 +51,7 @@ static enum ip_defrag_users nf_ct_defrag_user(unsigned int hooknum,
 #endif
 
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
-	if (skb->nf_bridge &&
-	    skb->nf_bridge->mask & BRNF_NF_BRIDGE_PREROUTING)
+	if (skb->nf_bridge_state == BRNF_STATE_PREROUTING)
 		return IP_DEFRAG_CONNTRACK_BRIDGE_IN + zone;
 #endif
 	if (hooknum == NF_INET_PRE_ROUTING)
diff --git a/net/ipv4/netfilter/nf_reject_ipv4.c b/net/ipv4/netfilter/nf_reject_ipv4.c
index 3262e41..3be3f1a 100644
--- a/net/ipv4/netfilter/nf_reject_ipv4.c
+++ b/net/ipv4/netfilter/nf_reject_ipv4.c
@@ -145,7 +145,7 @@ void nf_send_reset(struct sk_buff *oldskb, int hook)
 	 * build the eth header using the original destination's MAC as the
 	 * source, and send the RST packet directly.
 	 */
-	if (oldskb->nf_bridge) {
+	if (oldskb->nf_bridge_state) {
 		struct ethhdr *oeth = eth_hdr(oldskb);
 
 		nskb->dev = nf_bridge_get_physindev(oldskb);
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index e70382e..01706d3 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -41,8 +41,7 @@ static enum ip6_defrag_users nf_ct6_defrag_user(unsigned int hooknum,
 #endif
 
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
-	if (skb->nf_bridge &&
-	    skb->nf_bridge->mask & BRNF_NF_BRIDGE_PREROUTING)
+	if (skb->nf_bridge_state == BRNF_STATE_PREROUTING)
 		return IP6_DEFRAG_CONNTRACK_BRIDGE_IN + zone;
 #endif
 	if (hooknum == NF_INET_PRE_ROUTING)
diff --git a/net/ipv6/netfilter/nf_reject_ipv6.c b/net/ipv6/netfilter/nf_reject_ipv6.c
index 94b4c6d..c313bb7 100644
--- a/net/ipv6/netfilter/nf_reject_ipv6.c
+++ b/net/ipv6/netfilter/nf_reject_ipv6.c
@@ -194,7 +194,7 @@ void nf_send_reset6(struct net *net, struct sk_buff *oldskb, int hook)
 	 * build the eth header using the original destination's MAC as the
 	 * source, and send the RST packet directly.
 	 */
-	if (oldskb->nf_bridge) {
+	if (oldskb->nf_bridge_state) {
 		struct ethhdr *oeth = eth_hdr(oldskb);
 
 		nskb->dev = nf_bridge_get_physindev(oldskb);
diff --git a/net/netfilter/nf_log_common.c b/net/netfilter/nf_log_common.c
index a5aa596..f433262 100644
--- a/net/netfilter/nf_log_common.c
+++ b/net/netfilter/nf_log_common.c
@@ -160,7 +160,7 @@ nf_log_dump_packet_common(struct nf_log_buf *m, u_int8_t pf,
 	       in ? in->name : "",
 	       out ? out->name : "");
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
-	if (skb->nf_bridge) {
+	if (skb->nf_bridge_state) {
 		const struct net_device *physindev;
 		const struct net_device *physoutdev;
 
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index fb045b4..2dba75c 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -54,7 +54,7 @@ void nf_queue_entry_release_refs(struct nf_queue_entry *entry)
 	if (entry->outdev)
 		dev_put(entry->outdev);
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
-	if (entry->skb->nf_bridge) {
+	if (entry->skb->nf_bridge_state) {
 		struct net_device *physdev;
 
 		physdev = nf_bridge_get_physindev(entry->skb);
@@ -81,7 +81,7 @@ bool nf_queue_entry_get_refs(struct nf_queue_entry *entry)
 	if (entry->outdev)
 		dev_hold(entry->outdev);
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
-	if (entry->skb->nf_bridge) {
+	if (entry->skb->nf_bridge_state) {
 		struct net_device *physdev;
 
 		physdev = nf_bridge_get_physindev(entry->skb);
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 94e1aaf..e26abe5 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -585,13 +585,13 @@ nf_queue_entry_dup(struct nf_queue_entry *e)
  */
 static void nf_bridge_adjust_skb_data(struct sk_buff *skb)
 {
-	if (skb->nf_bridge)
+	if (skb->nf_bridge_state)
 		__skb_push(skb, skb->network_header - skb->mac_header);
 }
 
 static void nf_bridge_adjust_segmented_data(struct sk_buff *skb)
 {
-	if (skb->nf_bridge)
+	if (skb->nf_bridge_state)
 		__skb_pull(skb, skb->network_header - skb->mac_header);
 }
 #else
@@ -773,7 +773,7 @@ dev_cmp(struct nf_queue_entry *entry, unsigned long ifindex)
 		if (entry->outdev->ifindex == ifindex)
 			return 1;
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
-	if (entry->skb->nf_bridge) {
+	if (entry->skb->nf_bridge_state) {
 		int physinif, physoutif;
 
 		physinif = nf_bridge_get_physinif(entry->skb);
diff --git a/net/netfilter/xt_physdev.c b/net/netfilter/xt_physdev.c
index 1caaccb..535e4be 100644
--- a/net/netfilter/xt_physdev.c
+++ b/net/netfilter/xt_physdev.c
@@ -33,7 +33,7 @@ physdev_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	/* Not a bridged IP packet or no info available yet:
 	 * LOCAL_OUT/mangle and LOCAL_OUT/nat don't know if
 	 * the destination device will be a bridge. */
-	if (!skb->nf_bridge) {
+	if (skb->nf_bridge_state == 0) {
 		/* Return MATCH if the invert flags of the used options are on */
 		if ((info->bitmask & XT_PHYSDEV_OP_BRIDGED) &&
 		    !(info->invert & XT_PHYSDEV_OP_BRIDGED))
-- 
2.0.5
