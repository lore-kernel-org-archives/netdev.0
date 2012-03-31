From: "Indan Zupancic" <indan@nul.nu>
Subject: [RFC] net: bpf_jit: Two pass JIT and other changes
Date: Sat, 31 Mar 2012 23:12:30 +1100
Message-ID: <5185e05a69d88b5f12b5656358745b1a.squirrel@webmail.greenhost.nl>
Mime-Version: 1.0
Content-Type: text/plain;charset=UTF-8
Content-Transfer-Encoding: 8bit
To: "Eric Dumazet" <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost1.greenhost.nl ([195.190.28.78]:45982 "EHLO
	smarthost1.greenhost.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759703Ab2CaMMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Mar 2012 08:12:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

After fiddling with x86 JIT code I got it to compile the BPF
filters always in two passes instead of looping until the result
is stable. The current code loops at least three times, more
if jump offsets change from far to near because other jumps got
shorter. In the process I simplifying the code a bit, but I
tried to avoid controversial code changes. After the changes
bpf_jit_comp.o is about 1kb smaller.

As I moved the inner loop to a helper function, pretty much all
lines in bpf_jit_comp.c changed and a diff isn't very helpful.
Later changes I can redo for the original version and I'll send
a diff for those separately. But before I go to the trouble of
trying to get a readable patch series for the two pass version,
I'll attach the end result below so people can see if it's worth
the trouble or not.

As I'm currently travelling I've no access to a 64-bit machine,
so everything is done on 32-bit and as yet untested. JITing
should be quite a bit faster with this version, while the
generated code should have pretty much the same speed, as
nothing major changed.

Summary of the changes:

1) Sadly, gcc isn't always smart enough to inline emit_code().
   So turn it into a macro to force gcc to inline it. This saves
   about 500 bytes. Tested with gcc 4.6.0. An alternative to the
   macro would be to create inline emit_code1(), emit_code2() etc.

2) Split EMIT2() in the JMP macro's into a constant bit and a
   variable bit. This avoids the need to add them together and
   saves about 15 bytes. Adding __builtin_constant_p checks to
   emit macros saves more (50 bytes), but is ugly.

3) Only generate a CLEAR_X() when necessary. This is done by having
   an extra flag saying if X is used before it is set.

4) Simplify the code by adding a RET 0 as epilogue. This way the
   pc_ret0 and cleanup_addr logic can be merged. This was inspired
   by tcpdump always generating a RET 0 as last instruction. To make
   two pass compilation possible, the pc_ret0 had to go, as it's a
   backward jump.

5) Compile in two passes by doing the first pass in reverse.
   As all jumps are forward jumps, this way all offsets are known
   when needed, making it possible to do just two passes: One to
   check if we can JIT the filter and to calculate the code size.
   The second pass generates the real code directly into the
   allocated memory.

Are these changes worth pursuing? In the end it should speed up
JITing, saves 1kb, doesn't generate worse filter code and I think
it streamlines the code a bit.

Greetings,

Indan

---

Two-pass version of arch/x86/net/bpf_jit_comp.c:

---
/* bpf_jit_comp.c : BPF JIT compiler
 *
 * Copyright (C) 2011 Eric Dumazet (eric.dumazet@gmail.com)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; version 2
 * of the License.
 */
#include <linux/moduleloader.h>
#include <asm/cacheflush.h>
#include <linux/netdevice.h>
#include <linux/filter.h>

/*
 * Conventions :
 *  EAX : BPF A accumulator
 *  EBX : BPF X accumulator
 *  RDI : pointer to skb   (first argument given to JIT function)
 *  RBP : frame pointer (even if CONFIG_FRAME_POINTER=n)
 *  ECX,EDX,ESI : scratch registers
 *  r9d : skb->len - skb->data_len (headlen)
 *  r8  : skb->data
 * -8(RBP) : saved RBX value
 * -16(RBP)..-80(RBP) : BPF_MEMWORDS values
 */
int bpf_jit_enable __read_mostly;

/*
 * assembly code in arch/x86/net/bpf_jit.S
 */
