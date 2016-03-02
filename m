From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v5 net-next] net: Implement fast csum_partial for x86_64
Date: Wed, 2 Mar 2016 15:42:48 -0800
Message-ID: <CAKgT0UeApvo7149rAZfUUzYeiykWdzFZvzY-FDZ552A9o74PBg@mail.gmail.com>
References: <1456957112-2702469-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Peter Anvin <hpa@zytor.com>,
	"the arch/x86 maintainers" <x86@kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:37368 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751725AbcCBXmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 18:42:49 -0500
Received: by mail-wm0-f50.google.com with SMTP id p65so10365395wmp.0
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 15:42:49 -0800 (PST)
In-Reply-To: <1456957112-2702469-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 2, 2016 at 2:18 PM, Tom Herbert <tom@herbertland.com> wrote:
> This patch implements performant csum_partial for x86_64. The intent is
> to speed up checksum calculation, particularly for smaller lengths such
> as those that are present when doing skb_postpull_rcsum when getting
> CHECKSUM_COMPLETE from device or after CHECKSUM_UNNECESSARY conversion.
>
> - v4
>    - went back to C code with inline assembly for critical routines
>    - implemented suggestion from Linus to deal with lengths < 8
> - v5
>    - fixed register attribute add32_with_carry3
>    - do_csum returns unsigned long
>    - don't consider alignment at all. Rationalization is that x86
>      handles unaligned accesses very well except in the case that
>      the access crosses a page boundary which has a performance
>      penalty (I see about 10nsecs on my system). Drivers and the
>      stack go to considerable lengths to not have packets cross page
>      boundaries, so the case that csum_partial is called with
>      buffer that crosses a page boundary should be a very rare
>      occurrence. Not dealing with alignment is a significant
>      simplification.
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
>     1400/0    195.6    181.7   3%     (Big packet)

The interesting bit here for me would be how we handle the 1480 byte
values with a 2 byte alignment offset.  That would typically be our
case where we have 14 (eth) + 20 (IP) and no IP_ALIGN since we set it
to 0 on x86.  This is also the case where we would have around a 30%
chance of there being a page boundary in there somewhere since if I
recall 1536 + 64 (NET_SKB_PAD) + 384 (skb_shared_info) doesn't add up
to an even power of 2 so there is a good likelihood of us actually
regressing in the receive path for large packet checksumming since it
is about a 10ns penalty for spanning a page boundary for a single
read.

>     40/0      11.8     6.5     45%    (Ipv6 hdr cmn case)

Common case for transmit maybe.  For receive on x86 this isn't IP
aligned so the offset would be 6.

>     8/4       8.1      3.2     60%    (UDP, VXLAN in IPv4)

How likely is the 8/4 case in reality?  I ask because you have a
special handler for the case and as such that extra bit of code is
going to cost you one cycle or more in all other cases.  As far as the
checksum for VXLAN I would think you are probably looking at something
more like 20/4 because you would likely be pulling the UDP, VXLAN, and
inner Ethernet header to get to the inner IP header.  The only case I
can think of where we might be working on 8 bytes would be something
like L3 encapsulated inside of GRE.

>     14/0      8.9      6.3     29%    (Eth hdr)
>     14/4      9.5      6.3     33%    (Eth hdr in IPv4)
>     14/3      9.6      6.3     34%    (Eth with odd align)
>     20/0      9.1      6.8     25%    (IP hdr without options)
>     7/1       9.1      3.9     57%    (buffer in one quad)
>     100/0    17.4     13.6     21%    (medium-sized pkt)
>     100/2    17.7     13.5     24%    (medium-sized pkt w/ alignment)
>
> Results from: Intel(R) Xeon(R) CPU X5650 @ 2.67GHz


> Also tested on these with similar results:
>
> Intel(R) Xeon(R) CPU E5-2660 v2 @ 2.20GHz
> Intel(R) Xeon(R) CPU E5-2680 v2 @ 2.80GHz
> Intel(R) Atom(TM) CPU N450   @ 1.66GHz
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
>  arch/x86/include/asm/checksum_64.h |  21 +++++
>  arch/x86/lib/csum-partial_64.c     | 171 ++++++++++++++++++-------------------
>  2 files changed, 102 insertions(+), 90 deletions(-)
>
> diff --git a/arch/x86/include/asm/checksum_64.h b/arch/x86/include/asm/checksum_64.h
> index cd00e17..1224f7d 100644
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

You can probably just convert this and the add32_with_carry over to
the +r approach instead of using "0".

