From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH] mips: bpf: Fix broken BPF_MOD
Date: Mon,  1 Dec 2014 12:57:02 +0300
Message-ID: <1417427822-12729-1-git-send-email-kda@linux-powerpc.org>
Cc: markos.chandras@imgtec.com, Denis Kirjanov <kda@linux-powerpc.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:52861 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752715AbaLAKAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2014 05:00:37 -0500
Received: by mail-la0-f45.google.com with SMTP id gq15so8514620lab.18
        for <netdev@vger.kernel.org>; Mon, 01 Dec 2014 02:00:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove optimize_div() from BPF_MOD | BPF_K case
since we don't know the dividend and fix the
emit_mod() by reading the mod operation result from HI register

Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
---
 arch/mips/net/bpf_jit.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index 9b55143..9fd6834 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -426,7 +426,7 @@ static inline void emit_mod(unsigned int dst, unsigned int src,
 		u32 *p = &ctx->target[ctx->idx];
 		uasm_i_divu(&p, dst, src);
 		p = &ctx->target[ctx->idx + 1];
-		uasm_i_mflo(&p, dst);
+		uasm_i_mfhi(&p, dst);
 	}
 	ctx->idx += 2; /* 2 insts */
 }
@@ -971,7 +971,7 @@ load_ind:
 			break;
 		case BPF_ALU | BPF_MOD | BPF_K:
 			/* A %= k */
-			if (k == 1 || optimize_div(&k)) {
+			if (k == 1) {
 				ctx->flags |= SEEN_A;
 				emit_jit_reg_move(r_A, r_zero, ctx);
 			} else {
-- 
1.7.10.4
