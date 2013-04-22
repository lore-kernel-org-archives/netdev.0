From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net] bnx2x: Prevent NULL pointer dereference in kdump
Date: Mon, 22 Apr 2013 15:53:03 +0300
Message-ID: <1366635183-9541-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Ariel Elior" <ariele@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3655 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751738Ab3DVNyj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Apr 2013 09:54:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In scenarios in which a previous driver was removed without proper cleanup
(e.g., kdump), it is possible for the chip to generate an interrupt without
any apparent reason once interrupts are requested.

Due to an erroneous initialization of resources, some of the bnx2x structs
which are required for interrupt handling are initialized only after an
interface's interrupt is requested from the OS.

As a result, once such a spurious interrupt occurs, it will cause a NULL
pointer dereference - the driver will access those structs in its interrupt
handling routine.

This patch change the interrupt request scheme so that bnx2x would only
request interrupts from the kernel after it has finished initializing
all the inner structs required for interrupt handling.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
Hi Dave,

This patch follows the previously rejected `bnx2x: handle spurious interrupts'.

After verifying that by re-arranging the order by which interrupts' resource
were allocated and requested, we could no longer re-produce the Spurious
interrupt issue, we've dropped the spurious flag.

Please consider applying this patch to `net'.

Thanks,
Yuval Mintz
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  | 11 +++++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  | 19 +++++++++++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 32 ++++++++++++------------
 3 files changed, 39 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 57619dd..51a6030 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1037,6 +1037,7 @@ static irqreturn_t bnx2x_msix_fp_int(int irq, void *fp_cookie)
 	DP(NETIF_MSG_INTR,
 	   "got an MSI-X interrupt on IDX:SB [fp %d fw_sd %d igusb %d]\n",
 	   fp->index, fp->fw_sb_id, fp->igu_sb_id);
+
 	bnx2x_ack_sb(bp, fp->igu_sb_id, USTORM_ID, 0, IGU_INT_DISABLE, 0);
 
 #ifdef BNX2X_STOP_ON_ERROR
@@ -1718,7 +1719,7 @@ static int bnx2x_req_irq(struct bnx2x *bp)
 	return request_irq(irq, bnx2x_interrupt, flags, bp->dev->name, bp->dev);
 }
 
-static int bnx2x_setup_irqs(struct bnx2x *bp)
+int bnx2x_setup_irqs(struct bnx2x *bp)
 {
 	int rc = 0;
 	if (bp->flags & USING_MSIX_FLAG &&
@@ -2574,6 +2575,8 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		}
 	}
 
+	bnx2x_pre_irq_nic_init(bp);
+
 	/* Connect to IRQs */
 	rc = bnx2x_setup_irqs(bp);
 	if (rc) {
@@ -2583,11 +2586,11 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		LOAD_ERROR_EXIT(bp, load_error2);
 	}
 
-	/* Setup NIC internals and enable interrupts */
-	bnx2x_nic_init(bp, load_code);
-
 	/* Init per-function objects */
 	if (IS_PF(bp)) {
+		/* Setup NIC internals and enable interrupts */
+		bnx2x_post_irq_nic_init(bp, load_code);
+
 		bnx2x_init_bp_objs(bp);
 		bnx2x_iov_nic_init(bp);
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index aee7671..c3a65d0 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -295,16 +295,29 @@ void bnx2x_int_disable_sync(struct bnx2x *bp, int disable_hw);
 void bnx2x_nic_init_cnic(struct bnx2x *bp);
 
 /**
- * bnx2x_nic_init - init driver internals.
+ * bnx2x_preirq_nic_init - init driver internals.
  *
  * @bp:		driver handle
  *
  * Initializes:
- *  - rings
+ *  - fastpath object
+ *  - fastpath rings
+ *  etc.
+ */
+void bnx2x_pre_irq_nic_init(struct bnx2x *bp);
+
+/**
+ * bnx2x_postirq_nic_init - init driver internals.
+ *
+ * @bp:		driver handle
+ * @load_code:	COMMON, PORT or FUNCTION
+ *
+ * Initializes:
  *  - status blocks
+ *  - slowpath rings
  *  - etc.
  */
-void bnx2x_nic_init(struct bnx2x *bp, u32 load_code);
+void bnx2x_post_irq_nic_init(struct bnx2x *bp, u32 load_code);
 /**
  * bnx2x_alloc_mem_cnic - allocate driver's memory for cnic.
  *
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index c50696b..a8f1ee3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -6018,10 +6018,11 @@ void bnx2x_nic_init_cnic(struct bnx2x *bp)
 	mmiowb();
 }
 
-void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
+void bnx2x_pre_irq_nic_init(struct bnx2x *bp)
 {
 	int i;
 
+	/* Setup NIC internals and enable interrupts */
 	for_each_eth_queue(bp, i)
 		bnx2x_init_eth_fp(bp, i);
 
@@ -6030,17 +6031,21 @@ void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
 	bnx2x_init_rx_rings(bp);
 	bnx2x_init_tx_rings(bp);
 
-	if (IS_VF(bp))
-		return;
+	if (IS_PF(bp)) {
+		/* Initialize MOD_ABS interrupts */
+		bnx2x_init_mod_abs_int(bp, &bp->link_vars, bp->common.chip_id,
+				       bp->common.shmem_base,
+				       bp->common.shmem2_base, BP_PORT(bp));
 
-	/* Initialize MOD_ABS interrupts */
-	bnx2x_init_mod_abs_int(bp, &bp->link_vars, bp->common.chip_id,
-			       bp->common.shmem_base, bp->common.shmem2_base,
-			       BP_PORT(bp));
+		/* initialize the default status block and sp ring */
+		bnx2x_init_def_sb(bp);
+		bnx2x_update_dsb_idx(bp);
+		bnx2x_init_sp_ring(bp);
+	}
+}
 
-	bnx2x_init_def_sb(bp);
-	bnx2x_update_dsb_idx(bp);
-	bnx2x_init_sp_ring(bp);
+void bnx2x_post_irq_nic_init(struct bnx2x *bp, u32 load_code)
+{
 	bnx2x_init_eq_ring(bp);
 	bnx2x_init_internal(bp, load_code);
 	bnx2x_pf_init(bp);
@@ -6058,12 +6063,7 @@ void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
 				   AEU_INPUTS_ATTN_BITS_SPIO5);
 }
 
-/* end of nic init */
-
-/*
- * gzip service functions
- */
-
+/* gzip service functions */
 static int bnx2x_gunzip_init(struct bnx2x *bp)
 {
 	bp->gunzip_buf = dma_alloc_coherent(&bp->pdev->dev, FW_BUF_SIZE,
-- 
1.8.1.227.g44fe835
