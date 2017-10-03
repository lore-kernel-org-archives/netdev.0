From: Michal Kalderon <Michal.Kalderon@cavium.com>
Subject: [PATCH v2 net-next 01/12] qed: Add ll2 option to limit the number of bds per packet
Date: Tue, 3 Oct 2017 11:54:51 +0300
Message-ID: <1507020902-4952-2-git-send-email-Michal.Kalderon@cavium.com>
References: <1507020902-4952-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
        <dledford@redhat.com>,
        Michal Kalderon <Michal.Kalderon@cavium.com>,
        "Ariel Elior" <Ariel.Elior@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0070.outbound.protection.outlook.com ([104.47.41.70]:39053
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751156AbdJCIzf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Oct 2017 04:55:35 -0400
In-Reply-To: <1507020902-4952-1-git-send-email-Michal.Kalderon@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

iWARP uses 3 ll2 connections, the maximum number of bds is known
during connection setup. This patch modifies the static array in
the ll2_tx_packet descriptor to be a flexible array and
significantlly reduces memory size.

In addition, some redundant fields in the ll2_tx_packet were
removed, which also contributed to decreasing the descriptor size.

Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
Signed-off-by: Ariel Elior <Ariel.Elior@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_ll2.c | 29 +++++++++++++++++++++--------
 drivers/net/ethernet/qlogic/qed/qed_ll2.h |  9 +++------
 2 files changed, 24 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
index 250afa5..75af40a 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ll2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
@@ -1105,6 +1105,7 @@ static int qed_ll2_acquire_connection_tx(struct qed_hwfn *p_hwfn,
 					 struct qed_ll2_info *p_ll2_info)
 {
 	struct qed_ll2_tx_packet *p_descq;
+	u32 desc_size;
 	u32 capacity;
 	int rc = 0;
 
@@ -1122,13 +1123,17 @@ static int qed_ll2_acquire_connection_tx(struct qed_hwfn *p_hwfn,
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
 	}
-	p_ll2_info->tx_queue.descq_array = p_descq;
+	p_ll2_info->tx_queue.descq_mem = p_descq;
 
 	DP_VERBOSE(p_hwfn, QED_MSG_LL2,
 		   "Allocated LL2 Txq [Type %08x] with 0x%08x buffers\n",
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
+		p_pkt = p_tx->descq_mem + desc_size * i;
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
@@ -1858,7 +1871,7 @@ void qed_ll2_release_connection(void *cxt, u8 connection_handle)
 		qed_int_unregister_cb(p_hwfn, p_ll2_conn->tx_queue.tx_sb_index);
 	}
 
-	kfree(p_ll2_conn->tx_queue.descq_array);
+	kfree(p_ll2_conn->tx_queue.descq_mem);
 	qed_chain_free(p_hwfn->cdev, &p_ll2_conn->tx_queue.txq_chain);
 
 	kfree(p_ll2_conn->rx_queue.descq_array);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.h b/drivers/net/ethernet/qlogic/qed/qed_ll2.h
index a822528..9bdd08f 100644
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
@@ -101,7 +98,7 @@ struct qed_ll2_tx_queue {
 	struct list_head active_descq;
 	struct list_head free_descq;
 	struct list_head sending_descq;
-	struct qed_ll2_tx_packet *descq_array;
+	void *descq_mem; /* memory for variable sized qed_ll2_tx_packet*/
 	struct qed_ll2_tx_packet *cur_send_packet;
 	struct qed_ll2_tx_packet cur_completing_packet;
 	u16 cur_completing_bd_idx;
-- 
1.8.3.1
