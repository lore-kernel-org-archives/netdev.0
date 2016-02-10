From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net 4/5] bnxt_en: Fix implementation of tx push operation.
Date: Wed, 10 Feb 2016 17:33:49 -0500
Message-ID: <1455143630-30140-5-git-send-email-mchan@broadcom.com>
References: <1455143630-30140-1-git-send-email-mchan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:59459
	"EHLO mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750828AbcBJWdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 17:33:51 -0500
In-Reply-To: <1455143630-30140-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tx push is supported for small packets to reduce DMA latency.  The
following bugs are fixed in this patch:

1. Fix the definition of the push BD which is different from the DMA BD.
2. The push buffer has to be zero padded to the next 64-bit word boundary
or tx checksum won't be correct.
3. Increase the tx push packet threshold to 164 bytes (192 bytes with the BD)
so that small tunneled packets are within the threshold.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 42 ++++++++++++++++++-------------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h | 11 ++++++--
 2 files changed, 34 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index ddcf7ef..82f4e6d 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -69,7 +69,7 @@ MODULE_VERSION(DRV_MODULE_VERSION);
 #define BNXT_RX_DMA_OFFSET NET_SKB_PAD
 #define BNXT_RX_COPY_THRESH 256
 
-#define BNXT_TX_PUSH_THRESH 92
+#define BNXT_TX_PUSH_THRESH 164
 
 enum board_idx {
 	BCM57301,
@@ -223,11 +223,12 @@ static netdev_tx_t bnxt_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	if (free_size == bp->tx_ring_size && length <= bp->tx_push_thresh) {
-		struct tx_push_bd *push = txr->tx_push;
-		struct tx_bd *tx_push = &push->txbd1;
-		struct tx_bd_ext *tx_push1 = &push->txbd2;
-		void *pdata = tx_push1 + 1;
-		int j;
+		struct tx_push_buffer *tx_push_buf = txr->tx_push;
+		struct tx_push_bd *tx_push = &tx_push_buf->push_bd;
+		struct tx_bd_ext *tx_push1 = &tx_push->txbd2;
+		void *pdata = tx_push_buf->data;
+		u64 *end;
+		int j, push_len;
 
 		/* Set COAL_NOW to be ready quickly for the next push */
 		tx_push->tx_bd_len_flags_type =
@@ -247,6 +248,9 @@ static netdev_tx_t bnxt_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		tx_push1->tx_bd_cfa_meta = cpu_to_le32(vlan_tag_flags);
 		tx_push1->tx_bd_cfa_action = cpu_to_le32(cfa_action);
 
+		end = PTR_ALIGN(pdata + length + 1, 8) - 1;
+		*end = 0;
+
 		skb_copy_from_linear_data(skb, pdata, len);
 		pdata += len;
 		for (j = 0; j < last_frag; j++) {
@@ -261,22 +265,29 @@ static netdev_tx_t bnxt_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			pdata += skb_frag_size(frag);
 		}
 
-		memcpy(txbd, tx_push, sizeof(*txbd));
+		txbd->tx_bd_len_flags_type = tx_push->tx_bd_len_flags_type;
+		txbd->tx_bd_haddr = txr->data_mapping;
 		prod = NEXT_TX(prod);
 		txbd = &txr->tx_desc_ring[TX_RING(prod)][TX_IDX(prod)];
 		memcpy(txbd, tx_push1, sizeof(*txbd));
 		prod = NEXT_TX(prod);
-		push->doorbell =
+		tx_push->doorbell =
 			cpu_to_le32(DB_KEY_TX_PUSH | DB_LONG_TX_PUSH | prod);
 		txr->tx_prod = prod;
 
 		netdev_tx_sent_queue(txq, skb->len);
 
-		__iowrite64_copy(txr->tx_doorbell, push,
-				 (length + sizeof(*push) + 8) / 8);
+		push_len = (length + sizeof(*tx_push) + 7) / 8;
+		if (push_len > 16) {
+			__iowrite64_copy(txr->tx_doorbell, tx_push_buf, 16);
+			__iowrite64_copy(txr->tx_doorbell + 4, tx_push_buf + 1,
+					 push_len - 16);
+		} else {
+			__iowrite64_copy(txr->tx_doorbell, tx_push_buf,
+					 push_len);
+		}
 
 		tx_buf->is_push = 1;
-
 		goto tx_done;
 	}
 
@@ -1753,7 +1764,7 @@ static int bnxt_alloc_tx_rings(struct bnxt *bp)
 		push_size  = L1_CACHE_ALIGN(sizeof(struct tx_push_bd) +
 					bp->tx_push_thresh);
 
-		if (push_size > 128) {
+		if (push_size > 256) {
 			push_size = 0;
 			bp->tx_push_thresh = 0;
 		}
@@ -1772,7 +1783,6 @@ static int bnxt_alloc_tx_rings(struct bnxt *bp)
 			return rc;
 
 		if (bp->tx_push_size) {
-			struct tx_bd *txbd;
 			dma_addr_t mapping;
 
 			/* One pre-allocated DMA buffer to backup
@@ -1786,13 +1796,11 @@ static int bnxt_alloc_tx_rings(struct bnxt *bp)
 			if (!txr->tx_push)
 				return -ENOMEM;
 
-			txbd = &txr->tx_push->txbd1;
-
 			mapping = txr->tx_push_mapping +
 				sizeof(struct tx_push_bd);
-			txbd->tx_bd_haddr = cpu_to_le64(mapping);
+			txr->data_mapping = cpu_to_le64(mapping);
 
-			memset(txbd + 1, 0, sizeof(struct tx_bd_ext));
+			memset(txr->tx_push, 0, sizeof(struct tx_push_bd));
 		}
 		ring->queue_id = bp->q_info[j].queue_id;
 		if (i % bp->tx_nr_rings_per_tc == (bp->tx_nr_rings_per_tc - 1))
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 8af3ca8..9b4866c 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -523,10 +523,16 @@ struct bnxt_ring_struct {
 
 struct tx_push_bd {
 	__le32			doorbell;
-	struct tx_bd		txbd1;
+	__le32			tx_bd_len_flags_type;
+	u32			tx_bd_opaque;
 	struct tx_bd_ext	txbd2;
 };
 
+struct tx_push_buffer {
+	struct tx_push_bd	push_bd;
+	u32			data[25];
+};
+
 struct bnxt_tx_ring_info {
 	struct bnxt_napi	*bnapi;
 	u16			tx_prod;
@@ -538,8 +544,9 @@ struct bnxt_tx_ring_info {
 
 	dma_addr_t		tx_desc_mapping[MAX_TX_PAGES];
 
-	struct tx_push_bd	*tx_push;
+	struct tx_push_buffer	*tx_push;
 	dma_addr_t		tx_push_mapping;
+	__le64			data_mapping;
 
 #define BNXT_DEV_STATE_CLOSING	0x1
 	u32			dev_state;
-- 
1.8.3.1
