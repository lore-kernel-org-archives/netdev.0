From: Jing Huang <huangj@brocade.com>
Subject: [PATCH 1/7] bna: Serialize smem access during adapter initialization
Date: Wed, 4 Apr 2012 08:42:08 -0700
Message-ID: <1333554128-22044-1-git-send-email-huangj@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <AdapterLinuxOpenSrcExtTeam@brocade.com>,
	Jing Huang <huangj@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:36330 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756536Ab2DDPmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 11:42:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use init semaphore to serialize execution of the "unlock IOC semaphore"
code. Added bfa_ioc_fwver_clear() function to clear the firmware header if
last firmwar boot is not from driver.

Signed-off-by: Jing Huang <huangj@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bfa_ioc.c |   50 +++++++++++++++++++++++----
 1 files changed, 42 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.c b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
index 77977d7..7a3e79c 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
@@ -1207,27 +1207,62 @@ bfa_nw_ioc_sem_release(void __iomem *sem_reg)
 	writel(1, sem_reg);
 }
 
+/* Clear fwver hdr */
+static void
+bfa_ioc_fwver_clear(struct bfa_ioc *ioc)
+{
+	u32 pgnum, pgoff, loff = 0;
+	int i;
+
+	pgnum = PSS_SMEM_PGNUM(ioc->ioc_regs.smem_pg0, loff);
+	pgoff = PSS_SMEM_PGOFF(loff);
+	writel(pgnum, ioc->ioc_regs.host_page_num_fn);
+
+	for (i = 0; i < (sizeof(struct bfi_ioc_image_hdr) / sizeof(u32)); i++) {
+		writel(0, ioc->ioc_regs.smem_page_start + loff);
+		loff += sizeof(u32);
+	}
+}
+
+
 static void
 bfa_ioc_hw_sem_init(struct bfa_ioc *ioc)
 {
 	struct bfi_ioc_image_hdr fwhdr;
-	u32 fwstate = readl(ioc->ioc_regs.ioc_fwstate);
+	u32 fwstate, r32;
 
-	if (fwstate == BFI_IOC_UNINIT)
+	/* Spin on init semaphore to serialize. */
+	r32 = readl(ioc->ioc_regs.ioc_init_sem_reg);
+	while (r32 & 0x1) {
+		udelay(20);
+		r32 = readl(ioc->ioc_regs.ioc_init_sem_reg);
+	}
+
+	fwstate = readl(ioc->ioc_regs.ioc_fwstate);
+	if (fwstate == BFI_IOC_UNINIT) {
+		writel(1, ioc->ioc_regs.ioc_init_sem_reg);
 		return;
+	}
 
 	bfa_nw_ioc_fwver_get(ioc, &fwhdr);
 
-	if (swab32(fwhdr.exec) == BFI_FWBOOT_TYPE_NORMAL)
+	if (swab32(fwhdr.exec) == BFI_FWBOOT_TYPE_NORMAL) {
+		writel(1, ioc->ioc_regs.ioc_init_sem_reg);
 		return;
+	}
 
+	bfa_ioc_fwver_clear(ioc);
 	writel(BFI_IOC_UNINIT, ioc->ioc_regs.ioc_fwstate);
+	writel(BFI_IOC_UNINIT, ioc->ioc_regs.alt_ioc_fwstate);
 
 	/*
 	 * Try to lock and then unlock the semaphore.
 	 */
 	readl(ioc->ioc_regs.ioc_sem_reg);
 	writel(1, ioc->ioc_regs.ioc_sem_reg);
+
+	/* Unlock init semaphore */
+	writel(1, ioc->ioc_regs.ioc_init_sem_reg);
 }
 
 static void
@@ -1585,11 +1620,6 @@ bfa_ioc_download_fw(struct bfa_ioc *ioc, u32 boot_type,
 	u32 i;
 	u32 asicmode;
 
-	/**
-	 * Initialize LMEM first before code download
-	 */
-	bfa_ioc_lmem_init(ioc);
-
 	fwimg = bfa_cb_image_get_chunk(bfa_ioc_asic_gen(ioc), chunkno);
 
 	pgnum = bfa_ioc_smem_pgnum(ioc, loff);
@@ -1914,6 +1944,10 @@ bfa_ioc_pll_init(struct bfa_ioc *ioc)
 	bfa_ioc_pll_init_asic(ioc);
 
 	ioc->pllinit = true;
+
+	/* Initialize LMEM */
+	bfa_ioc_lmem_init(ioc);
+
 	/*
 	 *  release semaphore.
 	 */
-- 
1.6.5.2