extern u8 sk_load_word[], sk_load_half[], sk_load_byte[], sk_load_byte_msh[];
extern u8 sk_load_word_ind[], sk_load_half_ind[], sk_load_byte_ind[];

#define EMIT(bytes, len)			\
({						\
	if ((len) == 1)				\
		*prog = (u8)(bytes);		\
	else if ((len) == 2)			\
		*(u16 *)prog = (u16)(bytes);	\
	else {					\
		*(u32 *)prog = (bytes);		\
	}					\
	prog += (len);				\
})

#define EMIT1(b1)		EMIT(b1, 1)
#define EMIT2(b1, b2)		EMIT((b1) | ((b2) << 8), 2)
#define EMIT3(b1, b2, b3)	EMIT((b1) + ((b2) << 8) + ((b3) << 16), 3)
#define EMIT4(b1, b2, b3, b4)   EMIT((b1) + ((b2) << 8) + ((b3) << 16) + ((b4) << 24), 4)
#define EMIT1_off32(b1, off)	do { EMIT1(b1); EMIT(off, 4);} while (0)

#define CLEAR_A() EMIT2(0x31, 0xc0) /* xor %eax,%eax */
#define CLEAR_X() EMIT2(0x31, 0xdb) /* xor %ebx,%ebx */

static inline bool is_imm8(int value)
{
	return value <= 127 && value >= -128;
}

#define EMIT_JMP(offset)					\
do {								\
	if (is_imm8(offset)) {					\
		EMIT1(0xeb); /* jmp .+off8 */			\
		EMIT1(offset);					\
	} else {						\
		EMIT1_off32(0xe9, offset); /* jmp .+off32 */	\
	}							\
} while (0)

/* list of x86 cond jumps opcodes (. + s8)
 * Add 0x10 (and an extra 0x0f) to generate far jumps (. + s32)
 */
#define X86_JB  0x72
#define X86_JAE 0x73
#define X86_JE  0x74
#define X86_JNE 0x75
#define X86_JBE 0x76
#define X86_JA  0x77

#define EMIT_COND_JMP(op, offset)				\
do {								\
	if (is_imm8(offset)) {					\
		EMIT1(op); /* jxx .+off8 */			\
		EMIT1(offset);					\
	} else {						\
		EMIT2(0x0f, op + 0x10);				\
		EMIT(offset, 4); /* jxx .+off32 */		\
	}							\
} while (0)

#define COND_SEL(CODE, TOP, FOP)	\
	case CODE:			\
		t_op = TOP;		\
		f_op = FOP;		\
		goto cond_branch

#define SKB_OFF(field)	offsetof(struct sk_buff, field)

#define SEEN_DATAREF 1 /* might call external helpers */
#define SEEN_MEM     2 /* use mem[] for temporary storage */
#define USE_XREG     4 /* ebx is used */
#define CLEAR_XREG   8 /* ebx needs to be zeroed */
#define SEEN_XREG    (USE_XREG|CLEAR_XREG) /* ebx is used as input */

static inline void bpf_flush_icache(void *start, void *end)
{
	mm_segment_t old_fs = get_fs();

	set_fs(KERNEL_DS);
	smp_wmb();
	flush_icache_range((unsigned long)start, (unsigned long)end);
	set_fs(old_fs);
}

