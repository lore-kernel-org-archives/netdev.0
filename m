From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH v2] natsemi: add checks for dma mapping errors
Date: Sat, 19 Dec 2015 15:13:49 +0300
Message-ID: <1450527229-6454-1-git-send-email-khoroshilov@ispras.ru>
References: <56754855.6080808@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56754855.6080808@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

refill_rx() and start_tx() do not check if mapping dma memory succeed.
The patch adds the checks and failure handling.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/ethernet/natsemi/natsemi.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/natsemi/natsemi.c b/drivers/net/ethernet/natsemi/natsemi.c
index b83f7c0fcf99..122c2ee3dfe2 100644
--- a/drivers/net/ethernet/natsemi/natsemi.c
+++ b/drivers/net/ethernet/natsemi/natsemi.c
@@ -1937,6 +1937,12 @@ static void refill_rx(struct net_device *dev)
 				break; /* Better luck next round. */
 			np->rx_dma[entry] = pci_map_single(np->pci_dev,
 				skb->data, buflen, PCI_DMA_FROMDEVICE);
+			if (pci_dma_mapping_error(np->pci_dev,
+						  np->rx_dma[entry])) {
+				dev_kfree_skb_any(skb);
+				np->rx_skbuff[entry] = NULL;
+				break; /* Better luck next round. */
+			}
 			np->rx_ring[entry].addr = cpu_to_le32(np->rx_dma[entry]);
 		}
 		np->rx_ring[entry].cmd_status = cpu_to_le32(np->rx_buf_sz);
@@ -2093,6 +2099,12 @@ static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev)
 	np->tx_skbuff[entry] = skb;
 	np->tx_dma[entry] = pci_map_single(np->pci_dev,
 				skb->data,skb->len, PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(np->pci_dev, np->tx_dma[entry])) {
+		np->tx_skbuff[entry] = NULL;
+		dev_kfree_skb_irq(skb);
+		dev->stats.tx_dropped++;
+		return NETDEV_TX_OK;
+	}
 
 	np->tx_ring[entry].addr = cpu_to_le32(np->tx_dma[entry]);
 
-- 
1.9.1
