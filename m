From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH] davinci_emac: Use the instance of net_device_stats from net_device.
Date: Mon,  5 Jul 2010 16:13:26 +0400
Message-ID: <1278332007-16175-1-git-send-email-segooon@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Chaithrika U S <chaithrika@ti.com>,
	Sriramakrishnan <srk@ti.com>,
	Kevin Hilman <khilman@deeprootsystems.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Kernel Janitors <kernel-janitors@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since net_device has an instance of net_device_stats,
we can remove the instance of this from the adapter structure.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/davinci_emac.c |   38 +++++++++++++++++++-------------------
 1 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 08e82b1..25e14d2 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -470,7 +470,6 @@ struct emac_priv {
 	u32 isr_count;
 	u8 rmii_en;
 	u8 version;
-	struct net_device_stats net_dev_stats;
 	u32 mac_hash1;
 	u32 mac_hash2;
 	u32 multicast_hash_cnt[EMAC_NUM_MULTICAST_BITS];
@@ -1180,16 +1179,17 @@ static int emac_net_tx_complete(struct emac_priv *priv,
 				void **net_data_tokens,
 				int num_tokens, u32 ch)
 {
+	struct net_device *ndev = priv->ndev;
 	u32 cnt;
 
-	if (unlikely(num_tokens && netif_queue_stopped(priv->ndev)))
-		netif_start_queue(priv->ndev);
+	if (unlikely(num_tokens && netif_queue_stopped(dev)))
+		netif_start_queue(dev);
 	for (cnt = 0; cnt < num_tokens; cnt++) {
 		struct sk_buff *skb = (struct sk_buff *)net_data_tokens[cnt];
 		if (skb == NULL)
 			continue;
-		priv->net_dev_stats.tx_packets++;
-		priv->net_dev_stats.tx_bytes += skb->len;
+		ndev->stats.tx_packets++;
+		ndev->stats.tx_bytes += skb->len;
 		dev_kfree_skb_any(skb);
 	}
 	return 0;
@@ -1476,7 +1476,7 @@ static int emac_dev_xmit(struct sk_buff *skb, struct net_device *ndev)
 					" err. Out of TX BD's");
 			netif_stop_queue(priv->ndev);
 		}
-		priv->net_dev_stats.tx_dropped++;
+		ndev->stats.tx_dropped++;
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1501,7 +1501,7 @@ static void emac_dev_tx_timeout(struct net_device *ndev)
 	if (netif_msg_tx_err(priv))
 		dev_err(emac_dev, "DaVinci EMAC: xmit timeout, restarting TX");
 
-	priv->net_dev_stats.tx_errors++;
+	ndev->stats.tx_errors++;
 	emac_int_disable(priv);
 	emac_stop_txch(priv, EMAC_DEF_TX_CH);
 	emac_cleanup_txch(priv, EMAC_DEF_TX_CH);
@@ -1926,14 +1926,14 @@ static void emac_addbd_to_rx_queue(struct emac_priv *priv, u32 ch,
 static int emac_net_rx_cb(struct emac_priv *priv,
 			  struct emac_netpktobj *net_pkt_list)
 {
-	struct sk_buff *p_skb;
-	p_skb = (struct sk_buff *)net_pkt_list->pkt_token;
+	struct net_device *ndev = priv->ndev;
+	struct sk_buff *p_skb = net_pkt_list->pkt_token;
 	/* set length of packet */
 	skb_put(p_skb, net_pkt_list->pkt_length);
 	p_skb->protocol = eth_type_trans(p_skb, priv->ndev);
 	netif_receive_skb(p_skb);
-	priv->net_dev_stats.rx_bytes += net_pkt_list->pkt_length;
-	priv->net_dev_stats.rx_packets++;
+	ndev->stats.rx_bytes += net_pkt_list->pkt_length;
+	ndev->stats.rx_packets++;
 	return 0;
 }
 
@@ -2570,39 +2570,39 @@ static struct net_device_stats *emac_dev_getnetstats(struct net_device *ndev)
 	else
 		stats_clear_mask = 0;
 
-	priv->net_dev_stats.multicast += emac_read(EMAC_RXMCASTFRAMES);
+	ndev->stats.multicast += emac_read(EMAC_RXMCASTFRAMES);
 	emac_write(EMAC_RXMCASTFRAMES, stats_clear_mask);
 
-	priv->net_dev_stats.collisions += (emac_read(EMAC_TXCOLLISION) +
+	ndev->stats.collisions += (emac_read(EMAC_TXCOLLISION) +
 					   emac_read(EMAC_TXSINGLECOLL) +
 					   emac_read(EMAC_TXMULTICOLL));
 	emac_write(EMAC_TXCOLLISION, stats_clear_mask);
 	emac_write(EMAC_TXSINGLECOLL, stats_clear_mask);
 	emac_write(EMAC_TXMULTICOLL, stats_clear_mask);
 
-	priv->net_dev_stats.rx_length_errors += (emac_read(EMAC_RXOVERSIZED) +
+	ndev->stats.rx_length_errors += (emac_read(EMAC_RXOVERSIZED) +
 						emac_read(EMAC_RXJABBER) +
 						emac_read(EMAC_RXUNDERSIZED));
 	emac_write(EMAC_RXOVERSIZED, stats_clear_mask);
 	emac_write(EMAC_RXJABBER, stats_clear_mask);
 	emac_write(EMAC_RXUNDERSIZED, stats_clear_mask);
 
-	priv->net_dev_stats.rx_over_errors += (emac_read(EMAC_RXSOFOVERRUNS) +
+	ndev->stats.rx_over_errors += (emac_read(EMAC_RXSOFOVERRUNS) +
 					       emac_read(EMAC_RXMOFOVERRUNS));
 	emac_write(EMAC_RXSOFOVERRUNS, stats_clear_mask);
 	emac_write(EMAC_RXMOFOVERRUNS, stats_clear_mask);
 
-	priv->net_dev_stats.rx_fifo_errors += emac_read(EMAC_RXDMAOVERRUNS);
+	ndev->stats.rx_fifo_errors += emac_read(EMAC_RXDMAOVERRUNS);
 	emac_write(EMAC_RXDMAOVERRUNS, stats_clear_mask);
 
-	priv->net_dev_stats.tx_carrier_errors +=
+	ndev->stats.tx_carrier_errors +=
 		emac_read(EMAC_TXCARRIERSENSE);
 	emac_write(EMAC_TXCARRIERSENSE, stats_clear_mask);
 
-	priv->net_dev_stats.tx_fifo_errors = emac_read(EMAC_TXUNDERRUN);
+	ndev->stats.tx_fifo_errors = emac_read(EMAC_TXUNDERRUN);
 	emac_write(EMAC_TXUNDERRUN, stats_clear_mask);
 
-	return &priv->net_dev_stats;
+	return &ndev->stats;
 }
 
 static const struct net_device_ops emac_netdev_ops = {
-- 
1.7.0.4