static u8* bpf_jit_ins(u8 *prog, const struct sock_filter *f, u16 *addrs, u8 *flags)
{
	int t_offset, f_offset;
	u8 t_op, f_op;
	u8 *func;
	u8 seen = *flags;
	unsigned int K = f->k;

	switch (f->code) {
	case BPF_S_ALU_ADD_X: /* A += X; */
		seen |= SEEN_XREG;
		EMIT2(0x01, 0xd8);		/* add %ebx,%eax */
		break;
	case BPF_S_ALU_ADD_K: /* A += K; */
		if (!K)
			break;
		if (is_imm8(K))
			EMIT3(0x83, 0xc0, K);	/* add imm8,%eax */
		else
			EMIT1_off32(0x05, K);	/* add imm32,%eax */
		break;
	case BPF_S_ALU_SUB_X: /* A -= X; */
		seen |= SEEN_XREG;
		EMIT2(0x29, 0xd8);		/* sub    %ebx,%eax */
		break;
	case BPF_S_ALU_SUB_K: /* A -= K */
		if (!K)
			break;
		if (is_imm8(K))
			EMIT3(0x83, 0xe8, K); /* sub imm8,%eax */
		else
			EMIT1_off32(0x2d, K); /* sub imm32,%eax */
		break;
	case BPF_S_ALU_MUL_X: /* A *= X; */
		seen |= SEEN_XREG;
		EMIT3(0x0f, 0xaf, 0xc3);	/* imul %ebx,%eax */
		break;
	case BPF_S_ALU_MUL_K: /* A *= K */
		if (is_imm8(K))
			EMIT3(0x6b, 0xc0, K); /* imul imm8,%eax,%eax */
		else {
			EMIT2(0x69, 0xc0);	/* imul imm32,%eax */
			EMIT(K, 4);
		}
		break;
	case BPF_S_ALU_DIV_X: /* A /= X; */
		seen |= SEEN_XREG;
		EMIT2(0x85, 0xdb);	/* test %ebx,%ebx */
		/*
		 * Add 4 to jump over "xor %edx,%edx; div %ebx".
		 */
		EMIT_COND_JMP(X86_JE, 4 + addrs[0]);
		EMIT4(0x31, 0xd2, 0xf7, 0xf3); /* xor %edx,%edx; div %ebx */
		break;
	case BPF_S_ALU_DIV_K: /* A = reciprocal_divide(A, K); */
		EMIT3(0x48, 0x69, 0xc0); /* imul imm32,%rax,%rax */
		EMIT(K, 4);
		EMIT4(0x48, 0xc1, 0xe8, 0x20); /* shr $0x20,%rax */
		break;
	case BPF_S_ALU_AND_X:
		seen |= SEEN_XREG;
		EMIT2(0x21, 0xd8);		/* and %ebx,%eax */
		break;
	case BPF_S_ALU_AND_K:
		if (K >= 0xFFFFFF00) {
			EMIT2(0x24, K & 0xFF); /* and imm8,%al */
		} else if (K >= 0xFFFF0000) {
			EMIT2(0x66, 0x25);	/* and imm16,%ax */
			EMIT(K, 2);
		} else {
			EMIT1_off32(0x25, K);	/* and imm32,%eax */
		}
		break;
	case BPF_S_ALU_OR_X:
		seen |= SEEN_XREG;
		EMIT2(0x09, 0xd8);		/* or %ebx,%eax */
		break;
	case BPF_S_ALU_OR_K:
		if (is_imm8(K))
			EMIT3(0x83, 0xc8, K); /* or imm8,%eax */
		else
			EMIT1_off32(0x0d, K);	/* or imm32,%eax */
		break;
	case BPF_S_ALU_LSH_X: /* A <<= X; */
		seen |= SEEN_XREG;
		EMIT4(0x89, 0xd9, 0xd3, 0xe0);	/* mov %ebx,%ecx; shl %cl,%eax */
		break;
	case BPF_S_ALU_LSH_K:
		if (K == 0)
			break;
		else if (K == 1)
			EMIT2(0xd1, 0xe0); /* shl %eax */
		else
			EMIT3(0xc1, 0xe0, K);
		break;
	case BPF_S_ALU_RSH_X: /* A >>= X; */
		seen |= SEEN_XREG;
		EMIT4(0x89, 0xd9, 0xd3, 0xe8);	/* mov %ebx,%ecx; shr %cl,%eax */
		break;
	case BPF_S_ALU_RSH_K: /* A >>= K; */
		if (K == 0)
			break;
		else if (K == 1)
			EMIT2(0xd1, 0xe8); /* shr %eax */
		else
			EMIT3(0xc1, 0xe8, K);
		break;
	case BPF_S_ALU_NEG:
		EMIT2(0xf7, 0xd8);		/* neg %eax */
		break;
	case BPF_S_RET_K:
		t_offset = addrs[0];
		if (!K && t_offset) {
			EMIT_JMP(t_offset);
		} else {
			EMIT1_off32(0xb8, K);	/* mov $imm32,%eax */
			EMIT_JMP(t_offset + 2);
		}
		break;
	case BPF_S_RET_A:
		EMIT_JMP(addrs[0] + 2);
		break;
	case BPF_S_MISC_TAX: /* X = A */
		seen |= USE_XREG;
		seen &= ~CLEAR_XREG;
		EMIT2(0x89, 0xc3);	/* mov    %eax,%ebx */
		break;
	case BPF_S_MISC_TXA: /* A = X */
		seen |= SEEN_XREG;
		EMIT2(0x89, 0xd8);	/* mov    %ebx,%eax */
		break;
	case BPF_S_LD_IMM: /* A = K */
		if (!K)
			CLEAR_A();
		else
			EMIT1_off32(0xb8, K); /* mov $imm32,%eax */
		break;
	case BPF_S_LDX_IMM: /* X = K */
		seen |= USE_XREG;
		seen &= ~CLEAR_XREG;
		if (!K)
			CLEAR_X();
		else
			EMIT1_off32(0xbb, K); /* mov $imm32,%ebx */
		break;
	case BPF_S_LD_MEM: /* A = mem[K] : mov off8(%rbp),%eax */
		seen |= SEEN_MEM;
		EMIT3(0x8b, 0x45, 0xf0 - K*4);
		break;
	case BPF_S_LDX_MEM: /* X = mem[K] : mov off8(%rbp),%ebx */
		seen |= USE_XREG | SEEN_MEM;
		seen &= ~CLEAR_XREG;
		EMIT3(0x8b, 0x5d, 0xf0 - K*4);
		break;
	case BPF_S_ST: /* mem[K] = A : mov %eax,off8(%rbp) */
		seen |= SEEN_MEM;
		EMIT3(0x89, 0x45, 0xf0 - K*4);
		break;
	case BPF_S_STX: /* mem[K] = X : mov %ebx,off8(%rbp) */
		seen |= SEEN_XREG | SEEN_MEM;
		EMIT3(0x89, 0x5d, 0xf0 - K*4);
		break;
	case BPF_S_LD_W_LEN: /*	A = skb->len; */
		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, len) != 4);
		if (is_imm8(SKB_OFF(len)))
			/* mov    off8(%rdi),%eax */
			EMIT3(0x8b, 0x47, SKB_OFF(len));
		else {
			EMIT2(0x8b, 0x87);
			EMIT(SKB_OFF(len), 4);
		}
		break;
	case BPF_S_LDX_W_LEN: /* X = skb->len; */
		seen |= USE_XREG;
		seen &= ~CLEAR_XREG;
		if (is_imm8(SKB_OFF(len)))
			/* mov off8(%rdi),%ebx */
			EMIT3(0x8b, 0x5f, SKB_OFF(len));
		else {
			EMIT2(0x8b, 0x9f);
			EMIT(SKB_OFF(len), 4);
		}
		break;
	case BPF_S_ANC_PROTOCOL: /* A = ntohs(skb->protocol); */
		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, protocol) != 2);
		if (is_imm8(SKB_OFF(protocol))) {
			/* movzwl off8(%rdi),%eax */
			EMIT4(0x0f, 0xb7, 0x47, SKB_OFF(protocol));
		} else {
			EMIT3(0x0f, 0xb7, 0x87); /* movzwl off32(%rdi),%eax */
			EMIT(SKB_OFF(protocol), 4);
		}
		EMIT2(0x86, 0xc4); /* ntohs() : xchg   %al,%ah */
		break;
	case BPF_S_ANC_IFINDEX:
		if (is_imm8(SKB_OFF(dev))) {
			/* movq off8(%rdi),%rax */
			EMIT4(0x48, 0x8b, 0x47, SKB_OFF(dev));
		} else {
			EMIT3(0x48, 0x8b, 0x87); /* movq off32(%rdi),%rax */
			EMIT(SKB_OFF(dev), 4);
		}
		EMIT3(0x48, 0x85, 0xc0);	/* test %rax,%rax */
		EMIT_COND_JMP(X86_JE, 6 + addrs[0]);
		EMIT2(0x8b, 0x80);	/* mov off32(%rax),%eax */
		EMIT(offsetof(struct net_device, ifindex), 4);
		BUILD_BUG_ON(FIELD_SIZEOF(struct net_device, ifindex) != 4);
		break;
	case BPF_S_ANC_MARK:
		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, mark) != 4);
		if (is_imm8(SKB_OFF(mark))) {
			/* mov off8(%rdi),%eax */
			EMIT3(0x8b, 0x47, SKB_OFF(mark));
		} else {
			EMIT2(0x8b, 0x87);
			EMIT(SKB_OFF(mark), 4);
		}
		break;
	case BPF_S_ANC_RXHASH:
		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, rxhash) != 4);
		if (is_imm8(SKB_OFF(rxhash))) {
			/* mov off8(%rdi),%eax */
			EMIT3(0x8b, 0x47, SKB_OFF(rxhash));
		} else {
			EMIT2(0x8b, 0x87);
			EMIT(SKB_OFF(rxhash), 4);
		}
		break;
	case BPF_S_ANC_QUEUE:
		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, queue_mapping) != 2);
		if (is_imm8(SKB_OFF(queue_mapping))) {
			/* movzwl off8(%rdi),%eax */
			EMIT4(0x0f, 0xb7, 0x47, SKB_OFF(queue_mapping));
		} else {
			EMIT3(0x0f, 0xb7, 0x87); /* movzwl off32(%rdi),%eax */
			EMIT(SKB_OFF(queue_mapping), 4);
		}
		break;
	case BPF_S_ANC_CPU:
