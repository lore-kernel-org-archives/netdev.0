From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 8/9] bpf: change x86 JITed program stack layout
Date: Tue, 30 May 2017 13:31:34 -0700
Message-ID: <20170530203135.3642768-9-ast@fb.com>
References: <20170530203135.3642768-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:58117 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750871AbdE3Ubk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 16:31:40 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4UKQlWj009076
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 13:31:39 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 2asegy08ce-7
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 13:31:39 -0700
Received: from facebook.com (2401:db00:11:d082:face:0:5:0)      by
 mx-out.facebook.com (10.103.99.97) with ESMTP  id
 fa5781be457611e798ce0002c9931860-69b636b0 for <netdev@vger.kernel.org>;        Tue,
 30 May 2017 13:31:36 -0700
In-Reply-To: <20170530203135.3642768-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in order to JIT programs with different stack sizes we need to
make epilogue and exception path to be stack size independent,
hence move auxiliary stack space from the bottom of the stack
to the top of the stack.
Nice side effect is that JITed function prologue becomes shorter
due to imm8 offset encoding vs imm32.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 arch/x86/net/bpf_jit.S      | 20 +++++++---------
 arch/x86/net/bpf_jit_comp.c | 58 ++++++++++++++++++++++++---------------------
 2 files changed, 40 insertions(+), 38 deletions(-)

diff --git a/arch/x86/net/bpf_jit.S b/arch/x86/net/bpf_jit.S
index f2a7faf4706e..b33093f84528 100644
--- a/arch/x86/net/bpf_jit.S
+++ b/arch/x86/net/bpf_jit.S
@@ -19,9 +19,6 @@
  */
 #define SKBDATA	%r10
 #define SKF_MAX_NEG_OFF    $(-0x200000) /* SKF_LL_OFF from filter.h */
-#define MAX_BPF_STACK (512 /* from filter.h */ + \
-	32 /* space for rbx,r13,r14,r15 */ + \
-	8 /* space for skb_copy_bits */)
 
 #define FUNC(name) \
 	.globl name; \
@@ -66,7 +63,7 @@ FUNC(sk_load_byte_positive_offset)
 
 /* rsi contains offset and can be scratched */
 #define bpf_slow_path_common(LEN)		\
-	lea	-MAX_BPF_STACK + 32(%rbp), %rdx;\
+	lea	32(%rbp), %rdx;\
 	FRAME_BEGIN;				\
 	mov	%rbx, %rdi; /* arg1 == skb */	\
 	push	%r9;				\
@@ -83,14 +80,14 @@ FUNC(sk_load_byte_positive_offset)
 bpf_slow_path_word:
 	bpf_slow_path_common(4)
 	js	bpf_error
-	mov	- MAX_BPF_STACK + 32(%rbp),%eax
+	mov	32(%rbp),%eax
 	bswap	%eax
 	ret
 
 bpf_slow_path_half:
 	bpf_slow_path_common(2)
 	js	bpf_error
-	mov	- MAX_BPF_STACK + 32(%rbp),%ax
+	mov	32(%rbp),%ax
 	rol	$8,%ax
 	movzwl	%ax,%eax
 	ret
@@ -98,7 +95,7 @@ FUNC(sk_load_byte_positive_offset)
 bpf_slow_path_byte:
 	bpf_slow_path_common(1)
 	js	bpf_error
-	movzbl	- MAX_BPF_STACK + 32(%rbp),%eax
+	movzbl	32(%rbp),%eax
 	ret
 
 #define sk_negative_common(SIZE)				\
@@ -148,9 +145,10 @@ FUNC(sk_load_byte_negative_offset)
 bpf_error:
 # force a return 0 from jit handler
 	xor	%eax,%eax
