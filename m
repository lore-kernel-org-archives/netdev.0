From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 6/17][BNX2]: Re-organize firmware structures.
Date: Thu, 16 Nov 2006 19:00:06 -0800
Message-ID: <1163732406.6658.28.camel@rh4>
References: <1163731443.6658.8.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:24077 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1424917AbWKQCHn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 21:07:43 -0500
To: davem@davemloft.net
In-Reply-To: <1163731443.6658.8.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Re-organize firmware structures.

Re-organize the firmware handling code and declarations a bit to make
the code more compact.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 0a46b45..2633579 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2214,11 +2214,12 @@ load_rv2p_fw(struct bnx2 *bp, u32 *rv2p_
 	}
 }
 
-static void
+static int
 load_cpu_fw(struct bnx2 *bp, struct cpu_reg *cpu_reg, struct fw_info *fw)
 {
 	u32 offset;
 	u32 val;
+	int rc;
 
 	/* Halt the CPU. */
 	val = REG_RD_IND(bp, cpu_reg->mode);
@@ -2228,7 +2229,18 @@ load_cpu_fw(struct bnx2 *bp, struct cpu_
 
 	/* Load the Text area. */
 	offset = cpu_reg->spad_base + (fw->text_addr - cpu_reg->mips_view_base);
-	if (fw->text) {
+	if (fw->gz_text) {
+		u32 text_len;
+		void *text;
+
+		rc = bnx2_gunzip(bp, fw->gz_text, fw->gz_text_len, &text,
+				 &text_len);
+		if (rc)
+			return rc;
+
+		fw->text = text;
+	}
+	if (fw->gz_text) {
 		int j;
 
 		for (j = 0; j < (fw->text_len / 4); j++, offset += 4) {
@@ -2286,13 +2298,15 @@ load_cpu_fw(struct bnx2 *bp, struct cpu_
 	val &= ~cpu_reg->mode_value_halt;
 	REG_WR_IND(bp, cpu_reg->state, cpu_reg->state_value_clear);
 	REG_WR_IND(bp, cpu_reg->mode, val);
+
+	return 0;
 }
 
 static int
 bnx2_init_cpus(struct bnx2 *bp)
 {
 	struct cpu_reg cpu_reg;
-	struct fw_info fw;
+	struct fw_info *fw;
 	int rc = 0;
 	void *text;
 	u32 text_len;
@@ -2329,44 +2343,12 @@ bnx2_init_cpus(struct bnx2 *bp)
 	cpu_reg.spad_base = BNX2_RXP_SCRATCH;
 	cpu_reg.mips_view_base = 0x8000000;
 
-	fw.ver_major = bnx2_RXP_b06FwReleaseMajor;
-	fw.ver_minor = bnx2_RXP_b06FwReleaseMinor;
-	fw.ver_fix = bnx2_RXP_b06FwReleaseFix;
-	fw.start_addr = bnx2_RXP_b06FwStartAddr;
+	fw = &bnx2_rxp_fw_06;
 
-	fw.text_addr = bnx2_RXP_b06FwTextAddr;
-	fw.text_len = bnx2_RXP_b06FwTextLen;
-	fw.text_index = 0;
-
-	rc = bnx2_gunzip(bp, bnx2_RXP_b06FwText, sizeof(bnx2_RXP_b06FwText),
-			 &text, &text_len);
+	rc = load_cpu_fw(bp, &cpu_reg, fw);
 	if (rc)
 		goto init_cpu_err;
 
-	fw.text = text;
-
-	fw.data_addr = bnx2_RXP_b06FwDataAddr;
-	fw.data_len = bnx2_RXP_b06FwDataLen;
-	fw.data_index = 0;
-	fw.data = bnx2_RXP_b06FwData;
-
-	fw.sbss_addr = bnx2_RXP_b06FwSbssAddr;
-	fw.sbss_len = bnx2_RXP_b06FwSbssLen;
-	fw.sbss_index = 0;
-	fw.sbss = bnx2_RXP_b06FwSbss;
-
-	fw.bss_addr = bnx2_RXP_b06FwBssAddr;
-	fw.bss_len = bnx2_RXP_b06FwBssLen;
-	fw.bss_index = 0;
-	fw.bss = bnx2_RXP_b06FwBss;
-
-	fw.rodata_addr = bnx2_RXP_b06FwRodataAddr;
-	fw.rodata_len = bnx2_RXP_b06FwRodataLen;
-	fw.rodata_index = 0;
-	fw.rodata = bnx2_RXP_b06FwRodata;
-
-	load_cpu_fw(bp, &cpu_reg, &fw);
-
 	/* Initialize the TX Processor. */
 	cpu_reg.mode = BNX2_TXP_CPU_MODE;
 	cpu_reg.mode_value_halt = BNX2_TXP_CPU_MODE_SOFT_HALT;
@@ -2381,44 +2363,12 @@ bnx2_init_cpus(struct bnx2 *bp)
 	cpu_reg.spad_base = BNX2_TXP_SCRATCH;
 	cpu_reg.mips_view_base = 0x8000000;
 
-	fw.ver_major = bnx2_TXP_b06FwReleaseMajor;
-	fw.ver_minor = bnx2_TXP_b06FwReleaseMinor;
-	fw.ver_fix = bnx2_TXP_b06FwReleaseFix;
-	fw.start_addr = bnx2_TXP_b06FwStartAddr;
+	fw = &bnx2_txp_fw_06;
 
-	fw.text_addr = bnx2_TXP_b06FwTextAddr;
-	fw.text_len = bnx2_TXP_b06FwTextLen;
-	fw.text_index = 0;
-
-	rc = bnx2_gunzip(bp, bnx2_TXP_b06FwText, sizeof(bnx2_TXP_b06FwText),
-			 &text, &text_len);
+	rc = load_cpu_fw(bp, &cpu_reg, fw);
 	if (rc)
 		goto init_cpu_err;
 
-	fw.text = text;
-
-	fw.data_addr = bnx2_TXP_b06FwDataAddr;
-	fw.data_len = bnx2_TXP_b06FwDataLen;
-	fw.data_index = 0;
-	fw.data = bnx2_TXP_b06FwData;
-
-	fw.sbss_addr = bnx2_TXP_b06FwSbssAddr;
-	fw.sbss_len = bnx2_TXP_b06FwSbssLen;
-	fw.sbss_index = 0;
-	fw.sbss = bnx2_TXP_b06FwSbss;
-
-	fw.bss_addr = bnx2_TXP_b06FwBssAddr;
-	fw.bss_len = bnx2_TXP_b06FwBssLen;
-	fw.bss_index = 0;
-	fw.bss = bnx2_TXP_b06FwBss;
-
-	fw.rodata_addr = bnx2_TXP_b06FwRodataAddr;
-	fw.rodata_len = bnx2_TXP_b06FwRodataLen;
-	fw.rodata_index = 0;
-	fw.rodata = bnx2_TXP_b06FwRodata;
-
-	load_cpu_fw(bp, &cpu_reg, &fw);
-
 	/* Initialize the TX Patch-up Processor. */
 	cpu_reg.mode = BNX2_TPAT_CPU_MODE;
 	cpu_reg.mode_value_halt = BNX2_TPAT_CPU_MODE_SOFT_HALT;
@@ -2433,44 +2383,12 @@ bnx2_init_cpus(struct bnx2 *bp)
 	cpu_reg.spad_base = BNX2_TPAT_SCRATCH;
 	cpu_reg.mips_view_base = 0x8000000;
 
-	fw.ver_major = bnx2_TPAT_b06FwReleaseMajor;
-	fw.ver_minor = bnx2_TPAT_b06FwReleaseMinor;
-	fw.ver_fix = bnx2_TPAT_b06FwReleaseFix;
-	fw.start_addr = bnx2_TPAT_b06FwStartAddr;
+	fw = &bnx2_tpat_fw_06;
 
-	fw.text_addr = bnx2_TPAT_b06FwTextAddr;
-	fw.text_len = bnx2_TPAT_b06FwTextLen;
-	fw.text_index = 0;
-
-	rc = bnx2_gunzip(bp, bnx2_TPAT_b06FwText, sizeof(bnx2_TPAT_b06FwText),
-			 &text, &text_len);
+	rc = load_cpu_fw(bp, &cpu_reg, fw);
 	if (rc)
 		goto init_cpu_err;
 
-	fw.text = text;
-
-	fw.data_addr = bnx2_TPAT_b06FwDataAddr;
-	fw.data_len = bnx2_TPAT_b06FwDataLen;
-	fw.data_index = 0;
-	fw.data = bnx2_TPAT_b06FwData;
-
-	fw.sbss_addr = bnx2_TPAT_b06FwSbssAddr;
-	fw.sbss_len = bnx2_TPAT_b06FwSbssLen;
-	fw.sbss_index = 0;
-	fw.sbss = bnx2_TPAT_b06FwSbss;
-
-	fw.bss_addr = bnx2_TPAT_b06FwBssAddr;
-	fw.bss_len = bnx2_TPAT_b06FwBssLen;
-	fw.bss_index = 0;
-	fw.bss = bnx2_TPAT_b06FwBss;
-
-	fw.rodata_addr = bnx2_TPAT_b06FwRodataAddr;
-	fw.rodata_len = bnx2_TPAT_b06FwRodataLen;
-	fw.rodata_index = 0;
-	fw.rodata = bnx2_TPAT_b06FwRodata;
-
-	load_cpu_fw(bp, &cpu_reg, &fw);
-
 	/* Initialize the Completion Processor. */
 	cpu_reg.mode = BNX2_COM_CPU_MODE;
 	cpu_reg.mode_value_halt = BNX2_COM_CPU_MODE_SOFT_HALT;
@@ -2485,44 +2403,12 @@ bnx2_init_cpus(struct bnx2 *bp)
 	cpu_reg.spad_base = BNX2_COM_SCRATCH;
 	cpu_reg.mips_view_base = 0x8000000;
 
-	fw.ver_major = bnx2_COM_b06FwReleaseMajor;
-	fw.ver_minor = bnx2_COM_b06FwReleaseMinor;
-	fw.ver_fix = bnx2_COM_b06FwReleaseFix;
-	fw.start_addr = bnx2_COM_b06FwStartAddr;
-
-	fw.text_addr = bnx2_COM_b06FwTextAddr;
-	fw.text_len = bnx2_COM_b06FwTextLen;
-	fw.text_index = 0;
+	fw = &bnx2_com_fw_06;
 
-	rc = bnx2_gunzip(bp, bnx2_COM_b06FwText, sizeof(bnx2_COM_b06FwText),
-			 &text, &text_len);
+	rc = load_cpu_fw(bp, &cpu_reg, fw);
 	if (rc)
 		goto init_cpu_err;
 
-	fw.text = text;
-
-	fw.data_addr = bnx2_COM_b06FwDataAddr;
-	fw.data_len = bnx2_COM_b06FwDataLen;
-	fw.data_index = 0;
-	fw.data = bnx2_COM_b06FwData;
-
-	fw.sbss_addr = bnx2_COM_b06FwSbssAddr;
-	fw.sbss_len = bnx2_COM_b06FwSbssLen;
-	fw.sbss_index = 0;
-	fw.sbss = bnx2_COM_b06FwSbss;
-
-	fw.bss_addr = bnx2_COM_b06FwBssAddr;
-	fw.bss_len = bnx2_COM_b06FwBssLen;
-	fw.bss_index = 0;
-	fw.bss = bnx2_COM_b06FwBss;
-
-	fw.rodata_addr = bnx2_COM_b06FwRodataAddr;
-	fw.rodata_len = bnx2_COM_b06FwRodataLen;
-	fw.rodata_index = 0;
-	fw.rodata = bnx2_COM_b06FwRodata;
-
-	load_cpu_fw(bp, &cpu_reg, &fw);
-
 init_cpu_err:
 	bnx2_gunzip_end(bp);
 	return rc;
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 7fa7008..dc38039 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -4107,41 +4107,43 @@ struct cpu_reg {
 };
 
 struct fw_info {
-	u32 ver_major;
-	u32 ver_minor;
-	u32 ver_fix;
+	const u32 ver_major;
+	const u32 ver_minor;
+	const u32 ver_fix;
 
-	u32 start_addr;
+	const u32 start_addr;
 
 	/* Text section. */
-	u32 text_addr;
-	u32 text_len;
-	u32 text_index;
+	const u32 text_addr;
+	const u32 text_len;
+	const u32 text_index;
 	u32 *text;
+	u8 *gz_text;
+	const u32 gz_text_len;
 
 	/* Data section. */
-	u32 data_addr;
-	u32 data_len;
-	u32 data_index;
-	u32 *data;
+	const u32 data_addr;
+	const u32 data_len;
+	const u32 data_index;
+	const u32 *data;
 
 	/* SBSS section. */
-	u32 sbss_addr;
-	u32 sbss_len;
-	u32 sbss_index;
-	u32 *sbss;
+	const u32 sbss_addr;
+	const u32 sbss_len;
+	const u32 sbss_index;
+	const u32 *sbss;
 
 	/* BSS section. */
-	u32 bss_addr;
-	u32 bss_len;
-	u32 bss_index;
-	u32 *bss;
+	const u32 bss_addr;
+	const u32 bss_len;
+	const u32 bss_index;
+	const u32 *bss;
 
 	/* Read-only section. */
-	u32 rodata_addr;
-	u32 rodata_len;
-	u32 rodata_index;
-	u32 *rodata;
+	const u32 rodata_addr;
+	const u32 rodata_len;
+	const u32 rodata_index;
+	const u32 *rodata;
 };
 
 #define RV2P_PROC1                              0
diff --git a/drivers/net/bnx2_fw.h b/drivers/net/bnx2_fw.h
index 4adc8de..21d368f 100644
--- a/drivers/net/bnx2_fw.h
+++ b/drivers/net/bnx2_fw.h
@@ -14,20 +14,6 @@
  * accompanying it.
  */
 
-static const int bnx2_COM_b06FwReleaseMajor = 0x1;
-static const int bnx2_COM_b06FwReleaseMinor = 0x0;
-static const int bnx2_COM_b06FwReleaseFix = 0x0;
-static const u32 bnx2_COM_b06FwStartAddr = 0x080008b4;
-static const u32 bnx2_COM_b06FwTextAddr = 0x08000000;
-static const int bnx2_COM_b06FwTextLen = 0x57bc;
-static const u32 bnx2_COM_b06FwDataAddr = 0x08005840;
-static const int bnx2_COM_b06FwDataLen = 0x0;
-static const u32 bnx2_COM_b06FwRodataAddr = 0x080057c0;
-static const int bnx2_COM_b06FwRodataLen = 0x58;
-static const u32 bnx2_COM_b06FwBssAddr = 0x08005860;
-static const int bnx2_COM_b06FwBssLen = 0x88;
-static const u32 bnx2_COM_b06FwSbssAddr = 0x08005840;
-static const int bnx2_COM_b06FwSbssLen = 0x1c;
 static u8 bnx2_COM_b06FwText[] = {
 	0x1f, 0x8b, 0x08, 0x08, 0x09, 0x83, 0x41, 0x44, 0x00, 0x03, 0x74, 0x65,
 	0x73, 0x74, 0x31, 0x2e, 0x62, 0x69, 0x6e, 0x00, 0xec, 0x5b, 0x7d, 0x6c,
@@ -673,20 +659,40 @@ static u32 bnx2_COM_b06FwRodata[(0x58/4)
 static u32 bnx2_COM_b06FwBss[(0x88/4) + 1] = { 0x0 };
 static u32 bnx2_COM_b06FwSbss[(0x1c/4) + 1] = { 0x0 };
 
-static const int bnx2_RXP_b06FwReleaseMajor = 0x2;
-static const int bnx2_RXP_b06FwReleaseMinor = 0x8;
-static const int bnx2_RXP_b06FwReleaseFix = 0x17;
-static const u32 bnx2_RXP_b06FwStartAddr = 0x08003184;
-static const u32 bnx2_RXP_b06FwTextAddr = 0x08000000;
-static const int bnx2_RXP_b06FwTextLen = 0x6728;
-static const u32 bnx2_RXP_b06FwDataAddr = 0x080069c0;
-static const int bnx2_RXP_b06FwDataLen = 0x0;
-static const u32 bnx2_RXP_b06FwRodataAddr = 0x08006728;
-static const int bnx2_RXP_b06FwRodataLen = 0x278;
-static const u32 bnx2_RXP_b06FwBssAddr = 0x080069f0;
-static const int bnx2_RXP_b06FwBssLen = 0x13dc;
-static const u32 bnx2_RXP_b06FwSbssAddr = 0x080069c0;
-static const int bnx2_RXP_b06FwSbssLen = 0x2c;
+static struct fw_info bnx2_com_fw_06 = {
+	.ver_major			= 0x1,
+	.ver_minor			= 0x0,
+	.ver_fix			= 0x0,
+
+	.start_addr			= 0x080008b4,
+
+	.text_addr			= 0x08000000,
+	.text_len			= 0x57bc,
+	.text_index			= 0x0,
+	.gz_text			= bnx2_COM_b06FwText,
+	.gz_text_len			= sizeof(bnx2_COM_b06FwText),
+
+	.data_addr			= 0x08005840,
+	.data_len			= 0x0,
+	.data_index			= 0x0,
+	.data				= bnx2_COM_b06FwData,
+
+	.sbss_addr			= 0x08005840,
+	.sbss_len			= 0x1c,
+	.sbss_index			= 0x0,
+	.sbss				= bnx2_COM_b06FwSbss,
+
+	.bss_addr			= 0x08005860,
+	.bss_len			= 0x88,
+	.bss_index			= 0x0,
+	.bss				= bnx2_COM_b06FwBss,
+
+	.rodata_addr			= 0x080057c0,
+	.rodata_len			= 0x58,
+	.rodata_index			= 0x0,
+	.rodata				= bnx2_COM_b06FwRodata,
+};
+
 static u8 bnx2_RXP_b06FwText[] = {
 	0x1f, 0x8b, 0x08, 0x08, 0xcb, 0xa3, 0x46, 0x45, 0x00, 0x03, 0x74, 0x65,
 	0x73, 0x74, 0x31, 0x2e, 0x62, 0x69, 0x6e, 0x00, 0xec, 0x5c, 0x6f, 0x6c,
@@ -1366,6 +1372,40 @@ static u32 bnx2_RXP_b06FwRodata[(0x278/4
 static u32 bnx2_RXP_b06FwBss[(0x13dc/4) + 1] = { 0x0 };
 static u32 bnx2_RXP_b06FwSbss[(0x2c/4) + 1] = { 0x0 };
 
+static struct fw_info bnx2_rxp_fw_06 = {
+	.ver_major			= 0x2,
+	.ver_minor			= 0x8,
+	.ver_fix			= 0x17,
+
+	.start_addr			= 0x08003184,
+
+	.text_addr			= 0x08000000,
+	.text_len			= 0x6728,
+	.text_index			= 0x0,
+	.gz_text			= bnx2_RXP_b06FwText,
+	.gz_text_len			= sizeof(bnx2_RXP_b06FwText),
+
+	.data_addr			= 0x080069c0,
+	.data_len			= 0x0,
+	.data_index			= 0x0,
+	.data				= bnx2_RXP_b06FwData,
+
+	.sbss_addr			= 0x080069c0,
+	.sbss_len			= 0x2c,
+	.sbss_index			= 0x0,
+	.sbss				= bnx2_RXP_b06FwSbss,
+
+	.bss_addr			= 0x080069f0,
+	.bss_len			= 0x13dc,
+	.bss_index			= 0x0,
+	.bss				= bnx2_RXP_b06FwBss,
+
+	.rodata_addr			= 0x08006728,
+	.rodata_len			= 0x278,
+	.rodata_index			= 0x0,
+	.rodata				= bnx2_RXP_b06FwRodata,
+};
+
 static u8 bnx2_rv2p_proc1[] = {
 	0x1f, 0x8b, 0x08, 0x08, 0x5e, 0xd0, 0x41, 0x44, 0x00, 0x03, 0x74, 0x65,
 	0x73, 0x74, 0x31, 0x2e, 0x62, 0x69, 0x6e, 0x00, 0xc5, 0x56, 0xcf, 0x6b,
@@ -1625,20 +1665,6 @@ static u8 bnx2_rv2p_proc2[] = {
 	0x63, 0xd6, 0x11, 0x8f, 0x47, 0xd5, 0x5f, 0x3f, 0x97, 0x8f, 0x31, 0xd8,
 	0x17, 0x00, 0x00, 0x00 };
 
-static const int bnx2_TPAT_b06FwReleaseMajor = 0x1;
-static const int bnx2_TPAT_b06FwReleaseMinor = 0x0;
-static const int bnx2_TPAT_b06FwReleaseFix = 0x0;
-static const u32 bnx2_TPAT_b06FwStartAddr = 0x08000860;
-static const u32 bnx2_TPAT_b06FwTextAddr = 0x08000800;
-static const int bnx2_TPAT_b06FwTextLen = 0x122c;
-static const u32 bnx2_TPAT_b06FwDataAddr = 0x08001a60;
-static const int bnx2_TPAT_b06FwDataLen = 0x0;
-static const u32 bnx2_TPAT_b06FwRodataAddr = 0x00000000;
-static const int bnx2_TPAT_b06FwRodataLen = 0x0;
-static const u32 bnx2_TPAT_b06FwBssAddr = 0x08001aa0;
-static const int bnx2_TPAT_b06FwBssLen = 0x250;
-static const u32 bnx2_TPAT_b06FwSbssAddr = 0x08001a60;
-static const int bnx2_TPAT_b06FwSbssLen = 0x34;
 static u8 bnx2_TPAT_b06FwText[] = {
 	0x1f, 0x8b, 0x08, 0x08, 0x47, 0xd2, 0x41, 0x44, 0x00, 0x03, 0x74, 0x65,
 	0x73, 0x74, 0x31, 0x2e, 0x62, 0x69, 0x6e, 0x00, 0xc5, 0x57, 0x4d, 0x68,
@@ -1838,20 +1864,40 @@ static u32 bnx2_TPAT_b06FwRodata[(0x0/4)
 static u32 bnx2_TPAT_b06FwBss[(0x250/4) + 1] = { 0x0 };
 static u32 bnx2_TPAT_b06FwSbss[(0x34/4) + 1] = { 0x0 };
 
-static const int bnx2_TXP_b06FwReleaseMajor = 0x1;
-static const int bnx2_TXP_b06FwReleaseMinor = 0x0;
-static const int bnx2_TXP_b06FwReleaseFix = 0x0;
-static const u32 bnx2_TXP_b06FwStartAddr = 0x080034b0;
-static const u32 bnx2_TXP_b06FwTextAddr = 0x08000000;
-static const int bnx2_TXP_b06FwTextLen = 0x5748;
-static const u32 bnx2_TXP_b06FwDataAddr = 0x08005760;
-static const int bnx2_TXP_b06FwDataLen = 0x0;
-static const u32 bnx2_TXP_b06FwRodataAddr = 0x00000000;
-static const int bnx2_TXP_b06FwRodataLen = 0x0;
-static const u32 bnx2_TXP_b06FwBssAddr = 0x080057a0;
-static const int bnx2_TXP_b06FwBssLen = 0x1c4;
-static const u32 bnx2_TXP_b06FwSbssAddr = 0x08005760;
-static const int bnx2_TXP_b06FwSbssLen = 0x38;
+static struct fw_info bnx2_tpat_fw_06 = {
+	.ver_major			= 0x1,
+	.ver_minor			= 0x0,
+	.ver_fix			= 0x0,
+
+	.start_addr			= 0x08000860,
+
+	.text_addr			= 0x08000800,
+	.text_len			= 0x122c,
+	.text_index			= 0x0,
+	.gz_text			= bnx2_TPAT_b06FwText,
+	.gz_text_len			= sizeof(bnx2_TPAT_b06FwText),
+
+	.data_addr			= 0x08001a60,
+	.data_len			= 0x0,
+	.data_index			= 0x0,
+	.data				= bnx2_TPAT_b06FwData,
+
+	.sbss_addr			= 0x08001a60,
+	.sbss_len			= 0x34,
+	.sbss_index			= 0x0,
+	.sbss				= bnx2_TPAT_b06FwSbss,
+
+	.bss_addr			= 0x08001aa0,
+	.bss_len			= 0x250,
+	.bss_index			= 0x0,
+	.bss				= bnx2_TPAT_b06FwBss,
+
+	.rodata_addr			= 0x00000000,
+	.rodata_len			= 0x0,
+	.rodata_index			= 0x0,
+	.rodata				= bnx2_TPAT_b06FwRodata,
+};
+
 static u8 bnx2_TXP_b06FwText[] = {
 	0x1f, 0x8b, 0x08, 0x08, 0x21, 0xd3, 0x41, 0x44, 0x00, 0x03, 0x74, 0x65,
 	0x73, 0x74, 0x31, 0x2e, 0x62, 0x69, 0x6e, 0x00, 0xed, 0x5c, 0x6d, 0x6c,
@@ -2273,3 +2319,38 @@ static u32 bnx2_TXP_b06FwData[(0x0/4) +
 static u32 bnx2_TXP_b06FwRodata[(0x0/4) + 1] = { 0x0 };
 static u32 bnx2_TXP_b06FwBss[(0x1c4/4) + 1] = { 0x0 };
 static u32 bnx2_TXP_b06FwSbss[(0x38/4) + 1] = { 0x0 };
+
+static struct fw_info bnx2_txp_fw_06 = {
+	.ver_major			= 0x1,
+	.ver_minor			= 0x0,
+	.ver_fix			= 0x0,
+
+	.start_addr			= 0x080034b0,
+
+	.text_addr			= 0x08000000,
+	.text_len			= 0x5748,
+	.text_index			= 0x0,
+	.gz_text			= bnx2_TXP_b06FwText,
+	.gz_text_len			= sizeof(bnx2_TXP_b06FwText),
+
+	.data_addr			= 0x08005760,
+	.data_len			= 0x0,
+	.data_index			= 0x0,
+	.data				= bnx2_TXP_b06FwData,
+
+	.sbss_addr			= 0x08005760,
+	.sbss_len			= 0x38,
+	.sbss_index			= 0x0,
+	.sbss				= bnx2_TXP_b06FwSbss,
+
+	.bss_addr			= 0x080057a0,
+	.bss_len			= 0x1c4,
+	.bss_index			= 0x0,
+	.bss				= bnx2_TXP_b06FwBss,
+
+	.rodata_addr			= 0x00000000,
+	.rodata_len			= 0x0,
+	.rodata_index			= 0x0,
+	.rodata				= bnx2_TXP_b06FwRodata,
+};
+


