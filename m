From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v2 5/5] net: filter: optimize BPF migration for ARG1/CTX handling
Date: Thu, 24 Apr 2014 08:45:27 +0200
Message-ID: <1398321927-8845-6-git-send-email-dborkman@redhat.com>
References: <1398321927-8845-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21245 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751919AbaDXGqB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2014 02:46:01 -0400
In-Reply-To: <1398321927-8845-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, at initial setup in __sk_run_filter() we initialize the
BPF stack's frame-pointer and CTX register. However, instead of the
CTX register, we initialize context to ARG1, and during user filter
migration we emit *always* an instruction that copies the content
from ARG1 over to CTX. ARG1 is needed in BPF_CALL instructions to
setup ctx; for user BPF filter ARG2 has A, and ARG3 X for call
emission. However, we nevertheless copy CTX over to ARG1 in these
cases for user migrated filters. We can spare us this extra interpreter
instruction and assign it during initial setup time.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
---
 net/core/filter.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index eada3d5..9744365 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -257,7 +257,10 @@ unsigned int __sk_run_filter(void *ctx, const struct sock_filter_int *insn)
 #define CONT_JMP ({ insn++; goto select_insn; })
 
 	FP = (u64) (unsigned long) &stack[ARRAY_SIZE(stack)];
-	ARG1 = (u64) (unsigned long) ctx;
+	CTX = (u64) (unsigned long) ctx;
+
+	/* Direct users expect arg1 to be filled already with ctx. */
+	ARG1 = CTX;
 
 	/* Register for user BPF programs need to be reset first. */
 	regs[BPF_REG_A] = 0;
@@ -896,13 +899,6 @@ do_pass:
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
