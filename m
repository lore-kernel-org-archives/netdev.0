From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 4/8] qed: LL2 code relocations
Date: Thu, 8 Jun 2017 19:13:19 +0300
Message-ID: <20170608161323.7597-5-Yuval.Mintz@cavium.com>
References: <20170608161323.7597-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma@vger.kernel.org>, <Michal.Kalderon@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0071.outbound.protection.outlook.com ([104.47.40.71]:47680
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751967AbdFHQOZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Jun 2017 12:14:25 -0400
In-Reply-To: <20170608161323.7597-1-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of having the OOO logic packetd, divide it with rest of code
according to establish/release flows.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_ll2.c | 58 +++++++++++++++----------------
 1 file changed, 28 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
index fcf4ea9..f3aad61 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ll2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
@@ -896,36 +896,6 @@ static int qed_ll2_lb_txq_completion(struct qed_hwfn *p_hwfn, void *p_cookie)
 	return 0;
 }
 
-static void
-qed_ll2_establish_connection_ooo(struct qed_hwfn *p_hwfn,
-				 struct qed_ll2_info *p_ll2_conn)
-{
-	if (p_ll2_conn->input.conn_type != QED_LL2_TYPE_ISCSI_OOO)
-		return;
-
-	qed_ooo_release_all_isles(p_hwfn, p_hwfn->p_ooo_info);
-	qed_ooo_submit_rx_buffers(p_hwfn, p_ll2_conn);
-}
-
-static void qed_ll2_release_connection_ooo(struct qed_hwfn *p_hwfn,
-					   struct qed_ll2_info *p_ll2_conn)
-{
-	struct qed_ooo_buffer *p_buffer;
-
-	if (p_ll2_conn->input.conn_type != QED_LL2_TYPE_ISCSI_OOO)
-		return;
-
-	qed_ooo_release_all_isles(p_hwfn, p_hwfn->p_ooo_info);
-	while ((p_buffer = qed_ooo_get_free_buffer(p_hwfn,
-						   p_hwfn->p_ooo_info))) {
-		dma_free_coherent(&p_hwfn->cdev->pdev->dev,
-				  p_buffer->rx_buffer_size,
-				  p_buffer->rx_buffer_virt_addr,
-				  p_buffer->rx_buffer_phys_addr);
-		kfree(p_buffer);
-	}
-}
-
 static void qed_ll2_stop_ooo(struct qed_dev *cdev)
 {
 	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
@@ -1397,6 +1367,16 @@ static int qed_ll2_establish_connection_rx(struct qed_hwfn *p_hwfn,
 	return qed_sp_ll2_rx_queue_start(p_hwfn, p_ll2_conn, action_on_error);
 }
 
+static void
+qed_ll2_establish_connection_ooo(struct qed_hwfn *p_hwfn,
+				 struct qed_ll2_info *p_ll2_conn)
+{
+	if (p_ll2_conn->input.conn_type != QED_LL2_TYPE_ISCSI_OOO)
+		return;
+
+	qed_ooo_release_all_isles(p_hwfn, p_hwfn->p_ooo_info);
+	qed_ooo_submit_rx_buffers(p_hwfn, p_ll2_conn);
+}
 int qed_ll2_establish_connection(struct qed_hwfn *p_hwfn, u8 connection_handle)
 {
 	struct qed_ll2_info *p_ll2_conn;
@@ -1857,6 +1837,24 @@ int qed_ll2_terminate_connection(struct qed_hwfn *p_hwfn, u8 connection_handle)
 	return rc;
 }
 
+static void qed_ll2_release_connection_ooo(struct qed_hwfn *p_hwfn,
+					   struct qed_ll2_info *p_ll2_conn)
+{
+	struct qed_ooo_buffer *p_buffer;
+
+	if (p_ll2_conn->input.conn_type != QED_LL2_TYPE_ISCSI_OOO)
+		return;
+
+	qed_ooo_release_all_isles(p_hwfn, p_hwfn->p_ooo_info);
+	while ((p_buffer = qed_ooo_get_free_buffer(p_hwfn,
+						   p_hwfn->p_ooo_info))) {
+		dma_free_coherent(&p_hwfn->cdev->pdev->dev,
+				  p_buffer->rx_buffer_size,
+				  p_buffer->rx_buffer_virt_addr,
+				  p_buffer->rx_buffer_phys_addr);
+		kfree(p_buffer);
+	}
+}
 void qed_ll2_release_connection(struct qed_hwfn *p_hwfn, u8 connection_handle)
 {
 	struct qed_ll2_info *p_ll2_conn = NULL;
-- 
2.9.4
