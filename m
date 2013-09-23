From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool] sfc: Add support for EF10 registers
Date: Mon, 23 Sep 2013 17:04:58 +0100
Message-ID: <1379952298.2485.35.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:16031 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752737Ab3IWQFC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 12:05:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This works in conjunction with the recently submitted driver change
'sfc: Add EF10 registers to register dump'.

Ben.

 sfc.c | 159 +++++++++++++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 109 insertions(+), 50 deletions(-)

diff --git a/sfc.c b/sfc.c
index 3ba3da8..2e15f52 100644
--- a/sfc.c
+++ b/sfc.c
@@ -1,6 +1,6 @@
 /****************************************************************************
  * Support for Solarflare Solarstorm network controllers and boards
- * Copyright 2010 Solarflare Communications Inc.
+ * Copyright 2010-2012 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
@@ -15,7 +15,9 @@
 #define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
 #endif
 
-/* Register definitions (from linux-2.6/drivers/net/sfc/regs.h) */
+/* Falcon architecture register definitions
+ * (from linux/drivers/net/ethernet/sfc/farch_regs.h)
+ */
 
 /* ADR_REGION_REG: Address region register */
 #define	FR_AZ_ADR_REGION 0x00000000
@@ -2509,9 +2511,40 @@
 #define	FRF_CZ_MC_TREG_SMEM_ROW_LBN 0
 #define	FRF_CZ_MC_TREG_SMEM_ROW_WIDTH 32
 
+/* EF10 architecture register definitions
+ * (from linux/drivers/net/ethernet/sfc/ef10_regs.h)
+ */
+
+/* BIU_HW_REV_ID_REG:  */
+#define	ER_DZ_BIU_HW_REV_ID 0x00000000
+#define	ERF_DZ_HW_REV_ID_LBN 0
+#define	ERF_DZ_HW_REV_ID_WIDTH 32
+
+/* BIU_MC_SFT_STATUS_REG:  */
+#define	ER_DZ_BIU_MC_SFT_STATUS 0x00000010
+#define	ER_DZ_BIU_MC_SFT_STATUS_STEP 4
+#define	ER_DZ_BIU_MC_SFT_STATUS_ROWS 8
+#define	ERF_DZ_MC_SFT_STATUS_LBN 0
+#define	ERF_DZ_MC_SFT_STATUS_WIDTH 32
+
+/* BIU_INT_ISR_REG:  */
+#define	ER_DZ_BIU_INT_ISR 0x00000090
+#define	ERF_DZ_ISR_REG_LBN 0
+#define	ERF_DZ_ISR_REG_WIDTH 32
+
+/* MC_DB_LWRD_REG:  */
+#define	ER_DZ_MC_DB_LWRD 0x00000200
+#define	ERF_DZ_MC_DOORBELL_L_LBN 0
+#define	ERF_DZ_MC_DOORBELL_L_WIDTH 32
+
+/* MC_DB_HWRD_REG:  */
+#define	ER_DZ_MC_DB_HWRD 0x00000204
+#define	ERF_DZ_MC_DOORBELL_H_LBN 0
+#define	ERF_DZ_MC_DOORBELL_H_WIDTH 32
+
 /*
  * Register dump definition.  This is mostly taken from
- * linux-2.6/drivers/net/sfc/nic.c but has names and bitfield
+ * linux/drivers/net/ethernet/sfc/nic.c but has names and bitfield
  * definitions added.
  *
  * The definitions of efx_nic_regs and efx_nic_reg_tables should be
@@ -2520,37 +2553,41 @@
  * are defined differently.
  */
 
-#define REGISTER_REVISION_A	1
-#define REGISTER_REVISION_B	2
-#define REGISTER_REVISION_C	3
-#define REGISTER_REVISION_Z	3	/* latest revision */
+#define REGISTER_REVISION_FA	1
+#define REGISTER_REVISION_FB	2
+#define REGISTER_REVISION_FC	3
+#define REGISTER_REVISION_FZ	3	/* last Falcon arch revision */
+#define REGISTER_REVISION_ED	4
+#define REGISTER_REVISION_EZ	4	/* latest EF10 arch revision */
 
 struct efx_nic_reg_field {
 	const char *name;
 	u32 lbn:7, width:8;
-	u32 min_revision:2, max_revision:2;
+	u32 min_revision:3, max_revision:3;
 };
 
