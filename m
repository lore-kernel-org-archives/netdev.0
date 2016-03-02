From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 1/6] qed: Correct BAR sizes for older MFW
Date: Wed, 2 Mar 2016 20:26:00 +0200
Message-ID: <1456943165-15198-2-git-send-email-Yuval.Mintz@qlogic.com>
References: <1456943165-15198-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ram Amrani <Ram.Amrani@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:62833 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756033AbcCBS0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 13:26:20 -0500
In-Reply-To: <1456943165-15198-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ram Amrani <Ram.Amrani@qlogic.com>

Driver learns the inner bar sized from a register configured by management
firmware, but older versions are not setting this register.
But since we know which values were configured back then, use them instead.

Signed-off-by: Ram Amrani <Ram.Amrani@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c | 42 +++++++++++++++++++++----------
 1 file changed, 29 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index d9a5175..706c614 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -32,6 +32,33 @@
 #include "qed_sp.h"
 
 /* API common to all protocols */
+enum BAR_ID {
+	BAR_ID_0,       /* used for GRC */
+	BAR_ID_1        /* Used for doorbells */
+};
+
+static u32 qed_hw_bar_size(struct qed_hwfn	*p_hwfn,
+			   enum BAR_ID		bar_id)
+{
+	u32	bar_reg = (bar_id == BAR_ID_0 ?
+			   PGLUE_B_REG_PF_BAR0_SIZE : PGLUE_B_REG_PF_BAR1_SIZE);
+	u32	val = qed_rd(p_hwfn, p_hwfn->p_main_ptt, bar_reg);
+
+	if (val)
+		return 1 << (val + 15);
+
+	/* Old MFW initialized above registered only conditionally */
+	if (p_hwfn->cdev->num_hwfns > 1) {
+		DP_INFO(p_hwfn,
+			"BAR size not configured. Assuming BAR size of 256kB for GRC and 512kB for DB\n");
+			return BAR_ID_0 ? 256 * 1024 : 512 * 1024;
+	} else {
+		DP_INFO(p_hwfn,
+			"BAR size not configured. Assuming BAR size of 512kB for GRC and 512kB for DB\n");
+			return 512 * 1024;
+	}
+}
+
 void qed_init_dp(struct qed_dev *cdev,
 		 u32 dp_module, u8 dp_level)
 {
@@ -1385,17 +1412,6 @@ err0:
 	return rc;
 }
 
-static u32 qed_hw_bar_size(struct qed_hwfn	*p_hwfn,
-			   u8			bar_id)
-{
-	u32 bar_reg = (bar_id == 0 ? PGLUE_B_REG_PF_BAR0_SIZE
-		       : PGLUE_B_REG_PF_BAR1_SIZE);
-	u32 val = qed_rd(p_hwfn, p_hwfn->p_main_ptt, bar_reg);
-
-	/* Get the BAR size(in KB) from hardware given val */
-	return 1 << (val + 15);
-}
-
 int qed_hw_prepare(struct qed_dev *cdev,
 		   int personality)
 {
@@ -1420,11 +1436,11 @@ int qed_hw_prepare(struct qed_dev *cdev,
 		u8 __iomem *addr;
 
 		/* adjust bar offset for second engine */
-		addr = cdev->regview + qed_hw_bar_size(p_hwfn, 0) / 2;
+		addr = cdev->regview + qed_hw_bar_size(p_hwfn, BAR_ID_0) / 2;
 		p_regview = addr;
 
 		/* adjust doorbell bar offset for second engine */
-		addr = cdev->doorbells + qed_hw_bar_size(p_hwfn, 1) / 2;
+		addr = cdev->doorbells + qed_hw_bar_size(p_hwfn, BAR_ID_1) / 2;
 		p_doorbell = addr;
 
 		/* prepare second hw function */
-- 
1.9.3
