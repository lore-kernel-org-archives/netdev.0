From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] ipw2x00: add checks for dma mapping errors
Date: Sat,  2 Jan 2016 02:12:38 +0300
Message-ID: <1451689958-8005-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Stanislav Yakovlev <stas.yakovlev@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ispras.ru ([83.149.199.45]:34831 "EHLO mail.ispras.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751354AbcAAXMu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jan 2016 18:12:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipw2100_alloc_skb() and ipw2100_tx_send_data() do not check if mapping
dma memory succeed. The patch adds the checks and failure handling.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/wireless/ipw2x00/ipw2100.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index 36818c7f30b9..f93a7f71c047 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -2311,8 +2311,10 @@ static int ipw2100_alloc_skb(struct ipw2100_priv *priv,
 	packet->dma_addr = pci_map_single(priv->pci_dev, packet->skb->data,
 					  sizeof(struct ipw2100_rx),
 					  PCI_DMA_FROMDEVICE);
-	/* NOTE: pci_map_single does not return an error code, and 0 is a valid
-	 *       dma_addr */
+	if (pci_dma_mapping_error(priv->pci_dev, packet->dma_addr)) {
+		dev_kfree_skb(packet->skb);
+		return -ENOMEM;
+	}
 
 	return 0;
 }
@@ -3183,6 +3185,11 @@ static void ipw2100_tx_send_data(struct ipw2100_priv *priv)
 							LIBIPW_3ADDR_LEN,
 							tbd->buf_length,
 							PCI_DMA_TODEVICE);
+			if (pci_dma_mapping_error(priv->pci_dev,
+						  tbd->host_addr)) {
+				IPW_DEBUG_TX("dma mapping error\n");
+				break;
+			}
 
 			IPW_DEBUG_TX("data frag tbd TX%d P=%08x L=%d\n",
 				     txq->next, tbd->host_addr,
-- 
1.9.1
