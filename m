From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH] Fix ns82830 driver for x86-64
Date: Mon, 21 Mar 2005 05:59:47 -0500
Message-ID: <20050321105947.GB808@kvack.org>
References: <20050314000543.GA85950@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
To: Andi Kleen <ak@muc.de>
Content-Disposition: inline
In-Reply-To: <20050314000543.GA85950@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'll have a closer look at this when I'm back in Canada later this week, 
as there are a few other ns83820 patches which should be applied.  The 
patch looks right -- those ifdefs date back to the 2.4.9 days.

		-ben

On Mon, Mar 14, 2005 at 01:05:43AM +0100, Andi Kleen wrote:
> Fix up some dodgy ifdefs in the ns82820 driver 
> and support DAC mode on x86-64. Do proper sizeof(dma_addr_t) checks
> instead.
> 
> Only compile tested due to lack of hardware.
> 
> Originally pointed out by Al Viro
> 
> Signed-off-by: Andi Kleen <ak@muc.de>
> 
> Index: linux/drivers/net/ns83820.c
> ===================================================================
> --- linux.orig/drivers/net/ns83820.c	2005-03-12 15:06:34.000000000 +0100
> +++ linux/drivers/net/ns83820.c	2005-03-14 00:50:07.547865056 +0100
> @@ -1,4 +1,4 @@
> -#define _VERSION "0.20"
> +#define VERSION "0.20"
>  /* ns83820.c by Benjamin LaHaise with contributions.
>   *
>   * Questions/comments/discussion to linux-ns83820@kvack.org.
> @@ -129,18 +129,6 @@
>  #undef Dprintk
>  #define	Dprintk			dprintk
>  
> -#if defined(CONFIG_HIGHMEM64G) || defined(__ia64__)
> -#define USE_64BIT_ADDR	"+"
> -#endif
> -
> -#if defined(USE_64BIT_ADDR)
> -#define	VERSION	_VERSION USE_64BIT_ADDR
> -#define TRY_DAC	1
> -#else
> -#define	VERSION	_VERSION
> -#define TRY_DAC	0
> -#endif
> -
>  /* tunables */
>  #define RX_BUF_SIZE	1500	/* 8192 */
>  #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
> @@ -386,22 +374,16 @@
>  #define LINK_DOWN		0x02
>  #define LINK_UP			0x04
>  
> -#ifdef USE_64BIT_ADDR
> -#define HW_ADDR_LEN	8
> +#define HW_ADDR_LEN	sizeof(dma_addr_t) 
>  #define desc_addr_set(desc, addr)				\
>  	do {							\
> -		u64 __addr = (addr);				\
> -		(desc)[0] = cpu_to_le32(__addr);		\
> -		(desc)[1] = cpu_to_le32(__addr >> 32);		\
> +		((desc)[0] = cpu_to_le32(addr));		\
> +		if (HW_ADDR_LEN == 8)		 		\
> +			(desc)[1] = cpu_to_le32(((u64)addr) >> 32);	\
>  	} while(0)
>  #define desc_addr_get(desc)					\
> -		(((u64)le32_to_cpu((desc)[1]) << 32)		\
> -		     | le32_to_cpu((desc)[0]))
> -#else
> -#define HW_ADDR_LEN	4
> -#define desc_addr_set(desc, addr)	((desc)[0] = cpu_to_le32(addr))
> -#define desc_addr_get(desc)		(le32_to_cpu((desc)[0]))
> -#endif
> +	(le32_to_cpu((desc)[0]) | \
> +	(HW_ADDR_LEN == 8 ? ((dma_addr_t)le32_to_cpu((desc)[1]))<<32 : 0))
>  
>  #define DESC_LINK		0
>  #define DESC_BUFPTR		(DESC_LINK + HW_ADDR_LEN/4)
> @@ -1841,7 +1823,8 @@
>  	int using_dac = 0;
>  
>  	/* See if we can set the dma mask early on; failure is fatal. */
> -	if (TRY_DAC && !pci_set_dma_mask(pci_dev, 0xffffffffffffffffULL)) {
> +	if (sizeof(dma_addr_t) == 8 && 
> +	 	!pci_set_dma_mask(pci_dev, 0xffffffffffffffffULL)) {
>  		using_dac = 1;
>  	} else if (!pci_set_dma_mask(pci_dev, 0xffffffff)) {
>  		using_dac = 0;
> @@ -1972,9 +1955,8 @@
>  	/* When compiled with 64 bit addressing, we must always enable
>  	 * the 64 bit descriptor format.
>  	 */
> -#ifdef USE_64BIT_ADDR
> -	dev->CFG_cache |= CFG_M64ADDR;
> -#endif
> +	if (sizeof(dma_addr_t) == 8) 
> +		dev->CFG_cache |= CFG_M64ADDR;
>  	if (using_dac)
>  		dev->CFG_cache |= CFG_T64ADDR;
>  

-- 
"Time is what keeps everything from happening all at once." -- John Wheeler
