From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/12] netfilter: bridge: move DNAT helper to br_netfilter
Date: Mon,  9 Mar 2015 18:14:35 +0100
Message-ID: <1425921275-9171-13-git-send-email-pablo@netfilter.org>
References: <1425921275-9171-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1425921275-9171-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Only one caller, there is no need to keep this in a header.
Move it to br_netfilter.c where this belongs to.

Based on patch from Florian Westphal.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter_bridge.h |   12 ------------
 net/bridge/br_device.c           |    5 +----
 net/bridge/br_netfilter.c        |   32 ++++++++++++++++++++++++++++++++
 net/bridge/br_private.h          |    5 +++++
 4 files changed, 38 insertions(+), 16 deletions(-)

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index dd580a9..bb39113 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -44,18 +44,6 @@ static inline unsigned int nf_bridge_mtu_reduction(const struct sk_buff *skb)
 }
 
 int br_handle_frame_finish(struct sk_buff *skb);
-/* Only used in br_device.c */
-static inline int br_nf_pre_routing_finish_bridge_slow(struct sk_buff *skb)
-{
-	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
-
-	skb_pull(skb, ETH_HLEN);
-	nf_bridge->mask ^= BRNF_BRIDGED_DNAT;
-	skb_copy_to_linear_data_offset(skb, -(ETH_HLEN-ETH_ALEN),
-				       skb->nf_bridge->data, ETH_HLEN-ETH_ALEN);
-	skb->dev = nf_bridge->physindev;
-	return br_handle_frame_finish(skb);
-}
 
 /* This is called by the IP fragmenting code and it ensures there is
  * enough room for the encapsulating header (if there is one). */
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index ffd379d..294cbcc 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -36,13 +36,10 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	u16 vid = 0;
 
 	rcu_read_lock();
-#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
-	if (skb->nf_bridge && (skb->nf_bridge->mask & BRNF_BRIDGED_DNAT)) {
-		br_nf_pre_routing_finish_bridge_slow(skb);
+	if (br_nf_prerouting_finish_bridge(skb)) {
 		rcu_read_unlock();
 		return NETDEV_TX_OK;
 	}
-#endif
 
 	u64_stats_update_begin(&brstats->syncp);
 	brstats->tx_packets++;
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index ef1fe28..a8361c7 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -892,6 +892,38 @@ static unsigned int ip_sabotage_in(const struct nf_hook_ops *ops,
 	return NF_ACCEPT;
 }
 
+/* This is called when br_netfilter has called into iptables/netfilter,
+ * and DNAT has taken place on a bridge-forwarded packet.
+ *
+ * neigh->output has created a new MAC header, with local br0 MAC
+ * as saddr.
+ *
+ * This restores the original MAC saddr of the bridged packet
+ * before invoking bridge forward logic to transmit the packet.
+ */
+static void br_nf_pre_routing_finish_bridge_slow(struct sk_buff *skb)
+{
+	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
+
+	skb_pull(skb, ETH_HLEN);
+	nf_bridge->mask &= ~BRNF_BRIDGED_DNAT;
+
+	skb_copy_to_linear_data_offset(skb, -(ETH_HLEN-ETH_ALEN),
+				       skb->nf_bridge->data, ETH_HLEN-ETH_ALEN);
+	skb->dev = nf_bridge->physindev;
+	br_handle_frame_finish(skb);
+}
+
+int br_nf_prerouting_finish_bridge(struct sk_buff *skb)
+{
+	if (skb->nf_bridge && (skb->nf_bridge->mask & BRNF_BRIDGED_DNAT)) {
+		br_nf_pre_routing_finish_bridge_slow(skb);
+		return 1;
+	}
+	return 0;
+}
+EXPORT_SYMBOL_GPL(br_nf_prerouting_finish_bridge);
+
 void br_netfilter_enable(void)
 {
 }
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index de09199..d63fc17 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -764,10 +764,15 @@ static inline int br_vlan_enabled(struct net_bridge *br)
 
 /* br_netfilter.c */
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
+int br_nf_prerouting_finish_bridge(struct sk_buff *skb);
 int br_nf_core_init(void);
 void br_nf_core_fini(void);
 void br_netfilter_rtable_init(struct net_bridge *);
 #else
+static inline int br_nf_prerouting_finish_bridge(struct sk_buff *skb)
+{
+        return 0;
+}
 static inline int br_nf_core_init(void) { return 0; }
 static inline void br_nf_core_fini(void) {}
 #define br_netfilter_rtable_init(x)
-- 
1.7.10.4