-	mov	- MAX_BPF_STACK(%rbp),%rbx
-	mov	- MAX_BPF_STACK + 8(%rbp),%r13
-	mov	- MAX_BPF_STACK + 16(%rbp),%r14
-	mov	- MAX_BPF_STACK + 24(%rbp),%r15
+	mov	(%rbp),%rbx
+	mov	8(%rbp),%r13
+	mov	16(%rbp),%r14
+	mov	24(%rbp),%r15
+	add	$40, %rbp
 	leaveq
 	ret
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index fec12eaa0dec..c96dac838f3e 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -197,12 +197,11 @@ struct jit_context {
 #define BPF_MAX_INSN_SIZE	128
 #define BPF_INSN_SAFETY		64
 
-#define STACKSIZE \
-	(MAX_BPF_STACK + \
-	 32 /* space for rbx, r13, r14, r15 */ + \
+#define AUX_STACK_SPACE \
+	(32 /* space for rbx, r13, r14, r15 */ + \
 	 8 /* space for skb_copy_bits() buffer */)
 
-#define PROLOGUE_SIZE 48
+#define PROLOGUE_SIZE 37
 
 /* emit x64 prologue code for BPF program and check it's size.
  * bpf_tail_call helper will skip it while jumping into another program
@@ -215,13 +214,16 @@ static void emit_prologue(u8 **pprog)
 	EMIT1(0x55); /* push rbp */
 	EMIT3(0x48, 0x89, 0xE5); /* mov rbp,rsp */
 
-	/* sub rsp, STACKSIZE */
-	EMIT3_off32(0x48, 0x81, 0xEC, STACKSIZE);
+	/* sub rsp, MAX_BPF_STACK + AUX_STACK_SPACE */
+	EMIT3_off32(0x48, 0x81, 0xEC, MAX_BPF_STACK + AUX_STACK_SPACE);
+
+	/* sub rbp, AUX_STACK_SPACE */
+	EMIT4(0x48, 0x83, 0xED, AUX_STACK_SPACE);
 
 	/* all classic BPF filters use R6(rbx) save it */
 
-	/* mov qword ptr [rbp-X],rbx */
-	EMIT3_off32(0x48, 0x89, 0x9D, -STACKSIZE);
+	/* mov qword ptr [rbp+0],rbx */
+	EMIT4(0x48, 0x89, 0x5D, 0);
 
 	/* bpf_convert_filter() maps classic BPF register X to R7 and uses R8
 	 * as temporary, so all tcpdump filters need to spill/fill R7(r13) and
@@ -231,12 +233,12 @@ static void emit_prologue(u8 **pprog)
 	 * than synthetic ones. Therefore not worth adding complexity.
 	 */
 
-	/* mov qword ptr [rbp-X],r13 */
-	EMIT3_off32(0x4C, 0x89, 0xAD, -STACKSIZE + 8);
-	/* mov qword ptr [rbp-X],r14 */
-	EMIT3_off32(0x4C, 0x89, 0xB5, -STACKSIZE + 16);
-	/* mov qword ptr [rbp-X],r15 */
-	EMIT3_off32(0x4C, 0x89, 0xBD, -STACKSIZE + 24);
+	/* mov qword ptr [rbp+8],r13 */
+	EMIT4(0x4C, 0x89, 0x6D, 8);
+	/* mov qword ptr [rbp+16],r14 */
+	EMIT4(0x4C, 0x89, 0x75, 16);
+	/* mov qword ptr [rbp+24],r15 */
+	EMIT4(0x4C, 0x89, 0x7D, 24);
 
 	/* Clear the tail call counter (tail_call_cnt): for eBPF tail calls
 	 * we need to reset the counter to 0. It's done in two instructions,
@@ -246,8 +248,8 @@ static void emit_prologue(u8 **pprog)
 
 	/* xor eax, eax */
 	EMIT2(0x31, 0xc0);
-	/* mov qword ptr [rbp-X], rax */
-	EMIT3_off32(0x48, 0x89, 0x85, -STACKSIZE + 32);
+	/* mov qword ptr [rbp+32], rax */
+	EMIT4(0x48, 0x89, 0x45, 32);
 
 	BUILD_BUG_ON(cnt != PROLOGUE_SIZE);
 	*pprog = prog;
@@ -289,13 +291,13 @@ static void emit_bpf_tail_call(u8 **pprog)
 	/* if (tail_call_cnt > MAX_TAIL_CALL_CNT)
 	 *   goto out;
 	 */
-	EMIT2_off32(0x8B, 0x85, -STACKSIZE + 36); /* mov eax, dword ptr [rbp - 516] */
+	EMIT2_off32(0x8B, 0x85, 36);              /* mov eax, dword ptr [rbp + 36] */
 	EMIT3(0x83, 0xF8, MAX_TAIL_CALL_CNT);     /* cmp eax, MAX_TAIL_CALL_CNT */
 #define OFFSET2 36
 	EMIT2(X86_JA, OFFSET2);                   /* ja out */
 	label2 = cnt;
 	EMIT3(0x83, 0xC0, 0x01);                  /* add eax, 1 */
-	EMIT2_off32(0x89, 0x85, -STACKSIZE + 36); /* mov dword ptr [rbp - 516], eax */
+	EMIT2_off32(0x89, 0x85, 36);              /* mov dword ptr [rbp + 36], eax */
 
 	/* prog = array->ptrs[index]; */
 	EMIT4_off32(0x48, 0x8D, 0x84, 0xD6,       /* lea rax, [rsi + rdx * 8 + offsetof(...)] */
@@ -1036,15 +1038,17 @@ xadd:			if (is_imm8(insn->off))
 			seen_exit = true;
 			/* update cleanup_addr */
 			ctx->cleanup_addr = proglen;
-			/* mov rbx, qword ptr [rbp-X] */
-			EMIT3_off32(0x48, 0x8B, 0x9D, -STACKSIZE);
-			/* mov r13, qword ptr [rbp-X] */
-			EMIT3_off32(0x4C, 0x8B, 0xAD, -STACKSIZE + 8);
-			/* mov r14, qword ptr [rbp-X] */
-			EMIT3_off32(0x4C, 0x8B, 0xB5, -STACKSIZE + 16);
-			/* mov r15, qword ptr [rbp-X] */
-			EMIT3_off32(0x4C, 0x8B, 0xBD, -STACKSIZE + 24);
-
+			/* mov rbx, qword ptr [rbp+0] */
+			EMIT4(0x48, 0x8B, 0x5D, 0);
+			/* mov r13, qword ptr [rbp+8] */
+			EMIT4(0x4C, 0x8B, 0x6D, 8);
+			/* mov r14, qword ptr [rbp+16] */
+			EMIT4(0x4C, 0x8B, 0x75, 16);
+			/* mov r15, qword ptr [rbp+24] */
+			EMIT4(0x4C, 0x8B, 0x7D, 24);
+
+			/* add rbp, AUX_STACK_SPACE */
+			EMIT4(0x48, 0x83, 0xC5, AUX_STACK_SPACE);
 			EMIT1(0xC9); /* leave */
 			EMIT1(0xC3); /* ret */
 			break;
-- 
2.9.3
