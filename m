From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2] drivers: net: xgene: fix Tx flow control
Date: Wed, 16 Dec 2015 22:26:05 -0800
Message-ID: <1450333565-23670-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34895 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180AbbLQGX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 01:23:59 -0500
Received: by mail-pa0-f52.google.com with SMTP id jx14so7887441pad.2
        for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 22:23:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the Tx flow control is based on reading the hardware state,
which is not accurate since it may not reflect the descriptors that
are not yet reached the memory.

To accurately control the Tx flow, changing it to be software based.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---

v2: Address v1 review comments
	- Removed use of atomic_t
	- Added tx_level and txc_level counters to pdata

v1: Initial version
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 38 ++++++++++++++----------
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h |  4 +--
 2 files changed, 24 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 9147a01..d0ae1a6 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -289,6 +289,7 @@ static int xgene_enet_setup_tx_desc(struct xgene_enet_desc_ring *tx_ring,
 				    struct sk_buff *skb)
 {
 	struct device *dev = ndev_to_dev(tx_ring->ndev);
+	struct xgene_enet_pdata *pdata = netdev_priv(tx_ring->ndev);
 	struct xgene_enet_raw_desc *raw_desc;
 	__le64 *exp_desc = NULL, *exp_bufs = NULL;
 	dma_addr_t dma_addr, pbuf_addr, *frag_dma_addr;
@@ -419,6 +420,7 @@ out:
 	raw_desc->m0 = cpu_to_le64(SET_VAL(LL, ll) | SET_VAL(NV, nv) |
 				   SET_VAL(USERINFO, tx_ring->tail));
 	tx_ring->cp_ring->cp_skb[tx_ring->tail] = skb;
+	pdata->tx_level += count;
 	tx_ring->tail = tail;
 
 	return count;
@@ -429,14 +431,13 @@ static netdev_tx_t xgene_enet_start_xmit(struct sk_buff *skb,
 {
 	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
 	struct xgene_enet_desc_ring *tx_ring = pdata->tx_ring;
-	struct xgene_enet_desc_ring *cp_ring = tx_ring->cp_ring;
-	u32 tx_level, cq_level;
+	u32 tx_level = pdata->tx_level;
 	int count;
 
-	tx_level = pdata->ring_ops->len(tx_ring);
-	cq_level = pdata->ring_ops->len(cp_ring);
-	if (unlikely(tx_level > pdata->tx_qcnt_hi ||
-		     cq_level > pdata->cp_qcnt_hi)) {
+	if (tx_level < pdata->txc_level)
+		tx_level += ((typeof(pdata->tx_level))~0U);
+
+	if ((tx_level - pdata->txc_level) > pdata->tx_qcnt_hi) {
 		netif_stop_queue(ndev);
 		return NETDEV_TX_BUSY;
 	}
@@ -539,10 +540,13 @@ static int xgene_enet_process_ring(struct xgene_enet_desc_ring *ring,
 	struct xgene_enet_raw_desc *raw_desc, *exp_desc;
 	u16 head = ring->head;
 	u16 slots = ring->slots - 1;
-	int ret, count = 0, processed = 0;
+	int ret, desc_count, count = 0, processed = 0;
+	bool is_completion;
 
 	do {
 		raw_desc = &ring->raw_desc[head];
+		desc_count = 0;
+		is_completion = false;
 		exp_desc = NULL;
 		if (unlikely(xgene_enet_is_desc_slot_empty(raw_desc)))
 			break;
@@ -559,18 +563,24 @@ static int xgene_enet_process_ring(struct xgene_enet_desc_ring *ring,
 			}
 			dma_rmb();
 			count++;
+			desc_count++;
 		}
-		if (is_rx_desc(raw_desc))
+		if (is_rx_desc(raw_desc)) {
 			ret = xgene_enet_rx_frame(ring, raw_desc);
-		else
+		} else {
 			ret = xgene_enet_tx_completion(ring, raw_desc);
+			is_completion = true;
+		}
 		xgene_enet_mark_desc_slot_empty(raw_desc);
 		if (exp_desc)
 			xgene_enet_mark_desc_slot_empty(exp_desc);
 
 		head = (head + 1) & slots;
 		count++;
+		desc_count++;
 		processed++;
+		if (is_completion)
+			pdata->txc_level += desc_count;
 
 		if (ret)
 			break;
@@ -580,10 +590,8 @@ static int xgene_enet_process_ring(struct xgene_enet_desc_ring *ring,
 		pdata->ring_ops->wr_cmd(ring, -count);
 		ring->head = head;
 
-		if (netif_queue_stopped(ring->ndev)) {
-			if (pdata->ring_ops->len(ring) < pdata->cp_qcnt_low)
-				netif_wake_queue(ring->ndev);
-		}
+		if (netif_queue_stopped(ring->ndev))
+			netif_start_queue(ring->ndev);
 	}
 
 	return processed;
@@ -1033,9 +1041,7 @@ static int xgene_enet_create_desc_rings(struct net_device *ndev)
 	pdata->tx_ring->cp_ring = cp_ring;
 	pdata->tx_ring->dst_ring_num = xgene_enet_dst_ring_num(cp_ring);
 
-	pdata->tx_qcnt_hi = pdata->tx_ring->slots / 2;
-	pdata->cp_qcnt_hi = pdata->rx_ring->slots / 2;
-	pdata->cp_qcnt_low = pdata->cp_qcnt_hi / 2;
+	pdata->tx_qcnt_hi = pdata->tx_ring->slots - 128;
 
 	return 0;
 
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index a6e56b8..1aa72c7 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -155,11 +155,11 @@ struct xgene_enet_pdata {
 	enum xgene_enet_id enet_id;
 	struct xgene_enet_desc_ring *tx_ring;
 	struct xgene_enet_desc_ring *rx_ring;
+	u16 tx_level;
+	u16 txc_level;
 	char *dev_name;
 	u32 rx_buff_cnt;
 	u32 tx_qcnt_hi;
-	u32 cp_qcnt_hi;
-	u32 cp_qcnt_low;
 	u32 rx_irq;
 	u32 txc_irq;
 	u8 cq_cnt;
-- 
1.9.1
