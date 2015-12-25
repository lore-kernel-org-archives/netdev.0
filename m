From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] prism54: fix checks for dma mapping errors
Date: Sat, 26 Dec 2015 01:42:41 +0300
Message-ID: <1451083361-13141-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	"John W . Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: "Luis R. Rodriguez" <mcgrof@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ispras.ru ([83.149.199.45]:59968 "EHLO mail.ispras.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753788AbbLYWnK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Dec 2015 17:43:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

prism54 checks for dma mapping errors by comparison returned address
with zero, while pci_dma_mapping_error() should be used.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/wireless/prism54/islpci_dev.c | 4 +++-
 drivers/net/wireless/prism54/islpci_eth.c | 5 +++--
 drivers/net/wireless/prism54/islpci_mgt.c | 4 ++--
 3 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/prism54/islpci_dev.c b/drivers/net/wireless/prism54/islpci_dev.c
index 931cf440ff18..84a42012aeae 100644
--- a/drivers/net/wireless/prism54/islpci_dev.c
+++ b/drivers/net/wireless/prism54/islpci_dev.c
@@ -707,7 +707,9 @@ islpci_alloc_memory(islpci_private *priv)
 		    pci_map_single(priv->pdev, (void *) skb->data,
 				   MAX_FRAGMENT_SIZE_RX + 2,
 				   PCI_DMA_FROMDEVICE);
-		if (!priv->pci_map_rx_address[counter]) {
+		if (pci_dma_mapping_error(priv->pdev,
+					  priv->pci_map_rx_address[counter])) {
+			priv->pci_map_rx_address[counter] = 0;
 			/* error mapping the buffer to device
 			   accessible memory address */
 			printk(KERN_ERR "failed to map skb DMA'able\n");
diff --git a/drivers/net/wireless/prism54/islpci_eth.c b/drivers/net/wireless/prism54/islpci_eth.c
index 674658f2e6ef..d83f6332019e 100644
--- a/drivers/net/wireless/prism54/islpci_eth.c
+++ b/drivers/net/wireless/prism54/islpci_eth.c
@@ -190,7 +190,7 @@ islpci_eth_transmit(struct sk_buff *skb, struct net_device *ndev)
 	pci_map_address = pci_map_single(priv->pdev,
 					 (void *) skb->data, skb->len,
 					 PCI_DMA_TODEVICE);
-	if (unlikely(pci_map_address == 0)) {
+	if (pci_dma_mapping_error(priv->pdev, pci_map_address)) {
 		printk(KERN_WARNING "%s: cannot map buffer to PCI\n",
 		       ndev->name);
 		goto drop_free;
@@ -448,7 +448,8 @@ islpci_eth_receive(islpci_private *priv)
 		    pci_map_single(priv->pdev, (void *) skb->data,
 				   MAX_FRAGMENT_SIZE_RX + 2,
 				   PCI_DMA_FROMDEVICE);
-		if (unlikely(!priv->pci_map_rx_address[index])) {
+		if (pci_dma_mapping_error(priv->pdev,
+					  priv->pci_map_rx_address[index])) {
 			/* error mapping the buffer to device accessible memory address */
 			DEBUG(SHOW_ERROR_MESSAGES,
 			      "Error mapping DMA address\n");
diff --git a/drivers/net/wireless/prism54/islpci_mgt.c b/drivers/net/wireless/prism54/islpci_mgt.c
index 0de14dfa68cc..53d7a1705e8e 100644
--- a/drivers/net/wireless/prism54/islpci_mgt.c
+++ b/drivers/net/wireless/prism54/islpci_mgt.c
@@ -130,7 +130,7 @@ islpci_mgmt_rx_fill(struct net_device *ndev)
 			buf->pci_addr = pci_map_single(priv->pdev, buf->mem,
 						       MGMT_FRAME_SIZE,
 						       PCI_DMA_FROMDEVICE);
-			if (!buf->pci_addr) {
+			if (pci_dma_mapping_error(priv->pdev, buf->pci_addr)) {
 				printk(KERN_WARNING
 				       "Failed to make memory DMA'able.\n");
 				return -ENOMEM;
@@ -217,7 +217,7 @@ islpci_mgt_transmit(struct net_device *ndev, int operation, unsigned long oid,
 	err = -ENOMEM;
 	buf.pci_addr = pci_map_single(priv->pdev, buf.mem, frag_len,
 				      PCI_DMA_TODEVICE);
-	if (!buf.pci_addr) {
+	if (pci_dma_mapping_error(priv->pdev, buf.pci_addr)) {
 		printk(KERN_WARNING "%s: cannot map PCI memory for mgmt\n",
 		       ndev->name);
 		goto error_free;
-- 
1.9.1
