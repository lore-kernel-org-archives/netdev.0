From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 11/45] bna: Brocade-1860 Fabric Adapter Enablement
Date: Mon, 18 Jul 2011 01:22:31 -0700
Message-ID: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:37773 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753770Ab1GRIXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:23:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Added support for Brocade 1860 Fabric Adapter.
 - Made changes to support single firmware image per asic type.
 - Move asic specific defines to h/w config
 - Remove the check that asserts IOC is in CNA mode in bfa_ioc_firmware_lock()
   and bfa_ioc_firmware_unlock() in bfa_ioc_ct.c. There is no harm in using
   usecnt (ioc_usage_reg) to keep the count of loaded drivers.
 - Added support for Brocade 1860 device ID to bnad.c

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_cee.c    |    3 --
 drivers/net/bna/bfa_defs.h   |    4 ++
 drivers/net/bna/bfa_ioc.c    |   82 +++++++++++++++++++++++++----------------
 drivers/net/bna/bfa_ioc.h    |   22 +++++++-----
 drivers/net/bna/bfa_ioc_ct.c |   20 ++--------
 drivers/net/bna/bfi.h        |   59 ++++++++++++++++++++----------
 drivers/net/bna/bna_enet.c   |   11 ++++--
 drivers/net/bna/bnad.c       |    9 ++++-
 8 files changed, 126 insertions(+), 84 deletions(-)

diff --git a/drivers/net/bna/bfa_cee.c b/drivers/net/bna/bfa_cee.c
index 39e5ab9..b45b8eb 100644
--- a/drivers/net/bna/bfa_cee.c
+++ b/drivers/net/bna/bfa_cee.c
@@ -22,9 +22,6 @@
 #include "bfi_cna.h"
 #include "bfa_ioc.h"
 
-#define bfa_ioc_portid(__ioc) ((__ioc)->port_id)
-#define bfa_lpuid(__arg) bfa_ioc_portid(&(__arg)->ioc)
-
 static void bfa_cee_format_lldp_cfg(struct bfa_cee_lldp_cfg *lldp_cfg);
 static void bfa_cee_format_cee_cfg(void *buffer);
 
