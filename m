From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 2/7] bnxt_en: Separate bnxt_{rx|tx}_ring_info structs from bnxt_napi struct.
Date: Sat, 2 Jan 2016 23:44:59 -0500
Message-ID: <1451796304-23220-3-git-send-email-mchan@broadcom.com>
References: <1451796304-23220-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:52177 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751047AbcACEpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jan 2016 23:45:07 -0500
In-Reply-To: <1451796304-23220-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, an rx and a tx ring are always paired with a completion ring.
We want to restructure it so that it is possible to have a dedicated
completion ring for tx or rx only.

The bnxt hardware uses a completion ring for rx and tx events.  The driver
has to process the completion ring entries sequentially for the rx and tx
events.  Using a dedicated completion ring for rx only or tx only has these
benefits:

1. A burst of rx packets can cause delay in processing tx events if the
completion ring is shared.  If tx queue is stopped by BQL, this can cause
delay in re-starting the tx queue.

2. A completion ring is sized according to the rx and tx ring size rounded
up to the nearest power of 2.  When the completion ring is shared, it is
sized by adding the rx and tx ring sizes and then rounded to the next power
of 2, often with a lot of wasted space.

3. Using dedicated completion ring, we can adjust the tx and rx coalescing
parameters independently for rx and tx.

The first step is to separate the rx and tx ring structures from the
bnxt_napi struct.

In this patch, an rx ring and a tx ring will point to the same bnxt_napi
struct to share the same completion ring.  No change in ring assignment
and mapping yet.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 147 +++++++++++++-----------------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |   9 +-
 2 files changed, 70 insertions(+), 86 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 3f053de..8635e03 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -179,7 +179,6 @@ static netdev_tx_t bnxt_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	u32 len, free_size, vlan_tag_flags, cfa_action, flags;
 	u16 prod, last_frag;
 	struct pci_dev *pdev = bp->pdev;
-	struct bnxt_napi *bnapi;
 	struct bnxt_tx_ring_info *txr;
 	struct bnxt_sw_tx_bd *tx_buf;
 
@@ -189,8 +188,7 @@ static netdev_tx_t bnxt_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_OK;
 	}
 
-	bnapi = bp->bnapi[i];
-	txr = &bnapi->tx_ring;
+	txr = &bp->tx_ring[i];
 	txq = netdev_get_tx_queue(dev, i);
 	prod = txr->tx_prod;
 
