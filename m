From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC 05/12] nfp: add BPF to NFP code translator
Date: Wed,  1 Jun 2016 17:50:07 +0100
Message-ID: <1464799814-4453-6-git-send-email-jakub.kicinski@netronome.com>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
	dinan.gunawardena@netronome.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:38183 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932639AbcFAQvz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 12:51:55 -0400
Received: by mail-wm0-f44.google.com with SMTP id a20so35120076wma.1
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 09:51:54 -0700 (PDT)
In-Reply-To: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add translator for JITing eBPF to operations which
can be executed on NFP's programmable engines.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/Makefile      |   3 +-
 drivers/net/ethernet/netronome/nfp/nfp_asm.h     | 191 +++++
 drivers/net/ethernet/netronome/nfp/nfp_bpf.h     | 112 +++
 drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c | 937 +++++++++++++++++++++++
 4 files changed, 1242 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_asm.h
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_bpf.h
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c

diff --git a/drivers/net/ethernet/netronome/nfp/Makefile b/drivers/net/ethernet/netronome/nfp/Makefile
index 68178819ff12..46648404e750 100644
--- a/drivers/net/ethernet/netronome/nfp/Makefile
+++ b/drivers/net/ethernet/netronome/nfp/Makefile
@@ -3,6 +3,7 @@ obj-$(CONFIG_NFP_NETVF)	+= nfp_netvf.o
 nfp_netvf-objs := \
 	    nfp_net_common.o \
 	    nfp_net_ethtool.o \
