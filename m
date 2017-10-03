From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC 1/2] bpf: move instruction printing into a separate file
Date: Tue,  3 Oct 2017 10:57:45 -0700
Message-ID: <20171003175746.30145-1-jakub.kicinski@netronome.com>
References: <59D3B456.4020209@iogearbox.net>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        david.beckett@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: daniel@iogearbox.net, dsahern@gmail.com,
        alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:51073 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751199AbdJCR55 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 13:57:57 -0400
Received: by mail-pf0-f181.google.com with SMTP id m63so4957405pfk.7
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 10:57:57 -0700 (PDT)
In-Reply-To: <59D3B456.4020209@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Separate the instruction printing into a standalone source file.
This way sneaky code from tools/ can use it directly.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
Like this?

 kernel/bpf/Makefile   |   1 +
 kernel/bpf/disasm.c   | 212 ++++++++++++++++++++++++++++++++++++++++++++++++++
 kernel/bpf/disasm.h   |  29 +++++++
 kernel/bpf/verifier.c | 200 +----------------------------------------------
 4 files changed, 245 insertions(+), 197 deletions(-)
 create mode 100644 kernel/bpf/disasm.c
 create mode 100644 kernel/bpf/disasm.h

diff --git a/kernel/bpf/Makefile b/kernel/bpf/Makefile
index 897daa005b23..53fb09f92e3f 100644
--- a/kernel/bpf/Makefile
+++ b/kernel/bpf/Makefile
@@ -2,6 +2,7 @@ obj-y := core.o
 
 obj-$(CONFIG_BPF_SYSCALL) += syscall.o verifier.o inode.o helpers.o tnum.o
 obj-$(CONFIG_BPF_SYSCALL) += hashtab.o arraymap.o percpu_freelist.o bpf_lru_list.o lpm_trie.o map_in_map.o
+obj-$(CONFIG_BPF_SYSCALL) += disasm.o
 ifeq ($(CONFIG_NET),y)
 obj-$(CONFIG_BPF_SYSCALL) += devmap.o
 ifeq ($(CONFIG_STREAM_PARSER),y)
