From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v2] net: smc91: fix crash regression on the versatile
Date: Wed, 27 Nov 2013 13:35:23 +0000
Message-ID: <20131127133523.GH9032@mudshark.cambridge.arm.com>
References: <1385555601-4497-1-git-send-email-linus.walleij@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Nicolas Pitre <nico@fluxnic.net>,
	"David S. Miller" <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Eric Miao <eric.y.miao@gmail.com>,
	Jonathan Cameron <jic23@cam.ac.uk>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
To: Linus Walleij <linus.walleij@linaro.org>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1385555601-4497-1-git-send-email-linus.walleij@linaro.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Linus,

On Wed, Nov 27, 2013 at 12:33:21PM +0000, Linus Walleij wrote:
> After commit e9e4ea74f06635f2ffc1dffe5ef40c854faa0a90
> "net: smc91x: dont't use SMC_outw for fixing up halfword-aligned data"
> The Versatile SMSC LAN91C111 is crashing like this:

[...]

> This is because the macro operations in smc91x.h defined
> for Versatile are missing SMC_outsw() as used in this
> commit.
> 
> The Versatile needs and uses the same accessors as the other
> platforms in the first if(...) clause, just switch it to using
> that and we have one problem less to worry about.

[...]

> diff --git a/drivers/net/ethernet/smsc/smc91x.h b/drivers/net/ethernet/smsc/smc91x.h
> index c9d4c872e81d..902a7c268d82 100644
> --- a/drivers/net/ethernet/smsc/smc91x.h
> +++ b/drivers/net/ethernet/smsc/smc91x.h
> @@ -46,7 +46,8 @@
>      defined(CONFIG_MACH_LITTLETON) ||\
>      defined(CONFIG_MACH_ZYLONITE2) ||\
>      defined(CONFIG_ARCH_VIPER) ||\
> -    defined(CONFIG_MACH_STARGATE2)
> +    defined(CONFIG_MACH_STARGATE2) ||\
> +    defined(CONFIG_ARCH_VERSATILE)
>  
>  #include <asm/mach-types.h>
>  
> @@ -206,23 +207,6 @@ SMC_outw(u16 val, void __iomem *ioaddr, int reg)
>  #define RPC_LSA_DEFAULT		RPC_LED_TX_RX
>  #define RPC_LSB_DEFAULT		RPC_LED_100_10
>  
> -#elif	defined(CONFIG_ARCH_VERSATILE)
> -
> -#define SMC_CAN_USE_8BIT	1
> -#define SMC_CAN_USE_16BIT	1
> -#define SMC_CAN_USE_32BIT	1
> -#define SMC_NOWAIT		1
> -
> -#define SMC_inb(a, r)		readb((a) + (r))
> -#define SMC_inw(a, r)		readw((a) + (r))
> -#define SMC_inl(a, r)		readl((a) + (r))
> -#define SMC_outb(v, a, r)	writeb(v, (a) + (r))
> -#define SMC_outw(v, a, r)	writew(v, (a) + (r))
> -#define SMC_outl(v, a, r)	writel(v, (a) + (r))
> -#define SMC_insl(a, r, p, l)	readsl((a) + (r), p, l)
> -#define SMC_outsl(a, r, p, l)	writesl((a) + (r), p, l)
> -#define SMC_IRQ_FLAGS		(-1)	/* from resource */
> -
>  #elif defined(CONFIG_MN10300)

Ha! I was about to post a different fix for this issue, see below. I think
we may want a combination of the two...

Will

--->8

>From 2b4db3f7ddd560bc52be522098a96a6d18388f0f Mon Sep 17 00:00:00 2001
From: Will Deacon <will.deacon@arm.com>
Date: Wed, 27 Nov 2013 11:32:15 +0000
Subject: [PATCH] net: smc91x: ensure {in,out}sw are defined for platforms with
 32-bit PIO

Commit e9e4ea74f066 ("net: smc91x: dont't use SMC_outw for fixing up
halfword-aligned data") introduced a requirement for all 32-bit PIO
capable platforms to implement the string variants for word accessors.

This patch adds the accessors to platforms where they are missing.

Reported-by: Russell King <linux@arm.linux.org.uk>
Signed-off-by: Will Deacon <will.deacon@arm.com>
---
 drivers/net/ethernet/smsc/smc91x.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/smsc/smc91x.h b/drivers/net/ethernet/smsc/smc91x.h
index c9d4c872e81d..cbe72022cb52 100644
--- a/drivers/net/ethernet/smsc/smc91x.h
+++ b/drivers/net/ethernet/smsc/smc91x.h
@@ -154,6 +154,8 @@ static inline void SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 #define SMC_outl(v, a, r)      writel(v, (a) + (r))
 #define SMC_insl(a, r, p, l)   readsl((a) + (r), p, l)
 #define SMC_outsl(a, r, p, l)  writesl((a) + (r), p, l)
+#define SMC_insw(a, r, p, l)   readsw((a) + (r), p, l)
+#define SMC_outsw(a, r, p, l)  writesw((a) + (r), p, l)
 #define SMC_IRQ_FLAGS          (-1)    /* from resource */
 
 /* We actually can't write halfwords properly if not word aligned */
@@ -221,6 +223,8 @@ SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 #define SMC_outl(v, a, r)      writel(v, (a) + (r))
 #define SMC_insl(a, r, p, l)   readsl((a) + (r), p, l)
 #define SMC_outsl(a, r, p, l)  writesl((a) + (r), p, l)
+#define SMC_insw(a, r, p, l)   readsw((a) + (r), p, l)
+#define SMC_outsw(a, r, p, l)  writesw((a) + (r), p, l)
 #define SMC_IRQ_FLAGS          (-1)    /* from resource */
 
 #elif defined(CONFIG_MN10300)
-- 
1.8.2.2
