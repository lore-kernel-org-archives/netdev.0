From: Markos Chandras <markos.chandras@imgtec.com>
Subject: [PATCH 12/17] MIPS: bpf: Fix is_range() semantics
Date: Mon, 23 Jun 2014 10:38:55 +0100
Message-ID: <1403516340-22997-13-git-send-email-markos.chandras@imgtec.com>
References: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Markos Chandras <markos.chandras@imgtec.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Alexei Starovoitov" <ast@plumgrid.com>, <netdev@vger.kernel.org>
To: <linux-mips@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:11403 "EHLO
	mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753020AbaFWJji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 05:39:38 -0400
In-Reply-To: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

is_range() was meant to check whether the number is within
the s16 range or not. However the return values and consumers expected
the exact opposite. We fix that by inverting the logic in the function
to return 'true' for < s16 and 'false' for > s16.

Reported-by: Alexei Starovoitov <ast@plumgrid.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>
---
 arch/mips/net/bpf_jit.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index 1d228d27d759..00c4c83972bb 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -166,9 +166,7 @@ do {							\
 /* Determine if immediate is within the 16-bit signed range */
 static inline bool is_range16(s32 imm)
 {
-	if (imm >= SBIT(15) || imm < -SBIT(15))
-		return true;
-	return false;
+	return !(imm >= SBIT(15) || imm < -SBIT(15));
 }
 
 static inline void emit_addu(unsigned int dst, unsigned int src1,
@@ -187,7 +185,7 @@ static inline void emit_load_imm(unsigned int dst, u32 imm, struct jit_ctx *ctx)
 {
 	if (ctx->target != NULL) {
 		/* addiu can only handle s16 */
-		if (is_range16(imm)) {
+		if (!is_range16(imm)) {
 			u32 *p = &ctx->target[ctx->idx];
 			uasm_i_lui(&p, r_tmp_imm, (s32)imm >> 16);
 			p = &ctx->target[ctx->idx + 1];
@@ -199,7 +197,7 @@ static inline void emit_load_imm(unsigned int dst, u32 imm, struct jit_ctx *ctx)
 	}
 	ctx->idx++;
 
-	if (is_range16(imm))
+	if (!is_range16(imm))
 		ctx->idx++;
 }
 
@@ -240,7 +238,7 @@ static inline void emit_daddiu(unsigned int dst, unsigned int src,
 static inline void emit_addiu(unsigned int dst, unsigned int src,
 			      u32 imm, struct jit_ctx *ctx)
 {
-	if (is_range16(imm)) {
+	if (!is_range16(imm)) {
 		emit_load_imm(r_tmp, imm, ctx);
 		emit_addu(dst, r_tmp, src, ctx);
 	} else {
@@ -347,7 +345,7 @@ static inline void emit_sltiu(unsigned dst, unsigned int src,
 			      unsigned int imm, struct jit_ctx *ctx)
 {
 	/* 16 bit immediate */
-	if (is_range16((s32)imm)) {
+	if (!is_range16((s32)imm)) {
 		emit_load_imm(r_tmp, imm, ctx);
 		emit_sltu(dst, src, r_tmp, ctx);
 	} else {
-- 
2.0.0