diff --git a/kernel/bpf/disasm.c b/kernel/bpf/disasm.c
new file mode 100644
index 000000000000..f2194fa442a4
--- /dev/null
+++ b/kernel/bpf/disasm.c
@@ -0,0 +1,212 @@
+/* Copyright (c) 2011-2014 PLUMgrid, http://plumgrid.com
+ * Copyright (c) 2016 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ */
+
+#include <linux/bpf.h>
+
+#include "disasm.h"
+
+#define __BPF_FUNC_STR_FN(x) [BPF_FUNC_ ## x] = __stringify(bpf_ ## x)
+static const char * const func_id_str[] = {
+	__BPF_FUNC_MAPPER(__BPF_FUNC_STR_FN)
+};
+#undef __BPF_FUNC_STR_FN
+
+const char *func_id_name(int id)
+{
+	BUILD_BUG_ON(ARRAY_SIZE(func_id_str) != __BPF_FUNC_MAX_ID);
+
+	if (id >= 0 && id < __BPF_FUNC_MAX_ID && func_id_str[id])
+		return func_id_str[id];
+	else
+		return "unknown";
+}
+
+const char *const bpf_class_string[8] = {
+	[BPF_LD]    = "ld",
+	[BPF_LDX]   = "ldx",
+	[BPF_ST]    = "st",
+	[BPF_STX]   = "stx",
+	[BPF_ALU]   = "alu",
+	[BPF_JMP]   = "jmp",
+	[BPF_RET]   = "BUG",
+	[BPF_ALU64] = "alu64",
+};
+
+const char *const bpf_alu_string[16] = {
+	[BPF_ADD >> 4]  = "+=",
+	[BPF_SUB >> 4]  = "-=",
+	[BPF_MUL >> 4]  = "*=",
+	[BPF_DIV >> 4]  = "/=",
+	[BPF_OR  >> 4]  = "|=",
+	[BPF_AND >> 4]  = "&=",
+	[BPF_LSH >> 4]  = "<<=",
+	[BPF_RSH >> 4]  = ">>=",
+	[BPF_NEG >> 4]  = "neg",
+	[BPF_MOD >> 4]  = "%=",
+	[BPF_XOR >> 4]  = "^=",
+	[BPF_MOV >> 4]  = "=",
+	[BPF_ARSH >> 4] = "s>>=",
+	[BPF_END >> 4]  = "endian",
+};
+
+static const char *const bpf_ldst_string[] = {
+	[BPF_W >> 3]  = "u32",
+	[BPF_H >> 3]  = "u16",
+	[BPF_B >> 3]  = "u8",
+	[BPF_DW >> 3] = "u64",
+};
+
+static const char *const bpf_jmp_string[16] = {
+	[BPF_JA >> 4]   = "jmp",
+	[BPF_JEQ >> 4]  = "==",
+	[BPF_JGT >> 4]  = ">",
+	[BPF_JLT >> 4]  = "<",
+	[BPF_JGE >> 4]  = ">=",
+	[BPF_JLE >> 4]  = "<=",
+	[BPF_JSET >> 4] = "&",
+	[BPF_JNE >> 4]  = "!=",
+	[BPF_JSGT >> 4] = "s>",
+	[BPF_JSLT >> 4] = "s<",
+	[BPF_JSGE >> 4] = "s>=",
+	[BPF_JSLE >> 4] = "s<=",
+	[BPF_CALL >> 4] = "call",
+	[BPF_EXIT >> 4] = "exit",
+};
+
+static void print_bpf_end_insn(void (*verbose)(const char *, ...),
+			       const struct bpf_insn *insn)
+{
+	verbose("(%02x) r%d = %s%d r%d\n", insn->code, insn->dst_reg,
+		BPF_SRC(insn->code) == BPF_TO_BE ? "be" : "le",
+		insn->imm, insn->dst_reg);
+}
+
+void print_bpf_insn(void (*verbose)(const char *, ...),
+		    const struct bpf_insn *insn, bool allow_ptr_leaks)
+{
+	u8 class = BPF_CLASS(insn->code);
+
+	if (class == BPF_ALU || class == BPF_ALU64) {
+		if (BPF_OP(insn->code) == BPF_END) {
+			if (class == BPF_ALU64)
+				verbose("BUG_alu64_%02x\n", insn->code);
+			else
+				print_bpf_end_insn(verbose, insn);
+		} else if (BPF_OP(insn->code) == BPF_NEG) {
+			verbose("(%02x) r%d = %s-r%d\n",
+				insn->code, insn->dst_reg,
+				class == BPF_ALU ? "(u32) " : "",
+				insn->dst_reg);
+		} else if (BPF_SRC(insn->code) == BPF_X) {
+			verbose("(%02x) %sr%d %s %sr%d\n",
+				insn->code, class == BPF_ALU ? "(u32) " : "",
+				insn->dst_reg,
+				bpf_alu_string[BPF_OP(insn->code) >> 4],
+				class == BPF_ALU ? "(u32) " : "",
+				insn->src_reg);
+		} else {
+			verbose("(%02x) %sr%d %s %s%d\n",
+				insn->code, class == BPF_ALU ? "(u32) " : "",
+				insn->dst_reg,
+				bpf_alu_string[BPF_OP(insn->code) >> 4],
+				class == BPF_ALU ? "(u32) " : "",
+				insn->imm);
+		}
+	} else if (class == BPF_STX) {
+		if (BPF_MODE(insn->code) == BPF_MEM)
+			verbose("(%02x) *(%s *)(r%d %+d) = r%d\n",
+				insn->code,
+				bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
+				insn->dst_reg,
+				insn->off, insn->src_reg);
+		else if (BPF_MODE(insn->code) == BPF_XADD)
+			verbose("(%02x) lock *(%s *)(r%d %+d) += r%d\n",
+				insn->code,
+				bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
+				insn->dst_reg, insn->off,
+				insn->src_reg);
+		else
+			verbose("BUG_%02x\n", insn->code);
+	} else if (class == BPF_ST) {
+		if (BPF_MODE(insn->code) != BPF_MEM) {
+			verbose("BUG_st_%02x\n", insn->code);
+			return;
+		}
+		verbose("(%02x) *(%s *)(r%d %+d) = %d\n",
+			insn->code,
+			bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
+			insn->dst_reg,
+			insn->off, insn->imm);
+	} else if (class == BPF_LDX) {
+		if (BPF_MODE(insn->code) != BPF_MEM) {
+			verbose("BUG_ldx_%02x\n", insn->code);
+			return;
+		}
+		verbose("(%02x) r%d = *(%s *)(r%d %+d)\n",
+			insn->code, insn->dst_reg,
+			bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
+			insn->src_reg, insn->off);
+	} else if (class == BPF_LD) {
+		if (BPF_MODE(insn->code) == BPF_ABS) {
+			verbose("(%02x) r0 = *(%s *)skb[%d]\n",
+				insn->code,
+				bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
+				insn->imm);
+		} else if (BPF_MODE(insn->code) == BPF_IND) {
+			verbose("(%02x) r0 = *(%s *)skb[r%d + %d]\n",
+				insn->code,
+				bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
+				insn->src_reg, insn->imm);
+		} else if (BPF_MODE(insn->code) == BPF_IMM &&
+			   BPF_SIZE(insn->code) == BPF_DW) {
+			/* At this point, we already made sure that the second
+			 * part of the ldimm64 insn is accessible.
+			 */
+			u64 imm = ((u64)(insn + 1)->imm << 32) | (u32)insn->imm;
+			bool map_ptr = insn->src_reg == BPF_PSEUDO_MAP_FD;
+
+			if (map_ptr && allow_ptr_leaks)
+				imm = 0;
+
+			verbose("(%02x) r%d = 0x%llx\n", insn->code,
+				insn->dst_reg, (unsigned long long)imm);
+		} else {
+			verbose("BUG_ld_%02x\n", insn->code);
+			return;
+		}
+	} else if (class == BPF_JMP) {
+		u8 opcode = BPF_OP(insn->code);
+
+		if (opcode == BPF_CALL) {
+			verbose("(%02x) call %s#%d\n", insn->code,
+				func_id_name(insn->imm), insn->imm);
+		} else if (insn->code == (BPF_JMP | BPF_JA)) {
+			verbose("(%02x) goto pc%+d\n",
+				insn->code, insn->off);
+		} else if (insn->code == (BPF_JMP | BPF_EXIT)) {
+			verbose("(%02x) exit\n", insn->code);
+		} else if (BPF_SRC(insn->code) == BPF_X) {
+			verbose("(%02x) if r%d %s r%d goto pc%+d\n",
+				insn->code, insn->dst_reg,
+				bpf_jmp_string[BPF_OP(insn->code) >> 4],
+				insn->src_reg, insn->off);
+		} else {
+			verbose("(%02x) if r%d %s 0x%x goto pc%+d\n",
+				insn->code, insn->dst_reg,
+				bpf_jmp_string[BPF_OP(insn->code) >> 4],
+				insn->imm, insn->off);
+		}
+	} else {
+		verbose("(%02x) %s\n", insn->code, bpf_class_string[class]);
+	}
+}
diff --git a/kernel/bpf/disasm.h b/kernel/bpf/disasm.h
new file mode 100644
index 000000000000..fa5637334bb1
--- /dev/null
+++ b/kernel/bpf/disasm.h
@@ -0,0 +1,29 @@
+/* Copyright (c) 2011-2014 PLUMgrid, http://plumgrid.com
+ * Copyright (c) 2016 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ */
+
+#ifndef __BPF_DISASM_H__
+#define __BPF_DISASM_H__
+
+#include <linux/bpf.h>
+#include <linux/kernel.h>
+#include <linux/stringify.h>
+
+extern const char *const bpf_alu_string[16];
+extern const char *const bpf_class_string[8];
+
+const char *func_id_name(int id);
+
+void print_bpf_insn(void (*verbose)(const char *, ...),
+		    const struct bpf_insn *insn, bool allow_ptr_leaks);
+
+#endif
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 4cf9b72c59a0..1e40b5d41b9e 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -21,6 +21,8 @@
 #include <linux/vmalloc.h>
 #include <linux/stringify.h>
 
