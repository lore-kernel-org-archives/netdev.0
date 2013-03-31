From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next] bnx2x: handle spurious interrupts
Date: Sun, 31 Mar 2013 14:35:01 +0300
Message-ID: <1364729701-18855-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2863 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750935Ab3CaMjg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Mar 2013 08:39:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In scenarios in which a previous driver was removed without proper cleanup
(e.g., kdump), it is possible for the chip to generate an interrupt without
any apparent reason once interrupts are requested.

This patch introduces 2 changes:

  - It changes bnx2x's interrupt request scheme so that bnx2x would only
    request interrupts from the kernel after it has finished initializing
    all the inner structs required for those interrupts' handling.

  - The driver ignores any interrupt which arrives in an inappropriate time,
    i.e., when the HW generates interrupts without being configured to do so.
    Acking the HW for such an interrupt will prevent HW from generating further
    interrupts, thus ignoring them is necessary.
   
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
Hi Dave,

This is the revised patch (didn't know if v2 was appropriate, as most
changes are newly introduced).

Please apply this patch to `net-next'.

Thanks,
Yuval

---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |  1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  | 26 ++++++++++++++----------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |  9 +++++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 21 ++++++++++++++++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c |  3 ++-
 5 files changed, 44 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index c630342..5f181ee 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1391,6 +1391,7 @@ struct bnx2x {
 #define USING_SINGLE_MSIX_FLAG		(1 << 20)
 #define BC_SUPPORTS_DCBX_MSG_NON_PMF	(1 << 21)
 #define IS_VF_FLAG			(1 << 22)
+#define INTERRUPTS_ENABLED_FLAG	(1 << 23)
 
 #define BP_NOMCP(bp)			((bp)->flags & NO_MCP_FLAG)
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 352e58e..d256ffd 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1038,6 +1038,17 @@ static irqreturn_t bnx2x_msix_fp_int(int irq, void *fp_cookie)
 	DP(NETIF_MSG_INTR,
 	   "got an MSI-X interrupt on IDX:SB [fp %d fw_sd %d igusb %d]\n",
 	   fp->index, fp->fw_sb_id, fp->igu_sb_id);
+
+	/* It's possible for a spurious interrupt to be received, if the
+	 * driver was loaded above a previous configured function (e.g., kdump).
+	 * We simply ignore such interrupts.
+	 */
+	if (unlikely(!(bp->flags & INTERRUPTS_ENABLED_FLAG))) {
+		WARN_ONCE(1, "%s: Got Spurious interrupts",
+			  bp->dev ? bp->dev->name : "?");
+		return IRQ_HANDLED;
+	}
+
 	bnx2x_ack_sb(bp, fp->igu_sb_id, USTORM_ID, 0, IGU_INT_DISABLE, 0);
 
 #ifdef BNX2X_STOP_ON_ERROR
@@ -1719,7 +1730,7 @@ static int bnx2x_req_irq(struct bnx2x *bp)
 	return request_irq(irq, bnx2x_interrupt, flags, bp->dev->name, bp->dev);
 }
 
-static int bnx2x_setup_irqs(struct bnx2x *bp)
+int bnx2x_setup_irqs(struct bnx2x *bp)
 {
 	int rc = 0;
 	if (bp->flags & USING_MSIX_FLAG &&
@@ -2575,17 +2586,10 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		}
 	}
 
-	/* Connect to IRQs */
-	rc = bnx2x_setup_irqs(bp);
-	if (rc) {
-		BNX2X_ERR("setup irqs failed\n");
-		if (IS_PF(bp))
-			bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_DONE, 0);
-		LOAD_ERROR_EXIT(bp, load_error2);
-	}
-
 	/* Setup NIC internals and enable interrupts */
-	bnx2x_nic_init(bp, load_code);
+	rc = bnx2x_nic_init(bp, load_code);
+	if (rc)
+		LOAD_ERROR_EXIT(bp, load_error2);
 
 	/* Init per-function objects */
 	if (IS_PF(bp)) {
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 54e1b14..84ae16c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -304,7 +304,7 @@ void bnx2x_nic_init_cnic(struct bnx2x *bp);
  *  - status blocks
  *  - etc.
  */
-void bnx2x_nic_init(struct bnx2x *bp, u32 load_code);
+int bnx2x_nic_init(struct bnx2x *bp, u32 load_code);
 /**
  * bnx2x_alloc_mem_cnic - allocate driver's memory for cnic.
  *
@@ -1406,4 +1406,11 @@ void bnx2x_fill_fw_str(struct bnx2x *bp, char *buf, size_t buf_len);
 int bnx2x_drain_tx_queues(struct bnx2x *bp);
 void bnx2x_squeeze_objects(struct bnx2x *bp);
 
+/**
+ * bnx2x_setup_irqs - Request MSI-X/MSI/INTa interrupt from kernel
+ *
+ * @bp - driver handle
+ */
+int bnx2x_setup_irqs(struct bnx2x *bp);
+
 #endif /* BNX2X_CMN_H */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index fdfe33b..960b453 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -866,6 +866,7 @@ static void bnx2x_int_disable(struct bnx2x *bp)
 		bnx2x_hc_int_disable(bp);
 	else
 		bnx2x_igu_int_disable(bp);
+	bp->flags &= ~INTERRUPTS_ENABLED_FLAG;
 }
 
 void bnx2x_panic_dump(struct bnx2x *bp, bool disable_int)
@@ -1605,6 +1606,8 @@ static void bnx2x_igu_int_enable(struct bnx2x *bp)
 
 void bnx2x_int_enable(struct bnx2x *bp)
 {
+	bp->flags |= INTERRUPTS_ENABLED_FLAG;
+
 	if (bp->common.int_block == INT_BLOCK_HC)
 		bnx2x_hc_int_enable(bp);
 	else
@@ -6030,9 +6033,9 @@ void bnx2x_nic_init_cnic(struct bnx2x *bp)
 	mmiowb();
 }
 
-void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
+int bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
 {
-	int i;
+	int i, rc;
 
 	for_each_eth_queue(bp, i)
 		bnx2x_init_eth_fp(bp, i);
@@ -6043,7 +6046,7 @@ void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
 	bnx2x_init_tx_rings(bp);
 	if (IS_VF(bp)) {
 		bnx2x_memset_stats(bp);
-		return;
+		return 0;
 	}
 
 	/* Initialize MOD_ABS interrupts */
@@ -6054,6 +6057,16 @@ void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
 	bnx2x_init_def_sb(bp);
 	bnx2x_update_dsb_idx(bp);
 	bnx2x_init_sp_ring(bp);
+
+	/* Connect to IRQs */
+	rc = bnx2x_setup_irqs(bp);
+	if (rc) {
+		BNX2X_ERR("setup irqs failed\n");
+		if (IS_PF(bp))
+			bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_DONE, 0);
+		return rc;
+	}
+
 	bnx2x_init_eq_ring(bp);
 	bnx2x_init_internal(bp, load_code);
 	bnx2x_pf_init(bp);
@@ -6069,6 +6082,8 @@ void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
 	bnx2x_attn_int_deasserted0(bp,
 		REG_RD(bp, MISC_REG_AEU_AFTER_INVERT_1_FUNC_0 + BP_PORT(bp)*4) &
 				   AEU_INPUTS_ATTN_BITS_SPIO5);
+
+	return 0;
 }
 
 /* end of nic init */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index 90fbf9c..2017901 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -282,7 +282,8 @@ int bnx2x_vfpf_acquire(struct bnx2x *bp, u8 tx_count, u8 rx_count)
 	bp->mf_mode = 0;
 	bp->common.flash_size = 0;
 	bp->flags |=
-		NO_WOL_FLAG | NO_ISCSI_OOO_FLAG | NO_ISCSI_FLAG | NO_FCOE_FLAG;
+		NO_WOL_FLAG | NO_ISCSI_OOO_FLAG | NO_ISCSI_FLAG | NO_FCOE_FLAG |
+		INTERRUPTS_ENABLED_FLAG;
 	bp->igu_sb_cnt = 1;
 	bp->igu_base_sb = bp->acquire_resp.resc.hw_sbs[0].hw_sb_id;
 	strlcpy(bp->fw_ver, bp->acquire_resp.pfdev_info.fw_ver,
-- 
1.8.1.227.g44fe835
