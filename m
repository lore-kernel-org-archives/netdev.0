From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v2] sh_eth: unmap DMA buffers when freeing rings
Date: Mon, 17 Apr 2017 15:55:22 +0300
Message-ID: <20170417125532.826640693@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Cc: linux-renesas-soc@vger.kernel.org,
        Simon Horman <horms@verge.net.au>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: netdev@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline; filename=sh_eth-unmap-DMA-buffers-when-freeing-rings-v2.patch
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The DMA API debugging (when enabled) causes:

WARNING: CPU: 0 PID: 1445 at lib/dma-debug.c:519 add_dma_entry+0xe0/0x12c
DMA-API: exceeded 7 overlapping mappings of cacheline 0x01b2974d

to be  printed after repeated initialization of the Ether device, e.g.
suspend/resume or 'ifconfig' up/down. This is because DMA buffers mapped
using dma_map_single() in sh_eth_ring_format() and sh_eth_start_xmit() are
never unmapped. Resolve this problem by unmapping the buffers when freeing
the descriptor  rings;  in order  to do it right, we'd have to add an extra
parameter to sh_eth_txfree() (we rename this function to sh_eth_tx_free(),
while at it).

Based on the commit a47b70ea86bd ("ravb: unmap descriptors when freeing
rings").

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
This patch is against DaveM's 'net.git' repo.

Changed in version 2:
- fixed the "packet sent" condition in sh_eth_tx_free().

 drivers/net/ethernet/renesas/sh_eth.c |  122 ++++++++++++++++++----------------
 1 file changed, 67 insertions(+), 55 deletions(-)

Index: net/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net/drivers/net/ethernet/renesas/sh_eth.c
@@ -1127,12 +1127,70 @@ static struct mdiobb_ops bb_ops = {
 	.get_mdio_data = sh_get_mdio,
 };
 
+/* free Tx skb function */
+static int sh_eth_tx_free(struct net_device *ndev, bool sent_only)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	struct sh_eth_txdesc *txdesc;
+	int free_num = 0;
+	int entry;
+	bool sent;
+
+	for (; mdp->cur_tx - mdp->dirty_tx > 0; mdp->dirty_tx++) {
+		entry = mdp->dirty_tx % mdp->num_tx_ring;
+		txdesc = &mdp->tx_ring[entry];
+		sent = !(txdesc->status & cpu_to_le32(TD_TACT));
+		if (sent_only && !sent)
+			break;
+		/* TACT bit must be checked before all the following reads */
+		dma_rmb();
+		netif_info(mdp, tx_done, ndev,
+			   "tx entry %d status 0x%08x\n",
+			   entry, le32_to_cpu(txdesc->status));
+		/* Free the original skb. */
+		if (mdp->tx_skbuff[entry]) {
+			dma_unmap_single(&ndev->dev, le32_to_cpu(txdesc->addr),
+					 le32_to_cpu(txdesc->len) >> 16,
+					 DMA_TO_DEVICE);
+			dev_kfree_skb_irq(mdp->tx_skbuff[entry]);
+			mdp->tx_skbuff[entry] = NULL;
+			free_num++;
+		}
+		txdesc->status = cpu_to_le32(TD_TFP);
+		if (entry >= mdp->num_tx_ring - 1)
+			txdesc->status |= cpu_to_le32(TD_TDLE);
+
+		if (sent) {
+			ndev->stats.tx_packets++;
+			ndev->stats.tx_bytes += le32_to_cpu(txdesc->len) >> 16;
+		}
+	}
+	return free_num;
+}
+
 /* free skb and descriptor buffer */
 static void sh_eth_ring_free(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	int ringsize, i;
 
+	if (mdp->rx_ring) {
+		for (i = 0; i < mdp->num_rx_ring; i++) {
+			if (mdp->rx_skbuff[i]) {
+				struct sh_eth_rxdesc *rxdesc = &mdp->rx_ring[i];
+
+				dma_unmap_single(&ndev->dev,
+						 le32_to_cpu(rxdesc->addr),
+						 ALIGN(mdp->rx_buf_sz, 32),
+						 DMA_FROM_DEVICE);
+			}
+		}
+		ringsize = sizeof(struct sh_eth_rxdesc) * mdp->num_rx_ring;
+		dma_free_coherent(NULL, ringsize, mdp->rx_ring,
+				  mdp->rx_desc_dma);
+		mdp->rx_ring = NULL;
+	}
+
 	/* Free Rx skb ringbuffer */
 	if (mdp->rx_skbuff) {
 		for (i = 0; i < mdp->num_rx_ring; i++)
@@ -1141,27 +1199,18 @@ static void sh_eth_ring_free(struct net_
 	kfree(mdp->rx_skbuff);
 	mdp->rx_skbuff = NULL;
 
-	/* Free Tx skb ringbuffer */
-	if (mdp->tx_skbuff) {
-		for (i = 0; i < mdp->num_tx_ring; i++)
-			dev_kfree_skb(mdp->tx_skbuff[i]);
-	}
-	kfree(mdp->tx_skbuff);
-	mdp->tx_skbuff = NULL;
-
-	if (mdp->rx_ring) {
-		ringsize = sizeof(struct sh_eth_rxdesc) * mdp->num_rx_ring;
-		dma_free_coherent(NULL, ringsize, mdp->rx_ring,
-				  mdp->rx_desc_dma);
-		mdp->rx_ring = NULL;
-	}
-
 	if (mdp->tx_ring) {
+		sh_eth_tx_free(ndev, false);
+
 		ringsize = sizeof(struct sh_eth_txdesc) * mdp->num_tx_ring;
 		dma_free_coherent(NULL, ringsize, mdp->tx_ring,
 				  mdp->tx_desc_dma);
 		mdp->tx_ring = NULL;
 	}
+
+	/* Free Tx skb ringbuffer */
+	kfree(mdp->tx_skbuff);
+	mdp->tx_skbuff = NULL;
 }
 
 /* format skb and descriptor buffer */
@@ -1409,43 +1458,6 @@ static void sh_eth_dev_exit(struct net_d
 	update_mac_address(ndev);
 }
 
-/* free Tx skb function */
-static int sh_eth_txfree(struct net_device *ndev)
-{
-	struct sh_eth_private *mdp = netdev_priv(ndev);
-	struct sh_eth_txdesc *txdesc;
-	int free_num = 0;
-	int entry;
-
-	for (; mdp->cur_tx - mdp->dirty_tx > 0; mdp->dirty_tx++) {
-		entry = mdp->dirty_tx % mdp->num_tx_ring;
-		txdesc = &mdp->tx_ring[entry];
-		if (txdesc->status & cpu_to_le32(TD_TACT))
-			break;
-		/* TACT bit must be checked before all the following reads */
-		dma_rmb();
-		netif_info(mdp, tx_done, ndev,
-			   "tx entry %d status 0x%08x\n",
-			   entry, le32_to_cpu(txdesc->status));
-		/* Free the original skb. */
-		if (mdp->tx_skbuff[entry]) {
-			dma_unmap_single(&ndev->dev, le32_to_cpu(txdesc->addr),
-					 le32_to_cpu(txdesc->len) >> 16,
-					 DMA_TO_DEVICE);
-			dev_kfree_skb_irq(mdp->tx_skbuff[entry]);
-			mdp->tx_skbuff[entry] = NULL;
-			free_num++;
-		}
-		txdesc->status = cpu_to_le32(TD_TFP);
-		if (entry >= mdp->num_tx_ring - 1)
-			txdesc->status |= cpu_to_le32(TD_TDLE);
-
-		ndev->stats.tx_packets++;
-		ndev->stats.tx_bytes += le32_to_cpu(txdesc->len) >> 16;
-	}
-	return free_num;
-}
-
 /* Packet receive function */
 static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
 {
@@ -1690,7 +1702,7 @@ static void sh_eth_error(struct net_devi
 			   intr_status, mdp->cur_tx, mdp->dirty_tx,
 			   (u32)ndev->state, edtrr);
 		/* dirty buffer free */
-		sh_eth_txfree(ndev);
+		sh_eth_tx_free(ndev, true);
 
 		/* SH7712 BUG */
 		if (edtrr ^ sh_eth_get_edtrr_trns(mdp)) {
@@ -1751,7 +1763,7 @@ static irqreturn_t sh_eth_interrupt(int
 		/* Clear Tx interrupts */
 		sh_eth_write(ndev, intr_status & cd->tx_check, EESR);
 
-		sh_eth_txfree(ndev);
+		sh_eth_tx_free(ndev, true);
 		netif_wake_queue(ndev);
 	}
 
@@ -2412,7 +2424,7 @@ static int sh_eth_start_xmit(struct sk_b
 
 	spin_lock_irqsave(&mdp->lock, flags);
 	if ((mdp->cur_tx - mdp->dirty_tx) >= (mdp->num_tx_ring - 4)) {
-		if (!sh_eth_txfree(ndev)) {
+		if (!sh_eth_tx_free(ndev, true)) {
 			netif_warn(mdp, tx_queued, ndev, "TxFD exhausted.\n");
 			netif_stop_queue(ndev);
 			spin_unlock_irqrestore(&mdp->lock, flags);
