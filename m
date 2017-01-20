From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] net: adaptec: starfire: add checks for dma mapping errors
Date: Sat, 21 Jan 2017 01:52:24 +0300
Message-ID: <1484952744-9815-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Ion Badulescu <ionut@badula.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

init_ring() and refill_rx_ring() don't check if mapping dma memory succeed.
The patch adds the checks and failure handling.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/ethernet/adaptec/starfire.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/adaptec/starfire.c b/drivers/net/ethernet/adaptec/starfire.c
index c12d2618eebf..e27043d051e1 100644
--- a/drivers/net/ethernet/adaptec/starfire.c
+++ b/drivers/net/ethernet/adaptec/starfire.c
@@ -1152,6 +1152,12 @@ static void init_ring(struct net_device *dev)
 		if (skb == NULL)
 			break;
 		np->rx_info[i].mapping = pci_map_single(np->pci_dev, skb->data, np->rx_buf_sz, PCI_DMA_FROMDEVICE);
+		if (pci_dma_mapping_error(np->pci_dev,
+					  np->rx_info[i].mapping)) {
+			dev_kfree_skb(skb);
+			np->rx_info[i].skb = NULL;
+			break;
+		}
 		/* Grrr, we cannot offset to correctly align the IP header. */
 		np->rx_ring[i].rxaddr = cpu_to_dma(np->rx_info[i].mapping | RxDescValid);
 	}
@@ -1569,6 +1575,12 @@ static void refill_rx_ring(struct net_device *dev)
 				break;	/* Better luck next round. */
 			np->rx_info[entry].mapping =
 				pci_map_single(np->pci_dev, skb->data, np->rx_buf_sz, PCI_DMA_FROMDEVICE);
+			if (pci_dma_mapping_error(np->pci_dev,
+						np->rx_info[entry].mapping)) {
+				dev_kfree_skb(skb);
+				np->rx_info[entry].skb = NULL;
+				break;
+			}
 			np->rx_ring[entry].rxaddr =
 				cpu_to_dma(np->rx_info[entry].mapping | RxDescValid);
 		}
-- 
2.7.4
