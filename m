From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 1/2] bna: fix for clean fw re-initialization
Date: Thu, 14 Apr 2011 11:05:18 -0700
Message-ID: <1302804319-15677-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rasesh Mody <rmody@brocade.com>, Debashis Dutt <ddutt@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:53577 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933825Ab1DNSGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 14:06:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During a kernel crash, bna control path state machine and firmware do not
get a notification and hence are not cleanly shutdown. The registers
holding driver/IOC state information are not reset back to valid
disabled/parking values. This causes subsequent driver initialization
to hang during kdump kernel boot. This patch, during the initialization
of first PCI function, resets corresponding register when unclean shutown
is detect by reading chip registers. This will make sure that ioc/fw
gets clean re-initialization.

Signed-off-by: Debashis Dutt <ddutt@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_ioc.c    |   31 ++++++++++++++++++-------------
 drivers/net/bna/bfa_ioc.h    |    1 +
 drivers/net/bna/bfa_ioc_ct.c |   28 ++++++++++++++++++++++++++++
 drivers/net/bna/bfi.h        |    6 ++++--
 4 files changed, 51 insertions(+), 15 deletions(-)

diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index e3de0b8..7581518 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -38,6 +38,8 @@
 #define bfa_ioc_map_port(__ioc) ((__ioc)->ioc_hwif->ioc_map_port(__ioc))
 #define bfa_ioc_notify_fail(__ioc)			\
 			((__ioc)->ioc_hwif->ioc_notify_fail(__ioc))
+#define bfa_ioc_sync_start(__ioc)               \
+			((__ioc)->ioc_hwif->ioc_sync_start(__ioc))
 #define bfa_ioc_sync_join(__ioc)			\
 			((__ioc)->ioc_hwif->ioc_sync_join(__ioc))
 #define bfa_ioc_sync_leave(__ioc)			\
