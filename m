From: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v2 net-next 4/8] qed: LL2 code relocations
Date: Fri, 9 Jun 2017 17:13:21 +0300
Message-ID: <20170609141325.20547-5-Yuval.Mintz@cavium.com>
References: <20170609141325.20547-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170609141325.20547-1-Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Instead of having the OOO logic packetd, divide it with rest of code
according to establish/release flows.

Signed-off-by: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
