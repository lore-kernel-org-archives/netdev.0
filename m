From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH v2 net] bnx2x: Configure device endianity on driver load and reset endianity on removal.
Date: Tue, 2 Sep 2014 04:31:25 -0400
Message-ID: <1409646685-28320-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:32512 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750903AbaIBJEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 05:04:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some hosts can be both little and big endian.
In certain scenarios a big endian kernel can kexec a little endian kernel.

This patch fixes this case from both ends:
1) Return endianity to original values on shutdown (in case little endian kernel boots after we shutdown).
2) Do not rely on HW reset values when loading driver in little endian kernel
   but configure them explicitly (in case previous kernel was big endian and did not reset the HW).

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---

Hi David,

Please consider applying this patch to `net'
v2: Reset endianity registers on driver removal under IS_PF(bp) check.

Thanks,
Manish

---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   57 +++++++++++++++-------
 1 files changed, 39 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 900cab4..f6bd5ec 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -6849,6 +6849,37 @@ static void bnx2x__common_init_phy(struct bnx2x *bp)
 	bnx2x_release_phy_lock(bp);
 }
 
+static void bnx2x_config_endianity(struct bnx2x *bp, u32 val)
+{
+	REG_WR(bp, PXP2_REG_RQ_QM_ENDIAN_M, val);
+	REG_WR(bp, PXP2_REG_RQ_TM_ENDIAN_M, val);
+	REG_WR(bp, PXP2_REG_RQ_SRC_ENDIAN_M, val);
+	REG_WR(bp, PXP2_REG_RQ_CDU_ENDIAN_M, val);
+	REG_WR(bp, PXP2_REG_RQ_DBG_ENDIAN_M, val);
+
+	/* make sure this value is 0 */
+	REG_WR(bp, PXP2_REG_RQ_HC_ENDIAN_M, 0);
+
+	REG_WR(bp, PXP2_REG_RD_QM_SWAP_MODE, val);
+	REG_WR(bp, PXP2_REG_RD_TM_SWAP_MODE, val);
+	REG_WR(bp, PXP2_REG_RD_SRC_SWAP_MODE, val);
+	REG_WR(bp, PXP2_REG_RD_CDURD_SWAP_MODE, val);
+}
+
+static void bnx2x_set_endianity(struct bnx2x *bp)
+{
+#ifdef __BIG_ENDIAN
+	bnx2x_config_endianity(bp, 1);
+#else
+	bnx2x_config_endianity(bp, 0);
+#endif
+}
+
+static void bnx2x_reset_endianity(struct bnx2x *bp)
+{
+	bnx2x_config_endianity(bp, 0);
+}
+
 /**
  * bnx2x_init_hw_common - initialize the HW at the COMMON phase.
  *
@@ -6915,23 +6946,7 @@ static int bnx2x_init_hw_common(struct bnx2x *bp)
 
 	bnx2x_init_block(bp, BLOCK_PXP2, PHASE_COMMON);
 	bnx2x_init_pxp(bp);
-
-#ifdef __BIG_ENDIAN
-	REG_WR(bp, PXP2_REG_RQ_QM_ENDIAN_M, 1);
-	REG_WR(bp, PXP2_REG_RQ_TM_ENDIAN_M, 1);
-	REG_WR(bp, PXP2_REG_RQ_SRC_ENDIAN_M, 1);
-	REG_WR(bp, PXP2_REG_RQ_CDU_ENDIAN_M, 1);
-	REG_WR(bp, PXP2_REG_RQ_DBG_ENDIAN_M, 1);
-	/* make sure this value is 0 */
-	REG_WR(bp, PXP2_REG_RQ_HC_ENDIAN_M, 0);
-
-/*	REG_WR(bp, PXP2_REG_RD_PBF_SWAP_MODE, 1); */
-	REG_WR(bp, PXP2_REG_RD_QM_SWAP_MODE, 1);
-	REG_WR(bp, PXP2_REG_RD_TM_SWAP_MODE, 1);
-	REG_WR(bp, PXP2_REG_RD_SRC_SWAP_MODE, 1);
-	REG_WR(bp, PXP2_REG_RD_CDURD_SWAP_MODE, 1);
-#endif
-
+	bnx2x_set_endianity(bp);
 	bnx2x_ilt_init_page_size(bp, INITOP_SET);
 
 	if (CHIP_REV_IS_FPGA(bp) && CHIP_IS_E1H(bp))
@@ -13169,9 +13184,15 @@ static void __bnx2x_remove(struct pci_dev *pdev,
 	bnx2x_iov_remove_one(bp);
 
 	/* Power on: we can't let PCI layer write to us while we are in D3 */
-	if (IS_PF(bp))
+	if (IS_PF(bp)) {
 		bnx2x_set_power_state(bp, PCI_D0);
 
+		/* Set endianity registers to reset values in case next driver
+		 * boots in different endianty environment.
+		 */
+		bnx2x_reset_endianity(bp);
+	}
+
 	/* Disable MSI/MSI-X */
 	bnx2x_disable_msi(bp);
 
-- 
1.7.1
