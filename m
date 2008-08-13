From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 19/22] x86: use the new byteorder headers
Date: Tue, 12 Aug 2008 20:54:22 -0700
Message-ID: <20080812205422.4273d598.akpm@linux-foundation.org>
References: <1218587234.30194.93.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	per.liden@ericsson.com, jon.maloy@ericsson.com,
	allan.stephens@windriver.com
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35880 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753359AbYHMDzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 23:55:08 -0400
In-Reply-To: <1218587234.30194.93.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Aug 2008 17:27:14 -0700 Harvey Harrison <harvey.harrison@gmail.com> wrote:

> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> ---
> The prerequisite patches have landed in Linus' tree now.
> 
>  include/asm-x86/byteorder.h |   69 +++++++++++++++++--------------------------
>  1 files changed, 27 insertions(+), 42 deletions(-)
> 
> diff --git a/include/asm-x86/byteorder.h b/include/asm-x86/byteorder.h
> index e02ae2d..7187b3a 100644
> --- a/include/asm-x86/byteorder.h
> +++ b/include/asm-x86/byteorder.h
> @@ -4,26 +4,33 @@
>  #include <asm/types.h>
>  #include <linux/compiler.h>
>  
> -#ifdef __GNUC__
> +#define __LITTLE_ENDIAN
>  
> -#ifdef __i386__
> -
> -static inline __attribute_const__ __u32 ___arch__swab32(__u32 x)
> +static inline __attribute_const__ __u32 __arch_swab32(__u32 val)
>  {
> -#ifdef CONFIG_X86_BSWAP
> -	asm("bswap %0" : "=r" (x) : "0" (x));
> -#else
> +#ifdef __i386__
> +# ifdef CONFIG_X86_BSWAP
> +	asm("bswap %0" : "=r" (val) : "0" (val));
> +# else
>  	asm("xchgb %b0,%h0\n\t"	/* swap lower bytes	*/
>  	    "rorl $16,%0\n\t"	/* swap words		*/
>  	    "xchgb %b0,%h0"	/* swap higher bytes	*/
> -	    : "=q" (x)
> -	    : "0" (x));
> +	    : "=q" (val)
> +	    : "0" (val));
> +# endif
> +
> +#else /* __i386__ */
> +	asm("bswapl %0"
> +	    : "=r" (val)
> +	    : "0" (val));
>  #endif
> -	return x;
> +	return val;
>  }
> +#define __arch_swab32 __arch_swab32
>  
> -static inline __attribute_const__ __u64 ___arch__swab64(__u64 val)
> +static inline __attribute_const__ __u64 __arch_swab64(__u64 val)
>  {
> +#ifdef __i386__
>  	union {
>  		struct {
>  			__u32 a;
> @@ -32,50 +39,28 @@ static inline __attribute_const__ __u64 ___arch__swab64(__u64 val)
>  		__u64 u;
>  	} v;
>  	v.u = val;
> -#ifdef CONFIG_X86_BSWAP
> +# ifdef CONFIG_X86_BSWAP
>  	asm("bswapl %0 ; bswapl %1 ; xchgl %0,%1"
>  	    : "=r" (v.s.a), "=r" (v.s.b)
>  	    : "0" (v.s.a), "1" (v.s.b));
> -#else
> +# else
>  	v.s.a = ___arch__swab32(v.s.a);
>  	v.s.b = ___arch__swab32(v.s.b);
>  	asm("xchgl %0,%1"
>  	    : "=r" (v.s.a), "=r" (v.s.b)
>  	    : "0" (v.s.a), "1" (v.s.b));
> -#endif
> +# endif
>  	return v.u;
> -}
>  
>  #else /* __i386__ */
> -
> -static inline __attribute_const__ __u64 ___arch__swab64(__u64 x)
> -{
>  	asm("bswapq %0"
> -	    : "=r" (x)
> -	    : "0" (x));
> -	return x;
> -}
> -
> -static inline __attribute_const__ __u32 ___arch__swab32(__u32 x)
> -{
> -	asm("bswapl %0"
> -	    : "=r" (x)
> -	    : "0" (x));
> -	return x;
> -}
> -
> +	    : "=r" (val)
> +	    : "0" (val));
> +	return val;
>  #endif
> +}
> +#define __arch_swab64 __arch_swab64
>  
> -/* Do not define swab16.  Gcc is smart enough to recognize "C" version and
> -   convert it into rotation or exhange.  */
> -
> -#define __arch__swab64(x) ___arch__swab64(x)
> -#define __arch__swab32(x) ___arch__swab32(x)
> -
> -#define __BYTEORDER_HAS_U64__
> -
> -#endif /* __GNUC__ */
> -
> -#include <linux/byteorder/little_endian.h>
> +#include <linux/byteorder.h>
>  
>  #endif /* _ASM_X86_BYTEORDER_H */

net/tipc/subscr.c: In function 'htohl':
net/tipc/subscr.c:88: error: implicit declaration of function '___constant_swab32'

That's just a basic i386 allmodconfig.  How come you're not seeing this?

Heaven alone knows what tipc thinks it's doing poking into this sort of
thing.  Could you please take a look and teach it some manners?

Thanks.