#ifdef CONFIG_SMP
		EMIT4(0x65, 0x8b, 0x04, 0x25); /* mov %gs:off32,%eax */
		EMIT((u32)(unsigned long)&cpu_number, 4); /* A = smp_processor_id(); */
#else
		CLEAR_A();
#endif
		break;
	case BPF_S_LD_W_ABS:
		func = sk_load_word;
common_load:	seen |= SEEN_DATAREF;
		if ((int)K < 0) {
			/* Abort the JIT because __load_pointer() is needed. */
			return NULL;
		}
		t_offset = func - (prog + 10);
		EMIT1_off32(0xbe, K); /* mov imm32,%esi */
		EMIT1_off32(0xe8, t_offset); /* call */
		break;
	case BPF_S_LD_H_ABS:
		func = sk_load_half;
		goto common_load;
	case BPF_S_LD_B_ABS:
		func = sk_load_byte;
		goto common_load;
	case BPF_S_LDX_B_MSH:
		if ((int)K < 0) {
			/* Abort the JIT because __load_pointer() is needed. */
			return NULL;
		}
		seen |= SEEN_DATAREF | USE_XREG;
		seen &= ~CLEAR_XREG;
		t_offset = sk_load_byte_msh - (prog + 10);
		EMIT1_off32(0xbe, K);	/* mov imm32,%esi */
		EMIT1_off32(0xe8, t_offset); /* call sk_load_byte_msh */
		break;
	case BPF_S_LD_W_IND:
		func = sk_load_word_ind;
