From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Subject: [PATCH net-next,3/4] hv_netvsc: Add ethtool handler to set and get UDP hash levels
Date: Mon, 21 Aug 2017 19:22:39 -0700
Message-ID: <1503368560-14331-4-git-send-email-haiyangz@exchange.microsoft.com>
References: <1503368560-14331-1-git-send-email-haiyangz@exchange.microsoft.com>
Reply-To: haiyangz@microsoft.com
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
        vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503368560-14331-1-git-send-email-haiyangz@exchange.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>

The patch add the functions to switch UDP hash level between
L3 and L4 by ethtool command. UDP over IPv4 and v6 can be set
differently. The default hash level is L4. We currently only
allow switching TX hash level from within the guests.

On Azure, fragmented UDP packets have high loss rate with L4
hashing. Using L3 hashing is recommended in this case.

For example, for UDP over IPv4 on eth0:
To include UDP port numbers in hasing:
	ethtool -N eth0 rx-flow-hash udp4 sdfn
To exclude UDP port numbers in hasing:
	ethtool -N eth0 rx-flow-hash udp4 sd
To show UDP hash level:
	ethtool -n eth0 rx-flow-hash udp4

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h |    2 +
 drivers/net/hyperv/netvsc_drv.c |   78 +++++++++++++++++++++++++++++++++++----
 2 files changed, 72 insertions(+), 8 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 9198dd1..ff1c0c8 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -720,6 +720,8 @@ struct net_device_context {
 	u32 tx_send_table[VRSS_SEND_TAB_SIZE];
 
 	/* Ethtool settings */
+	bool udp4_l4_hash;
+	bool udp6_l4_hash;
 	u8 duplex;
 	u32 speed;
 	struct netvsc_ethtool_stats eth_stats;
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index d8612b1..c0c4c91 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -190,10 +190,12 @@ static int netvsc_close(struct net_device *net)
 	return ppi;
 }
 
-/* Azure hosts don't support non-TCP port numbers in hashing yet. We compute
- * hash for non-TCP traffic with only IP numbers.
+/* Azure hosts don't support non-TCP port numbers in hashing for fragmented
+ * packets. We can use ethtool to change UDP hash level when necessary.
  */
-static inline u32 netvsc_get_hash(struct sk_buff *skb)
+static inline u32 netvsc_get_hash(
+	struct sk_buff *skb,
+	const struct net_device_context *ndc)
 {
 	struct flow_keys flow;
 	u32 hash;
@@ -204,7 +206,11 @@ static inline u32 netvsc_get_hash(struct sk_buff *skb)
 	if (!skb_flow_dissect_flow_keys(skb, &flow, 0))
 		return 0;
 
-	if (flow.basic.ip_proto == IPPROTO_TCP) {
+	if (flow.basic.ip_proto == IPPROTO_TCP ||
+	    (flow.basic.ip_proto == IPPROTO_UDP &&
+	     ((flow.basic.n_proto == htons(ETH_P_IP) && ndc->udp4_l4_hash) ||
+	      (flow.basic.n_proto == htons(ETH_P_IPV6) &&
+	       ndc->udp6_l4_hash)))) {
 		return skb_get_hash(skb);
 	} else {
 		if (flow.basic.n_proto == htons(ETH_P_IP))
@@ -227,7 +233,7 @@ static inline int netvsc_get_tx_queue(struct net_device *ndev,
 	struct sock *sk = skb->sk;
 	int q_idx;
 
-	q_idx = ndc->tx_send_table[netvsc_get_hash(skb) &
+	q_idx = ndc->tx_send_table[netvsc_get_hash(skb, ndc) &
 				   (VRSS_SEND_TAB_SIZE - 1)];
 
 	/* If queue index changed record the new value */
@@ -891,6 +897,9 @@ static void netvsc_init_settings(struct net_device *dev)
 {
 	struct net_device_context *ndc = netdev_priv(dev);
 
+	ndc->udp4_l4_hash = true;
+	ndc->udp6_l4_hash = true;
+
 	ndc->speed = SPEED_UNKNOWN;
 	ndc->duplex = DUPLEX_FULL;
 }
@@ -1228,7 +1237,8 @@ static void netvsc_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 }
 
 static int
-netvsc_get_rss_hash_opts(struct ethtool_rxnfc *info)
+netvsc_get_rss_hash_opts(struct net_device_context *ndc,
+			 struct ethtool_rxnfc *info)
 {
 	info->data = RXH_IP_SRC | RXH_IP_DST;
 
@@ -1236,9 +1246,20 @@ static void netvsc_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 	case TCP_V4_FLOW:
 	case TCP_V6_FLOW:
 		info->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
-		/* fallthrough */
+		break;
+
 	case UDP_V4_FLOW:
+		if (ndc->udp4_l4_hash)
+			info->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+
+		break;
+
 	case UDP_V6_FLOW:
+		if (ndc->udp6_l4_hash)
+			info->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+
+		break;
+
 	case IPV4_FLOW:
 	case IPV6_FLOW:
 		break;
@@ -1266,11 +1287,51 @@ static void netvsc_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 		return 0;
 
 	case ETHTOOL_GRXFH:
-		return netvsc_get_rss_hash_opts(info);
+		return netvsc_get_rss_hash_opts(ndc, info);
 	}
 	return -EOPNOTSUPP;
 }
 
+static int netvsc_set_rss_hash_opts(struct net_device_context *ndc,
+				    struct ethtool_rxnfc *info)
+{
+	if (info->data == (RXH_IP_SRC | RXH_IP_DST |
+			   RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
+		if (info->flow_type == UDP_V4_FLOW)
+			ndc->udp4_l4_hash = true;
+		else if (info->flow_type == UDP_V6_FLOW)
+			ndc->udp6_l4_hash = true;
+		else
+			return -EOPNOTSUPP;
+
+		return 0;
+	}
+
+	if (info->data == (RXH_IP_SRC | RXH_IP_DST)) {
+		if (info->flow_type == UDP_V4_FLOW)
+			ndc->udp4_l4_hash = false;
+		else if (info->flow_type == UDP_V6_FLOW)
+			ndc->udp6_l4_hash = false;
+		else
+			return -EOPNOTSUPP;
+
+		return 0;
+	}
+
+	return -EOPNOTSUPP;
+}
+
+static int
+netvsc_set_rxnfc(struct net_device *ndev, struct ethtool_rxnfc *info)
+{
+	struct net_device_context *ndc = netdev_priv(ndev);
+
+	if (info->cmd == ETHTOOL_SRXFH)
+		return netvsc_set_rss_hash_opts(ndc, info);
+
+	return -EOPNOTSUPP;
+}
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void netvsc_poll_controller(struct net_device *dev)
 {
@@ -1469,6 +1530,7 @@ static int netvsc_set_ringparam(struct net_device *ndev,
 	.set_channels   = netvsc_set_channels,
 	.get_ts_info	= ethtool_op_get_ts_info,
 	.get_rxnfc	= netvsc_get_rxnfc,
+	.set_rxnfc	= netvsc_set_rxnfc,
 	.get_rxfh_key_size = netvsc_get_rxfh_key_size,
 	.get_rxfh_indir_size = netvsc_rss_indir_size,
 	.get_rxfh	= netvsc_get_rxfh,
-- 
1.7.1