+#include "disasm.h"
+
 /* bpf_check() is a static code analyzer that walks eBPF program
  * instruction by instruction and updates register/stack state.
  * All paths of conditional branches are analyzed until 'bpf_exit' insn.
@@ -197,22 +199,6 @@ static const char * const reg_type_str[] = {
 	[PTR_TO_PACKET_END]	= "pkt_end",
 };
 
-#define __BPF_FUNC_STR_FN(x) [BPF_FUNC_ ## x] = __stringify(bpf_ ## x)
-static const char * const func_id_str[] = {
-	__BPF_FUNC_MAPPER(__BPF_FUNC_STR_FN)
-};
-#undef __BPF_FUNC_STR_FN
-
-static const char *func_id_name(int id)
-{
-	BUILD_BUG_ON(ARRAY_SIZE(func_id_str) != __BPF_FUNC_MAX_ID);
-
-	if (id >= 0 && id < __BPF_FUNC_MAX_ID && func_id_str[id])
-		return func_id_str[id];
-	else
-		return "unknown";
-}
-
 static void print_verifier_state(struct bpf_verifier_state *state)
 {
 	struct bpf_reg_state *reg;
@@ -280,186 +266,6 @@ static void print_verifier_state(struct bpf_verifier_state *state)
 	verbose("\n");
 }
 
-static const char *const bpf_class_string[] = {
-	[BPF_LD]    = "ld",
-	[BPF_LDX]   = "ldx",
-	[BPF_ST]    = "st",
-	[BPF_STX]   = "stx",
-	[BPF_ALU]   = "alu",
-	[BPF_JMP]   = "jmp",
-	[BPF_RET]   = "BUG",
-	[BPF_ALU64] = "alu64",
-};
-
-static const char *const bpf_alu_string[16] = {
-	[BPF_ADD >> 4]  = "+=",
-	[BPF_SUB >> 4]  = "-=",
-	[BPF_MUL >> 4]  = "*=",
-	[BPF_DIV >> 4]  = "/=",
-	[BPF_OR  >> 4]  = "|=",
-	[BPF_AND >> 4]  = "&=",
-	[BPF_LSH >> 4]  = "<<=",
-	[BPF_RSH >> 4]  = ">>=",
-	[BPF_NEG >> 4]  = "neg",
-	[BPF_MOD >> 4]  = "%=",
-	[BPF_XOR >> 4]  = "^=",
-	[BPF_MOV >> 4]  = "=",
-	[BPF_ARSH >> 4] = "s>>=",
-	[BPF_END >> 4]  = "endian",
-};
-
-static const char *const bpf_ldst_string[] = {
-	[BPF_W >> 3]  = "u32",
-	[BPF_H >> 3]  = "u16",
-	[BPF_B >> 3]  = "u8",
-	[BPF_DW >> 3] = "u64",
-};
-
-static const char *const bpf_jmp_string[16] = {
-	[BPF_JA >> 4]   = "jmp",
-	[BPF_JEQ >> 4]  = "==",
-	[BPF_JGT >> 4]  = ">",
-	[BPF_JLT >> 4]  = "<",
-	[BPF_JGE >> 4]  = ">=",
-	[BPF_JLE >> 4]  = "<=",
-	[BPF_JSET >> 4] = "&",
-	[BPF_JNE >> 4]  = "!=",
-	[BPF_JSGT >> 4] = "s>",
-	[BPF_JSLT >> 4] = "s<",
-	[BPF_JSGE >> 4] = "s>=",
-	[BPF_JSLE >> 4] = "s<=",
-	[BPF_CALL >> 4] = "call",
-	[BPF_EXIT >> 4] = "exit",
-};
-
-static void print_bpf_end_insn(const struct bpf_verifier_env *env,
-			       const struct bpf_insn *insn)
-{
-	verbose("(%02x) r%d = %s%d r%d\n", insn->code, insn->dst_reg,
-		BPF_SRC(insn->code) == BPF_TO_BE ? "be" : "le",
-		insn->imm, insn->dst_reg);
-}
-
-static void print_bpf_insn(const struct bpf_verifier_env *env,
-			   const struct bpf_insn *insn)
-{
-	u8 class = BPF_CLASS(insn->code);
-
-	if (class == BPF_ALU || class == BPF_ALU64) {
-		if (BPF_OP(insn->code) == BPF_END) {
-			if (class == BPF_ALU64)
-				verbose("BUG_alu64_%02x\n", insn->code);
-			else
-				print_bpf_end_insn(env, insn);
-		} else if (BPF_OP(insn->code) == BPF_NEG) {
-			verbose("(%02x) r%d = %s-r%d\n",
-				insn->code, insn->dst_reg,
-				class == BPF_ALU ? "(u32) " : "",
-				insn->dst_reg);
-		} else if (BPF_SRC(insn->code) == BPF_X) {
-			verbose("(%02x) %sr%d %s %sr%d\n",
-				insn->code, class == BPF_ALU ? "(u32) " : "",
-				insn->dst_reg,
-				bpf_alu_string[BPF_OP(insn->code) >> 4],
-				class == BPF_ALU ? "(u32) " : "",
-				insn->src_reg);
-		} else {
-			verbose("(%02x) %sr%d %s %s%d\n",
-				insn->code, class == BPF_ALU ? "(u32) " : "",
-				insn->dst_reg,
-				bpf_alu_string[BPF_OP(insn->code) >> 4],
-				class == BPF_ALU ? "(u32) " : "",
-				insn->imm);
-		}
-	} else if (class == BPF_STX) {
-		if (BPF_MODE(insn->code) == BPF_MEM)
-			verbose("(%02x) *(%s *)(r%d %+d) = r%d\n",
-				insn->code,
-				bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
-				insn->dst_reg,
-				insn->off, insn->src_reg);
-		else if (BPF_MODE(insn->code) == BPF_XADD)
-			verbose("(%02x) lock *(%s *)(r%d %+d) += r%d\n",
-				insn->code,
-				bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
-				insn->dst_reg, insn->off,
-				insn->src_reg);
-		else
-			verbose("BUG_%02x\n", insn->code);
-	} else if (class == BPF_ST) {
-		if (BPF_MODE(insn->code) != BPF_MEM) {
-			verbose("BUG_st_%02x\n", insn->code);
-			return;
-		}
-		verbose("(%02x) *(%s *)(r%d %+d) = %d\n",
-			insn->code,
-			bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
-			insn->dst_reg,
-			insn->off, insn->imm);
-	} else if (class == BPF_LDX) {
-		if (BPF_MODE(insn->code) != BPF_MEM) {
-			verbose("BUG_ldx_%02x\n", insn->code);
-			return;
-		}
-		verbose("(%02x) r%d = *(%s *)(r%d %+d)\n",
-			insn->code, insn->dst_reg,
-			bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
-			insn->src_reg, insn->off);
-	} else if (class == BPF_LD) {
-		if (BPF_MODE(insn->code) == BPF_ABS) {
-			verbose("(%02x) r0 = *(%s *)skb[%d]\n",
-				insn->code,
-				bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
-				insn->imm);
-		} else if (BPF_MODE(insn->code) == BPF_IND) {
-			verbose("(%02x) r0 = *(%s *)skb[r%d + %d]\n",
-				insn->code,
-				bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
-				insn->src_reg, insn->imm);
-		} else if (BPF_MODE(insn->code) == BPF_IMM &&
-			   BPF_SIZE(insn->code) == BPF_DW) {
-			/* At this point, we already made sure that the second
-			 * part of the ldimm64 insn is accessible.
-			 */
-			u64 imm = ((u64)(insn + 1)->imm << 32) | (u32)insn->imm;
-			bool map_ptr = insn->src_reg == BPF_PSEUDO_MAP_FD;
-
-			if (map_ptr && !env->allow_ptr_leaks)
-				imm = 0;
-
-			verbose("(%02x) r%d = 0x%llx\n", insn->code,
-				insn->dst_reg, (unsigned long long)imm);
-		} else {
-			verbose("BUG_ld_%02x\n", insn->code);
-			return;
-		}
-	} else if (class == BPF_JMP) {
-		u8 opcode = BPF_OP(insn->code);
-
-		if (opcode == BPF_CALL) {
-			verbose("(%02x) call %s#%d\n", insn->code,
-				func_id_name(insn->imm), insn->imm);
-		} else if (insn->code == (BPF_JMP | BPF_JA)) {
-			verbose("(%02x) goto pc%+d\n",
-				insn->code, insn->off);
-		} else if (insn->code == (BPF_JMP | BPF_EXIT)) {
-			verbose("(%02x) exit\n", insn->code);
-		} else if (BPF_SRC(insn->code) == BPF_X) {
-			verbose("(%02x) if r%d %s r%d goto pc%+d\n",
-				insn->code, insn->dst_reg,
-				bpf_jmp_string[BPF_OP(insn->code) >> 4],
-				insn->src_reg, insn->off);
-		} else {
-			verbose("(%02x) if r%d %s 0x%x goto pc%+d\n",
-				insn->code, insn->dst_reg,
-				bpf_jmp_string[BPF_OP(insn->code) >> 4],
-				insn->imm, insn->off);
-		}
-	} else {
-		verbose("(%02x) %s\n", insn->code, bpf_class_string[class]);
-	}
-}
-
 static int pop_stack(struct bpf_verifier_env *env, int *prev_insn_idx)
 {
 	struct bpf_verifier_stack_elem *elem;
@@ -3693,7 +3499,7 @@ static int do_check(struct bpf_verifier_env *env)
 
 		if (log_level) {
 			verbose("%d: ", insn_idx);
-			print_bpf_insn(env, insn);
+			print_bpf_insn(verbose, insn, env->allow_ptr_leaks);
 		}
 
 		err = ext_analyzer_insn_hook(env, insn_idx, prev_insn_idx);
-- 
2.14.1
