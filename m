From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/3] e1000: ethtool: Add missing dma_mapping_error-call in e1000_setup_desc_rings
Date: Wed, 27 Mar 2013 04:05:31 -0700
Message-ID: <1364382333-14721-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1364382333-14721-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Christoph Paasch <christoph.paasch@uclouvain.be>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:8713 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751950Ab3C0LFn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 07:05:43 -0400
In-Reply-To: <1364382333-14721-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>

After dma_map_single, dma_mapping_error must be called.

Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
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
1.7.11.7