-#define REGISTER_FIELD_RENAME(name, display_name, min_rev, max_rev) {	\
+#define REGISTER_FIELD_RENAME(name, display_name, arch, min_rev, max_rev) { \
 	display_name,							\
-	FRF_ ## min_rev ## max_rev ## _ ## name ## _LBN,		\
-	FRF_ ## min_rev ## max_rev ## _ ## name ## _WIDTH,		\
-	REGISTER_REVISION_ ## min_rev, REGISTER_REVISION_ ## max_rev	\
+	arch ## RF_ ## min_rev ## max_rev ## _ ## name ## _LBN,		\
+	arch ## RF_ ## min_rev ## max_rev ## _ ## name ## _WIDTH,	\
+	REGISTER_REVISION_ ## arch ## min_rev,				\
+	REGISTER_REVISION_ ## arch ## max_rev				\
 }
-#define REGISTER_FIELD(name, min_rev, max_rev)			\
-	REGISTER_FIELD_RENAME(name, #name, min_rev, max_rev)
-#define REGISTER_FIELD_AA(name) REGISTER_FIELD(name, A, A)
-#define REGISTER_FIELD_AB(name) REGISTER_FIELD(name, A, B)
-#define REGISTER_FIELD_AZ(name) REGISTER_FIELD(name, A, Z)
-#define REGISTER_FIELD_BB(name) REGISTER_FIELD(name, B, B)
-#define REGISTER_FIELD_BZ(name) REGISTER_FIELD(name, B, Z)
-#define REGISTER_FIELD_CZ(name) REGISTER_FIELD(name, C, Z)
+#define REGISTER_FIELD(name, arch, min_rev, max_rev)			\
+	REGISTER_FIELD_RENAME(name, #name, arch, min_rev, max_rev)
+#define REGISTER_FIELD_AA(name) REGISTER_FIELD(name, F, A, A)
+#define REGISTER_FIELD_AB(name) REGISTER_FIELD(name, F, A, B)
+#define REGISTER_FIELD_AZ(name) REGISTER_FIELD(name, F, A, Z)
+#define REGISTER_FIELD_BB(name) REGISTER_FIELD(name, F, B, B)
+#define REGISTER_FIELD_BZ(name) REGISTER_FIELD(name, F, B, Z)
+#define REGISTER_FIELD_CZ(name) REGISTER_FIELD(name, F, C, Z)
+#define REGISTER_FIELD_DZ(name) REGISTER_FIELD(name, E, D, Z)
 #define REGISTER_FIELD_AZ_RENAME(name, display_name)	\
-	REGISTER_FIELD_RENAME(name, display_name, A, Z)
+	REGISTER_FIELD_RENAME(name, display_name, F, A, Z)
 #define REGISTER_FIELD_BZ_RENAME(name, display_name)	\
-	REGISTER_FIELD_RENAME(name, display_name, B, Z)
+	REGISTER_FIELD_RENAME(name, display_name, F, B, Z)
 #define REGISTER_FIELD_CZ_RENAME(name, display_name)	\
-	REGISTER_FIELD_RENAME(name, display_name, C, Z)
+	REGISTER_FIELD_RENAME(name, display_name, F, C, Z)
 
 static const struct efx_nic_reg_field efx_nic_reg_fields_ADR_REGION[] = {
 	REGISTER_FIELD_AZ(ADR_REGION0),
@@ -3383,6 +3420,15 @@ static const struct efx_nic_reg_field efx_nic_reg_fields_XX_TXDRV_CTL[] = {
 	REGISTER_FIELD_AB(XX_DEQC),
 	REGISTER_FIELD_AB(XX_DEQD),
 };
+static const struct efx_nic_reg_field efx_nic_reg_fields_BIU_HW_REV_ID[] = {
+	REGISTER_FIELD_DZ(HW_REV_ID),
+};
+static const struct efx_nic_reg_field efx_nic_reg_fields_MC_DB_LWRD[] = {
+	REGISTER_FIELD_DZ(MC_DOORBELL_L),
+};
+static const struct efx_nic_reg_field efx_nic_reg_fields_MC_DB_HWRD[] = {
+	REGISTER_FIELD_DZ(MC_DOORBELL_H),
+};
 static const struct efx_nic_reg_field efx_nic_reg_fields_RX_DESC_PTR_TBL[] = {
 	/* Abbreviate field names to reduce the table width */
 	REGISTER_FIELD_AZ_RENAME(RX_DESCQ_EN, "EN"),
@@ -3492,26 +3538,31 @@ static const struct efx_nic_reg_field efx_nic_reg_fields_TX_MAC_FILTER_TBL0[] =
 static const struct efx_nic_reg_field efx_nic_reg_fields_MC_TREG_SMEM[] = {
 	REGISTER_FIELD_CZ(MC_TREG_SMEM_ROW),
 };
+static const struct efx_nic_reg_field efx_nic_reg_fields_BIU_MC_SFT_STATUS[] = {
+	REGISTER_FIELD_DZ(MC_SFT_STATUS),
+};
 
 struct efx_nic_reg {
 	const char *name;
 	const struct efx_nic_reg_field *fields;
 	u32 field_count:7;
-	u32 min_revision:2, max_revision:2;
+	u32 min_revision:3, max_revision:3;
 };
 
-#define REGISTER(name, min_rev, max_rev) {				\
+#define REGISTER(name, arch, min_rev, max_rev) {			\
 	#name,								\
 	efx_nic_reg_fields_ ## name,					\
 	ARRAY_SIZE(efx_nic_reg_fields_ ## name),			\
-	REGISTER_REVISION_ ## min_rev, REGISTER_REVISION_ ## max_rev	\
+	REGISTER_REVISION_ ## arch ## min_rev,				\
+	REGISTER_REVISION_ ## arch ## max_rev				\
 }
-#define REGISTER_AA(name) REGISTER(name, A, A)
-#define REGISTER_AB(name) REGISTER(name, A, B)
-#define REGISTER_AZ(name) REGISTER(name, A, Z)
-#define REGISTER_BB(name) REGISTER(name, B, B)
-#define REGISTER_BZ(name) REGISTER(name, B, Z)
-#define REGISTER_CZ(name) REGISTER(name, C, Z)
+#define REGISTER_AA(name) REGISTER(name, F, A, A)
+#define REGISTER_AB(name) REGISTER(name, F, A, B)
+#define REGISTER_AZ(name) REGISTER(name, F, A, Z)
+#define REGISTER_BB(name) REGISTER(name, F, B, B)
+#define REGISTER_BZ(name) REGISTER(name, F, B, Z)
+#define REGISTER_CZ(name) REGISTER(name, F, C, Z)
+#define REGISTER_DZ(name) REGISTER(name, E, D, Z)
 
 static const struct efx_nic_reg efx_nic_regs[] = {
 	REGISTER_AZ(ADR_REGION),
@@ -3618,41 +3669,46 @@ static const struct efx_nic_reg efx_nic_regs[] = {
 	REGISTER_AB(XX_TXDRV_CTL),
 	/* XX_PRBS_CTL, XX_PRBS_CHK and XX_PRBS_ERR are not used */
 	/* XX_CORE_STAT is partly RC */
+	REGISTER_DZ(BIU_HW_REV_ID),
+	REGISTER_DZ(MC_DB_LWRD),
+	REGISTER_DZ(MC_DB_HWRD),
 };
 
 struct efx_nic_reg_table {
 	const char *name;
 	const struct efx_nic_reg_field *fields;
 	u32 field_count:7;
-	u32 min_revision:2, max_revision:2;
+	u32 min_revision:3, max_revision:3;
 	u32 step:6, rows:21;
 };
 
-#define REGISTER_TABLE_DIMENSIONS(name, _, min_rev, max_rev, step, rows) { \
+#define REGISTER_TABLE_DIMENSIONS(name, _, arch, min_rev, max_rev, step, rows) { \
 	#name,								\
 	efx_nic_reg_fields_ ## name,					\
 	ARRAY_SIZE(efx_nic_reg_fields_ ## name),			\
-	REGISTER_REVISION_ ## min_rev, REGISTER_REVISION_ ## max_rev,	\
+	REGISTER_REVISION_ ## arch ## min_rev,				\
+	REGISTER_REVISION_ ## arch ## max_rev,				\
 	step, rows							\
 }
-#define REGISTER_TABLE(name, min_rev, max_rev) 				\
+#define REGISTER_TABLE(name, arch, min_rev, max_rev)			\
 	REGISTER_TABLE_DIMENSIONS(					\
-		name, FR_ ## min_rev ## max_rev ## _ ## name,		\
-		min_rev, max_rev,					\
-		FR_ ## min_rev ## max_rev ## _ ## name ## _STEP,	\
-		FR_ ## min_rev ## max_rev ## _ ## name ## _ROWS)
-#define REGISTER_TABLE_AA(name) REGISTER_TABLE(name, A, A)
-#define REGISTER_TABLE_AZ(name) REGISTER_TABLE(name, A, Z)
-#define REGISTER_TABLE_BB(name) REGISTER_TABLE(name, B, B)
-#define REGISTER_TABLE_BZ(name) REGISTER_TABLE(name, B, Z)
+		name, arch ## R_ ## min_rev ## max_rev ## _ ## name,	\
+		arch, min_rev, max_rev,					\
+		arch ## R_ ## min_rev ## max_rev ## _ ## name ## _STEP,	\
+		arch ## R_ ## min_rev ## max_rev ## _ ## name ## _ROWS)
+#define REGISTER_TABLE_AA(name) REGISTER_TABLE(name, F, A, A)
+#define REGISTER_TABLE_AZ(name) REGISTER_TABLE(name, F, A, Z)
+#define REGISTER_TABLE_BB(name) REGISTER_TABLE(name, F, B, B)
+#define REGISTER_TABLE_BZ(name) REGISTER_TABLE(name, F, B, Z)
 #define REGISTER_TABLE_BB_CZ(name)					\
-	REGISTER_TABLE_DIMENSIONS(name, FR_BZ_ ## name, B, B,		\
+	REGISTER_TABLE_DIMENSIONS(name, FR_BZ_ ## name, F, B, B,	\
 				  FR_BZ_ ## name ## _STEP,		\
 				  FR_BB_ ## name ## _ROWS),		\
-	REGISTER_TABLE_DIMENSIONS(name, FR_BZ_ ## name, C, Z,		\
+	REGISTER_TABLE_DIMENSIONS(name, FR_BZ_ ## name, F, C, Z,	\
 				  FR_BZ_ ## name ## _STEP,		\
 				  FR_CZ_ ## name ## _ROWS)
-#define REGISTER_TABLE_CZ(name) REGISTER_TABLE(name, C, Z)
+#define REGISTER_TABLE_CZ(name) REGISTER_TABLE(name, F, C, Z)
+#define REGISTER_TABLE_DZ(name) REGISTER_TABLE(name, E, D, Z)
 
 static const struct efx_nic_reg_table efx_nic_reg_tables[] = {
 	/* DRIVER is not used */
@@ -3670,9 +3726,9 @@ static const struct efx_nic_reg_table efx_nic_reg_tables[] = {
 	 * 1K entries allows for some expansion of queue count and
 	 * size before we need to change the version. */
 	REGISTER_TABLE_DIMENSIONS(BUF_FULL_TBL_KER, FR_AA_BUF_FULL_TBL_KER,
-				  A, A, 8, 1024),
+				  F, A, A, 8, 1024),
 	REGISTER_TABLE_DIMENSIONS(BUF_FULL_TBL, FR_BZ_BUF_FULL_TBL,
-				  B, Z, 8, 1024),
+				  F, B, Z, 8, 1024),
 	REGISTER_TABLE_CZ(RX_MAC_FILTER_TBL0),
 	REGISTER_TABLE_BB_CZ(TIMER_TBL),
 	REGISTER_TABLE_BB_CZ(TX_PACE_TBL),
@@ -3682,7 +3738,10 @@ static const struct efx_nic_reg_table efx_nic_reg_tables[] = {
 	REGISTER_TABLE_CZ(MC_TREG_SMEM),
 	/* MSIX_PBA_TABLE is not mapped */
 	/* SRM_DBG is not mapped (and is redundant with BUF_FLL_TBL) */
+#if !defined(EFX_USE_KCOMPAT) || defined(EFX_HAVE_VMALLOC_REG_DUMP_BUF)
 	REGISTER_TABLE_BZ(RX_FILTER_TBL0),
+#endif
+	REGISTER_TABLE_DZ(BIU_MC_SFT_STATUS),
 };
 
 static size_t column_width(const struct efx_nic_reg_field *field)
@@ -3844,7 +3903,7 @@ sfc_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 	const void *buf = regs->data;
 	const void *end = regs->data + regs->len;
 
-	if (revision > REGISTER_REVISION_Z)
+	if (revision > REGISTER_REVISION_ED)
 		return -1;
 
 	for (reg = efx_nic_regs;	


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
