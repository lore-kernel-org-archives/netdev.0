From: amit.salecha@qlogic.com
Subject: [PATCH NEXT 1/8] qlcnic: cleanup skb allocation
Date: Tue, 22 Jun 2010 06:18:58 -0700
Message-ID: <1277212745-26857-2-git-send-email-amit.salecha@qlogic.com>
References: <1277212745-26857-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:9626 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755008Ab0FVNTI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jun 2010 09:19:08 -0400
In-Reply-To: <1277212745-26857-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>

No need to maintian separate state for alloced and freed skb.
This can be done by null check.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h         |    2 --
 drivers/net/qlcnic/qlcnic_ethtool.c |    2 --
 drivers/net/qlcnic/qlcnic_init.c    |   30 +++++++++++++-----------------
 3 files changed, 13 insertions(+), 21 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 99ccdd8..86e4781 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -381,7 +381,6 @@ struct qlcnic_rx_buffer {
 	struct sk_buff *skb;
 	u64 dma;
 	u16 ref_handle;
-	u16 state;
 };
 
 /* Board types */
@@ -423,7 +422,6 @@ struct qlcnic_adapter_stats {
 	u64  xmit_on;
 	u64  xmit_off;
 	u64  skb_alloc_failure;
-	u64  null_skb;
 	u64  null_rxbuf;
 	u64  rx_dma_map_error;
 	u64  tx_dma_map_error;
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index 3e4822a..a4f1120 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -69,8 +69,6 @@ static const struct qlcnic_stats qlcnic_gstrings_stats[] = {
 		QLC_SIZEOF(stats.xmit_off), QLC_OFF(stats.xmit_off)},
 	{"skb_alloc_failure", QLC_SIZEOF(stats.skb_alloc_failure),
 		QLC_OFF(stats.skb_alloc_failure)},
-	{"null skb",
-		QLC_SIZEOF(stats.null_skb), QLC_OFF(stats.null_skb)},
 	{"null rxbuf",
 		QLC_SIZEOF(stats.null_rxbuf), QLC_OFF(stats.null_rxbuf)},
 	{"rx dma map error", QLC_SIZEOF(stats.rx_dma_map_error),
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 058ce61..1c3d5a9 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -112,14 +112,15 @@ void qlcnic_release_rx_buffers(struct qlcnic_adapter *adapter)
 		rds_ring = &recv_ctx->rds_rings[ring];
 		for (i = 0; i < rds_ring->num_desc; ++i) {
 			rx_buf = &(rds_ring->rx_buf_arr[i]);
-			if (rx_buf->state == QLCNIC_BUFFER_FREE)
+			if (rx_buf->skb == NULL)
 				continue;
+
 			pci_unmap_single(adapter->pdev,
 					rx_buf->dma,
 					rds_ring->dma_size,
 					PCI_DMA_FROMDEVICE);
-			if (rx_buf->skb != NULL)
-				dev_kfree_skb_any(rx_buf->skb);
+
+			dev_kfree_skb_any(rx_buf->skb);
 		}
 	}
 }
@@ -266,7 +267,6 @@ int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter)
 			list_add_tail(&rx_buf->list,
 					&rds_ring->free_list);
 			rx_buf->ref_handle = i;
-			rx_buf->state = QLCNIC_BUFFER_FREE;
 			rx_buf++;
 		}
 		spin_lock_init(&rds_ring->lock);
@@ -1281,14 +1281,12 @@ qlcnic_alloc_rx_skb(struct qlcnic_adapter *adapter,
 	dma_addr_t dma;
 	struct pci_dev *pdev = adapter->pdev;
 
-	buffer->skb = dev_alloc_skb(rds_ring->skb_size);
-	if (!buffer->skb) {
+	skb = dev_alloc_skb(rds_ring->skb_size);
+	if (!skb) {
 		adapter->stats.skb_alloc_failure++;
 		return -ENOMEM;
 	}
 
-	skb = buffer->skb;
-
 	skb_reserve(skb, 2);
 
 	dma = pci_map_single(pdev, skb->data,
@@ -1297,13 +1295,11 @@ qlcnic_alloc_rx_skb(struct qlcnic_adapter *adapter,
 	if (pci_dma_mapping_error(pdev, dma)) {
 		adapter->stats.rx_dma_map_error++;
 		dev_kfree_skb_any(skb);
-		buffer->skb = NULL;
 		return -ENOMEM;
 	}
 
 	buffer->skb = skb;
 	buffer->dma = dma;
-	buffer->state = QLCNIC_BUFFER_BUSY;
 
 	return 0;
 }
@@ -1316,14 +1312,15 @@ static struct sk_buff *qlcnic_process_rxbuf(struct qlcnic_adapter *adapter,
 
 	buffer = &rds_ring->rx_buf_arr[index];
 
+	if (unlikely(buffer->skb == NULL)) {
+		WARN_ON(1);
+		return NULL;
+	}
+
 	pci_unmap_single(adapter->pdev, buffer->dma, rds_ring->dma_size,
 			PCI_DMA_FROMDEVICE);
 
 	skb = buffer->skb;
-	if (!skb) {
-		adapter->stats.null_skb++;
-		goto no_skb;
-	}
 
 	if (likely(adapter->rx_csum && cksum == STATUS_CKSUM_OK)) {
 		adapter->stats.csummed++;
@@ -1335,8 +1332,7 @@ static struct sk_buff *qlcnic_process_rxbuf(struct qlcnic_adapter *adapter,
 	skb->dev = adapter->netdev;
 
 	buffer->skb = NULL;
-no_skb:
-	buffer->state = QLCNIC_BUFFER_FREE;
+
 	return skb;
 }
 
@@ -1511,7 +1507,7 @@ qlcnic_process_rcv_ring(struct qlcnic_host_sds_ring *sds_ring, int max)
 
 		WARN_ON(desc_cnt > 1);
 
-		if (rxbuf)
+		if (likely(rxbuf))
 			list_add_tail(&rxbuf->list, &sds_ring->free_list[ring]);
 		else
 			adapter->stats.null_rxbuf++;
-- 
1.6.0.2

