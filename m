From: Michal Kalderon <Michal.Kalderon@cavium.com>
Subject: [PATCH v2 net-next 06/12] qed: Add LL2 slowpath handling
Date: Tue, 3 Oct 2017 11:54:56 +0300
Message-ID: <1507020902-4952-7-git-send-email-Michal.Kalderon@cavium.com>
References: <1507020902-4952-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
        <dledford@redhat.com>,
        Michal Kalderon <Michal.Kalderon@cavium.com>,
        "Ariel Elior" <Ariel.Elior@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0071.outbound.protection.outlook.com ([104.47.34.71]:27217
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751277AbdJCI4C (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Oct 2017 04:56:02 -0400
In-Reply-To: <1507020902-4952-1-git-send-email-Michal.Kalderon@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For iWARP unaligned MPA flow, a slowpath event of flushing an
MPA connection that entered an unaligned state is required.
The flush ramrod is received on the ll2 queue, and a pre-registered
callback function is called to handle the flush event.

Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
Signed-off-by: Ariel Elior <Ariel.Elior@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_ll2.c | 40 +++++++++++++++++++++++++++++--
 include/linux/qed/qed_ll2_if.h            |  5 ++++
 2 files changed, 43 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
index 8eb9645..047f556 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ll2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
@@ -423,6 +423,41 @@ static void qed_ll2_rxq_parse_reg(struct qed_hwfn *p_hwfn,
 }
 
 static int
+qed_ll2_handle_slowpath(struct qed_hwfn *p_hwfn,
+			struct qed_ll2_info *p_ll2_conn,
+			union core_rx_cqe_union *p_cqe,
+			unsigned long *p_lock_flags)
+{
+	struct qed_ll2_rx_queue *p_rx = &p_ll2_conn->rx_queue;
+	struct core_rx_slow_path_cqe *sp_cqe;
+
+	sp_cqe = &p_cqe->rx_cqe_sp;
+	if (sp_cqe->ramrod_cmd_id != CORE_RAMROD_RX_QUEUE_FLUSH) {
+		DP_NOTICE(p_hwfn,
+			  "LL2 - unexpected Rx CQE slowpath ramrod_cmd_id:%d\n",
+			  sp_cqe->ramrod_cmd_id);
+		return -EINVAL;
+	}
+
+	if (!p_ll2_conn->cbs.slowpath_cb) {
+		DP_NOTICE(p_hwfn,
+			  "LL2 - received RX_QUEUE_FLUSH but no callback was provided\n");
+		return -EINVAL;
+	}
+
+	spin_unlock_irqrestore(&p_rx->lock, *p_lock_flags);
+
+	p_ll2_conn->cbs.slowpath_cb(p_ll2_conn->cbs.cookie,
+				    p_ll2_conn->my_id,
+				    le32_to_cpu(sp_cqe->opaque_data.data[0]),
+				    le32_to_cpu(sp_cqe->opaque_data.data[1]));
+
+	spin_lock_irqsave(&p_rx->lock, *p_lock_flags);
+
+	return 0;
+}
+
+static int
 qed_ll2_rxq_handle_completion(struct qed_hwfn *p_hwfn,
 			      struct qed_ll2_info *p_ll2_conn,
 			      union core_rx_cqe_union *p_cqe,
@@ -495,8 +530,8 @@ static int qed_ll2_rxq_completion(struct qed_hwfn *p_hwfn, void *cookie)
 
 		switch (cqe->rx_cqe_sp.type) {
 		case CORE_RX_CQE_TYPE_SLOW_PATH:
-			DP_NOTICE(p_hwfn, "LL2 - unexpected Rx CQE slowpath\n");
-			rc = -EINVAL;
+			rc = qed_ll2_handle_slowpath(p_hwfn, p_ll2_conn,
+						     cqe, &flags);
 			break;
 		case CORE_RX_CQE_TYPE_GSI_OFFLOAD:
 		case CORE_RX_CQE_TYPE_REGULAR:
@@ -1214,6 +1249,7 @@ static int qed_ll2_acquire_connection_tx(struct qed_hwfn *p_hwfn,
 	p_ll2_info->cbs.rx_release_cb = cbs->rx_release_cb;
 	p_ll2_info->cbs.tx_comp_cb = cbs->tx_comp_cb;
 	p_ll2_info->cbs.tx_release_cb = cbs->tx_release_cb;
+	p_ll2_info->cbs.slowpath_cb = cbs->slowpath_cb;
 	p_ll2_info->cbs.cookie = cbs->cookie;
 
 	return 0;
diff --git a/include/linux/qed/qed_ll2_if.h b/include/linux/qed/qed_ll2_if.h
index 95fdf02..e755954 100644
--- a/include/linux/qed/qed_ll2_if.h
+++ b/include/linux/qed/qed_ll2_if.h
@@ -151,11 +151,16 @@ struct qed_ll2_comp_rx_data {
 				     dma_addr_t first_frag_addr,
 				     bool b_last_fragment, bool b_last_packet);
 
+typedef
+void (*qed_ll2_slowpath_cb)(void *cxt, u8 connection_handle,
+			    u32 opaque_data_0, u32 opaque_data_1);
+
 struct qed_ll2_cbs {
 	qed_ll2_complete_rx_packet_cb rx_comp_cb;
 	qed_ll2_release_rx_packet_cb rx_release_cb;
 	qed_ll2_complete_tx_packet_cb tx_comp_cb;
 	qed_ll2_release_tx_packet_cb tx_release_cb;
+	qed_ll2_slowpath_cb slowpath_cb;
 	void *cookie;
 };
 
-- 
1.8.3.1
