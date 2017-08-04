From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] wan: dscc4: add checks for dma mapping errors
Date: Fri,  4 Aug 2017 23:23:24 +0300
Message-ID: <1501878204-24270-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver does not check if mapping dma memory succeed.
The patch adds the checks and failure handling.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/wan/dscc4.c | 52 +++++++++++++++++++++++++++++++++++--------------
 1 file changed, 37 insertions(+), 15 deletions(-)

diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index 799830ffcae2..1a94f0a95b2c 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -522,19 +522,27 @@ static inline int try_get_rx_skb(struct dscc4_dev_priv *dpriv,
 	struct RxFD *rx_fd = dpriv->rx_fd + dirty;
 	const int len = RX_MAX(HDLC_MAX_MRU);
 	struct sk_buff *skb;
-	int ret = 0;
+	dma_addr_t addr;
 
 	skb = dev_alloc_skb(len);
 	dpriv->rx_skbuff[dirty] = skb;
-	if (skb) {
-		skb->protocol = hdlc_type_trans(skb, dev);
-		rx_fd->data = cpu_to_le32(pci_map_single(dpriv->pci_priv->pdev,
-					  skb->data, len, PCI_DMA_FROMDEVICE));
-	} else {
-		rx_fd->data = 0;
-		ret = -1;
-	}
-	return ret;
+	if (!skb)
+		goto err_out;
+
+	skb->protocol = hdlc_type_trans(skb, dev);
+	addr = pci_map_single(dpriv->pci_priv->pdev,
+			      skb->data, len, PCI_DMA_FROMDEVICE);
+	if (pci_dma_mapping_error(dpriv->pci_priv->pdev, addr))
+		goto err_free_skb;
+
+	rx_fd->data = cpu_to_le32(addr);
+	return 0;
+
+err_free_skb:
+	dev_kfree_skb_any(skb);
+err_out:
+	rx_fd->data = 0;
+	return -1;
 }
 
 /*
@@ -1147,14 +1155,22 @@ static netdev_tx_t dscc4_start_xmit(struct sk_buff *skb,
 	struct dscc4_dev_priv *dpriv = dscc4_priv(dev);
 	struct dscc4_pci_priv *ppriv = dpriv->pci_priv;
 	struct TxFD *tx_fd;
+	dma_addr_t addr;
 	int next;
 
+	addr = pci_map_single(ppriv->pdev, skb->data, skb->len,
+			      PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(ppriv->pdev, addr)) {
+		dev_kfree_skb_any(skb);
+		dev->stats.tx_errors++;
+		return NETDEV_TX_OK;
+	}
+
 	next = dpriv->tx_current%TX_RING_SIZE;
 	dpriv->tx_skbuff[next] = skb;
 	tx_fd = dpriv->tx_fd + next;
 	tx_fd->state = FrameEnd | TO_STATE_TX(skb->len);
-	tx_fd->data = cpu_to_le32(pci_map_single(ppriv->pdev, skb->data, skb->len,
-				     PCI_DMA_TODEVICE));
+	tx_fd->data = cpu_to_le32(addr);
 	tx_fd->complete = 0x00000000;
 	tx_fd->jiffies = jiffies;
 	mb();
@@ -1889,14 +1905,20 @@ static struct sk_buff *dscc4_init_dummy_skb(struct dscc4_dev_priv *dpriv)
 	if (skb) {
 		int last = dpriv->tx_dirty%TX_RING_SIZE;
 		struct TxFD *tx_fd = dpriv->tx_fd + last;
+		dma_addr_t addr;
 
 		skb->len = DUMMY_SKB_SIZE;
 		skb_copy_to_linear_data(skb, version,
 					strlen(version) % DUMMY_SKB_SIZE);
 		tx_fd->state = FrameEnd | TO_STATE_TX(DUMMY_SKB_SIZE);
-		tx_fd->data = cpu_to_le32(pci_map_single(dpriv->pci_priv->pdev,
-					     skb->data, DUMMY_SKB_SIZE,
-					     PCI_DMA_TODEVICE));
+		addr = pci_map_single(dpriv->pci_priv->pdev,
+				      skb->data, DUMMY_SKB_SIZE,
+				      PCI_DMA_TODEVICE);
+		if (pci_dma_mapping_error(dpriv->pci_priv->pdev, addr)) {
+			dev_kfree_skb_any(skb);
+			return NULL;
+		}
+		tx_fd->data = cpu_to_le32(addr);
 		dpriv->tx_skbuff[last] = skb;
 	}
 	return skb;
-- 
2.7.4
