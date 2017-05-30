From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 7/9] bpf: use different interpreter depending on required stack size
Date: Tue, 30 May 2017 13:31:33 -0700
Message-ID: <20170530203135.3642768-8-ast@fb.com>
References: <20170530203135.3642768-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:41235 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750952AbdE3Ubi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 16:31:38 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.20/8.16.0.20) with SMTP id v4UKQMlr005930
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 13:31:38 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 2asap7s4gn-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 13:31:38 -0700
Received: from facebook.com (2401:db00:11:d082:face:0:5:0)      by
 mx-out.facebook.com (10.103.99.97) with ESMTP  id
 fa4eb124457611e782f90002c9931860-db1348f0 for <netdev@vger.kernel.org>;        Tue,
 30 May 2017 13:31:36 -0700
In-Reply-To: <20170530203135.3642768-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

16 __bpf_prog_run() interpreters for various stack sizes add .text
but not a lot comparing to run-time stack savings

   text	   data	    bss	    dec	    hex	filename
  26350   10328     624   37302    91b6 kernel/bpf/core.o.before_split
  25777   10328     624   36729    8f79 kernel/bpf/core.o.after_split
  26970	  10328	    624	  37922	   9422	kernel/bpf/core.o.now

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/core.c | 40 +++++++++++++++++++++++++++++++---------
 1 file changed, 31 insertions(+), 9 deletions(-)

diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index abd410d394bc..774069ca18a7 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -1218,16 +1218,38 @@ static unsigned int ___bpf_prog_run(u64 *regs, const struct bpf_insn *insn,
 }
 STACK_FRAME_NON_STANDARD(___bpf_prog_run); /* jump table */
 
-static unsigned int __bpf_prog_run(void *ctx, const struct bpf_insn *insn)
-{
-	u64 stack[MAX_BPF_STACK / sizeof(u64)];
-	u64 regs[MAX_BPF_REG];
-
-	FP = (u64) (unsigned long) &stack[ARRAY_SIZE(stack)];
-	ARG1 = (u64) (unsigned long) ctx;
-	return ___bpf_prog_run(regs, insn, stack);
+#define PROG_NAME(stack_size) __bpf_prog_run##stack_size
+#define DEFINE_BPF_PROG_RUN(stack_size) \
+static unsigned int PROG_NAME(stack_size)(const void *ctx, const struct bpf_insn *insn) \
+{ \
+	u64 stack[stack_size / sizeof(u64)]; \
+	u64 regs[MAX_BPF_REG]; \
+\
+	FP = (u64) (unsigned long) &stack[ARRAY_SIZE(stack)]; \
+	ARG1 = (u64) (unsigned long) ctx; \
+	return ___bpf_prog_run(regs, insn, stack); \
 }
 
+#define EVAL1(FN, X) FN(X)
+#define EVAL2(FN, X, Y...) FN(X) EVAL1(FN, Y)
+#define EVAL3(FN, X, Y...) FN(X) EVAL2(FN, Y)
+#define EVAL4(FN, X, Y...) FN(X) EVAL3(FN, Y)
+#define EVAL5(FN, X, Y...) FN(X) EVAL4(FN, Y)
+#define EVAL6(FN, X, Y...) FN(X) EVAL5(FN, Y)
+
+EVAL6(DEFINE_BPF_PROG_RUN, 32, 64, 96, 128, 160, 192);
+EVAL6(DEFINE_BPF_PROG_RUN, 224, 256, 288, 320, 352, 384);
+EVAL4(DEFINE_BPF_PROG_RUN, 416, 448, 480, 512);
+
+#define PROG_NAME_LIST(stack_size) PROG_NAME(stack_size),
+
+static unsigned int (*interpreters[])(const void *ctx,
+				      const struct bpf_insn *insn) = {
+EVAL6(PROG_NAME_LIST, 32, 64, 96, 128, 160, 192)
+EVAL6(PROG_NAME_LIST, 224, 256, 288, 320, 352, 384)
+EVAL4(PROG_NAME_LIST, 416, 448, 480, 512)
+};
+
 bool bpf_prog_array_compatible(struct bpf_array *array,
 			       const struct bpf_prog *fp)
 {
@@ -1275,7 +1297,7 @@ static int bpf_check_tail_call(const struct bpf_prog *fp)
  */
 struct bpf_prog *bpf_prog_select_runtime(struct bpf_prog *fp, int *err)
 {
-	fp->bpf_func = (void *) __bpf_prog_run;
+	fp->bpf_func = interpreters[round_down(fp->aux->stack_depth, 32) / 32];
 
 	/* eBPF JITs can rewrite the program in case constant
 	 * blinding is active. However, in case of error during
-- 
2.9.3