diff --git a/drivers/net/bna/bfa_defs.h b/drivers/net/bna/bfa_defs.h
index fa81f3c..49b990c 100644
--- a/drivers/net/bna/bfa_defs.h
+++ b/drivers/net/bna/bfa_defs.h
@@ -238,6 +238,10 @@ struct bfa_mfg_block {
  * ---------------------- pci definitions ------------
  */
 
+enum {
+	BFA_PCI_DEVICE_ID_CT		= 0x14,
+};
+
 #define bfa_asic_id_ct(devid)			\
 	((devid) == PCI_DEVICE_ID_BROCADE_CT ||	\
 	(devid) == PCI_DEVICE_ID_BROCADE_CT_FC)
diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index ad98c86..a31c0cc 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -1305,7 +1305,7 @@ bfa_nw_ioc_fwver_cmp(struct bfa_ioc *ioc, struct bfi_ioc_image_hdr *fwhdr)
 	int i;
 
 	drv_fwhdr = (struct bfi_ioc_image_hdr *)
-		bfa_cb_image_get_chunk(BFA_IOC_FWIMG_TYPE(ioc), 0);
+		bfa_cb_image_get_chunk(bfa_ioc_asic_gen(ioc), 0);
 
 	for (i = 0; i < BFI_IOC_MD5SUM_SZ; i++) {
 		if (fwhdr->md5sum[i] != drv_fwhdr->md5sum[i])
@@ -1326,12 +1326,12 @@ bfa_ioc_fwver_valid(struct bfa_ioc *ioc, u32 boot_env)
 
 	bfa_nw_ioc_fwver_get(ioc, &fwhdr);
 	drv_fwhdr = (struct bfi_ioc_image_hdr *)
-		bfa_cb_image_get_chunk(BFA_IOC_FWIMG_TYPE(ioc), 0);
+		bfa_cb_image_get_chunk(bfa_ioc_asic_gen(ioc), 0);
 
 	if (fwhdr.signature != drv_fwhdr->signature)
 		return false;
 
-	if (swab32(fwhdr.param) != boot_env)
+	if (swab32(fwhdr.bootenv) != boot_env)
 		return false;
 
 	return bfa_nw_ioc_fwver_cmp(ioc, &fwhdr);
@@ -1358,11 +1358,11 @@ bfa_ioc_hwinit(struct bfa_ioc *ioc, bool force)
 {
 	enum bfi_ioc_state ioc_fwstate;
 	bool fwvalid;
-	u32 boot_env;
+	enum bfi_fwboot_env boot_env;
 
 	ioc_fwstate = readl(ioc->ioc_regs.ioc_fwstate);
 
-	boot_env = BFI_BOOT_LOADER_OS;
+	boot_env = BFI_FWBOOT_ENV_OS;
 
 	if (force)
 		ioc_fwstate = BFI_IOC_UNINIT;
@@ -1374,7 +1374,7 @@ bfa_ioc_hwinit(struct bfa_ioc *ioc, bool force)
 		false : bfa_ioc_fwver_valid(ioc, boot_env);
 
 	if (!fwvalid) {
-		bfa_ioc_boot(ioc, BFI_BOOT_TYPE_NORMAL, boot_env);
+		bfa_ioc_boot(ioc, BFI_FWBOOT_TYPE_NORMAL, boot_env);
 		return;
 	}
 
@@ -1405,7 +1405,7 @@ bfa_ioc_hwinit(struct bfa_ioc *ioc, bool force)
 	/**
 	 * Initialize the h/w for any other states.
 	 */
-	bfa_ioc_boot(ioc, BFI_BOOT_TYPE_NORMAL, boot_env);
+	bfa_ioc_boot(ioc, BFI_FWBOOT_TYPE_NORMAL, boot_env);
 }
 
 void
@@ -1522,22 +1522,23 @@ bfa_ioc_download_fw(struct bfa_ioc *ioc, u32 boot_type,
 	u32 loff = 0;
 	u32 chunkno = 0;
 	u32 i;
+	u32 asicmode;
 
 	/**
 	 * Initialize LMEM first before code download
 	 */
 	bfa_ioc_lmem_init(ioc);
 
-	fwimg = bfa_cb_image_get_chunk(BFA_IOC_FWIMG_TYPE(ioc), chunkno);
+	fwimg = bfa_cb_image_get_chunk(bfa_ioc_asic_gen(ioc), chunkno);
 
 	pgnum = bfa_ioc_smem_pgnum(ioc, loff);
 
 	writel(pgnum, ioc->ioc_regs.host_page_num_fn);
 
-	for (i = 0; i < bfa_cb_image_get_size(BFA_IOC_FWIMG_TYPE(ioc)); i++) {
+	for (i = 0; i < bfa_cb_image_get_size(bfa_ioc_asic_gen(ioc)); i++) {
 		if (BFA_IOC_FLASH_CHUNK_NO(i) != chunkno) {
 			chunkno = BFA_IOC_FLASH_CHUNK_NO(i);
-			fwimg = bfa_cb_image_get_chunk(BFA_IOC_FWIMG_TYPE(ioc),
+			fwimg = bfa_cb_image_get_chunk(bfa_ioc_asic_gen(ioc),
 					BFA_IOC_FLASH_CHUNK_ADDR(chunkno));
 		}
 
@@ -1564,12 +1565,16 @@ bfa_ioc_download_fw(struct bfa_ioc *ioc, u32 boot_type,
 		      ioc->ioc_regs.host_page_num_fn);
 
 	/*
-	 * Set boot type and boot param at the end.
+	 * Set boot type, env and device mode at the end.
 	*/
+	asicmode = BFI_FWBOOT_ASICMODE(ioc->asic_gen, ioc->mode_p0,
+					ioc->mode_p1);
+	writel(asicmode, ((ioc->ioc_regs.smem_page_start)
+			+ BFI_FWBOOT_ASICMODE_OFF));
 	writel(boot_type, ((ioc->ioc_regs.smem_page_start)
-			+ (BFI_BOOT_TYPE_OFF)));
+			+ (BFI_FWBOOT_TYPE_OFF)));
 	writel(boot_env, ((ioc->ioc_regs.smem_page_start)
-			+ (BFI_BOOT_LOADER_OFF)));
+			+ (BFI_FWBOOT_ENV_OFF)));
 }
 
 static void
@@ -1723,7 +1728,8 @@ bfa_ioc_pll_init(struct bfa_ioc *ioc)
  * as the entry vector.
  */
 static void
-bfa_ioc_boot(struct bfa_ioc *ioc, u32 boot_type, u32 boot_env)
+bfa_ioc_boot(struct bfa_ioc *ioc, enum bfi_fwboot_type boot_type,
+		enum bfi_fwboot_env boot_env)
 {
 	void __iomem *rb;
 
@@ -1736,7 +1742,7 @@ bfa_ioc_boot(struct bfa_ioc *ioc, u32 boot_type, u32 boot_env)
 	 * Initialize IOC state of all functions on a chip reset.
 	 */
 	rb = ioc->pcidev.pci_bar_kva;
-	if (boot_type == BFI_BOOT_TYPE_MEMTEST) {
+	if (boot_type == BFI_FWBOOT_TYPE_MEMTEST) {
 		writel(BFI_IOC_MEMTEST, (rb + BFA_IOC0_STATE_REG));
 		writel(BFI_IOC_MEMTEST, (rb + BFA_IOC1_STATE_REG));
 	} else {
@@ -1865,8 +1871,19 @@ bfa_nw_ioc_pci_init(struct bfa_ioc *ioc, struct bfa_pcidev *pcidev,
 {
 	ioc->ioc_mc	= mc;
 	ioc->pcidev	= *pcidev;
-	ioc->ctdev	= bfa_asic_id_ct(ioc->pcidev.device_id);
-	ioc->cna	= ioc->ctdev && !ioc->fcmode;
+
+	/**
+	 * Initialize IOC and device personality
+	 */
+	switch (pcidev->device_id) {
+	case BFA_PCI_DEVICE_ID_CT:
+		ioc->asic_gen = BFI_ASIC_GEN_CT;
+		ioc->mode_p0 = ioc->mode_p1 = BFI_FWBOOT_DEVMOD_CNA;
+		break;
+
+	default:
+		BUG_ON(1);
+	}
 
 	bfa_nw_ioc_set_ct_hwif(ioc);
 
@@ -2072,23 +2089,24 @@ bfa_ioc_get_adapter_attr(struct bfa_ioc *ioc,
 
 	bfa_ioc_get_pci_chip_rev(ioc, ad_attr->hw_ver);
 
-	ad_attr->cna_capable = ioc->cna;
-	ad_attr->trunk_capable = (ad_attr->nports > 1) && !ioc->cna;
+	ad_attr->cna_capable = bfa_ioc_is_cna(ioc);
+	ad_attr->trunk_capable = (ad_attr->nports > 1) &&
+				!bfa_ioc_is_cna(ioc) && !ad_attr->is_mezz;
 }
 
-static enum bfa_ioc_type
-bfa_ioc_get_type(struct bfa_ioc *ioc)
+enum bfa_ioc_type
+bfa_nw_ioc_get_type(struct bfa_ioc *ioc)
 {
-	if (!ioc->ctdev || ioc->fcmode)
-		return BFA_IOC_TYPE_FC;
-	else if (ioc->ioc_mc == BFI_MC_IOCFC)
-		return BFA_IOC_TYPE_FCoE;
-	else if (ioc->ioc_mc == BFI_MC_LL)
-		return BFA_IOC_TYPE_LL;
-	else {
-		BUG_ON(!(ioc->ioc_mc == BFI_MC_LL));
+	enum bfi_fwboot_devmode mode;
+
+	if (ioc->clscode == BFI_PCIFN_CLASS_ETH)
 		return BFA_IOC_TYPE_LL;
-	}
+
+	BUG_ON(!(ioc->clscode == BFI_PCIFN_CLASS_FC));
+
+	mode = (ioc->port_id == 0) ? ioc->mode_p0 : ioc->mode_p1;
+	return (mode == BFI_FWBOOT_DEVMOD_HBA)
+		? BFA_IOC_TYPE_FC : BFA_IOC_TYPE_FCoE;
 }
 
 static void
@@ -2201,7 +2219,7 @@ bfa_nw_ioc_get_attr(struct bfa_ioc *ioc, struct bfa_ioc_attr *ioc_attr)
 	ioc_attr->state = bfa_ioc_get_state(ioc);
 	ioc_attr->port_id = ioc->port_id;
 
-	ioc_attr->ioc_type = bfa_ioc_get_type(ioc);
+	ioc_attr->ioc_type = bfa_nw_ioc_get_type(ioc);
 
 	bfa_ioc_get_adapter_attr(ioc, &ioc_attr->adapter_attr);
 
@@ -2239,7 +2257,7 @@ bfa_ioc_recover(struct bfa_ioc *ioc)
 static void
 bfa_ioc_check_attr_wwns(struct bfa_ioc *ioc)
 {
-	if (bfa_ioc_get_type(ioc) == BFA_IOC_TYPE_LL)
+	if (bfa_nw_ioc_get_type(ioc) == BFA_IOC_TYPE_LL)
 		return;
 }
 
diff --git a/drivers/net/bna/bfa_ioc.h b/drivers/net/bna/bfa_ioc.h
index b3c3c5e..8ffdbea 100644
--- a/drivers/net/bna/bfa_ioc.h
+++ b/drivers/net/bna/bfa_ioc.h
@@ -186,12 +186,11 @@ struct bfa_ioc {
 	void			*dbg_fwsave;
 	int			dbg_fwsave_len;
 	bool			dbg_fwsave_once;
+	enum bfi_pcifn_class	clscode;
 	enum bfi_mclass		ioc_mc;
 	struct bfa_ioc_regs	ioc_regs;
 	struct bfa_ioc_drv_stats stats;
 	bool			fcmode;
-	bool			ctdev;
-	bool			cna;
 	bool			pllinit;
 	bool			stats_busy;	/*!< outstanding stats */
 	u8			port_id;
@@ -202,6 +201,10 @@ struct bfa_ioc {
 	struct bfa_ioc_mbox_mod	mbox_mod;
 	struct bfa_ioc_hwif	*ioc_hwif;
 	struct bfa_iocpf	iocpf;
+	enum bfi_fwboot_env	boot_env;
+	enum bfi_asic_gen	asic_gen;
+	enum bfi_fwboot_devmode	mode_p0;
+	enum bfi_fwboot_devmode	mode_p1;
 };
 
 struct bfa_ioc_hwif {
@@ -225,6 +228,9 @@ struct bfa_ioc_hwif {
 #define bfa_ioc_devid(__ioc)		((__ioc)->pcidev.device_id)
 #define bfa_ioc_bar0(__ioc)		((__ioc)->pcidev.pci_bar_kva)
 #define bfa_ioc_portid(__ioc)		((__ioc)->port_id)
+#define bfa_ioc_asic_gen(__ioc)		((__ioc)->asic_gen)
+#define bfa_ioc_is_cna(__ioc)		\
+	(bfa_nw_ioc_get_type(ioc) == BFA_IOC_TYPE_FCoE)
 #define bfa_ioc_fetch_stats(__ioc, __stats) \
 		(((__stats)->drv_stats) = (__ioc)->stats)
 #define bfa_ioc_clr_stats(__ioc)	\
@@ -238,12 +244,9 @@ struct bfa_ioc_hwif {
 
 #define bfa_ioc_stats(_ioc, _stats)	((_ioc)->stats._stats++)
 #define BFA_IOC_FWIMG_MINSZ	(16 * 1024)
-#define BFA_IOC_FWIMG_TYPE(__ioc)					\
-	(((__ioc)->ctdev) ?						\
-	 (((__ioc)->fcmode) ? BFI_IMAGE_CT_FC : BFI_IMAGE_CT_CNA) :	\
-	 BFI_IMAGE_CB_FC)
 #define BFA_IOC_FW_SMEM_SIZE(__ioc)					\
-	(((__ioc)->ctdev) ? BFI_SMEM_CT_SIZE : BFI_SMEM_CB_SIZE)
+	((bfa_ioc_asic_gen(__ioc) == BFI_ASIC_GEN_CB)			\
+	? BFI_SMEM_CB_SIZE : BFI_SMEM_CT_SIZE)
 #define BFA_IOC_FLASH_CHUNK_NO(off)		(off / BFI_FLASH_CHUNK_SZ_WORDS)
 #define BFA_IOC_FLASH_OFFSET_IN_CHUNK(off)	(off % BFI_FLASH_CHUNK_SZ_WORDS)
 #define BFA_IOC_FLASH_CHUNK_ADDR(chunkno)  (chunkno * BFI_FLASH_CHUNK_SZ_WORDS)
@@ -286,6 +289,7 @@ void bfa_nw_ioc_disable(struct bfa_ioc *ioc);
 
 void bfa_nw_ioc_error_isr(struct bfa_ioc *ioc);
 bool bfa_nw_ioc_is_disabled(struct bfa_ioc *ioc);
+enum bfa_ioc_type bfa_nw_ioc_get_type(struct bfa_ioc *ioc);
 void bfa_nw_ioc_get_attr(struct bfa_ioc *ioc, struct bfa_ioc_attr *ioc_attr);
 void bfa_nw_ioc_notify_register(struct bfa_ioc *ioc,
 	struct bfa_ioc_notify *notify);
@@ -309,7 +313,7 @@ void bfa_nw_iocpf_sem_timeout(void *ioc);
 /*
  * F/W Image Size & Chunk
  */
-u32 *bfa_cb_image_get_chunk(int type, u32 off);
-u32 bfa_cb_image_get_size(int type);
+u32 *bfa_cb_image_get_chunk(enum bfi_asic_gen asic_gen, u32 off);
+u32 bfa_cb_image_get_size(enum bfi_asic_gen asic_gen);
 
 #endif /* __BFA_IOC_H__ */
diff --git a/drivers/net/bna/bfa_ioc_ct.c b/drivers/net/bna/bfa_ioc_ct.c
index 75ecf7a..2daa1dd 100644
--- a/drivers/net/bna/bfa_ioc_ct.c
+++ b/drivers/net/bna/bfa_ioc_ct.c
@@ -84,15 +84,9 @@ bfa_ioc_ct_firmware_lock(struct bfa_ioc *ioc)
 	struct bfi_ioc_image_hdr fwhdr;
 
 	/**
-	 * Firmware match check is relevant only for CNA.
-	 */
-	if (!ioc->cna)
-		return true;
-
-	/**
 	 * If bios boot (flash based) -- do not increment usage count
 	 */
-	if (bfa_cb_image_get_size(BFA_IOC_FWIMG_TYPE(ioc)) <
+	if (bfa_cb_image_get_size(bfa_ioc_asic_gen(ioc)) <
 						BFA_IOC_FWIMG_MINSZ)
 		return true;
 
@@ -140,15 +134,9 @@ bfa_ioc_ct_firmware_unlock(struct bfa_ioc *ioc)
 	u32 usecnt;
 
 	/**
-	 * Firmware lock is relevant only for CNA.
-	 */
-	if (!ioc->cna)
-		return;
-
-	/**
 	 * If bios boot (flash based) -- do not decrement usage count
 	 */
-	if (bfa_cb_image_get_size(BFA_IOC_FWIMG_TYPE(ioc)) <
+	if (bfa_cb_image_get_size(bfa_ioc_asic_gen(ioc)) <
 						BFA_IOC_FWIMG_MINSZ)
 		return;
 
@@ -171,7 +159,7 @@ bfa_ioc_ct_firmware_unlock(struct bfa_ioc *ioc)
 static void
 bfa_ioc_ct_notify_fail(struct bfa_ioc *ioc)
 {
-	if (ioc->cna) {
+	if (bfa_ioc_is_cna(ioc)) {
 		writel(__FW_INIT_HALT_P, ioc->ioc_regs.ll_halt);
 		writel(__FW_INIT_HALT_P, ioc->ioc_regs.alt_ll_halt);
 		/* Wait for halt to take effect */
@@ -329,7 +317,7 @@ bfa_ioc_ct_isr_mode_set(struct bfa_ioc *ioc, bool msix)
 static void
 bfa_ioc_ct_ownership_reset(struct bfa_ioc *ioc)
 {
-	if (ioc->cna) {
+	if (bfa_ioc_is_cna(ioc)) {
 		bfa_nw_ioc_sem_get(ioc->ioc_regs.ioc_usage_sem_reg);
 		writel(0, ioc->ioc_regs.ioc_usage_reg);
 		bfa_nw_ioc_sem_release(ioc->ioc_regs.ioc_usage_sem_reg);
diff --git a/drivers/net/bna/bfi.h b/drivers/net/bna/bfi.h
index c5d46a6..cd51edd 100644
--- a/drivers/net/bna/bfi.h
+++ b/drivers/net/bna/bfi.h
@@ -28,12 +28,6 @@
  */
 #define	BFI_FLASH_CHUNK_SZ			256	/*!< Flash chunk size */
 #define	BFI_FLASH_CHUNK_SZ_WORDS	(BFI_FLASH_CHUNK_SZ/sizeof(u32))
-enum {
-	BFI_IMAGE_CB_FC,
-	BFI_IMAGE_CT_FC,
-	BFI_IMAGE_CT_CNA,
-	BFI_IMAGE_MAX,
-};
 
 /**
  * Msg header common to all msgs
@@ -191,17 +185,6 @@ enum bfi_mclass {
 #define BFI_IOC_MAX_CQS_ASIC	8
 #define BFI_IOC_MSGLEN_MAX	32	/* 32 bytes */
 
-#define BFI_BOOT_TYPE_OFF		8
-#define BFI_BOOT_LOADER_OFF		12
-
-#define BFI_BOOT_TYPE_NORMAL		0
-#define	BFI_BOOT_TYPE_FLASH		1
-#define	BFI_BOOT_TYPE_MEMTEST		2
-
-#define BFI_BOOT_LOADER_OS		0
-
-#define BFI_FWBOOT_ENV_OS		0
-
 #define BFI_BOOT_MEMTEST_RES_ADDR   0x900
 #define BFI_BOOT_MEMTEST_RES_SIG    0xA0A1A2A3
 
@@ -211,6 +194,15 @@ enum bfi_mclass {
  *----------------------------------------------------------------------
  */
 
+/**
+ * Different asic generations
+ */
+enum bfi_asic_gen {
+	BFI_ASIC_GEN_CB		= 1,	/* 8G FC		*/
+	BFI_ASIC_GEN_CT		= 2,	/* 8G FC or 10G CNA	*/
+	BFI_ASIC_GEN_CT2	= 3,	/* 16G FC or 10G CNA	*/
+};
+
 enum bfi_ioc_h2i_msgs {
 	BFI_IOC_H2I_ENABLE_REQ		= 1,
 	BFI_IOC_H2I_DISABLE_REQ		= 2,
@@ -292,13 +284,42 @@ struct bfi_ioc_getattr_reply {
 #define BFI_IOC_MD5SUM_SZ	4
 struct bfi_ioc_image_hdr {
 	u32	signature;	/*!< constant signature */
-	u32	rsvd_a;
+	u8	asic_gen;	/*!< asic generation */
+	u8	mode_p0;	/*!< device mode for port 0 */
+	u8	mode_p1;	/*!< device mode for port 1 */
+	u8	rsvd_a;
 	u32	exec;		/*!< exec vector	*/
-	u32	param;		/*!< parameters		*/
+	u32	bootenv;	/*!< firmware boot env */
 	u32	rsvd_b[4];
 	u32	md5sum[BFI_IOC_MD5SUM_SZ];
 };
 
+#define BFI_FWBOOT_ASICMODE_OFF		4
+#define BFI_FWBOOT_TYPE_OFF		8
+#define BFI_FWBOOT_ENV_OFF		12
+#define BFI_FWBOOT_ASICMODE(__asic_gen, __mode_p0, __mode_p1) \
+	(((u32)(__asic_gen)) << 24 |	\
+	 ((u32)(__mode_p0)) << 16 |	\
+	 ((u32)(__mode_p0)) << 8)
+
+enum bfi_fwboot_type {
+	BFI_FWBOOT_TYPE_NORMAL	= 0,
+	BFI_FWBOOT_TYPE_FLASH	= 1,
+	BFI_FWBOOT_TYPE_MEMTEST	= 2,
+};
+
+enum bfi_fwboot_env {
+	BFI_FWBOOT_ENV_OS	= 0,
+	BFI_FWBOOT_ENV_BIOS	= 1,
+	BFI_FWBOOT_ENV_UEFI	= 2,
+};
+
+enum bfi_fwboot_devmode {
+	BFI_FWBOOT_DEVMOD_HBA	= 1,
+	BFI_FWBOOT_DEVMOD_CNA	= 2,
+	BFI_FWBOOT_DEVMOD_NIC	= 3,
+};
+
 /**
  *  BFI_IOC_I2H_READY_EVENT message
  */
diff --git a/drivers/net/bna/bna_enet.c b/drivers/net/bna/bna_enet.c
index 668c72e..30afb41 100644
--- a/drivers/net/bna/bna_enet.c
+++ b/drivers/net/bna/bna_enet.c
@@ -1293,15 +1293,18 @@ bna_enet_type_get(struct bna_enet *enet)
 #define enable_mbox_intr(_ioceth)					\
 do {									\
 	u32 intr_status;						\
-	bna_intr_status_get((_ioceth)->bna, intr_status);		\
-	bnad_cb_mbox_intr_enable((_ioceth)->bna->bnad);			\
-	bna_mbox_intr_enable((_ioceth)->bna);				\
+	if (((_ioceth)->ioc.boot_env) == BFI_FWBOOT_ENV_OS) {		\
+		bna_intr_status_get((_ioceth)->bna, intr_status);	\
+		bnad_cb_mbox_intr_enable((_ioceth)->bna->bnad);		\
+		bna_mbox_intr_enable((_ioceth)->bna);			\
+	}								\
 } while (0)
 
 #define disable_mbox_intr(_ioceth)					\
 do {									\
 	bna_mbox_intr_disable((_ioceth)->bna);				\
-	bnad_cb_mbox_intr_disable((_ioceth)->bna->bnad);		\
+	if (((_ioceth)->ioc.boot_env) == BFI_FWBOOT_ENV_OS)		\
+		bnad_cb_mbox_intr_disable((_ioceth)->bna->bnad);	\
 } while (0)
 
 #define call_ioceth_stop_cbfn(_ioceth)					\
diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index 50a6868..f696d3a 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -3346,7 +3346,14 @@ static DEFINE_PCI_DEVICE_TABLE(bnad_pci_id_table) = {
 			PCI_DEVICE_ID_BROCADE_CT),
 		.class = PCI_CLASS_NETWORK_ETHERNET << 8,
 		.class_mask =  0xffff00
-	}, {0,  }
+	},
+	{
+		PCI_DEVICE(PCI_VENDOR_ID_BROCADE,
+			PCI_DEVICE_ID_BROCADE_CT2),
+		.class = PCI_CLASS_NETWORK_ETHERNET << 8,
+		.class_mask =  0xffff00
+	},
+	{0,  },
 };
 
 MODULE_DEVICE_TABLE(pci, bnad_pci_id_table);
-- 
1.7.1

