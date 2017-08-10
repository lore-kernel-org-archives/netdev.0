From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH v3 net-next 1/2] wan: dscc4: add checks for dma mapping errors
Date: Fri, 11 Aug 2017 01:55:20 +0300
Message-ID: <1502405721-27738-1-git-send-email-khoroshilov@ispras.ru>
References: <20170808232147.GA27445@electric-eye.fr.zoreil.com>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Francois Romieu <romieu@fr.zoreil.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170808232147.GA27445@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver does not check if mapping dma memory succeed.
The patch adds the checks and failure handling.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
v2: Fix issues noted by David Miller and Francois Romieu.
v3: Improve code per Francois Romieu recommendations.
    Convert to plain DMA API.

 drivers/net/wan/dscc4.c | 53 ++++++++++++++++++++++++++++++++++---------------
 1 file changed, 37 insertions(+), 16 deletions(-)

diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index 799830f..8480dbf 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -519,22 +519,30 @@ static inline int try_get_rx_skb(struct dscc4_dev_priv *dpriv,
 				 struct net_device *dev)
 {
 	unsigned int dirty = dpriv->rx_dirty%RX_RING_SIZE;
+	struct pci_dev *pdev = dpriv->pci_priv->pdev;
 	struct RxFD *rx_fd = dpriv->rx_fd + dirty;
 	const int len = RX_MAX(HDLC_MAX_MRU);
 	struct sk_buff *skb;
-	int ret = 0;
+	dma_addr_t addr;
 
 	skb = dev_alloc_skb(len);
+	if (!skb)
+		goto err_out;
+
+	skb->protocol = hdlc_type_trans(skb, dev);
+	addr = pci_map_single(pdev, skb->data, len, PCI_DMA_FROMDEVICE);
+	if (pci_dma_mapping_error(pdev, addr))
+		goto err_free_skb;
+
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
@@ -1145,16 +1153,23 @@ static netdev_tx_t dscc4_start_xmit(struct sk_buff *skb,
 					  struct net_device *dev)
 {
 	struct dscc4_dev_priv *dpriv = dscc4_priv(dev);
-	struct dscc4_pci_priv *ppriv = dpriv->pci_priv;
+	struct pci_dev *pdev = dpriv->pci_priv->pdev;
 	struct TxFD *tx_fd;
+	dma_addr_t addr;
 	int next;
 
+	addr = pci_map_single(pdev, skb->data, skb->len, PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(pdev, addr)) {
+		dev_kfree_skb_any(skb);
+		dev->stats.tx_dropped++;
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
@@ -1887,16 +1902,22 @@ static struct sk_buff *dscc4_init_dummy_skb(struct dscc4_dev_priv *dpriv)
 
 	skb = dev_alloc_skb(DUMMY_SKB_SIZE);
 	if (skb) {
+		struct pci_dev *pdev = dpriv->pci_priv->pdev;
 		int last = dpriv->tx_dirty%TX_RING_SIZE;
 		struct TxFD *tx_fd = dpriv->tx_fd + last;
+		dma_addr_t addr;
 
 		skb->len = DUMMY_SKB_SIZE;
 		skb_copy_to_linear_data(skb, version,
 					strlen(version) % DUMMY_SKB_SIZE);
+		addr = pci_map_single(pdev, skb->data, DUMMY_SKB_SIZE,
+				      PCI_DMA_TODEVICE);
+		if (pci_dma_mapping_error(pdev, addr)) {
+			dev_kfree_skb_any(skb);
+			return NULL;
+		}
 		tx_fd->state = FrameEnd | TO_STATE_TX(DUMMY_SKB_SIZE);
-		tx_fd->data = cpu_to_le32(pci_map_single(dpriv->pci_priv->pdev,
-					     skb->data, DUMMY_SKB_SIZE,
-					     PCI_DMA_TODEVICE));
+		tx_fd->data = cpu_to_le32(addr);
 		dpriv->tx_skbuff[last] = skb;
 	}
 	return skb;
-- 
2.7.4