@@ -423,7 +421,7 @@ tx_dma_error:
 
 static void bnxt_tx_int(struct bnxt *bp, struct bnxt_napi *bnapi, int nr_pkts)
 {
-	struct bnxt_tx_ring_info *txr = &bnapi->tx_ring;
+	struct bnxt_tx_ring_info *txr = bnapi->tx_ring;
 	int index = bnapi->index;
 	struct netdev_queue *txq = netdev_get_tx_queue(bp->dev, index);
 	u16 cons = txr->tx_cons;
@@ -602,7 +600,7 @@ static void bnxt_reuse_rx_agg_bufs(struct bnxt_napi *bnapi, u16 cp_cons,
 {
 	struct bnxt *bp = bnapi->bp;
 	struct bnxt_cp_ring_info *cpr = &bnapi->cp_ring;
-	struct bnxt_rx_ring_info *rxr = &bnapi->rx_ring;
+	struct bnxt_rx_ring_info *rxr = bnapi->rx_ring;
 	u16 prod = rxr->rx_agg_prod;
 	u16 sw_prod = rxr->rx_sw_agg_prod;
 	u32 i;
@@ -681,7 +679,7 @@ static struct sk_buff *bnxt_rx_pages(struct bnxt *bp, struct bnxt_napi *bnapi,
 {
 	struct pci_dev *pdev = bp->pdev;
 	struct bnxt_cp_ring_info *cpr = &bnapi->cp_ring;
-	struct bnxt_rx_ring_info *rxr = &bnapi->rx_ring;
+	struct bnxt_rx_ring_info *rxr = bnapi->rx_ring;
 	u16 prod = rxr->rx_agg_prod;
 	u32 i;
 
@@ -940,7 +938,7 @@ static inline struct sk_buff *bnxt_tpa_end(struct bnxt *bp,
 					   bool *agg_event)
 {
 	struct bnxt_cp_ring_info *cpr = &bnapi->cp_ring;
-	struct bnxt_rx_ring_info *rxr = &bnapi->rx_ring;
+	struct bnxt_rx_ring_info *rxr = bnapi->rx_ring;
 	u8 agg_id = TPA_END_AGG_ID(tpa_end);
 	u8 *data, agg_bufs;
 	u16 cp_cons = RING_CMP(*raw_cons);
@@ -1056,7 +1054,7 @@ static int bnxt_rx_pkt(struct bnxt *bp, struct bnxt_napi *bnapi, u32 *raw_cons,
 		       bool *agg_event)
 {
 	struct bnxt_cp_ring_info *cpr = &bnapi->cp_ring;
-	struct bnxt_rx_ring_info *rxr = &bnapi->rx_ring;
+	struct bnxt_rx_ring_info *rxr = bnapi->rx_ring;
 	struct net_device *dev = bp->dev;
 	struct rx_cmp *rxcmp;
 	struct rx_cmp_ext *rxcmp1;
@@ -1390,7 +1388,7 @@ static int bnxt_poll_work(struct bnxt *bp, struct bnxt_napi *bnapi, int budget)
 		bnxt_tx_int(bp, bnapi, tx_pkts);
 
 	if (rx_event) {
-		struct bnxt_rx_ring_info *rxr = &bnapi->rx_ring;
+		struct bnxt_rx_ring_info *rxr = bnapi->rx_ring;
 
 		writel(DB_KEY_RX | rxr->rx_prod, rxr->rx_doorbell);
 		writel(DB_KEY_RX | rxr->rx_prod, rxr->rx_doorbell);
@@ -1459,19 +1457,14 @@ static void bnxt_free_tx_skbs(struct bnxt *bp)
 	int i, max_idx;
 	struct pci_dev *pdev = bp->pdev;
 
-	if (!bp->bnapi)
+	if (!bp->tx_ring)
 		return;
 
 	max_idx = bp->tx_nr_pages * TX_DESC_CNT;
 	for (i = 0; i < bp->tx_nr_rings; i++) {
-		struct bnxt_napi *bnapi = bp->bnapi[i];
-		struct bnxt_tx_ring_info *txr;
+		struct bnxt_tx_ring_info *txr = &bp->tx_ring[i];
 		int j;
 
-		if (!bnapi)
-			continue;
-
-		txr = &bnapi->tx_ring;
 		for (j = 0; j < max_idx;) {
 			struct bnxt_sw_tx_bd *tx_buf = &txr->tx_buf_ring[j];
 			struct sk_buff *skb = tx_buf->skb;
@@ -1517,21 +1510,15 @@ static void bnxt_free_rx_skbs(struct bnxt *bp)
 	int i, max_idx, max_agg_idx;
 	struct pci_dev *pdev = bp->pdev;
 
-	if (!bp->bnapi)
+	if (!bp->rx_ring)
 		return;
 
 	max_idx = bp->rx_nr_pages * RX_DESC_CNT;
 	max_agg_idx = bp->rx_agg_nr_pages * RX_DESC_CNT;
 	for (i = 0; i < bp->rx_nr_rings; i++) {
-		struct bnxt_napi *bnapi = bp->bnapi[i];
-		struct bnxt_rx_ring_info *rxr;
+		struct bnxt_rx_ring_info *rxr = &bp->rx_ring[i];
 		int j;
 
-		if (!bnapi)
-			continue;
-
-		rxr = &bnapi->rx_ring;
-
 		if (rxr->rx_tpa) {
 			for (j = 0; j < MAX_TPA; j++) {
 				struct bnxt_tpa_info *tpa_info =
@@ -1659,19 +1646,13 @@ static void bnxt_free_rx_rings(struct bnxt *bp)
 {
 	int i;
 
-	if (!bp->bnapi)
+	if (!bp->rx_ring)
 		return;
 
 	for (i = 0; i < bp->rx_nr_rings; i++) {
-		struct bnxt_napi *bnapi = bp->bnapi[i];
-		struct bnxt_rx_ring_info *rxr;
+		struct bnxt_rx_ring_info *rxr = &bp->rx_ring[i];
 		struct bnxt_ring_struct *ring;
 
-		if (!bnapi)
-			continue;
-
-		rxr = &bnapi->rx_ring;
-
 		kfree(rxr->rx_tpa);
 		rxr->rx_tpa = NULL;
 
@@ -1690,6 +1671,9 @@ static int bnxt_alloc_rx_rings(struct bnxt *bp)
 {
 	int i, rc, agg_rings = 0, tpa_rings = 0;
 
+	if (!bp->rx_ring)
+		return -ENOMEM;
+
 	if (bp->flags & BNXT_FLAG_AGG_RINGS)
 		agg_rings = 1;
 
@@ -1697,14 +1681,9 @@ static int bnxt_alloc_rx_rings(struct bnxt *bp)
 		tpa_rings = 1;
 
 	for (i = 0; i < bp->rx_nr_rings; i++) {
-		struct bnxt_napi *bnapi = bp->bnapi[i];
-		struct bnxt_rx_ring_info *rxr;
+		struct bnxt_rx_ring_info *rxr = &bp->rx_ring[i];
 		struct bnxt_ring_struct *ring;
 
-		if (!bnapi)
-			continue;
-
-		rxr = &bnapi->rx_ring;
 		ring = &rxr->rx_ring_struct;
 
 		rc = bnxt_alloc_ring(bp, ring);
@@ -1742,19 +1721,13 @@ static void bnxt_free_tx_rings(struct bnxt *bp)
 	int i;
 	struct pci_dev *pdev = bp->pdev;
 
-	if (!bp->bnapi)
+	if (!bp->tx_ring)
 		return;
 
 	for (i = 0; i < bp->tx_nr_rings; i++) {
-		struct bnxt_napi *bnapi = bp->bnapi[i];
-		struct bnxt_tx_ring_info *txr;
+		struct bnxt_tx_ring_info *txr = &bp->tx_ring[i];
 		struct bnxt_ring_struct *ring;
 
-		if (!bnapi)
-			continue;
-
-		txr = &bnapi->tx_ring;
-
 		if (txr->tx_push) {
 			dma_free_coherent(&pdev->dev, bp->tx_push_size,
 					  txr->tx_push, txr->tx_push_mapping);
@@ -1788,14 +1761,9 @@ static int bnxt_alloc_tx_rings(struct bnxt *bp)
 	}
 
 	for (i = 0, j = 0; i < bp->tx_nr_rings; i++) {
-		struct bnxt_napi *bnapi = bp->bnapi[i];
-		struct bnxt_tx_ring_info *txr;
+		struct bnxt_tx_ring_info *txr = &bp->tx_ring[i];
 		struct bnxt_ring_struct *ring;
 
-		if (!bnapi)
-			continue;
-
-		txr = &bnapi->tx_ring;
 		ring = &txr->tx_ring_struct;
 
 		rc = bnxt_alloc_ring(bp, ring);
@@ -1898,7 +1866,7 @@ static void bnxt_init_ring_struct(struct bnxt *bp)
 		ring->dma_arr = cpr->cp_desc_mapping;
 		ring->vmem_size = 0;
 
-		rxr = &bnapi->rx_ring;
+		rxr = bnapi->rx_ring;
 		ring = &rxr->rx_ring_struct;
 		ring->nr_pages = bp->rx_nr_pages;
 		ring->page_size = HW_RXBD_RING_SIZE;
@@ -1915,7 +1883,7 @@ static void bnxt_init_ring_struct(struct bnxt *bp)
 		ring->vmem_size = SW_RXBD_AGG_RING_SIZE * bp->rx_agg_nr_pages;
 		ring->vmem = (void **)&rxr->rx_agg_ring;
 
-		txr = &bnapi->tx_ring;
+		txr = bnapi->tx_ring;
 		ring = &txr->tx_ring_struct;
 		ring->nr_pages = bp->tx_nr_pages;
 		ring->page_size = HW_RXBD_RING_SIZE;
@@ -1951,22 +1919,18 @@ static void bnxt_init_rxbd_pages(struct bnxt_ring_struct *ring, u32 type)
 static int bnxt_init_one_rx_ring(struct bnxt *bp, int ring_nr)
 {
 	struct net_device *dev = bp->dev;
-	struct bnxt_napi *bnapi = bp->bnapi[ring_nr];
 	struct bnxt_rx_ring_info *rxr;
 	struct bnxt_ring_struct *ring;
 	u32 prod, type;
 	int i;
 
-	if (!bnapi)
-		return -EINVAL;
-
 	type = (bp->rx_buf_use_size << RX_BD_LEN_SHIFT) |
 		RX_BD_TYPE_RX_PACKET_BD | RX_BD_FLAGS_EOP;
 
 	if (NET_IP_ALIGN == 2)
 		type |= RX_BD_FLAGS_SOP;
 
-	rxr = &bnapi->rx_ring;
+	rxr = &bp->rx_ring[ring_nr];
 	ring = &rxr->rx_ring_struct;
 	bnxt_init_rxbd_pages(ring, type);
 
@@ -2048,8 +2012,7 @@ static int bnxt_init_tx_rings(struct bnxt *bp)
 				   MAX_SKB_FRAGS + 1);
 
 	for (i = 0; i < bp->tx_nr_rings; i++) {
-		struct bnxt_napi *bnapi = bp->bnapi[i];
-		struct bnxt_tx_ring_info *txr = &bnapi->tx_ring;
+		struct bnxt_tx_ring_info *txr = &bp->tx_ring[i];
 		struct bnxt_ring_struct *ring = &txr->tx_ring_struct;
 
 		ring->fw_ring_id = INVALID_HW_RING_ID;
@@ -2436,11 +2399,11 @@ static void bnxt_clear_ring_indices(struct bnxt *bp)
 		cpr = &bnapi->cp_ring;
 		cpr->cp_raw_cons = 0;
 
-		txr = &bnapi->tx_ring;
+		txr = bnapi->tx_ring;
 		txr->tx_prod = 0;
 		txr->tx_cons = 0;
 
-		rxr = &bnapi->rx_ring;
+		rxr = bnapi->rx_ring;
 		rxr->rx_prod = 0;
 		rxr->rx_agg_prod = 0;
 		rxr->rx_sw_agg_prod = 0;
@@ -2509,6 +2472,10 @@ static void bnxt_free_mem(struct bnxt *bp, bool irq_re_init)
 		bnxt_free_stats(bp);
 		bnxt_free_ring_grps(bp);
 		bnxt_free_vnics(bp);
+		kfree(bp->tx_ring);
+		bp->tx_ring = NULL;
+		kfree(bp->rx_ring);
+		bp->rx_ring = NULL;
 		kfree(bp->bnapi);
 		bp->bnapi = NULL;
 	} else {
@@ -2540,6 +2507,28 @@ static int bnxt_alloc_mem(struct bnxt *bp, bool irq_re_init)
 			bp->bnapi[i]->bp = bp;
 		}
 
+		bp->rx_ring = kcalloc(bp->rx_nr_rings,
+				      sizeof(struct bnxt_rx_ring_info),
+				      GFP_KERNEL);
+		if (!bp->rx_ring)
+			return -ENOMEM;
+
+		for (i = 0; i < bp->rx_nr_rings; i++) {
+			bp->rx_ring[i].bnapi = bp->bnapi[i];
+			bp->bnapi[i]->rx_ring = &bp->rx_ring[i];
+		}
+
+		bp->tx_ring = kcalloc(bp->tx_nr_rings,
+				      sizeof(struct bnxt_tx_ring_info),
+				      GFP_KERNEL);
+		if (!bp->tx_ring)
+			return -ENOMEM;
+
+		for (i = 0; i < bp->tx_nr_rings; i++) {
+			bp->tx_ring[i].bnapi = bp->bnapi[i];
+			bp->bnapi[i]->tx_ring = &bp->tx_ring[i];
+		}
+
 		rc = bnxt_alloc_stats(bp);
 		if (rc)
 			goto alloc_mem_err;
@@ -3332,8 +3321,7 @@ static int bnxt_hwrm_ring_alloc(struct bnxt *bp)
 	}
 
 	for (i = 0; i < bp->tx_nr_rings; i++) {
-		struct bnxt_napi *bnapi = bp->bnapi[i];
-		struct bnxt_tx_ring_info *txr = &bnapi->tx_ring;
+		struct bnxt_tx_ring_info *txr = &bp->tx_ring[i];
 		struct bnxt_ring_struct *ring = &txr->tx_ring_struct;
 		u16 fw_stats_ctx = bp->grp_info[i].fw_stats_ctx;
 
@@ -3345,8 +3333,7 @@ static int bnxt_hwrm_ring_alloc(struct bnxt *bp)
 	}
 
 	for (i = 0; i < bp->rx_nr_rings; i++) {
-		struct bnxt_napi *bnapi = bp->bnapi[i];
-		struct bnxt_rx_ring_info *rxr = &bnapi->rx_ring;
+		struct bnxt_rx_ring_info *rxr = &bp->rx_ring[i];
 		struct bnxt_ring_struct *ring = &rxr->rx_ring_struct;
 
 		rc = hwrm_ring_alloc_send_msg(bp, ring, HWRM_RING_ALLOC_RX, i,
@@ -3360,8 +3347,7 @@ static int bnxt_hwrm_ring_alloc(struct bnxt *bp)
 
 	if (bp->flags & BNXT_FLAG_AGG_RINGS) {
 		for (i = 0; i < bp->rx_nr_rings; i++) {
-			struct bnxt_napi *bnapi = bp->bnapi[i];
-			struct bnxt_rx_ring_info *rxr = &bnapi->rx_ring;
+			struct bnxt_rx_ring_info *rxr = &bp->rx_ring[i];
 			struct bnxt_ring_struct *ring =
 						&rxr->rx_agg_ring_struct;
 
@@ -3431,8 +3417,7 @@ static void bnxt_hwrm_ring_free(struct bnxt *bp, bool close_path)
 		return;
 
 	for (i = 0; i < bp->tx_nr_rings; i++) {
-		struct bnxt_napi *bnapi = bp->bnapi[i];
-		struct bnxt_tx_ring_info *txr = &bnapi->tx_ring;
+		struct bnxt_tx_ring_info *txr = &bp->tx_ring[i];
 		struct bnxt_ring_struct *ring = &txr->tx_ring_struct;
 		u32 cmpl_ring_id = bp->grp_info[i].cp_fw_ring_id;
 
@@ -3446,8 +3431,7 @@ static void bnxt_hwrm_ring_free(struct bnxt *bp, bool close_path)
 	}
 
 	for (i = 0; i < bp->rx_nr_rings; i++) {
-		struct bnxt_napi *bnapi = bp->bnapi[i];
-		struct bnxt_rx_ring_info *rxr = &bnapi->rx_ring;
+		struct bnxt_rx_ring_info *rxr = &bp->rx_ring[i];
 		struct bnxt_ring_struct *ring = &rxr->rx_ring_struct;
 		u32 cmpl_ring_id = bp->grp_info[i].cp_fw_ring_id;
 
@@ -3462,8 +3446,7 @@ static void bnxt_hwrm_ring_free(struct bnxt *bp, bool close_path)
 	}
 
 	for (i = 0; i < bp->rx_nr_rings; i++) {
-		struct bnxt_napi *bnapi = bp->bnapi[i];
-		struct bnxt_rx_ring_info *rxr = &bnapi->rx_ring;
+		struct bnxt_rx_ring_info *rxr = &bp->rx_ring[i];
 		struct bnxt_ring_struct *ring = &rxr->rx_agg_ring_struct;
 		u32 cmpl_ring_id = bp->grp_info[i].cp_fw_ring_id;
 
@@ -4258,14 +4241,12 @@ static void bnxt_enable_napi(struct bnxt *bp)
 static void bnxt_tx_disable(struct bnxt *bp)
 {
 	int i;
-	struct bnxt_napi *bnapi;
 	struct bnxt_tx_ring_info *txr;
 	struct netdev_queue *txq;
 
-	if (bp->bnapi) {
+	if (bp->tx_ring) {
 		for (i = 0; i < bp->tx_nr_rings; i++) {
-			bnapi = bp->bnapi[i];
-			txr = &bnapi->tx_ring;
+			txr = &bp->tx_ring[i];
 			txq = netdev_get_tx_queue(bp->dev, i);
 			__netif_tx_lock(txq, smp_processor_id());
 			txr->dev_state = BNXT_DEV_STATE_CLOSING;
@@ -4280,13 +4261,11 @@ static void bnxt_tx_disable(struct bnxt *bp)
 static void bnxt_tx_enable(struct bnxt *bp)
 {
 	int i;
-	struct bnxt_napi *bnapi;
 	struct bnxt_tx_ring_info *txr;
 	struct netdev_queue *txq;
 
 	for (i = 0; i < bp->tx_nr_rings; i++) {
-		bnapi = bp->bnapi[i];
-		txr = &bnapi->tx_ring;
+		txr = &bp->tx_ring[i];
 		txq = netdev_get_tx_queue(bp->dev, i);
 		txr->dev_state = 0;
 	}
@@ -5017,7 +4996,7 @@ static int bnxt_set_features(struct net_device *dev, netdev_features_t features)
 
 static void bnxt_dump_tx_sw_state(struct bnxt_napi *bnapi)
 {
-	struct bnxt_tx_ring_info *txr = &bnapi->tx_ring;
+	struct bnxt_tx_ring_info *txr = bnapi->tx_ring;
 	int i = bnapi->index;
 
 	netdev_info(bnapi->bp->dev, "[%d]: tx{fw_ring: %d prod: %x cons: %x}\n",
@@ -5027,7 +5006,7 @@ static void bnxt_dump_tx_sw_state(struct bnxt_napi *bnapi)
 
 static void bnxt_dump_rx_sw_state(struct bnxt_napi *bnapi)
 {
-	struct bnxt_rx_ring_info *rxr = &bnapi->rx_ring;
+	struct bnxt_rx_ring_info *rxr = bnapi->rx_ring;
 	int i = bnapi->index;
 
 	netdev_info(bnapi->bp->dev, "[%d]: rx{fw_ring: %d prod: %x} rx_agg{fw_ring: %d agg_prod: %x sw_agg_prod: %x}\n",
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 78d639d..ea2fd92 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -528,6 +528,7 @@ struct tx_push_bd {
 };
 
 struct bnxt_tx_ring_info {
+	struct bnxt_napi	*bnapi;
 	u16			tx_prod;
 	u16			tx_cons;
 	void __iomem		*tx_doorbell;
@@ -558,6 +559,7 @@ struct bnxt_tpa_info {
 };
 
 struct bnxt_rx_ring_info {
+	struct bnxt_napi	*bnapi;
 	u16			rx_prod;
 	u16			rx_agg_prod;
 	u16			rx_sw_agg_prod;
@@ -604,8 +606,8 @@ struct bnxt_napi {
 
 	int			index;
 	struct bnxt_cp_ring_info	cp_ring;
-	struct bnxt_rx_ring_info	rx_ring;
-	struct bnxt_tx_ring_info	tx_ring;
+	struct bnxt_rx_ring_info	*rx_ring;
+	struct bnxt_tx_ring_info	*tx_ring;
 
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	atomic_t		poll_state;
@@ -884,6 +886,9 @@ struct bnxt {
 
 	struct bnxt_napi	**bnapi;
 
+	struct bnxt_rx_ring_info	*rx_ring;
+	struct bnxt_tx_ring_info	*tx_ring;
+
 	u32			rx_buf_size;
 	u32			rx_buf_use_size;	/* useable size */
 	u32			rx_ring_size;
-- 
1.8.3.1
