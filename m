From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH 1/3] e1000: ethtool: Add missing dma_mapping_error-call in e1000_setup_desc_rings
Date: Sat, 16 Mar 2013 11:32:03 +0100
Message-ID: <1363429925-12724-2-git-send-email-christoph.paasch@uclouvain.be>
References: <1363429925-12724-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:51915 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755587Ab3CPKcQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Mar 2013 06:32:16 -0400
In-Reply-To: <1363429925-12724-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After dma_map_single, dma_mapping_error must be called.

Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 drivers/net/ethernet/intel/e1000/e1000_ethtool.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
index 43462d5..ffd2871 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
@@ -1053,6 +1053,10 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 		txdr->buffer_info[i].dma =
 			dma_map_single(&pdev->dev, skb->data, skb->len,
 				       DMA_TO_DEVICE);
+		if (dma_mapping_error(&pdev->dev, txdr->buffer_info[i].dma)) {
+			ret_val = 4;
+			goto err_nomem;
+		}
 		tx_desc->buffer_addr = cpu_to_le64(txdr->buffer_info[i].dma);
 		tx_desc->lower.data = cpu_to_le32(skb->len);
 		tx_desc->lower.data |= cpu_to_le32(E1000_TXD_CMD_EOP |
@@ -1069,7 +1073,7 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	rxdr->buffer_info = kcalloc(rxdr->count, sizeof(struct e1000_buffer),
 				    GFP_KERNEL);
 	if (!rxdr->buffer_info) {
-		ret_val = 4;
+		ret_val = 5;
 		goto err_nomem;
 	}
 
@@ -1077,7 +1081,7 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	rxdr->desc = dma_alloc_coherent(&pdev->dev, rxdr->size, &rxdr->dma,
 					GFP_KERNEL);
 	if (!rxdr->desc) {
-		ret_val = 5;
+		ret_val = 6;
 		goto err_nomem;
 	}
 	memset(rxdr->desc, 0, rxdr->size);
@@ -1101,7 +1105,7 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 
 		skb = alloc_skb(E1000_RXBUFFER_2048 + NET_IP_ALIGN, GFP_KERNEL);
 		if (!skb) {
-			ret_val = 6;
+			ret_val = 7;
 			goto err_nomem;
 		}
 		skb_reserve(skb, NET_IP_ALIGN);
@@ -1110,6 +1114,10 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 		rxdr->buffer_info[i].dma =
 			dma_map_single(&pdev->dev, skb->data,
 				       E1000_RXBUFFER_2048, DMA_FROM_DEVICE);
+		if (dma_mapping_error(&pdev->dev, rxdr->buffer_info[i].dma)) {
+			ret_val = 8;
+			goto err_nomem;
+		}
 		rx_desc->buffer_addr = cpu_to_le64(rxdr->buffer_info[i].dma);
 		memset(skb->data, 0x00, skb->len);
 	}
-- 
1.8.1.227.g44fe835
