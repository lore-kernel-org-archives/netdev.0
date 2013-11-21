From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 02/13] bna: Set Get IOC fw State
Date: Wed, 20 Nov 2013 21:54:06 -0800
Message-ID: <1385013257-32745-3-git-send-email-rmody@brocade.com>
References: <1385013257-32745-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	<adapter_linux_open_src_team@Brocade.COM>,
	Rasesh Mody <rmody@Brocade.COM>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:7951 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750902Ab3KUGSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 01:18:01 -0500
In-Reply-To: <1385013257-32745-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add APIs to set and get IOC currnet fw state and alt IOC fw state
 - bfa_ioc_ct_set_cur_ioc_fwstate()
 - bfa_ioc_ct_get_cur_ioc_fwstate()
 - bfa_ioc_ct_set_alt_ioc_fwstate()
 - bfa_ioc_ct_get_alt_ioc_fwstate()

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bfa_ioc.c    | 32 +++++++++++++--------
 drivers/net/ethernet/brocade/bna/bfa_ioc.h    |  7 +++++
 drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c | 40 +++++++++++++++++++++++++++
 3 files changed, 67 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.c b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
index 6f3cac0..b81132a 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
@@ -42,6 +42,14 @@
 			((__ioc)->ioc_hwif->ioc_sync_ack(__ioc))
 #define bfa_ioc_sync_complete(__ioc)			\
 			((__ioc)->ioc_hwif->ioc_sync_complete(__ioc))
+#define bfa_ioc_set_cur_ioc_fwstate(__ioc, __fwstate)		\
+			((__ioc)->ioc_hwif->ioc_set_fwstate(__ioc, __fwstate))
+#define bfa_ioc_get_cur_ioc_fwstate(__ioc)		\
+			((__ioc)->ioc_hwif->ioc_get_fwstate(__ioc))
+#define bfa_ioc_set_alt_ioc_fwstate(__ioc, __fwstate)		\
+		((__ioc)->ioc_hwif->ioc_set_alt_fwstate(__ioc, __fwstate))
+#define bfa_ioc_get_alt_ioc_fwstate(__ioc)		\
+			((__ioc)->ioc_hwif->ioc_get_alt_fwstate(__ioc))
 
 #define bfa_ioc_mbox_cmd_pending(__ioc)		\
 			(!list_empty(&((__ioc)->mbox_mod.cmd_q)) || \
@@ -860,7 +868,7 @@ bfa_iocpf_sm_disabling(struct bfa_iocpf *iocpf, enum iocpf_event event)
 		 */
 
 	case IOCPF_E_TIMEOUT:
-		writel(BFI_IOC_FAIL, ioc->ioc_regs.ioc_fwstate);
+		bfa_ioc_set_cur_ioc_fwstate(ioc, BFI_IOC_FAIL);
 		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_disabling_sync);
 		break;
 
@@ -949,7 +957,7 @@ bfa_iocpf_sm_initfail_sync(struct bfa_iocpf *iocpf, enum iocpf_event event)
 	case IOCPF_E_SEMLOCKED:
 		bfa_ioc_notify_fail(ioc);
 		bfa_ioc_sync_leave(ioc);
-		writel(BFI_IOC_FAIL, ioc->ioc_regs.ioc_fwstate);
+		bfa_ioc_set_cur_ioc_fwstate(ioc, BFI_IOC_FAIL);
 		bfa_nw_ioc_hw_sem_release(ioc);
 		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_initfail);
 		break;
@@ -1031,7 +1039,7 @@ bfa_iocpf_sm_fail_sync(struct bfa_iocpf *iocpf, enum iocpf_event event)
 		bfa_ioc_notify_fail(ioc);
 		if (!iocpf->auto_recover) {
 			bfa_ioc_sync_leave(ioc);
-			writel(BFI_IOC_FAIL, ioc->ioc_regs.ioc_fwstate);
+			bfa_ioc_set_cur_ioc_fwstate(ioc, BFI_IOC_FAIL);
 			bfa_nw_ioc_hw_sem_release(ioc);
 			bfa_fsm_set_state(iocpf, bfa_iocpf_sm_fail);
 		} else {
@@ -1162,7 +1170,7 @@ bfa_ioc_hw_sem_init(struct bfa_ioc *ioc)
 		r32 = readl(ioc->ioc_regs.ioc_init_sem_reg);
 	}
 
