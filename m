From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 12/45] bna: Hardware Clock Setup
Date: Mon, 18 Jul 2011 01:22:32 -0700
Message-ID: <1310977385-5268-2-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:37778 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753914Ab1GRIXV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:23:21 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Clock values for Brocade 1860 hardware PLL initialization depends on
   asic mode.
 - Removed additional mode dependent PCI device ID definitions for 1860.
 - Pass asic generation, port modes and asic mode as part firmware boot
   parameters to firmware.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_defs.h |    1 +
 drivers/net/bna/bfa_ioc.c  |   23 ++++++++++++++++-------
 drivers/net/bna/bfa_ioc.h  |    5 +++--
 drivers/net/bna/bfi.h      |   28 ++++++++++++++++++----------
 4 files changed, 38 insertions(+), 19 deletions(-)

diff --git a/drivers/net/bna/bfa_defs.h b/drivers/net/bna/bfa_defs.h
index 49b990c..fc9702c 100644
--- a/drivers/net/bna/bfa_defs.h
+++ b/drivers/net/bna/bfa_defs.h
@@ -240,6 +240,7 @@ struct bfa_mfg_block {
 
 enum {
 	BFA_PCI_DEVICE_ID_CT		= 0x14,
+	BFA_PCI_DEVICE_ID_CT2		= 0x22,
 };
 
 #define bfa_asic_id_ct(devid)			\
diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index a31c0cc..b23d331 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -1567,10 +1567,10 @@ bfa_ioc_download_fw(struct bfa_ioc *ioc, u32 boot_type,
 	/*
 	 * Set boot type, env and device mode at the end.
 	*/
-	asicmode = BFI_FWBOOT_ASICMODE(ioc->asic_gen, ioc->mode_p0,
-					ioc->mode_p1);
+	asicmode = BFI_FWBOOT_ASICMODE(ioc->asic_gen, ioc->asic_mode,
+					ioc->port0_mode, ioc->port1_mode);
 	writel(asicmode, ((ioc->ioc_regs.smem_page_start)
-			+ BFI_FWBOOT_ASICMODE_OFF));
+			+ BFI_FWBOOT_DEVMODE_OFF));
 	writel(boot_type, ((ioc->ioc_regs.smem_page_start)
 			+ (BFI_FWBOOT_TYPE_OFF)));
 	writel(boot_env, ((ioc->ioc_regs.smem_page_start)
@@ -1875,10 +1875,19 @@ bfa_nw_ioc_pci_init(struct bfa_ioc *ioc, struct bfa_pcidev *pcidev,
 	/**
 	 * Initialize IOC and device personality
 	 */
+	ioc->port0_mode = ioc->port1_mode = BFI_PORT_MODE_FC;
+	ioc->asic_mode  = BFI_ASIC_MODE_FC;
+
 	switch (pcidev->device_id) {
 	case BFA_PCI_DEVICE_ID_CT:
 		ioc->asic_gen = BFI_ASIC_GEN_CT;
-		ioc->mode_p0 = ioc->mode_p1 = BFI_FWBOOT_DEVMOD_CNA;
+		ioc->port0_mode = ioc->port1_mode = BFI_PORT_MODE_ETH;
+		ioc->asic_mode  = BFI_ASIC_MODE_ETH;
+		break;
+
+	case BFA_PCI_DEVICE_ID_CT2:
+		ioc->asic_gen = BFI_ASIC_GEN_CT2;
+		ioc->asic_mode  = BFI_ASIC_MODE_FC16;
 		break;
 
 	default:
@@ -2097,15 +2106,15 @@ bfa_ioc_get_adapter_attr(struct bfa_ioc *ioc,
 enum bfa_ioc_type
 bfa_nw_ioc_get_type(struct bfa_ioc *ioc)
 {
-	enum bfi_fwboot_devmode mode;
+	enum bfi_port_mode mode;
 
 	if (ioc->clscode == BFI_PCIFN_CLASS_ETH)
 		return BFA_IOC_TYPE_LL;
 
 	BUG_ON(!(ioc->clscode == BFI_PCIFN_CLASS_FC));
 
-	mode = (ioc->port_id == 0) ? ioc->mode_p0 : ioc->mode_p1;
-	return (mode == BFI_FWBOOT_DEVMOD_HBA)
+	mode = (ioc->port_id == 0) ? ioc->port0_mode : ioc->port1_mode;
+	return (mode == BFI_PORT_MODE_FC)
 		? BFA_IOC_TYPE_FC : BFA_IOC_TYPE_FCoE;
 }
 
diff --git a/drivers/net/bna/bfa_ioc.h b/drivers/net/bna/bfa_ioc.h
index 8ffdbea..11c7bd5 100644
--- a/drivers/net/bna/bfa_ioc.h
+++ b/drivers/net/bna/bfa_ioc.h
@@ -203,8 +203,9 @@ struct bfa_ioc {
 	struct bfa_iocpf	iocpf;
 	enum bfi_fwboot_env	boot_env;
 	enum bfi_asic_gen	asic_gen;
-	enum bfi_fwboot_devmode	mode_p0;
-	enum bfi_fwboot_devmode	mode_p1;
+	enum bfi_asic_mode	asic_mode;
+	enum bfi_port_mode	port0_mode;
+	enum bfi_port_mode	port1_mode;
 };
 
 struct bfa_ioc_hwif {
diff --git a/drivers/net/bna/bfi.h b/drivers/net/bna/bfi.h
index cd51edd..c855b44 100644
--- a/drivers/net/bna/bfi.h
+++ b/drivers/net/bna/bfi.h
@@ -203,6 +203,13 @@ enum bfi_asic_gen {
 	BFI_ASIC_GEN_CT2	= 3,	/* 16G FC or 10G CNA	*/
 };
 
+enum bfi_asic_mode {
+	BFI_ASIC_MODE_FC	= 1,	/* FC upto 8G speed		*/
+	BFI_ASIC_MODE_FC16	= 2,	/* FC upto 16G speed		*/
+	BFI_ASIC_MODE_ETH	= 3,	/* Ethernet ports		*/
+	BFI_ASIC_MODE_COMBO	= 4,	/* FC 16G and Ethernet 10G port	*/
+};
+
 enum bfi_ioc_h2i_msgs {
 	BFI_IOC_H2I_ENABLE_REQ		= 1,
 	BFI_IOC_H2I_DISABLE_REQ		= 2,
@@ -285,8 +292,9 @@ struct bfi_ioc_getattr_reply {
 struct bfi_ioc_image_hdr {
 	u32	signature;	/*!< constant signature */
 	u8	asic_gen;	/*!< asic generation */
-	u8	mode_p0;	/*!< device mode for port 0 */
-	u8	mode_p1;	/*!< device mode for port 1 */
+	u8	asic_mode;
+	u8	port0_mode;	/*!< device mode for port 0 */
+	u8	port1_mode;	/*!< device mode for port 1 */
 	u8	rsvd_a;
 	u32	exec;		/*!< exec vector	*/
 	u32	bootenv;	/*!< firmware boot env */
@@ -294,13 +302,14 @@ struct bfi_ioc_image_hdr {
 	u32	md5sum[BFI_IOC_MD5SUM_SZ];
 };
 
-#define BFI_FWBOOT_ASICMODE_OFF		4
+#define BFI_FWBOOT_DEVMODE_OFF		4
 #define BFI_FWBOOT_TYPE_OFF		8
 #define BFI_FWBOOT_ENV_OFF		12
-#define BFI_FWBOOT_ASICMODE(__asic_gen, __mode_p0, __mode_p1) \
+#define BFI_FWBOOT_ASICMODE(__asic_gen, __asic_mode, __p0_mode, __p1_mode) \
 	(((u32)(__asic_gen)) << 24 |	\
-	 ((u32)(__mode_p0)) << 16 |	\
-	 ((u32)(__mode_p0)) << 8)
+	 ((u32)(__asic_mode)) << 16 |	\
+	 ((u32)(__p0_mode)) << 8 |	\
+	 ((u32)(__p1_mode)))
 
 enum bfi_fwboot_type {
 	BFI_FWBOOT_TYPE_NORMAL	= 0,
@@ -314,10 +323,9 @@ enum bfi_fwboot_env {
 	BFI_FWBOOT_ENV_UEFI	= 2,
 };
 
-enum bfi_fwboot_devmode {
-	BFI_FWBOOT_DEVMOD_HBA	= 1,
-	BFI_FWBOOT_DEVMOD_CNA	= 2,
-	BFI_FWBOOT_DEVMOD_NIC	= 3,
+enum bfi_port_mode {
+	BFI_PORT_MODE_FC	= 1,
+	BFI_PORT_MODE_ETH	= 2,
 };
 
 /**
-- 
1.7.1

