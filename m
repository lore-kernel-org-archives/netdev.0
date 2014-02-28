From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v3 net-next 1/1] bpf32->bpf64 mapper and bpf64 interpreter
Date: Fri, 28 Feb 2014 13:45:20 +0100
Message-ID: <531084E0.5080601@redhat.com>
References: <1393468732-3919-1-git-send-email-ast@plumgrid.com> <1393468732-3919-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Jovi Zhangwei <jovi.zhangwei@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Pekka Enberg <penberg@iki.fi>,
	Arjan van de Ven <arjan@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Jesse Gross <jesse@nicira.com>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393468732-3919-2-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Alexei,

[also cc'ing Hagen and Jesse]

Just some minor comments below ... let me know what you think.

On 02/27/2014 03:38 AM, Alexei Starovoitov wrote:
> Extended BPF (or 64-bit BPF) is an instruction set to
> create safe dynamically loadable filters that can call fixed set
> of kernel functions and take generic bpf_context as an input.
> BPF filter is a glue between kernel functions and bpf_context.
> Different kernel subsystems can define their own set of available functions
> and alter BPF machinery for specific use case.
> BPF64 instruction set is designed for efficient mapping to native
> instructions on 64-bit CPUs
>
> Old BPF instructions are remapped on the fly to BPF64
> when sysctl net.core.bpf64_enable=1

Would be nice if the commit message could be extended with what you
have posted in your [PATCH v3 net-next 0/1] email (but without the
changelog, changelog should go after "---" line), so that also this
information will appear here and in the Git log later on. Also please
elaborate more on this commit message. I think, at least, as it's a
bigger change it also needs to include future planned usage scenarios
for user space and for inside the kernel e.g. for OVS and ftrace.

You could make this patch a 2 patch patch-series and put into patch
2/2 all documentation you had in your previous version of the set.
Would be nice to extend the file Documentation/networking/filter.txt
with a description of your extended BPF so that users can read about
them in the same file.

Did you also test that seccomp-BPF still works out?

> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
>   include/linux/filter.h      |    9 +-
>   include/linux/netdevice.h   |    1 +
>   include/uapi/linux/filter.h |   37 ++-
>   net/core/Makefile           |    2 +-
>   net/core/bpf_run.c          |  766 +++++++++++++++++++++++++++++++++++++++++++
>   net/core/filter.c           |  114 ++++++-

I would have liked to see the content from net/core/bpf_run.c to go
directly into net/core/filter.c, not as a separate file, if that's
possible.

>   net/core/sysctl_net_core.c  |    7 +
>   7 files changed, 913 insertions(+), 23 deletions(-)
>   create mode 100644 net/core/bpf_run.c
>
> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index e568c8ef896b..bf3085258f4c 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -53,6 +53,13 @@ extern int sk_chk_filter(struct sock_filter *filter, unsigned int flen);
>   extern int sk_get_filter(struct sock *sk, struct sock_filter __user *filter, unsigned len);
>   extern void sk_decode_filter(struct sock_filter *filt, struct sock_filter *to);
>
> +/* function remaps 'sock_filter' style insns to 'bpf_insn' style insns */
> +int bpf_convert(struct sock_filter *fp, int len, struct bpf_insn *new_prog,
> +		int *p_new_len);
> +/* execute bpf64 program */
> +u32 bpf_run(struct bpf_context *ctx, const struct bpf_insn *insn);
> +
> +#define SK_RUN_FILTER(FILTER, SKB) (*FILTER->bpf_func)(SKB, FILTER->insns)
>   #ifdef CONFIG_BPF_JIT
>   #include <stdarg.h>
>   #include <linux/linkage.h>
> @@ -70,7 +77,6 @@ static inline void bpf_jit_dump(unsigned int flen, unsigned int proglen,
>   		print_hex_dump(KERN_ERR, "JIT code: ", DUMP_PREFIX_OFFSET,
>   			       16, 1, image, proglen, false);
>   }
> -#define SK_RUN_FILTER(FILTER, SKB) (*FILTER->bpf_func)(SKB, FILTER->insns)
>   #else
>   #include <linux/slab.h>
>   static inline void bpf_jit_compile(struct sk_filter *fp)
> @@ -80,7 +86,6 @@ static inline void bpf_jit_free(struct sk_filter *fp)
>   {
>   	kfree(fp);
>   }
> -#define SK_RUN_FILTER(FILTER, SKB) sk_run_filter(SKB, FILTER->insns)
>   #endif
>
>   static inline int bpf_tell_extensions(void)
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 5e84483c0650..7b1acefc244e 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -2971,6 +2971,7 @@ extern int		netdev_max_backlog;
>   extern int		netdev_tstamp_prequeue;
>   extern int		weight_p;
>   extern int		bpf_jit_enable;
> +extern int		bpf64_enable;

We should keep naming consistent (so either extended BPF or BPF64),
so maybe bpf_ext_enable ? I'd presume rather {bpf,sk_filter}*_ext
as in 'struct bpf_insn' the immediate value is 32 bit, so for 64 bit
comparisons, you'd still need to load to immediate values, right?

After all your changes, we will still have the bpf_jit_enable knob
in tact, right?

>   bool netdev_has_upper_dev(struct net_device *dev, struct net_device *upper_dev);
>   struct net_device *netdev_all_upper_get_next_dev_rcu(struct net_device *dev,
> diff --git a/include/uapi/linux/filter.h b/include/uapi/linux/filter.h
> index 8eb9ccaa5b48..70ff29ee6825 100644
> --- a/include/uapi/linux/filter.h
> +++ b/include/uapi/linux/filter.h
> @@ -1,3 +1,4 @@
> +/* extended BPF is Copyright (c) 2011-2014, PLUMgrid, http://plumgrid.com */
>   /*
>    * Linux Socket Filter Data Structures
>    */

You can merge both comments into one.

> @@ -19,7 +20,7 @@
>    *	Try and keep these values and structures similar to BSD, especially
>    *	the BPF code definitions which need to match so you can share filters
>    */
> -
> +
>   struct sock_filter {	/* Filter block */
>   	__u16	code;   /* Actual filter code */
>   	__u8	jt;	/* Jump true */
> @@ -45,12 +46,26 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
>   #define         BPF_JMP         0x05
>   #define         BPF_RET         0x06
>   #define         BPF_MISC        0x07
> +#define         BPF_ALU64       0x07
> +
> +struct bpf_insn {
> +	__u8	code;    /* opcode */
> +	__u8    a_reg:4; /* dest register*/
> +	__u8    x_reg:4; /* source register */
> +	__s16	off;     /* signed offset */
> +	__s32	imm;     /* signed immediate constant */
> +};

As we have struct sock_filter and it's immutable due to uapi, I
would have liked to see the new data structure with a consistent
naming scheme, e.g. struct sock_filter_ext {...} for extended
BPF.

> +/* pointer to bpf_context is the first and only argument to BPF program
> + * its definition is use-case specific */
> +struct bpf_context;
>
>   /* ld/ldx fields */
>   #define BPF_SIZE(code)  ((code) & 0x18)
>   #define         BPF_W           0x00
>   #define         BPF_H           0x08
>   #define         BPF_B           0x10
> +#define         BPF_DW          0x18
>   #define BPF_MODE(code)  ((code) & 0xe0)
>   #define         BPF_IMM         0x00
>   #define         BPF_ABS         0x20
> @@ -58,6 +73,7 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
>   #define         BPF_MEM         0x60
>   #define         BPF_LEN         0x80
>   #define         BPF_MSH         0xa0
> +#define         BPF_XADD        0xc0 /* exclusive add */
>
>   /* alu/jmp fields */
>   #define BPF_OP(code)    ((code) & 0xf0)
> @@ -68,16 +84,24 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
>   #define         BPF_OR          0x40
>   #define         BPF_AND         0x50
>   #define         BPF_LSH         0x60
> -#define         BPF_RSH         0x70
> +#define         BPF_RSH         0x70 /* logical shift right */
>   #define         BPF_NEG         0x80
>   #define		BPF_MOD		0x90
>   #define		BPF_XOR		0xa0
> +#define		BPF_MOV		0xb0 /* mov reg to reg */
> +#define		BPF_ARSH	0xc0 /* sign extending arithmetic shift right */
> +#define		BPF_BSWAP32	0xd0 /* swap lower 4 bytes of 64-bit register */
> +#define		BPF_BSWAP64	0xe0 /* swap all 8 bytes of 64-bit register */
>
>   #define         BPF_JA          0x00
> -#define         BPF_JEQ         0x10
> -#define         BPF_JGT         0x20
> -#define         BPF_JGE         0x30
> -#define         BPF_JSET        0x40
> +#define         BPF_JEQ         0x10 /* jump == */
> +#define         BPF_JGT         0x20 /* GT is unsigned '>', JA in x86 */
> +#define         BPF_JGE         0x30 /* GE is unsigned '>=', JAE in x86 */
> +#define         BPF_JSET        0x40 /* if (A & X) */
> +#define         BPF_JNE         0x50 /* jump != */
> +#define         BPF_JSGT        0x60 /* SGT is signed '>', GT in x86 */
> +#define         BPF_JSGE        0x70 /* SGE is signed '>=', GE in x86 */
> +#define         BPF_CALL        0x80 /* function call */
>   #define BPF_SRC(code)   ((code) & 0x08)
>   #define         BPF_K           0x00
>   #define         BPF_X           0x08
> @@ -134,5 +158,4 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
>   #define SKF_NET_OFF   (-0x100000)
>   #define SKF_LL_OFF    (-0x200000)
>
> -
>   #endif /* _UAPI__LINUX_FILTER_H__ */
> diff --git a/net/core/Makefile b/net/core/Makefile
> index 9628c20acff6..e622b97f58dc 100644
> --- a/net/core/Makefile
> +++ b/net/core/Makefile
> @@ -8,7 +8,7 @@ obj-y := sock.o request_sock.o skbuff.o iovec.o datagram.o stream.o scm.o \
>   obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
>
>   obj-y		     += dev.o ethtool.o dev_addr_lists.o dst.o netevent.o \
> -			neighbour.o rtnetlink.o utils.o link_watch.o filter.o \
> +			neighbour.o rtnetlink.o utils.o link_watch.o filter.o bpf_run.o \
>   			sock_diag.o dev_ioctl.o
>
>   obj-$(CONFIG_XFRM) += flow.o
> diff --git a/net/core/bpf_run.c b/net/core/bpf_run.c
> new file mode 100644
> index 000000000000..fa1862fcbc74
> --- /dev/null
> +++ b/net/core/bpf_run.c
> @@ -0,0 +1,766 @@
> +/* Copyright (c) 2011-2014 PLUMgrid, http://plumgrid.com
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of version 2 of the GNU General Public
> + * License as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful, but
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
> + * General Public License for more details.
> + */
> +#include <linux/kernel.h>
> +#include <linux/types.h>
> +#include <linux/slab.h>
> +#include <linux/uaccess.h>
> +#include <linux/filter.h>
> +#include <linux/skbuff.h>
> +#include <asm/unaligned.h>
> +
> +int bpf64_enable __read_mostly;
> +
> +void *bpf_internal_load_pointer_neg_helper(const struct sk_buff *skb, int k,
> +					   unsigned int size);
> +
> +static inline void *load_pointer(const struct sk_buff *skb, int k,
> +				 unsigned int size, void *buffer)
> +{
> +	if (k >= 0)
> +		return skb_header_pointer(skb, k, size, buffer);
> +	return bpf_internal_load_pointer_neg_helper(skb, k, size);
> +}
> +
> +static const char *const bpf_class_string[] = {
> +	"ld", "ldx", "st", "stx", "alu", "jmp", "ret", "misc"
> +};
> +
> +static const char *const bpf_alu_string[] = {
> +	"+=", "-=", "*=", "/=", "|=", "&=", "<<=", ">>=", "neg",
> +	"%=", "^=", "=", "s>>=", "bswap32", "bswap64", "???"
> +};
> +
> +static const char *const bpf_ldst_string[] = {
> +	"u32", "u16", "u8", "u64"
> +};
> +
> +static const char *const bpf_jmp_string[] = {
> +	"jmp", "==", ">", ">=", "&", "!=", "s>", "s>=", "call"
> +};
> +
> +static const char *reg_to_str(int regno, u64 *regs)
> +{
> +	static char reg_value[16][32];
> +	if (!regs)
> +		return "";
> +	snprintf(reg_value[regno], sizeof(reg_value[regno]), "(0x%llx)",
> +		 regs[regno]);
> +	return reg_value[regno];
> +}
> +
> +#define R(regno) reg_to_str(regno, regs)
> +
> +void pr_info_bpf_insn(const struct bpf_insn *insn, u64 *regs)
> +{
> +	u16 class = BPF_CLASS(insn->code);
> +	if (class == BPF_ALU || class == BPF_ALU64) {
> +		if (BPF_SRC(insn->code) == BPF_X)
> +			pr_info("code_%02x %sr%d%s %s r%d%s\n",
> +				insn->code, class == BPF_ALU ? "(u32)" : "",
> +				insn->a_reg, R(insn->a_reg),
> +				bpf_alu_string[BPF_OP(insn->code) >> 4],
> +				insn->x_reg, R(insn->x_reg));
> +		else
> +			pr_info("code_%02x %sr%d%s %s %d\n",
> +				insn->code, class == BPF_ALU ? "(u32)" : "",
> +				insn->a_reg, R(insn->a_reg),
> +				bpf_alu_string[BPF_OP(insn->code) >> 4],
> +				insn->imm);
> +	} else if (class == BPF_STX) {
> +		if (BPF_MODE(insn->code) == BPF_MEM)
> +			pr_info("code_%02x *(%s *)(r%d%s %+d) = r%d%s\n",
> +				insn->code,
> +				bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
> +				insn->a_reg, R(insn->a_reg),
> +				insn->off, insn->x_reg, R(insn->x_reg));
> +		else if (BPF_MODE(insn->code) == BPF_XADD)
> +			pr_info("code_%02x lock *(%s *)(r%d%s %+d) += r%d%s\n",
> +				insn->code,
> +				bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
> +				insn->a_reg, R(insn->a_reg), insn->off,
> +				insn->x_reg, R(insn->x_reg));
> +		else
> +			pr_info("BUG_%02x\n", insn->code);
> +	} else if (class == BPF_ST) {
> +		if (BPF_MODE(insn->code) != BPF_MEM) {
> +			pr_info("BUG_st_%02x\n", insn->code);
> +			return;
> +		}
> +		pr_info("code_%02x *(%s *)(r%d%s %+d) = %d\n",
> +			insn->code,
> +			bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
> +			insn->a_reg, R(insn->a_reg),
> +			insn->off, insn->imm);
> +	} else if (class == BPF_LDX) {
> +		if (BPF_MODE(insn->code) == BPF_MEM) {
> +			pr_info("code_%02x r%d = *(%s *)(r%d%s %+d)\n",
> +				insn->code, insn->a_reg,
> +				bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
> +				insn->x_reg, R(insn->x_reg), insn->off);
> +		} else {
> +			pr_info("BUG_ldx_%02x\n", insn->code);
> +		}
> +	} else if (class == BPF_LD) {
> +		if (BPF_MODE(insn->code) == BPF_ABS) {
> +			pr_info("code_%02x r%d = *(%s *)(skb %+d)\n",
> +				insn->code, insn->a_reg,
> +				bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
> +				insn->imm);
> +		} else if (BPF_MODE(insn->code) == BPF_IND) {
> +			pr_info("code_%02x r%d = *(%s *)(skb + r%d%s %+d)\n",
> +				insn->code, insn->a_reg,
> +				bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
> +				insn->x_reg, R(insn->x_reg), insn->imm);
> +		} else {
> +			pr_info("BUG_ld_%02x\n", insn->code);
> +		}
> +	} else if (class == BPF_JMP) {
> +		u16 opcode = BPF_OP(insn->code);
> +		if (opcode == BPF_CALL) {
> +			pr_info("code_%02x call %d\n", insn->code, insn->imm);
> +		} else if (insn->code == (BPF_JMP | BPF_JA)) {
> +			pr_info("code_%02x goto pc%+d\n",
> +				insn->code, insn->off);
> +		} else if (BPF_SRC(insn->code) == BPF_X) {
> +			pr_info("code_%02x if r%d%s %s r%d%s goto pc%+d\n",
> +				insn->code, insn->a_reg, R(insn->a_reg),
> +				bpf_jmp_string[BPF_OP(insn->code) >> 4],
> +				insn->x_reg, R(insn->x_reg), insn->off);
> +		} else {
> +			pr_info("code_%02x if r%d%s %s 0x%x goto pc%+d\n",
> +				insn->code, insn->a_reg, R(insn->a_reg),
> +				bpf_jmp_string[BPF_OP(insn->code) >> 4],
> +				insn->imm, insn->off);
> +		}
> +	} else {
> +		pr_info("code_%02x %s\n", insn->code, bpf_class_string[class]);
> +	}
> +}
> +EXPORT_SYMBOL(pr_info_bpf_insn);

Why would that need to be exported as a symbol?

I would actually like to avoid having this pr_info* inside the kernel.
Couldn't this be done e.g. through systemtap script that could e.g. be
placed under tools/net/ or inside the documentation file?

> +/* remap 'sock_filter' style BPF instruction set to 'bpf_insn' style (BPF64)
> + *
> + * first, call bpf_convert(old_prog, len, NULL, &new_len) to calculate new
> + * program length in one pass
> + *
> + * then new_prog = kmalloc(sizeof(struct bpf_insn) * new_len);
> + *
> + * and call it again: bpf_convert(old_prog, len, new_prog, &new_len);
> + * to remap in two passes: 1st pass finds new jump offsets, 2nd pass remaps
> + */

Would be nice to have the API comment it in kdoc format.

> +int bpf_convert(struct sock_filter *old_prog, int len,
> +		struct bpf_insn *new_prog, int *p_new_len)
> +{

If we place it into net/core/filter.c, it would be nice to keep naming
conventions consistent, e.g. sk_convert_filter() or so.

> +	struct bpf_insn *new_insn;
> +	struct sock_filter *fp;
> +	int *addrs = NULL;
> +	int new_len = 0;
> +	int pass = 0;
> +	int tgt, i;
> +
> +	if (len <= 0 || len >= BPF_MAXINSNS)
> +		return -EINVAL;
> +
> +	if (new_prog) {
> +		addrs = kzalloc(len * sizeof(*addrs), GFP_KERNEL);
> +		if (!addrs)
> +			return -ENOMEM;
> +	}
> +
> +do_pass:
> +	new_insn = new_prog;
> +	fp = old_prog;
> +	for (i = 0; i < len; fp++, i++) {
> +		struct bpf_insn tmp_insns[3] = {};
> +		struct bpf_insn *insn = tmp_insns;
> +
> +		if (addrs)
> +			addrs[i] = new_insn - new_prog;
> +
> +		switch (fp->code) {
> +		/* all arithmetic insns and skb loads map as-is */
> +		case BPF_ALU | BPF_ADD | BPF_X:
> +		case BPF_ALU | BPF_ADD | BPF_K:
> +		case BPF_ALU | BPF_SUB | BPF_X:
> +		case BPF_ALU | BPF_SUB | BPF_K:
> +		case BPF_ALU | BPF_AND | BPF_X:
> +		case BPF_ALU | BPF_AND | BPF_K:
> +		case BPF_ALU | BPF_OR | BPF_X:
> +		case BPF_ALU | BPF_OR | BPF_K:
> +		case BPF_ALU | BPF_LSH | BPF_X:
> +		case BPF_ALU | BPF_LSH | BPF_K:
> +		case BPF_ALU | BPF_RSH | BPF_X:
> +		case BPF_ALU | BPF_RSH | BPF_K:
> +		case BPF_ALU | BPF_XOR | BPF_X:
> +		case BPF_ALU | BPF_XOR | BPF_K:
> +		case BPF_ALU | BPF_MUL | BPF_X:
> +		case BPF_ALU | BPF_MUL | BPF_K:
> +		case BPF_ALU | BPF_DIV | BPF_X:
> +		case BPF_ALU | BPF_DIV | BPF_K:
> +		case BPF_ALU | BPF_MOD | BPF_X:
> +		case BPF_ALU | BPF_MOD | BPF_K:
> +		case BPF_ALU | BPF_NEG:
> +		case BPF_LD | BPF_ABS | BPF_W:
> +		case BPF_LD | BPF_ABS | BPF_H:
> +		case BPF_LD | BPF_ABS | BPF_B:
> +		case BPF_LD | BPF_IND | BPF_W:
> +		case BPF_LD | BPF_IND | BPF_H:
> +		case BPF_LD | BPF_IND | BPF_B:

I think here and elsewhere for similar constructions, we could use
BPF_S_* helpers that was introduced by Hagen in commit 01f2f3f6ef4d076
("net: optimize Berkeley Packet Filter (BPF) processing").

> +			insn->code = fp->code;
> +			insn->a_reg = 6;
> +			insn->x_reg = 7;
> +			insn->imm = fp->k;
> +			break;
> +
> +		/* jump opcodes map as-is, but offsets need adjustment */
> +		case BPF_JMP | BPF_JA:
> +			tgt = i + fp->k + 1;
> +			insn->code = fp->code;
> +#define EMIT_JMP \
> +	do { \
> +		if (tgt >= len || tgt < 0) \
> +			goto err; \
> +		insn->off = addrs ? addrs[tgt] - addrs[i] - 1 : 0; \
> +	} while (0)
> +
> +			EMIT_JMP;
> +			break;
> +
> +		case BPF_JMP | BPF_JEQ | BPF_K:
> +		case BPF_JMP | BPF_JEQ | BPF_X:
> +		case BPF_JMP | BPF_JSET | BPF_K:
> +		case BPF_JMP | BPF_JSET | BPF_X:
> +		case BPF_JMP | BPF_JGT | BPF_K:
> +		case BPF_JMP | BPF_JGT | BPF_X:
> +		case BPF_JMP | BPF_JGE | BPF_K:
> +		case BPF_JMP | BPF_JGE | BPF_X:
> +			insn->a_reg = 6;
> +			insn->x_reg = 7;
> +			insn->imm = fp->k;
> +			/* common case where 'jump_false' is next insn */
> +			if (fp->jf == 0) {
> +				insn->code = fp->code;
> +				tgt = i + fp->jt + 1;
> +				EMIT_JMP;
> +				break;
> +			}
> +			/* convert JEQ into JNE when 'jump_true' is next insn */
> +			if (fp->jt == 0 && BPF_OP(fp->code) == BPF_JEQ) {
> +				insn->code = BPF_JMP | BPF_JNE |
> +					BPF_SRC(fp->code);
> +				tgt = i + fp->jf + 1;
> +				EMIT_JMP;
> +				break;
> +			}
> +			/* other jumps are mapped into two insns: Jxx and JA */
> +			tgt = i + fp->jt + 1;
> +			insn->code = fp->code;
> +			EMIT_JMP;
> +
> +			insn++;
> +			insn->code = BPF_JMP | BPF_JA;
> +			tgt = i + fp->jf + 1;
> +			EMIT_JMP;
> +			/* adjust pc relative offset, since it's a 2nd insn */
> +			insn->off--;
> +			break;
> +
> +			/* ldxb 4*([14]&0xf) is remaped into 3 insns */
> +		case BPF_LDX | BPF_MSH | BPF_B:
> +			insn->code = BPF_LD | BPF_ABS | BPF_B;
> +			insn->a_reg = 7;
> +			insn->imm = fp->k;
> +
> +			insn++;
> +			insn->code = BPF_ALU | BPF_AND | BPF_K;
> +			insn->a_reg = 7;
> +			insn->imm = 0xf;
> +
> +			insn++;
> +			insn->code = BPF_ALU | BPF_LSH | BPF_K;
> +			insn->a_reg = 7;
> +			insn->imm = 2;
> +			break;
> +
> +			/* RET_K, RET_A are remaped into 2 insns */
> +		case BPF_RET | BPF_A:
> +		case BPF_RET | BPF_K:
> +			insn->code = BPF_ALU | BPF_MOV |
> +				(BPF_SRC(fp->code) == BPF_K ? BPF_K : BPF_X);
> +			insn->a_reg = 0;
> +			insn->x_reg = 6;
> +			insn->imm = fp->k;
> +
> +			insn++;
> +			insn->code = BPF_RET | BPF_K;
> +			break;
> +
> +			/* store to stack */
> +		case BPF_ST:
> +		case BPF_STX:
> +			insn->code = BPF_STX | BPF_MEM | BPF_W;
> +			insn->a_reg = 10;
> +			insn->x_reg = fp->code == BPF_ST ? 6 : 7;
> +			insn->off = -(BPF_MEMWORDS - fp->k) * 4;
> +			break;
> +
> +			/* load from stack */
> +		case BPF_LD | BPF_MEM:
> +		case BPF_LDX | BPF_MEM:
> +			insn->code = BPF_LDX | BPF_MEM | BPF_W;
> +			insn->a_reg = BPF_CLASS(fp->code) == BPF_LD ? 6 : 7;
> +			insn->x_reg = 10;
> +			insn->off = -(BPF_MEMWORDS - fp->k) * 4;
> +			break;
> +
> +			/* A = K or X = K */
> +		case BPF_LD | BPF_IMM:
> +		case BPF_LDX | BPF_IMM:
> +			insn->code = BPF_ALU | BPF_MOV | BPF_K;
> +			insn->a_reg = BPF_CLASS(fp->code) == BPF_LD ? 6 : 7;
> +			insn->imm = fp->k;
> +			break;
> +
> +			/* X = A */
> +		case BPF_MISC | BPF_TAX:
> +			insn->code = BPF_ALU64 | BPF_MOV | BPF_X;
> +			insn->a_reg = 7;
> +			insn->x_reg = 6;
> +			break;
> +
> +			/* A = X */
> +		case BPF_MISC | BPF_TXA:
> +			insn->code = BPF_ALU64 | BPF_MOV | BPF_X;
> +			insn->a_reg = 6;
> +			insn->x_reg = 7;
> +			break;
> +
> +			/* A = skb->len or X = skb->len */
> +		case BPF_LD|BPF_W|BPF_LEN:
> +		case BPF_LDX|BPF_W|BPF_LEN:
> +			insn->code = BPF_LDX | BPF_MEM | BPF_W;
> +			insn->a_reg = BPF_CLASS(fp->code) == BPF_LD ? 6 : 7;
> +			insn->x_reg = 1;
> +			insn->off = offsetof(struct sk_buff, len);
> +			break;
> +
> +		default:
> +			/* pr_err("unknown opcode %02x\n", fp->code); */
> +			goto err;
> +		}
> +
> +		insn++;
> +		if (new_prog) {
> +			memcpy(new_insn, tmp_insns,
> +			       sizeof(*insn) * (insn - tmp_insns));
> +		}
> +		new_insn += insn - tmp_insns;
> +	}
> +
> +	if (!new_prog) {
> +		/* only calculating new length */
> +		*p_new_len = new_insn - new_prog;
> +		return 0;
> +	}
> +
> +	pass++;
> +	if (new_len != new_insn - new_prog) {
> +		new_len = new_insn - new_prog;
> +		if (pass > 2)
> +			goto err;
> +		goto do_pass;
> +	}
> +	kfree(addrs);
> +	if (*p_new_len != new_len)
> +		/* inconsistent new program length */
> +		pr_err("bpf_convert() usage error\n");
> +	return 0;
> +err:
> +	kfree(addrs);
> +	return -EINVAL;
> +}
> +
> +notrace u32 bpf_run(struct bpf_context *ctx, const struct bpf_insn *insn)
> +{

Similarly, sk_run_filter_ext()?

> +	u64 stack[64];
> +	u64 regs[16];
> +	void *ptr;
> +	u64 tmp;
> +	int off;
> +
> +#ifdef __x86_64
> +#define LOAD_IMM /**/
> +#define K insn->imm
> +#else
> +#define LOAD_IMM (K = insn->imm)
> +	s32 K = insn->imm;
> +#endif
> +
> +#ifdef DEBUG
> +#define DEBUG_INSN pr_info_bpf_insn(insn, regs)
> +#else
> +#define DEBUG_INSN
> +#endif

This DEBUG hunk could then be removed when we use a stap script
instead, for example.

> +#define A regs[insn->a_reg]
> +#define X regs[insn->x_reg]
> +
> +#define DL(A, B, C) [A|B|C] = &&L_##A##B##C,
> +#define L(A, B, C) L_##A##B##C:

Could we get rid of these two defines? I know you're defining
and using that as labels, but it's not obvious at first what
'jt' does. Maybe 'jt_labels' ?

> +#define CONT ({insn++; LOAD_IMM; DEBUG_INSN; goto select_insn; })
> +#define CONT_JMP ({insn++; LOAD_IMM; DEBUG_INSN; goto select_insn; })

Not a big fan of macros, but here it seems fine though.

> +/* some compilers may need help:
> + * #define CONT_JMP ({insn++; LOAD_IMM; DEBUG_INSN; goto *jt[insn->code]; })
> + */
> +
> +	static const void *jt[256] = {
> +		[0 ... 255] = &&L_default,

Nit: please just one define per line below:

> +		DL(BPF_ALU, BPF_ADD, BPF_X) DL(BPF_ALU, BPF_ADD, BPF_K)
> +		DL(BPF_ALU, BPF_SUB, BPF_X) DL(BPF_ALU, BPF_SUB, BPF_K)
> +		DL(BPF_ALU, BPF_AND, BPF_X) DL(BPF_ALU, BPF_AND, BPF_K)
> +		DL(BPF_ALU, BPF_OR, BPF_X)  DL(BPF_ALU, BPF_OR, BPF_K)
> +		DL(BPF_ALU, BPF_LSH, BPF_X) DL(BPF_ALU, BPF_LSH, BPF_K)
> +		DL(BPF_ALU, BPF_RSH, BPF_X) DL(BPF_ALU, BPF_RSH, BPF_K)
> +		DL(BPF_ALU, BPF_XOR, BPF_X) DL(BPF_ALU, BPF_XOR, BPF_K)
> +		DL(BPF_ALU, BPF_MUL, BPF_X) DL(BPF_ALU, BPF_MUL, BPF_K)
> +		DL(BPF_ALU, BPF_MOV, BPF_X) DL(BPF_ALU, BPF_MOV, BPF_K)
> +		DL(BPF_ALU, BPF_DIV, BPF_X) DL(BPF_ALU, BPF_DIV, BPF_K)
> +		DL(BPF_ALU, BPF_MOD, BPF_X) DL(BPF_ALU, BPF_MOD, BPF_K)
> +		DL(BPF_ALU64, BPF_ADD, BPF_X) DL(BPF_ALU64, BPF_ADD, BPF_K)
> +		DL(BPF_ALU64, BPF_SUB, BPF_X) DL(BPF_ALU64, BPF_SUB, BPF_K)
> +		DL(BPF_ALU64, BPF_AND, BPF_X) DL(BPF_ALU64, BPF_AND, BPF_K)
> +		DL(BPF_ALU64, BPF_OR, BPF_X)  DL(BPF_ALU64, BPF_OR, BPF_K)
> +		DL(BPF_ALU64, BPF_LSH, BPF_X) DL(BPF_ALU64, BPF_LSH, BPF_K)
> +		DL(BPF_ALU64, BPF_RSH, BPF_X) DL(BPF_ALU64, BPF_RSH, BPF_K)
> +		DL(BPF_ALU64, BPF_XOR, BPF_X) DL(BPF_ALU64, BPF_XOR, BPF_K)
> +		DL(BPF_ALU64, BPF_MUL, BPF_X) DL(BPF_ALU64, BPF_MUL, BPF_K)
> +		DL(BPF_ALU64, BPF_MOV, BPF_X) DL(BPF_ALU64, BPF_MOV, BPF_K)
> +		DL(BPF_ALU64, BPF_ARSH, BPF_X)DL(BPF_ALU64, BPF_ARSH, BPF_K)
> +		DL(BPF_ALU64, BPF_DIV, BPF_X) DL(BPF_ALU64, BPF_DIV, BPF_K)
> +		DL(BPF_ALU64, BPF_MOD, BPF_X) DL(BPF_ALU64, BPF_MOD, BPF_K)
> +		DL(BPF_ALU64, BPF_BSWAP32, BPF_X)
> +		DL(BPF_ALU64, BPF_BSWAP64, BPF_X)
> +		DL(BPF_ALU, BPF_NEG, 0)
> +		DL(BPF_JMP, BPF_CALL, 0)
> +		DL(BPF_JMP, BPF_JA, 0)
> +		DL(BPF_JMP, BPF_JEQ, BPF_X) DL(BPF_JMP, BPF_JEQ, BPF_K)
> +		DL(BPF_JMP, BPF_JNE, BPF_X) DL(BPF_JMP, BPF_JNE, BPF_K)
> +		DL(BPF_JMP, BPF_JGT, BPF_X) DL(BPF_JMP, BPF_JGT, BPF_K)
> +		DL(BPF_JMP, BPF_JGE, BPF_X) DL(BPF_JMP, BPF_JGE, BPF_K)
> +		DL(BPF_JMP, BPF_JSGT, BPF_X) DL(BPF_JMP, BPF_JSGT, BPF_K)
> +		DL(BPF_JMP, BPF_JSGE, BPF_X) DL(BPF_JMP, BPF_JSGE, BPF_K)
> +		DL(BPF_JMP, BPF_JSET, BPF_X) DL(BPF_JMP, BPF_JSET, BPF_K)
> +		DL(BPF_STX, BPF_MEM, BPF_B) DL(BPF_STX, BPF_MEM, BPF_H)
> +		DL(BPF_STX, BPF_MEM, BPF_W) DL(BPF_STX, BPF_MEM, BPF_DW)
> +		DL(BPF_ST, BPF_MEM, BPF_B) DL(BPF_ST, BPF_MEM, BPF_H)
> +		DL(BPF_ST, BPF_MEM, BPF_W) DL(BPF_ST, BPF_MEM, BPF_DW)
> +		DL(BPF_LDX, BPF_MEM, BPF_B) DL(BPF_LDX, BPF_MEM, BPF_H)
> +		DL(BPF_LDX, BPF_MEM, BPF_W) DL(BPF_LDX, BPF_MEM, BPF_DW)
> +		DL(BPF_STX, BPF_XADD, BPF_W)
> +#ifdef CONFIG_64BIT
> +		DL(BPF_STX, BPF_XADD, BPF_DW)
> +#endif
> +		DL(BPF_LD, BPF_ABS, BPF_W) DL(BPF_LD, BPF_ABS, BPF_H)
> +		DL(BPF_LD, BPF_ABS, BPF_B) DL(BPF_LD, BPF_IND, BPF_W)
> +		DL(BPF_LD, BPF_IND, BPF_H) DL(BPF_LD, BPF_IND, BPF_B)
> +		DL(BPF_RET, BPF_K, 0)
> +	};
> +
> +	regs[10/* BPF R10 */] = (u64)(ulong)&stack[64];
> +	regs[1/* BPF R1 */] = (u64)(ulong)ctx;
> +
> +	DEBUG_INSN;
> +	/* execute 1st insn */
> +select_insn:
> +	goto *jt[insn->code];
> +
> +		/* ALU */
> +#define ALU(OPCODE, OP) \
> +	L_BPF_ALU64##OPCODE##BPF_X: \
> +		A = A OP X; \
> +		CONT; \
> +	L_BPF_ALU##OPCODE##BPF_X: \
> +		A = (u32)A OP (u32)X; \
> +		CONT; \
> +	L_BPF_ALU64##OPCODE##BPF_K: \
> +		A = A OP K; \
> +		CONT; \
> +	L_BPF_ALU##OPCODE##BPF_K: \
> +		A = (u32)A OP (u32)K; \
> +		CONT;
> +
> +	ALU(BPF_ADD, +)
> +	ALU(BPF_SUB, -)
> +	ALU(BPF_AND, &)
> +	ALU(BPF_OR, |)
> +	ALU(BPF_LSH, <<)
> +	ALU(BPF_RSH, >>)
> +	ALU(BPF_XOR, ^)
> +	ALU(BPF_MUL, *)
> +
> +	L(BPF_ALU, BPF_NEG, 0)
> +		A = (u32)-A;
> +		CONT;
> +	L(BPF_ALU, BPF_MOV, BPF_X)
> +		A = (u32)X;
> +		CONT;
> +	L(BPF_ALU, BPF_MOV, BPF_K)
> +		A = (u32)K;
> +		CONT;
> +	L(BPF_ALU64, BPF_MOV, BPF_X)
> +		A = X;
> +		CONT;
> +	L(BPF_ALU64, BPF_MOV, BPF_K)
> +		A = K;
> +		CONT;
> +	L(BPF_ALU64, BPF_ARSH, BPF_X)
> +		(*(s64 *) &A) >>= X;
> +		CONT;
> +	L(BPF_ALU64, BPF_ARSH, BPF_K)
> +		(*(s64 *) &A) >>= K;
> +		CONT;
> +	L(BPF_ALU64, BPF_MOD, BPF_X)
> +		tmp = A;
> +		if (X)
> +			A = do_div(tmp, X);
> +		CONT;
> +	L(BPF_ALU, BPF_MOD, BPF_X)
> +		tmp = (u32)A;
> +		if (X)
> +			A = do_div(tmp, (u32)X);
> +		CONT;
> +	L(BPF_ALU64, BPF_MOD, BPF_K)
> +		tmp = A;
> +		if (K)
> +			A = do_div(tmp, K);
> +		CONT;
> +	L(BPF_ALU, BPF_MOD, BPF_K)
> +		tmp = (u32)A;
> +		if (K)
> +			A = do_div(tmp, (u32)K);
> +		CONT;
> +	L(BPF_ALU64, BPF_DIV, BPF_X)
> +		if (X)
> +			do_div(A, X);
> +		CONT;
> +	L(BPF_ALU, BPF_DIV, BPF_X)
> +		tmp = (u32)A;
> +		if (X)
> +			do_div(tmp, (u32)X);
> +		A = (u32)tmp;
> +		CONT;
> +	L(BPF_ALU64, BPF_DIV, BPF_K)
> +		if (K)
> +			do_div(A, K);
> +		CONT;
> +	L(BPF_ALU, BPF_DIV, BPF_K)
> +		tmp = (u32)A;
> +		if (K)
> +			do_div(tmp, (u32)K);
> +		A = (u32)tmp;
> +		CONT;
> +	L(BPF_ALU64, BPF_BSWAP32, BPF_X)
> +		A = swab32(A);
> +		CONT;
> +	L(BPF_ALU64, BPF_BSWAP64, BPF_X)
> +		A = swab64(A);
> +		CONT;
> +
> +		/* CALL */
> +	L(BPF_JMP, BPF_CALL, 0)
> +		/* TODO execute_func(K, regs); */
> +		CONT;

Would the filter checker for now just return -EINVAL when this is used?

> +		/* JMP */
> +	L(BPF_JMP, BPF_JA, 0)
> +		insn += insn->off;
> +		CONT;
> +	L(BPF_JMP, BPF_JEQ, BPF_X)
> +		if (A == X) {
> +			insn += insn->off;
> +			CONT_JMP;
> +		}
> +		CONT;
> +	L(BPF_JMP, BPF_JEQ, BPF_K)
> +		if (A == K) {
> +			insn += insn->off;
> +			CONT_JMP;
> +		}
> +		CONT;
> +	L(BPF_JMP, BPF_JNE, BPF_X)
> +		if (A != X) {
> +			insn += insn->off;
> +			CONT_JMP;
> +		}
> +		CONT;
> +	L(BPF_JMP, BPF_JNE, BPF_K)
> +		if (A != K) {
> +			insn += insn->off;
> +			CONT_JMP;
> +		}
> +		CONT;
> +	L(BPF_JMP, BPF_JGT, BPF_X)
> +		if (A > X) {
> +			insn += insn->off;
> +			CONT_JMP;
> +		}
> +		CONT;
> +	L(BPF_JMP, BPF_JGT, BPF_K)
> +		if (A > K) {
> +			insn += insn->off;
> +			CONT_JMP;
> +		}
> +		CONT;
> +	L(BPF_JMP, BPF_JGE, BPF_X)
> +		if (A >= X) {
> +			insn += insn->off;
> +			CONT_JMP;
> +		}
> +		CONT;
> +	L(BPF_JMP, BPF_JGE, BPF_K)
> +		if (A >= K) {
> +			insn += insn->off;
> +			CONT_JMP;
> +		}
> +		CONT;
> +	L(BPF_JMP, BPF_JSGT, BPF_X)
> +		if (((s64)A) > ((s64)X)) {
> +			insn += insn->off;
> +			CONT_JMP;
> +		}
> +		CONT;
> +	L(BPF_JMP, BPF_JSGT, BPF_K)
> +		if (((s64)A) > ((s64)K)) {
> +			insn += insn->off;
> +			CONT_JMP;
> +		}
> +		CONT;
> +	L(BPF_JMP, BPF_JSGE, BPF_X)
> +		if (((s64)A) >= ((s64)X)) {
> +			insn += insn->off;
> +			CONT_JMP;
> +		}
> +		CONT;
> +	L(BPF_JMP, BPF_JSGE, BPF_K)
> +		if (((s64)A) >= ((s64)K)) {
> +			insn += insn->off;
> +			CONT_JMP;
> +		}
> +		CONT;
> +	L(BPF_JMP, BPF_JSET, BPF_X)
> +		if (A & X) {
> +			insn += insn->off;
> +			CONT_JMP;
> +		}
> +		CONT;
> +	L(BPF_JMP, BPF_JSET, BPF_K)
> +		if (A & (u32)K) {
> +			insn += insn->off;
> +			CONT_JMP;
> +		}
> +		CONT;

Okay, so right now we only support forward jumps, right? And these
are checked by the old checker code I'd assume?

> +		/* STX and ST and LDX*/
> +#define LDST(SIZEOP, SIZE) \
> +	L_BPF_STXBPF_MEM##SIZEOP: \
> +		*(SIZE *)(ulong)(A + insn->off) = X; \
> +		CONT; \
> +	L_BPF_STBPF_MEM##SIZEOP: \
> +		*(SIZE *)(ulong)(A + insn->off) = K; \
> +		CONT; \
> +	L_BPF_LDXBPF_MEM##SIZEOP: \
> +		A = *(SIZE *)(ulong)(X + insn->off); \
> +		CONT;
> +
> +		LDST(BPF_B, u8)
> +		LDST(BPF_H, u16)
> +		LDST(BPF_W, u32)
> +		LDST(BPF_DW, u64)
> +
> +		/* STX XADD */
> +	L(BPF_STX, BPF_XADD, BPF_W)
> +		atomic_add((u32)X, (atomic_t *)(ulong)(A + insn->off));
> +		CONT;
> +#ifdef CONFIG_64BIT
> +	L(BPF_STX, BPF_XADD, BPF_DW)
> +		atomic64_add((u64)X, (atomic64_t *)(ulong)(A + insn->off));
> +		CONT;
> +#endif
> +
> +		/* LD from SKB + K */

Nit: indent one tab too much (here and elsewhere)

> +	L(BPF_LD, BPF_ABS, BPF_W)
> +		off = K;
> +load_word:
> +		ptr = load_pointer((struct sk_buff *)ctx, off, 4, &tmp);
> +		if (likely(ptr != NULL)) {
> +			A = get_unaligned_be32(ptr);
> +			CONT;
> +		}
> +		return 0;
> +
> +	L(BPF_LD, BPF_ABS, BPF_H)
> +		off = K;
> +load_half:
> +		ptr = load_pointer((struct sk_buff *)ctx, off, 2, &tmp);
> +		if (likely(ptr != NULL)) {
> +			A = get_unaligned_be16(ptr);
> +			CONT;
> +		}
> +		return 0;
> +
> +	L(BPF_LD, BPF_ABS, BPF_B)
> +		off = K;
> +load_byte:
> +		ptr = load_pointer((struct sk_buff *)ctx, off, 1, &tmp);
> +		if (likely(ptr != NULL)) {
> +			A = *(u8 *)ptr;
> +			CONT;
> +		}
> +		return 0;
> +
> +		/* LD from SKB + X + K */

Nit: ditto

> +	L(BPF_LD, BPF_IND, BPF_W)
> +		off = K + X;
> +		goto load_word;
> +
> +	L(BPF_LD, BPF_IND, BPF_H)
> +		off = K + X;
> +		goto load_half;
> +
> +	L(BPF_LD, BPF_IND, BPF_B)
> +		off = K + X;
> +		goto load_byte;
> +
> +		/* RET */
> +	L(BPF_RET, BPF_K, 0)
> +		return regs[0/* R0 */];
> +
> +	L_default:
> +		/* bpf_check() or bpf_convert() will guarantee that
> +		 * we never reach here
> +		 */
> +		WARN_RATELIMIT(1, "unknown opcode %02x\n", insn->code);
> +		return 0;
> +#undef DL
> +#undef L
> +#undef CONT
> +#undef A
> +#undef X
> +#undef K
> +#undef LOAD_IMM
> +#undef DEBUG_INSN
> +#undef ALU
> +#undef LDST
> +}
> +EXPORT_SYMBOL(bpf_run);
> +
> diff --git a/net/core/filter.c b/net/core/filter.c
> index ad30d626a5bd..575bf5fd4335 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -637,6 +637,10 @@ void sk_filter_release_rcu(struct rcu_head *rcu)
>   {
>   	struct sk_filter *fp = container_of(rcu, struct sk_filter, rcu);
>
> +	if ((void *)fp->bpf_func == (void *)bpf_run)
> +		/* arch specific jit_free are expecting this value */
> +		fp->bpf_func = sk_run_filter;
> +
>   	bpf_jit_free(fp);
>   }
>   EXPORT_SYMBOL(sk_filter_release_rcu);
> @@ -655,6 +659,81 @@ static int __sk_prepare_filter(struct sk_filter *fp)
>   	return 0;
>   }
>
> +static int bpf64_prepare(struct sk_filter **pfp, struct sock_fprog *fprog,
> +			 struct sock *sk)
> +{

sk_prepare_filter_ext()?

> +	unsigned int fsize = sizeof(struct sock_filter) * fprog->len;
> +	struct sock_filter *old_prog;
> +	unsigned int sk_fsize;
> +	struct sk_filter *fp;
> +	int new_len;
> +	int err;
> +
> +	/* store old program into buffer, since chk_filter will remap opcodes */
> +	old_prog = kmalloc(fsize, GFP_KERNEL);
> +	if (!old_prog)
> +		return -ENOMEM;
> +
> +	if (sk) {
> +		if (copy_from_user(old_prog, fprog->filter, fsize)) {
> +			err = -EFAULT;
> +			goto free_prog;
> +		}
> +	} else {
> +		memcpy(old_prog, fprog->filter, fsize);
> +	}
> +
> +	/* calculate bpf64 program length */
> +	err = bpf_convert(fprog->filter, fprog->len, NULL, &new_len);
> +	if (err)
> +		goto free_prog;
> +
> +	sk_fsize = sk_filter_size(new_len);
> +	/* allocate sk_filter to store bpf64 program */
> +	if (sk)
> +		fp = sock_kmalloc(sk, sk_fsize, GFP_KERNEL);
> +	else
> +		fp = kmalloc(sk_fsize, GFP_KERNEL);
> +	if (!fp) {
> +		err = -ENOMEM;
> +		goto free_prog;
> +	}
> +
> +	/* remap old insns into bpf64 */
> +	err = bpf_convert(old_prog, fprog->len,
> +			  (struct bpf_insn *)fp->insns, &new_len);
> +	if (err)
> +		/* 2nd bpf_convert() can fail only if it fails
> +		 * to allocate memory, remapping must succeed
> +		 */
> +		goto free_fp;
> +
> +	/* now chk_filter can overwrite old_prog while checking */
> +	err = sk_chk_filter(old_prog, fprog->len);
> +	if (err)
> +		goto free_fp;
> +
> +	/* discard old prog */
> +	kfree(old_prog);
> +
> +	atomic_set(&fp->refcnt, 1);
> +	fp->len = new_len;
> +
> +	/* bpf64 insns must be executed by bpf_run */
> +	fp->bpf_func = (typeof(fp->bpf_func))bpf_run;
> +
> +	*pfp = fp;
> +	return 0;
> +free_fp:
> +	if (sk)
> +		sock_kfree_s(sk, fp, sk_fsize);
> +	else
> +		kfree(fp);
> +free_prog:
> +	kfree(old_prog);
> +	return err;
> +}
> +
>   /**
>    *	sk_unattached_filter_create - create an unattached filter
>    *	@fprog: the filter program
> @@ -676,6 +755,9 @@ int sk_unattached_filter_create(struct sk_filter **pfp,
>   	if (fprog->filter == NULL)
>   		return -EINVAL;
>
> +	if (bpf64_enable)
> +		return bpf64_prepare(pfp, fprog, NULL);
> +
>   	fp = kmalloc(sk_filter_size(fprog->len), GFP_KERNEL);
>   	if (!fp)
>   		return -ENOMEM;
> @@ -726,21 +808,27 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
>   	if (fprog->filter == NULL)
>   		return -EINVAL;
>
> -	fp = sock_kmalloc(sk, sk_fsize, GFP_KERNEL);
> -	if (!fp)
> -		return -ENOMEM;
> -	if (copy_from_user(fp->insns, fprog->filter, fsize)) {
> -		sock_kfree_s(sk, fp, sk_fsize);
> -		return -EFAULT;
> -	}
> +	if (bpf64_enable) {
> +		err = bpf64_prepare(&fp, fprog, sk);
> +		if (err)
> +			return err;
> +	} else {
> +		fp = sock_kmalloc(sk, sk_fsize, GFP_KERNEL);
> +		if (!fp)
> +			return -ENOMEM;
> +		if (copy_from_user(fp->insns, fprog->filter, fsize)) {
> +			sock_kfree_s(sk, fp, sk_fsize);
> +			return -EFAULT;
> +		}
>
> -	atomic_set(&fp->refcnt, 1);
> -	fp->len = fprog->len;
> +		atomic_set(&fp->refcnt, 1);
> +		fp->len = fprog->len;
>
> -	err = __sk_prepare_filter(fp);
> -	if (err) {
> -		sk_filter_uncharge(sk, fp);
> -		return err;
> +		err = __sk_prepare_filter(fp);
> +		if (err) {
> +			sk_filter_uncharge(sk, fp);
> +			return err;
> +		}
>   	}
>
>   	old_fp = rcu_dereference_protected(sk->sk_filter,
> diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
> index cf9cd13509a7..f03acc0e8950 100644
> --- a/net/core/sysctl_net_core.c
> +++ b/net/core/sysctl_net_core.c
> @@ -273,6 +273,13 @@ static struct ctl_table net_core_table[] = {
>   	},
>   #endif
>   	{
> +		.procname	= "bpf64_enable",
> +		.data		= &bpf64_enable,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec
> +	},
> +	{
>   		.procname	= "netdev_tstamp_prequeue",
>   		.data		= &netdev_tstamp_prequeue,
>   		.maxlen		= sizeof(int),
>

Hope some of the comments made sense. ;-)

Thanks,

Daniel
