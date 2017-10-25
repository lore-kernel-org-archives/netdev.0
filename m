From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next 3/4] net: qualcomm: rmnet: Add support for 64 bit stats
Date: Tue, 24 Oct 2017 22:55:28 -0600
Message-ID: <1508907329-1077-4-git-send-email-subashab@codeaurora.org>
References: <1508907329-1077-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:43362 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751425AbdJYEzw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 00:55:52 -0400
In-Reply-To: <1508907329-1077-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement 64 bit per cpu stats.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h | 14 ++++
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c    | 76 ++++++++++++++++++++--
 2 files changed, 85 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
index 60115e6..9586703d 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
@@ -41,9 +41,23 @@ struct rmnet_port {
 
 extern struct rtnl_link_ops rmnet_link_ops;
 
+struct rmnet_vnd_stats {
+	u64 rx_pkts;
+	u64 rx_bytes;
+	u64 tx_pkts;
+	u64 tx_bytes;
+	u32 tx_drops;
+};
+
+struct rmnet_pcpu_stats {
+	struct rmnet_vnd_stats stats;
+	struct u64_stats_sync syncp;
+};
+
 struct rmnet_priv {
 	u8 mux_id;
 	struct net_device *real_dev;
+	struct rmnet_pcpu_stats __percpu *pcpu_stats;
 };
 
 struct rmnet_port *rmnet_get_port(struct net_device *real_dev);
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
index 12bd0bb..b0befa1 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
@@ -27,14 +27,28 @@
 
 void rmnet_vnd_rx_fixup(struct sk_buff *skb, struct net_device *dev)
 {
-	dev->stats.rx_packets++;
-	dev->stats.rx_bytes += skb->len;
+	struct rmnet_priv *priv = netdev_priv(dev);
+	struct rmnet_pcpu_stats *pcpu_ptr;
+
+	pcpu_ptr = this_cpu_ptr(priv->pcpu_stats);
+
+	u64_stats_update_begin(&pcpu_ptr->syncp);
+	pcpu_ptr->stats.rx_pkts++;
+	pcpu_ptr->stats.rx_bytes += skb->len;
+	u64_stats_update_end(&pcpu_ptr->syncp);
 }
 
 void rmnet_vnd_tx_fixup(struct sk_buff *skb, struct net_device *dev)
 {
-	dev->stats.tx_packets++;
-	dev->stats.tx_bytes += skb->len;
+	struct rmnet_priv *priv = netdev_priv(dev);
+	struct rmnet_pcpu_stats *pcpu_ptr;
+
+	pcpu_ptr = this_cpu_ptr(priv->pcpu_stats);
+
+	u64_stats_update_begin(&pcpu_ptr->syncp);
+	pcpu_ptr->stats.tx_pkts++;
+	pcpu_ptr->stats.tx_bytes += skb->len;
+	u64_stats_update_end(&pcpu_ptr->syncp);
 }
 
 /* Network Device Operations */
@@ -48,7 +62,7 @@ static netdev_tx_t rmnet_vnd_start_xmit(struct sk_buff *skb,
 	if (priv->real_dev) {
 		rmnet_egress_handler(skb);
 	} else {
-		dev->stats.tx_dropped++;
+		this_cpu_inc(priv->pcpu_stats->stats.tx_drops);
 		kfree_skb(skb);
 	}
 	return NETDEV_TX_OK;
@@ -70,12 +84,64 @@ static int rmnet_vnd_get_iflink(const struct net_device *dev)
 	return priv->real_dev->ifindex;
 }
 
+static int rmnet_vnd_init(struct net_device *dev)
+{
+	struct rmnet_priv *priv = netdev_priv(dev);
+
+	priv->pcpu_stats = alloc_percpu(struct rmnet_pcpu_stats);
+	if (!priv->pcpu_stats)
+		return -ENOMEM;
+
+	return 0;
+}
+
+static void rmnet_vnd_uninit(struct net_device *dev)
+{
+	struct rmnet_priv *priv = netdev_priv(dev);
+
+	free_percpu(priv->pcpu_stats);
+}
+
+static void rmnet_get_stats64(struct net_device *dev,
+			      struct rtnl_link_stats64 *s)
+{
+	struct rmnet_priv *priv = netdev_priv(dev);
+	struct rmnet_vnd_stats total_stats;
+	struct rmnet_pcpu_stats *pcpu_ptr;
+	unsigned int cpu, start;
+
+	memset(&total_stats, 0, sizeof(struct rmnet_vnd_stats));
+
+	for_each_possible_cpu(cpu) {
+		pcpu_ptr = this_cpu_ptr(priv->pcpu_stats);
+
+		do {
+			start = u64_stats_fetch_begin_irq(&pcpu_ptr->syncp);
+			total_stats.rx_pkts += pcpu_ptr->stats.rx_pkts;
+			total_stats.rx_bytes += pcpu_ptr->stats.rx_bytes;
+			total_stats.tx_pkts += pcpu_ptr->stats.tx_pkts;
+			total_stats.tx_bytes += pcpu_ptr->stats.tx_bytes;
+		} while (u64_stats_fetch_retry_irq(&pcpu_ptr->syncp, start));
+
+		total_stats.tx_drops += pcpu_ptr->stats.tx_drops;
+	}
+
+	s->rx_packets = total_stats.rx_pkts;
+	s->rx_bytes = total_stats.rx_bytes;
+	s->tx_packets = total_stats.tx_pkts;
+	s->tx_bytes = total_stats.tx_bytes;
+	s->tx_dropped = total_stats.tx_drops;
+}
+
 static const struct net_device_ops rmnet_vnd_ops = {
 	.ndo_start_xmit = rmnet_vnd_start_xmit,
 	.ndo_change_mtu = rmnet_vnd_change_mtu,
 	.ndo_get_iflink = rmnet_vnd_get_iflink,
 	.ndo_add_slave  = rmnet_add_bridge,
 	.ndo_del_slave  = rmnet_del_bridge,
+	.ndo_init       = rmnet_vnd_init,
+	.ndo_uninit     = rmnet_vnd_uninit,
+	.ndo_get_stats64 = rmnet_get_stats64,
 };
 
 /* Called by kernel whenever a new rmnet<n> device is created. Sets MTU,
-- 
1.9.1
