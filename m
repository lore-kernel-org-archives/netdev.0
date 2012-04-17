From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH] net: filter: Just In Time compiler for sparc
Date: Tue, 17 Apr 2012 21:57:16 +0200
Message-ID: <20120417195716.GA26750@merkur.ravnborg.org>
References: <20120416.225823.1395194623649559124.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, sparclinux@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <sparclinux-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120416.225823.1395194623649559124.davem@davemloft.net>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David.

I am glad to see sparc32 covered as well as sparc64 - but you knew that.

A few nits below.

I did not find the time to walk through it so I understood
the functionality. But I guess netdev's will do so.

I hope you had some fun doing this work - it does not look simple!

	Sam

> diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
> index db4e821..9f9afd9 100644
> --- a/arch/sparc/Kconfig
> +++ b/arch/sparc/Kconfig
> @@ -30,6 +30,7 @@ config SPARC
>  	select USE_GENERIC_SMP_HELPERS if SMP
>  	select GENERIC_PCI_IOMAP
>  	select HAVE_NMI_WATCHDOG if SPARC64
> +	select HAVE_BPF_JIT
If we sorted this block of select then the chances
for merge conflict would be smaller.
But this is not this patch to do so.

> +#define r_TMP		G1
> +#define r_TMP2		G2
> +#define r_OFF		G3
> +#else
> +#define r_SKB		%o0
> +#define r_A		%o1
> +#define r_X		%o2
> +#define r_saved_O7	%o3
> +#define r_HEADLEN	%o4
> +#define r_SKB_DATA	%o5
> +#define r_TMP		%g1
> +#define r_TMP2		%g2
> +#define r_OFF		%g3
> +#endif
Nice helpers - they made it easier for me to follow the assembler.
r_SKB is not used in assembler?

> +++ b/arch/sparc/net/bpf_jit_asm.S
> @@ -0,0 +1,199 @@
> +#include <asm/ptrace.h>
> +
> +#include "bpf_jit.h"
> +
> +#ifdef CONFIG_SPARC64
> +#define SAVE_SZ		176
> +#define SCRATCH_OFF	STACK_BIAS + 128
> +#define BE_PTR(label)	be,pn %xcc, label
> +#else
> +#define SAVE_SZ		96
> +#define SCRATCH_OFF	72
> +#define BE_PTR(label)	be label
> +#endif

Is it coincidentally that SAVE_SZ has same value as BASE_STACKFRAME?
>From my quick browse of the code I think this is two distinct things,
but if not we should move the definition to the header file and use the same.


> +bpf_error:
> +	jmpl	r_saved_O7 + 8, %g0
> +	 clr	%o0

I wondered about this - because this is the only reference to %03 aka r_saved_O7
And then the + 8 also puzzeled me.

A small comment would be nice.


> diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
> new file mode 100644
> index 0000000..86349ca
> --- /dev/null
> +++ b/arch/sparc/net/bpf_jit_comp.c
> @@ -0,0 +1,785 @@
> +#include <linux/moduleloader.h>
> +#include <linux/workqueue.h>
> +#include <linux/netdevice.h>
> +#include <linux/filter.h>
> +#include <linux/cache.h>
> +
> +#include <asm/cacheflush.h>
> +#include <asm/ptrace.h>
> +
> +#include "bpf_jit.h"
> +
> +int bpf_jit_enable __read_mostly;
> +
> +/* assembly code in arch/sparc/net/bpf_jit_asm.S */
> +extern u32 bpf_jit_load_word[];
> +extern u32 bpf_jit_load_half[];
> +extern u32 bpf_jit_load_byte[];
> +extern u32 bpf_jit_load_byte_msh[];
> +extern u32 bpf_jit_load_word_positive_offset[];
> +extern u32 bpf_jit_load_half_positive_offset[];
> +extern u32 bpf_jit_load_byte_positive_offset[];
> +extern u32 bpf_jit_load_byte_msh_positive_offset[];
> +extern u32 bpf_jit_load_word_negative_offset[];
> +extern u32 bpf_jit_load_half_negative_offset[];
> +extern u32 bpf_jit_load_byte_negative_offset[];
> +extern u32 bpf_jit_load_byte_msh_negative_offset[];

I know this is from assembler files - but I hate externs in .c files.
sparse did not complain though.

