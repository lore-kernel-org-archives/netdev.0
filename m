From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] natsemi: add checks for dma mapping errors
Date: Sat, 19 Dec 2015 00:55:37 +0300
Message-ID: <1450475737-5959-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ispras.ru ([83.149.199.45]:35426 "EHLO mail.ispras.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753057AbbLRVzu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2015 16:55:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

refill_rx() and start_tx() do not check if mapping dma memory succeed.
The patch adds the checks and failure handling.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/ethernet/natsemi/natsemi.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/natsemi/natsemi.c b/drivers/net/ethernet/natsemi/natsemi.c
index b83f7c0fcf99..282e59d66a52 100644
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
@@ -2093,6 +2099,10 @@ static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev)
 	np->tx_skbuff[entry] = skb;
 	np->tx_dma[entry] = pci_map_single(np->pci_dev,
 				skb->data,skb->len, PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(np->pci_dev, np->tx_dma[entry])) {
+		np->tx_skbuff[entry] = NULL;
+		return NETDEV_TX_BUSY;
+	}
 
 	np->tx_ring[entry].addr = cpu_to_le32(np->tx_dma[entry]);
 
-- 
1.9.1
