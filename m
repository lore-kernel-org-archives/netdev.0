From: Denis Kirjanov <dkirjanov@kernel.org>
Subject: [PATCH -next 1/3] sundance: Convert to DMA API
Date: Tue, 21 Sep 2010 08:56:07 +0000
Message-ID: <20100921085607.GA19700@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:47044 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756503Ab0IUI4J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Sep 2010 04:56:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to DMA API

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
 drivers/net/sundance.c |   87 +++++++++++++++++++++++------------------------
 1 files changed, 43 insertions(+), 44 deletions(-)

diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index 3fa9497..ac32650 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -96,6 +96,7 @@ static char *media[MAX_UNITS];
 #include <asm/io.h>
 #include <linux/delay.h>
 #include <linux/spinlock.h>
+#include <linux/dma-mapping.h>
 #ifndef _COMPAT_WITH_OLD_KERNEL
 #include <linux/crc32.h>
 #include <linux/ethtool.h>
@@ -523,13 +524,15 @@ static int __devinit sundance_probe1 (struct pci_dev *pdev,
 	tasklet_init(&np->rx_tasklet, rx_poll, (unsigned long)dev);
 	tasklet_init(&np->tx_tasklet, tx_poll, (unsigned long)dev);
 
-	ring_space = pci_alloc_consistent(pdev, TX_TOTAL_SIZE, &ring_dma);
+	ring_space = dma_alloc_coherent(&pdev->dev, TX_TOTAL_SIZE,
+			&ring_dma, GFP_KERNEL);
 	if (!ring_space)
 		goto err_out_cleardev;
 	np->tx_ring = (struct netdev_desc *)ring_space;
 	np->tx_ring_dma = ring_dma;
 
-	ring_space = pci_alloc_consistent(pdev, RX_TOTAL_SIZE, &ring_dma);
+	ring_space = dma_alloc_coherent(&pdev->dev, RX_TOTAL_SIZE,
+			&ring_dma, GFP_KERNEL);
 	if (!ring_space)
 		goto err_out_unmap_tx;
 	np->rx_ring = (struct netdev_desc *)ring_space;
@@ -663,9 +666,11 @@ static int __devinit sundance_probe1 (struct pci_dev *pdev,
 err_out_unregister:
 	unregister_netdev(dev);
 err_out_unmap_rx:
-        pci_free_consistent(pdev, RX_TOTAL_SIZE, np->rx_ring, np->rx_ring_dma);
+	dma_free_coherent(&pdev->dev, RX_TOTAL_SIZE,
+		np->rx_ring, np->rx_ring_dma);
 err_out_unmap_tx:
-        pci_free_consistent(pdev, TX_TOTAL_SIZE, np->tx_ring, np->tx_ring_dma);
+	dma_free_coherent(&pdev->dev, TX_TOTAL_SIZE,
+		np->tx_ring, np->tx_ring_dma);
 err_out_cleardev:
 	pci_set_drvdata(pdev, NULL);
 	pci_iounmap(pdev, ioaddr);
@@ -1011,8 +1016,8 @@ static void init_ring(struct net_device *dev)
 		skb->dev = dev;		/* Mark as being used by this device. */
 		skb_reserve(skb, 2);	/* 16 byte align the IP header. */
 		np->rx_ring[i].frag[0].addr = cpu_to_le32(
-			pci_map_single(np->pci_dev, skb->data, np->rx_buf_sz,
-				PCI_DMA_FROMDEVICE));
+			dma_map_single(&np->pci_dev->dev, skb->data,
+				np->rx_buf_sz, DMA_FROM_DEVICE));
 		np->rx_ring[i].frag[0].length = cpu_to_le32(np->rx_buf_sz | LastFrag);
 	}
 	np->dirty_rx = (unsigned int)(i - RX_RING_SIZE);
@@ -1063,9 +1068,8 @@ start_tx (struct sk_buff *skb, struct net_device *dev)
 
 	txdesc->next_desc = 0;
 	txdesc->status = cpu_to_le32 ((entry << 2) | DisableAlign);
-	txdesc->frag[0].addr = cpu_to_le32 (pci_map_single (np->pci_dev, skb->data,
-							skb->len,
-							PCI_DMA_TODEVICE));
+	txdesc->frag[0].addr = cpu_to_le32(dma_map_single(&np->pci_dev->dev,
+				skb->data, skb->len, DMA_TO_DEVICE));
 	txdesc->frag[0].length = cpu_to_le32 (skb->len | LastFrag);
 
 	/* Increment cur_tx before tasklet_schedule() */