> +#define CONDN		COND (0x0)
> +#define CONDE		COND (0x1)
> +#define CONDLE		COND (0x2)
> +#define CONDL		COND (0x3)
> +#define CONDLEU		COND (0x4)
> +#define CONDCS		COND (0x5)
> +#define CONDNEG		COND (0x6)
> +#define CONDVC		COND (0x7)
> +#define CONDA		COND (0x8)
> +#define CONDNE		COND (0x9)
> +#define CONDG		COND (0xa)
> +#define CONDGE		COND (0xb)
> +#define CONDGU		COND (0xc)
> +#define CONDCC		COND (0xd)
> +#define CONDPOS		COND (0xe)
> +#define CONDVS		COND (0xf)

The added space between COND and (0x..) looks strange to me.

> +} while (0)
> +
> +	/* Emit
> +	 *
> +	 * 	OP	r_A, r_X, r_A
> +	 */
My vim marks the mixed spaces/tabs before OP with red.

> +do {			   					\
Mixed spaces and tabs (vim is again red here)

> +	if (K) {						\
> +		unsigned int _insn = OPCODE;			\
> +		_insn |= RS1(r_A) | RD(r_A);			\
> +		if (is_simm13(K)) {				\
> +			*prog++ = _insn | IMMED | S13(K);	\
> +		} else {					\
> +			emit_set_const(K, r_TMP);		\
> +			*prog++ = _insn | RS2(r_TMP);		\
> +		}		  	  			\
Mixed spaces and tabs.

> +#define emit_loadptr(BASE, STRUCT, FIELD, DEST)				\
> +do {	unsigned int _off = offsetof(STRUCT, FIELD);			\
> +	BUILD_BUG_ON(FIELD_SIZEOF(STRUCT, FIELD) != sizeof(void *));	\
> +	*prog++ = LDPTRI | RS1(BASE) | S13(_off) | RD(DEST);		\
> +} while(0)
          ^
Missing space. Repeats in the following macros.

> #define emit_read_y(REG)        *prog++ = RD_Y | RD(REG);
> #define emit_write_y(REG)       *prog++ = WR_Y | IMMED | RS1(REG) | S13(0);
Mixed spaces and tabs, (The above is pasted).


> +		proglen = 0;
> +		prog = temp;
> +
> +		/* Prologue */
> +		if (seen_or_pass0) {
> +			if (seen_or_pass0 & SEEN_MEM) {
> +				unsigned int sz = BASE_STACKFRAME;
> +				sz += BPF_MEMWORDS * sizeof(u32);
> +				emit_alloc_stack(sz);
> +			}
> +
> +			/* Make sure we dont leek kernel memory. */
> +			if (seen_or_pass0 & SEEN_XREG)
> +				emit_clear(r_X);
> +
> +			/* If this filter needs to access skb data,
> +			 * load %o4 and %o4 with:
> +			 *  %o4 = skb->len - skb->data_len
> +			 *  %o5 = skb->data
We have nice menonics for o4 and o5 (r_HEADLEN, r_SKB_DATA),
but I assume you follow the registers easier.


> +			 * And also back up %o7 into r_saved_O7 so we can
> +			 * invoke the stubs using 'call'.
> +			 */
> +			if (seen_or_pass0 & SEEN_DATAREF) {
> +				emit_load32(r_SKB, struct sk_buff, len, r_HEADLEN);
> +				emit_load32(r_SKB, struct sk_buff, data_len, r_TMP);
> +				emit_sub(r_HEADLEN, r_TMP, r_HEADLEN);
> +				emit_loadptr(r_SKB, struct sk_buff, data, r_SKB_DATA);
> +			}
> +		}
> +		emit_reg_move(O7, r_saved_O7);
I want to say that I have seen this use of saved_O7 - but it did not help me.

> +#ifdef CONFIG_SPARC32
> +					emit_branch(BE, t_offset + 20);
> +#else
> +					emit_branch(BE, t_offset + 8);
> +#endif

What are these magic 8 and 20?


> +					emit_nop(); /* delay slot */
> +				} else {
> +					emit_branch_off(BNE, 16);
> +					emit_nop();
> +#ifdef CONFIG_SPARC32
> +					emit_jump(cleanup_addr + 20);
> +#else
> +					emit_jump(cleanup_addr + 8);
> +#endif
Here they are again.

> +					emit_clear(r_A);
> +				}
> +				emit_write_y(G0);
> +#ifdef CONFIG_SPARC32
> +				emit_nop();
> +				emit_nop();
> +				emit_nop();
> +#endif
Why these nops? Comment?

