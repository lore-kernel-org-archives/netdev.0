From: Markos Chandras <markos.chandras@imgtec.com>
Subject: [PATCH v2 14/17] MIPS: bpf: Prevent kernel fall over for >=32bit shifts
Date: Wed, 25 Jun 2014 09:37:21 +0100
Message-ID: <1403685441-4858-1-git-send-email-markos.chandras@imgtec.com>
References: <53A811FA.5060502@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Markos Chandras <markos.chandras@imgtec.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Alexei Starovoitov" <ast@plumgrid.com>, <netdev@vger.kernel.org>
To: <linux-mips@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:42173 "EHLO
	mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753978AbaFYIhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 04:37:34 -0400
In-Reply-To: <53A811FA.5060502@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove BUG_ON() if the shift immediate is >=32 to avoid kernel crashes
due to malicious user input. If the shift immediate is >= 32,
we simply load the destination register with 0 since only
32-bit instructions are used by JIT so this will do the
correct thing even on MIPS64.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>
---
Changes since v1:
- For sa >=32, load destination register with zero instead of treating
the immediate as 31
---
 arch/mips/net/bpf_jit.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index 1bcd599d9971..9476e7f061a1 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -151,6 +151,8 @@ static inline int optimize_div(u32 *k)
 	return 0;
 }
 
+static inline void emit_jit_reg_move(ptr dst, ptr src, struct jit_ctx *ctx);
+
 /* Simply emit the instruction if the JIT memory space has been allocated */
 #define emit_instr(ctx, func, ...)			\
 do {							\
@@ -309,8 +311,11 @@ static inline void emit_sll(unsigned int dst, unsigned int src,
 			    unsigned int sa, struct jit_ctx *ctx)
 {
 	/* sa is 5-bits long */
-	BUG_ON(sa >= BIT(5));
-	emit_instr(ctx, sll, dst, src, sa);
+	if (sa >= BIT(5))
+		/* Shifting >= 32 results in zero */
+		emit_jit_reg_move(dst, r_zero, ctx);
+	else
+		emit_instr(ctx, sll, dst, src, sa);
 }
 
 static inline void emit_srlv(unsigned int dst, unsigned int src,
@@ -323,8 +328,11 @@ static inline void emit_srl(unsigned int dst, unsigned int src,
 			    unsigned int sa, struct jit_ctx *ctx)
 {
 	/* sa is 5-bits long */
-	BUG_ON(sa >= BIT(5));
-	emit_instr(ctx, srl, dst, src, sa);
+	if (sa >= BIT(5))
+		/* Shifting >= 32 results in zero */
+		emit_jit_reg_move(dst, r_zero, ctx);
+	else
+		emit_instr(ctx, srl, dst, src, sa);
 }
 
 static inline void emit_slt(unsigned int dst, unsigned int src1,
-- 
2.0.0
