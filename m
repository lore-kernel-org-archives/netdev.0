From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH] drivers: net: xgene: fix Tx flow control
Date: Fri, 27 Nov 2015 19:22:31 -0800
Message-ID: <1448680951-4730-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	kdinh@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33942 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751465AbbK1DVD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2015 22:21:03 -0500
Received: by padhx2 with SMTP id hx2so128674401pad.1
        for <netdev@vger.kernel.org>; Fri, 27 Nov 2015 19:21:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the Tx flow control is based on reading the hardware state,
which is not accurate since it may not reflect the descriptors that
are not yet reached the memory.

To accurately control the Tx flow, changing it to be software based.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Khuong Dinh <kdinh@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 35 +++++++++++++-----------
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h |  3 +-
 2 files changed, 20 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 1adfe70..a25cc6f7 100644
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
+	atomic_add(count, &pdata->level);
 	tx_ring->tail = tail;
 
 	return count;
@@ -429,14 +431,9 @@ static netdev_tx_t xgene_enet_start_xmit(struct sk_buff *skb,
 {
 	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
 	struct xgene_enet_desc_ring *tx_ring = pdata->tx_ring;
-	struct xgene_enet_desc_ring *cp_ring = tx_ring->cp_ring;
-	u32 tx_level, cq_level;
 	int count;
 
-	tx_level = pdata->ring_ops->len(tx_ring);
-	cq_level = pdata->ring_ops->len(cp_ring);
-	if (unlikely(tx_level > pdata->tx_qcnt_hi ||
-		     cq_level > pdata->cp_qcnt_hi)) {
+	if (atomic_read(&pdata->level) > pdata->tx_qcnt_hi) {
 		netif_stop_queue(ndev);
 		return NETDEV_TX_BUSY;
 	}
@@ -539,10 +536,13 @@ static int xgene_enet_process_ring(struct xgene_enet_desc_ring *ring,
 	struct xgene_enet_raw_desc *raw_desc, *exp_desc;
 	u16 head = ring->head;
 	u16 slots = ring->slots - 1;
-	int ret, count = 0, processed = 0;
+	int ret, count = 0, desc_count = 0, processed = 0;
+	bool is_completion;
 
 	do {
 		raw_desc = &ring->raw_desc[head];
+		desc_count = 0;
+		is_completion = false;
 		exp_desc = NULL;
 		if (unlikely(xgene_enet_is_desc_slot_empty(raw_desc)))
 			break;
@@ -559,18 +559,24 @@ static int xgene_enet_process_ring(struct xgene_enet_desc_ring *ring,
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
+			atomic_sub(desc_count, &pdata->level);
 
 		if (ret)
 			break;
@@ -580,10 +586,8 @@ static int xgene_enet_process_ring(struct xgene_enet_desc_ring *ring,
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
@@ -685,6 +689,7 @@ static int xgene_enet_open(struct net_device *ndev)
 	struct xgene_mac_ops *mac_ops = pdata->mac_ops;
 	int ret;
 
+	atomic_set(&pdata->level, 0);
 	mac_ops->tx_enable(pdata);
 	mac_ops->rx_enable(pdata);
 
@@ -1033,9 +1038,7 @@ static int xgene_enet_create_desc_rings(struct net_device *ndev)
 	pdata->tx_ring->cp_ring = cp_ring;
 	pdata->tx_ring->dst_ring_num = xgene_enet_dst_ring_num(cp_ring);
 
-	pdata->tx_qcnt_hi = pdata->tx_ring->slots / 2;
-	pdata->cp_qcnt_hi = pdata->rx_ring->slots / 2;
-	pdata->cp_qcnt_low = pdata->cp_qcnt_hi / 2;
+	pdata->tx_qcnt_hi = pdata->tx_ring->slots - 128;
 
 	return 0;
 
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index a6e56b8..4399fa5 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -155,11 +155,10 @@ struct xgene_enet_pdata {
 	enum xgene_enet_id enet_id;
 	struct xgene_enet_desc_ring *tx_ring;
 	struct xgene_enet_desc_ring *rx_ring;
+	atomic_t level;
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