-	fwstate = readl(ioc->ioc_regs.ioc_fwstate);
+	fwstate = bfa_ioc_get_cur_ioc_fwstate(ioc);
 	if (fwstate == BFI_IOC_UNINIT) {
 		writel(1, ioc->ioc_regs.ioc_init_sem_reg);
 		return;
@@ -1176,8 +1184,8 @@ bfa_ioc_hw_sem_init(struct bfa_ioc *ioc)
 	}
 
 	bfa_ioc_fwver_clear(ioc);
-	writel(BFI_IOC_UNINIT, ioc->ioc_regs.ioc_fwstate);
-	writel(BFI_IOC_UNINIT, ioc->ioc_regs.alt_ioc_fwstate);
+	bfa_ioc_set_cur_ioc_fwstate(ioc, BFI_IOC_UNINIT);
+	bfa_ioc_set_alt_ioc_fwstate(ioc, BFI_IOC_UNINIT);
 
 	/*
 	 * Try to lock and then unlock the semaphore.
@@ -1366,7 +1374,7 @@ bfa_ioc_hwinit(struct bfa_ioc *ioc, bool force)
 	bool fwvalid;
 	u32 boot_env;
 
-	ioc_fwstate = readl(ioc->ioc_regs.ioc_fwstate);
+	ioc_fwstate = bfa_ioc_get_cur_ioc_fwstate(ioc);
 
 	if (force)
 		ioc_fwstate = BFI_IOC_UNINIT;
@@ -1859,11 +1867,11 @@ bfa_ioc_boot(struct bfa_ioc *ioc, enum bfi_fwboot_type boot_type,
 	 * Initialize IOC state of all functions on a chip reset.
 	 */
 	if (boot_type == BFI_FWBOOT_TYPE_MEMTEST) {
-		writel(BFI_IOC_MEMTEST, ioc->ioc_regs.ioc_fwstate);
-		writel(BFI_IOC_MEMTEST, ioc->ioc_regs.alt_ioc_fwstate);
+		bfa_ioc_set_cur_ioc_fwstate(ioc, BFI_IOC_MEMTEST);
+		bfa_ioc_set_alt_ioc_fwstate(ioc, BFI_IOC_MEMTEST);
 	} else {
-		writel(BFI_IOC_INITING, ioc->ioc_regs.ioc_fwstate);
-		writel(BFI_IOC_INITING, ioc->ioc_regs.alt_ioc_fwstate);
+		bfa_ioc_set_cur_ioc_fwstate(ioc, BFI_IOC_INITING);
+		bfa_ioc_set_alt_ioc_fwstate(ioc, BFI_IOC_INITING);
 	}
 
 	bfa_ioc_msgflush(ioc);