common_load_ind:
		seen |= SEEN_DATAREF | SEEN_XREG;
		t_offset = func - (prog + 10);
		EMIT1_off32(0xbe, K);	/* mov imm32,%esi   */
		EMIT1_off32(0xe8, t_offset);	/* call sk_load_xxx_ind */
		break;
	case BPF_S_LD_H_IND:
		func = sk_load_half_ind;
		goto common_load_ind;
	case BPF_S_LD_B_IND:
		func = sk_load_byte_ind;
		goto common_load_ind;
	case BPF_S_JMP_JA:
		t_offset = addrs[0] - addrs[K];
		if (t_offset)
			EMIT_JMP(t_offset);
		break;
	COND_SEL(BPF_S_JMP_JGT_K, X86_JA, X86_JBE);
	COND_SEL(BPF_S_JMP_JGE_K, X86_JAE, X86_JB);
	COND_SEL(BPF_S_JMP_JEQ_K, X86_JE, X86_JNE);
	COND_SEL(BPF_S_JMP_JSET_K,X86_JNE, X86_JE);
	COND_SEL(BPF_S_JMP_JGT_X, X86_JA, X86_JBE);
	COND_SEL(BPF_S_JMP_JGE_X, X86_JAE, X86_JB);
	COND_SEL(BPF_S_JMP_JEQ_X, X86_JE, X86_JNE);
	COND_SEL(BPF_S_JMP_JSET_X,X86_JNE, X86_JE);

