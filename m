From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH] 2.4.25 pcnet32.c SLAB_DEBUG length error fix
Date: Thu, 19 Feb 2004 08:46:38 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402191646.i1JGkcf04984@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The pcnet32 driver uses the incorrect length (of zero) in
pci_[un]map_single for receive buffers.  This is seen with SLAB_DEBUG
enabled.

--- linux-2.4.25/drivers/net/orig.pcnet32.c	Fri Nov 28 10:26:20 2003
+++ linux-2.4.25/drivers/net/pcnet32.c	Thu Feb 19 08:35:21 2004
@@ -976,9 +976,10 @@
 	}
 
 	if (lp->rx_dma_addr[i] == 0) 
-		lp->rx_dma_addr[i] = pci_map_single(lp->pci_dev, rx_skbuff->tail, rx_skbuff->len, PCI_DMA_FROMDEVICE);
+		lp->rx_dma_addr[i] = pci_map_single(lp->pci_dev,
+			rx_skbuff->tail, PKT_BUF_SZ-2, PCI_DMA_FROMDEVICE);
 	lp->rx_ring[i].base = (u32)le32_to_cpu(lp->rx_dma_addr[i]);
-	lp->rx_ring[i].buf_length = le16_to_cpu(-PKT_BUF_SZ);
+	lp->rx_ring[i].buf_length = le16_to_cpu(2-PKT_BUF_SZ);
 	lp->rx_ring[i].status = le16_to_cpu(0x8000);
     }
     /* The Tx buffer address is filled in as needed, but we do need to clear
@@ -1312,13 +1313,14 @@
 		    if ((newskb = dev_alloc_skb (PKT_BUF_SZ))) {
 			skb_reserve (newskb, 2);
 			skb = lp->rx_skbuff[entry];
-			pci_unmap_single(lp->pci_dev, lp->rx_dma_addr[entry], skb->len, PCI_DMA_FROMDEVICE);
+			pci_unmap_single(lp->pci_dev, lp->rx_dma_addr[entry],
+				PKT_BUF_SZ-2, PCI_DMA_FROMDEVICE);
 			skb_put (skb, pkt_len);
 			lp->rx_skbuff[entry] = newskb;
 			newskb->dev = dev;
                         lp->rx_dma_addr[entry] = 
 				pci_map_single(lp->pci_dev, newskb->tail,
-					newskb->len, PCI_DMA_FROMDEVICE);
+					PKT_BUF_SZ-2, PCI_DMA_FROMDEVICE);
 			lp->rx_ring[entry].base = le32_to_cpu(lp->rx_dma_addr[entry]);
 			rx_in_place = 1;
 		    } else
@@ -1347,7 +1349,7 @@
 		    skb_put(skb,pkt_len);	/* Make room */
 		    pci_dma_sync_single(lp->pci_dev,
 		                        lp->rx_dma_addr[entry],
-		                        PKT_BUF_SZ,
+		                        PKT_BUF_SZ-2,
 		                        PCI_DMA_FROMDEVICE);
 		    eth_copy_and_sum(skb,
 				     (unsigned char *)(lp->rx_skbuff[entry]->tail),
@@ -1364,7 +1366,7 @@
 	 * The docs say that the buffer length isn't touched, but Andrew Boyd
 	 * of QNX reports that some revs of the 79C965 clear it.
 	 */
-	lp->rx_ring[entry].buf_length = le16_to_cpu(-PKT_BUF_SZ);
+	lp->rx_ring[entry].buf_length = le16_to_cpu(2-PKT_BUF_SZ);
 	lp->rx_ring[entry].status |= le16_to_cpu(0x8000);
 	entry = (++lp->cur_rx) & RX_RING_MOD_MASK;
     }
@@ -1402,7 +1404,8 @@
     for (i = 0; i < RX_RING_SIZE; i++) {
 	lp->rx_ring[i].status = 0;			    
 	if (lp->rx_skbuff[i]) {
-            pci_unmap_single(lp->pci_dev, lp->rx_dma_addr[i], lp->rx_skbuff[i]->len, PCI_DMA_FROMDEVICE);
+            pci_unmap_single(lp->pci_dev, lp->rx_dma_addr[i], PKT_BUF_SZ-2,
+		    PCI_DMA_FROMDEVICE);
 	    dev_kfree_skb(lp->rx_skbuff[i]);
         }
 	lp->rx_skbuff[i] = NULL;

-- 
Don Fry
brazilnut@us.ibm.com
