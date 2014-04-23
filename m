From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 5/5] net: filter: optimize BPF migration for ARG1/CTX handling
Date: Wed, 23 Apr 2014 22:57:01 +0200
Message-ID: <1398286621-3591-6-git-send-email-dborkman@redhat.com>
References: <1398286621-3591-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16268 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932651AbaDWU5a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 16:57:30 -0400
In-Reply-To: <1398286621-3591-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, at initial setup in __sk_run_filter() we initialize the
BPF stack's frame-pointer and CTX register. However, instead of the
CTX register, we initialize context to ARG1, and during user filter
migration we emit *always* an instruction that copies the content
from ARG1 to CTX. ARG1 is needed in BPF_CALL instructions to setup
ctx, A, X for call emission. However, we nevertheless copy CTX over
to ARG1 in these cases. So all in all, we always emit one instruction
at BPF program beginning that should have actually been avoided to
spare this overhead.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
---
 net/core/filter.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index eada3d5..6fed231 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -62,7 +62,6 @@
 #define A	regs[insn->a_reg]
 #define X	regs[insn->x_reg]
 #define FP	regs[BPF_REG_FP]
-#define ARG1	regs[BPF_REG_ARG1]
 #define CTX	regs[BPF_REG_CTX]
 #define K	insn->imm
 
@@ -257,7 +256,7 @@ unsigned int __sk_run_filter(void *ctx, const struct sock_filter_int *insn)
 #define CONT_JMP ({ insn++; goto select_insn; })
 
 	FP = (u64) (unsigned long) &stack[ARRAY_SIZE(stack)];
-	ARG1 = (u64) (unsigned long) ctx;
+	CTX = (u64) (unsigned long) ctx;
 
 	/* Register for user BPF programs need to be reset first. */
 	regs[BPF_REG_A] = 0;
@@ -896,13 +895,6 @@ do_pass:
 	new_insn = new_prog;
 	fp = prog;
 
-	if (new_insn) {
-		new_insn->code = BPF_ALU64 | BPF_MOV | BPF_X;
-		new_insn->a_reg = BPF_REG_CTX;
-		new_insn->x_reg = BPF_REG_ARG1;
-	}
-	new_insn++;
-
 	for (i = 0; i < len; fp++, i++) {
 		struct sock_filter_int tmp_insns[6] = { };
 		struct sock_filter_int *insn = tmp_insns;
-- 
1.7.11.7
