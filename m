From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH v2 net 3/4] qed: Fix BAR size split for some servers
Date: Mon, 7 Dec 2015 06:25:58 -0500
Message-ID: <1449487559-31811-4-git-send-email-manish.chopra@qlogic.com>
References: <1449487559-31811-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:55869 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754516AbbLGMGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 07:06:25 -0500
In-Reply-To: <1449487559-31811-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <Ariel.Elior@qlogic.com>

Can't rely on pci config space to discover bar size,
as in some environments this returns a wrong, too large value.
Instead, rely on device register, which contains the value
provided by MFW at preboot.

Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c      |   53 ++++++++++++++---------
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h |    4 ++
 2 files changed, 36 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 803b190..817bbd5 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -1385,52 +1385,63 @@ err0:
 	return rc;
 }
 
-static u32 qed_hw_bar_size(struct qed_dev *cdev,
-			   u8 bar_id)
+static u32 qed_hw_bar_size(struct qed_hwfn	*p_hwfn,
+			   u8			bar_id)
 {
-	u32 size = pci_resource_len(cdev->pdev, (bar_id > 0) ? 2 : 0);
+	u32 bar_reg = (bar_id == 0 ? PGLUE_B_REG_PF_BAR0_SIZE
+		       : PGLUE_B_REG_PF_BAR1_SIZE);
+	u32 val = qed_rd(p_hwfn, p_hwfn->p_main_ptt, bar_reg);
 
-	return size / cdev->num_hwfns;
+	/* Get the BAR size(in KB) from hardware given val */
+	return 1 << (val + 15);
 }
 
 int qed_hw_prepare(struct qed_dev *cdev,
 		   int personality)
 {
-	int rc, i;
+	struct qed_hwfn *p_hwfn = QED_LEADING_HWFN(cdev);
+	int rc;
 
 	/* Store the precompiled init data ptrs */
 	qed_init_iro_array(cdev);
 
 	/* Initialize the first hwfn - will learn number of hwfns */
-	rc = qed_hw_prepare_single(&cdev->hwfns[0], cdev->regview,
+	rc = qed_hw_prepare_single(p_hwfn,
+				   cdev->regview,
 				   cdev->doorbells, personality);
 	if (rc)
 		return rc;
 
-	personality = cdev->hwfns[0].hw_info.personality;
+	personality = p_hwfn->hw_info.personality;
 
 	/* Initialize the rest of the hwfns */
-	for (i = 1; i < cdev->num_hwfns; i++) {
+	if (cdev->num_hwfns > 1) {
 		void __iomem *p_regview, *p_doorbell;
+		u8 __iomem *addr;
+
+		/* adjust bar offset for second engine */
+		addr = cdev->regview + qed_hw_bar_size(p_hwfn, 0) / 2;
+		p_regview = addr;
 
-		p_regview =  cdev->regview +
-			     i * qed_hw_bar_size(cdev, 0);
-		p_doorbell = cdev->doorbells +
-			     i * qed_hw_bar_size(cdev, 1);
-		rc = qed_hw_prepare_single(&cdev->hwfns[i], p_regview,
+		/* adjust doorbell bar offset for second engine */
+		addr = cdev->doorbells + qed_hw_bar_size(p_hwfn, 1) / 2;
+		p_doorbell = addr;
+
+		/* prepare second hw function */
+		rc = qed_hw_prepare_single(&cdev->hwfns[1], p_regview,
 					   p_doorbell, personality);
+
+		/* in case of error, need to free the previously
+		 * initiliazed hwfn 0.
+		 */
 		if (rc) {
-			/* Cleanup previously initialized hwfns */
-			while (--i >= 0) {
-				qed_init_free(&cdev->hwfns[i]);
-				qed_mcp_free(&cdev->hwfns[i]);
-				qed_hw_hwfn_free(&cdev->hwfns[i]);
-			}
-			return rc;
+			qed_init_free(p_hwfn);
+			qed_mcp_free(p_hwfn);
+			qed_hw_hwfn_free(p_hwfn);
 		}
 	}
 
-	return 0;
+	return rc;
 }
 
 void qed_hw_remove(struct qed_dev *cdev)
diff --git a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
index 7a5ce59..e8df123 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
@@ -363,4 +363,8 @@
 		0x7 << 0)
 #define  MCP_REG_NVM_CFG4_FLASH_SIZE_SHIFT \
 	0
+#define PGLUE_B_REG_PF_BAR0_SIZE \
+	0x2aae60UL
+#define PGLUE_B_REG_PF_BAR1_SIZE \
+	0x2aae64UL
 #endif
-- 
1.7.1
