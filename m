From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 1/1] bna: Multiple Definition and Interface Setup Fix
Date: Tue, 4 Oct 2011 19:31:20 -0700
Message-ID: <1317781880-26515-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-next@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-scsi@vger.kernel.org>, <rdunlap@xenotime.net>,
	<sfr@canb.auug.org.au>, <huangj@brocade.com>,
	<adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:43039 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933575Ab1JECbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2011 22:31:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/net/built-in.o: In function `bfa_ioc_ct2_poweron':
(.text+0xcdc90): multiple definition of `bfa_ioc_ct2_poweron'
drivers/scsi/built-in.o:(.text+0x17f9a0): first defined here

This patch renames bfa_ioc_ct2_poweron() to bfa_nw_ioc_ct2_poweron() to avoid
multiple definition with Brocade scsi driver. It also modifies asic specific
interface setup to allocate MSIX resources at power on in case of 1860 HW with
no asic block and warns if the asic gen is neither BFI_ASIC_GEN_CT nor
BFI_ASIC_GEN_CT2.

Reported-by: Randy Dunlap <rdunlap@xenotime.net>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bfa_ioc.c    |    5 ++++-
 drivers/net/ethernet/brocade/bna/bfa_ioc.h    |    2 +-
 drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c |    2 +-
 3 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.c b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
index e02d607..b0307a0 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
@@ -2006,8 +2006,11 @@ bfa_nw_ioc_pci_init(struct bfa_ioc *ioc, struct bfa_pcidev *pcidev,
 	 */
 	if (ioc->asic_gen == BFI_ASIC_GEN_CT)
 		bfa_nw_ioc_set_ct_hwif(ioc);
-	else
+	else {
+		WARN_ON(ioc->asic_gen != BFI_ASIC_GEN_CT2);
 		bfa_nw_ioc_set_ct2_hwif(ioc);
+		bfa_nw_ioc_ct2_poweron(ioc);
+	}
 
 	bfa_ioc_map_port(ioc);
 	bfa_ioc_reg_init(ioc);
diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.h b/drivers/net/ethernet/brocade/bna/bfa_ioc.h
index d5a21f4..ca158d1 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.h
@@ -281,7 +281,7 @@ void bfa_nw_ioc_mbox_regisr(struct bfa_ioc *ioc, enum bfi_mclass mc,
 
 void bfa_nw_ioc_set_ct_hwif(struct bfa_ioc *ioc);
 void bfa_nw_ioc_set_ct2_hwif(struct bfa_ioc *ioc);
-void bfa_ioc_ct2_poweron(struct bfa_ioc *ioc);
+void bfa_nw_ioc_ct2_poweron(struct bfa_ioc *ioc);
 
 void bfa_nw_ioc_attach(struct bfa_ioc *ioc, void *bfa,
 		struct bfa_ioc_cbfn *cbfn);
diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c b/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c
index c2d3b1a..348479b 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c
@@ -454,7 +454,7 @@ bfa_ioc_ct2_lpu_read_stat(struct bfa_ioc *ioc)
 #define __MSIX_VT_NUMVT_(_v)		((_v) << __MSIX_VT_NUMVT__SH)
 #define __MSIX_VT_OFST_			0x000007ff
 void
-bfa_ioc_ct2_poweron(struct bfa_ioc *ioc)
+bfa_nw_ioc_ct2_poweron(struct bfa_ioc *ioc)
 {
 	void __iomem *rb = ioc->pcidev.pci_bar_kva;
 	u32 r32;
-- 
1.7.1
