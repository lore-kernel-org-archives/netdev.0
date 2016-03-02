From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 2/6] qed: Support B0 instead of A0
Date: Wed, 2 Mar 2016 20:26:01 +0200
Message-ID: <1456943165-15198-3-git-send-email-Yuval.Mintz@qlogic.com>
References: <1456943165-15198-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:38781 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754927AbcCBS0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 13:26:24 -0500
In-Reply-To: <1456943165-15198-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BB_A0 is a development model that is will not reach actual clients.
In fact, future firmware would simply fail to initialize such chip.

This changes the configuration into B0 instead of A0, and adds a safeguard
against the slim chance someone would actually try this with an A0 adapter
in which case probe would gracefully fail.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c | 41 +++++++++++++++++--------------
 drivers/net/ethernet/qlogic/qed/qed_hsi.h |  2 +-
 2 files changed, 24 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 706c614..2e02e05 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -420,7 +420,7 @@ static void qed_calc_hw_mode(struct qed_hwfn *p_hwfn)
 {
 	int hw_mode = 0;
 
-	hw_mode = (1 << MODE_BB_A0);
+	hw_mode = (1 << MODE_BB_B0);
 
 	switch (p_hwfn->cdev->num_ports_in_engines) {
 	case 1:
@@ -976,18 +976,8 @@ static void qed_hw_hwfn_free(struct qed_hwfn *p_hwfn)
 }
 
 /* Setup bar access */
-static int qed_hw_hwfn_prepare(struct qed_hwfn *p_hwfn)
+static void qed_hw_hwfn_prepare(struct qed_hwfn *p_hwfn)
 {
-	int rc;
-
-	/* Allocate PTT pool */
-	rc = qed_ptt_pool_alloc(p_hwfn);
-	if (rc)
-		return rc;
-
-	/* Allocate the main PTT */
-	p_hwfn->p_main_ptt = qed_get_reserved_ptt(p_hwfn, RESERVED_PTT_MAIN);
-
 	/* clear indirect access */
 	qed_wr(p_hwfn, p_hwfn->p_main_ptt, PGLUE_B_REG_PGL_ADDR_88_F0, 0);
 	qed_wr(p_hwfn, p_hwfn->p_main_ptt, PGLUE_B_REG_PGL_ADDR_8C_F0, 0);
@@ -1002,8 +992,6 @@ static int qed_hw_hwfn_prepare(struct qed_hwfn *p_hwfn)
 	/* enable internal target-read */
 	qed_wr(p_hwfn, p_hwfn->p_main_ptt,
 	       PGLUE_B_REG_INTERNAL_PFID_ENABLE_TARGET_READ, 1);
-
-	return 0;
 }
 
 static void get_function_id(struct qed_hwfn *p_hwfn)
@@ -1311,7 +1299,7 @@ qed_get_hw_info(struct qed_hwfn *p_hwfn,
 	return rc;
 }
 
-static void qed_get_dev_info(struct qed_dev *cdev)
+static int qed_get_dev_info(struct qed_dev *cdev)
 {
 	struct qed_hwfn *p_hwfn = QED_LEADING_HWFN(cdev);
 	u32 tmp;
@@ -1350,6 +1338,14 @@ static void qed_get_dev_info(struct qed_dev *cdev)
 		"Chip details - Num: %04x Rev: %04x Bond id: %04x Metal: %04x\n",
 		cdev->chip_num, cdev->chip_rev,
 		cdev->chip_bond_id, cdev->chip_metal);
+
+	if (QED_IS_BB(cdev) && CHIP_REV_IS_A0(cdev)) {
+		DP_NOTICE(cdev->hwfns,
+			  "The chip type/rev (BB A0) is not supported!\n");
+		return -EINVAL;
+	}
+
+	return 0;
 }
 
 static int qed_hw_prepare_single(struct qed_hwfn *p_hwfn,
@@ -1372,15 +1368,24 @@ static int qed_hw_prepare_single(struct qed_hwfn *p_hwfn,
 
 	get_function_id(p_hwfn);
 
-	rc = qed_hw_hwfn_prepare(p_hwfn);
+	/* Allocate PTT pool */
+	rc = qed_ptt_pool_alloc(p_hwfn);
 	if (rc) {
 		DP_NOTICE(p_hwfn, "Failed to prepare hwfn's hw\n");
 		goto err0;
 	}
 
+	/* Allocate the main PTT */
+	p_hwfn->p_main_ptt = qed_get_reserved_ptt(p_hwfn, RESERVED_PTT_MAIN);
+
 	/* First hwfn learns basic information, e.g., number of hwfns */
-	if (!p_hwfn->my_id)
-		qed_get_dev_info(p_hwfn->cdev);
+	if (!p_hwfn->my_id) {
+		rc = qed_get_dev_info(p_hwfn->cdev);
+		if (rc != 0)
+			goto err1;
+	}
+
+	qed_hw_hwfn_prepare(p_hwfn);
 
 	/* Initialize MCP structure */
 	rc = qed_mcp_cmd_init(p_hwfn, p_hwfn->p_main_ptt);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
index 49bbf69..592e0e6 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hsi.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
@@ -968,7 +968,7 @@ struct igu_msix_vector {
 
 enum init_modes {
 	MODE_BB_A0,
-	MODE_RESERVED,
+	MODE_BB_B0,
 	MODE_RESERVED2,
 	MODE_ASIC,
 	MODE_RESERVED3,
-- 
1.9.3
