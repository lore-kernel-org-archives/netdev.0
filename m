From: Markos Chandras <markos.chandras@imgtec.com>
Subject: [PATCH 16/17] MIPS: bpf: Use 32 or 64-bit load instruction to load an address to register
Date: Mon, 23 Jun 2014 10:38:59 +0100
Message-ID: <1403516340-22997-17-git-send-email-markos.chandras@imgtec.com>
References: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Markos Chandras <markos.chandras@imgtec.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Alexei Starovoitov" <ast@plumgrid.com>, <netdev@vger.kernel.org>
To: <linux-mips@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:12059 "EHLO
	mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753182AbaFWJjo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 05:39:44 -0400
In-Reply-To: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When loading a pointer to a register we need to use the appropriate
32 or 64bit instruction to preserve the pointer's top 32bits.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>
---
 arch/mips/net/bpf_jit.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index 4920e0fd05ee..d8dba7b523a5 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -447,6 +447,17 @@ static inline void emit_wsbh(unsigned int dst, unsigned int src,
 	emit_instr(ctx, wsbh, dst, src);
 }
 
+/* load address to register */
+static inline void emit_load_addr(unsigned int dst, unsigned int src,
+				     int imm, struct jit_ctx *ctx)
+{
+	/* src contains the base addr of the 32/64-pointer */
+	if (config_enabled(CONFIG_64BIT))
+		emit_instr(ctx, ld, dst, imm, src);
+	else
+		emit_instr(ctx, lw, dst, imm, src);
+}
+
 /* load a function pointer to register */
 static inline void emit_load_func(unsigned int reg, ptr imm,
 				  struct jit_ctx *ctx)
@@ -1271,7 +1282,8 @@ jmp_cmp:
 			/* A = skb->dev->ifindex */
 			ctx->flags |= SEEN_SKB | SEEN_A | SEEN_S0;
 			off = offsetof(struct sk_buff, dev);
-			emit_load(r_s0, r_skb, off, ctx);
+			/* Load address of *dev member */
+			emit_load_addr(r_s0, r_skb, off, ctx);
 			/* error (0) in the delay slot */
 			emit_bcond(MIPS_COND_EQ, r_s0, r_zero,
 				   b_imm(prog->len, ctx), ctx);
-- 
2.0.0
