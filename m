From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] smc91x: remove ARM hack for unaligned 16-bit writes
Date: Fri, 26 Aug 2016 11:41:21 +0200
Message-ID: <1899384.M1jdqOztqi@wuerfel>
References: <20160825144314.1850730-1-arnd@arndb.de> <87inuopw04.fsf@belgarion.home> <20160825223743.GK1041@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Russell King - ARM Linux <linux@armlinux.org.uk>,
        Robert Jarzmik <robert.jarzmik@free.fr>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        Nicolas Pitre <nico@fluxnic.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160825223743.GK1041@n2100.armlinux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, August 25, 2016 11:37:43 PM CEST Russell King - ARM Linux wrote:
> On Thu, Aug 25, 2016 at 08:02:35PM +0200, Robert Jarzmik wrote:
> > Arnd Bergmann <arnd@arndb.de> writes:
>  /*
> + * Any 16-bit access is performed with two 8-bit accesses if the hardware
> + * can't do it directly. Most registers are 16-bit so those are mandatory.
> + */
> +#define SMC_outw_b(x, a, r)						\
> +	do {								\
> +		unsigned int __val16 = (x);				\
> +		unsigned int __reg = (r);				\
> +		SMC_outb(__val16, a, __reg);				\
> +		SMC_outb(__val16 >> 8, a, __reg + (1 << SMC_IO_SHIFT));	\
> +	} while (0)
> +
> +#define SMC_inw_b(a, r)							\
> +	({								\
> +		unsigned int __val16;					\
> +		unsigned int __reg = r;					\
> +		__val16  = SMC_inb(a, __reg);				\
> +		__val16 |= SMC_inb(a, __reg + (1 << SMC_IO_SHIFT)) << 8; \
> +		__val16;						\
> +	})
> +
> +/*
>   * Define your architecture specific bus configuration parameters here.
>   */
>  
> @@ -55,10 +76,30 @@
>  #define SMC_IO_SHIFT		(lp->io_shift)
>  
>  #define SMC_inb(a, r)		readb((a) + (r))
> -#define SMC_inw(a, r)		readw((a) + (r))
> +#define SMC_inw(a, r)							\
> +	({								\
> +		unsigned int __smc_r = r;				\
> +		SMC_16BIT(lp) ? readw((a) + __smc_r) :			\
> +		SMC_8BIT(lp) ? SMC_inw_b(a, __smc_r) :			\
> +		({ BUG(); 0; });					\
> +	})
> +

I think this breaks machines that declare a device that just lists
SMC91X_USE_32BIT but not SMC91X_USE_16BIT. Right now, the way this
is interpreted is to use 32-bit accessors for most things, but
not avoiding 16-bit reads.

That is a bit fishy though, and we could instead change the platform
data to always set both SMC91X_USE_32BIT and SMC91X_USE_16BIT.

The affected platforms are DT based machines with 32-bit I/O and
these board files:

arch/arm/mach-pxa/idp.c:        .flags = SMC91X_USE_32BIT | SMC91X_USE_DMA | SMC91X_NOWAIT,
arch/arm/mach-pxa/xcep.c:       .flags  = SMC91X_USE_32BIT | SMC91X_NOWAIT | SMC91X_USE_DMA,
arch/arm/mach-realview/core.c:  .flags = SMC91X_USE_32BIT | SMC91X_NOWAIT,
arch/blackfin/mach-bf561/boards/cm_bf561.c:     .flags = SMC91X_USE_32BIT | SMC91X_NOWAIT,
arch/blackfin/mach-bf561/boards/ezkit.c:        .flags = SMC91X_USE_32BIT | SMC91X_NOWAIT,

	Arnd
