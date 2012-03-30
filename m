From: Jan Seiffert <kaffeemonster@googlemail.com>
Subject: [REGRESSION][PATCH V4 2/3] bpf jit: Let the x86 jit handle negative
 offsets
Date: Fri, 30 Mar 2012 17:24:05 +0200
Message-ID: <4F75D015.30609@googlemail.com>
References: <4F75CA89.4010709@googlemail.com>
Reply-To: <kaffeemonster@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F75CA89.4010709@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now the helper function from filter.c for negative offsets is exported,
it can be used it in the jit to handle negative offsets.

First modify the asm load helper functions to handle:
- know positive offsets
- know negative offsets
- any offset

then the compiler can be modified to explicitly use these helper
when appropriate.

This fixes the case of a negative X register and allows to lift
the restriction that bpf programs with negative offsets can't
be jited.

Signed-of-by: Jan Seiffert <kaffeemonster@googlemail.com>

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
