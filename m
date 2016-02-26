From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v4 net-next] net: Implement fast csum_partial for x86_64
Date: Fri, 26 Feb 2016 14:52:05 -0800
Message-ID: <CAKgT0UfjM6jpGwJpXb=w6VX5P0SqzKe41HGCzp=Rz6stpO6Ucg@mail.gmail.com>
References: <1456516995-3471163-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com,
	x86@kernel.org, Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:34730 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753919AbcBZWwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 17:52:07 -0500
Received: by mail-io0-f172.google.com with SMTP id 9so132396131iom.1
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 14:52:06 -0800 (PST)
In-Reply-To: <1456516995-3471163-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 26, 2016 at 12:03 PM, Tom Herbert <tom@herbertland.com> wrote:
> This patch implements performant csum_partial for x86_64. The intent is
> to speed up checksum calculation, particularly for smaller lengths such
> as those that are present when doing skb_postpull_rcsum when getting
> CHECKSUM_COMPLETE from device or after CHECKSUM_UNNECESSARY conversion.
>
> - v4
>    - went back to C code with inline assembly for critical routines
>    - implemented suggestion from Linus to deal with lengths < 8
>
> Testing:
>
> Correctness:
>
> Verified correctness by testing arbitrary length buffer filled with
> random data. For each buffer I compared the computed checksum
> using the original algorithm for each possible alignment (0-7 bytes).
>
> Performance:
>
> Isolating old and new implementation for some common cases:
>
>              Old      New     %
>     Len/Aln  nsecs    nsecs   Improv
>     --------+-------+--------+-------
>     1400/0    195.6    181.7   7%     (Big packet)
>     40/0      11.4     6.2     45%    (Ipv6 hdr cmn case)
>     8/4       7.9      3.2     59%    (UDP, VXLAN in IPv4)
>     14/0      8.9      5.9     33%    (Eth hdr)
>     14/4      9.2      5.9     35%    (Eth hdr in IPv4)
>     14/3      9.6      5.9     38%    (Eth with odd align)
>     20/0      9.0      6.2     31%    (IP hdr without options)
>     7/1       8.9      4.2     52%    (buffer in one quad)
>     100/0    17.4     13.9     20%    (medium-sized pkt)
>     100/2    17.8     14.2     20%    (medium-sized pkt w/ alignment)
>
> Results from: Intel(R) Xeon(R) CPU X5650 @ 2.67GHz
>
> Also tested on these with similar results:
>
> Intel(R) Xeon(R) CPU E5-2660 v2 @ 2.20GHz
> Intel(R) Xeon(R) CPU E5-2680 v2 @ 2.80GHz
>
> Branch  prediction:
>
> To test the effects of poor branch prediction in the jump tables I
> tested checksum performance with runs for two combinations of length
> and alignment. As the baseline I performed the test by doing half of
> calls with the first combination, followed by using the second
> combination for the second half. In the test case, I interleave the
> two combinations so that in every call the length and alignment are
> different to defeat the effects of branch prediction. Running several
> cases, I did not see any material performance difference between the
> two scenarios (perf stat output is below), neither does either case
> show a significant number of branch misses.
>
> Interleave lengths case:
>
> perf stat --repeat 10 -e '{instructions, branches, branch-misses}' \
>     ./csum -M new-thrash -I -l 100 -S 24 -a 1 -c 100000000
>
>  Performance counter stats for './csum -M new-thrash -I -l 100 -S 24 -a 1 -c 100000000' (10 runs):
>
>      9,556,693,202      instructions               ( +-  0.00% )
>      1,176,208,640       branches                                                     ( +-  0.00% )
>             19,487       branch-misses            #    0.00% of all branches          ( +-  6.07% )
>
>        2.049732539 seconds time elapsed
>
>     Non-interleave case:
>
> perf stat --repeat 10 -e '{instructions, branches, branch-misses}' \
>      ./csum -M new-thrash -l 100 -S 24 -a 1 -c 100000000
>
> Performance counter stats for './csum -M new-thrash -l 100 -S 24 -a 1 -c 100000000' (10 runs):
>
>      9,782,188,310      instructions               ( +-  0.00% )
>      1,251,286,958       branches                                                     ( +-  0.01% )
>             18,950       branch-misses            #    0.00% of all branches          ( +- 12.74% )
>
>        2.271789046 seconds time elapsed
>
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  arch/x86/include/asm/checksum_64.h |  21 ++++
>  arch/x86/lib/csum-partial_64.c     | 225 ++++++++++++++++++++-----------------
>  2 files changed, 143 insertions(+), 103 deletions(-)
>
> diff --git a/arch/x86/include/asm/checksum_64.h b/arch/x86/include/asm/checksum_64.h
> index cd00e17..e20c35b 100644
> --- a/arch/x86/include/asm/checksum_64.h
> +++ b/arch/x86/include/asm/checksum_64.h
> @@ -188,6 +188,27 @@ static inline unsigned add32_with_carry(unsigned a, unsigned b)
>         return a;
>  }
>
> +static inline unsigned long add64_with_carry(unsigned long a, unsigned long b)
> +{
> +       asm("addq %2,%0\n\t"
> +           "adcq $0,%0"
> +           : "=r" (a)
> +           : "0" (a), "rm" (b));
> +       return a;
> +}
> +
> +static inline unsigned int add32_with_carry3(unsigned int a, unsigned int b,
> +                                            unsigned int c)
> +{
> +       asm("addl %2,%0\n\t"
> +           "adcl %3,%0\n\t"
> +           "adcl $0,%0"
> +           : "=r" (a)
> +           : "" (a), "rm" (b), "rm" (c));
> +
> +       return a;
> +}
> +
>  #define HAVE_ARCH_CSUM_ADD
>  static inline __wsum csum_add(__wsum csum, __wsum addend)
>  {
> diff --git a/arch/x86/lib/csum-partial_64.c b/arch/x86/lib/csum-partial_64.c
> index 9845371..df82c9b 100644
> --- a/arch/x86/lib/csum-partial_64.c
> +++ b/arch/x86/lib/csum-partial_64.c
> @@ -8,114 +8,66 @@
>  #include <linux/compiler.h>
>  #include <linux/module.h>
>  #include <asm/checksum.h>
> +#include <asm/word-at-a-time.h>
>
> -static inline unsigned short from32to16(unsigned a)
> +static inline unsigned long rotate_by8_if_odd(unsigned long sum, bool aligned)
>  {
> -       unsigned short b = a >> 16;
> -       asm("addw %w2,%w0\n\t"
> -           "adcw $0,%w0\n"
> -           : "=r" (b)
> -           : "0" (b), "r" (a));
> -       return b;
> +       if (unlikely(aligned))
> +               asm("rorq $0x8,%0"
> +                       : "=r" (sum)
> +                       : "0" (sum));
> +       return sum;
>  }

Instead of making this conditional you might just want to perform the
rotate always and just bump the aligned value up bits.  That way you
reduce the length of the dependency chain by 1, and rotates tend to
only take a cycle on most x86_64 capable systems anyways.

>
> -/*
> - * Do a 64-bit checksum on an arbitrary memory area.
> - * Returns a 32bit checksum.
> - *
> - * This isn't as time critical as it used to be because many NICs
> - * do hardware checksumming these days.
> - *
> - * Things tried and found to not make it faster:
> - * Manual Prefetching
> - * Unrolling to an 128 bytes inner loop.
> - * Using interleaving with more registers to break the carry chains.
> - */
> -static unsigned do_csum(const unsigned char *buff, unsigned len)
> +/* Extract eight high order (nbo) bytes of quad "val". */
> +static inline unsigned long csum_partial_lt8_head(unsigned long val, int len)
>  {
> -       unsigned odd, count;
> -       unsigned long result = 0;
> +       return val & ((1ul << len * 8) - 1);
> +}
>
> -       if (unlikely(len == 0))
> -               return result;
> -       odd = 1 & (unsigned long) buff;
> -       if (unlikely(odd)) {
> -               result = *buff << 8;
> -               len--;
> -               buff++;
> -       }
> -       count = len >> 1;               /* nr of 16-bit words.. */
> -       if (count) {
> -               if (2 & (unsigned long) buff) {
> -                       result += *(unsigned short *)buff;
> -                       count--;
> -                       len -= 2;
> -                       buff += 2;
> -               }
> -               count >>= 1;            /* nr of 32-bit words.. */
> -               if (count) {
> -                       unsigned long zero;
> -                       unsigned count64;
> -                       if (4 & (unsigned long) buff) {
> -                               result += *(unsigned int *) buff;
> -                               count--;
> -                               len -= 4;
> -                               buff += 4;
> -                       }
> -                       count >>= 1;    /* nr of 64-bit words.. */
> -
> -                       /* main loop using 64byte blocks */
> -                       zero = 0;
> -                       count64 = count >> 3;
> -                       while (count64) {
> -                               asm("addq 0*8(%[src]),%[res]\n\t"
> -                                   "adcq 1*8(%[src]),%[res]\n\t"
> -                                   "adcq 2*8(%[src]),%[res]\n\t"
> -                                   "adcq 3*8(%[src]),%[res]\n\t"
> -                                   "adcq 4*8(%[src]),%[res]\n\t"
> -                                   "adcq 5*8(%[src]),%[res]\n\t"
> -                                   "adcq 6*8(%[src]),%[res]\n\t"
> -                                   "adcq 7*8(%[src]),%[res]\n\t"
> -                                   "adcq %[zero],%[res]"
> -                                   : [res] "=r" (result)
> -                                   : [src] "r" (buff), [zero] "r" (zero),
> -                                   "[res]" (result));
> -                               buff += 64;
> -                               count64--;
> -                       }
> -
> -                       /* last up to 7 8byte blocks */
> -                       count %= 8;
> -                       while (count) {
> -                               asm("addq %1,%0\n\t"
> -                                   "adcq %2,%0\n"
> -                                           : "=r" (result)
> -                                   : "m" (*(unsigned long *)buff),
> -                                   "r" (zero),  "0" (result));
> -                               --count;
> -                                       buff += 8;
> -                       }
> -                       result = add32_with_carry(result>>32,
> -                                                 result&0xffffffff);
> -
> -                       if (len & 4) {
> -                               result += *(unsigned int *) buff;
> -                               buff += 4;
> -                       }
> -               }
> -               if (len & 2) {
> -                       result += *(unsigned short *) buff;
> -                       buff += 2;
> -               }
> -       }
> -       if (len & 1)
> -               result += *buff;
> -       result = add32_with_carry(result>>32, result & 0xffffffff);
> -       if (unlikely(odd)) {
> -               result = from32to16(result);
> -               result = ((result >> 8) & 0xff) | ((result & 0xff) << 8);
> +/* Extract eight low order (nbo) bytes of quad in "val". */
> +static inline unsigned long csum_partial_lt8_tail(unsigned long val, int len)
> +{
> +       return val >> (8 * (8 - len));
> +}

>From what I can tell these functions only get used in one or two
spots.  It may be worth it to just place the code directly in the
function rather than obscuring it by placing it in a function.

> +/* Sum over buffer up to 64 bytes. */
> +static unsigned long csum_partial_le64(const void *buff, unsigned int len,
> +                                      unsigned long sum)
> +{
> +       asm("lea 40f(, %[slen], 4), %%r11\n\t"
> +           "clc\n\t"
> +           "jmpq *%%r11\n\t"
> +           "adcq 7*8(%[src]),%[res]\n\t"

Technically this first adcq could just be an addq.  You don't have
anything to carry anyway.

> +           "adcq 6*8(%[src]),%[res]\n\t"
> +           "adcq 5*8(%[src]),%[res]\n\t"
> +           "adcq 4*8(%[src]),%[res]\n\t"
> +           "adcq 3*8(%[src]),%[res]\n\t"
> +           "adcq 2*8(%[src]),%[res]\n\t"
> +           "adcq 1*8(%[src]),%[res]\n\t"
> +           "adcq 0*8(%[src]),%[res]\n\t"
> +           "nop\n\t"
> +           "40: adcq $0,%[res]"
> +                   : [res] "=r" (sum)
> +                   : [src] "r" (buff),
> +                     [slen] "r" (-((unsigned long)(len >> 3))), "[res]" (sum)
> +                   : "r11");
> +

It would probably useful to add a comment explaining that this block.
I had to compile it to verify my understanding of this is correct in
that you are using the label 40 as a jump target and simply
subtracting the length in longs from that jump target.  If nothing
else you might want to rename the label from 40 to something else just
to improve the readability.  It is possible that the code could get
shifted around or inlined and at that point the 40 becomes completely
meaningless.

Also it wouldn't hurt to explain that the nop, and the reason for the
4 in the lea instruction is because adcq is 4 bytes per instruction
with a memory offset, and the last one has an offset of 0 so we need
to add the nop to keep everything 4 byte aligned from the end.

> +       if (len & 0x7) {
> +               unsigned long val;
> +               /*
> +                * Since "len" is > 8 here we backtrack in the buffer to load
> +                * the outstaning bytes into the low order bytes of a quad and
> +                * sum those in csum_partial_lt8_tail. By doing this we avoid
> +                * additional calls to load_unaligned_zeropad.
> +                */
> +
> +               val = csum_partial_lt8_tail(*(unsigned long *)(buff + len - 8),
> +                                           len & 0x7);
> +               sum = add64_with_carry(val, sum);
>         }
> -       return result;
> +
> +       return sum;
>  }
>
>  /*
> @@ -130,10 +82,77 @@ static unsigned do_csum(const unsigned char *buff, unsigned len)
>   *
>   * it's best to have buff aligned on a 64-bit boundary
>   */
> +static unsigned int do_csum(const void *buff, int len, unsigned int sum)
> +{
> +       bool aligned = false;
> +       unsigned long result = 0;
> +
> +       /*
> +        * For "small" lengths don't bother with alignment, x86 handles
> +        * this pretty well.
> +        */
> +       if (len <= 8) {
> +               unsigned long val;
> +
> +               /* Optimize trivial cases */
> +               if (len == 8)
> +                       return add32_with_carry3(sum,
> +                                      *(unsigned int *)buff,
> +                                      *(unsigned int *)(buff + 4));

Doesn't this still run the risk of triggering a fault if the buffer
crosses pages on a non-4 byte aligned boundary?

> +               else if (len == 0)
> +                       return sum;
> +
> +               val = load_unaligned_zeropad(buff);
> +               result = csum_partial_lt8_head(val, len);
> +
> +               return add32_with_carry3(sum, result >> 32,
> +                                        result & 0xffffffff);
> +       } else if (len <= 64) {
> +               result = csum_partial_le64(buff, len, result);
> +
> +               return add32_with_carry3(sum, result >> 32,
> +                                        result & 0xffffffff);
> +       }
> +

One side effect I see from the fact that you are calling
csum_partial_le64 in two spots is that you are ending up having to
make a call to it instead of having it be inlined directly into your
do_csum function.  What you may want to do is look at altering your
code flow so that if (len > 64) you do the bits below that occur
before you call into csum_partial_le64, and that way you will reduce
the number of callers to csum_partial_le64 to one which should get the
compiler to inline it into your function.

> +       /*
> +        * Length is greater than 64. Sum to eight byte alignment before
> +        * proceeding with main loop.
> +        */
> +       aligned = !!((unsigned long)buff & 0x1);
> +       if (aligned) {
> +               unsigned int align = 7 & -(unsigned long)buff;
> +
> +               result = csum_partial_lt8_head(*(unsigned long *)buff, align);
> +               buff += align;
> +               len -= align;
> +               result = rotate_by8_if_odd(result, align);
> +       }

I'm still not a fan of the unaligned reads.  They may be okay but it
just seems like we are going run into corner cases all over the place
where this ends up biting us.

> +       /* main loop using 64byte blocks */
> +       for (; len >= 64; len -= 64, buff += 64) {
> +               asm("addq 0*8(%[src]),%[res]\n\t"
> +                   "adcq 1*8(%[src]),%[res]\n\t"
> +                   "adcq 2*8(%[src]),%[res]\n\t"
> +                   "adcq 3*8(%[src]),%[res]\n\t"
> +                   "adcq 4*8(%[src]),%[res]\n\t"
> +                   "adcq 5*8(%[src]),%[res]\n\t"
> +                   "adcq 6*8(%[src]),%[res]\n\t"
> +                   "adcq 7*8(%[src]),%[res]\n\t"
> +                   "adcq $0,%[res]"
> +                   : [res] "=r" (result)
> +                   : [src] "r" (buff),
> +                   "[res]" (result));
> +       }
> +
> +       result = csum_partial_le64(buff, len, result);
> +       result = rotate_by8_if_odd(result, aligned);
> +
> +       return add32_with_carry3(sum, result >> 32, result & 0xffffffff);
> +}
> +
>  __wsum csum_partial(const void *buff, int len, __wsum sum)
>  {
> -       return (__force __wsum)add32_with_carry(do_csum(buff, len),
> -                                               (__force u32)sum);
> +       return (__force __wsum)do_csum(buff, len, (__force u32)sum);
>  }
>
>  /*
> --
> 2.6.5
>
