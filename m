From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH v2 net 4/4] qed: Correct slowpath interrupt scheme
Date: Mon, 7 Dec 2015 06:25:59 -0500
Message-ID: <1449487559-31811-5-git-send-email-manish.chopra@qlogic.com>
References: <1449487559-31811-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>,
	Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:10721 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754724AbbLGMGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 07:06:25 -0500
In-Reply-To: <1449487559-31811-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>

When using INTa, ISR might be called before device is configured
for INTa [E.g., due to other device asserting the shared interrupt line],
in which case the ISR would read the SISR registers that shouldn't be
read unless HW is already configured for INTa. This might break interrupts
later on. There's also an MSI-X issue due to this difference, although
it's mostly theoretical.

This patch changes the initialization order, calling request_irq() for the
slowpath interrupt only after the chip is configured for working
in the preferred interrupt mode.

Signed-off-by: Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>
Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h      |    3 +
 drivers/net/ethernet/qlogic/qed/qed_int.c  |   33 ++++++++++++----
 drivers/net/ethernet/qlogic/qed/qed_int.h  |   15 +++++--
 drivers/net/ethernet/qlogic/qed/qed_main.c |   56 +++++++++-------------------
 4 files changed, 55 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index ac17d86..1292c36 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -299,6 +299,7 @@ struct qed_hwfn {
 
 	/* Flag indicating whether interrupts are enabled or not*/
 	bool				b_int_enabled;
+	bool				b_int_requested;
 
 	struct qed_mcp_info		*mcp_info;
 
@@ -491,6 +492,8 @@ u32 qed_unzip_data(struct qed_hwfn *p_hwfn,
 		   u32 input_len, u8 *input_buf,
 		   u32 max_size, u8 *unzip_buf);
 
+int qed_slowpath_irq_req(struct qed_hwfn *hwfn);
+
 #define QED_ETH_INTERFACE_VERSION       300
 
 #endif /* _QED_H */
diff --git a/drivers/net/ethernet/qlogic/qed/qed_int.c b/drivers/net/ethernet/qlogic/qed/qed_int.c
index de50e84..9cc9d62 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_int.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_int.c
@@ -783,22 +783,16 @@ void qed_int_igu_enable_int(struct qed_hwfn *p_hwfn,
 	qed_wr(p_hwfn, p_ptt, IGU_REG_PF_CONFIGURATION, igu_pf_conf);
 }
 
-void qed_int_igu_enable(struct qed_hwfn *p_hwfn,
-			struct qed_ptt *p_ptt,
-			enum qed_int_mode int_mode)
+int qed_int_igu_enable(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
+		       enum qed_int_mode int_mode)
 {
-	int i;
-
-	p_hwfn->b_int_enabled = 1;
+	int rc, i;
 
 	/* Mask non-link attentions */
 	for (i = 0; i < 9; i++)
 		qed_wr(p_hwfn, p_ptt,
 		       MISC_REG_AEU_ENABLE1_IGU_OUT_0 + (i << 2), 0);
 
-	/* Enable interrupt Generation */
-	qed_int_igu_enable_int(p_hwfn, p_ptt, int_mode);
-
 	/* Configure AEU signal change to produce attentions for link */
 	qed_wr(p_hwfn, p_ptt, IGU_REG_LEADING_EDGE_LATCH, 0xfff);
 	qed_wr(p_hwfn, p_ptt, IGU_REG_TRAILING_EDGE_LATCH, 0xfff);
@@ -808,6 +802,19 @@ void qed_int_igu_enable(struct qed_hwfn *p_hwfn,
 
 	/* Unmask AEU signals toward IGU */
 	qed_wr(p_hwfn, p_ptt, MISC_REG_AEU_MASK_ATTN_IGU, 0xff);
+	if ((int_mode != QED_INT_MODE_INTA) || IS_LEAD_HWFN(p_hwfn)) {
+		rc = qed_slowpath_irq_req(p_hwfn);
+		if (rc != 0) {
+			DP_NOTICE(p_hwfn, "Slowpath IRQ request failed\n");
+			return -EINVAL;
+		}
+		p_hwfn->b_int_requested = true;
+	}
+	/* Enable interrupt Generation */
+	qed_int_igu_enable_int(p_hwfn, p_ptt, int_mode);
+	p_hwfn->b_int_enabled = 1;
+
+	return rc;
 }
 
 void qed_int_igu_disable_int(struct qed_hwfn *p_hwfn,
@@ -1127,3 +1134,11 @@ int qed_int_get_num_sbs(struct qed_hwfn *p_hwfn,
 
 	return info->igu_sb_cnt;
 }
+
+void qed_int_disable_post_isr_release(struct qed_dev *cdev)
+{
+	int i;
+
+	for_each_hwfn(cdev, i)
+		cdev->hwfns[i].b_int_requested = false;
+}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_int.h b/drivers/net/ethernet/qlogic/qed/qed_int.h
index 16b5751..51e0b09 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_int.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_int.h
@@ -169,10 +169,14 @@ int qed_int_get_num_sbs(struct qed_hwfn *p_hwfn,
 			int *p_iov_blks);
 
 /**
- * @file
+ * @brief qed_int_disable_post_isr_release - performs the cleanup post ISR
+ *        release. The API need to be called after releasing all slowpath IRQs
+ *        of the device.
+ *
+ * @param cdev
  *
- * @brief Interrupt handler
  */
+void qed_int_disable_post_isr_release(struct qed_dev *cdev);
 
 #define QED_CAU_DEF_RX_TIMER_RES 0
 #define QED_CAU_DEF_TX_TIMER_RES 0
@@ -366,10 +370,11 @@ void qed_int_setup(struct qed_hwfn *p_hwfn,
  * @param p_hwfn
  * @param p_ptt
  * @param int_mode
+ *
+ * @return int
  */
-void qed_int_igu_enable(struct qed_hwfn *p_hwfn,
-			struct qed_ptt *p_ptt,
-			enum qed_int_mode int_mode);
+int qed_int_igu_enable(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
+		       enum qed_int_mode int_mode);
 
 /**
  * @brief - Initialize CAU status block entry
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 947c7af..174f734 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -476,41 +476,22 @@ static irqreturn_t qed_single_int(int irq, void *dev_instance)
 	return rc;
 }
 
-static int qed_slowpath_irq_req(struct qed_dev *cdev)
+int qed_slowpath_irq_req(struct qed_hwfn *hwfn)
 {
-	int i = 0, rc = 0;
+	struct qed_dev *cdev = hwfn->cdev;
+	int rc = 0;
+	u8 id;
 
 	if (cdev->int_params.out.int_mode == QED_INT_MODE_MSIX) {
-		/* Request all the slowpath MSI-X vectors */
-		for (i = 0; i < cdev->num_hwfns; i++) {
-			snprintf(cdev->hwfns[i].name, NAME_SIZE,
-				 "sp-%d-%02x:%02x.%02x",
-				 i, cdev->pdev->bus->number,
-				 PCI_SLOT(cdev->pdev->devfn),
-				 cdev->hwfns[i].abs_pf_id);
-
-			rc = request_irq(cdev->int_params.msix_table[i].vector,
-					 qed_msix_sp_int, 0,
-					 cdev->hwfns[i].name,
-					 cdev->hwfns[i].sp_dpc);
-			if (rc)
-				break;
-
-			DP_VERBOSE(&cdev->hwfns[i],
-				   (NETIF_MSG_INTR | QED_MSG_SP),
+		id = hwfn->my_id;
+		snprintf(hwfn->name, NAME_SIZE, "sp-%d-%02x:%02x.%02x",
+			 id, cdev->pdev->bus->number,
+			 PCI_SLOT(cdev->pdev->devfn), hwfn->abs_pf_id);
+		rc = request_irq(cdev->int_params.msix_table[id].vector,
+				 qed_msix_sp_int, 0, hwfn->name, hwfn->sp_dpc);
+		if (!rc)
+			DP_VERBOSE(hwfn, (NETIF_MSG_INTR | QED_MSG_SP),
 				   "Requested slowpath MSI-X\n");
-		}
-
-		if (i != cdev->num_hwfns) {
-			/* Free already request MSI-X vectors */
-			for (i--; i >= 0; i--) {
-				unsigned int vec =
-					cdev->int_params.msix_table[i].vector;
-				synchronize_irq(vec);
-				free_irq(cdev->int_params.msix_table[i].vector,
-					 cdev->hwfns[i].sp_dpc);
-			}
-		}
 	} else {
 		unsigned long flags = 0;
 
@@ -534,13 +515,17 @@ static void qed_slowpath_irq_free(struct qed_dev *cdev)
 
 	if (cdev->int_params.out.int_mode == QED_INT_MODE_MSIX) {
 		for_each_hwfn(cdev, i) {
+			if (!cdev->hwfns[i].b_int_requested)
+				break;
 			synchronize_irq(cdev->int_params.msix_table[i].vector);
 			free_irq(cdev->int_params.msix_table[i].vector,
 				 cdev->hwfns[i].sp_dpc);
 		}
 	} else {
-		free_irq(cdev->pdev->irq, cdev);
+		if (QED_LEADING_HWFN(cdev)->b_int_requested)
+			free_irq(cdev->pdev->irq, cdev);
 	}
+	qed_int_disable_post_isr_release(cdev);
 }
 
 static int qed_nic_stop(struct qed_dev *cdev)
@@ -765,16 +750,11 @@ static int qed_slowpath_start(struct qed_dev *cdev,
 	if (rc)
 		goto err1;
 
-	/* Request the slowpath IRQ */
-	rc = qed_slowpath_irq_req(cdev);
-	if (rc)
-		goto err2;
-
 	/* Allocate stream for unzipping */
 	rc = qed_alloc_stream_mem(cdev);
 	if (rc) {
 		DP_NOTICE(cdev, "Failed to allocate stream memory\n");
-		goto err3;
+		goto err2;
 	}
 
 	/* Start the slowpath */
-- 
1.7.1
