From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next 06/14] net: moxa: Use net_device_stats from struct net_device
Date: Fri,  7 Apr 2017 10:17:31 +0200
Message-ID: <20170407081739.5243-7-tklauser@distanz.ch>
References: <20170407081739.5243-1-tklauser@distanz.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:34520 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755361AbdDGIRq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 04:17:46 -0400
In-Reply-To: <20170407081739.5243-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using a private copy of struct net_device_stats in struct
moxart_mac_priv_t, use stats from struct net_device. Also remove the now
unnecessary .ndo_get_stats function.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/moxa/moxart_ether.c | 28 ++++++++++------------------
 drivers/net/ethernet/moxa/moxart_ether.h |  1 -
 2 files changed, 10 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index 6ad44be08b33..c0d7d5eec7e7 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -228,8 +228,8 @@ static int moxart_rx_poll(struct napi_struct *napi, int budget)
 		if (desc0 & (RX_DESC0_ERR | RX_DESC0_CRC_ERR | RX_DESC0_FTL |
 			     RX_DESC0_RUNT | RX_DESC0_ODD_NB)) {
 			net_dbg_ratelimited("packet error\n");
-			priv->stats.rx_dropped++;
-			priv->stats.rx_errors++;
+			ndev->stats.rx_dropped++;
+			ndev->stats.rx_errors++;
 			goto rx_next;
 		}
 
@@ -245,8 +245,8 @@ static int moxart_rx_poll(struct napi_struct *napi, int budget)
 
 		if (unlikely(!skb)) {
 			net_dbg_ratelimited("netdev_alloc_skb_ip_align failed\n");
-			priv->stats.rx_dropped++;
-			priv->stats.rx_errors++;
+			ndev->stats.rx_dropped++;
+			ndev->stats.rx_errors++;
 			goto rx_next;
 		}
 
@@ -256,10 +256,10 @@ static int moxart_rx_poll(struct napi_struct *napi, int budget)
 		napi_gro_receive(&priv->napi, skb);
 		rx++;
 
-		priv->stats.rx_packets++;
-		priv->stats.rx_bytes += len;
+		ndev->stats.rx_packets++;
+		ndev->stats.rx_bytes += len;
 		if (desc0 & RX_DESC0_MULTICAST)
-			priv->stats.multicast++;
+			ndev->stats.multicast++;
 
 rx_next:
 		wmb(); /* prevent setting ownership back too early */
@@ -296,8 +296,8 @@ static void moxart_tx_finished(struct net_device *ndev)
 		dma_unmap_single(&ndev->dev, priv->tx_mapping[tx_tail],
 				 priv->tx_len[tx_tail], DMA_TO_DEVICE);
 
-		priv->stats.tx_packets++;
-		priv->stats.tx_bytes += priv->tx_skb[tx_tail]->len;
+		ndev->stats.tx_packets++;
+		ndev->stats.tx_bytes += priv->tx_skb[tx_tail]->len;
 
 		dev_kfree_skb_irq(priv->tx_skb[tx_tail]);
 		priv->tx_skb[tx_tail] = NULL;
@@ -349,7 +349,7 @@ static int moxart_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 	if (moxart_desc_read(desc + TX_REG_OFFSET_DESC0) & TX_DESC0_DMA_OWN) {
 		net_dbg_ratelimited("no TX space for packet\n");
-		priv->stats.tx_dropped++;
+		ndev->stats.tx_dropped++;
 		goto out_unlock;
 	}
 	rmb(); /* ensure data is only read that had TX_DESC0_DMA_OWN cleared */
@@ -400,13 +400,6 @@ static int moxart_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	return ret;
 }
 
-static struct net_device_stats *moxart_mac_get_stats(struct net_device *ndev)
-{
-	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
-
-	return &priv->stats;
-}
-
 static void moxart_mac_setmulticast(struct net_device *ndev)
 {
 	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
@@ -456,7 +449,6 @@ static const struct net_device_ops moxart_netdev_ops = {
 	.ndo_open		= moxart_mac_open,
 	.ndo_stop		= moxart_mac_stop,
 	.ndo_start_xmit		= moxart_mac_start_xmit,
-	.ndo_get_stats		= moxart_mac_get_stats,
 	.ndo_set_rx_mode	= moxart_mac_set_rx_mode,
 	.ndo_set_mac_address	= moxart_set_mac_address,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/moxa/moxart_ether.h b/drivers/net/ethernet/moxa/moxart_ether.h
index afc32ec998c0..686b8957d5cf 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.h
+++ b/drivers/net/ethernet/moxa/moxart_ether.h
@@ -293,7 +293,6 @@
 
 struct moxart_mac_priv_t {
 	void __iomem *base;
-	struct net_device_stats stats;
 	unsigned int reg_maccr;
 	unsigned int reg_imr;
 	struct napi_struct napi;
-- 
2.12.2
