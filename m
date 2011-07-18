From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 17/45] bna: Mailbox Interface Changes and FW MBOX fix
Date: Mon, 18 Jul 2011 01:22:37 -0700
Message-ID: <1310977385-5268-7-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:48228 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753801Ab1GRIXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:23:43 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Define Brocade 1850 specific interrupt status defines.
 - CT2 host mailbox interrupt now has 2 roles -- lpu-to-host event notification
   and host-to-lpu mailbox completion event
 - Defined asic specific mailbox interfaces.
 - New h/w mailbox interfaces take 8-bit FIDs and 2-bit port id for owner.
 - Cleaned up mailbox definitions and usage for new and old HW.
   Eliminated usage of ASIC ID.
 - MSI-X vector assignment and programming done by firmware.
 - Fixed host offsets for CPE/RME queue registers.
 - Enable Ethernet driver/mode.
 - Firmware mbox fixes.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_defs.h |   10 +++++++---
 drivers/net/bna/bfa_ioc.c  |   29 +++++++++++++++++++----------
 drivers/net/bna/bfa_ioc.h  |    6 ++++--
 3 files changed, 30 insertions(+), 15 deletions(-)

diff --git a/drivers/net/bna/bfa_defs.h b/drivers/net/bna/bfa_defs.h
index fc9702c..f5909d0 100644
--- a/drivers/net/bna/bfa_defs.h
+++ b/drivers/net/bna/bfa_defs.h
@@ -243,8 +243,12 @@ enum {
 	BFA_PCI_DEVICE_ID_CT2		= 0x22,
 };
 
-#define bfa_asic_id_ct(devid)			\
-	((devid) == PCI_DEVICE_ID_BROCADE_CT ||	\
-	(devid) == PCI_DEVICE_ID_BROCADE_CT_FC)
+#define bfa_asic_id_ct(device)			\
+	((device) == PCI_DEVICE_ID_BROCADE_CT ||	\
+	 (device) == PCI_DEVICE_ID_BROCADE_CT_FC)
+#define bfa_asic_id_ct2(device)			\
+	((device) == BFA_PCI_DEVICE_ID_CT2) /* Add to pci_ids.h */
+#define bfa_asic_id_ctc(device)			\
+	(bfa_asic_id_ct(device) || bfa_asic_id_ct2(device))
 
 #endif /* __BFA_DEFS_H__ */
diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index c304212..fcc9278 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -1731,8 +1731,6 @@ static void
 bfa_ioc_boot(struct bfa_ioc *ioc, enum bfi_fwboot_type boot_type,
 		enum bfi_fwboot_env boot_env)
 {
-	void __iomem *rb;
-
 	bfa_ioc_stats(ioc, ioc_boots);
 
 	if (bfa_ioc_pll_init(ioc) != BFA_STATUS_OK)
@@ -1741,13 +1739,12 @@ bfa_ioc_boot(struct bfa_ioc *ioc, enum bfi_fwboot_type boot_type,
 	/**
 	 * Initialize IOC state of all functions on a chip reset.
 	 */
-	rb = ioc->pcidev.pci_bar_kva;
 	if (boot_type == BFI_FWBOOT_TYPE_MEMTEST) {
-		writel(BFI_IOC_MEMTEST, (rb + BFA_IOC0_STATE_REG));
-		writel(BFI_IOC_MEMTEST, (rb + BFA_IOC1_STATE_REG));
+		writel(BFI_IOC_MEMTEST, ioc->ioc_regs.ioc_fwstate);
+		writel(BFI_IOC_MEMTEST, ioc->ioc_regs.alt_ioc_fwstate);
 	} else {
-		writel(BFI_IOC_INITING, (rb + BFA_IOC0_STATE_REG));
-		writel(BFI_IOC_INITING, (rb + BFA_IOC1_STATE_REG));
+		writel(BFI_IOC_INITING, ioc->ioc_regs.ioc_fwstate);
+		writel(BFI_IOC_INITING, ioc->ioc_regs.alt_ioc_fwstate);
 	}
 
 	bfa_ioc_msgflush(ioc);
@@ -1769,13 +1766,17 @@ bfa_nw_ioc_auto_recover(bool auto_recover)
 	bfa_nw_auto_recover = auto_recover;
 }
 
-static void
+static bool
 bfa_ioc_msgget(struct bfa_ioc *ioc, void *mbmsg)
 {
 	u32	*msgp = mbmsg;
 	u32	r32;
 	int		i;
 
+	r32 = readl(ioc->ioc_regs.lpu_mbox_cmd);
+	if ((r32 & 1) == 0)
+		return false;
+
 	/**
 	 * read the MBOX msg
 	 */
@@ -1791,6 +1792,8 @@ bfa_ioc_msgget(struct bfa_ioc *ioc, void *mbmsg)
 	 */
 	writel(1, ioc->ioc_regs.lpu_mbox_cmd);
 	readl(ioc->ioc_regs.lpu_mbox_cmd);
+
+	return true;
 }
 
 static void
@@ -1887,7 +1890,12 @@ bfa_nw_ioc_pci_init(struct bfa_ioc *ioc, struct bfa_pcidev *pcidev,
 
 	case BFA_PCI_DEVICE_ID_CT2:
 		ioc->asic_gen = BFI_ASIC_GEN_CT2;
-		ioc->asic_mode  = BFI_ASIC_MODE_FC16;
+		if (clscode == BFI_PCIFN_CLASS_FC)
+			ioc->asic_mode  = BFI_ASIC_MODE_FC16;
+		else {
+			ioc->port0_mode = ioc->port1_mode = BFI_PORT_MODE_ETH;
+			ioc->asic_mode  = BFI_ASIC_MODE_ETH;
+		}
 		break;
 
 	default:
@@ -2019,7 +2027,8 @@ bfa_nw_ioc_mbox_isr(struct bfa_ioc *ioc)
 	struct bfi_mbmsg m;
 	int				mc;
 
-	bfa_ioc_msgget(ioc, &m);
+	if (!bfa_ioc_msgget(ioc, &m))
+		return;
 
 	/**
 	 * Treat IOC message class as special.
diff --git a/drivers/net/bna/bfa_ioc.h b/drivers/net/bna/bfa_ioc.h
index 46309e4..95358a2 100644
--- a/drivers/net/bna/bfa_ioc.h
+++ b/drivers/net/bna/bfa_ioc.h
@@ -272,8 +272,10 @@ void bfa_nw_ioc_mbox_regisr(struct bfa_ioc *ioc, enum bfi_mclass mc,
 	((__ioc)->ioc_hwif->ioc_pll_init((__ioc)->pcidev.pci_bar_kva, \
 			   (__ioc)->asic_mode))
 
-#define	bfa_ioc_isr_mode_set(__ioc, __msix)			\
-			((__ioc)->ioc_hwif->ioc_isr_mode_set(__ioc, __msix))
+#define	bfa_ioc_isr_mode_set(__ioc, __msix) do {			\
+	if ((__ioc)->ioc_hwif->ioc_isr_mode_set)			\
+		((__ioc)->ioc_hwif->ioc_isr_mode_set(__ioc, __msix));	\
+} while (0)
 #define	bfa_ioc_ownership_reset(__ioc)				\
 			((__ioc)->ioc_hwif->ioc_ownership_reset(__ioc))
 
-- 
1.7.1