-	    nfp_netvf_main.o
+	    nfp_netvf_main.o \
+	    nfp_bpf_jit.o
 
 nfp_netvf-$(CONFIG_NFP_NET_DEBUG) += nfp_net_debugfs.o
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_asm.h b/drivers/net/ethernet/netronome/nfp/nfp_asm.h
new file mode 100644
index 000000000000..8ea1c35665ee
--- /dev/null
+++ b/drivers/net/ethernet/netronome/nfp/nfp_asm.h
@@ -0,0 +1,191 @@
+/*
+ * Copyright (C) 2016 Netronome Systems, Inc.
+ *
+ * This software is dual licensed under the GNU General License Version 2,
+ * June 1991 as shown in the file COPYING in the top-level directory of this
+ * source tree or the BSD 2-Clause License provided below.  You have the
+ * option to license this software under the complete terms of either license.
+ *
+ * The BSD 2-Clause License:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      1. Redistributions of source code must retain the above
+ *         copyright notice, this list of conditions and the following
+ *         disclaimer.
+ *
+ *      2. Redistributions in binary form must reproduce the above
+ *         copyright notice, this list of conditions and the following
+ *         disclaimer in the documentation and/or other materials
+ *         provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#ifndef __NFP_ASM_H__
+#define __NFP_ASM_H__ 1
+
+#include "nfp_bpf.h"
+
+#define REG_NONE	0
+#define RE_REG_IMM(x)	(0x20 | ((x) & 0x1f) | (((x) & 0x60) << 1))
+#define RE_REG_IMM_MAX	0x07fULL
+#define RE_REG_NO_DST	0x20
+#define RE_REG_XFR	0x80
+#define UR_REG_IMM	0x300
+#define UR_REG_IMM_MAX	0x0ffULL
+#define UR_REG_NO_DST	0x300
+#define UR_REG_XFR	0x180
+
+#define OP_BR_BASE	0x0d800000020ULL
+#define OP_BR_BASE_MASK	0x0f8000c3ce0ULL
+#define OP_BR_MASK	0x0000000001fULL
+#define OP_BR_EV_PIP	0x00000000300ULL
+#define OP_BR_CSS	0x0000003c000ULL
+#define OP_BR_ADDR_LO	0x007ffc00000ULL
+#define OP_BR_ADDR_HI	0x10000000000ULL
+
+enum br_mask {
+	BR_BEQ = 0x00,
+	BR_BNE = 0x01,
+	BR_BHS = 0x04,
+	BR_BLO = 0x05,
+	BR_BGE = 0x08,
+	BR_UNC = 0x18,
+};
+
+enum br_ev_pip {
+	BR_EV_PIP_UNCOND = 0,
+	BR_EV_PIP_COND = 1,
+};
+
+enum br_ctx_signal_state {
+	BR_CSS_NONE = 2,
+};
+
+#define OP_IMMED_A_SRC	0x000000003ffULL
+#define OP_IMMED_B_SRC	0x000000ffc00ULL
+#define OP_IMMED_IMM	0x0000ff00000ULL
+#define OP_IMMED_WIDTH	0x00060000000ULL
+#define OP_IMMED_INV	0x00080000000ULL
+#define OP_IMMED_SHIFT	0x00600000000ULL
+#define OP_IMMED_BASE	0x0f000000000ULL
+#define OP_IMMED_WR_AB	0x20000000000ULL
+
+enum immed_width {
+	IMMED_WIDTH_ALL = 0,
+	IMMED_WIDTH_BYTE = 1,
+	IMMED_WIDTH_WORD = 2,
+};
+
+enum immed_shift {
+	IMMED_SHIFT_0B = 0,
+	IMMED_SHIFT_1B = 1,
+	IMMED_SHIFT_2B = 2,
+};
+
+#define OP_SHF_BASE	0x08000000000ULL
+#define OP_SHF_A_SRC	0x000000000ffULL
+#define OP_SHF_SC	0x00000000300ULL
+#define OP_SHF_B_SRC	0x0000003fc00ULL
+#define OP_SHF_I8	0x00000040000ULL
+#define OP_SHF_SW	0x00000080000ULL
+#define OP_SHF_DST	0x0000ff00000ULL
+#define OP_SHF_SHIFT	0x001f0000000ULL
+#define OP_SHF_OP	0x00e00000000ULL
+#define OP_SHF_DST_AB	0x01000000000ULL
+#define OP_SHF_WR_AB	0x20000000000ULL
+
+enum shf_op {
+	SHF_OP_NONE = 0,
+	SHF_OP_AND = 2,
+};
+
+enum shf_sc {
+	SHF_SC_R_ROT = 0,
+	SHF_SC_R_SHF = 1,
+	SHF_SC_L_SHF = 2,
+	SHF_SC_R_DSHF = 3,
+};
+
+#define OP_ALU_A_SRC	0x000000003ffULL
+#define OP_ALU_B_SRC	0x000000ffc00ULL
+#define OP_ALU_DST	0x0003ff00000ULL
+#define OP_ALU_SW	0x00040000000ULL
+#define OP_ALU_OP	0x00f80000000ULL
+#define OP_ALU_DST_AB	0x01000000000ULL
+#define OP_ALU_BASE	0x0a000000000ULL
+#define OP_ALU_WR_AB	0x20000000000ULL
+
+enum alu_op {
+	ALU_OP_NONE = 0x00,
+	ALU_OP_ADD = 0x01,
+	ALU_OP_AND = 0x08,
+	ALU_OP_SUB = 0x15,
+	ALU_OP_XOR = 0x18,
+};
+
+enum alu_dst_ab {
+	ALU_DST_A = 0,
+	ALU_DST_B = 1,
+};
+
+#define OP_CMD_A_SRC	 0x000000000ffULL
+#define OP_CMD_CTX	 0x00000000300ULL
+#define OP_CMD_B_SRC	 0x0000003fc00ULL
+#define OP_CMD_TOKEN	 0x000000c0000ULL
+#define OP_CMD_XFER	 0x00001f00000ULL
+#define OP_CMD_CNT	 0x0000e000000ULL
+#define OP_CMD_SIG	 0x000f0000000ULL
+#define OP_CMD_TGT_CMD	 0x07f00000000ULL
+#define OP_CMD_MODE	0x1c0000000000ULL
+
+struct cmd_tgt_act {
+	u8 token;
+	u8 tgt_cmd;
+};
+
+enum cmd_tgt_map {
+	CMD_TGT_READ8,
+	CMD_TGT_WRITE8,
+	CMD_TGT_READ_LE,
+	CMD_TGT_READ_SWAP_LE,
+	__CMD_TGT_MAP_SIZE,
+};
+
+enum cmd_mode {
+	CMD_MODE_40b_AB	= 0,
+	CMD_MODE_40b_BA	= 1,
+	CMD_MODE_32b	= 4,
+};
+
+enum cmd_ctx_swap {
+	CMD_CTX_SWAP = 0,
+	CMD_CTX_NO_SWAP = 3,
+};
+
+#define OP_LCSR_BASE	0x0fc00000000ULL
+#define OP_LCSR_A_SRC	0x000000003ffULL
+#define OP_LCSR_B_SRC	0x000000ffc00ULL
+#define OP_LCSR_WRITE	0x00000200000ULL
+#define OP_LCSR_ADDR	0x001ffc00000ULL
+
+enum lcsr_wr_src {
+	LCSR_WR_AREG,
+	LCSR_WR_BREG,
+	LCSR_WR_IMM,
+};
+
+#define OP_CARB_BASE	0x0e000000000ULL
+#define OP_CARB_OR	0x00000010000ULL
+
+#endif
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_bpf.h b/drivers/net/ethernet/netronome/nfp/nfp_bpf.h
new file mode 100644
index 000000000000..8fa9ff28ba80
--- /dev/null
+++ b/drivers/net/ethernet/netronome/nfp/nfp_bpf.h
@@ -0,0 +1,112 @@
+/*
+ * Copyright (C) 2016 Netronome Systems, Inc.
+ *
+ * This software is dual licensed under the GNU General License Version 2,
+ * June 1991 as shown in the file COPYING in the top-level directory of this
+ * source tree or the BSD 2-Clause License provided below.  You have the
+ * option to license this software under the complete terms of either license.
+ *
+ * The BSD 2-Clause License:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      1. Redistributions of source code must retain the above
+ *         copyright notice, this list of conditions and the following
+ *         disclaimer.
+ *
+ *      2. Redistributions in binary form must reproduce the above
+ *         copyright notice, this list of conditions and the following
+ *         disclaimer in the documentation and/or other materials
+ *         provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#ifndef __NFP_BPF_H__
+#define __NFP_BPF_H__ 1
+
+#include <linux/bitfield.h>
+#include <linux/bpf.h>
+#include <linux/list.h>
+#include <linux/types.h>
+
+#define FIT_FIELD(mask, val)  (!((((u64)val) << compile_ffs64(mask)) & ~(mask)))
+
+/* For branch fixup logic use up-most byte of branch instruction as scratch
+ * area.  Remember to clear this before sending instructions to HW!
+ */
+#define OP_BR_SPECIAL	0xff00000000000000ULL
+
+enum br_special {
+	OP_BR_NORMAL = 0,
+	OP_BR_GO_OUT,
+	OP_BR_GO_ABORT,
+};
+
+struct nfp_prog;
+struct nfp_insn_meta;
+typedef int (*instr_cb_t)(struct nfp_prog *, struct nfp_insn_meta *);
+
+/**
+ * struct nfp_insn_meta - BPF instruction wrapper
+ * @insn: BPF instruction
+ * @off: index of first generated machine instruction (in nfp_prog.prog)
+ * @skip: skip this instruction (optimized out)
+ * @double_cb: callback for second part of the instruction
+ * @l: link on nfp_prog->insns list
+ */
+struct nfp_insn_meta {
+	struct bpf_insn insn;
+	unsigned int off;
+	bool skip;
+	instr_cb_t double_cb;
+
+	struct list_head l;
+};
+
+/**
+ * struct nfp_prog - nfp BPF program
+ * @prog: machine code
+ * @prog_len: number of valid instructions in @prog array
+ * @__prog_alloc_len: alloc size of @prog array
+ * @start_off: address of the first instruction in the memory
+ * @tgt_out: jump target for normal exit
+ * @tgt_abort: jump target for abort (e.g. access outside of packet buffer)
+ * @n_translated: number of successfully translated instructions (for errors)
+ * @error: error code if something went wrong
+ * @insns: list of BPF instruction wrappers (struct nfp_insn_meta)
+ */
+struct nfp_prog {
+	u64 *prog;
+	unsigned int prog_len;
+	unsigned int __prog_alloc_len;
+
+	unsigned int start_off;
+	unsigned int tgt_out;
+	unsigned int tgt_abort;
+
+	unsigned int n_translated;
+	int error;
+
+	struct list_head insns;
+};
+
+struct nfp_bpf_result {
+	unsigned int n_instr;
+};
+
+int
+nfp_bpf_jit(struct bpf_prog *filter, void *prog, unsigned int prog_start,
+	    unsigned int tgt_out, unsigned int tgt_abort,
+	    unsigned int prog_sz, struct nfp_bpf_result *res);
+
+#endif
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c b/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
new file mode 100644
index 000000000000..d7eecfceba5c
--- /dev/null
+++ b/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
@@ -0,0 +1,937 @@
+/*
+ * Copyright (C) 2016 Netronome Systems, Inc.
+ *
+ * This software is dual licensed under the GNU General License Version 2,
+ * June 1991 as shown in the file COPYING in the top-level directory of this
+ * source tree or the BSD 2-Clause License provided below.  You have the
+ * option to license this software under the complete terms of either license.
+ *
+ * The BSD 2-Clause License:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      1. Redistributions of source code must retain the above
+ *         copyright notice, this list of conditions and the following
+ *         disclaimer.
+ *
+ *      2. Redistributions in binary form must reproduce the above
+ *         copyright notice, this list of conditions and the following
+ *         disclaimer in the documentation and/or other materials
+ *         provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include <linux/kernel.h>
+#include <linux/bpf.h>
+#include <linux/filter.h>
+#include <linux/unistd.h>
+
+#include "nfp_asm.h"
+#include "nfp_bpf.h"
+
+#define REG_PKT_N	31
+#define REG_PKT_BANK	ALU_DST_A
+#define REG_LEN_N	31
+#define REG_LEN_BANK	ALU_DST_B
+
+#define REG_IMM0_N	30 /* Bank AB */
+#define REG_QNUM	29 /* Bank AB */
+
+/* --- NFP prog --- */
+/* Foreach "multiple" entries macros provide pos and next<n> pointers.
+ * It's safe to modify the next pointers (but not pos).
+ */
+#define nfp_for_each_insn_walk2(nfp_prog, pos, next)			\
+	for (pos = list_first_entry(&(nfp_prog)->insns, typeof(*pos), l), \
+	     next = list_next_entry(pos, l);			\
+	     &(nfp_prog)->insns != &pos->l &&			\
+	     &(nfp_prog)->insns != &next->l;			\
+	     pos = nfp_meta_next(pos),				\
+	     next = nfp_meta_next(pos))
+
+#define nfp_for_each_insn_walk3(nfp_prog, pos, next, next2)		\
+	for (pos = list_first_entry(&(nfp_prog)->insns, typeof(*pos), l), \
+	     next = list_next_entry(pos, l),			\
+	     next2 = list_next_entry(next, l);			\
+	     &(nfp_prog)->insns != &pos->l &&			\
+	     &(nfp_prog)->insns != &next->l &&			\
+	     &(nfp_prog)->insns != &next2->l;			\
+	     pos = nfp_meta_next(pos),				\
+	     next = nfp_meta_next(pos),				\
+	     next2 = nfp_meta_next(next))
+
+#define nfp_meta_next(meta)	list_next_entry(meta, l)
+#define nfp_meta_prev(meta)	list_prev_entry(meta, l)
+
+static bool
+nfp_meta_has_next(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return meta->l.next != &nfp_prog->insns;
+}
+
+static bool
+nfp_meta_has_prev(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return meta->l.prev != &nfp_prog->insns;
+}
+
+static void nfp_prog_free(struct nfp_prog *nfp_prog)
+{
+	struct nfp_insn_meta *meta, *tmp;
+
+	list_for_each_entry_safe(meta, tmp, &nfp_prog->insns, l) {
+		list_del(&meta->l);
+		kfree(meta);
+	}
+	kfree(nfp_prog);
+}
+
+static struct nfp_insn_meta *
+nfp_prog_new_instr(struct nfp_prog *nfp_prog, const struct bpf_insn *insn)
+{
+	struct nfp_insn_meta *meta;
+
+	meta = kzalloc(sizeof(*meta), GFP_KERNEL);
+	if (!meta)
+		return NULL;
+
+	meta->insn = *insn;
+
+	list_add_tail(&meta->l, &nfp_prog->insns);
+
+	return meta;
+}
+
+static void nfp_prog_push(struct nfp_prog *nfp_prog, u64 insn)
+{
+	if (nfp_prog->__prog_alloc_len == nfp_prog->prog_len) {
+		nfp_prog->error = -ENOSPC;
+		return;
+	}
+
+	nfp_prog->prog[nfp_prog->prog_len] = insn;
+	nfp_prog->prog_len++;
+}
+
+static unsigned int nfp_prog_current_offset(struct nfp_prog *nfp_prog)
+{
+	return nfp_prog->start_off + nfp_prog->prog_len;
+}
+
+static unsigned int
+nfp_prog_offset_to_index(struct nfp_prog *nfp_prog, unsigned int offset)
+{
+	return offset - nfp_prog->start_off;
+}
+
+/* --- Emitters --- */
+static const struct cmd_tgt_act cmd_tgt_act[__CMD_TGT_MAP_SIZE] = {
+	[CMD_TGT_WRITE8] =		{ 0x00, 0x42 },
+	[CMD_TGT_READ8] =		{ 0x01, 0x43 },
+	[CMD_TGT_READ_LE] =		{ 0x01, 0x40 },
+	[CMD_TGT_READ_SWAP_LE] =	{ 0x03, 0x40 },
+};
+
+static void
+__emit_cmd(struct nfp_prog *nfp_prog, enum cmd_tgt_map op,
+	   u8 mode, u8 xfer, u8 areg, u8 breg, u8 size, bool sync)
+{
+	enum cmd_ctx_swap ctx;
+	u64 insn;
+
+	if (sync)
+		ctx = CMD_CTX_SWAP;
+	else
+		ctx = CMD_CTX_NO_SWAP;
+
+	insn =	FIELD_PUT64(OP_CMD_A_SRC, areg) |
+		FIELD_PUT64(OP_CMD_CTX, ctx) |
+		FIELD_PUT64(OP_CMD_B_SRC, breg) |
+		FIELD_PUT64(OP_CMD_TOKEN, cmd_tgt_act[op].token) |
+		FIELD_PUT64(OP_CMD_XFER, xfer) |
+		FIELD_PUT64(OP_CMD_CNT, size) |
+		FIELD_PUT64(OP_CMD_SIG, sync) |
+		FIELD_PUT64(OP_CMD_TGT_CMD, cmd_tgt_act[op].tgt_cmd) |
+		FIELD_PUT64(OP_CMD_MODE, mode);
+
+	nfp_prog_push(nfp_prog, insn);
+}
+
+static void
+__emit_br(struct nfp_prog *nfp_prog, enum br_mask mask, enum br_ev_pip ev_pip,
+	  enum br_ctx_signal_state css, u16 addr)
+{
+	u16 addr_lo, addr_hi;
+	u64 insn;
+
+	addr_lo = addr & (OP_BR_ADDR_LO >> compile_ffs64(OP_BR_ADDR_LO));
+	addr_hi = addr != addr_lo;
+
+	insn = OP_BR_BASE |
+		FIELD_PUT64(OP_BR_MASK, mask) |
+		FIELD_PUT64(OP_BR_EV_PIP, ev_pip) |
+		FIELD_PUT64(OP_BR_CSS, css) |
+		FIELD_PUT64(OP_BR_ADDR_LO, addr_lo) |
+		FIELD_PUT64(OP_BR_ADDR_HI, addr_hi);
+
+	nfp_prog_push(nfp_prog, insn);
+}
+
+static bool pack_immed(u32 imm, u16 *val, enum immed_shift *shift)
+{
+	if (!(imm & 0xffff0000)) {
+		*val = imm;
+		*shift = IMMED_SHIFT_0B;
+	} else if (!(imm & 0xff0000ff)) {
+		*val = imm >> 8;
+		*shift = IMMED_SHIFT_1B;
+	} else if (!(imm & 0x0000ffff)) {
+		*val = imm >> 16;
+		*shift = IMMED_SHIFT_2B;
+	} else {
+		return false;
+	}
+
+	return true;
+}
+
+static void
+__emit_immed(struct nfp_prog *nfp_prog, u8 dst, enum alu_dst_ab dst_ab,
+	     u32 imm, bool wr_both)
+{
+	enum immed_shift shift;
+	bool invert = false;
+	u16 areg, breg;
+	u64 insn;
+	u16 val;
+
+	if (!pack_immed(imm, &val, &shift)) {
+		if (!pack_immed(~imm, &val, &shift)) {
+			nfp_prog->error = -EFAULT; /* TODO */
+			return;
+		}
+		invert = true;
+	}
+
+	if (dst_ab == ALU_DST_A) {
+		areg = dst;
+		breg = UR_REG_IMM | (val & 0xff);
+	} else {
+		areg = UR_REG_IMM | (val & 0xff);
+		breg = dst;
+	}
+
+	insn = OP_IMMED_BASE |
+		FIELD_PUT64(OP_IMMED_A_SRC, areg) |
+		FIELD_PUT64(OP_IMMED_B_SRC, breg) |
+		FIELD_PUT64(OP_IMMED_IMM, (val >> 8) & 0xff) |
+		FIELD_PUT64(OP_IMMED_WIDTH, IMMED_WIDTH_ALL) |
+		FIELD_PUT64(OP_IMMED_INV, invert) |
+		FIELD_PUT64(OP_IMMED_SHIFT, shift) |
+		FIELD_PUT64(OP_IMMED_WR_AB, wr_both);
+
+	nfp_prog_push(nfp_prog, insn);
+}
+
+static void
+__emit_shf(struct nfp_prog *nfp_prog, u16 dst, enum alu_dst_ab dst_ab,
+	   enum shf_sc sc, u8 shift,
+	   u16 areg, enum shf_op op, u16 breg, bool sw, bool wr_both)
+{
+	u64 insn;
+
+	if (!FIT_FIELD(OP_SHF_SHIFT, shift)) {
+		nfp_prog->error = -EFAULT;
+		return;
+	}
+
+	if (sc == SHF_SC_L_SHF) {
+		shift = 32 - shift;
+	} else if (sc != SHF_SC_R_SHF) {
+		nfp_prog->error = -EFAULT; /* TODO */
+		return;
+	}
+
+	insn = OP_SHF_BASE |
+		FIELD_PUT64(OP_SHF_A_SRC, areg) |
+		FIELD_PUT64(OP_SHF_SC, sc) |
+		FIELD_PUT64(OP_SHF_B_SRC, breg) |
+		FIELD_PUT64(OP_SHF_SW, sw) |
+		FIELD_PUT64(OP_SHF_DST, dst) |
+		FIELD_PUT64(OP_SHF_SHIFT, shift) |
+		FIELD_PUT64(OP_SHF_OP, op) |
+		FIELD_PUT64(OP_SHF_DST_AB, dst_ab) |
+		FIELD_PUT64(OP_SHF_WR_AB, wr_both);
+
+	nfp_prog_push(nfp_prog, insn);
+}
+
+static void
+__emit_alu(struct nfp_prog *nfp_prog, u16 dst, enum alu_dst_ab dst_ab,
+	   u16 areg, enum alu_op op, u16 breg, bool swap, bool wr_both)
+{
+	u64 insn;
+
+	insn = OP_ALU_BASE |
+		FIELD_PUT64(OP_ALU_A_SRC, areg) |
+		FIELD_PUT64(OP_ALU_B_SRC, breg) |
+		FIELD_PUT64(OP_ALU_DST, dst) |
+		FIELD_PUT64(OP_ALU_SW, swap) |
+		FIELD_PUT64(OP_ALU_OP, op) |
+		FIELD_PUT64(OP_ALU_DST_AB, dst_ab) |
+		FIELD_PUT64(OP_ALU_WR_AB,	wr_both);
+
+	nfp_prog_push(nfp_prog, insn);
+}
+
+/* --- Wrappers --- */
+/* ur_load_imm_any() - encode immediate or use tmp register (unrestricted)
+ * If the @imm is small enough encode it directly in operand and return
+ * otherwise load @imm to a spare register and return its encoding.
+ */
+static u16
+ur_load_imm_any(struct nfp_prog *nfp_prog, u32 imm, u16 reg,
+		enum alu_dst_ab alu_dst)
+{
+	if (FIT_FIELD(UR_REG_IMM_MAX, imm))
+		return UR_REG_IMM | imm;
+
+	__emit_immed(nfp_prog, reg, alu_dst, imm, false);
+	return reg;
+}
+
+/* re_load_imm_any() - encode immediate or use tmp register (restricted)
+ * If the @imm is small enough encode it directly in operand and return
+ * otherwise load @imm to a spare register and return its encoding.
+ */
+static u16
+re_load_imm_any(struct nfp_prog *nfp_prog, u32 imm, u16 reg,
+		enum alu_dst_ab alu_dst)
+{
+	if (FIT_FIELD(RE_REG_IMM_MAX, imm))
+		return RE_REG_IMM(imm);
+
+	__emit_immed(nfp_prog, reg, alu_dst, imm, false);
+	return reg;
+}
+
+static void wrp_br(struct nfp_prog *nfp_prog, enum br_mask mask, u16 addr)
+{
+	__emit_br(nfp_prog, mask,
+		  mask != BR_UNC ? BR_EV_PIP_COND : BR_EV_PIP_UNCOND,
+		  BR_CSS_NONE, addr);
+}
+
+static void
+wrp_br_special(struct nfp_prog *nfp_prog, enum br_mask mask,
+	       enum br_special special)
+{
+	wrp_br(nfp_prog, mask, 0);
+
+	nfp_prog->prog[nfp_prog->prog_len - 1] |=
+		FIELD_PUT64(OP_BR_SPECIAL, special);
+}
+
+static void wrp_reg_mov(struct nfp_prog *nfp_prog, u16 dst, u16 src)
+{
+	__emit_alu(nfp_prog, dst, ALU_DST_A, REG_NONE, ALU_OP_NONE, src,
+		   false, true);
+}
+
+static void wrp_reg_xor(struct nfp_prog *nfp_prog, u16 dst, u16 src)
+{
+	__emit_alu(nfp_prog, dst, ALU_DST_A, dst, ALU_OP_XOR, src, false, true);
+}
+
+static int
+construct_data_ind_ld(struct nfp_prog *nfp_prog, u16 offset,
+		      u16 src, bool src_valid, u8 size)
+{
+	unsigned int i;
+	u16 shift, sz;
+	u16 imm_reg;
+
+	/* We load the value from the address indicated in @offset and then
+	 * shift out the data we don't need.  Note: this is big endian!
+	 */
+	sz = size < 4 ? 4 : size;
+	shift = size < 4 ? 4 - size : 0;
+
+	if (src_valid) {
+		/* Calculate the true offset (src_reg + imm) */
+		imm_reg = ur_load_imm_any(nfp_prog, offset,
+					  REG_IMM0_N, ALU_DST_B);
+		__emit_alu(nfp_prog, REG_IMM0_N, ALU_DST_A,
+			   src, ALU_OP_ADD, imm_reg, false, true);
+		/* Check packet length (size guaranteed to fit b/c it's u8) */
+		__emit_alu(nfp_prog, REG_IMM0_N, ALU_DST_A,
+			   REG_IMM0_N, ALU_OP_ADD, UR_REG_IMM | size,
+			   false, false);
+		__emit_alu(nfp_prog, UR_REG_NO_DST, ALU_DST_A,
+			   REG_IMM0_N, ALU_OP_SUB, REG_LEN_N, true, false);
+		wrp_br_special(nfp_prog, BR_BLO, OP_BR_GO_ABORT);
+		/* Load data */
+		__emit_cmd(nfp_prog, CMD_TGT_READ8, CMD_MODE_32b, 0,
+			   REG_PKT_N, REG_IMM0_N, sz - 1, true);
+	} else {
+		/* Check packet length */
+		imm_reg = ur_load_imm_any(nfp_prog, offset + size,
+					  REG_IMM0_N, ALU_DST_A);
+		__emit_alu(nfp_prog, UR_REG_NO_DST, ALU_DST_A,
+			   imm_reg, ALU_OP_SUB, REG_LEN_N, true, false);
+		wrp_br_special(nfp_prog, BR_BLO, OP_BR_GO_ABORT);
+		/* Load data */
+		imm_reg = re_load_imm_any(nfp_prog, offset,
+					  REG_IMM0_N, ALU_DST_B);
+		__emit_cmd(nfp_prog, CMD_TGT_READ8, CMD_MODE_32b, 0,
+			   REG_PKT_N, imm_reg, sz - 1, true);
+	}
+
+	i = 0;
+	if (shift)
+		__emit_shf(nfp_prog, 0, ALU_DST_A, SHF_SC_R_SHF, shift * 8,
+			   REG_NONE, SHF_OP_NONE, RE_REG_XFR | 0, false, true);
+	else
+		for (; i * 4 < size; i++)
+			wrp_reg_mov(nfp_prog, i, UR_REG_XFR | i);
+
+	if (i < 2)
+		__emit_immed(nfp_prog, 1, ALU_DST_A, 0, true);
+
+	return 0;
+}
+
+static int construct_data_ld(struct nfp_prog *nfp_prog, u16 offset, u8 size)
+{
+	return construct_data_ind_ld(nfp_prog, offset, 0, false, size);
+}
+
+static int
+construct_br_imm(struct nfp_prog *nfp_prog, u32 imm, u16 dst, u8 br, u16 off,
+		 enum alu_op alu_op, bool sw)
+{
+	u16 imm_reg;
+
+	imm_reg = ur_load_imm_any(nfp_prog, imm, REG_IMM0_N, ALU_DST_B);
+
+	__emit_alu(nfp_prog, UR_REG_NO_DST, ALU_DST_A,
+		   dst, alu_op, imm_reg, sw, false);
+	wrp_br(nfp_prog, br, off);
+
+	return 0;
+}
+
+static int
+wrp_jmp_imm(struct nfp_prog *nfp_prog, const struct bpf_insn *insn,
+	    enum br_mask mask, enum alu_op alu_op, bool sw)
+{
+	if (insn->off < 0) /* TODO */
+		return -ENOTSUPP;
+	construct_br_imm(nfp_prog, insn->imm, insn->dst_reg * 2,
+			 mask, insn->off, alu_op, sw);
+	return 0;
+}
+
+static int
+wrp_jmp_reg(struct nfp_prog *nfp_prog, const struct bpf_insn *insn,
+	    enum br_mask mask, enum alu_op alu_op, bool sw)
+{
+	if (insn->off < 0) /* TODO */
+		return -ENOTSUPP;
+	__emit_alu(nfp_prog, UR_REG_NO_DST, ALU_DST_A,
+		   insn->src_reg * 2, alu_op, insn->dst_reg * 2, sw, false);
+	wrp_br(nfp_prog, mask, insn->off);
+
+	return 0;
+}
+
+/* --- Callbacks --- */
+static int mov_reg64(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	const struct bpf_insn *insn = &meta->insn;
+
+	wrp_reg_mov(nfp_prog, insn->dst_reg * 2, insn->src_reg * 2);
+	wrp_reg_mov(nfp_prog, insn->dst_reg * 2 + 1, insn->src_reg * 2 + 1);
+
+	return 0;
+}
+
+static int xor_reg64(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	const struct bpf_insn *insn = &meta->insn;
+
+	wrp_reg_xor(nfp_prog, insn->dst_reg * 2, insn->src_reg * 2);
+	wrp_reg_xor(nfp_prog, insn->dst_reg * 2 + 1, insn->src_reg * 2 + 1);
+
+	return 0;
+}
+
+static int data_ld1(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return construct_data_ld(nfp_prog, meta->insn.imm, 1);
+}
+
+static int data_ld2(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return construct_data_ld(nfp_prog, meta->insn.imm, 2);
+}
+
+static int data_ld4(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return construct_data_ld(nfp_prog, meta->insn.imm, 4);
+}
+
+static int data_ind_ld1(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return construct_data_ind_ld(nfp_prog, meta->insn.imm,
+				     meta->insn.src_reg * 2, true, 1);
+}
+
+static int data_ind_ld2(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return construct_data_ind_ld(nfp_prog, meta->insn.imm,
+				     meta->insn.src_reg * 2, true, 2);
+}
+
+static int data_ind_ld4(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return construct_data_ind_ld(nfp_prog, meta->insn.imm,
+				     meta->insn.src_reg * 2, true, 4);
+}
+
+static int mem_ld4(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	if (meta->insn.off == offsetof(struct sk_buff, len))
+		__emit_alu(nfp_prog, meta->insn.dst_reg * 2, ALU_DST_A,
+			   REG_NONE, ALU_OP_NONE, REG_LEN_N, false, true);
+	else
+		return -ENOTSUPP;
+
+	return 0;
+}
+
+static int imm_ld8_part2(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	__emit_immed(nfp_prog, nfp_meta_prev(meta)->insn.dst_reg * 2 + 1,
+		     ALU_DST_A, meta->insn.imm, true);
+
+	return 0;
+}
+
+static int imm_ld8(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	const struct bpf_insn *insn = &meta->insn;
+
+	meta->double_cb = imm_ld8_part2;
+	__emit_immed(nfp_prog, insn->dst_reg * 2, ALU_DST_A, insn->imm, true);
+
+	return 0;
+}
+
+static int and_immX(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	const struct bpf_insn *insn = &meta->insn;
+	u16 imm_reg;
+
+	imm_reg = ur_load_imm_any(nfp_prog, insn->imm, REG_IMM0_N, ALU_DST_B);
+
+	__emit_alu(nfp_prog, insn->dst_reg * 2, ALU_DST_A,
+		   insn->dst_reg * 2, ALU_OP_AND, imm_reg, false, true);
+	/* Zero the upper part - imm is just 32b */
+	if (BPF_CLASS(insn->code) == BPF_ALU64)
+		__emit_immed(nfp_prog, insn->dst_reg * 2 + 1,
+			     ALU_DST_A, 0, true);
+
+	return 0;
+}
+
+static int shl_imm32(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	const struct bpf_insn *insn = &meta->insn;
+
+	__emit_shf(nfp_prog, insn->dst_reg * 2, ALU_DST_A,
+		   SHF_SC_L_SHF, insn->imm,
+		   REG_NONE, SHF_OP_NONE, insn->dst_reg * 2, false, true);
+
+	return 0;
+}
+
+static int mov_imm(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	const struct bpf_insn *insn = &meta->insn;
+
+	__emit_immed(nfp_prog, insn->dst_reg * 2, ALU_DST_A, insn->imm, true);
+	/* We need to zero-extend the movs according to ABI */
+	__emit_immed(nfp_prog, insn->dst_reg * 2 + 1, ALU_DST_A, 0, true);
+
+	return 0;
+}
+
+/* Note to self - 'ja' is unconditional jump in BPF speak, not Jump Above... */
+static int ja_imm(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	if (meta->insn.off < 0) /* TODO */
+		return -ENOTSUPP;
+	wrp_br(nfp_prog, BR_UNC, meta->insn.off);
+
+	return 0;
+}
+
+static int jeq_imm(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return wrp_jmp_imm(nfp_prog, &meta->insn, BR_BEQ, ALU_OP_SUB, false);
+}
+
+static int jgt_imm(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return wrp_jmp_imm(nfp_prog, &meta->insn, BR_BLO, ALU_OP_SUB, false);
+}
+
+static int jge_imm(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return wrp_jmp_imm(nfp_prog, &meta->insn, BR_BHS, ALU_OP_SUB, true);
+}
+
+static int jset_imm(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return wrp_jmp_imm(nfp_prog, &meta->insn, BR_BNE, ALU_OP_AND, false);
+}
+
+static int jne_imm(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return wrp_jmp_imm(nfp_prog, &meta->insn, BR_BNE, ALU_OP_SUB, false);
+}
+
+static int jeq_reg(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return wrp_jmp_reg(nfp_prog, &meta->insn, BR_BEQ, ALU_OP_SUB, false);
+}
+
+static int jgt_reg(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return wrp_jmp_reg(nfp_prog, &meta->insn, BR_BLO, ALU_OP_SUB, false);
+}
+
+static int jge_reg(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return wrp_jmp_reg(nfp_prog, &meta->insn, BR_BHS, ALU_OP_SUB, true);
+}
+
+static int jset_reg(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return wrp_jmp_reg(nfp_prog, &meta->insn, BR_BNE, ALU_OP_AND, false);
+}
+
+static int jne_reg(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return wrp_jmp_reg(nfp_prog, &meta->insn, BR_BNE, ALU_OP_SUB, false);
+}
+
+static int goto_out(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	wrp_br_special(nfp_prog, BR_UNC, OP_BR_GO_OUT);
+
+	return 0;
+}
+
+static const instr_cb_t instr_cb[256] = {
+	[BPF_ALU64 | BPF_MOV | BPF_X] =	mov_reg64,
+	[BPF_ALU64 | BPF_MOV | BPF_K] =	mov_imm, /* imm is always 32b */
+	[BPF_ALU64 | BPF_XOR | BPF_X] =	xor_reg64,
+	[BPF_ALU64 | BPF_AND | BPF_K] =	and_immX,
+	[BPF_ALU | BPF_MOV | BPF_K] =	mov_imm,
+	[BPF_ALU | BPF_AND | BPF_K] =	and_immX,
+	[BPF_ALU | BPF_LSH | BPF_K] =	shl_imm32,
+	[BPF_LDX | BPF_MEM | BPF_W] =	mem_ld4,
+	[BPF_LD | BPF_IMM | BPF_DW] =	imm_ld8,
+	[BPF_LD | BPF_ABS | BPF_B] =	data_ld1,
+	[BPF_LD | BPF_ABS | BPF_H] =	data_ld2,
+	[BPF_LD | BPF_ABS | BPF_W] =	data_ld4,
+	[BPF_LD | BPF_IND | BPF_B] =	data_ind_ld1,
+	[BPF_LD | BPF_IND | BPF_H] =	data_ind_ld2,
+	[BPF_LD | BPF_IND | BPF_W] =	data_ind_ld4,
+	[BPF_JMP | BPF_JA | BPF_K] =	ja_imm,
+	[BPF_JMP | BPF_JEQ | BPF_K] =	jeq_imm,
+	[BPF_JMP | BPF_JGT | BPF_K] =	jgt_imm,
+	[BPF_JMP | BPF_JGE | BPF_K] =	jge_imm,
+	[BPF_JMP | BPF_JSET | BPF_K] =	jset_imm,
+	[BPF_JMP | BPF_JNE | BPF_K] =	jne_imm,
+	[BPF_JMP | BPF_JEQ | BPF_X] =	jeq_reg,
+	[BPF_JMP | BPF_JGT | BPF_X] =	jgt_reg,
+	[BPF_JMP | BPF_JGE | BPF_X] =	jge_reg,
+	[BPF_JMP | BPF_JSET | BPF_X] =	jset_reg,
+	[BPF_JMP | BPF_JNE | BPF_X] =	jne_reg,
+	[BPF_JMP | BPF_EXIT] =		goto_out,
+};
+
+/* --- Misc code --- */
+static void br_set_offset(u64 *instr, u16 offset)
+{
+	u16 addr_lo, addr_hi;
+
+	addr_lo = offset & (OP_BR_ADDR_LO >> compile_ffs64(OP_BR_ADDR_LO));
+	addr_hi = offset != addr_lo;
+	*instr &= ~(OP_BR_ADDR_HI | OP_BR_ADDR_LO);
+	*instr |= FIELD_PUT64(OP_BR_ADDR_HI, addr_hi);
+	*instr |= FIELD_PUT64(OP_BR_ADDR_LO, addr_lo);
+}
+
+/* --- Assembler logic --- */
+static int nfp_fixup_branches(struct nfp_prog *nfp_prog)
+{
+	struct nfp_insn_meta *meta, *next;
+	u32 off, br_idx;
+
+	nfp_for_each_insn_walk2(nfp_prog, meta, next) {
+		if (BPF_CLASS(meta->insn.code) != BPF_JMP)
+			continue;
+
+		br_idx = nfp_prog_offset_to_index(nfp_prog, next->off) - 1;
+		if ((nfp_prog->prog[br_idx] & OP_BR_BASE_MASK) != OP_BR_BASE) {
+			pr_err("Fixup found block not ending in branch %d %02x %016llx!!\n",
+			       br_idx, meta->insn.code, nfp_prog->prog[br_idx]);
+			return -ELOOP;
+		}
+		/* Leave special branches for later */
+		if (FIELD_GET64(OP_BR_SPECIAL, nfp_prog->prog[br_idx]))
+			continue;
+
+		/* Find the target offset in assembler realm */
+		off = meta->insn.off;
+		if (!off) {
+			pr_err("Fixup found zero offset!!\n");
+			return -ELOOP;
+		}
+
+		while (off && nfp_meta_has_next(nfp_prog, next)) {
+			next = nfp_meta_next(next);
+			off--;
+		}
+		if (off) {
+			pr_err("Fixup found too large jump!! %d\n", off);
+			return -ELOOP;
+		}
+
+		if (next->skip) {
+			pr_err("Branch landing on removed instruction!!\n");
+			return -ELOOP;
+		}
+
+		br_set_offset(&nfp_prog->prog[br_idx], next->off);
+	}
+
+	/* Fixup 'goto out's separately, they can be scattered around */
+	for (br_idx = 0; br_idx < nfp_prog->prog_len; br_idx++) {
+		enum br_special special;
+
+		if ((nfp_prog->prog[br_idx] & OP_BR_BASE_MASK) != OP_BR_BASE)
+			continue;
+
+		special = FIELD_GET64(OP_BR_SPECIAL, nfp_prog->prog[br_idx]);
+		switch (special) {
+		case OP_BR_NORMAL:
+			break;
+		case OP_BR_GO_OUT:
+			br_set_offset(&nfp_prog->prog[br_idx],
+				      nfp_prog->tgt_out);
+			break;
+		case OP_BR_GO_ABORT:
+			br_set_offset(&nfp_prog->prog[br_idx],
+				      nfp_prog->tgt_abort);
+			break;
+		}
+
+		nfp_prog->prog[br_idx] &= ~OP_BR_SPECIAL;
+	}
+
+	return 0;
+}
+
+static int nfp_translate(struct nfp_prog *nfp_prog)
+{
+	struct nfp_insn_meta *meta;
+	int err;
+
+	list_for_each_entry(meta, &nfp_prog->insns, l) {
+		instr_cb_t cb = instr_cb[meta->insn.code];
+
+		meta->off = nfp_prog_current_offset(nfp_prog);
+
+		if (meta->skip) {
+			nfp_prog->n_translated++;
+			continue;
+		}
+
+		if (nfp_meta_has_prev(nfp_prog, meta) &&
+		    nfp_meta_prev(meta)->double_cb)
+			cb = nfp_meta_prev(meta)->double_cb;
+		if (!cb)
+			return -ENOENT;
+		err = cb(nfp_prog, meta);
+		if (err)
+			return err;
+
+		if (nfp_prog->error)
+			return nfp_prog->error;
+
+		nfp_prog->n_translated++;
+	}
+
+	return nfp_fixup_branches(nfp_prog);
+}
+
+static int
+nfp_prog_prepare(struct nfp_prog *nfp_prog, const struct bpf_insn *prog,
+		 unsigned int cnt)
+{
+	unsigned int i;
+
+	for (i = 0; i < cnt; i++)
+		if (!nfp_prog_new_instr(nfp_prog, prog + i))
+			return -ENOMEM;
+
+	return 0;
+}
+
+/* --- Optimizations --- */
+/* Remove masking after load since our load guarantees this is not needed */
+static void nfp_bpf_opt_ld_mask(struct nfp_prog *nfp_prog)
+{
+	struct nfp_insn_meta *meta1, *meta2;
+	const s32 exp_mask[] = {
+		[BPF_B] = 0x000000ffU,
+		[BPF_H] = 0x0000ffffU,
+		[BPF_W] = 0xffffffffU,
+	};
+
+	nfp_for_each_insn_walk2(nfp_prog, meta1, meta2) {
+		struct bpf_insn insn, next;
+
+		insn = meta1->insn;
+		next = meta2->insn;
+
+		if (BPF_CLASS(insn.code) != BPF_LD)
+			continue;
+		if (BPF_MODE(insn.code) != BPF_ABS &&
+		    BPF_MODE(insn.code) != BPF_IND)
+			continue;
+
+		if (next.code != (BPF_ALU64 | BPF_AND | BPF_K))
+			continue;
+
+		if (!exp_mask[BPF_SIZE(insn.code)])
+			continue;
+		if (exp_mask[BPF_SIZE(insn.code)] != next.imm)
+			continue;
+
+		if (next.src_reg || next.dst_reg)
+			continue;
+
+		meta2->skip = true;
+	}
+}
+
+static void nfp_bpf_opt_ld_shift(struct nfp_prog *nfp_prog)
+{
+	struct nfp_insn_meta *meta1, *meta2, *meta3;
+
+	nfp_for_each_insn_walk3(nfp_prog, meta1, meta2, meta3) {
+		struct bpf_insn insn, next1, next2;
+
+		insn = meta1->insn;
+		next1 = meta2->insn;
+		next2 = meta3->insn;
+
+		if (BPF_CLASS(insn.code) != BPF_LD)
+			continue;
+		if (BPF_MODE(insn.code) != BPF_ABS &&
+		    BPF_MODE(insn.code) != BPF_IND)
+			continue;
+		if (BPF_SIZE(insn.code) != BPF_W)
+			continue;
+
+		if (!(next1.code == (BPF_LSH | BPF_K | BPF_ALU64) &&
+		      next2.code == (BPF_RSH | BPF_K | BPF_ALU64)) &&
+		    !(next1.code == (BPF_RSH | BPF_K | BPF_ALU64) &&
+		      next2.code == (BPF_LSH | BPF_K | BPF_ALU64)))
+			continue;
+
+		if (next1.src_reg || next1.dst_reg ||
+		    next2.src_reg || next2.dst_reg)
+			continue;
+
+		if (next1.imm != 0x20 || next2.imm != 0x20)
+			continue;
+
+		meta2->skip = true;
+		meta3->skip = true;
+	}
+}
+
+static void nfp_bpf_optimize(struct nfp_prog *nfp_prog)
+{
+	nfp_bpf_opt_ld_mask(nfp_prog);
+	nfp_bpf_opt_ld_shift(nfp_prog);
+}
+
+/**
+ * nfp_bpf_jit() - translate BPF code into NFP assembly
+ * @filter:	kernel BPF filter struct
+ * @prog_mem:	memory to store assembler instructions
+ * @prog_start:	offset of the first instruction when loaded
+ * @tgt_out:	where to jump on clean exit
+ * @tgt_abort:	where to jump on abort (i.e. access beyond end of packet)
+ * @prog_sz:	size of @prog_mem in instructions
+ * @res:	achieved parameters of translation results
+ */
+int
+nfp_bpf_jit(struct bpf_prog *filter, void *prog_mem, unsigned int prog_start,
+	    unsigned int tgt_out, unsigned int tgt_abort,
+	    unsigned int prog_sz, struct nfp_bpf_result *res)
+{
+	struct nfp_prog *nfp_prog;
+	int ret;
+
+	/* TODO: maybe make this dependent on bpf_jit_enable? */
+
+	nfp_prog = kzalloc(sizeof(*nfp_prog), GFP_KERNEL);
+	if (!nfp_prog)
+		return -ENOMEM;
+
+	INIT_LIST_HEAD(&nfp_prog->insns);
+	nfp_prog->start_off = prog_start;
+	nfp_prog->tgt_out = tgt_out;
+	nfp_prog->tgt_abort = tgt_abort;
+
+	ret = nfp_prog_prepare(nfp_prog, filter->insnsi, filter->len);
+	if (ret)
+		goto out;
+
+	nfp_bpf_optimize(nfp_prog);
+
+	nfp_prog->prog = prog_mem;
+	nfp_prog->__prog_alloc_len = prog_sz;
+
+	ret = nfp_translate(nfp_prog);
+	if (ret) {
+		pr_err("Translation failed with error %d (translated: %u)\n",
+		       ret, nfp_prog->n_translated);
+		ret = -EINVAL;
+	}
+
+	res->n_instr = nfp_prog->prog_len;
+out:
+	nfp_prog_free(nfp_prog);
+
+	return ret;
+}
-- 
1.9.1
