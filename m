From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH v2] net: adaptec: starfire: add checks for dma mapping errors
Date: Sat, 28 Jan 2017 01:07:30 +0300
Message-ID: <1485554850-7726-1-git-send-email-khoroshilov@ispras.ru>
References: <20170123.125317.799337053139253880.davem@redhat.com>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
        Ion Badulescu <ionut@badula.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170123.125317.799337053139253880.davem@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

init_ring(), refill_rx_ring() and start_tx() don't check
if mapping dma memory succeed.
The patch adds the checks and failure handling.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/ethernet/adaptec/starfire.c | 45 +++++++++++++++++++++++++++++++--
 1 file changed, 43 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/adaptec/starfire.c b/drivers/net/ethernet/adaptec/starfire.c
index c12d2618eebf..3872ab96b80a 100644
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
@@ -1182,8 +1188,9 @@ static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	unsigned int entry;
+	unsigned int prev_tx;
 	u32 status;
-	int i;
+	int i, j;
 
 	/*
 	 * be cautious here, wrapping the queue has weird semantics
@@ -1201,6 +1208,7 @@ static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev)
 	}
 #endif /* ZEROCOPY && HAS_BROKEN_FIRMWARE */
 
+	prev_tx = np->cur_tx;
 	entry = np->cur_tx % TX_RING_SIZE;
 	for (i = 0; i < skb_num_frags(skb); i++) {
 		int wrap_ring = 0;
@@ -1234,6 +1242,11 @@ static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev)
 					       skb_frag_size(this_frag),
 					       PCI_DMA_TODEVICE);
 		}
+		if (pci_dma_mapping_error(np->pci_dev,
+					  np->tx_info[entry].mapping)) {
+			dev->stats.tx_dropped++;
+			goto err_out;
+		}
 
 		np->tx_ring[entry].addr = cpu_to_dma(np->tx_info[entry].mapping);
 		np->tx_ring[entry].status = cpu_to_le32(status);
@@ -1268,8 +1281,30 @@ static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev)
 		netif_stop_queue(dev);
 
 	return NETDEV_TX_OK;
-}
 
+err_out:
+	entry = prev_tx % TX_RING_SIZE;
+	np->tx_info[entry].skb = NULL;
+	if (i > 0) {
+		pci_unmap_single(np->pci_dev,
+				 np->tx_info[entry].mapping,
+				 skb_first_frag_len(skb),
+				 PCI_DMA_TODEVICE);
+		np->tx_info[entry].mapping = 0;
+		entry = (entry + np->tx_info[entry].used_slots) % TX_RING_SIZE;
+		for (j = 1; j < i; j++) {
+			pci_unmap_single(np->pci_dev,
+					 np->tx_info[entry].mapping,
+					 skb_frag_size(
+						&skb_shinfo(skb)->frags[j-1]),
+					 PCI_DMA_TODEVICE);
+			entry++;
+		}
+	}
+	dev_kfree_skb_any(skb);
+	np->cur_tx = prev_tx;
+	return NETDEV_TX_OK;
+}
 
 /* The interrupt handler does all of the Rx thread work and cleans up
    after the Tx thread. */
@@ -1569,6 +1604,12 @@ static void refill_rx_ring(struct net_device *dev)
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
