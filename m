From: Florian Westphal <fw@strlen.de>
Subject: [PATCH v2 nf-next 5/6] netfilter: bridge: replace remaining flags with state enum
Date: Thu, 12 Mar 2015 18:05:24 +0100
Message-ID: <1426179925-18220-6-git-send-email-fw@strlen.de>
References: <1426179925-18220-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1426179925-18220-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The two remaining flags are mutually exclusive, use a state enum for
telling in which stage of bridge netfilter processing we are.

BRNF_STATE_PREROUTING: used so that netfilter PRE_ROUTING is not
traversed twice and to put such skbs into different defragmentation
queues.

Could also be indicated via skb->cb, but this would make it necessary to
expose such flag in ipv4 IPCB so that physdev match can use this reliably,
and we want less IP stack entanglements).

BRNF_STATE_BRIDGED_DNAT means that we don't know the new destination
mac address after a IP DNAT took place and that we'll have to push the
skb through negh resolution.

Cannot be stored in skb->cb either since such skb leaves bridge ownership and
can e.g. be enqueued in qdisc.

The SEEN state is only so we know when skb is neither in nefarious
DNAT reinject path nor travelling through the PRE_ROUTING netfilter hooks.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/netfilter_bridge.h          |  4 ----
 include/linux/skbuff.h                    | 15 ++++++++++++++-
 net/bridge/br_netfilter.c                 | 19 +++++++++----------
 net/ipv4/netfilter/nf_defrag_ipv4.c       |  2 +-
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c |  2 +-
 5 files changed, 25 insertions(+), 17 deletions(-)

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index 66245b5..2070623 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -16,10 +16,6 @@ enum nf_br_hook_priorities {
 };
 
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
-
-#define BRNF_BRIDGED_DNAT		0x02
-#define BRNF_NF_BRIDGE_PREROUTING	0x08
-
 int br_handle_frame_finish(struct sk_buff *skb);
 
 static inline void br_drop_fake_rtable(struct sk_buff *skb)
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index bba1330..364c4a8 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -163,10 +163,23 @@ struct nf_conntrack {
 };
 #endif
 
+enum brnf_state {
+	BRNF_STATE_SEEN,
+
+	/* IPV4/IPV6 PRE_ROUTING called from bridge netfilter */
+	BRNF_STATE_PREROUTING,
+
+	/* skb that is 'transmitted' via bridge must to be injected
+	 * back into br forwarding for delivery to the correct bridge output
+	 * port due to DNAT to a destination on the same (bridged) network.
+	 */
+	BRNF_STATE_BRIDGED_DNAT,
+};
+
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 struct nf_bridge_info {
 	atomic_t		use;
-	unsigned int		mask;
+	enum brnf_state	brnf_state;
 	struct net_device	*physindev;
 	struct net_device	*physoutdev;
 	unsigned long		data[32 / sizeof(unsigned long)];
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 215ec3f..342081e 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -315,8 +315,7 @@ static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
 	struct rtable *rt;
 
 	nf_bridge_restore_otherhost(skb);
-
-	nf_bridge->mask ^= BRNF_NF_BRIDGE_PREROUTING;
+	nf_bridge->brnf_state = BRNF_STATE_SEEN;
 
 	rt = bridge_parent_rtable(nf_bridge->physindev);
 	if (!rt) {
@@ -367,8 +366,7 @@ static int br_nf_pre_routing_finish_bridge(struct sk_buff *skb)
 							 skb->nf_bridge->data,
 							 ETH_HLEN-ETH_ALEN);
 			/* tell br_dev_xmit to continue with forwarding */
-			nf_bridge->mask |= BRNF_BRIDGED_DNAT;
-			/* FIXME Need to refragment */
+			nf_bridge->brnf_state = BRNF_STATE_BRIDGED_DNAT;
 			ret = neigh->output(neigh, skb);
 		}
 		neigh_release(neigh);
