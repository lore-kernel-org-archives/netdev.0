From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 14/45] bna: Brocade 1860 Register and ASIC Mode Changes
Date: Mon, 18 Jul 2011 01:22:34 -0700
Message-ID: <1310977385-5268-4-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:48225 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753801Ab1GRIX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:23:29 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chnage details:
 - Added 1860 specific register definitions
 - Setup 1860 registers used by IOC logic

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_ioc.h    |    5 +++--
 drivers/net/bna/bfa_ioc_ct.c |   19 +++++++++++--------
 2 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bna/bfa_ioc.h b/drivers/net/bna/bfa_ioc.h
index c22c9c0..592a104 100644
--- a/drivers/net/bna/bfa_ioc.h
+++ b/drivers/net/bna/bfa_ioc.h
@@ -210,7 +210,8 @@ struct bfa_ioc {
 };
 
 struct bfa_ioc_hwif {
-	enum bfa_status (*ioc_pll_init) (void __iomem *rb, bool fcmode);
+	enum bfa_status (*ioc_pll_init) (void __iomem *rb,
+						enum bfi_asic_mode m);
 	bool		(*ioc_firmware_lock)	(struct bfa_ioc *ioc);
 	void		(*ioc_firmware_unlock)	(struct bfa_ioc *ioc);
 	void		(*ioc_reg_init)	(struct bfa_ioc *ioc);
@@ -270,7 +271,7 @@ void bfa_nw_ioc_mbox_regisr(struct bfa_ioc *ioc, enum bfi_mclass mc,
 
 #define bfa_ioc_pll_init_asic(__ioc) \
 	((__ioc)->ioc_hwif->ioc_pll_init((__ioc)->pcidev.pci_bar_kva, \
-			   (__ioc)->fcmode))
+			   (__ioc)->asic_mode))
 
 #define	bfa_ioc_isr_mode_set(__ioc, __msix)			\
 			((__ioc)->ioc_hwif->ioc_isr_mode_set(__ioc, __msix))
diff --git a/drivers/net/bna/bfa_ioc_ct.c b/drivers/net/bna/bfa_ioc_ct.c
index 3aa01dd..a615c15 100644
--- a/drivers/net/bna/bfa_ioc_ct.c
+++ b/drivers/net/bna/bfa_ioc_ct.c
@@ -48,8 +48,10 @@ static void bfa_ioc_ct_sync_join(struct bfa_ioc *ioc);
 static void bfa_ioc_ct_sync_leave(struct bfa_ioc *ioc);
 static void bfa_ioc_ct_sync_ack(struct bfa_ioc *ioc);
 static bool bfa_ioc_ct_sync_complete(struct bfa_ioc *ioc);
-static enum bfa_status bfa_ioc_ct_pll_init(void __iomem *rb, bool fcmode);
-static enum bfa_status bfa_ioc_ct2_pll_init(void __iomem *rb, bool fcmode);
+static enum bfa_status bfa_ioc_ct_pll_init(void __iomem *rb,
+				enum bfi_asic_mode asic_mode);
+static enum bfa_status bfa_ioc_ct2_pll_init(void __iomem *rb,
+				enum bfi_asic_mode asic_mode);
 static bool bfa_ioc_ct2_lpu_read_stat(struct bfa_ioc *ioc);
 
 static struct bfa_ioc_hwif nw_hwif_ct;
@@ -204,7 +206,7 @@ bfa_ioc_ct_notify_fail(struct bfa_ioc *ioc)
 /**
  * Host to LPU mailbox message addresses
  */
-static struct { u32 hfn_mbox, lpu_mbox, hfn_pgn; } iocreg_fnreg[] = {
+static struct { u32 hfn_mbox, lpu_mbox, hfn_pgn; } ct_fnreg[] = {
 	{ HOSTFN0_LPU_MBOX0_0, LPU_HOSTFN0_MBOX0_0, HOST_PAGE_NUM_FN0 },
 	{ HOSTFN1_LPU_MBOX0_8, LPU_HOSTFN1_MBOX0_8, HOST_PAGE_NUM_FN1 },
 	{ HOSTFN2_LPU_MBOX0_0, LPU_HOSTFN2_MBOX0_0, HOST_PAGE_NUM_FN2 },
@@ -249,9 +251,9 @@ bfa_ioc_ct_reg_init(struct bfa_ioc *ioc)
 
 	rb = bfa_ioc_bar0(ioc);
 
-	ioc->ioc_regs.hfn_mbox = rb + iocreg_fnreg[pcifn].hfn_mbox;
-	ioc->ioc_regs.lpu_mbox = rb + iocreg_fnreg[pcifn].lpu_mbox;
-	ioc->ioc_regs.host_page_num_fn = rb + iocreg_fnreg[pcifn].hfn_pgn;
+	ioc->ioc_regs.hfn_mbox = rb + ct_fnreg[pcifn].hfn_mbox;
+	ioc->ioc_regs.lpu_mbox = rb + ct_fnreg[pcifn].lpu_mbox;
+	ioc->ioc_regs.host_page_num_fn = rb + ct_fnreg[pcifn].hfn_pgn;
 
 	if (ioc->port_id == 0) {
 		ioc->ioc_regs.heartbeat = rb + BFA_IOC0_HBEAT_REG;
@@ -582,9 +584,10 @@ bfa_ioc_ct_sync_complete(struct bfa_ioc *ioc)
 }
 
 static enum bfa_status
-bfa_ioc_ct_pll_init(void __iomem *rb, bool fcmode)
+bfa_ioc_ct_pll_init(void __iomem *rb, enum bfi_asic_mode asic_mode)
 {
 	u32	pll_sclk, pll_fclk, r32;
+	bool fcmode = (asic_mode == BFI_ASIC_MODE_FC);
 
 	pll_sclk = __APP_PLL_SCLK_LRESETN | __APP_PLL_SCLK_ENARST |
 		__APP_PLL_SCLK_RSEL200500 | __APP_PLL_SCLK_P0_1(3U) |
@@ -795,7 +798,7 @@ bfa_ioc_ct2_mac_reset(void __iomem *rb)
 
 #define CT2_NFC_MAX_DELAY       1000
 static enum bfa_status
-bfa_ioc_ct2_pll_init(void __iomem *rb, bool fcmode)
+bfa_ioc_ct2_pll_init(void __iomem *rb, enum bfi_asic_mode asic_mode)
 {
 	volatile u32 wgn, r32;
 	int i;
-- 
1.7.1

