From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH v3 1/6] net: fec: Factorize the .xmit transmit function
Date: Thu, 5 Jun 2014 14:59:27 +0800
Message-ID: <1401951572-6538-2-git-send-email-b38611@freescale.com>
References: <1401951572-6538-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <shawn.guo@linaro.org>,
	<b38611@freescale.com>, <R49496@freescale.com>,
	<ezequiel.garcia@free-electrons.com>, <bhutchings@solarflare.com>,
	<stephen@networkplumber.org>, <b20596@freescale.com>,
	<David.Laight@ACULAB.COM>, <eric.dumazet@gmail.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0211.outbound.protection.outlook.com ([207.46.163.211]:4170
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751740AbaFEIXS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2014 04:23:18 -0400
In-Reply-To: <1401951572-6538-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the code more readable and easy to support other features like
SG, TSO, moving the common transmit function to one api.

And the patch also factorize the getting BD index to it own function.

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c |   87 ++++++++++++++++++-----------
 1 files changed, 54 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 802be17..32c2276 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -287,6 +287,25 @@ struct bufdesc *fec_enet_get_prevdesc(struct bufdesc *bdp, struct fec_enet_priva
 		return (new_bd < base) ? (new_bd + ring_size) : new_bd;
 }
 
+static inline
+int fec_enet_get_bd_index(struct bufdesc *bdp, struct fec_enet_private *fep)
+{
+	struct bufdesc *base;
+	int index;
+
+	if (bdp >= fep->tx_bd_base)
+		base = fep->tx_bd_base;
+	else
+		base = fep->rx_bd_base;
+
+	if (fep->bufdesc_ex)
+		index = (struct bufdesc_ex *)bdp - (struct bufdesc_ex *)base;
+	else
+		index = bdp - base;
+
+	return index;
+}
+
 static void *swap_buffer(void *bufaddr, int len)
 {
 	int i;
@@ -313,8 +332,7 @@ fec_enet_clear_csum(struct sk_buff *skb, struct net_device *ndev)
 	return 0;
 }
 
-static netdev_tx_t
-fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
+static int txq_submit_skb(struct sk_buff *skb, struct net_device *ndev)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	const struct platform_device_id *id_entry =
@@ -329,14 +347,6 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 	status = bdp->cbd_sc;
 
-	if (status & BD_ENET_TX_READY) {
-		/* Ooops.  All transmit buffers are full.  Bail out.
-		 * This should not happen, since ndev->tbusy should be set.
-		 */
-		netdev_err(ndev, "tx queue full!\n");
-		return NETDEV_TX_BUSY;
-	}
-
 	/* Protocol checksum off-load for TCP and UDP. */
 	if (fec_enet_clear_csum(skb, ndev)) {
 		dev_kfree_skb_any(skb);
@@ -350,16 +360,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	bufaddr = skb->data;
 	bdp->cbd_datlen = skb->len;
 
-	/*
-	 * On some FEC implementations data must be aligned on
-	 * 4-byte boundaries. Use bounce buffers to copy data
-	 * and get it aligned. Ugh.
-	 */
-	if (fep->bufdesc_ex)
-		index = (struct bufdesc_ex *)bdp -
-			(struct bufdesc_ex *)fep->tx_bd_base;
-	else
-		index = bdp - fep->tx_bd_base;
+	index = fec_enet_get_bd_index(bdp, fep);
 
 	if (((unsigned long) bufaddr) & FEC_ALIGNMENT) {
 		memcpy(fep->tx_bounce[index], skb->data, skb->len);
@@ -433,15 +434,43 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 	fep->cur_tx = bdp;
 
-	if (fep->cur_tx == fep->dirty_tx)
-		netif_stop_queue(ndev);
-
 	/* Trigger transmission start */
 	writel(0, fep->hwp + FEC_X_DES_ACTIVE);
 
 	return NETDEV_TX_OK;
 }
 
+static netdev_tx_t
+fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
+{
+	struct fec_enet_private *fep = netdev_priv(ndev);
+	struct bufdesc *bdp;
+	unsigned short	status;
+	int ret;
+
+	/* Fill in a Tx ring entry */
+	bdp = fep->cur_tx;
+
+	status = bdp->cbd_sc;
+
+	if (status & BD_ENET_TX_READY) {
+		/* Ooops.  All transmit buffers are full.  Bail out.
+		 * This should not happen, since ndev->tbusy should be set.
+		 */
+		netdev_err(ndev, "tx queue full!\n");
+		return NETDEV_TX_BUSY;
+	}
+
+	ret = txq_submit_skb(skb, ndev);
+	if (ret == -EBUSY)
+		return NETDEV_TX_BUSY;
+
+	if (fep->cur_tx == fep->dirty_tx)
+		netif_stop_queue(ndev);
+
+	return NETDEV_TX_OK;
+}
+
 /* Init RX & TX buffer descriptors
  */
 static void fec_enet_bd_init(struct net_device *dev)
@@ -770,11 +799,7 @@ fec_enet_tx(struct net_device *ndev)
 		if (bdp == fep->cur_tx)
 			break;
 
-		if (fep->bufdesc_ex)
-			index = (struct bufdesc_ex *)bdp -
-				(struct bufdesc_ex *)fep->tx_bd_base;
-		else
-			index = bdp - fep->tx_bd_base;
+		index = fec_enet_get_bd_index(bdp, fep);
 
 		skb = fep->tx_skbuff[index];
 		dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr, skb->len,
@@ -921,11 +946,7 @@ fec_enet_rx(struct net_device *ndev, int budget)
 		pkt_len = bdp->cbd_datlen;
 		ndev->stats.rx_bytes += pkt_len;
 
-		if (fep->bufdesc_ex)
-			index = (struct bufdesc_ex *)bdp -
-				(struct bufdesc_ex *)fep->rx_bd_base;
-		else
-			index = bdp - fep->rx_bd_base;
+		index = fec_enet_get_bd_index(bdp, fep);
 		data = fep->rx_skbuff[index]->data;
 		dma_sync_single_for_cpu(&fep->pdev->dev, bdp->cbd_bufaddr,
 					FEC_ENET_RX_FRSIZE, DMA_FROM_DEVICE);
-- 
1.7.8
