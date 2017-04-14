From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] net: natsemi: ns83820: add checks for dma mapping error
Date: Sat, 15 Apr 2017 01:50:50 +0300
Message-ID: <1492210250-17200-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver does not check if mapping dma memory succeed.
The patch adds the checks and failure handling.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/ethernet/natsemi/ns83820.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/natsemi/ns83820.c b/drivers/net/ethernet/natsemi/ns83820.c
index 729095db3e08..7d6d692ebb92 100644
--- a/drivers/net/ethernet/natsemi/ns83820.c
+++ b/drivers/net/ethernet/natsemi/ns83820.c
@@ -534,14 +534,19 @@ static inline int ns83820_add_rx_skb(struct ns83820 *dev, struct sk_buff *skb)
 		);
 #endif
 
+	buf = pci_map_single(dev->pci_dev, skb->data,
+			     REAL_RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
+	if (pci_dma_mapping_error(dev->pci_dev, buf)) {
+		kfree_skb(skb);
+		return 1;
+	}
+
 	sg = dev->rx_info.descs + (next_empty * DESC_SIZE);
 	BUG_ON(NULL != dev->rx_info.skbs[next_empty]);
 	dev->rx_info.skbs[next_empty] = skb;
 
 	dev->rx_info.next_empty = (next_empty + 1) % NR_RX_DESC;
 	cmdsts = REAL_RX_BUF_SIZE | CMDSTS_INTR;
-	buf = pci_map_single(dev->pci_dev, skb->data,
-			     REAL_RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
 	build_rx_desc(dev, sg, 0, buf, cmdsts, 0);
 	/* update link of previous rx */
 	if (likely(next_empty != dev->rx_info.next_rx))
@@ -1136,6 +1141,10 @@ static netdev_tx_t ns83820_hard_start_xmit(struct sk_buff *skb,
 	if (nr_frags)
 		len -= skb->data_len;
 	buf = pci_map_single(dev->pci_dev, skb->data, len, PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(dev->pci_dev, buf)) {
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
+	}
 
 	first_desc = dev->tx_descs + (free_idx * DESC_SIZE);
 
-- 
2.7.4