@@ -2473,7 +2481,7 @@ bfa_nw_iocpf_sem_timeout(void *ioc_arg)
 static void
 bfa_ioc_poll_fwinit(struct bfa_ioc *ioc)
 {
-	u32 fwstate = readl(ioc->ioc_regs.ioc_fwstate);
+	u32 fwstate = bfa_ioc_get_cur_ioc_fwstate(ioc);
 
 	if (fwstate == BFI_IOC_DISABLED) {
 		bfa_fsm_send_event(&ioc->iocpf, IOCPF_E_FWREADY);
diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.h b/drivers/net/ethernet/brocade/bna/bfa_ioc.h
index f04e0aa..9521cbf 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.h
@@ -215,6 +215,13 @@ struct bfa_ioc_hwif {
 	void		(*ioc_sync_ack)		(struct bfa_ioc *ioc);
 	bool		(*ioc_sync_complete)	(struct bfa_ioc *ioc);
 	bool		(*ioc_lpu_read_stat)	(struct bfa_ioc *ioc);
+	void		(*ioc_set_fwstate)	(struct bfa_ioc *ioc,
+					enum bfi_ioc_state fwstate);
+	enum bfi_ioc_state (*ioc_get_fwstate) (struct bfa_ioc *ioc);
+	void		(*ioc_set_alt_fwstate)	(struct bfa_ioc *ioc,
+					enum bfi_ioc_state fwstate);
+	enum bfi_ioc_state (*ioc_get_alt_fwstate) (struct bfa_ioc *ioc);
+
 };
 
 #define bfa_ioc_pcifn(__ioc)		((__ioc)->pcidev.pci_func)
diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c b/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c
index 5df0b0c..fca4560 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c
@@ -48,6 +48,12 @@ static void bfa_ioc_ct_sync_join(struct bfa_ioc *ioc);
 static void bfa_ioc_ct_sync_leave(struct bfa_ioc *ioc);
 static void bfa_ioc_ct_sync_ack(struct bfa_ioc *ioc);
 static bool bfa_ioc_ct_sync_complete(struct bfa_ioc *ioc);
+static void bfa_ioc_ct_set_cur_ioc_fwstate(
+			struct bfa_ioc *ioc, enum bfi_ioc_state fwstate);
+static enum bfi_ioc_state bfa_ioc_ct_get_cur_ioc_fwstate(struct bfa_ioc *ioc);
+static void bfa_ioc_ct_set_alt_ioc_fwstate(
+			struct bfa_ioc *ioc, enum bfi_ioc_state fwstate);
+static enum bfi_ioc_state bfa_ioc_ct_get_alt_ioc_fwstate(struct bfa_ioc *ioc);
 static enum bfa_status bfa_ioc_ct_pll_init(void __iomem *rb,
 				enum bfi_asic_mode asic_mode);
 static enum bfa_status bfa_ioc_ct2_pll_init(void __iomem *rb,
@@ -68,6 +74,10 @@ static const struct bfa_ioc_hwif nw_hwif_ct = {
 	.ioc_sync_leave	     = bfa_ioc_ct_sync_leave,
 	.ioc_sync_ack	     = bfa_ioc_ct_sync_ack,
 	.ioc_sync_complete   = bfa_ioc_ct_sync_complete,
+	.ioc_set_fwstate     = bfa_ioc_ct_set_cur_ioc_fwstate,
+	.ioc_get_fwstate     = bfa_ioc_ct_get_cur_ioc_fwstate,
+	.ioc_set_alt_fwstate     = bfa_ioc_ct_set_alt_ioc_fwstate,
+	.ioc_get_alt_fwstate     = bfa_ioc_ct_get_alt_ioc_fwstate,
 };
 
 static const struct bfa_ioc_hwif nw_hwif_ct2 = {
@@ -85,6 +95,10 @@ static const struct bfa_ioc_hwif nw_hwif_ct2 = {
 	.ioc_sync_leave	     = bfa_ioc_ct_sync_leave,
 	.ioc_sync_ack	     = bfa_ioc_ct_sync_ack,
 	.ioc_sync_complete   = bfa_ioc_ct_sync_complete,
+	.ioc_set_fwstate     = bfa_ioc_ct_set_cur_ioc_fwstate,
+	.ioc_get_fwstate     = bfa_ioc_ct_get_cur_ioc_fwstate,
+	.ioc_set_alt_fwstate     = bfa_ioc_ct_set_alt_ioc_fwstate,
+	.ioc_get_alt_fwstate     = bfa_ioc_ct_get_alt_ioc_fwstate,
 };
 
 /* Called from bfa_ioc_attach() to map asic specific calls. */
@@ -565,6 +579,32 @@ bfa_ioc_ct_sync_complete(struct bfa_ioc *ioc)
 	return false;
 }
 
+static void
+bfa_ioc_ct_set_cur_ioc_fwstate(struct bfa_ioc *ioc,
+		enum bfi_ioc_state fwstate)
+{
+	writel(fwstate, ioc->ioc_regs.ioc_fwstate);
+}
+
+static enum bfi_ioc_state
+bfa_ioc_ct_get_cur_ioc_fwstate(struct bfa_ioc *ioc)
+{
+	return (enum bfi_ioc_state)readl(ioc->ioc_regs.ioc_fwstate);
+}
+
+static void
+bfa_ioc_ct_set_alt_ioc_fwstate(struct bfa_ioc *ioc,
+		enum bfi_ioc_state fwstate)
+{
+	writel(fwstate, ioc->ioc_regs.alt_ioc_fwstate);
+}
+
+static enum bfi_ioc_state
+bfa_ioc_ct_get_alt_ioc_fwstate(struct bfa_ioc *ioc)
+{
+	return (enum bfi_ioc_state)readl(ioc->ioc_regs.alt_ioc_fwstate);
+}
+
 static enum bfa_status
 bfa_ioc_ct_pll_init(void __iomem *rb, enum bfi_asic_mode asic_mode)
 {
-- 
1.8.2.3
