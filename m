From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v3 net-next] net: Implement fast csum_partial for x86_64
Date: Thu, 4 Feb 2016 10:30:21 +0100
Message-ID: <20160204093021.GB1553@gmail.com>
References: <1454527121-4007853-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, tglx@linutronix.de,
	mingo@redhat.com, hpa@zytor.com, x86@kernel.org,
	kernel-team@fb.com, linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Tom Herbert <tom@herbertland.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1454527121-4007853-1-git-send-email-tom@herbertland.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Tom Herbert <tom@herbertland.com> wrote:

> Implement assembly routine for csum_partial for 64 bit x86. This
> primarily speeds up checksum calculation for smaller lengths such as
> those that are present when doing skb_postpull_rcsum when getting
> CHECKSUM_COMPLETE from device or after CHECKSUM_UNNECESSARY
> conversion.
> 
> CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is checked to determine whether
> we need to avoid unaligned accesses. Efficient unaligned accesses
> offer a nice additional speedup as demonstrated in the results
> provided below.
> 
> This implementation is similar to csum_partial implemented in
> checksum_32.S, however since we are dealing with 8 bytes at a time
> there are more cases for small lengths (and alignments)-- for that
> we employ a jump table.
> 
> Testing:
> 
> Correctness:
> 
> Verified correctness by testing arbitrary length buffer filled with
> random data. For each buffer I compared the computed checksum
> using the original algorithm for each possible alignment (0-7 bytes).
> 
> Checksum performance:
> 
> Isolating old and new implementation for some common cases:
> 
>          Old      NewA     NewA %   NewNoA   NewNoA %
> Len/Aln  nsec     nsec     Improv   nsecs    Improve
> --------+-------+--------+-------+-------+---------------------
> 1400/0    192.9    175.1   10%     174.9     10%   (Big packet)
> 40/0      13.8     7.7     44%     5.7       58%   (Ipv6 hdr cmn case)
> 8/4       8.4      6.9     18%     2.8       67%   (UDP, VXLAN in IPv4)
> 14/0      10.5     7.3     30%     5.4       48%   (Eth hdr)
> 14/4      10.8     8.7     19%     5.4       50%   (Eth hdr in IPv4)
> 14/3      11.0     9.8     11%     5.6       49%   (Eth with odd align)
> 7/1       10.0     5.8     42%     4.8       52%   (buffer in one quad)
> 
> NewA=>CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS not set
> NewNoA=>CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is set
> 
> Results from: Intel(R) Xeon(R) CPU X5650 @ 2.67GHz
> 
> Also test on these with similar results:
> 
> Intel(R) Xeon(R) CPU E5-2660 v2 @ 2.20GHz
> Intel(R) Xeon(R) CPU E5-2680 v2 @ 2.80GHz
> 
> Branch prediction:
> 
> To test the effects of poor branch prediction in the jump tables I
> tested checksum performance with runs for two combinations of length
> and alignment. As the baseline I performed the test by doing half of
> calls with the first combination, followed by using the second
> combination for the second half. In the test case, I interleave the
> two combinations so that in every call the length and alignment are
> different to defeat the effects of branch prediction. Running several
> cases, I did not see any material performance difference between
> the baseline and the interleaving test case.

Possibly because the jumps are missing branch prediction for all these variants...

Please run something like:

 triton:~/tip> perf stat --repeat 10 -e '{instructions, branches, branch-misses}' ~/hackbench 10
 ...

 Performance counter stats for '/home/mingo/hackbench 10' (10 runs):

     1,701,689,802      instructions                                                  ( +-  0.83% )
       305,439,262       branches                                                     ( +-  0.92% )
         2,011,032       branch-misses            #    0.66% of all branches          ( +-  3.00% )

       0.074311070 seconds time elapsed                                          ( +-  2.42% )


... to see the quality of x86 branch prediction and to see the statistical quality 
of the measurement (stddev).

The real comparison would be jump table against a hierarchy of open coded 
branches. The latter is much more likely to be correctly branch-predicted.

I have a couple of (mostly stylistic) comments about the patch:

> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  arch/x86/include/asm/checksum_64.h |   5 +
>  arch/x86/lib/csum-partial_64.S     | 277 +++++++++++++++++++++++++++++++++++++
>  arch/x86/lib/csum-partial_64.c     | 148 --------------------
>  3 files changed, 282 insertions(+), 148 deletions(-)
>  create mode 100644 arch/x86/lib/csum-partial_64.S
>  delete mode 100644 arch/x86/lib/csum-partial_64.c
> 
> diff --git a/arch/x86/include/asm/checksum_64.h b/arch/x86/include/asm/checksum_64.h
> index cd00e17..a888f65 100644
> --- a/arch/x86/include/asm/checksum_64.h
> +++ b/arch/x86/include/asm/checksum_64.h
> @@ -128,6 +128,11 @@ static inline __sum16 csum_tcpudp_magic(__be32 saddr, __be32 daddr,
>   */
>  extern __wsum csum_partial(const void *buff, int len, __wsum sum);
>  
> +static inline __sum16 ip_compute_csum(const void *buff, int len)
> +{
> +	return csum_fold(csum_partial(buff, len, 0));
> +}
> +
>  #define  _HAVE_ARCH_COPY_AND_CSUM_FROM_USER 1
>  #define HAVE_CSUM_COPY_USER 1
>  
> diff --git a/arch/x86/lib/csum-partial_64.S b/arch/x86/lib/csum-partial_64.S
> new file mode 100644
> index 0000000..520b400
> --- /dev/null
> +++ b/arch/x86/lib/csum-partial_64.S
> @@ -0,0 +1,277 @@
> +/* Copyright 2016 Tom Herbert <tom@herbertland.com>
> + *
> + * Checksum partial calculation

s/    Partial checksum calculation

> + *
> + * __wsum csum_partial(const void *buff, int len, __wsum sum)
> + *
> + * Computes the checksum of a memory block at buff, length len,
> + * and adds in "sum" (32-bit)

So please refer to arguments consistently in an escaped manner, i.e. 'buff', 
'len', 'sum'. It's a bit confusing to read otherwise.

This applies to other comments in your patch as well.

> + *
> + * Returns a 32-bit number suitable for feeding into itself
> + * or csum_tcpudp_magic

In comments please refer to functions with (), i.e. csum_tcpudp_magic().

> + *
> + * CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS determines whether alignment of the
> + * buffer must be dealt with.
> + *
> + * If CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is set then the steps are:

s/    If CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y then the steps are:


> + *     1) Initialize accumulator to initial sum
> + *     2) Sum 8 bytes at a time using adcq (unroll main loop
> + *        to do 128 bytes at a time)

Please refer to x86 instructions capitalized, i.e. ADCQ here. That makes them 
stand out better especially when they alias to some English word.

This applies to other parts of your patch as well.

> + *     3) Sum remaining length (less than 8 bytes)
> + *
> + * If CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is not set then the steps are:

s/    If !CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS then the steps are:

> + *     1) Handle buffer that is not aligned to 8 bytes, sum up to 8 byte
> + *        alignment
> + *     2) Sum 8 bytes at a time using adcq (unroll main loop
> + *        to do 128 bytes at a time)
> + *     3) Sum remaining length (less than 8 bytes)
> + *     4) Roll result if alignment is odd and add in initial sum argument
> + *     5) If buffer is not aligned to 8 bytes and length is less than
> + *        or equal to 8 - alignment (whole buffer is in one quad), then
> + *        treat that as a special case.

Had to read it 3 times to realize that '-' is not a separator, so please:

s/8-alignment

> + *
> + * Register usage:
> + *   %rdi: argument #1, buff
> + *   %rsi: argument #2, length
> + *   %rdx: argument #3, add in value
> + *   %rax,%eax: accumulator and return value
> + *   %rcx,%ecx: counter and tmp
> + *   %r11: tmp
> + *   %r10: alignment (0-7) - when CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is set

s/CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y

> + */
> +
> +#include <linux/linkage.h>
> +#include <asm/errno.h>
> +#include <asm/asm.h>
> +
> +#define branch_tbl_len .L_branch_tbl_len
> +
> +#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
> +
> +/* Close the carry chain and return. */
> +#define	RETURN			\
> +	adcl	$0, %eax;	\
> +	ret
> +
> +#else /* CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS */
> +
> +/* Before returning need to roll the result if alignment was odd and then add
> + * in the initial sum.
> + */

Please use the customary (multi-line) comment style:

  /*
   * Comment .....
   * ...... goes here.
   */

specified in Documentation/CodingStyle. This applies to other comments in your 
patch as well.

> +#define	RETURN			\
> +	adcl	$0, %eax;	\
> +	test	$0x1, %r10d;	\
> +	jz	99f;		\
> +	roll	$8, %eax;	\
> +99:	addl	%edx, %eax;	\
> +	adcl	$0, %eax;	\
> +	ret
> +
> +#define branch_tbl_align .L_branch_tbl_align
> +
> +#endif /* CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS */

On x86 we always set CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS.

So this is dead, untested code that is never compiled on x86.

> +
> +ENTRY(csum_partial)
> +
> +#ifdef	CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
> +	movl	%edx, %eax	/* Initialize with initial sum argument */
> +#else	/* CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS */

s/!CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS

> +	test	%esi, %esi	/* Zero length? */
> +	jne	310f
> +	movl	%edx, %eax
> +	ret
> +
> +310:	xorl	%eax, %eax

So in modern x86 assembly we try to use local named labels instead of numeric 
ones. Easier to extend and the result is a lot easier to read. This applies to 
most other numeric labels in your patch.

> +
> +	/* Determine alignment */
> +	movl	%edi, %r10d
> +	andl	$0x7, %r10d
> +	jz	10f
> +	movl	$8, %ecx
> +	subl	%r10d, %ecx
> +	cmpl	%ecx, %esi
> +	jle	320f
> +	clc
> +	jmpq	*branch_tbl_align(, %r10, 8)
> +
> +	/* Whole buffer fits into one quad. Sum up to a four byte alignment
> +	 * and then call into the length table to finish.
> +	 */
> +320:	test	$0x1, %r10d
> +	jz	330f
> +	movb	(%rdi), %ah /* Align to two bytes */
> +	decl	%esi
> +	lea	1(%rdi), %rdi
> +330:	cmpl	$2, %esi
> +	jl	340f
> +	test	$0x2, %r10d
> +	jz	340f
> +	addw	(%rdi), %ax /* Align to four bytes */
> +	adcl	$0, %eax
> +	lea	2(%rdi), %rdi
> +	subl	$2, %esi
> +340:
> +	clc
> +	jmpq *branch_tbl_len(, %rsi, 8)

Also, please use extra newlines to better delineate the control flow.

I.e. something like:

.L_small_buffer:
	test	$0x1, %r10d
	jz	L_2_bytes_aligned:

	/* Align to two bytes: */
	movb	(%rdi), %ah
	decl	%esi
	lea	1(%rdi), %rdi

.L_2_bytes_aligned:
	cmpl	$2, %esi
	jl	.L_4_bytes_aligned

	test	$0x2, %r10d
	jz	.L_4_bytes_aligned

	/* Align to four bytes: */
	addw	(%rdi), %ax
	adcl	$0, %eax
	lea	2(%rdi), %rdi
	subl	$2, %esi

.L_4_bytes_aligned:

See how much more readable such an assembly construct is than numeric labels and 
no proper flow control separation?

Also note how I changed the placement and style of the existing comments.

Note that I just guessed about the labels based on patch context, some might be 
wrong. Also, this code will go away as it's dead code - but the comments still 
apply to the rest of the patch.

Please propagate all such readability improvements to the rest of your patch.

> +
> +/* Jumps table for alignments */

s/Jump table

> +
> +201:	/* Align 1 */
> +	adcw	5(%rdi), %ax
> +203:	/* Align 3 */
> +	adcw	3(%rdi), %ax
> +205:	/* Align 5 */
> +	adcw	1(%rdi), %ax
> +207:	/* Align 7 */
> +	adcl	$0, %eax
> +	addb	(%rdi), %ah
> +	jmp	222f
> +202:	/* Align 2 */
> +	adcw	4(%rdi), %ax
> +204:	/* Align 4 */
> +	adcw	2(%rdi), %ax
> +206:	/* Align 6 */
> +	adcw	(%rdi), %ax
> +
> +222:	adcl	$0, %eax
> +	subl	%ecx, %esi /* %rcx is 8 - alignment */
> +	addq	%rcx, %rdi
> +200:
> +	/* Fall through */
> +
> +#endif /* CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS */

s/!CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS

> +
> +	/* Check length */
> +10:	cmpl	$8, %esi
> +	jg	30f
> +	jl	20f
> +
> +	/* Exactly 8 bytes length */
> +	addl	(%rdi), %eax
> +	adcl	4(%rdi), %eax
> +	RETURN
> +
> +	/* Less than 8 bytes length */
> +20:	clc
> +	jmpq *branch_tbl_len(, %rsi, 8)
> +
> +	/* Greater than 8 bytes length. Determine number of quads (n). Sum
> +	 * over first n % 16 quads
> +	 */
> +30:	movl	%esi, %ecx
> +	shrl	$3, %ecx
> +	andl	$0xf, %ecx
> +	negq	%rcx
> +	lea	40f(, %rcx, 4), %r11
> +	clc
> +	jmp	*%r11

Are you absolutely sure that a jump table is the proper solution here? It defeats 
branch prediction on most x86 uarchs. Why not label the loop stages and jump in 
directly with a binary tree of branches?

> +
> +.align 8
> +	adcq	14*8(%rdi),%rax
> +	adcq	13*8(%rdi),%rax
> +	adcq	12*8(%rdi),%rax
> +	adcq	11*8(%rdi),%rax
> +	adcq	10*8(%rdi),%rax
> +	adcq	9*8(%rdi),%rax
> +	adcq	8*8(%rdi),%rax
> +	adcq	7*8(%rdi),%rax
> +	adcq	6*8(%rdi),%rax
> +	adcq	5*8(%rdi),%rax
> +	adcq	4*8(%rdi),%rax
> +	adcq	3*8(%rdi),%rax
> +	adcq	2*8(%rdi),%rax
> +	adcq	1*8(%rdi),%rax
> +	adcq 	0*8(%rdi),%rax

Stray whitespace.

> +	nop
> +40:	/* #quads % 16 jump table base */

So both the jump table and its initial alignment adds NOPs that at minimum blows 
up the I$ a bit. With direct jumps we could avoid all that.

> +
> +	adcq	$0, %rax
> +	shlq	$3, %rcx
> +	subq	%rcx, %rdi /* %rcx is already negative length */
> +
> +	/* Now determine number of blocks of 8 quads. Sum 128 bytes at a time
> +	 * using unrolled loop.

s/using an unrolled loop

> +	 */
> +	movl	%esi, %ecx
> +	shrl	$7, %ecx
> +	jz	60f
> +	clc
> +
> +	/* Main loop */
> +50:	adcq	0*8(%rdi),%rax
> +	adcq	1*8(%rdi),%rax
> +	adcq	2*8(%rdi),%rax
> +	adcq	3*8(%rdi),%rax
> +	adcq	4*8(%rdi),%rax
> +	adcq	5*8(%rdi),%rax
> +	adcq	6*8(%rdi),%rax
> +	adcq	7*8(%rdi),%rax
> +	adcq	8*8(%rdi),%rax
> +	adcq	9*8(%rdi),%rax
> +	adcq	10*8(%rdi),%rax
> +	adcq	11*8(%rdi),%rax
> +	adcq	12*8(%rdi),%rax
> +	adcq	13*8(%rdi),%rax
> +	adcq	14*8(%rdi),%rax
> +	adcq	15*8(%rdi),%rax
> +	lea	128(%rdi), %rdi
> +	loop	50b
> +
> +	adcq	$0, %rax
> +
> +	/* Handle remaining length which is <= 8 bytes */
> +60:	andl	$0x7, %esi
> +
> +	/* Fold 64 bit sum to 32 bits */

s/64-bit

> +	movq	%rax, %rcx
> +	shrq	$32, %rcx
> +	addl	%ecx, %eax
> +
> +	jmpq *branch_tbl_len(, %rsi, 8)

Same fundamental question as above.

> +
> +/* Length table targets */
> +
> +107:	/* Length 7 */
> +	adcw	4(%rdi), %ax
> +105:	/* Length 5 */
> +	adcw	2(%rdi), %ax
> +103:	/* Length 3 */
> +	adcw	(%rdi), %ax
> +101:	/* Length 1, grab the odd byte */
> +	adcb	-1(%rdi, %rsi), %al
> +	adcb	$0, %ah
> +	RETURN
> +106:	/* Length 6 */
> +	adcw	4(%rdi), %ax
> +104:	/* Length 4, optimized  for double word access*/
> +	adcl	(%rdi), %eax
> +	RETURN
> +102:	/* Length 2 */
> +	adcw	(%rdi), %ax
> +100:	/* Length 0 */
> +	RETURN
> +
> +.section .rodata
> +.align 64

Please use the proper parametric cache alignment define. There are 
subarchitectures that prefer (and need) much larger alignment.

> +.L_branch_tbl_len:
> +	.quad	100b
> +	.quad	101b
> +	.quad	102b
> +	.quad	103b
> +	.quad	104b
> +	.quad	105b
> +	.quad	106b
> +	.quad	107b
> +
> +#ifndef	CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
> +.L_branch_tbl_align:
> +	.quad	200b
> +	.quad	201b
> +	.quad	202b
> +	.quad	203b
> +	.quad	204b
> +	.quad	205b
> +	.quad	206b
> +	.quad	207b
> +#endif

This too is dead code.

Thanks,

	Ingo
