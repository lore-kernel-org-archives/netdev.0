From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 30/45] bna: Add HW Semaphore Unlock Logic
Date: Mon, 18 Jul 2011 01:22:50 -0700
Message-ID: <1310977385-5268-20-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:37816 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753227Ab1GRIYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:24:35 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Added logic to unlock hw semaphore if the previos FW boot was from boot
   code (flash based) and the current FW initialization attempt is from OS
   driver.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_ioc.c |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index 78cdc2b..940c94a 100644
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
@@ -691,6 +692,7 @@ bfa_iocpf_sm_reset(struct bfa_iocpf *iocpf, enum iocpf_event event)
 static void
 bfa_iocpf_sm_fwcheck_entry(struct bfa_iocpf *iocpf)
 {
+	bfa_ioc_hw_sem_init(iocpf->ioc);
 	bfa_ioc_hw_sem_get(iocpf->ioc);
 }
 
@@ -1263,6 +1265,29 @@ bfa_nw_ioc_sem_release(void __iomem *sem_reg)
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
-- 
1.7.1