cond_branch:	f_offset = addrs[0] - addrs[f->jf];
		t_offset = addrs[0] - addrs[f->jt];

		/* same targets, can avoid doing the test :) */
		if (f->jt == f->jf) {
			EMIT_JMP(t_offset);
			break;
		}

		switch (f->code) {
		case BPF_S_JMP_JGT_X:
		case BPF_S_JMP_JGE_X:
		case BPF_S_JMP_JEQ_X:
			seen |= SEEN_XREG;
			EMIT2(0x39, 0xd8); /* cmp %ebx,%eax */
			break;
		case BPF_S_JMP_JSET_X:
			seen |= SEEN_XREG;
			EMIT2(0x85, 0xd8); /* test %ebx,%eax */
			break;
		case BPF_S_JMP_JEQ_K:
			if (K == 0) {
				EMIT2(0x85, 0xc0); /* test   %eax,%eax */
				break;
			}
		case BPF_S_JMP_JGT_K:
		case BPF_S_JMP_JGE_K:
			if (K <= 127)
				EMIT3(0x83, 0xf8, K); /* cmp imm8,%eax */
			else
				EMIT1_off32(0x3d, K); /* cmp imm32,%eax */
			break;
		case BPF_S_JMP_JSET_K:
			if (K <= 0xFF)
				EMIT2(0xa8, K); /* test imm8,%al */
			else if (!(K & 0xFFFF00FF))
				EMIT3(0xf6, 0xc4, K >> 8); /* test imm8,%ah */
			else if (K <= 0xFFFF) {
				EMIT2(0x66, 0xa9); /* test imm16,%ax */
				EMIT(K, 2);
			} else {
				EMIT1_off32(0xa9, K); /* test imm32,%eax */
			}
			break;
		}
		if (t_offset) {
			if (f_offset)
				t_offset += is_imm8(f_offset) ? 2 : 5;
			EMIT_COND_JMP(t_op, t_offset);
			if (f_offset)
				EMIT_JMP(f_offset);
			break;
		}
		if (f_offset)
			EMIT_COND_JMP(f_op, f_offset);
		break;
	default:
		/* hmm, too complex filter, give up with jit compiler */
		return NULL;
	}
	*flags |= seen;
	return prog;
}

