From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net] net: filter: initialize A and X registers
Date: Tue, 22 Apr 2014 20:18:57 -0700
Message-ID: <1398223137-5463-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:57776 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751154AbaDWDTC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 23:19:02 -0400
Received: by mail-pb0-f50.google.com with SMTP id md12so303122pbc.23
        for <netdev@vger.kernel.org>; Tue, 22 Apr 2014 20:19:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

exisiting BPF verifier allows uninitialized access to registers,
'ret A' is considered to be a valid filter.
So initialize A and X to zero to prevent leaking kernel memory
In the future BPF verifier will be rejecting such filters

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>
---
 net/core/filter.c |   16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index cd58614..9d79ca0 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -122,6 +122,13 @@ noinline u64 __bpf_call_base(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 	return 0;
 }
 
+/* Register mappings for user programs. */
+#define A_REG		0
+#define X_REG		7
+#define TMP_REG		8
+#define ARG2_REG	2
+#define ARG3_REG	3
+
 /**
  *	__sk_run_filter - run a filter on a given context
  *	@ctx: buffer to run the filter on
@@ -242,6 +249,8 @@ unsigned int __sk_run_filter(void *ctx, const struct sock_filter_int *insn)
 
 	regs[FP_REG]  = (u64) (unsigned long) &stack[ARRAY_SIZE(stack)];
 	regs[ARG1_REG] = (u64) (unsigned long) ctx;
+	regs[A_REG] = 0;
+	regs[X_REG] = 0;
 
 select_insn:
 	goto *jumptable[insn->code];
@@ -643,13 +652,6 @@ static u64 __get_raw_cpu_id(u64 ctx, u64 A, u64 X, u64 r4, u64 r5)
 	return raw_smp_processor_id();
 }
 
-/* Register mappings for user programs. */
-#define A_REG		0
-#define X_REG		7
-#define TMP_REG		8
-#define ARG2_REG	2
-#define ARG3_REG	3
-
 static bool convert_bpf_extensions(struct sock_filter *fp,
 				   struct sock_filter_int **insnp)
 {
-- 
1.7.9.5