@@ -1109,9 +1113,9 @@ reset_tx (struct net_device *dev)
 
 		skb = np->tx_skbuff[i];
 		if (skb) {
-			pci_unmap_single(np->pci_dev,
+			dma_unmap_single(&np->pci_dev->dev,
 				le32_to_cpu(np->tx_ring[i].frag[0].addr),
-				skb->len, PCI_DMA_TODEVICE);
+				skb->len, DMA_TO_DEVICE);
 			if (irq)
 				dev_kfree_skb_irq (skb);
 			else
@@ -1233,9 +1237,9 @@ static irqreturn_t intr_handler(int irq, void *dev_instance)
 						break;
 				skb = np->tx_skbuff[entry];
 				/* Free the original skb. */
-				pci_unmap_single(np->pci_dev,
+				dma_unmap_single(&np->pci_dev->dev,
 					le32_to_cpu(np->tx_ring[entry].frag[0].addr),
-					skb->len, PCI_DMA_TODEVICE);
+					skb->len, DMA_TO_DEVICE);
 				dev_kfree_skb_irq (np->tx_skbuff[entry]);
 				np->tx_skbuff[entry] = NULL;
 				np->tx_ring[entry].frag[0].addr = 0;
@@ -1252,9 +1256,9 @@ static irqreturn_t intr_handler(int irq, void *dev_instance)
 					break;
 				skb = np->tx_skbuff[entry];
 				/* Free the original skb. */
-				pci_unmap_single(np->pci_dev,
+				dma_unmap_single(&np->pci_dev->dev,
 					le32_to_cpu(np->tx_ring[entry].frag[0].addr),
-					skb->len, PCI_DMA_TODEVICE);
+					skb->len, DMA_TO_DEVICE);
 				dev_kfree_skb_irq (np->tx_skbuff[entry]);
 				np->tx_skbuff[entry] = NULL;
 				np->tx_ring[entry].frag[0].addr = 0;
@@ -1334,22 +1338,18 @@ static void rx_poll(unsigned long data)
 			if (pkt_len < rx_copybreak &&
 			    (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
 				skb_reserve(skb, 2);	/* 16 byte align the IP header */
-				pci_dma_sync_single_for_cpu(np->pci_dev,
-							    le32_to_cpu(desc->frag[0].addr),
-							    np->rx_buf_sz,
-							    PCI_DMA_FROMDEVICE);
-
+				dma_sync_single_for_cpu(&np->pci_dev->dev,
+						le32_to_cpu(desc->frag[0].addr),
+						np->rx_buf_sz, DMA_FROM_DEVICE);
 				skb_copy_to_linear_data(skb, np->rx_skbuff[entry]->data, pkt_len);
-				pci_dma_sync_single_for_device(np->pci_dev,
-							       le32_to_cpu(desc->frag[0].addr),
-							       np->rx_buf_sz,
-							       PCI_DMA_FROMDEVICE);
+				dma_sync_single_for_device(&np->pci_dev->dev,
+						le32_to_cpu(desc->frag[0].addr),
+						np->rx_buf_sz, DMA_FROM_DEVICE);
 				skb_put(skb, pkt_len);
 			} else {
-				pci_unmap_single(np->pci_dev,
+				dma_unmap_single(&np->pci_dev->dev,
 					le32_to_cpu(desc->frag[0].addr),
-					np->rx_buf_sz,
-					PCI_DMA_FROMDEVICE);
+					np->rx_buf_sz, DMA_FROM_DEVICE);
 				skb_put(skb = np->rx_skbuff[entry], pkt_len);
 				np->rx_skbuff[entry] = NULL;
 			}
@@ -1396,8 +1396,8 @@ static void refill_rx (struct net_device *dev)
 			skb->dev = dev;		/* Mark as being used by this device. */
 			skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
 			np->rx_ring[entry].frag[0].addr = cpu_to_le32(
-				pci_map_single(np->pci_dev, skb->data,
-					np->rx_buf_sz, PCI_DMA_FROMDEVICE));
+				dma_map_single(&np->pci_dev->dev, skb->data,
+					np->rx_buf_sz, DMA_FROM_DEVICE));
 		}
 		/* Perhaps we need not reset this field. */
 		np->rx_ring[entry].frag[0].length =
@@ -1715,9 +1715,9 @@ static int netdev_close(struct net_device *dev)
 		np->rx_ring[i].status = 0;
 		skb = np->rx_skbuff[i];
 		if (skb) {
-			pci_unmap_single(np->pci_dev,
+			dma_unmap_single(&np->pci_dev->dev,
 				le32_to_cpu(np->rx_ring[i].frag[0].addr),
-				np->rx_buf_sz, PCI_DMA_FROMDEVICE);
+				np->rx_buf_sz, DMA_FROM_DEVICE);
 			dev_kfree_skb(skb);
 			np->rx_skbuff[i] = NULL;
 		}
@@ -1727,9 +1727,9 @@ static int netdev_close(struct net_device *dev)
 		np->tx_ring[i].next_desc = 0;
 		skb = np->tx_skbuff[i];
 		if (skb) {
-			pci_unmap_single(np->pci_dev,
+			dma_unmap_single(&np->pci_dev->dev,
 				le32_to_cpu(np->tx_ring[i].frag[0].addr),
-				skb->len, PCI_DMA_TODEVICE);
+				skb->len, DMA_TO_DEVICE);
 			dev_kfree_skb(skb);
 			np->tx_skbuff[i] = NULL;
 		}
@@ -1743,17 +1743,16 @@ static void __devexit sundance_remove1 (struct pci_dev *pdev)
 	struct net_device *dev = pci_get_drvdata(pdev);
 
 	if (dev) {
-		struct netdev_private *np = netdev_priv(dev);
-
-		unregister_netdev(dev);
-        	pci_free_consistent(pdev, RX_TOTAL_SIZE, np->rx_ring,
-			np->rx_ring_dma);
-	        pci_free_consistent(pdev, TX_TOTAL_SIZE, np->tx_ring,
-			np->tx_ring_dma);
-		pci_iounmap(pdev, np->base);
-		pci_release_regions(pdev);
-		free_netdev(dev);
-		pci_set_drvdata(pdev, NULL);
+	    struct netdev_private *np = netdev_priv(dev);
+	    unregister_netdev(dev);
+	    dma_free_coherent(&pdev->dev, RX_TOTAL_SIZE,
+		    np->rx_ring, np->rx_ring_dma);
+	    dma_free_coherent(&pdev->dev, TX_TOTAL_SIZE,
+		    np->tx_ring, np->tx_ring_dma);
+	    pci_iounmap(pdev, np->base);
+	    pci_release_regions(pdev);
+	    free_netdev(dev);
+	    pci_set_drvdata(pdev, NULL);
 	}
 }
 
-- 
1.7.2.2

