From: Jan Seiffert <kaffeemonster@googlemail.com>
Subject: Re: [REGRESSION][PATCH] bpf_jit drops the ball on indirect negative
 mem references
Date: Fri, 30 Mar 2012 15:42:00 +0200
Message-ID: <4F75B828.3090705@googlemail.com>
References: <CAPwCz79wO=5zTZmCG+ePfRuEu-p_Vosi18bYZ-MVNZGOdbE3aQ@mail.gmail.com>   <1332965129.2325.12.camel@edumazet-glaptop>   <CAPwCz7_tnjq32duJSDj21LpRe5TFvGGszH4joQr1DGTjNd7GcA@mail.gmail.com>  <1332967172.2325.22.camel@edumazet-glaptop>  <4F744D58.3070009@googlemail.com> <1333098711.19659.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	<linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Matt Evans <matt@ozlabs.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from uhura.skim.hs-owl.de ([193.174.118.81]:40049 "EHLO
	uhura.skim.hs-owl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932832Ab2C3No0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2012 09:44:26 -0400
In-Reply-To: <1333098711.19659.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet schrieb:
> [snip]
> All these ".p2align 1" are noise for this patch.
>
> This should be done as separate patch, explaining the rationale.
>
> ...
Ok, i thought since you where concerned with the performance and
I'm touching this stuff anyway.
But you are right, can be done separately.
So gone.

> [snip]
>
> Please add the code for imm8 offsets as well ?
>
> if (is_imm8(K))
> 	EMIT3(0x8d, 0x73, K); /* lea imm8(%rbx),%esi */
> else
> 	EMIT2_off32(0x8d, 0xb3, K); /* lea imm32(%rbx),%esi */

Right, there is this imm8 form. I left it out because i never saw gas emit it
and totally forgot about it.
Your wish is my command. But since there is no EMIT2_off32 and introducing
it would mean additional cleanup noise, i stayed with two emits.

Do you know where i can ping the powerpc guys a little bit harder?

So here a v3 of the patch:

Consider the following test program:

#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <pcap-bpf.h>

#define die(x) do {perror(x); return 1;} while (0)
struct bpf_insn udp_filter[] = {
	/*   0 */ BPF_STMT(BPF_LDX|BPF_W|BPF_IMM, -1048576+(0)), /* leax	net[0] */
	/*   1 */ BPF_STMT(BPF_LD|BPF_B|BPF_IND, 0),             /* ldb	[x+0] */
	/*   2 */ BPF_STMT(BPF_RET|BPF_A, 0),                    /* ret	a */
};

int main(int argc, char *argv[])
{
	char buf[512];
	struct sockaddr_in addr;
	struct bpf_program prg;
	socklen_t addr_s;
	ssize_t res;
	int fd;

	addr.sin_family = AF_INET;
	addr.sin_port = htons(5000);
	addr.sin_addr.s_addr = 0;
	addr_s = sizeof(addr);
	prg.bf_len = sizeof(udp_filter)/sizeof(udp_filter[0]);
	prg.bf_insns = udp_filter;
	if(-1 == (fd = socket(AF_INET, SOCK_DGRAM, 0)))
		die("socket");
	if(-1 == bind(fd, (struct sockaddr *)&addr, sizeof(addr)))
		die("bind");
	if(-1 == setsockopt(fd, SOL_SOCKET, SO_ATTACH_FILTER, &prg, sizeof(prg)))
		die("setsockopt");
	res = recvfrom(fd, buf, sizeof(buf), 0, (struct sockaddr *)&addr, &addr_s);
	if(res != -1)
		printf("packet received: %zi bytes\n", res);
	else
		die("recvfrom");
	return 0;
}

when used with the bpf jit disabled works:
console 1 $ ./bpf
console 2 $ echo "hello" | nc -u localhost 5000
console 1: packet received: 6 bytes

When the bpf jit gets enabled (echo 100 >
/proc/sys/net/core/bpf_jit_enable) the same program stops working:
console 1 $ ./bpf
console 2 $ echo "hello" | nc -u localhost 5000
console 1:

The reason is that both jits (x86 and powerpc) do not handle negative
memory references like SKF_NET_OFF or SKF_LL_OFF, only the simple
ancillary data references are supported (by mapping to special
instructions).
In the case of an absolute reference, the jit aborts the translation
if a negative reference is seen, also a negative k on the indirect
load aborts the translation, but if X is negative to begin with, only
the error handler is reached at runtime which drops the whole packet.

I propose the following patch to fix this situation.
Lightly tested on x86, but the powerpc asm part is prop. wrong.

Signed-of-by: Jan Seiffert <kaffeemonster@googlemail.com>

diff --git a/arch/powerpc/net/bpf_jit.h b/arch/powerpc/net/bpf_jit.h
index af1ab5e..e9b57b3 100644
--- a/arch/powerpc/net/bpf_jit.h
+++ b/arch/powerpc/net/bpf_jit.h
@@ -49,6 +49,10 @@
  * Assembly helpers from arch/powerpc/net/bpf_jit.S:
  */
 extern u8 sk_load_word[], sk_load_half[], sk_load_byte[], sk_load_byte_msh[];
+extern u8 sk_load_word_positive_offset[], sk_load_half_positive_offset[];
+extern u8 sk_load_byte_positive_offset[], sk_load_byte_msh_positive_offset[];
+extern u8 sk_load_word_negative_offset[], sk_load_half_negative_offset[];
+extern u8 sk_load_byte_negative_offset[], sk_load_byte_msh_negative_offset[];
 
 #define FUNCTION_DESCR_SIZE	24
 
diff --git a/arch/powerpc/net/bpf_jit_64.S b/arch/powerpc/net/bpf_jit_64.S
index ff4506e..e590aa5 100644
--- a/arch/powerpc/net/bpf_jit_64.S
+++ b/arch/powerpc/net/bpf_jit_64.S
@@ -31,14 +31,13 @@
  * then branch directly to slow_path_XXX if required.  (In fact, could
  * load a spare GPR with the address of slow_path_generic and pass size
  * as an argument, making the call site a mtlr, li and bllr.)
- *
- * Technically, the "is addr < 0" check is unnecessary & slowing down
- * the ABS path, as it's statically checked on generation.
  */
 	.globl	sk_load_word
 sk_load_word:
 	cmpdi	r_addr, 0
-	blt	bpf_error
+	blt	bpf_slow_path_word_neg
+	.globl	sk_load_word_positive_offset
+sk_load_word_positive_offset:
 	/* Are we accessing past headlen? */
 	subi	r_scratch1, r_HL, 4
 	cmpd	r_scratch1, r_addr
@@ -51,7 +50,9 @@ sk_load_word:
 	.globl	sk_load_half
 sk_load_half:
 	cmpdi	r_addr, 0
-	blt	bpf_error
+	blt	bpf_slow_path_half_neg
+	.globl	sk_load_half_positive_offset
+sk_load_half_positive_offset:
 	subi	r_scratch1, r_HL, 2
 	cmpd	r_scratch1, r_addr
 	blt	bpf_slow_path_half
@@ -61,7 +62,9 @@ sk_load_half:
 	.globl	sk_load_byte
 sk_load_byte:
 	cmpdi	r_addr, 0
-	blt	bpf_error
+	blt	bpf_slow_path_byte_neg
+	.globl	sk_load_byte_positive_offset
+sk_load_byte_positive_offset:
 	cmpd	r_HL, r_addr
 	ble	bpf_slow_path_byte
 	lbzx	r_A, r_D, r_addr
@@ -69,22 +72,20 @@ sk_load_byte:
 
 /*
  * BPF_S_LDX_B_MSH: ldxb  4*([offset]&0xf)
- * r_addr is the offset value, already known positive
+ * r_addr is the offset value
  */
 	.globl sk_load_byte_msh
 sk_load_byte_msh:
+	cmpdi	r_addr, 0
+	blt	bpf_slow_path_byte_msh_neg
+	.globl sk_load_byte_msh_positive_offset
+sk_load_byte_msh_positive_offset:
 	cmpd	r_HL, r_addr
 	ble	bpf_slow_path_byte_msh
 	lbzx	r_X, r_D, r_addr
 	rlwinm	r_X, r_X, 2, 32-4-2, 31-2
 	blr
 
-bpf_error:
-	/* Entered with cr0 = lt */
-	li	r3, 0
-	/* Generated code will 'blt epilogue', returning 0. */
-	blr
-
 /* Call out to skb_copy_bits:
  * We'll need to back up our volatile regs first; we have
  * local variable space at r1+(BPF_PPC_STACK_BASIC).
@@ -136,3 +137,85 @@ bpf_slow_path_byte_msh:
 	lbz	r_X, BPF_PPC_STACK_BASIC+(2*8)(r1)
 	rlwinm	r_X, r_X, 2, 32-4-2, 31-2
 	blr
+
+/* Call out to bpf_internal_load_pointer_neg_helper:
+ * We'll need to back up our volatile regs first; we have
+ * local variable space at r1+(BPF_PPC_STACK_BASIC).
+ * Allocate a new stack frame here to remain ABI-compliant in
+ * stashing LR.
+ */
+#define sk_negative_common(SIZE)				\
+	mflr	r0;						\
+	std	r0, 16(r1);					\
+	/* R3 goes in parameter space of caller's frame */	\
+	std	r_skb, (BPF_PPC_STACKFRAME+48)(r1);		\
+	std	r_A, (BPF_PPC_STACK_BASIC+(0*8))(r1);		\
+	std	r_X, (BPF_PPC_STACK_BASIC+(1*8))(r1);		\
+	stdu	r1, -BPF_PPC_SLOWPATH_FRAME(r1);		\
+	/* R3 = r_skb, as passed */				\
+	mr	r4, r_addr;					\
+	li	r5, SIZE;					\
+	bl	bpf_internal_load_pointer_neg_helper;		\
+	/* R3 != 0 on success */				\
+	addi	r1, r1, BPF_PPC_SLOWPATH_FRAME;			\
+	ld	r0, 16(r1);					\
+	ld	r_A, (BPF_PPC_STACK_BASIC+(0*8))(r1);		\
+	ld	r_X, (BPF_PPC_STACK_BASIC+(1*8))(r1);		\
+	mtlr	r0;						\
+	cmpldi	r3, 0;						\
+	beq	bpf_error_slow;	/* cr0 = EQ */			\
+	mr	r_addr, r3;					\
+	ld	r_skb, (BPF_PPC_STACKFRAME+48)(r1);		\
+	/* Great success! */
+
+bpf_slow_path_word_neg:
+	lis     r_scratch1,-32	/* SKF_LL_OFF */
+	cmpd	r_addr, r_scratch1	/* addr < SKF_* */
+	blt	bpf_error	/* cr0 = LT */
+	.globl	sk_load_word_negative_offset
+sk_load_word_negative_offset:
+	sk_negative_common(4)
+	lwz	r_A, 0(r_addr)
+	blr
+
+bpf_slow_path_half_neg:
+	lis     r_scratch1,-32	/* SKF_LL_OFF */
+	cmpd	r_addr, r_scratch1	/* addr < SKF_* */
+	blt	bpf_error	/* cr0 = LT */
+	.globl	sk_load_half_negative_offset
+sk_load_half_negative_offset:
+	sk_negative_common(2)
+	lhz	r_A, 0(r_addr)
+	blr
+
+bpf_slow_path_byte_neg:
+	lis     r_scratch1,-32	/* SKF_LL_OFF */
+	cmpd	r_addr, r_scratch1	/* addr < SKF_* */
+	blt	bpf_error	/* cr0 = LT */
+	.globl	sk_load_byte_negative_offset
+sk_load_byte_negative_offset:
+	sk_negative_common(1)
+	lbz	r_A, 0(r_addr)
+	blr
+
+bpf_slow_path_byte_msh_neg:
+	lis     r_scratch1,-32	/* SKF_LL_OFF */
+	cmpd	r_addr, r_scratch1	/* addr < SKF_* */
+	blt	bpf_error	/* cr0 = LT */
+	.globl	sk_load_byte_msh_negative_offset
+sk_load_byte_msh_negative_offset:
+	sk_negative_common(1)
+	lbz	r_X, 0(r_addr)
+	rlwinm	r_X, r_X, 2, 32-4-2, 31-2
+	blr
+
+bpf_error_slow:
+	/* fabricate a cr0 = lt */
+	li	r_scratch1, -1
+	cmpdi	r_scratch1, 0
+bpf_error:
+	/* Entered with cr0 = lt */
+	li	r3, 0
+	/* Generated code will 'blt epilogue', returning 0. */
+	blr
+
diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index 73619d3..2dc8b14 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -127,6 +127,9 @@ static void bpf_jit_build_epilogue(u32 *image, struct codegen_context *ctx)
 	PPC_BLR();
 }
 
