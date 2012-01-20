From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/3] skge: add byte queue limit support
Date: Thu, 19 Jan 2012 16:43:54 -0800
Message-ID: <20120119164354.78ea63d6@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49242 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753978Ab2ATApU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jan 2012 19:45:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This also changes the cleanup logic slightly to aggregate
completed notifications for multiple packets.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/ethernet/marvell/skge.c	2012-01-19 16:12:19.000000000 -0800
+++ b/drivers/net/ethernet/marvell/skge.c	2012-01-19 16:42:17.675908798 -0800
@@ -2831,6 +2831,7 @@ static netdev_tx_t skge_xmit_frame(struc
 		netif_stop_queue(dev);
 	}
 
+	netdev_sent_queue(dev, skb->len);
 	return NETDEV_TX_OK;
 
 mapping_unwind:
@@ -2858,11 +2859,9 @@ mapping_error:
 
 
 /* Free resources associated with this reing element */
-static void skge_tx_free(struct skge_port *skge, struct skge_element *e,
-			 u32 control)
+static inline void skge_tx_unmap(struct pci_dev *pdev, struct skge_element *e,
+				 u32 control)
 {
-	struct pci_dev *pdev = skge->hw->pdev;
-
 	/* skb header vs. fragment */
 	if (control & BMU_STF)
 		pci_unmap_single(pdev, dma_unmap_addr(e, mapaddr),
@@ -2872,13 +2871,6 @@ static void skge_tx_free(struct skge_por
 		pci_unmap_page(pdev, dma_unmap_addr(e, mapaddr),
 			       dma_unmap_len(e, maplen),
 			       PCI_DMA_TODEVICE);
-
-	if (control & BMU_EOF) {
-		netif_printk(skge, tx_done, KERN_DEBUG, skge->netdev,
-			     "tx done slot %td\n", e - skge->tx_ring.start);
-
-		dev_kfree_skb(e->skb);
-	}
 }
 
 /* Free all buffers in transmit ring */
@@ -2889,10 +2881,15 @@ static void skge_tx_clean(struct net_dev
 
 	for (e = skge->tx_ring.to_clean; e != skge->tx_ring.to_use; e = e->next) {
 		struct skge_tx_desc *td = e->desc;
-		skge_tx_free(skge, e, td->control);
+
+		skge_tx_unmap(skge->hw->pdev, e, td->control);
+
+		if (td->control & BMU_EOF)
+			dev_kfree_skb(e->skb);
 		td->control = 0;
 	}
 
+	netdev_reset_queue(dev);
 	skge->tx_ring.to_clean = e;
 }
 
@@ -3157,6 +3154,7 @@ static void skge_tx_done(struct net_devi
 	struct skge_port *skge = netdev_priv(dev);
 	struct skge_ring *ring = &skge->tx_ring;
 	struct skge_element *e;
+	unsigned int bytes_compl = 0, pkts_compl = 0;
 
 	skge_write8(skge->hw, Q_ADDR(txqaddr[skge->port], Q_CSR), CSR_IRQ_CL_F);
 
@@ -3166,8 +3164,20 @@ static void skge_tx_done(struct net_devi
 		if (control & BMU_OWN)
 			break;
 
-		skge_tx_free(skge, e, control);
+		skge_tx_unmap(skge->hw->pdev, e, control);
+
+		if (control & BMU_EOF) {
+			netif_printk(skge, tx_done, KERN_DEBUG, skge->netdev,
+				     "tx done slot %td\n",
+				     e - skge->tx_ring.start);
+
+			pkts_compl++;
+			bytes_compl += e->skb->len;
+
+			dev_kfree_skb(e->skb);
+		}
 	}
+	netdev_completed_queue(dev, pkts_compl, bytes_compl);
 	skge->tx_ring.to_clean = e;
 
 	/* Can run lockless until we need to synchronize to restart queue. */
