From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 5/6] [BNX2]: Pre-initialize struct cpu_reg.
Date: Fri, 16 May 2008 14:30:48 -0700
Message-ID: <1210973448.5507.21.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, benli@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4225 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760672AbYEPU0B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2008 16:26:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Pre-initialize struct cpu_reg.

Instead of assigning values for the struct cpu_reg's at runtime,
we already know these values at compile time.  Therefore, we can use
designated initializers, to initialize these structures and not have
to incur this assignment cost at run-time.

Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c    |   78 ++++--------------------------------------------
 drivers/net/bnx2_fw.h |   80 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 86 insertions(+), 72 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 1534eed..e1787a1 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3219,7 +3219,7 @@ load_rv2p_fw(struct bnx2 *bp, __le32 *rv2p_code, u32 rv2p_code_len,
 }
 
 static int
-load_cpu_fw(struct bnx2 *bp, struct cpu_reg *cpu_reg, struct fw_info *fw)
+load_cpu_fw(struct bnx2 *bp, const struct cpu_reg *cpu_reg, struct fw_info *fw)
 {
 	u32 offset;
 	u32 val;
@@ -3303,7 +3303,6 @@ load_cpu_fw(struct bnx2 *bp, struct cpu_reg *cpu_reg, struct fw_info *fw)
 static int
 bnx2_init_cpus(struct bnx2 *bp)
 {
-	struct cpu_reg cpu_reg;
 	struct fw_info *fw;
 	int rc, rv2p_len;
 	void *text, *rv2p;
@@ -3339,122 +3338,57 @@ bnx2_init_cpus(struct bnx2 *bp)
 	load_rv2p_fw(bp, text, rc /* == len */, RV2P_PROC2);
 
 	/* Initialize the RX Processor. */
-	cpu_reg.mode = BNX2_RXP_CPU_MODE;
-	cpu_reg.mode_value_halt = BNX2_RXP_CPU_MODE_SOFT_HALT;
-	cpu_reg.mode_value_sstep = BNX2_RXP_CPU_MODE_STEP_ENA;
-	cpu_reg.state = BNX2_RXP_CPU_STATE;
-	cpu_reg.state_value_clear = 0xffffff;
-	cpu_reg.gpr0 = BNX2_RXP_CPU_REG_FILE;
-	cpu_reg.evmask = BNX2_RXP_CPU_EVENT_MASK;
-	cpu_reg.pc = BNX2_RXP_CPU_PROGRAM_COUNTER;
-	cpu_reg.inst = BNX2_RXP_CPU_INSTRUCTION;
-	cpu_reg.bp = BNX2_RXP_CPU_HW_BREAKPOINT;
-	cpu_reg.spad_base = BNX2_RXP_SCRATCH;
-	cpu_reg.mips_view_base = 0x8000000;
-
 	if (CHIP_NUM(bp) == CHIP_NUM_5709)
 		fw = &bnx2_rxp_fw_09;
 	else
 		fw = &bnx2_rxp_fw_06;
 
 	fw->text = text;
-	rc = load_cpu_fw(bp, &cpu_reg, fw);
+	rc = load_cpu_fw(bp, &cpu_reg_rxp, fw);
 	if (rc)
 		goto init_cpu_err;
 
 	/* Initialize the TX Processor. */
-	cpu_reg.mode = BNX2_TXP_CPU_MODE;
-	cpu_reg.mode_value_halt = BNX2_TXP_CPU_MODE_SOFT_HALT;
-	cpu_reg.mode_value_sstep = BNX2_TXP_CPU_MODE_STEP_ENA;
-	cpu_reg.state = BNX2_TXP_CPU_STATE;
-	cpu_reg.state_value_clear = 0xffffff;
-	cpu_reg.gpr0 = BNX2_TXP_CPU_REG_FILE;
-	cpu_reg.evmask = BNX2_TXP_CPU_EVENT_MASK;
-	cpu_reg.pc = BNX2_TXP_CPU_PROGRAM_COUNTER;
-	cpu_reg.inst = BNX2_TXP_CPU_INSTRUCTION;
-	cpu_reg.bp = BNX2_TXP_CPU_HW_BREAKPOINT;
-	cpu_reg.spad_base = BNX2_TXP_SCRATCH;
-	cpu_reg.mips_view_base = 0x8000000;
-
 	if (CHIP_NUM(bp) == CHIP_NUM_5709)
 		fw = &bnx2_txp_fw_09;
 	else
 		fw = &bnx2_txp_fw_06;
 
 	fw->text = text;
-	rc = load_cpu_fw(bp, &cpu_reg, fw);
+	rc = load_cpu_fw(bp, &cpu_reg_txp, fw);
 	if (rc)
 		goto init_cpu_err;
 
 	/* Initialize the TX Patch-up Processor. */
-	cpu_reg.mode = BNX2_TPAT_CPU_MODE;
-	cpu_reg.mode_value_halt = BNX2_TPAT_CPU_MODE_SOFT_HALT;
-	cpu_reg.mode_value_sstep = BNX2_TPAT_CPU_MODE_STEP_ENA;
-	cpu_reg.state = BNX2_TPAT_CPU_STATE;
-	cpu_reg.state_value_clear = 0xffffff;
-	cpu_reg.gpr0 = BNX2_TPAT_CPU_REG_FILE;
-	cpu_reg.evmask = BNX2_TPAT_CPU_EVENT_MASK;
-	cpu_reg.pc = BNX2_TPAT_CPU_PROGRAM_COUNTER;
-	cpu_reg.inst = BNX2_TPAT_CPU_INSTRUCTION;
-	cpu_reg.bp = BNX2_TPAT_CPU_HW_BREAKPOINT;
-	cpu_reg.spad_base = BNX2_TPAT_SCRATCH;
-	cpu_reg.mips_view_base = 0x8000000;
-
 	if (CHIP_NUM(bp) == CHIP_NUM_5709)
 		fw = &bnx2_tpat_fw_09;
 	else
 		fw = &bnx2_tpat_fw_06;
 
 	fw->text = text;
-	rc = load_cpu_fw(bp, &cpu_reg, fw);
+	rc = load_cpu_fw(bp, &cpu_reg_tpat, fw);
 	if (rc)
 		goto init_cpu_err;
 
 	/* Initialize the Completion Processor. */
-	cpu_reg.mode = BNX2_COM_CPU_MODE;
-	cpu_reg.mode_value_halt = BNX2_COM_CPU_MODE_SOFT_HALT;
-	cpu_reg.mode_value_sstep = BNX2_COM_CPU_MODE_STEP_ENA;
-	cpu_reg.state = BNX2_COM_CPU_STATE;
-	cpu_reg.state_value_clear = 0xffffff;
-	cpu_reg.gpr0 = BNX2_COM_CPU_REG_FILE;
-	cpu_reg.evmask = BNX2_COM_CPU_EVENT_MASK;
-	cpu_reg.pc = BNX2_COM_CPU_PROGRAM_COUNTER;
-	cpu_reg.inst = BNX2_COM_CPU_INSTRUCTION;
-	cpu_reg.bp = BNX2_COM_CPU_HW_BREAKPOINT;
-	cpu_reg.spad_base = BNX2_COM_SCRATCH;
-	cpu_reg.mips_view_base = 0x8000000;
-
 	if (CHIP_NUM(bp) == CHIP_NUM_5709)
 		fw = &bnx2_com_fw_09;
 	else
 		fw = &bnx2_com_fw_06;
 
 	fw->text = text;
-	rc = load_cpu_fw(bp, &cpu_reg, fw);
+	rc = load_cpu_fw(bp, &cpu_reg_com, fw);
 	if (rc)
 		goto init_cpu_err;
 
 	/* Initialize the Command Processor. */
-	cpu_reg.mode = BNX2_CP_CPU_MODE;
-	cpu_reg.mode_value_halt = BNX2_CP_CPU_MODE_SOFT_HALT;
-	cpu_reg.mode_value_sstep = BNX2_CP_CPU_MODE_STEP_ENA;
-	cpu_reg.state = BNX2_CP_CPU_STATE;
-	cpu_reg.state_value_clear = 0xffffff;
-	cpu_reg.gpr0 = BNX2_CP_CPU_REG_FILE;
-	cpu_reg.evmask = BNX2_CP_CPU_EVENT_MASK;
-	cpu_reg.pc = BNX2_CP_CPU_PROGRAM_COUNTER;
-	cpu_reg.inst = BNX2_CP_CPU_INSTRUCTION;
-	cpu_reg.bp = BNX2_CP_CPU_HW_BREAKPOINT;
-	cpu_reg.spad_base = BNX2_CP_SCRATCH;
-	cpu_reg.mips_view_base = 0x8000000;
-
 	if (CHIP_NUM(bp) == CHIP_NUM_5709)
 		fw = &bnx2_cp_fw_09;
 	else
 		fw = &bnx2_cp_fw_06;
 
 	fw->text = text;
-	rc = load_cpu_fw(bp, &cpu_reg, fw);
+	rc = load_cpu_fw(bp, &cpu_reg_cp, fw);
 
 init_cpu_err:
 	vfree(text);
diff --git a/drivers/net/bnx2_fw.h b/drivers/net/bnx2_fw.h
index 3b839d4..e4b1de4 100644
--- a/drivers/net/bnx2_fw.h
+++ b/drivers/net/bnx2_fw.h
@@ -886,6 +886,23 @@ static struct fw_info bnx2_com_fw_06 = {
 	.rodata				= bnx2_COM_b06FwRodata,
 };
 
+/* Initialized Values for the Completion Processor. */
+static const struct cpu_reg cpu_reg_com = {
+	.mode = BNX2_COM_CPU_MODE,
+	.mode_value_halt = BNX2_COM_CPU_MODE_SOFT_HALT,
+	.mode_value_sstep = BNX2_COM_CPU_MODE_STEP_ENA,
+	.state = BNX2_COM_CPU_STATE,
+	.state_value_clear = 0xffffff,
+	.gpr0 = BNX2_COM_CPU_REG_FILE,
+	.evmask = BNX2_COM_CPU_EVENT_MASK,
+	.pc = BNX2_COM_CPU_PROGRAM_COUNTER,
+	.inst = BNX2_COM_CPU_INSTRUCTION,
+	.bp = BNX2_COM_CPU_HW_BREAKPOINT,
+	.spad_base = BNX2_COM_SCRATCH,
+	.mips_view_base = 0x8000000,
+};
+
+
 static u8 bnx2_CP_b06FwText[] = {
 	0x9d, 0xbc, 0x0d, 0x78, 0x13, 0xe7, 0x99, 0x2e, 0x7c, 0xcf, 0x48, 0xb2,
 	0x65, 0x5b, 0xb6, 0xc7, 0xb6, 0x0c, 0x22, 0x65, 0x41, 0x83, 0x47, 0x20,
@@ -2167,6 +2184,22 @@ static struct fw_info bnx2_cp_fw_06 = {
 	.rodata				= bnx2_CP_b06FwRodata,
 };
 
+/* Initialized Values the Command Processor. */
+static const struct cpu_reg cpu_reg_cp = {
+	.mode = BNX2_CP_CPU_MODE,
+	.mode_value_halt = BNX2_CP_CPU_MODE_SOFT_HALT,
+	.mode_value_sstep = BNX2_CP_CPU_MODE_STEP_ENA,
+	.state = BNX2_CP_CPU_STATE,
+	.state_value_clear = 0xffffff,
+	.gpr0 = BNX2_CP_CPU_REG_FILE,
+	.evmask = BNX2_CP_CPU_EVENT_MASK,
+	.pc = BNX2_CP_CPU_PROGRAM_COUNTER,
+	.inst = BNX2_CP_CPU_INSTRUCTION,
+	.bp = BNX2_CP_CPU_HW_BREAKPOINT,
+	.spad_base = BNX2_CP_SCRATCH,
+	.mips_view_base = 0x8000000,
+};
+
 static u8 bnx2_RXP_b06FwText[] = {
 	0xec, 0x5b, 0x5d, 0x70, 0x5c, 0xd7, 0x5d, 0xff, 0xdf, 0xb3, 0x2b, 0x69,
 	0x2d, 0x4b, 0xf2, 0x95, 0xbc, 0x71, 0x56, 0xa9, 0x92, 0xec, 0x5a, 0x57,
@@ -2946,6 +2979,22 @@ static struct fw_info bnx2_rxp_fw_06 = {
 	.rodata				= bnx2_RXP_b06FwRodata,
 };
 
+/* Initialized Values for the RX Processor. */
+static const struct cpu_reg cpu_reg_rxp = {
+	.mode = BNX2_RXP_CPU_MODE,
+	.mode_value_halt = BNX2_RXP_CPU_MODE_SOFT_HALT,
+	.mode_value_sstep = BNX2_RXP_CPU_MODE_STEP_ENA,
+	.state = BNX2_RXP_CPU_STATE,
+	.state_value_clear = 0xffffff,
+	.gpr0 = BNX2_RXP_CPU_REG_FILE,
+	.evmask = BNX2_RXP_CPU_EVENT_MASK,
+	.pc = BNX2_RXP_CPU_PROGRAM_COUNTER,
+	.inst = BNX2_RXP_CPU_INSTRUCTION,
+	.bp = BNX2_RXP_CPU_HW_BREAKPOINT,
+	.spad_base = BNX2_RXP_SCRATCH,
+	.mips_view_base = 0x8000000,
+};
+
 static u8 bnx2_rv2p_proc1[] = {
 	/* Date:        12/07/2007 15:02 */
 	0xd5, 0x56, 0x41, 0x6b, 0x13, 0x51, 0x10, 0x9e, 0xdd, 0x6c, 0xbb, 0xdb,
@@ -3651,6 +3700,22 @@ static struct fw_info bnx2_tpat_fw_06 = {
 	.rodata				= bnx2_TPAT_b06FwRodata,
 };
 
+/* Initialized Values for the TX Patch-up Processor. */
+static const struct cpu_reg cpu_reg_tpat = {
+	.mode = BNX2_TPAT_CPU_MODE,
+	.mode_value_halt = BNX2_TPAT_CPU_MODE_SOFT_HALT,
+	.mode_value_sstep = BNX2_TPAT_CPU_MODE_STEP_ENA,
+	.state = BNX2_TPAT_CPU_STATE,
+	.state_value_clear = 0xffffff,
+	.gpr0 = BNX2_TPAT_CPU_REG_FILE,
+	.evmask = BNX2_TPAT_CPU_EVENT_MASK,
+	.pc = BNX2_TPAT_CPU_PROGRAM_COUNTER,
+	.inst = BNX2_TPAT_CPU_INSTRUCTION,
+	.bp = BNX2_TPAT_CPU_HW_BREAKPOINT,
+	.spad_base = BNX2_TPAT_SCRATCH,
+	.mips_view_base = 0x8000000,
+};
+
 static u8 bnx2_TXP_b06FwText[] = {
 	0xad, 0x7b, 0x7f, 0x70, 0x9b, 0x75, 0x7a, 0xe7, 0xe7, 0xd5, 0x0f, 0x5b,
 	0xb2, 0x65, 0x59, 0x0e, 0x4a, 0x90, 0x77, 0xbd, 0x8d, 0x5e, 0xf4, 0xca,
@@ -4531,3 +4596,18 @@ static struct fw_info bnx2_txp_fw_06 = {
 	.rodata				= bnx2_TXP_b06FwRodata,
 };
 
+/* Initialized Values for the TX Processor. */
+static const struct cpu_reg cpu_reg_txp = {
+	.mode = BNX2_TXP_CPU_MODE,
+	.mode_value_halt = BNX2_TXP_CPU_MODE_SOFT_HALT,
+	.mode_value_sstep = BNX2_TXP_CPU_MODE_STEP_ENA,
+	.state = BNX2_TXP_CPU_STATE,
+	.state_value_clear = 0xffffff,
+	.gpr0 = BNX2_TXP_CPU_REG_FILE,
+	.evmask = BNX2_TXP_CPU_EVENT_MASK,
+	.pc = BNX2_TXP_CPU_PROGRAM_COUNTER,
+	.inst = BNX2_TXP_CPU_INSTRUCTION,
+	.bp = BNX2_TXP_CPU_HW_BREAKPOINT,
+	.spad_base = BNX2_TXP_SCRATCH,
+	.mips_view_base = 0x8000000,
+};
-- 
1.5.5.GIT



