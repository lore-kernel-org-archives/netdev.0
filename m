From: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 01/12] qed: Add ll2 option to limit the number of bds per packet
Date: Mon, 2 Oct 2017 11:23:47 +0300
Message-ID: <1506932638-26268-2-git-send-email-Michal.Kalderon@cavium.com>
References: <1506932638-26268-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        "Ariel Elior" <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1506932638-26268-1-git-send-email-Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

iWARP uses 3 ll2 connections, the maximum number of bds is known
during connection setup. This patch modifies the static array in
the ll2_tx_packet descriptor to be a flexible array and
significantlly reduces memory size.

In addition, some redundant fields in the ll2_tx_packet were
removed, which also contributed to decreasing the descriptor size.

Signed-off-by: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/qlogic/qed/qed_ll2.c | 25 +++++++++++++++++++------
 drivers/net/ethernet/qlogic/qed/qed_ll2.h |  7 ++-----
 2 files changed, 21 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
index 250afa5..10e3a43 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ll2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
@@ -1105,6 +1105,7 @@ static int qed_ll2_acquire_connection_tx(struct qed_hwfn *p_hwfn,
 					 struct qed_ll2_info *p_ll2_info)
 {
 	struct qed_ll2_tx_packet *p_descq;
+	u32 desc_size;
 	u32 capacity;
 	int rc = 0;
 
@@ -1122,8 +1123,12 @@ static int qed_ll2_acquire_connection_tx(struct qed_hwfn *p_hwfn,
 		goto out;
 
 	capacity = qed_chain_get_capacity(&p_ll2_info->tx_queue.txq_chain);
-	p_descq = kcalloc(capacity, sizeof(struct qed_ll2_tx_packet),
-			  GFP_KERNEL);
+	/* First element is part of the packet, rest are flexibly added */
+	desc_size = (sizeof(*p_descq) +
+		     (p_ll2_info->input.tx_max_bds_per_packet - 1) *
+		     sizeof(p_descq->bds_set));
+
+	p_descq = kcalloc(capacity, desc_size, GFP_KERNEL);
 	if (!p_descq) {
 		rc = -ENOMEM;
 		goto out;
@@ -1359,11 +1364,13 @@ int qed_ll2_establish_connection(void *cxt, u8 connection_handle)
 {
 	struct qed_hwfn *p_hwfn = cxt;
 	struct qed_ll2_info *p_ll2_conn;
+	struct qed_ll2_tx_packet *p_pkt;
 	struct qed_ll2_rx_queue *p_rx;
 	struct qed_ll2_tx_queue *p_tx;
 	struct qed_ptt *p_ptt;
 	int rc = -EINVAL;
 	u32 i, capacity;
+	u32 desc_size;
 	u8 qid;
 
 	p_ptt = qed_ptt_acquire(p_hwfn);
@@ -1397,9 +1404,15 @@ int qed_ll2_establish_connection(void *cxt, u8 connection_handle)
 	INIT_LIST_HEAD(&p_tx->sending_descq);
 	spin_lock_init(&p_tx->lock);
 	capacity = qed_chain_get_capacity(&p_tx->txq_chain);
-	for (i = 0; i < capacity; i++)
-		list_add_tail(&p_tx->descq_array[i].list_entry,
-			      &p_tx->free_descq);
+	/* First element is part of the packet, rest are flexibly added */
+	desc_size = (sizeof(*p_pkt) +
+		     (p_ll2_conn->input.tx_max_bds_per_packet - 1) *
+		     sizeof(p_pkt->bds_set));
+
+	for (i = 0; i < capacity; i++) {
+		p_pkt = (void *)((u8 *)p_tx->descq_array + desc_size * i);
+		list_add_tail(&p_pkt->list_entry, &p_tx->free_descq);
+	}
 	p_tx->cur_completing_bd_idx = 0;
 	p_tx->bds_idx = 0;
 	p_tx->b_completing_packet = false;
@@ -1698,7 +1711,7 @@ int qed_ll2_prepare_tx_packet(void *cxt,
 	p_tx = &p_ll2_conn->tx_queue;
 	p_tx_chain = &p_tx->txq_chain;
 
-	if (pkt->num_of_bds > CORE_LL2_TX_MAX_BDS_PER_PACKET)
+	if (pkt->num_of_bds > p_ll2_conn->input.tx_max_bds_per_packet)
 		return -EIO;
 
 	spin_lock_irqsave(&p_tx->lock, flags);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.h b/drivers/net/ethernet/qlogic/qed/qed_ll2.h
index a822528..8019336 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ll2.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.h
@@ -63,17 +63,14 @@ struct qed_ll2_rx_packet {
 struct qed_ll2_tx_packet {
 	struct list_head list_entry;
 	u16 bd_used;
-	u16 vlan;
-	u16 l4_hdr_offset_w;
-	u8 bd_flags;
 	bool notify_fw;
 	void *cookie;
-
+	/* Flexible Array of bds_set determined by max_bds_per_packet */
 	struct {
 		struct core_tx_bd *txq_bd;
 		dma_addr_t tx_frag;
 		u16 frag_len;
-	} bds_set[ETH_TX_MAX_BDS_PER_NON_LSO_PACKET];
+	} bds_set[1];
 };
 
 struct qed_ll2_rx_queue {
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