@@ -602,7 +604,7 @@ bfa_iocpf_sm_fwcheck(struct bfa_iocpf *iocpf, enum iocpf_event event)
 	switch (event) {
 	case IOCPF_E_SEMLOCKED:
 		if (bfa_ioc_firmware_lock(ioc)) {
-			if (bfa_ioc_sync_complete(ioc)) {
+			if (bfa_ioc_sync_start(ioc)) {
 				iocpf->retry_count = 0;
 				bfa_ioc_sync_join(ioc);
 				bfa_fsm_set_state(iocpf, bfa_iocpf_sm_hwinit);
@@ -1314,7 +1316,7 @@ bfa_nw_ioc_fwver_cmp(struct bfa_ioc *ioc, struct bfi_ioc_image_hdr *fwhdr)
  * execution context (driver/bios) must match.
  */
 static bool
-bfa_ioc_fwver_valid(struct bfa_ioc *ioc)
+bfa_ioc_fwver_valid(struct bfa_ioc *ioc, u32 boot_env)
 {
 	struct bfi_ioc_image_hdr fwhdr, *drv_fwhdr;
 
@@ -1325,7 +1327,7 @@ bfa_ioc_fwver_valid(struct bfa_ioc *ioc)
 	if (fwhdr.signature != drv_fwhdr->signature)
 		return false;
 
-	if (fwhdr.exec != drv_fwhdr->exec)
+	if (swab32(fwhdr.param) != boot_env)
 		return false;
 
 	return bfa_nw_ioc_fwver_cmp(ioc, &fwhdr);
@@ -1352,9 +1354,12 @@ bfa_ioc_hwinit(struct bfa_ioc *ioc, bool force)
 {
 	enum bfi_ioc_state ioc_fwstate;
 	bool fwvalid;
+	u32 boot_env;
 
 	ioc_fwstate = readl(ioc->ioc_regs.ioc_fwstate);
 
+	boot_env = BFI_BOOT_LOADER_OS;
+
 	if (force)
 		ioc_fwstate = BFI_IOC_UNINIT;
 
@@ -1362,10 +1367,10 @@ bfa_ioc_hwinit(struct bfa_ioc *ioc, bool force)
 	 * check if firmware is valid
 	 */
 	fwvalid = (ioc_fwstate == BFI_IOC_UNINIT) ?
-		false : bfa_ioc_fwver_valid(ioc);
+		false : bfa_ioc_fwver_valid(ioc, boot_env);
 
 	if (!fwvalid) {
-		bfa_ioc_boot(ioc, BFI_BOOT_TYPE_NORMAL, ioc->pcidev.device_id);
+		bfa_ioc_boot(ioc, BFI_BOOT_TYPE_NORMAL, boot_env);
 		return;
 	}
 
@@ -1396,7 +1401,7 @@ bfa_ioc_hwinit(struct bfa_ioc *ioc, bool force)
 	/**
 	 * Initialize the h/w for any other states.
 	 */
-	bfa_ioc_boot(ioc, BFI_BOOT_TYPE_NORMAL, ioc->pcidev.device_id);
+	bfa_ioc_boot(ioc, BFI_BOOT_TYPE_NORMAL, boot_env);
 }
 
 void
@@ -1506,7 +1511,7 @@ bfa_ioc_hb_stop(struct bfa_ioc *ioc)
  */
 static void
 bfa_ioc_download_fw(struct bfa_ioc *ioc, u32 boot_type,
-		    u32 boot_param)
+		    u32 boot_env)
 {
 	u32 *fwimg;
 	u32 pgnum, pgoff;
@@ -1558,10 +1563,10 @@ bfa_ioc_download_fw(struct bfa_ioc *ioc, u32 boot_type,
 	/*
 	 * Set boot type and boot param at the end.
 	*/
-	writel((swab32(swab32(boot_type))), ((ioc->ioc_regs.smem_page_start)
+	writel(boot_type, ((ioc->ioc_regs.smem_page_start)
 			+ (BFI_BOOT_TYPE_OFF)));
-	writel((swab32(swab32(boot_param))), ((ioc->ioc_regs.smem_page_start)
-			+ (BFI_BOOT_PARAM_OFF)));
+	writel(boot_env, ((ioc->ioc_regs.smem_page_start)
+			+ (BFI_BOOT_LOADER_OFF)));
 }
 
 static void
@@ -1721,7 +1726,7 @@ bfa_ioc_pll_init(struct bfa_ioc *ioc)
  * as the entry vector.
  */
 static void
-bfa_ioc_boot(struct bfa_ioc *ioc, u32 boot_type, u32 boot_param)
+bfa_ioc_boot(struct bfa_ioc *ioc, u32 boot_type, u32 boot_env)
 {
 	void __iomem *rb;
 
@@ -1734,7 +1739,7 @@ bfa_ioc_boot(struct bfa_ioc *ioc, u32 boot_type, u32 boot_param)
 	 * Initialize IOC state of all functions on a chip reset.
 	 */
 	rb = ioc->pcidev.pci_bar_kva;
-	if (boot_param == BFI_BOOT_TYPE_MEMTEST) {
+	if (boot_type == BFI_BOOT_TYPE_MEMTEST) {
 		writel(BFI_IOC_MEMTEST, (rb + BFA_IOC0_STATE_REG));
 		writel(BFI_IOC_MEMTEST, (rb + BFA_IOC1_STATE_REG));
 	} else {
@@ -1743,7 +1748,7 @@ bfa_ioc_boot(struct bfa_ioc *ioc, u32 boot_type, u32 boot_param)
 	}
 
 	bfa_ioc_msgflush(ioc);
-	bfa_ioc_download_fw(ioc, boot_type, boot_param);
+	bfa_ioc_download_fw(ioc, boot_type, boot_env);
 
 	/**
 	 * Enable interrupts just before starting LPU
diff --git a/drivers/net/bna/bfa_ioc.h b/drivers/net/bna/bfa_ioc.h
index e4974bc..bd48abe 100644
--- a/drivers/net/bna/bfa_ioc.h
+++ b/drivers/net/bna/bfa_ioc.h
@@ -194,6 +194,7 @@ struct bfa_ioc_hwif {
 					bool msix);
 	void		(*ioc_notify_fail)	(struct bfa_ioc *ioc);
 	void		(*ioc_ownership_reset)	(struct bfa_ioc *ioc);
+	bool		(*ioc_sync_start)       (struct bfa_ioc *ioc);
 	void		(*ioc_sync_join)	(struct bfa_ioc *ioc);
 	void		(*ioc_sync_leave)	(struct bfa_ioc *ioc);
 	void		(*ioc_sync_ack)		(struct bfa_ioc *ioc);
diff --git a/drivers/net/bna/bfa_ioc_ct.c b/drivers/net/bna/bfa_ioc_ct.c
index 469997c..87aecdf 100644
--- a/drivers/net/bna/bfa_ioc_ct.c
+++ b/drivers/net/bna/bfa_ioc_ct.c
@@ -41,6 +41,7 @@ static void bfa_ioc_ct_map_port(struct bfa_ioc *ioc);
 static void bfa_ioc_ct_isr_mode_set(struct bfa_ioc *ioc, bool msix);
 static void bfa_ioc_ct_notify_fail(struct bfa_ioc *ioc);
 static void bfa_ioc_ct_ownership_reset(struct bfa_ioc *ioc);
+static bool bfa_ioc_ct_sync_start(struct bfa_ioc *ioc);
 static void bfa_ioc_ct_sync_join(struct bfa_ioc *ioc);
 static void bfa_ioc_ct_sync_leave(struct bfa_ioc *ioc);
 static void bfa_ioc_ct_sync_ack(struct bfa_ioc *ioc);
@@ -63,6 +64,7 @@ bfa_nw_ioc_set_ct_hwif(struct bfa_ioc *ioc)
 	nw_hwif_ct.ioc_isr_mode_set = bfa_ioc_ct_isr_mode_set;
 	nw_hwif_ct.ioc_notify_fail = bfa_ioc_ct_notify_fail;
 	nw_hwif_ct.ioc_ownership_reset = bfa_ioc_ct_ownership_reset;
+	nw_hwif_ct.ioc_sync_start = bfa_ioc_ct_sync_start;
 	nw_hwif_ct.ioc_sync_join = bfa_ioc_ct_sync_join;
 	nw_hwif_ct.ioc_sync_leave = bfa_ioc_ct_sync_leave;
 	nw_hwif_ct.ioc_sync_ack = bfa_ioc_ct_sync_ack;
@@ -345,6 +347,32 @@ bfa_ioc_ct_ownership_reset(struct bfa_ioc *ioc)
 /**
  * Synchronized IOC failure processing routines
  */
+static bool
+bfa_ioc_ct_sync_start(struct bfa_ioc *ioc)
+{
+	u32 r32 = readl(ioc->ioc_regs.ioc_fail_sync);
+	u32 sync_reqd = bfa_ioc_ct_get_sync_reqd(r32);
+
+	/*
+	 * Driver load time.  If the sync required bit for this PCI fn
+	 * is set, it is due to an unclean exit by the driver for this
+	 * PCI fn in the previous incarnation. Whoever comes here first
+	 * should clean it up, no matter which PCI fn.
+	 */
+
+	if (sync_reqd & bfa_ioc_ct_sync_pos(ioc)) {
+		writel(0, ioc->ioc_regs.ioc_fail_sync);
+		writel(1, ioc->ioc_regs.ioc_usage_reg);
+		writel(BFI_IOC_UNINIT, ioc->ioc_regs.ioc_fwstate);
+		writel(BFI_IOC_UNINIT, ioc->ioc_regs.alt_ioc_fwstate);
+		return true;
+	}
+
+	return bfa_ioc_ct_sync_complete(ioc);
+}
+/**
+ * Synchronized IOC failure processing routines
+ */
 static void
 bfa_ioc_ct_sync_join(struct bfa_ioc *ioc)
 {
diff --git a/drivers/net/bna/bfi.h b/drivers/net/bna/bfi.h
index a973968..6050379 100644
--- a/drivers/net/bna/bfi.h
+++ b/drivers/net/bna/bfi.h
@@ -184,12 +184,14 @@ enum bfi_mclass {
 #define BFI_IOC_MSGLEN_MAX	32	/* 32 bytes */
 
 #define BFI_BOOT_TYPE_OFF		8
-#define BFI_BOOT_PARAM_OFF		12
+#define BFI_BOOT_LOADER_OFF		12
 
-#define BFI_BOOT_TYPE_NORMAL 		0	/* param is device id */
+#define BFI_BOOT_TYPE_NORMAL 		0
 #define	BFI_BOOT_TYPE_FLASH		1
 #define	BFI_BOOT_TYPE_MEMTEST		2
 
+#define BFI_BOOT_LOADER_OS		0
+
 #define BFI_BOOT_MEMTEST_RES_ADDR   0x900
 #define BFI_BOOT_MEMTEST_RES_SIG    0xA0A1A2A3
 
-- 
1.7.1

