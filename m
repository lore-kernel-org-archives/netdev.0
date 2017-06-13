From: David Daney <david.daney@cavium.com>
Subject: [PATCH v2 1/5] MIPS: Optimize uasm insn lookup.
Date: Tue, 13 Jun 2017 15:28:43 -0700
Message-ID: <20170613222847.7122-2-david.daney@cavium.com>
References: <20170613222847.7122-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Markos Chandras <markos.chandras@imgtec.com>,
        Matt Redfearn <matt.redfearn@imgtec.com>,
        David Daney <david.daney@cavium.com>
To: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        ralf@linux-mips.org
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <20170613222847.7122-1-david.daney@cavium.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

Instead of doing a linear search through the insn_table for each
instruction, use the opcode as direct index into the table.  This will
give constant time lookup performance as the number of supported
opcodes increases.  Make the tables const as they are only ever read.
For uasm-mips.c sort the table alphabetically, and remove duplicate
entries, uasm-micromips.c was already sorted and duplicate free.
There is a small savings in object size as struct insn loses a field:

$ size arch/mips/mm/uasm-mips.o arch/mips/mm/uasm-mips.o.save
   text	   data	    bss	    dec	    hex	filename
  10040	      0	      0	  10040	   2738	arch/mips/mm/uasm-mips.o
   9240	   1120	      0	  10360	   2878	arch/mips/mm/uasm-mips.o.save

Signed-off-by: David Daney <david.daney@cavium.com>
---
 arch/mips/mm/uasm-micromips.c | 188 ++++++++++++++++++------------------
 arch/mips/mm/uasm-mips.c      | 217 +++++++++++++++++++++---------------------
 arch/mips/mm/uasm.c           |   3 +-
 3 files changed, 199 insertions(+), 209 deletions(-)

diff --git a/arch/mips/mm/uasm-micromips.c b/arch/mips/mm/uasm-micromips.c
index 277cf52..c28ff53 100644
--- a/arch/mips/mm/uasm-micromips.c
+++ b/arch/mips/mm/uasm-micromips.c
@@ -40,93 +40,92 @@
 
 #include "uasm.c"
 
