From: Rabin Vincent <rabin@rab.in>
Subject: [PATCH] arm64: net: bpf: don't BUG() on large shifts
Date: Tue,  5 Jan 2016 18:39:03 +0100
Message-ID: <1452015543-6790-1-git-send-email-rabin@rab.in>
Cc: netdev@vger.kernel.org, zlim.lnx@gmail.com, yang.shi@linaro.org,
	will.deacon@arm.com, catalin.marinas@arm.com,
	linux-arm-kernel@lists.infradead.org, Rabin Vincent <rabin@rab.in>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:34690 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752133AbcAERjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 12:39:08 -0500
Received: by mail-wm0-f44.google.com with SMTP id u188so32120979wmu.1
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 09:39:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Attempting to generate UBFM/SBFM instructions with shifts that can't be
encoded in the immediate fields of the opcodes leads to a trigger of a
BUG() in the instruction generation code.  As the ARMv8 ARM says: "The
shift amounts must be in the range 0 to one less than the register width
of the instruction, inclusive."  Make the JIT reject unencodable shifts
instead of crashing.

 ------------[ cut here ]------------
 kernel BUG at arch/arm64/kernel/insn.c:766!
 Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
 CPU: 0 PID: 669 Comm: insmod Not tainted 4.4.0-rc8+ #4
 PC is at aarch64_insn_gen_bitfield+0xcc/0xd4
 LR is at build_body+0x1000/0x2914
 ..
 Call trace:
 [<ffffffc00008c65c>] aarch64_insn_gen_bitfield+0xcc/0xd4
 [<ffffffc000096bfc>] build_body+0x1000/0x2914
 [<ffffffc000098590>] bpf_int_jit_compile+0x7c/0x1b4
 [<ffffffc000130d10>] bpf_prog_select_runtime+0x20/0xcc
 [<ffffffc0004afbac>] bpf_prepare_filter+0x3d8/0x3e8
 [<ffffffc0004afc30>] bpf_prog_create+0x74/0xa4
 [<ffffffbffc3de1d4>] test_bpf_init+0x1d4/0x748 [test_bpf]
 [<ffffffc00008293c>] do_one_initcall+0x90/0x1a8
 [<ffffffc000140c4c>] do_init_module+0x60/0x1c8
 [<ffffffc00011bdcc>] load_module+0x1554/0x1c98
 [<ffffffc00011c62c>] SyS_init_module+0x11c/0x140
 [<ffffffc000085cb0>] el0_svc_naked+0x24/0x28

Signed-off-by: Rabin Vincent <rabin@rab.in>
---
 arch/arm64/net/bpf_jit_comp.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
index b162ad70effc..3f4f089a85c0 100644
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -255,6 +255,7 @@ static int build_insn(const struct bpf_insn *insn, struct jit_ctx *ctx)
 	const s32 imm = insn->imm;
 	const int i = insn - ctx->prog->insnsi;
 	const bool is64 = BPF_CLASS(code) == BPF_ALU64;
+	const int bits = is64 ? 64 : 32;
 	u8 jmp_cond;
 	s32 jmp_offset;
 
@@ -444,14 +445,20 @@ emit_bswap_uxt:
 		break;
 	case BPF_ALU | BPF_LSH | BPF_K:
 	case BPF_ALU64 | BPF_LSH | BPF_K:
+		if (imm < 0 || imm >= bits)
+			return -EINVAL;
 		emit(A64_LSL(is64, dst, dst, imm), ctx);
 		break;
 	case BPF_ALU | BPF_RSH | BPF_K:
 	case BPF_ALU64 | BPF_RSH | BPF_K:
+		if (imm < 0 || imm >= bits)
+			return -EINVAL;
 		emit(A64_LSR(is64, dst, dst, imm), ctx);
 		break;
 	case BPF_ALU | BPF_ARSH | BPF_K:
 	case BPF_ALU64 | BPF_ARSH | BPF_K:
+		if (imm < 0 || imm >= bits)
+			return -EINVAL;
 		emit(A64_ASR(is64, dst, dst, imm), ctx);
 		break;
 
-- 
2.6.4