void bpf_jit_compile(struct sk_filter *fp)
{
	u8 temp[64];
	u8 *prog;
	unsigned int proglen = 0;
	u8 seen = 0;
	u8 *image;
	u16 *addrs;
	const struct sock_filter *filter = fp->insns;
	int i, flen = fp->len;

	if (!bpf_jit_enable)
		return;

	addrs = kmalloc(flen * sizeof(*addrs), GFP_KERNEL);
	if (addrs == NULL)
		return;

	/*
	 * First pass: Check if we can JIT this and calculate the size.
	 *
	 * As there are only forward jumps, go backwards through the
	 * instructions so all jump offsets are known when needed.
	 */
	for (i = flen - 1; i >= 0; i--) {
		/*
		 * Store the offset from the end of this instruction to
		 * the beginning of the epilogue (RET 0) in addrs[i].
		 *
		 * To return zero, jump addrs[i] bytes.
		 * To return A, jump addrs[i] + 2 bytes, to skip the CLEAR_A.
		 * To skip N instructions, jump addrs[i] - addrs[i + N] bytes.
		 */
		addrs[i] = proglen;
		prog = bpf_jit_ins(temp, &filter[i], &addrs[i], &seen);
		if (!prog)
			goto out;
		proglen += prog - temp;
	}
	/* Allocate extra memory for the prologue and epilogue */
	proglen += 64;
	/* Don't use too much memory */
	if (proglen > 32 * 1024)
		goto out;

	image = module_alloc(max_t(unsigned int, proglen, sizeof(struct work_struct)));
	if (!image)
		goto out;

	/*
	 * Second pass, now for real.
	 */
	prog = image;

	/* No prologue for trivial filters (RET something) */
	if (seen) {
		EMIT4(0x55, 0x48, 0x89, 0xe5); /* push %rbp; mov %rsp,%rbp */
		EMIT4(0x48, 0x83, 0xec, 96);	/* subq  $96,%rsp	*/
		/* note : must save %rbx in case bpf_error is hit */
		if (seen & (USE_XREG | SEEN_DATAREF))
			EMIT4(0x48, 0x89, 0x5d, 0xf8); /* mov %rbx, -8(%rbp) */
		if (seen & CLEAR_XREG)
			CLEAR_X(); /* make sure we don't leak kernel memory */
		/*
		 * If this filter needs to access skb data,
		 * loads r9 and r8 with :
		 *  r9 = skb->len - skb->data_len
		 *  r8 = skb->data
		 */
		if (seen & SEEN_DATAREF) {
			if (is_imm8(SKB_OFF(len)))
				/* mov    off8(%rdi),%r9d */
				EMIT4(0x44, 0x8b, 0x4f, SKB_OFF(len));
			else {
				/* mov    off32(%rdi),%r9d */
				EMIT3(0x44, 0x8b, 0x8f);
				EMIT(SKB_OFF(len), 4);
			}
			if (is_imm8(SKB_OFF(data_len)))
				/* sub    off8(%rdi),%r9d */
				EMIT4(0x44, 0x2b, 0x4f, SKB_OFF(data_len));
			else {
				EMIT3(0x44, 0x2b, 0x8f);
				EMIT(SKB_OFF(data_len), 4);
			}
			/* mov off32(%rdi),%r8 */
			EMIT3(0x4c, 0x8b, 0x87);
			EMIT(SKB_OFF(data), 4);
		}
	}
	switch (filter[0].code) {
	case BPF_S_RET_K:
	case BPF_S_LD_W_ABS:
	case BPF_S_LD_H_ABS:
	case BPF_S_LD_B_ABS:
	case BPF_S_LD_W_LEN:
	case BPF_S_LD_W_IND:
	case BPF_S_LD_H_IND:
	case BPF_S_LD_B_IND:
	case BPF_S_LD_IMM:
	case BPF_S_ANC_PROTOCOL:
	case BPF_S_ANC_IFINDEX:
	case BPF_S_ANC_MARK:
	case BPF_S_ANC_QUEUE:
	case BPF_S_ANC_RXHASH:
	case BPF_S_ANC_CPU:
		/* first instruction sets A register (or is RET 'constant') */
		break;
	default:
		/* make sure we don't leak kernel information to user */
		CLEAR_A(); /* A = 0 */
	}

	for (i = 0; i < flen; i++) {
		prog = bpf_jit_ins(prog, &filter[i], &addrs[i], &seen);
	}

	/*
	 * Epilogue is a RET 0.
	 * RET A jumps to addr[i] + 2, to skip the A = 0.
	 */
	CLEAR_A();
	if (seen & USE_XREG)
		EMIT4(0x48, 0x8b, 0x5d, 0xf8);  /* mov  -8(%rbp),%rbx */
	if (seen)
		EMIT1(0xc9);	/* leaveq */
	EMIT1(0xc3);		/* ret */

	proglen = prog - image;

	if (bpf_jit_enable > 1) {
		pr_err("flen=%d proglen=%u image=%p\n", flen, proglen, image);
		print_hex_dump(KERN_ERR, "JIT code: ", DUMP_PREFIX_ADDRESS,
				       16, 1, image, proglen, false);
	}

	bpf_flush_icache(image, image + proglen);
	fp->bpf_func = (void *)image;
out:
	kfree(addrs);
	return;
}

static void jit_free_defer(struct work_struct *arg)
{
	module_free(NULL, arg);
}

/* run from softirq, we must use a work_struct to call
 * module_free() from process context
 */
void bpf_jit_free(struct sk_filter *fp)
{
	if (fp->bpf_func != sk_run_filter) {
		struct work_struct *work = (struct work_struct *)fp->bpf_func;

		INIT_WORK(work, jit_free_defer);
		schedule_work(work);
	}
}