-static struct insn insn_table_MM[] = {
-	{ insn_addu, M(mm_pool32a_op, 0, 0, 0, 0, mm_addu32_op), RT | RS | RD },
-	{ insn_addiu, M(mm_addiu32_op, 0, 0, 0, 0, 0), RT | RS | SIMM },
-	{ insn_and, M(mm_pool32a_op, 0, 0, 0, 0, mm_and_op), RT | RS | RD },
-	{ insn_andi, M(mm_andi32_op, 0, 0, 0, 0, 0), RT | RS | UIMM },
-	{ insn_beq, M(mm_beq32_op, 0, 0, 0, 0, 0), RS | RT | BIMM },
-	{ insn_beql, 0, 0 },
-	{ insn_bgez, M(mm_pool32i_op, mm_bgez_op, 0, 0, 0, 0), RS | BIMM },
-	{ insn_bgezl, 0, 0 },
-	{ insn_bltz, M(mm_pool32i_op, mm_bltz_op, 0, 0, 0, 0), RS | BIMM },
-	{ insn_bltzl, 0, 0 },
-	{ insn_bne, M(mm_bne32_op, 0, 0, 0, 0, 0), RT | RS | BIMM },
-	{ insn_cache, M(mm_pool32b_op, 0, 0, mm_cache_func, 0, 0), RT | RS | SIMM },
-	{ insn_cfc1, M(mm_pool32f_op, 0, 0, 0, mm_cfc1_op, mm_32f_73_op), RT | RS },
-	{ insn_cfcmsa, M(mm_pool32s_op, 0, msa_cfc_op, 0, 0, mm_32s_elm_op), RD | RE },
-	{ insn_ctc1, M(mm_pool32f_op, 0, 0, 0, mm_ctc1_op, mm_32f_73_op), RT | RS },
-	{ insn_ctcmsa, M(mm_pool32s_op, 0, msa_ctc_op, 0, 0, mm_32s_elm_op), RD | RE },
-	{ insn_daddu, 0, 0 },
-	{ insn_daddiu, 0, 0 },
-	{ insn_di, M(mm_pool32a_op, 0, 0, 0, mm_di_op, mm_pool32axf_op), RS },
-	{ insn_divu, M(mm_pool32a_op, 0, 0, 0, mm_divu_op, mm_pool32axf_op), RT | RS },
-	{ insn_dmfc0, 0, 0 },
-	{ insn_dmtc0, 0, 0 },
-	{ insn_dsll, 0, 0 },
-	{ insn_dsll32, 0, 0 },
-	{ insn_dsra, 0, 0 },
-	{ insn_dsrl, 0, 0 },
-	{ insn_dsrl32, 0, 0 },
-	{ insn_drotr, 0, 0 },
-	{ insn_drotr32, 0, 0 },
-	{ insn_dsubu, 0, 0 },
-	{ insn_eret, M(mm_pool32a_op, 0, 0, 0, mm_eret_op, mm_pool32axf_op), 0 },
-	{ insn_ins, M(mm_pool32a_op, 0, 0, 0, 0, mm_ins_op), RT | RS | RD | RE },
-	{ insn_ext, M(mm_pool32a_op, 0, 0, 0, 0, mm_ext_op), RT | RS | RD | RE },
-	{ insn_j, M(mm_j32_op, 0, 0, 0, 0, 0), JIMM },
-	{ insn_jal, M(mm_jal32_op, 0, 0, 0, 0, 0), JIMM },
-	{ insn_jalr, M(mm_pool32a_op, 0, 0, 0, mm_jalr_op, mm_pool32axf_op), RT | RS },
-	{ insn_jr, M(mm_pool32a_op, 0, 0, 0, mm_jalr_op, mm_pool32axf_op), RS },
-	{ insn_lb, M(mm_lb32_op, 0, 0, 0, 0, 0), RT | RS | SIMM },
-	{ insn_ld, 0, 0 },
-	{ insn_lh, M(mm_lh32_op, 0, 0, 0, 0, 0), RS | RS | SIMM },
-	{ insn_ll, M(mm_pool32c_op, 0, 0, (mm_ll_func << 1), 0, 0), RS | RT | SIMM },
-	{ insn_lld, 0, 0 },
-	{ insn_lui, M(mm_pool32i_op, mm_lui_op, 0, 0, 0, 0), RS | SIMM },
-	{ insn_lw, M(mm_lw32_op, 0, 0, 0, 0, 0), RT | RS | SIMM },
-	{ insn_mfc0, M(mm_pool32a_op, 0, 0, 0, mm_mfc0_op, mm_pool32axf_op), RT | RS | RD },
-	{ insn_mfhi, M(mm_pool32a_op, 0, 0, 0, mm_mfhi32_op, mm_pool32axf_op), RS },
-	{ insn_mflo, M(mm_pool32a_op, 0, 0, 0, mm_mflo32_op, mm_pool32axf_op), RS },
-	{ insn_mtc0, M(mm_pool32a_op, 0, 0, 0, mm_mtc0_op, mm_pool32axf_op), RT | RS | RD },
-	{ insn_mthi, M(mm_pool32a_op, 0, 0, 0, mm_mthi32_op, mm_pool32axf_op), RS },
-	{ insn_mtlo, M(mm_pool32a_op, 0, 0, 0, mm_mtlo32_op, mm_pool32axf_op), RS },
-	{ insn_mul, M(mm_pool32a_op, 0, 0, 0, 0, mm_mul_op), RT | RS | RD },
-	{ insn_or, M(mm_pool32a_op, 0, 0, 0, 0, mm_or32_op), RT | RS | RD },
-	{ insn_ori, M(mm_ori32_op, 0, 0, 0, 0, 0), RT | RS | UIMM },
-	{ insn_pref, M(mm_pool32c_op, 0, 0, (mm_pref_func << 1), 0, 0), RT | RS | SIMM },
-	{ insn_rfe, 0, 0 },
-	{ insn_sc, M(mm_pool32c_op, 0, 0, (mm_sc_func << 1), 0, 0), RT | RS | SIMM },
-	{ insn_scd, 0, 0 },
-	{ insn_sd, 0, 0 },
-	{ insn_sll, M(mm_pool32a_op, 0, 0, 0, 0, mm_sll32_op), RT | RS | RD },
-	{ insn_sllv, M(mm_pool32a_op, 0, 0, 0, 0, mm_sllv32_op), RT | RS | RD },
-	{ insn_slt, M(mm_pool32a_op, 0, 0, 0, 0, mm_slt_op), RT | RS | RD },
-	{ insn_sltiu, M(mm_sltiu32_op, 0, 0, 0, 0, 0), RT | RS | SIMM },
-	{ insn_sltu, M(mm_pool32a_op, 0, 0, 0, 0, mm_sltu_op), RT | RS | RD },
-	{ insn_sra, M(mm_pool32a_op, 0, 0, 0, 0, mm_sra_op), RT | RS | RD },
-	{ insn_srl, M(mm_pool32a_op, 0, 0, 0, 0, mm_srl32_op), RT | RS | RD },
-	{ insn_srlv, M(mm_pool32a_op, 0, 0, 0, 0, mm_srlv32_op), RT | RS | RD },
-	{ insn_rotr, M(mm_pool32a_op, 0, 0, 0, 0, mm_rotr_op), RT | RS | RD },
-	{ insn_subu, M(mm_pool32a_op, 0, 0, 0, 0, mm_subu32_op), RT | RS | RD },
-	{ insn_sw, M(mm_sw32_op, 0, 0, 0, 0, 0), RT | RS | SIMM },
-	{ insn_sync, M(mm_pool32a_op, 0, 0, 0, mm_sync_op, mm_pool32axf_op), RS },
-	{ insn_tlbp, M(mm_pool32a_op, 0, 0, 0, mm_tlbp_op, mm_pool32axf_op), 0 },
-	{ insn_tlbr, M(mm_pool32a_op, 0, 0, 0, mm_tlbr_op, mm_pool32axf_op), 0 },
-	{ insn_tlbwi, M(mm_pool32a_op, 0, 0, 0, mm_tlbwi_op, mm_pool32axf_op), 0 },
-	{ insn_tlbwr, M(mm_pool32a_op, 0, 0, 0, mm_tlbwr_op, mm_pool32axf_op), 0 },
-	{ insn_wait, M(mm_pool32a_op, 0, 0, 0, mm_wait_op, mm_pool32axf_op), SCIMM },
-	{ insn_wsbh, M(mm_pool32a_op, 0, 0, 0, mm_wsbh_op, mm_pool32axf_op), RT | RS },
-	{ insn_xor, M(mm_pool32a_op, 0, 0, 0, 0, mm_xor32_op), RT | RS | RD },
-	{ insn_xori, M(mm_xori32_op, 0, 0, 0, 0, 0), RT | RS | UIMM },
-	{ insn_dins, 0, 0 },
-	{ insn_dinsm, 0, 0 },
-	{ insn_syscall, M(mm_pool32a_op, 0, 0, 0, mm_syscall_op, mm_pool32axf_op), SCIMM},
-	{ insn_bbit0, 0, 0 },
-	{ insn_bbit1, 0, 0 },
-	{ insn_lwx, 0, 0 },
-	{ insn_ldx, 0, 0 },
-	{ insn_invalid, 0, 0 }
+static const struct insn const insn_table_MM[insn_invalid] = {
+	[insn_addu]	= {M(mm_pool32a_op, 0, 0, 0, 0, mm_addu32_op), RT | RS | RD},
+	[insn_addiu]	= {M(mm_addiu32_op, 0, 0, 0, 0, 0), RT | RS | SIMM},
+	[insn_and]	= {M(mm_pool32a_op, 0, 0, 0, 0, mm_and_op), RT | RS | RD},
+	[insn_andi]	= {M(mm_andi32_op, 0, 0, 0, 0, 0), RT | RS | UIMM},
+	[insn_beq]	= {M(mm_beq32_op, 0, 0, 0, 0, 0), RS | RT | BIMM},
+	[insn_beql]	= {0, 0},
+	[insn_bgez]	= {M(mm_pool32i_op, mm_bgez_op, 0, 0, 0, 0), RS | BIMM},
+	[insn_bgezl]	= {0, 0},
+	[insn_bltz]	= {M(mm_pool32i_op, mm_bltz_op, 0, 0, 0, 0), RS | BIMM},
+	[insn_bltzl]	= {0, 0},
+	[insn_bne]	= {M(mm_bne32_op, 0, 0, 0, 0, 0), RT | RS | BIMM},
+	[insn_cache]	= {M(mm_pool32b_op, 0, 0, mm_cache_func, 0, 0), RT | RS | SIMM},
+	[insn_cfc1]	= {M(mm_pool32f_op, 0, 0, 0, mm_cfc1_op, mm_32f_73_op), RT | RS},
+	[insn_cfcmsa]	= {M(mm_pool32s_op, 0, msa_cfc_op, 0, 0, mm_32s_elm_op), RD | RE},
+	[insn_ctc1]	= {M(mm_pool32f_op, 0, 0, 0, mm_ctc1_op, mm_32f_73_op), RT | RS},
+	[insn_ctcmsa]	= {M(mm_pool32s_op, 0, msa_ctc_op, 0, 0, mm_32s_elm_op), RD | RE},
+	[insn_daddu]	= {0, 0},
+	[insn_daddiu]	= {0, 0},
+	[insn_di]	= {M(mm_pool32a_op, 0, 0, 0, mm_di_op, mm_pool32axf_op), RS},
+	[insn_divu]	= {M(mm_pool32a_op, 0, 0, 0, mm_divu_op, mm_pool32axf_op), RT | RS},
+	[insn_dmfc0]	= {0, 0},
+	[insn_dmtc0]	= {0, 0},
+	[insn_dsll]	= {0, 0},
+	[insn_dsll32]	= {0, 0},
+	[insn_dsra]	= {0, 0},
+	[insn_dsrl]	= {0, 0},
+	[insn_dsrl32]	= {0, 0},
+	[insn_drotr]	= {0, 0},
+	[insn_drotr32]	= {0, 0},
+	[insn_dsubu]	= {0, 0},
+	[insn_eret]	= {M(mm_pool32a_op, 0, 0, 0, mm_eret_op, mm_pool32axf_op), 0},
+	[insn_ins]	= {M(mm_pool32a_op, 0, 0, 0, 0, mm_ins_op), RT | RS | RD | RE},
+	[insn_ext]	= {M(mm_pool32a_op, 0, 0, 0, 0, mm_ext_op), RT | RS | RD | RE},
+	[insn_j]	= {M(mm_j32_op, 0, 0, 0, 0, 0), JIMM},
+	[insn_jal]	= {M(mm_jal32_op, 0, 0, 0, 0, 0), JIMM},
+	[insn_jalr]	= {M(mm_pool32a_op, 0, 0, 0, mm_jalr_op, mm_pool32axf_op), RT | RS},
+	[insn_jr]	= {M(mm_pool32a_op, 0, 0, 0, mm_jalr_op, mm_pool32axf_op), RS},
+	[insn_lb]	= {M(mm_lb32_op, 0, 0, 0, 0, 0), RT | RS | SIMM},
+	[insn_ld]	= {0, 0},
+	[insn_lh]	= {M(mm_lh32_op, 0, 0, 0, 0, 0), RS | RS | SIMM},
+	[insn_ll]	= {M(mm_pool32c_op, 0, 0, (mm_ll_func << 1), 0, 0), RS | RT | SIMM},
+	[insn_lld]	= {0, 0},
+	[insn_lui]	= {M(mm_pool32i_op, mm_lui_op, 0, 0, 0, 0), RS | SIMM},
+	[insn_lw]	= {M(mm_lw32_op, 0, 0, 0, 0, 0), RT | RS | SIMM},
+	[insn_mfc0]	= {M(mm_pool32a_op, 0, 0, 0, mm_mfc0_op, mm_pool32axf_op), RT | RS | RD},
+	[insn_mfhi]	= {M(mm_pool32a_op, 0, 0, 0, mm_mfhi32_op, mm_pool32axf_op), RS},
+	[insn_mflo]	= {M(mm_pool32a_op, 0, 0, 0, mm_mflo32_op, mm_pool32axf_op), RS},
+	[insn_mtc0]	= {M(mm_pool32a_op, 0, 0, 0, mm_mtc0_op, mm_pool32axf_op), RT | RS | RD},
+	[insn_mthi]	= {M(mm_pool32a_op, 0, 0, 0, mm_mthi32_op, mm_pool32axf_op), RS},
+	[insn_mtlo]	= {M(mm_pool32a_op, 0, 0, 0, mm_mtlo32_op, mm_pool32axf_op), RS},
+	[insn_mul]	= {M(mm_pool32a_op, 0, 0, 0, 0, mm_mul_op), RT | RS | RD},
+	[insn_or]	= {M(mm_pool32a_op, 0, 0, 0, 0, mm_or32_op), RT | RS | RD},
+	[insn_ori]	= {M(mm_ori32_op, 0, 0, 0, 0, 0), RT | RS | UIMM},
+	[insn_pref]	= {M(mm_pool32c_op, 0, 0, (mm_pref_func << 1), 0, 0), RT | RS | SIMM},
+	[insn_rfe]	= {0, 0},
+	[insn_sc]	= {M(mm_pool32c_op, 0, 0, (mm_sc_func << 1), 0, 0), RT | RS | SIMM},
+	[insn_scd]	= {0, 0},
+	[insn_sd]	= {0, 0},
+	[insn_sll]	= {M(mm_pool32a_op, 0, 0, 0, 0, mm_sll32_op), RT | RS | RD},
+	[insn_sllv]	= {M(mm_pool32a_op, 0, 0, 0, 0, mm_sllv32_op), RT | RS | RD},
+	[insn_slt]	= {M(mm_pool32a_op, 0, 0, 0, 0, mm_slt_op), RT | RS | RD},
+	[insn_sltiu]	= {M(mm_sltiu32_op, 0, 0, 0, 0, 0), RT | RS | SIMM},
+	[insn_sltu]	= {M(mm_pool32a_op, 0, 0, 0, 0, mm_sltu_op), RT | RS | RD},
+	[insn_sra]	= {M(mm_pool32a_op, 0, 0, 0, 0, mm_sra_op), RT | RS | RD},
+	[insn_srl]	= {M(mm_pool32a_op, 0, 0, 0, 0, mm_srl32_op), RT | RS | RD},
+	[insn_srlv]	= {M(mm_pool32a_op, 0, 0, 0, 0, mm_srlv32_op), RT | RS | RD},
+	[insn_rotr]	= {M(mm_pool32a_op, 0, 0, 0, 0, mm_rotr_op), RT | RS | RD},
+	[insn_subu]	= {M(mm_pool32a_op, 0, 0, 0, 0, mm_subu32_op), RT | RS | RD},
+	[insn_sw]	= {M(mm_sw32_op, 0, 0, 0, 0, 0), RT | RS | SIMM},
+	[insn_sync]	= {M(mm_pool32a_op, 0, 0, 0, mm_sync_op, mm_pool32axf_op), RS},
+	[insn_tlbp]	= {M(mm_pool32a_op, 0, 0, 0, mm_tlbp_op, mm_pool32axf_op), 0},
+	[insn_tlbr]	= {M(mm_pool32a_op, 0, 0, 0, mm_tlbr_op, mm_pool32axf_op), 0},
+	[insn_tlbwi]	= {M(mm_pool32a_op, 0, 0, 0, mm_tlbwi_op, mm_pool32axf_op), 0},
+	[insn_tlbwr]	= {M(mm_pool32a_op, 0, 0, 0, mm_tlbwr_op, mm_pool32axf_op), 0},
+	[insn_wait]	= {M(mm_pool32a_op, 0, 0, 0, mm_wait_op, mm_pool32axf_op), SCIMM},
+	[insn_wsbh]	= {M(mm_pool32a_op, 0, 0, 0, mm_wsbh_op, mm_pool32axf_op), RT | RS},
+	[insn_xor]	= {M(mm_pool32a_op, 0, 0, 0, 0, mm_xor32_op), RT | RS | RD},
+	[insn_xori]	= {M(mm_xori32_op, 0, 0, 0, 0, 0), RT | RS | UIMM},
+	[insn_dins]	= {0, 0},
+	[insn_dinsm]	= {0, 0},
+	[insn_syscall]	= {M(mm_pool32a_op, 0, 0, 0, mm_syscall_op, mm_pool32axf_op), SCIMM},
+	[insn_bbit0]	= {0, 0},
+	[insn_bbit1]	= {0, 0},
+	[insn_lwx]	= {0, 0},
+	[insn_ldx]	= {0, 0},
 };
 
 #undef M
@@ -156,20 +155,17 @@ static inline u32 build_jimm(u32 arg)
  */
 static void build_insn(u32 **buf, enum opcode opc, ...)
 {
-	struct insn *ip = NULL;
-	unsigned int i;
+	const struct insn *ip;
 	va_list ap;
 	u32 op;
 
-	for (i = 0; insn_table_MM[i].opcode != insn_invalid; i++)
-		if (insn_table_MM[i].opcode == opc) {
-			ip = &insn_table_MM[i];
-			break;
-		}
-
-	if (!ip || (opc == insn_daddiu && r4k_daddiu_bug()))
+	if (opc < 0 || opc >= insn_invalid ||
+	    (opc == insn_daddiu && r4k_daddiu_bug()) ||
+	    (insn_table_MM[opc].match == 0 && insn_table_MM[opc].fields == 0))
 		panic("Unsupported Micro-assembler instruction %d", opc);
 
+	ip = &insn_table_MM[opc];
+
 	op = ip->match;
 	va_start(ap, opc);
 	if (ip->fields & RS) {
diff --git a/arch/mips/mm/uasm-mips.c b/arch/mips/mm/uasm-mips.c
index 2277499..f3937e3 100644
--- a/arch/mips/mm/uasm-mips.c
+++ b/arch/mips/mm/uasm-mips.c
@@ -48,126 +48,124 @@
 
 #include "uasm.c"
 
-static struct insn insn_table[] = {
-	{ insn_addiu, M(addiu_op, 0, 0, 0, 0, 0), RS | RT | SIMM },
-	{ insn_addu, M(spec_op, 0, 0, 0, 0, addu_op), RS | RT | RD },
-	{ insn_andi, M(andi_op, 0, 0, 0, 0, 0), RS | RT | UIMM },
-	{ insn_and, M(spec_op, 0, 0, 0, 0, and_op), RS | RT | RD },
-	{ insn_bbit0, M(lwc2_op, 0, 0, 0, 0, 0), RS | RT | BIMM },
-	{ insn_bbit1, M(swc2_op, 0, 0, 0, 0, 0), RS | RT | BIMM },
-	{ insn_beql, M(beql_op, 0, 0, 0, 0, 0), RS | RT | BIMM },
-	{ insn_beq, M(beq_op, 0, 0, 0, 0, 0), RS | RT | BIMM },
-	{ insn_bgezl, M(bcond_op, 0, bgezl_op, 0, 0, 0), RS | BIMM },
-	{ insn_bgez, M(bcond_op, 0, bgez_op, 0, 0, 0), RS | BIMM },
-	{ insn_bltzl, M(bcond_op, 0, bltzl_op, 0, 0, 0), RS | BIMM },
-	{ insn_bltz, M(bcond_op, 0, bltz_op, 0, 0, 0), RS | BIMM },
-	{ insn_bne, M(bne_op, 0, 0, 0, 0, 0), RS | RT | BIMM },
+static const struct insn const insn_table[insn_invalid] = {
+	[insn_addiu]	= {M(addiu_op, 0, 0, 0, 0, 0), RS | RT | SIMM},
+	[insn_addu]	= {M(spec_op, 0, 0, 0, 0, addu_op), RS | RT | RD},
+	[insn_and]	= {M(spec_op, 0, 0, 0, 0, and_op), RS | RT | RD},
+	[insn_andi]	= {M(andi_op, 0, 0, 0, 0, 0), RS | RT | UIMM},
+	[insn_bbit0]	= {M(lwc2_op, 0, 0, 0, 0, 0), RS | RT | BIMM},
+	[insn_bbit1]	= {M(swc2_op, 0, 0, 0, 0, 0), RS | RT | BIMM},
+	[insn_beq]	= {M(beq_op, 0, 0, 0, 0, 0), RS | RT | BIMM},
+	[insn_beql]	= {M(beql_op, 0, 0, 0, 0, 0), RS | RT | BIMM},
+	[insn_bgez]	= {M(bcond_op, 0, bgez_op, 0, 0, 0), RS | BIMM},
+	[insn_bgezl]	= {M(bcond_op, 0, bgezl_op, 0, 0, 0), RS | BIMM},
+	[insn_bltz]	= {M(bcond_op, 0, bltz_op, 0, 0, 0), RS | BIMM},
+	[insn_bltzl]	= {M(bcond_op, 0, bltzl_op, 0, 0, 0), RS | BIMM},
+	[insn_bne]	= {M(bne_op, 0, 0, 0, 0, 0), RS | RT | BIMM},
 #ifndef CONFIG_CPU_MIPSR6
-	{ insn_cache,  M(cache_op, 0, 0, 0, 0, 0),  RS | RT | SIMM },
+	[insn_cache]	= {M(cache_op, 0, 0, 0, 0, 0),  RS | RT | SIMM},
 #else
-	{ insn_cache,  M6(spec3_op, 0, 0, 0, cache6_op),  RS | RT | SIMM9 },
+	[insn_cache]	= {M6(spec3_op, 0, 0, 0, cache6_op),  RS | RT | SIMM9},
 #endif
-	{ insn_cfc1, M(cop1_op, cfc_op, 0, 0, 0, 0), RT | RD },
-	{ insn_cfcmsa, M(msa_op, 0, msa_cfc_op, 0, 0, msa_elm_op), RD | RE },
-	{ insn_ctc1, M(cop1_op, ctc_op, 0, 0, 0, 0), RT | RD },
-	{ insn_ctcmsa, M(msa_op, 0, msa_ctc_op, 0, 0, msa_elm_op), RD | RE },
-	{ insn_daddiu, M(daddiu_op, 0, 0, 0, 0, 0), RS | RT | SIMM },
-	{ insn_daddu, M(spec_op, 0, 0, 0, 0, daddu_op), RS | RT | RD },
-	{ insn_dinsm, M(spec3_op, 0, 0, 0, 0, dinsm_op), RS | RT | RD | RE },
-	{ insn_di, M(cop0_op, mfmc0_op, 0, 12, 0, 0), RT },
-	{ insn_dins, M(spec3_op, 0, 0, 0, 0, dins_op), RS | RT | RD | RE },
-	{ insn_divu, M(spec_op, 0, 0, 0, 0, divu_op), RS | RT },
-	{ insn_dmfc0, M(cop0_op, dmfc_op, 0, 0, 0, 0), RT | RD | SET},
-	{ insn_dmtc0, M(cop0_op, dmtc_op, 0, 0, 0, 0), RT | RD | SET},
-	{ insn_drotr32, M(spec_op, 1, 0, 0, 0, dsrl32_op), RT | RD | RE },
-	{ insn_drotr, M(spec_op, 1, 0, 0, 0, dsrl_op), RT | RD | RE },
-	{ insn_dsll32, M(spec_op, 0, 0, 0, 0, dsll32_op), RT | RD | RE },
-	{ insn_dsll, M(spec_op, 0, 0, 0, 0, dsll_op), RT | RD | RE },
-	{ insn_dsra, M(spec_op, 0, 0, 0, 0, dsra_op), RT | RD | RE },
-	{ insn_dsrl32, M(spec_op, 0, 0, 0, 0, dsrl32_op), RT | RD | RE },
-	{ insn_dsrl, M(spec_op, 0, 0, 0, 0, dsrl_op), RT | RD | RE },
-	{ insn_dsubu, M(spec_op, 0, 0, 0, 0, dsubu_op), RS | RT | RD },
-	{ insn_eret,  M(cop0_op, cop_op, 0, 0, 0, eret_op),  0 },
-	{ insn_ext, M(spec3_op, 0, 0, 0, 0, ext_op), RS | RT | RD | RE },
-	{ insn_ins, M(spec3_op, 0, 0, 0, 0, ins_op), RS | RT | RD | RE },
-	{ insn_j,  M(j_op, 0, 0, 0, 0, 0),  JIMM },
-	{ insn_jal,  M(jal_op, 0, 0, 0, 0, 0),	JIMM },
-	{ insn_jalr,  M(spec_op, 0, 0, 0, 0, jalr_op), RS | RD },
-	{ insn_j,  M(j_op, 0, 0, 0, 0, 0),  JIMM },
+	[insn_cfc1]	= {M(cop1_op, cfc_op, 0, 0, 0, 0), RT | RD},
+	[insn_cfcmsa]	= {M(msa_op, 0, msa_cfc_op, 0, 0, msa_elm_op), RD | RE},
+	[insn_ctc1]	= {M(cop1_op, ctc_op, 0, 0, 0, 0), RT | RD},
+	[insn_ctcmsa]	= {M(msa_op, 0, msa_ctc_op, 0, 0, msa_elm_op), RD | RE},
+	[insn_daddiu]	= {M(daddiu_op, 0, 0, 0, 0, 0), RS | RT | SIMM},
+	[insn_daddu]	= {M(spec_op, 0, 0, 0, 0, daddu_op), RS | RT | RD},
+	[insn_di]	= {M(cop0_op, mfmc0_op, 0, 12, 0, 0), RT},
+	[insn_dins]	= {M(spec3_op, 0, 0, 0, 0, dins_op), RS | RT | RD | RE},
+	[insn_dinsm]	= {M(spec3_op, 0, 0, 0, 0, dinsm_op), RS | RT | RD | RE},
+	[insn_divu]	= {M(spec_op, 0, 0, 0, 0, divu_op), RS | RT},
+	[insn_dmfc0]	= {M(cop0_op, dmfc_op, 0, 0, 0, 0), RT | RD | SET},
+	[insn_dmtc0]	= {M(cop0_op, dmtc_op, 0, 0, 0, 0), RT | RD | SET},
+	[insn_drotr]	= {M(spec_op, 1, 0, 0, 0, dsrl_op), RT | RD | RE},
+	[insn_drotr32]	= {M(spec_op, 1, 0, 0, 0, dsrl32_op), RT | RD | RE},
+	[insn_dsll]	= {M(spec_op, 0, 0, 0, 0, dsll_op), RT | RD | RE},
+	[insn_dsll32]	= {M(spec_op, 0, 0, 0, 0, dsll32_op), RT | RD | RE},
+	[insn_dsra]	= {M(spec_op, 0, 0, 0, 0, dsra_op), RT | RD | RE},
+	[insn_dsrl]	= {M(spec_op, 0, 0, 0, 0, dsrl_op), RT | RD | RE},
+	[insn_dsrl32]	= {M(spec_op, 0, 0, 0, 0, dsrl32_op), RT | RD | RE},
+	[insn_dsubu]	= {M(spec_op, 0, 0, 0, 0, dsubu_op), RS | RT | RD},
+	[insn_eret]	= {M(cop0_op, cop_op, 0, 0, 0, eret_op),  0},
+	[insn_ext]	= {M(spec3_op, 0, 0, 0, 0, ext_op), RS | RT | RD | RE},
+	[insn_ins]	= {M(spec3_op, 0, 0, 0, 0, ins_op), RS | RT | RD | RE},
+	[insn_j]	= {M(j_op, 0, 0, 0, 0, 0),  JIMM},
+	[insn_jal]	= {M(jal_op, 0, 0, 0, 0, 0),	JIMM},
+	[insn_jalr]	= {M(spec_op, 0, 0, 0, 0, jalr_op), RS | RD},
 #ifndef CONFIG_CPU_MIPSR6
-	{ insn_jr,  M(spec_op, 0, 0, 0, 0, jr_op),  RS },
+	[insn_jr]	= {M(spec_op, 0, 0, 0, 0, jr_op),  RS},
 #else
-	{ insn_jr,  M(spec_op, 0, 0, 0, 0, jalr_op),  RS },
+	[insn_jr]	= {M(spec_op, 0, 0, 0, 0, jalr_op),  RS},
 #endif
-	{ insn_lb, M(lb_op, 0, 0, 0, 0, 0), RS | RT | SIMM },
-	{ insn_ld,  M(ld_op, 0, 0, 0, 0, 0),  RS | RT | SIMM },
-	{ insn_ldx, M(spec3_op, 0, 0, 0, ldx_op, lx_op), RS | RT | RD },
-	{ insn_lh,  M(lh_op, 0, 0, 0, 0, 0),  RS | RT | SIMM },
-	{ insn_lhu,  M(lhu_op, 0, 0, 0, 0, 0),  RS | RT | SIMM },
+	[insn_lb]	= {M(lb_op, 0, 0, 0, 0, 0), RS | RT | SIMM},
+	[insn_ld]	= {M(ld_op, 0, 0, 0, 0, 0),  RS | RT | SIMM},
+	[insn_lddir]	= {M(lwc2_op, 0, 0, 0, lddir_op, mult_op), RS | RT | RD},
+	[insn_ldpte]	= {M(lwc2_op, 0, 0, 0, ldpte_op, mult_op), RS | RD},
+	[insn_ldx]	= {M(spec3_op, 0, 0, 0, ldx_op, lx_op), RS | RT | RD},
+	[insn_lh]	= {M(lh_op, 0, 0, 0, 0, 0),  RS | RT | SIMM},
+	[insn_lhu]	= {M(lhu_op, 0, 0, 0, 0, 0),  RS | RT | SIMM},
 #ifndef CONFIG_CPU_MIPSR6
-	{ insn_lld,  M(lld_op, 0, 0, 0, 0, 0),	RS | RT | SIMM },
-	{ insn_ll,  M(ll_op, 0, 0, 0, 0, 0),  RS | RT | SIMM },
+	[insn_ll]	= {M(ll_op, 0, 0, 0, 0, 0),  RS | RT | SIMM},
+	[insn_lld]	= {M(lld_op, 0, 0, 0, 0, 0),	RS | RT | SIMM},
 #else
-	{ insn_lld,  M6(spec3_op, 0, 0, 0, lld6_op),  RS | RT | SIMM9 },
-	{ insn_ll,  M6(spec3_op, 0, 0, 0, ll6_op),  RS | RT | SIMM9 },
+	[insn_ll]	= {M6(spec3_op, 0, 0, 0, ll6_op),  RS | RT | SIMM9},
+	[insn_lld]	= {M6(spec3_op, 0, 0, 0, lld6_op),  RS | RT | SIMM9},
 #endif
-	{ insn_lui,  M(lui_op, 0, 0, 0, 0, 0),	RT | SIMM },
-	{ insn_lw,  M(lw_op, 0, 0, 0, 0, 0),  RS | RT | SIMM },
-	{ insn_lwx, M(spec3_op, 0, 0, 0, lwx_op, lx_op), RS | RT | RD },
-	{ insn_mfc0,  M(cop0_op, mfc_op, 0, 0, 0, 0),  RT | RD | SET},
-	{ insn_mfhc0,  M(cop0_op, mfhc0_op, 0, 0, 0, 0),  RT | RD | SET},
-	{ insn_mfhi,  M(spec_op, 0, 0, 0, 0, mfhi_op), RD },
-	{ insn_mflo,  M(spec_op, 0, 0, 0, 0, mflo_op), RD },
-	{ insn_mtc0,  M(cop0_op, mtc_op, 0, 0, 0, 0),  RT | RD | SET},
-	{ insn_mthc0,  M(cop0_op, mthc0_op, 0, 0, 0, 0),  RT | RD | SET},
-	{ insn_mthi,  M(spec_op, 0, 0, 0, 0, mthi_op), RS },
-	{ insn_mtlo,  M(spec_op, 0, 0, 0, 0, mtlo_op), RS },
+	[insn_lui]	= {M(lui_op, 0, 0, 0, 0, 0),	RT | SIMM},
+	[insn_lw]	= {M(lw_op, 0, 0, 0, 0, 0),  RS | RT | SIMM},
+	[insn_lwx]	= {M(spec3_op, 0, 0, 0, lwx_op, lx_op), RS | RT | RD},
+	[insn_mfc0]	= {M(cop0_op, mfc_op, 0, 0, 0, 0),  RT | RD | SET},
+	[insn_mfhc0]	= {M(cop0_op, mfhc0_op, 0, 0, 0, 0),  RT | RD | SET},
+	[insn_mfhi]	= {M(spec_op, 0, 0, 0, 0, mfhi_op), RD},
+	[insn_mflo]	= {M(spec_op, 0, 0, 0, 0, mflo_op), RD},
+	[insn_mtc0]	= {M(cop0_op, mtc_op, 0, 0, 0, 0),  RT | RD | SET},
+	[insn_mthc0]	= {M(cop0_op, mthc0_op, 0, 0, 0, 0),  RT | RD | SET},
+	[insn_mthi]	= {M(spec_op, 0, 0, 0, 0, mthi_op), RS},
+	[insn_mtlo]	= {M(spec_op, 0, 0, 0, 0, mtlo_op), RS},
 #ifndef CONFIG_CPU_MIPSR6
-	{ insn_mul, M(spec2_op, 0, 0, 0, 0, mul_op), RS | RT | RD},
+	[insn_mul]	= {M(spec2_op, 0, 0, 0, 0, mul_op), RS | RT | RD},
 #else
-	{ insn_mul, M(spec_op, 0, 0, 0, mult_mul_op, mult_op), RS | RT | RD},
+	[insn_mul]	= {M(spec_op, 0, 0, 0, mult_mul_op, mult_op), RS | RT | RD},
 #endif
-	{ insn_ori,  M(ori_op, 0, 0, 0, 0, 0),	RS | RT | UIMM },
-	{ insn_or,  M(spec_op, 0, 0, 0, 0, or_op),  RS | RT | RD },
+	[insn_or]	= {M(spec_op, 0, 0, 0, 0, or_op),  RS | RT | RD},
+	[insn_ori]	= {M(ori_op, 0, 0, 0, 0, 0),	RS | RT | UIMM},
 #ifndef CONFIG_CPU_MIPSR6
-	{ insn_pref,  M(pref_op, 0, 0, 0, 0, 0),  RS | RT | SIMM },
+	[insn_pref]	= {M(pref_op, 0, 0, 0, 0, 0),  RS | RT | SIMM},
 #else
-	{ insn_pref,  M6(spec3_op, 0, 0, 0, pref6_op),  RS | RT | SIMM9 },
+	[insn_pref]	= {M6(spec3_op, 0, 0, 0, pref6_op),  RS | RT | SIMM9},
 #endif
-	{ insn_rfe,  M(cop0_op, cop_op, 0, 0, 0, rfe_op),  0 },
-	{ insn_rotr,  M(spec_op, 1, 0, 0, 0, srl_op),  RT | RD | RE },
+	[insn_rfe]	= {M(cop0_op, cop_op, 0, 0, 0, rfe_op),  0},
+	[insn_rotr]	= {M(spec_op, 1, 0, 0, 0, srl_op),  RT | RD | RE},
 #ifndef CONFIG_CPU_MIPSR6
-	{ insn_scd,  M(scd_op, 0, 0, 0, 0, 0),	RS | RT | SIMM },
-	{ insn_sc,  M(sc_op, 0, 0, 0, 0, 0),  RS | RT | SIMM },
+	[insn_sc]	= {M(sc_op, 0, 0, 0, 0, 0),  RS | RT | SIMM},
+	[insn_scd]	= {M(scd_op, 0, 0, 0, 0, 0),	RS | RT | SIMM},
 #else
-	{ insn_scd,  M6(spec3_op, 0, 0, 0, scd6_op),  RS | RT | SIMM9 },
-	{ insn_sc,  M6(spec3_op, 0, 0, 0, sc6_op),  RS | RT | SIMM9 },
+	[insn_sc]	= {M6(spec3_op, 0, 0, 0, sc6_op),  RS | RT | SIMM9},
+	[insn_scd]	= {M6(spec3_op, 0, 0, 0, scd6_op),  RS | RT | SIMM9},
 #endif
-	{ insn_sd,  M(sd_op, 0, 0, 0, 0, 0),  RS | RT | SIMM },
-	{ insn_sll,  M(spec_op, 0, 0, 0, 0, sll_op),  RT | RD | RE },
-	{ insn_sllv,  M(spec_op, 0, 0, 0, 0, sllv_op),  RS | RT | RD },
-	{ insn_slt,  M(spec_op, 0, 0, 0, 0, slt_op),  RS | RT | RD },
-	{ insn_sltiu, M(sltiu_op, 0, 0, 0, 0, 0), RS | RT | SIMM },
-	{ insn_sltu, M(spec_op, 0, 0, 0, 0, sltu_op), RS | RT | RD },
-	{ insn_sra,  M(spec_op, 0, 0, 0, 0, sra_op),  RT | RD | RE },
-	{ insn_srl,  M(spec_op, 0, 0, 0, 0, srl_op),  RT | RD | RE },
-	{ insn_srlv,  M(spec_op, 0, 0, 0, 0, srlv_op),  RS | RT | RD },
-	{ insn_subu,  M(spec_op, 0, 0, 0, 0, subu_op),	RS | RT | RD },
-	{ insn_sw,  M(sw_op, 0, 0, 0, 0, 0),  RS | RT | SIMM },
-	{ insn_sync, M(spec_op, 0, 0, 0, 0, sync_op), RE },
-	{ insn_syscall, M(spec_op, 0, 0, 0, 0, syscall_op), SCIMM},
-	{ insn_tlbp,  M(cop0_op, cop_op, 0, 0, 0, tlbp_op),  0 },
-	{ insn_tlbr,  M(cop0_op, cop_op, 0, 0, 0, tlbr_op),  0 },
-	{ insn_tlbwi,  M(cop0_op, cop_op, 0, 0, 0, tlbwi_op),  0 },
-	{ insn_tlbwr,  M(cop0_op, cop_op, 0, 0, 0, tlbwr_op),  0 },
-	{ insn_wait, M(cop0_op, cop_op, 0, 0, 0, wait_op), SCIMM },
-	{ insn_wsbh, M(spec3_op, 0, 0, 0, wsbh_op, bshfl_op), RT | RD },
-	{ insn_xori,  M(xori_op, 0, 0, 0, 0, 0),  RS | RT | UIMM },
-	{ insn_xor,  M(spec_op, 0, 0, 0, 0, xor_op),  RS | RT | RD },
-	{ insn_yield, M(spec3_op, 0, 0, 0, 0, yield_op), RS | RD },
-	{ insn_ldpte, M(lwc2_op, 0, 0, 0, ldpte_op, mult_op), RS | RD },
-	{ insn_lddir, M(lwc2_op, 0, 0, 0, lddir_op, mult_op), RS | RT | RD },
-	{ insn_invalid, 0, 0 }
+	[insn_sd]	= {M(sd_op, 0, 0, 0, 0, 0),  RS | RT | SIMM},
+	[insn_sll]	= {M(spec_op, 0, 0, 0, 0, sll_op),  RT | RD | RE},
+	[insn_sllv]	= {M(spec_op, 0, 0, 0, 0, sllv_op),  RS | RT | RD},
+	[insn_slt]	= {M(spec_op, 0, 0, 0, 0, slt_op),  RS | RT | RD},
+	[insn_sltiu]	= {M(sltiu_op, 0, 0, 0, 0, 0), RS | RT | SIMM},
+	[insn_sltu]	= {M(spec_op, 0, 0, 0, 0, sltu_op), RS | RT | RD},
+	[insn_sra]	= {M(spec_op, 0, 0, 0, 0, sra_op),  RT | RD | RE},
+	[insn_srl]	= {M(spec_op, 0, 0, 0, 0, srl_op),  RT | RD | RE},
+	[insn_srlv]	= {M(spec_op, 0, 0, 0, 0, srlv_op),  RS | RT | RD},
+	[insn_subu]	= {M(spec_op, 0, 0, 0, 0, subu_op),	RS | RT | RD},
+	[insn_sw]	= {M(sw_op, 0, 0, 0, 0, 0),  RS | RT | SIMM},
+	[insn_sync]	= {M(spec_op, 0, 0, 0, 0, sync_op), RE},
+	[insn_syscall]	= {M(spec_op, 0, 0, 0, 0, syscall_op), SCIMM},
+	[insn_tlbp]	= {M(cop0_op, cop_op, 0, 0, 0, tlbp_op),  0},
+	[insn_tlbr]	= {M(cop0_op, cop_op, 0, 0, 0, tlbr_op),  0},
+	[insn_tlbwi]	= {M(cop0_op, cop_op, 0, 0, 0, tlbwi_op),  0},
+	[insn_tlbwr]	= {M(cop0_op, cop_op, 0, 0, 0, tlbwr_op),  0},
+	[insn_wait]	= {M(cop0_op, cop_op, 0, 0, 0, wait_op), SCIMM},
+	[insn_wsbh]	= {M(spec3_op, 0, 0, 0, wsbh_op, bshfl_op), RT | RD},
+	[insn_xor]	= {M(spec_op, 0, 0, 0, 0, xor_op),  RS | RT | RD},
+	[insn_xori]	= {M(xori_op, 0, 0, 0, 0, 0),  RS | RT | UIMM},
+	[insn_yield]	= {M(spec3_op, 0, 0, 0, 0, yield_op), RS | RD},
 };
 
 #undef M
@@ -196,20 +194,17 @@ static inline u32 build_jimm(u32 arg)
  */
 static void build_insn(u32 **buf, enum opcode opc, ...)
 {
-	struct insn *ip = NULL;
-	unsigned int i;
+	const struct insn *ip;
 	va_list ap;
 	u32 op;
 
-	for (i = 0; insn_table[i].opcode != insn_invalid; i++)
-		if (insn_table[i].opcode == opc) {
-			ip = &insn_table[i];
-			break;
-		}
-
-	if (!ip || (opc == insn_daddiu && r4k_daddiu_bug()))
+	if (opc < 0 || opc >= insn_invalid ||
+	    (opc == insn_daddiu && r4k_daddiu_bug()) ||
+	    (insn_table[opc].match == 0 && insn_table[opc].fields == 0))
 		panic("Unsupported Micro-assembler instruction %d", opc);
 
+	ip = &insn_table[opc];
+
 	op = ip->match;
 	va_start(ap, opc);
 	if (ip->fields & RS)
diff --git a/arch/mips/mm/uasm.c b/arch/mips/mm/uasm.c
index 730363b..f23ed85 100644
--- a/arch/mips/mm/uasm.c
+++ b/arch/mips/mm/uasm.c
@@ -46,7 +46,6 @@ enum fields {
 #define SIMM9_MASK	0x1ff
 
 enum opcode {
-	insn_invalid,
 	insn_addiu, insn_addu, insn_and, insn_andi, insn_bbit0, insn_bbit1,
 	insn_beq, insn_beql, insn_bgez, insn_bgezl, insn_bltz, insn_bltzl,
 	insn_bne, insn_cache, insn_cfc1, insn_cfcmsa, insn_ctc1, insn_ctcmsa,
@@ -62,10 +61,10 @@ enum opcode {
 	insn_srlv, insn_subu, insn_sw, insn_sync, insn_syscall, insn_tlbp,
 	insn_tlbr, insn_tlbwi, insn_tlbwr, insn_wait, insn_wsbh, insn_xor,
 	insn_xori, insn_yield, insn_lddir, insn_ldpte, insn_lhu,
+	insn_invalid /* insn_invalid must be last */
 };
 
 struct insn {
-	enum opcode opcode;
 	u32 match;
 	enum fields fields;
 };
-- 
2.9.4