@@ -446,7 +444,8 @@ static int br_nf_pre_routing_finish(struct sk_buff *skb)
 	BR_INPUT_SKB_CB(skb)->frag_max_size = frag_max_size;
 
 	nf_bridge_restore_otherhost(skb);
-	nf_bridge->mask ^= BRNF_NF_BRIDGE_PREROUTING;
+	nf_bridge->brnf_state = BRNF_STATE_SEEN;
+
 	if (dnat_took_place(skb)) {
 		if ((err = ip_route_input(skb, iph->daddr, iph->saddr, iph->tos, dev))) {
 			struct in_device *in_dev = __in_dev_get_rcu(dev);
@@ -532,7 +531,7 @@ static struct net_device *setup_pre_routing(struct sk_buff *skb)
 	cb->packet_otherhost = 0;
 	nf_bridge_save_otherhost(skb);
 
-	nf_bridge->mask |= BRNF_NF_BRIDGE_PREROUTING;
+	nf_bridge->brnf_state = BRNF_STATE_PREROUTING;
 	nf_bridge->physindev = skb->dev;
 	skb->dev = brnf_get_logical_dev(skb, skb->dev);
 
@@ -977,9 +976,8 @@ static unsigned int ip_sabotage_in(const struct nf_hook_ops *ops,
 				   int (*okfn)(struct sk_buff *))
 {
 	if (skb->nf_bridge &&
-	    !(skb->nf_bridge->mask & BRNF_NF_BRIDGE_PREROUTING)) {
+	    skb->nf_bridge->brnf_state != BRNF_STATE_PREROUTING)
 		return NF_STOP;
-	}
 
 	return NF_ACCEPT;
 }
@@ -998,7 +996,7 @@ static void br_nf_pre_routing_finish_bridge_slow(struct sk_buff *skb)
 	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
 
 	skb_pull(skb, ETH_HLEN);
-	nf_bridge->mask &= ~BRNF_BRIDGED_DNAT;
+	nf_bridge->brnf_state = BRNF_STATE_SEEN;
 
 	skb_copy_to_linear_data_offset(skb, -(ETH_HLEN-ETH_ALEN),
 				       skb->nf_bridge->data, ETH_HLEN-ETH_ALEN);
@@ -1008,7 +1006,8 @@ static void br_nf_pre_routing_finish_bridge_slow(struct sk_buff *skb)
 
 static int br_nf_dev_xmit(struct sk_buff *skb)
 {
-	if (skb->nf_bridge && (skb->nf_bridge->mask & BRNF_BRIDGED_DNAT)) {
+	if (skb->nf_bridge &&
+	    skb->nf_bridge->brnf_state == BRNF_STATE_BRIDGED_DNAT) {
 		br_nf_pre_routing_finish_bridge_slow(skb);
 		return 1;
 	}
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index 7e5ca6f..8280816 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -52,7 +52,7 @@ static enum ip_defrag_users nf_ct_defrag_user(unsigned int hooknum,
 
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	if (skb->nf_bridge &&
-	    skb->nf_bridge->mask & BRNF_NF_BRIDGE_PREROUTING)
+	    skb->nf_bridge->brnf_state == BRNF_STATE_PREROUTING)
 		return IP_DEFRAG_CONNTRACK_BRIDGE_IN + zone;
 #endif
 	if (hooknum == NF_INET_PRE_ROUTING)
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index e70382e..3d89c92 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -42,7 +42,7 @@ static enum ip6_defrag_users nf_ct6_defrag_user(unsigned int hooknum,
 
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	if (skb->nf_bridge &&
-	    skb->nf_bridge->mask & BRNF_NF_BRIDGE_PREROUTING)
+	    skb->nf_bridge->brnf_state == BRNF_STATE_PREROUTING)
 		return IP6_DEFRAG_CONNTRACK_BRIDGE_IN + zone;
 #endif
 	if (hooknum == NF_INET_PRE_ROUTING)
-- 
2.0.5

