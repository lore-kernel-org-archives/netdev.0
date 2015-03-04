From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 3/8] netfilter: brige: move DNAT helper to where its used
Date: Thu,  5 Mar 2015 00:52:35 +0100
Message-ID: <1425513160-496-4-git-send-email-fw@strlen.de>
References: <1425513160-496-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1425513160-496-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Only one caller, there is no need to keep this in a header.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/netfilter_bridge.h | 12 ------------
 net/bridge/br_device.c           | 24 ++++++++++++++++++++++++
 2 files changed, 24 insertions(+), 12 deletions(-)

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
index ffd379d..7e39b8d 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -25,6 +25,30 @@
 #define COMMON_FEATURES (NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA | \
 			 NETIF_F_GSO_MASK | NETIF_F_HW_CSUM)
 
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
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
+#endif
+
 /* net device transmit always called with BH disabled */
 netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-- 
2.0.5

