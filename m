From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 1/9] bpf: free up BPF_JMP | BPF_CALL | BPF_X opcode
Date: Tue, 30 May 2017 13:31:27 -0700
Message-ID: <20170530203135.3642768-2-ast@fb.com>
References: <20170530203135.3642768-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:40213 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751088AbdE3Ubn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 16:31:43 -0400
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4UKSNkt025432
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 13:31:43 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2as25qa7wr-4
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 13:31:43 -0700
Received: from facebook.com (2401:db00:11:d082:face:0:5:0)      by
 mx-out.facebook.com (10.102.107.99) with ESMTP id
 fa1af26c457611e7b8d70002c99293a0-7dd206b0 for <netdev@vger.kernel.org>;        Tue,
 30 May 2017 13:31:36 -0700
In-Reply-To: <20170530203135.3642768-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

free up BPF_JMP | BPF_CALL | BPF_X opcode to be used by actual
indirect call by register and use kernel internal opcode to
mark call instruction into bpf_tail_call() helper.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 arch/arm64/net/bpf_jit_comp.c     | 2 +-
 arch/powerpc/net/bpf_jit_comp64.c | 2 +-
 arch/s390/net/bpf_jit_comp.c      | 2 +-
 arch/sparc/net/bpf_jit_comp_64.c  | 2 +-
 arch/x86/net/bpf_jit_comp.c       | 2 +-
 include/linux/filter.h            | 3 +++
 kernel/bpf/core.c                 | 2 +-
 kernel/bpf/verifier.c             | 2 +-
 8 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
index 71f930501ade..b1d38eeb24f6 100644
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -586,7 +586,7 @@ static int build_insn(const struct bpf_insn *insn, struct jit_ctx *ctx)
 		break;
 	}
 	/* tail call */
-	case BPF_JMP | BPF_CALL | BPF_X:
+	case BPF_JMP | BPF_TAIL_CALL:
 		if (emit_bpf_tail_call(ctx))
 			return -EFAULT;
 		break;
diff --git a/arch/powerpc/net/bpf_jit_comp64.c b/arch/powerpc/net/bpf_jit_comp64.c
index aee2bb817ac6..a01366584a4b 100644
--- a/arch/powerpc/net/bpf_jit_comp64.c
+++ b/arch/powerpc/net/bpf_jit_comp64.c
@@ -938,7 +938,7 @@ static int bpf_jit_build_body(struct bpf_prog *fp, u32 *image,
 		/*
 		 * Tail call
 		 */
-		case BPF_JMP | BPF_CALL | BPF_X:
+		case BPF_JMP | BPF_TAIL_CALL:
 			ctx->seen |= SEEN_TAILCALL;
 			bpf_jit_emit_tail_call(image, ctx, addrs[i + 1]);
 			break;
diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index 6e97a2e3fd8d..42ad3832586c 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -991,7 +991,7 @@ static noinline int bpf_jit_insn(struct bpf_jit *jit, struct bpf_prog *fp, int i
 		}
 		break;
 	}
-	case BPF_JMP | BPF_CALL | BPF_X:
+	case BPF_JMP | BPF_TAIL_CALL:
 		/*
 		 * Implicit input:
 		 *  B1: pointer to ctx
diff --git a/arch/sparc/net/bpf_jit_comp_64.c b/arch/sparc/net/bpf_jit_comp_64.c
index 21de77419f48..4a52d34facf9 100644
--- a/arch/sparc/net/bpf_jit_comp_64.c
+++ b/arch/sparc/net/bpf_jit_comp_64.c
@@ -1217,7 +1217,7 @@ static int build_insn(const struct bpf_insn *insn, struct jit_ctx *ctx)
 	}
 
 	/* tail call */
-	case BPF_JMP | BPF_CALL |BPF_X:
+	case BPF_JMP | BPF_TAIL_CALL:
 		emit_tail_call(ctx);
 		break;
 
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index f58939393eef..fec12eaa0dec 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -877,7 +877,7 @@ xadd:			if (is_imm8(insn->off))
 			}
 			break;
 
-		case BPF_JMP | BPF_CALL | BPF_X:
+		case BPF_JMP | BPF_TAIL_CALL:
 			emit_bpf_tail_call(&prog);
 			break;
 
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 62d948f80730..a20ba40fcb73 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -57,6 +57,9 @@ struct bpf_prog_aux;
 #define BPF_REG_AX		MAX_BPF_REG
 #define MAX_BPF_JIT_REG		(MAX_BPF_REG + 1)
 
+/* unused opcode to mark special call to bpf_tail_call() helper */
+#define BPF_TAIL_CALL	0xf0
+
 /* As per nm, we expose JITed images as text (code) section for
  * kallsyms. That way, tools like perf can find it to match
  * addresses.
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index dedf367f59bb..339289402b96 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -824,7 +824,7 @@ static unsigned int __bpf_prog_run(void *ctx, const struct bpf_insn *insn)
 		[BPF_ALU64 | BPF_NEG] = &&ALU64_NEG,
 		/* Call instruction */
 		[BPF_JMP | BPF_CALL] = &&JMP_CALL,
-		[BPF_JMP | BPF_CALL | BPF_X] = &&JMP_TAIL_CALL,
+		[BPF_JMP | BPF_TAIL_CALL] = &&JMP_TAIL_CALL,
 		/* Jumps */
 		[BPF_JMP | BPF_JA] = &&JMP_JA,
 		[BPF_JMP | BPF_JEQ | BPF_X] = &&JMP_JEQ_X,
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 339c8a1371de..28113d0e8e92 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -3469,7 +3469,7 @@ static int fixup_bpf_calls(struct bpf_verifier_env *env)
 			 * that doesn't support bpf_tail_call yet
 			 */
 			insn->imm = 0;
-			insn->code |= BPF_X;
+			insn->code = BPF_JMP | BPF_TAIL_CALL;
 			continue;
 		}
 
-- 
2.9.3
