From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: MediaGX/GeodeGX1 requires X86_OOSTORE.
Date: Tue, 20 Feb 2007 09:48:23 -0500
Message-ID: <20070220144823.GN7585@csclub.uwaterloo.ca>
References: <ada3b5253p0.fsf@cisco.com> <20070220.085639.260788422.takada@mbf.nifty.com> <20070220000231.GM7585@csclub.uwaterloo.ca> <20070220.203413.260790539.takada@mbf.nifty.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rdreier@cisco.com, pcnet32@verizon.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: takada <takada@mbf.nifty.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:36339 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932461AbXBTOsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Feb 2007 09:48:24 -0500
Content-Disposition: inline
In-Reply-To: <20070220.203413.260790539.takada@mbf.nifty.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 08:34:13PM +0900, takada wrote:
> I posted with 2.6.20 + enabled X86_OOSTORE.
> The clflush sze line is in /proc/cpuinfo. but clfush is not in flags line.
> 
> BTW, can we use WBINVD instruction? I tested compile only.
> Do you know a method to change dynamically without #ifdef when it works
> with MediaGX/GeodeGX.
> 
> diff -Narup a/include/asm-i386/io.h b/include/asm-i386/io.h
> --- a/include/asm-i386/io.h	2007-02-20 16:23:25.000000000 +0900
> +++ b/include/asm-i386/io.h	2007-02-20 17:07:14.000000000 +0900
> @@ -232,7 +232,19 @@ static inline void memcpy_toio(volatile 
>   *	2. Accidentally out of order processors (PPro errata #51)
>   */
>   
> -#if defined(CONFIG_X86_OOSTORE) || defined(CONFIG_X86_PPRO_FENCE)
> +#ifdef CONFIG_MGEODEGX1
> +
> +static inline void dma_flush_cache(void)
> +{
> +	__asm__ __volatile__ ("wbinvd": : :"memory");
> +}
> +
> +#define dma_cache_inv(_start,_size)		dma_flush_cache()
> +#define dma_cache_wback(_start,_size)		dma_flush_cache()
> +#define dma_cache_wback_inv(_start,_size)	dma_flush_cache()
> +#define flush_write_buffers()
> +
> +#elif defined(CONFIG_X86_OOSTORE) || defined(CONFIG_X86_PPRO_FENCE)
>  
>  static inline void flush_write_buffers(void)
>  {
> -

Well it is starting to look like it isn't a caching issue, but more
likely an issue of which order writes are performed in.  I think the MAC
might be seeing the ownership bit change before the rest of the
descriptor, which shouldn't happen.  With X86_OOSTORE, wmb() is called
between setting the fields in the descriptor and setting the ownership
bit to the MAC.  I still have to investigate a bit more to find out for
sure, but that could certainly explain why X86_OOSTORE makes the problem
become much less frequent.  It doesn't completely elliminate it though.
Of course maybe there are two different problems with the same symptoms.

--
Len Sorensen
