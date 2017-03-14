From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net 4/7] qed: Free previous connections when releasing iSCSI
Date: Tue, 14 Mar 2017 15:26:01 +0200
Message-ID: <1489497964-13734-5-git-send-email-Yuval.Mintz@cavium.com>
References: <1489497964-13734-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:39038 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752192AbdCNN0Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 09:26:24 -0400
In-Reply-To: <1489497964-13734-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: fc831825f99e ("qed: Add support for hardware offloaded iSCSI")
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_iscsi.c | 28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_iscsi.c b/drivers/net/ethernet/qlogic/qed/qed_iscsi.c
index 3a44d6b..7e73b05 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_iscsi.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_iscsi.c
@@ -786,6 +786,23 @@ static void qed_iscsi_release_connection(struct qed_hwfn *p_hwfn,
 	spin_unlock_bh(&p_hwfn->p_iscsi_info->lock);
 }
 
+void qed_iscsi_free_connection(struct qed_hwfn *p_hwfn,
+			       struct qed_iscsi_conn *p_conn)
+{
+	qed_chain_free(p_hwfn->cdev, &p_conn->xhq);
+	qed_chain_free(p_hwfn->cdev, &p_conn->uhq);
+	qed_chain_free(p_hwfn->cdev, &p_conn->r2tq);
+	dma_free_coherent(&p_hwfn->cdev->pdev->dev,
+			  sizeof(struct tcp_upload_params),
+			  p_conn->tcp_upload_params_virt_addr,
+			  p_conn->tcp_upload_params_phys_addr);
+	dma_free_coherent(&p_hwfn->cdev->pdev->dev,
+			  sizeof(struct scsi_terminate_extra_params),
+			  p_conn->queue_cnts_virt_addr,
+			  p_conn->queue_cnts_phys_addr);
+	kfree(p_conn);
+}
+
 struct qed_iscsi_info *qed_iscsi_alloc(struct qed_hwfn *p_hwfn)
 {
 	struct qed_iscsi_info *p_iscsi_info;
@@ -807,6 +824,17 @@ void qed_iscsi_setup(struct qed_hwfn *p_hwfn,
 void qed_iscsi_free(struct qed_hwfn *p_hwfn,
 		    struct qed_iscsi_info *p_iscsi_info)
 {
+	struct qed_iscsi_conn *p_conn = NULL;
+
+	while (!list_empty(&p_hwfn->p_iscsi_info->free_list)) {
+		p_conn = list_first_entry(&p_hwfn->p_iscsi_info->free_list,
+					  struct qed_iscsi_conn, list_entry);
+		if (p_conn) {
+			list_del(&p_conn->list_entry);
+			qed_iscsi_free_connection(p_hwfn, p_conn);
+		}
+	}
+
 	kfree(p_iscsi_info);
 }
 
-- 
1.9.3
