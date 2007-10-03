From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.24 2/3][BNX2]: Optimize firmware loading.
Date: Tue, 02 Oct 2007 17:23:43 -0700
Message-ID: <1191371023.5961.32.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vda.linux@googlemail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4072 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752996AbXJBXY6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 19:24:58 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Optimize firmware loading.

This is a follow up to the patches from Denys Vlasenkos
<vda.linux@googlemail.com> to further optimize firmware loading.

1. In bnx2_init_cpus(), we allocate memory for decompression once
and use it repeatedly instead of doing this for every firmware image.

2. We eliminate the BSS and SBSS firmware sections in bnx2_fw*.h since
these are always zeros.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 4887c31..c50e4c8 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2810,21 +2810,16 @@ load_cpu_fw(struct bnx2 *bp, struct cpu_reg *cpu_reg, struct fw_info *fw)
 	/* Load the Text area. */
 	offset = cpu_reg->spad_base + (fw->text_addr - cpu_reg->mips_view_base);
 	if (fw->gz_text) {
-		u32 *text;
 		int j;
 
-		text = vmalloc(FW_BUF_SIZE);
-		if (!text)
-			return -ENOMEM;
-		rc = zlib_inflate_blob(text, FW_BUF_SIZE, fw->gz_text, fw->gz_text_len);
-		if (rc < 0) {
-			vfree(text);
+		rc = zlib_inflate_blob(fw->text, FW_BUF_SIZE, fw->gz_text,
+				       fw->gz_text_len);
+		if (rc < 0)
 			return rc;
-		}
+
 		for (j = 0; j < (fw->text_len / 4); j++, offset += 4) {
-			REG_WR_IND(bp, offset, cpu_to_le32(text[j]));
+			REG_WR_IND(bp, offset, cpu_to_le32(fw->text[j]));
 	        }
-		vfree(text);
 	}
 
 	/* Load the Data area. */
@@ -2839,21 +2834,21 @@ load_cpu_fw(struct bnx2 *bp, struct cpu_reg *cpu_reg, struct fw_info *fw)
 
 	/* Load the SBSS area. */
 	offset = cpu_reg->spad_base + (fw->sbss_addr - cpu_reg->mips_view_base);