> +static inline unsigned int add32_with_carry3(unsigned int a, unsigned int b,
> +                                            unsigned int c)
> +{
> +       asm("addl %1,%0\n\t"
> +           "adcl %2,%0\n\t"
> +           "adcl $0,%0"
> +           : "+r" (a)
> +           : "rm" (b), "rm" (c));
> +
> +       return a;
> +}
> +
>  #define HAVE_ARCH_CSUM_ADD
>  static inline __wsum csum_add(__wsum csum, __wsum addend)
>  {
> diff --git a/arch/x86/lib/csum-partial_64.c b/arch/x86/lib/csum-partial_64.c
> index 9845371..7f1f60f 100644
> --- a/arch/x86/lib/csum-partial_64.c
> +++ b/arch/x86/lib/csum-partial_64.c
> @@ -8,6 +8,7 @@
>  #include <linux/compiler.h>
>  #include <linux/module.h>
>  #include <asm/checksum.h>
> +#include <asm/word-at-a-time.h>
>
>  static inline unsigned short from32to16(unsigned a)
>  {
> @@ -21,99 +22,78 @@ static inline unsigned short from32to16(unsigned a)
>
>  /*
>   * Do a 64-bit checksum on an arbitrary memory area.
> - * Returns a 32bit checksum.
> + * Returns a 64bit checksum.
>   *
> - * This isn't as time critical as it used to be because many NICs
> - * do hardware checksumming these days.
> - *
> - * Things tried and found to not make it faster:
> - * Manual Prefetching
> - * Unrolling to an 128 bytes inner loop.
> - * Using interleaving with more registers to break the carry chains.
> + * This is optimized for small lengths such as might be common when pulling
> + * up checksums over protocol headers to handle CHECKSUM_COMPLETE (e.g.
> + * checksum over 40 bytes will be quite common for pulling up checksum over
> + * IPv6 headers).
>   */
> -static unsigned do_csum(const unsigned char *buff, unsigned len)
> +static unsigned long do_csum(const void *buff, int len)
>  {
> -       unsigned odd, count;
>         unsigned long result = 0;
>
> -       if (unlikely(len == 0))
> -               return result;
> -       odd = 1 & (unsigned long) buff;
> -       if (unlikely(odd)) {
> -               result = *buff << 8;
> -               len--;
> -               buff++;
> +       /* Check for less than a quad to sum */
> +       if (len < 8) {
> +               unsigned long val = load_unaligned_zeropad(buff);
> +
> +               return (val & ((1ul << len * 8) - 1));
> +       }
> +
> +       /* Main loop using 64byte blocks */
> +       for (; len > 64; len -= 64, buff += 64) {
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

The +r would probably work here to just to be consistent.

> +                   : [src] "r" (buff),
> +                   "[res]" (result));
>         }
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
>
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
> +       /*
> +        * Sum over remaining quads (<= 8 of them). This uses a jump table
> +        * based on number of quads to sum. The jump assumes that each case
> +        * is 4 bytes. Each adcq instruction is 4 bytes except for adcq 0()
> +        * which is 3 bytes, so a nop instruction is inserted to make that case
> +        * 4 bytes.
> +        */
> +       asm("lea 0f(, %[slen], 4), %%r11\n\t"
> +           "clc\n\t"
> +           "jmpq *%%r11\n\t"
> +           "adcq 7*8(%[src]),%[res]\n\t"
> +           "adcq 6*8(%[src]),%[res]\n\t"
> +           "adcq 5*8(%[src]),%[res]\n\t"
> +           "adcq 4*8(%[src]),%[res]\n\t"
> +           "adcq 3*8(%[src]),%[res]\n\t"
> +           "adcq 2*8(%[src]),%[res]\n\t"
> +           "adcq 1*8(%[src]),%[res]\n\t"
> +           "adcq 0*8(%[src]),%[res]\n\t"
> +           "nop\n\t"
> +           "0: adcq $0,%[res]"
> +                   : [res] "=r" (result)

Same comment about +r here.

> +                   : [src] "r" (buff),
> +                     [slen] "r" (-(unsigned long)(len >> 3)), "[res]" (result)
> +                   : "r11");
>
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
> +       /* Sum over any remaining bytes (< 8 of them) */
> +       if (len & 0x7) {
> +               unsigned long val;
> +               /*
> +                * Since "len" is > 8 here we backtrack in the buffer to load
> +                * the outstanding bytes into the low order bytes of a quad and
> +                * then shift to extract the relevant bytes. By doing this we
> +                * avoid additional calls to load_unaligned_zeropad.
> +                */
>
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
> +               val = *(unsigned long *)(buff + len - 8);
> +               val >>= 8 * (-len & 0x7);
> +               result = add64_with_carry(val, result);
>         }
>         return result;
>  }
> @@ -125,15 +105,26 @@ static unsigned do_csum(const unsigned char *buff, unsigned len)
>   * returns a 32-bit number suitable for feeding into itself
>   * or csum_tcpudp_magic
>   *
> - * this function must be called with even lengths, except
> - * for the last fragment, which may be odd
> - *
> - * it's best to have buff aligned on a 64-bit boundary
> + * Note that this implementation makes no attempt to avoid unaligned accesses
> + * (e.g. load a quad word with non 8-byte alignment). On x86 unaligned accesses
> + * only seem to be a performance penalty when the access crosses a page
> + * boundary-- such a scenario should be an extremely rare occurrence for use
> + * cases of csum_partial.
>   */
>  __wsum csum_partial(const void *buff, int len, __wsum sum)
>  {
> -       return (__force __wsum)add32_with_carry(do_csum(buff, len),
> -                                               (__force u32)sum);
> +       if (len == 8) {
> +               /* Optimize trivial case */
> +               return (__force __wsum)add32_with_carry3((__force u32)sum,
> +                                                *(unsigned int *)buff,
> +                                                *(unsigned int *)(buff + 4));
> +       } else {
> +               unsigned long result = do_csum(buff, len);
> +
> +               return (__force __wsum)add32_with_carry3((__force u32)sum,
> +                                                result >> 32,
> +                                                result & 0xffffffff);
> +       }
>  }
>
>  /*
> --
> 2.6.5
>