+#define CHOOSE_LOAD_FUNC(K, func) \
+	((int)K < 0 ? ((int)K >= SKF_LL_OFF ? func##_negative_offset : func) : func##_positive_offset)
+
 /* Assemble the body code between the prologue & epilogue. */
 static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 			      struct codegen_context *ctx,
@@ -391,21 +394,16 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 
 			/*** Absolute loads from packet header/data ***/
 		case BPF_S_LD_W_ABS:
-			func = sk_load_word;
+			func = CHOOSE_LOAD_FUNC(K, sk_load_word);
 			goto common_load;
 		case BPF_S_LD_H_ABS:
-			func = sk_load_half;
+			func = CHOOSE_LOAD_FUNC(K, sk_load_half);
 			goto common_load;
 		case BPF_S_LD_B_ABS:
-			func = sk_load_byte;
+			func = CHOOSE_LOAD_FUNC(K, sk_load_byte);
 		common_load:
-			/*
-			 * Load from [K].  Reference with the (negative)
-			 * SKF_NET_OFF/SKF_LL_OFF offsets is unsupported.
-			 */
+			/* Load from [K]. */
 			ctx->seen |= SEEN_DATAREF;
-			if ((int)K < 0)
-				return -ENOTSUPP;
 			PPC_LI64(r_scratch1, func);
 			PPC_MTLR(r_scratch1);
 			PPC_LI32(r_addr, K);
@@ -429,7 +427,7 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 		common_load_ind:
 			/*
 			 * Load from [X + K].  Negative offsets are tested for
-			 * in the helper functions, and result in a 'ret 0'.
+			 * in the helper functions.
 			 */
 			ctx->seen |= SEEN_DATAREF | SEEN_XREG;
 			PPC_LI64(r_scratch1, func);
@@ -443,13 +441,7 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 			break;
 
 		case BPF_S_LDX_B_MSH:
-			/*
-			 * x86 version drops packet (RET 0) when K<0, whereas
-			 * interpreter does allow K<0 (__load_pointer, special
-			 * ancillary data).  common_load returns ENOTSUPP if K<0,
-			 * so we fall back to interpreter & filter works.
-			 */
-			func = sk_load_byte_msh;
+			func = CHOOSE_LOAD_FUNC(K, sk_load_byte_msh);
 			goto common_load;
 			break;
 
diff --git a/arch/x86/net/bpf_jit.S b/arch/x86/net/bpf_jit.S
index 6687022..2897d7f 100644
--- a/arch/x86/net/bpf_jit.S
+++ b/arch/x86/net/bpf_jit.S
@@ -18,17 +18,17 @@
  * r9d : hlen = skb->len - skb->data_len
  */
 #define SKBDATA	%r8
-
-sk_load_word_ind:
-	.globl	sk_load_word_ind
-
-	add	%ebx,%esi	/* offset += X */
-#	test    %esi,%esi	/* if (offset < 0) goto bpf_error; */
-	js	bpf_error
+#define SKF_MAX_NEG_OFF    $(-0x200000) /* SKF_LL_OFF from filter.h */
 
 sk_load_word:
 	.globl	sk_load_word
 
+	test	%esi,%esi
+	js	bpf_slow_path_word_neg
+
+sk_load_word_positive_offset:
+	.globl	sk_load_word_positive_offset
+
 	mov	%r9d,%eax		# hlen
 	sub	%esi,%eax		# hlen - offset
 	cmp	$3,%eax
@@ -37,16 +37,15 @@ sk_load_word:
 	bswap   %eax  			/* ntohl() */
 	ret
 
-
-sk_load_half_ind:
-	.globl sk_load_half_ind
-
-	add	%ebx,%esi	/* offset += X */
-	js	bpf_error
-
 sk_load_half:
 	.globl	sk_load_half
 
+	test	%esi,%esi
+	js	bpf_slow_path_half_neg
+
+sk_load_half_positive_offset:
+	.globl	sk_load_half_positive_offset
+
 	mov	%r9d,%eax
 	sub	%esi,%eax		#	hlen - offset
 	cmp	$1,%eax
@@ -55,14 +54,15 @@ sk_load_half:
 	rol	$8,%ax			# ntohs()
 	ret
 
-sk_load_byte_ind:
-	.globl sk_load_byte_ind
-	add	%ebx,%esi	/* offset += X */
-	js	bpf_error
-
 sk_load_byte:
 	.globl	sk_load_byte
 
+	test	%esi,%esi
+	js	bpf_slow_path_byte_neg
+
+sk_load_byte_positive_offset:
+	.globl	sk_load_byte_positive_offset
+
 	cmp	%esi,%r9d   /* if (offset >= hlen) goto bpf_slow_path_byte */
 	jle	bpf_slow_path_byte
 	movzbl	(SKBDATA,%rsi),%eax
@@ -73,25 +73,21 @@ sk_load_byte:
  *
  * Implements BPF_S_LDX_B_MSH : ldxb  4*([offset]&0xf)
  * Must preserve A accumulator (%eax)
- * Inputs : %esi is the offset value, already known positive
+ * Inputs : %esi is the offset value
  */
-ENTRY(sk_load_byte_msh)
-	CFI_STARTPROC
+sk_load_byte_msh:
+	.globl	sk_load_byte_msh
+	test	%esi,%esi
+	js	bpf_slow_path_byte_msh_neg
+
+sk_load_byte_msh_positive_offset:
+	.globl	sk_load_byte_msh_positive_offset
 	cmp	%esi,%r9d      /* if (offset >= hlen) goto bpf_slow_path_byte_msh */
 	jle	bpf_slow_path_byte_msh
 	movzbl	(SKBDATA,%rsi),%ebx
 	and	$15,%bl
 	shl	$2,%bl
 	ret
-	CFI_ENDPROC
-ENDPROC(sk_load_byte_msh)
-
-bpf_error:
-# force a return 0 from jit handler
-	xor		%eax,%eax
-	mov		-8(%rbp),%rbx
-	leaveq
-	ret
 
 /* rsi contains offset and can be scratched */
 #define bpf_slow_path_common(LEN)		\
@@ -138,3 +134,68 @@ bpf_slow_path_byte_msh:
 	shl	$2,%al
 	xchg	%eax,%ebx
 	ret
+
+#define sk_negative_common(SIZE)				\
+	push	%rdi;	/* save skb */				\
+	push	%r9;						\
+	push	SKBDATA;					\
+/* rsi already has offset */					\
+	mov	$SIZE,%ecx;	/* size */			\
+	call	bpf_internal_load_pointer_neg_helper;		\
+	test	%rax,%rax;					\
+	pop	SKBDATA;					\
+	pop	%r9;						\
+	pop	%rdi;						\
+	jz	bpf_error
+
+
+bpf_slow_path_word_neg:
+	cmp	SKF_MAX_NEG_OFF, %esi	/* test range */
+	jl	bpf_error	/* offset lower -> error  */
+sk_load_word_negative_offset:
+	.globl	sk_load_word_negative_offset
+	sk_negative_common(4)
+	mov	(%rax), %eax
+	bswap	%eax
+	ret
+
+bpf_slow_path_half_neg:
+	cmp	SKF_MAX_NEG_OFF, %esi
+	jl	bpf_error
+sk_load_half_negative_offset:
+	.globl	sk_load_half_negative_offset
+	sk_negative_common(2)
+	mov	(%rax),%ax
+	rol	$8,%ax
+	movzwl	%ax,%eax
+	ret
+
+bpf_slow_path_byte_neg:
+	cmp	SKF_MAX_NEG_OFF, %esi
+	jl	bpf_error
+sk_load_byte_negative_offset:
+	.globl	sk_load_byte_negative_offset
+	sk_negative_common(1)
+	movzbl	(%rax), %eax
+	ret
+
+bpf_slow_path_byte_msh_neg:
+	cmp	SKF_MAX_NEG_OFF, %esi
+	jl	bpf_error
+sk_load_byte_msh_negative_offset:
+	.globl	sk_load_byte_msh_negative_offset
+	xchg	%eax,%ebx /* dont lose A , X is about to be scratched */
+	sk_negative_common(1)
+	movzbl	(%rax),%eax
+	and	$15,%al
+	shl	$2,%al
+	xchg	%eax,%ebx
+	ret
+
+bpf_error:
+# force a return 0 from jit handler
+	xor		%eax,%eax
+	mov		-8(%rbp),%rbx
+	leaveq
+	ret
+
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 5671752..39a2e2c 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -30,7 +30,10 @@ int bpf_jit_enable __read_mostly;
  * assembly code in arch/x86/net/bpf_jit.S
  */
 extern u8 sk_load_word[], sk_load_half[], sk_load_byte[], sk_load_byte_msh[];
-extern u8 sk_load_word_ind[], sk_load_half_ind[], sk_load_byte_ind[];
+extern u8 sk_load_word_positive_offset[], sk_load_half_positive_offset[];
+extern u8 sk_load_byte_positive_offset[], sk_load_byte_msh_positive_offset[];
+extern u8 sk_load_word_negative_offset[], sk_load_half_negative_offset[];
+extern u8 sk_load_byte_negative_offset[], sk_load_byte_msh_negative_offset[];
 
 static inline u8 *emit_code(u8 *ptr, u32 bytes, unsigned int len)
 {
@@ -117,6 +120,8 @@ static inline void bpf_flush_icache(void *start, void *end)
 	set_fs(old_fs);
 }
 
+#define CHOOSE_LOAD_FUNC(K, func) \
+	((int)K < 0 ? ((int)K >= SKF_LL_OFF ? func##_negative_offset : func) : func##_positive_offset)
 
 void bpf_jit_compile(struct sk_filter *fp)
 {
@@ -473,44 +478,46 @@ void bpf_jit_compile(struct sk_filter *fp)
 #endif
 				break;
 			case BPF_S_LD_W_ABS:
-				func = sk_load_word;
+				func = CHOOSE_LOAD_FUNC(K, sk_load_word);
 common_load:			seen |= SEEN_DATAREF;
-				if ((int)K < 0) {
-					/* Abort the JIT because __load_pointer() is needed. */
-					goto out;
-				}
 				t_offset = func - (image + addrs[i]);
 				EMIT1_off32(0xbe, K); /* mov imm32,%esi */
 				EMIT1_off32(0xe8, t_offset); /* call */
 				break;
 			case BPF_S_LD_H_ABS:
-				func = sk_load_half;
+				func = CHOOSE_LOAD_FUNC(K, sk_load_half);
 				goto common_load;
 			case BPF_S_LD_B_ABS:
-				func = sk_load_byte;
+				func = CHOOSE_LOAD_FUNC(K, sk_load_byte);
 				goto common_load;
 			case BPF_S_LDX_B_MSH:
-				if ((int)K < 0) {
-					/* Abort the JIT because __load_pointer() is needed. */
-					goto out;
-				}
+				func = CHOOSE_LOAD_FUNC(K, sk_load_byte_msh);
 				seen |= SEEN_DATAREF | SEEN_XREG;
-				t_offset = sk_load_byte_msh - (image + addrs[i]);
+				t_offset = func - (image + addrs[i]);
 				EMIT1_off32(0xbe, K);	/* mov imm32,%esi */
 				EMIT1_off32(0xe8, t_offset); /* call sk_load_byte_msh */
 				break;
 			case BPF_S_LD_W_IND:
-				func = sk_load_word_ind;
+				func = sk_load_word;
 common_load_ind:		seen |= SEEN_DATAREF | SEEN_XREG;
 				t_offset = func - (image + addrs[i]);
-				EMIT1_off32(0xbe, K);	/* mov imm32,%esi   */
+				if (K) {
+					if (is_imm8(K)) {
+						EMIT3(0x8d, 0x73, K); /* lea imm8(%rbx), %esi */
+					} else {
+						EMIT2(0x8d, 0xb3); /* lea imm32(%rbx),%esi */
+						EMIT(K, 4);
+					}
+				} else {
+					EMIT2(0x89,0xde); /* mov %ebx,%esi */
+				}
 				EMIT1_off32(0xe8, t_offset);	/* call sk_load_xxx_ind */
 				break;
 			case BPF_S_LD_H_IND:
-				func = sk_load_half_ind;
+				func = sk_load_half;
 				goto common_load_ind;
 			case BPF_S_LD_B_IND:
-				func = sk_load_byte_ind;
+				func = sk_load_byte;
 				goto common_load_ind;
 			case BPF_S_JMP_JA:
 				t_offset = addrs[i + K] - addrs[i];
diff --git a/net/core/filter.c b/net/core/filter.c
index 5dea452..04ca613 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -41,7 +41,7 @@
 #include <linux/ratelimit.h>
 
 /* No hurry in this branch */
-static void *__load_pointer(const struct sk_buff *skb, int k, unsigned int size)
+void *bpf_internal_load_pointer_neg_helper(const struct sk_buff *skb, int k, unsigned int size)
 {
 	u8 *ptr = NULL;
 
@@ -54,13 +54,14 @@ static void *__load_pointer(const struct sk_buff *skb, int k, unsigned int size)
 		return ptr;
 	return NULL;
 }
+EXPORT_SYMBOL(bpf_internal_load_pointer_neg_helper);
 
 static inline void *load_pointer(const struct sk_buff *skb, int k,
 				 unsigned int size, void *buffer)
 {
 	if (k >= 0)
 		return skb_header_pointer(skb, k, size, buffer);
-	return __load_pointer(skb, k, size);
+	return bpf_internal_load_pointer_neg_helper(skb, k, size);
 }
 
 /**