-	if (fw->sbss) {
+	if (fw->sbss_len) {
 		int j;
 
 		for (j = 0; j < (fw->sbss_len / 4); j++, offset += 4) {
-			REG_WR_IND(bp, offset, fw->sbss[j]);
+			REG_WR_IND(bp, offset, 0);
 		}
 	}
 
 	/* Load the BSS area. */
 	offset = cpu_reg->spad_base + (fw->bss_addr - cpu_reg->mips_view_base);
-	if (fw->bss) {
+	if (fw->bss_len) {
 		int j;
 
 		for (j = 0; j < (fw->bss_len/4); j++, offset += 4) {
-			REG_WR_IND(bp, offset, fw->bss[j]);
+			REG_WR_IND(bp, offset, 0);
 		}
 	}
 
@@ -2894,19 +2889,16 @@ bnx2_init_cpus(struct bnx2 *bp)
 	if (!text)
 		return -ENOMEM;
 	rc = zlib_inflate_blob(text, FW_BUF_SIZE, bnx2_rv2p_proc1, sizeof(bnx2_rv2p_proc1));
-	if (rc < 0) {
-		vfree(text);
+	if (rc < 0)
 		goto init_cpu_err;
-	}
+
 	load_rv2p_fw(bp, text, rc /* == len */, RV2P_PROC1);
 
 	rc = zlib_inflate_blob(text, FW_BUF_SIZE, bnx2_rv2p_proc2, sizeof(bnx2_rv2p_proc2));
-	if (rc < 0) {
-		vfree(text);
+	if (rc < 0)
 		goto init_cpu_err;
-	}
+
 	load_rv2p_fw(bp, text, rc /* == len */, RV2P_PROC2);
-	vfree(text);
 
 	/* Initialize the RX Processor. */
 	cpu_reg.mode = BNX2_RXP_CPU_MODE;
@@ -2927,6 +2919,7 @@ bnx2_init_cpus(struct bnx2 *bp)
 	else
 		fw = &bnx2_rxp_fw_06;
 
+	fw->text = text;
 	rc = load_cpu_fw(bp, &cpu_reg, fw);
 	if (rc)
 		goto init_cpu_err;
@@ -2950,6 +2943,7 @@ bnx2_init_cpus(struct bnx2 *bp)
 	else
 		fw = &bnx2_txp_fw_06;
 
+	fw->text = text;
 	rc = load_cpu_fw(bp, &cpu_reg, fw);
 	if (rc)
 		goto init_cpu_err;
@@ -2973,6 +2967,7 @@ bnx2_init_cpus(struct bnx2 *bp)
 	else
 		fw = &bnx2_tpat_fw_06;
 
+	fw->text = text;
 	rc = load_cpu_fw(bp, &cpu_reg, fw);
 	if (rc)
 		goto init_cpu_err;
@@ -2996,6 +2991,7 @@ bnx2_init_cpus(struct bnx2 *bp)
 	else
 		fw = &bnx2_com_fw_06;
 
+	fw->text = text;
 	rc = load_cpu_fw(bp, &cpu_reg, fw);
 	if (rc)
 		goto init_cpu_err;
@@ -3017,11 +3013,13 @@ bnx2_init_cpus(struct bnx2 *bp)
 	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
 		fw = &bnx2_cp_fw_09;
 
+		fw->text = text;
 		rc = load_cpu_fw(bp, &cpu_reg, fw);
 		if (rc)
 			goto init_cpu_err;
 	}
 init_cpu_err:
+	vfree(text);
 	return rc;
 }
 
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index a717459..56c190f 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6738,7 +6738,7 @@ struct fw_info {
 	const u32 text_addr;
 	const u32 text_len;
 	const u32 text_index;
-/*	u32 *text;*/
+	u32 *text;
 	u8 *gz_text;
 	const u32 gz_text_len;
 
@@ -6752,13 +6752,11 @@ struct fw_info {
 	const u32 sbss_addr;
 	const u32 sbss_len;
 	const u32 sbss_index;
-	const u32 *sbss;
 
 	/* BSS section. */
 	const u32 bss_addr;
 	const u32 bss_len;
 	const u32 bss_index;
-	const u32 *bss;
 
 	/* Read-only section. */
 	const u32 rodata_addr;
diff --git a/drivers/net/bnx2_fw.h b/drivers/net/bnx2_fw.h
index 30f2f40..a6d7824 100644
--- a/drivers/net/bnx2_fw.h
+++ b/drivers/net/bnx2_fw.h
@@ -1048,8 +1048,6 @@ static const u32 bnx2_COM_b06FwRodata[(0x88/4) + 1] = {
 	0x08002bd8, 0x08002c08, 0x08002c38, 0x00000000, 0x080060cc, 0x080060cc,
 	0x080060cc, 0x080060cc, 0x080060cc, 0x08006100, 0x08006100, 0x08006140,
 	0x0800614c, 0x0800614c, 0x080060cc, 0x00000000, 0x00000000 };
-static const u32 bnx2_COM_b06FwBss[(0x88/4) + 1] = { 0x0 };
-static const u32 bnx2_COM_b06FwSbss[(0x60/4) + 1] = { 0x0 };
 
 static struct fw_info bnx2_com_fw_06 = {
 	.ver_major			= 0x3,
@@ -1072,12 +1070,10 @@ static struct fw_info bnx2_com_fw_06 = {
 	.sbss_addr			= 0x08007e00,
 	.sbss_len			= 0x60,
 	.sbss_index			= 0x0,
-	.sbss				= bnx2_COM_b06FwSbss,
 
 	.bss_addr			= 0x08007e60,
 	.bss_len			= 0x88,
 	.bss_index			= 0x0,
-	.bss				= bnx2_COM_b06FwBss,
 
 	.rodata_addr			= 0x08007d58,
 	.rodata_len			= 0x88,
@@ -1762,9 +1758,6 @@ static u32 bnx2_RXP_b06FwRodata[(0x278/4) + 1] = {
 	0x08006030, 0x08006030, 0x08006018, 0x08006030, 0x08006030, 0x08006030,
 	0x08006024, 0x00000000, 0x00000000 };
 
-static u32 bnx2_RXP_b06FwBss[(0x13dc/4) + 1] = { 0x0 };
-static u32 bnx2_RXP_b06FwSbss[(0x2c/4) + 1] = { 0x0 };
-
 static struct fw_info bnx2_rxp_fw_06 = {
 	.ver_major			= 0x2,
 	.ver_minor			= 0x8,
@@ -1786,12 +1779,10 @@ static struct fw_info bnx2_rxp_fw_06 = {
 	.sbss_addr			= 0x080069c0,
 	.sbss_len			= 0x2c,
 	.sbss_index			= 0x0,
-	.sbss				= bnx2_RXP_b06FwSbss,
 
 	.bss_addr			= 0x080069f0,
 	.bss_len			= 0x13dc,
 	.bss_index			= 0x0,
-	.bss				= bnx2_RXP_b06FwBss,
 
 	.rodata_addr			= 0x08006728,
 	.rodata_len			= 0x278,
@@ -2257,8 +2248,6 @@ static u8 bnx2_TPAT_b06FwText[] = {
 
 static u32 bnx2_TPAT_b06FwData[(0x0/4) + 1] = { 0x0 };
 static u32 bnx2_TPAT_b06FwRodata[(0x0/4) + 1] = { 0x0 };
-static u32 bnx2_TPAT_b06FwBss[(0x250/4) + 1] = { 0x0 };
-static u32 bnx2_TPAT_b06FwSbss[(0x34/4) + 1] = { 0x0 };
 
 static struct fw_info bnx2_tpat_fw_06 = {
 	.ver_major			= 0x1,
@@ -2281,12 +2270,10 @@ static struct fw_info bnx2_tpat_fw_06 = {
 	.sbss_addr			= 0x08001a60,
 	.sbss_len			= 0x34,
 	.sbss_index			= 0x0,
-	.sbss				= bnx2_TPAT_b06FwSbss,
 
 	.bss_addr			= 0x08001aa0,
 	.bss_len			= 0x250,
 	.bss_index			= 0x0,
-	.bss				= bnx2_TPAT_b06FwBss,
 
 	.rodata_addr			= 0x00000000,
 	.rodata_len			= 0x0,
@@ -2714,8 +2701,6 @@ static u8 bnx2_TXP_b06FwText[] = {
 
 static u32 bnx2_TXP_b06FwData[(0x0/4) + 1] = { 0x0 };
 static u32 bnx2_TXP_b06FwRodata[(0x0/4) + 1] = { 0x0 };
-static u32 bnx2_TXP_b06FwBss[(0x1c4/4) + 1] = { 0x0 };
-static u32 bnx2_TXP_b06FwSbss[(0x38/4) + 1] = { 0x0 };
 
 static struct fw_info bnx2_txp_fw_06 = {
 	.ver_major			= 0x1,
@@ -2738,12 +2723,10 @@ static struct fw_info bnx2_txp_fw_06 = {
 	.sbss_addr			= 0x08005760,
 	.sbss_len			= 0x38,
 	.sbss_index			= 0x0,
-	.sbss				= bnx2_TXP_b06FwSbss,
 
 	.bss_addr			= 0x080057a0,
 	.bss_len			= 0x1c4,
 	.bss_index			= 0x0,
-	.bss				= bnx2_TXP_b06FwBss,
 
 	.rodata_addr			= 0x00000000,
 	.rodata_len			= 0x0,
diff --git a/drivers/net/bnx2_fw2.h b/drivers/net/bnx2_fw2.h
index 74f985d..5bd52be 100644
--- a/drivers/net/bnx2_fw2.h
+++ b/drivers/net/bnx2_fw2.h
@@ -1046,8 +1046,6 @@ static const u32 bnx2_COM_b09FwRodata[(0x88/4) + 1] = {
 	0x08002b3c, 0x08002b6c, 0x08002b9c, 0x00000000, 0x0800604c, 0x0800604c,
 	0x0800604c, 0x0800604c, 0x0800604c, 0x08006078, 0x08006078, 0x080060b8,
 	0x080060c4, 0x080060c4, 0x0800604c, 0x00000000, 0x00000000 };
-static const u32 bnx2_COM_b09FwBss[(0x88/4) + 1] = { 0x0 };
-static const u32 bnx2_COM_b09FwSbss[(0x60/4) + 1] = { 0x0 };
 
 static struct fw_info bnx2_com_fw_09 = {
 	.ver_major			= 0x3,
@@ -1070,12 +1068,10 @@ static struct fw_info bnx2_com_fw_09 = {
 	.sbss_addr			= 0x08007e60,
 	.sbss_len			= 0x60,
 	.sbss_index			= 0x0,
-	.sbss				= bnx2_COM_b09FwSbss,
 
 	.bss_addr			= 0x08007ec0,
 	.bss_len			= 0x88,
 	.bss_index			= 0x0,
-	.bss				= bnx2_COM_b09FwBss,
 
 	.rodata_addr			= 0x08007dc0,
 	.rodata_len			= 0x88,
@@ -2243,8 +2239,6 @@ static const u32 bnx2_CP_b09FwRodata[(0x118/4) + 1] = {
 	0x080032e8, 0x08003300, 0x08003320, 0x08003358, 0x08003338, 0x08003338,
 	0x080050d4, 0x080050d4, 0x080050d4, 0x080050d4, 0x080050d4, 0x080050fc,
 	0x080050fc, 0x08005124, 0x08005174, 0x08005144, 0x00000000 };
-static const u32 bnx2_CP_b09FwBss[(0x3b0/4) + 1] = { 0x0 };
-static const u32 bnx2_CP_b09FwSbss[(0xa1/4) + 1] = { 0x0 };
 
 static struct fw_info bnx2_cp_fw_09 = {
 	.ver_major			= 0x3,
@@ -2267,12 +2261,10 @@ static struct fw_info bnx2_cp_fw_09 = {
 	.sbss_addr			= 0x08007024,
 	.sbss_len			= 0xa1,
 	.sbss_index			= 0x0,
-	.sbss				= bnx2_CP_b09FwSbss,
 
 	.bss_addr			= 0x080070d0,
 	.bss_len			= 0x3b0,
 	.bss_index			= 0x0,
-	.bss				= bnx2_CP_b09FwBss,
 
 	.rodata_addr			= 0x08006ee8,
 	.rodata_len			= 0x118,
@@ -2953,8 +2945,6 @@ static const u32 bnx2_RXP_b09FwRodata[(0x278/4) + 1] = {
 	0x08006058, 0x08006070, 0x08006070, 0x08006070, 0x08006058, 0x08006070,
 	0x08006070, 0x08006070, 0x08006058, 0x08006070, 0x08006070, 0x08006070,
 	0x08006064, 0x00000000, 0x00000000 };
-static const u32 bnx2_RXP_b09FwBss[(0x13dc/4) + 1] = { 0x0 };
-static const u32 bnx2_RXP_b09FwSbss[(0x20/4) + 1] = { 0x0 };
 
 static struct fw_info bnx2_rxp_fw_09 = {
 	.ver_major			= 0x3,
@@ -2977,12 +2967,10 @@ static struct fw_info bnx2_rxp_fw_09 = {
 	.sbss_addr			= 0x08006a00,
 	.sbss_len			= 0x20,
 	.sbss_index			= 0x0,
-	.sbss				= bnx2_RXP_b09FwSbss,
 
 	.bss_addr			= 0x08006a20,
 	.bss_len			= 0x13dc,
 	.bss_index			= 0x0,
-	.bss				= bnx2_RXP_b09FwBss,
 
 	.rodata_addr			= 0x08006768,
 	.rodata_len			= 0x278,
@@ -3245,8 +3233,6 @@ static u8 bnx2_TPAT_b09FwText[] = {
 
 static const u32 bnx2_TPAT_b09FwData[(0x0/4) + 1] = { 0x0 };
 static const u32 bnx2_TPAT_b09FwRodata[(0x0/4) + 1] = { 0x0 };
-static const u32 bnx2_TPAT_b09FwBss[(0x850/4) + 1] = { 0x0 };
-static const u32 bnx2_TPAT_b09FwSbss[(0x2c/4) + 1] = { 0x0 };
 
 static struct fw_info bnx2_tpat_fw_09 = {
 	.ver_major			= 0x3,
@@ -3269,12 +3255,10 @@ static struct fw_info bnx2_tpat_fw_09 = {
 	.sbss_addr			= 0x08002088,
 	.sbss_len			= 0x2c,
 	.sbss_index			= 0x0,
-	.sbss				= bnx2_TPAT_b09FwSbss,
 
 	.bss_addr			= 0x080020c0,
 	.bss_len			= 0x850,
 	.bss_index			= 0x0,
-	.bss				= bnx2_TPAT_b09FwBss,
 
 	.rodata_addr			= 0x00000000,
 	.rodata_len			= 0x0,
@@ -4060,8 +4044,6 @@ static const u32 bnx2_TXP_b09FwRodata[(0x30/4) + 1] = {
 	0x08004060, 0x0800408c, 0x080040d4, 0x080040d4, 0x08003f60, 0x08003f8c,
 	0x08003f8c, 0x080040d4, 0x080040d4, 0x080040d4, 0x08003ff4, 0x00000000,
 	0x00000000 };
-static const u32 bnx2_TXP_b09FwBss[(0xa20/4) + 1] = { 0x0 };
-static const u32 bnx2_TXP_b09FwSbss[(0x8c/4) + 1] = { 0x0 };
 
 static struct fw_info bnx2_txp_fw_09 = {
 	.ver_major			= 0x3,
@@ -4084,12 +4066,10 @@ static struct fw_info bnx2_txp_fw_09 = {
 	.sbss_addr			= 0x08004750,
 	.sbss_len			= 0x8c,
 	.sbss_index			= 0x0,
-	.sbss				= bnx2_TXP_b09FwSbss,
 
 	.bss_addr			= 0x080047e0,
 	.bss_len			= 0xa20,
 	.bss_index			= 0x0,
-	.bss				= bnx2_TXP_b09FwBss,
 
 	.rodata_addr			= 0x08004638,
 	.rodata_len			= 0x30,


