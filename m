From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 08/10] bna: Add HW Semaphore Unlock Logic
Date: Fri, 22 Jul 2011 11:07:47 -0700
Message-ID: <1311358069-32067-9-git-send-email-rmody@brocade.com>
References: <1311358069-32067-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:39797 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754575Ab1GVSIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 14:08:47 -0400
In-Reply-To: <1311358069-32067-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Added logic to unlock hw semaphore if the previos FW boot was from boot
   code (flash based) and the current FW initialization attempt is from OS
   driver.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_ioc.c |   25 +++++++++++++++++++++++++
 drivers/net/bna/bfi.h     |    6 ++++++
 2 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index da56c2f..c3b62a3 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -58,6 +58,7 @@ static bool bfa_nw_auto_recover = true;
 /*
  * forward declarations
  */
+static void bfa_ioc_hw_sem_init(struct bfa_ioc *ioc);
 static void bfa_ioc_hw_sem_get(struct bfa_ioc *ioc);
 static void bfa_ioc_hw_sem_get_cancel(struct bfa_ioc *ioc);
 static void bfa_ioc_hwinit(struct bfa_ioc *ioc, bool force);
@@ -590,6 +591,7 @@ bfa_iocpf_sm_reset(struct bfa_iocpf *iocpf, enum iocpf_event event)
 static void
 bfa_iocpf_sm_fwcheck_entry(struct bfa_iocpf *iocpf)
 {
+	bfa_ioc_hw_sem_init(iocpf->ioc);
 	bfa_ioc_hw_sem_get(iocpf->ioc);
 }
 
@@ -1176,6 +1178,29 @@ bfa_nw_ioc_sem_release(void __iomem *sem_reg)
 }
 
 static void
+bfa_ioc_hw_sem_init(struct bfa_ioc *ioc)
+{
+	struct bfi_ioc_image_hdr fwhdr;
+	u32 fwstate = readl(ioc->ioc_regs.ioc_fwstate);
+
+	if (fwstate == BFI_IOC_UNINIT)
+		return;
+
+	bfa_nw_ioc_fwver_get(ioc, &fwhdr);
+
+	if (swab32(fwhdr.exec) == BFI_FWBOOT_TYPE_NORMAL)
+		return;
+
+	writel(BFI_IOC_UNINIT, ioc->ioc_regs.ioc_fwstate);
+
+	/*
+	 * Try to lock and then unlock the semaphore.
+	 */
+	readl(ioc->ioc_regs.ioc_sem_reg);
+	writel(1, ioc->ioc_regs.ioc_sem_reg);
+}
+
+static void
 bfa_ioc_hw_sem_get(struct bfa_ioc *ioc)
 {
 	u32	r32;
diff --git a/drivers/net/bna/bfi.h b/drivers/net/bna/bfi.h
index 683a7d7..088211c 100644
--- a/drivers/net/bna/bfi.h
+++ b/drivers/net/bna/bfi.h
@@ -289,6 +289,12 @@ struct bfi_ioc_image_hdr {
 	u32	md5sum[BFI_IOC_MD5SUM_SZ];
 };
 
+enum bfi_fwboot_type {
+	BFI_FWBOOT_TYPE_NORMAL	= 0,
+	BFI_FWBOOT_TYPE_FLASH	= 1,
+	BFI_FWBOOT_TYPE_MEMTEST	= 2,
+};
+
 /**
  *  BFI_IOC_I2H_READY_EVENT message
  */
-- 
1.7.1

