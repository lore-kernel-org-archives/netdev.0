From: Rabin Vincent <rabin@rab.in>
Subject: [PATCH] net: bpf: reject invalid shifts
Date: Tue, 12 Jan 2016 18:55:07 +0100
Message-ID: <1452621307-2213-1-git-send-email-rabin@rab.in>
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net,
	linux-arm-kernel@lists.infradead.org, Rabin Vincent <rabin@rab.in>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36633 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752252AbcALRzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 12:55:20 -0500
Received: by mail-wm0-f67.google.com with SMTP id l65so32586084wmf.3
        for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 09:55:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On ARM64, a BUG() is triggered in the eBPF JIT if a filter with a
constant shift that can't be encoded in the immediate field of the
UBFM/SBFM instructions is passed to the JIT.  Since these shifts
amounts, which are negative or >= regsize, are invalid, reject then in
the eBPF verifier and the classic BPF filter checker, for all
architectures.

Signed-off-by: Rabin Vincent <rabin@rab.in>
---
 kernel/bpf/verifier.c | 10 ++++++++++
 net/core/filter.c     |  5 +++++
 2 files changed, 15 insertions(+)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index a7945d10b378..3643df0dfaa9 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1121,6 +1121,16 @@ static int check_alu_op(struct verifier_env *env, struct bpf_insn *insn)
 			return -EINVAL;
 		}
 
+		if ((opcode == BPF_LSH || opcode == BPF_RSH) &&
+		    BPF_SRC(insn->code) == BPF_K) {
+			int size = BPF_CLASS(insn->code) == BPF_ALU64 ? 64 : 32;
+
+			if (insn->imm < 0 || insn->imm >= size) {
+				verbose("invalid shift %d\n", insn->imm);
+				return -EINVAL;
+			}
+		}
+
 		/* pattern match 'bpf_add Rx, imm' instruction */
 		if (opcode == BPF_ADD && BPF_CLASS(insn->code) == BPF_ALU64 &&
 		    regs[insn->dst_reg].type == FRAME_PTR &&
diff --git a/net/core/filter.c b/net/core/filter.c
index 672eefbfbe99..37157c4c1a78 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -777,6 +777,11 @@ static int bpf_check_classic(const struct sock_filter *filter,
 			if (ftest->k == 0)
 				return -EINVAL;
 			break;
+		case BPF_ALU | BPF_LSH | BPF_K:
+		case BPF_ALU | BPF_RSH | BPF_K:
+			if (ftest->k >= 32)
+				return -EINVAL;
+			break;
 		case BPF_LD | BPF_MEM:
 		case BPF_LDX | BPF_MEM:
 		case BPF_ST:
-- 
2.6.4
