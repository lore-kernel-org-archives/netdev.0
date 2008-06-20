From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH 5/8] smc91x: add SMC91X_IO_SHIFT* macros and make
	SMC_IO_SHIFT a variable
Date: Fri, 20 Jun 2008 09:29:40 +0200
Message-ID: <20080620072939.GA1479@pengutronix.de>
References: <485A3E0B.1080505@gmail.com> <alpine.LFD.1.10.0806191223390.2982@xanadu.home> <485B2850.5050004@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Pitre <nico@cam.org>,
	linux-netdev <netdev@vger.kernel.org>,
	Magnus Damm <magnus.damm@gmail.com>,
	linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>
To: Eric Miao <eric.y.miao@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.extern.pengutronix.de ([83.236.181.26]:38533 "EHLO
	metis.extern.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751163AbYFTH3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 03:29:43 -0400
Content-Disposition: inline
In-Reply-To: <485B2850.5050004@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 20, 2008 at 11:47:28AM +0800, Eric Miao wrote:
> Nicolas Pitre wrote:
> > On Thu, 19 Jun 2008, Eric Miao wrote:
> > 
> >> SMC_IO_SHIFT is currently hardcoded, which makes some platforms (e.g.
> >> Lubbock) unable to use the newly introduced platform data. This patch
> >> introduces SMC91X_IO_SHIFT* macros and make SMC_IO_SHIFT a variable.
> >>
> >> Signed-off-by: Eric Miao <eric.miao@marvell.com>
> > 
> > NAK.
> > 
> > The very point of those macros is actually to optimize the IO accesses 
> > as much as possible at compile time.  By introducing a variable element 
> > in the definition of those macros (for when the driver is configured 
> > with constant params for those macros of course) you add a significant 
> > overhead to every access to the hardware, including when transferring 
> > data in and out of the chip.
> > 
> 
> Contrary to expected, the result shows a slight decrease on zylonite,
> PXA310@624MHz, result shown as below:
> 
> (by a simple measurement with "proc/uptime" and tftp)
> 
> with SMC_IO_SHIFT being a variable
> 
> trial 1: 2062776 bytes in (179.77 - 177.72 = 2.05) seconds = 1,006,232 Bps
> trial 2: 2062776 bytes in (183.00 - 180.95 = 2.05) seconds = 1,006,232 Bps
> trial 3: 2062776 bytes in (261.48 - 259.42 = 2.06) seconds = 1,001,347 Bps
> 
> with SMC_IO_SHIFT being a constant
> 
> trial 1: 2062776 bytes in (41.07 - 39.04 = 2.03) seconds = 1,016,145 Bps
> trial 2: 2062776 bytes in (97.19 - 95.16 = 2.03) seconds = 1,016,145 Bps
> trial 3: 2062776 bytes in (159.81 - 157.78 = 2.03) seconds = 1,016,145 Bps
> 
> The statistics were stable during the test, so I generally think it's
> typical.
> 
> On lubbock, PXA255@200MHz, however, the result shows a slight increase:
> 
> with SMC_IO_SHIFT being a variable
> 
> trial 1: 2062776 bytes in (49.42 - 42.20 = 7.22) seconds = 285,703 Bps
> trial 2: 2062776 bytes in (60.27 - 53.07 = 7.20) seconds = 286,497 Bps
> trial 3: 2062776 bytes in (141.04 - 133.84 = 7.20) seconds = 286,497 Bps
> 
> with SMC_IO_SHIFT being a constant
> 
> trial 1: 2062776 bytes in (58.93 - 51.62 = 7.31) seconds = 282,185 Bps
> trial 2: 2062776 bytes in (69.26 - 61.95 = 7.31) seconds = 282,185 Bps
> trial 3: 2062776 bytes in (151.58 - 144.27 = 7.31) seconds = 282,185 Bps

Your numbers look like a very bad overall performance. I remember we got
nearly 100Mbit/s on a pxa system with the smsc connected in 32bit mode.
While this project was performance critical I'm often in the situation
that I just expect the smsc driver to work without looking at the
ifdeffery in the header file.
Shouldn't it be possible to make access macros optional for those who
want performance and use functions as the default case?


> 
> So I'm thinking that the overhead may not be so significant as expected,
> 1. control register accesses are rare compared to data register
> 2. data register access is usually fixed at one address and enclosed in
>    a loop, which the compiler may well optimize
> 
> > And this is very important to have the lowest overhead possible with 
> > this chip that can do 100mbps on platforms with a CPU clock almost as 
> > slow.
> > 
> 
> Indeed, the overhead will be magnified on a system with slow CPU clock,
> maybe I should spend some time to have a test also. However, arguably,
> the smc91x chips are usually used as a debug ethernet on most (if not
> all) platforms, I don't think a serious design will deploy such a chip
> for performance critical application, though.

Not anymore probably, but we seem to tun into the same problem with the
current smc911x driver aswell

Sascha


> 
> > 
> > 
> >> ---
> >>  drivers/net/smc91x.c   |   25 ++++++++++++++-----------
> >>  drivers/net/smc91x.h   |   18 ++++++++++--------
> >>  include/linux/smc91x.h |    6 ++++++
> >>  3 files changed, 30 insertions(+), 19 deletions(-)
> >>
> >> diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
> >> index caa0308..85eceab 100644
> >> --- a/drivers/net/smc91x.c
> >> +++ b/drivers/net/smc91x.c
> >> @@ -105,6 +105,8 @@ MODULE_PARM_DESC(watchdog, "transmit timeout in milliseconds");
> >>  MODULE_LICENSE("GPL");
> >>  MODULE_ALIAS("platform:smc91x");
> >>  
> >> +int smc_io_shift = SMC_IO_SHIFT;
> >> +
> >>  /*
> >>   * The internal workings of the driver.  If you are changing anything
> >>   * here with the SMC stuff, you should have the datasheet and know
> >> @@ -1794,8 +1796,8 @@ static int __init smc_probe(struct net_device *dev, void __iomem *ioaddr,
> >>  	 */
> >>  	SMC_SELECT_BANK(lp, 1);
> >>  	val = SMC_GET_BASE(lp);
> >> -	val = ((val & 0x1F00) >> 3) << SMC_IO_SHIFT;
> >> -	if (((unsigned int)ioaddr & (0x3e0 << SMC_IO_SHIFT)) != val) {
> >> +	val = ((val & 0x1F00) >> 3) << smc_io_shift;
> >> +	if (((unsigned int)ioaddr & (0x3e0 << smc_io_shift)) != val) {
> >>  		printk("%s: IOADDR %p doesn't match configuration (%x).\n",
> >>  			CARDNAME, ioaddr, val);
> >>  	}
> >> @@ -1994,9 +1996,9 @@ static int smc_enable_device(struct platform_device *pdev)
> >>  	 * since a reset causes the IRQ line become active.
> >>  	 */
> >>  	local_irq_save(flags);
> >> -	ecor = readb(addr + (ECOR << SMC_IO_SHIFT)) & ~ECOR_RESET;
> >> -	writeb(ecor | ECOR_RESET, addr + (ECOR << SMC_IO_SHIFT));
> >> -	readb(addr + (ECOR << SMC_IO_SHIFT));
> >> +	ecor = readb(addr + (ECOR << smc_io_shift)) & ~ECOR_RESET;
> >> +	writeb(ecor | ECOR_RESET, addr + (ECOR << smc_io_shift));
> >> +	readb(addr + (ECOR << smc_io_shift));
> >>  
> >>  	/*
> >>  	 * Wait 100us for the chip to reset.
> >> @@ -2008,16 +2010,16 @@ static int smc_enable_device(struct platform_device *pdev)
> >>  	 * reset is asserted, even if the reset bit is cleared in the
> >>  	 * same write.  Must clear reset first, then enable the device.
> >>  	 */
> >> -	writeb(ecor, addr + (ECOR << SMC_IO_SHIFT));
> >> -	writeb(ecor | ECOR_ENABLE, addr + (ECOR << SMC_IO_SHIFT));
> >> +	writeb(ecor, addr + (ECOR << smc_io_shift));
> >> +	writeb(ecor | ECOR_ENABLE, addr + (ECOR << smc_io_shift));
> >>  
> >>  	/*
> >>  	 * Set the appropriate byte/word mode.
> >>  	 */
> >> -	ecsr = readb(addr + (ECSR << SMC_IO_SHIFT)) & ~ECSR_IOIS8;
> >> +	ecsr = readb(addr + (ECSR << smc_io_shift)) & ~ECSR_IOIS8;
> >>  	if (!SMC_16BIT(lp))
> >>  		ecsr |= ECSR_IOIS8;
> >> -	writeb(ecsr, addr + (ECSR << SMC_IO_SHIFT));
> >> +	writeb(ecsr, addr + (ECSR << smc_io_shift));
> >>  	local_irq_restore(flags);
> >>  
> >>  	iounmap(addr);
> >> @@ -2136,9 +2138,10 @@ static int smc_drv_probe(struct platform_device *pdev)
> >>  
> >>  	lp = netdev_priv(ndev);
> >>  
> >> -	if (pd)
> >> +	if (pd) {
> >>  		memcpy(&lp->cfg, pd, sizeof(lp->cfg));
> >> -	else {
> >> +		smc_io_shift = SMC91X_IO_SHIFT(lp->cfg.flags);
> >> +	} else {
> >>  		lp->cfg.flags |= (SMC_CAN_USE_8BIT)  ? SMC91X_USE_8BIT  : 0;
> >>  		lp->cfg.flags |= (SMC_CAN_USE_16BIT) ? SMC91X_USE_16BIT : 0;
> >>  		lp->cfg.flags |= (SMC_CAN_USE_32BIT) ? SMC91X_USE_32BIT : 0;
> >> diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
> >> index 6a90400..3ce1ca4 100644
> >> --- a/drivers/net/smc91x.h
> >> +++ b/drivers/net/smc91x.h
> >> @@ -610,6 +610,8 @@ smc_pxa_dma_irq(int dma, void *dummy)
> >>  #define SMC_outsl(a, r, p, l)		BUG()
> >>  #endif
> >>  
> >> +extern int smc_io_shift;
> >> +
> >>  #if ! SMC_CAN_USE_16BIT
> >>  
> >>  /*
> >> @@ -620,13 +622,13 @@ smc_pxa_dma_irq(int dma, void *dummy)
> >>  	do {								\
> >>  		unsigned int __val16 = (x);				\
> >>  		SMC_outb( __val16, ioaddr, reg );			\
> >> -		SMC_outb( __val16 >> 8, ioaddr, reg + (1 << SMC_IO_SHIFT));\
> >> +		SMC_outb( __val16 >> 8, ioaddr, reg + (1 << smc_io_shift));\
> >>  	} while (0)
> >>  #define SMC_inw(ioaddr, reg)						\
> >>  	({								\
> >>  		unsigned int __val16;					\
> >>  		__val16 =  SMC_inb( ioaddr, reg );			\
> >> -		__val16 |= SMC_inb( ioaddr, reg + (1 << SMC_IO_SHIFT)) << 8; \
> >> +		__val16 |= SMC_inb( ioaddr, reg + (1 << smc_io_shift)) << 8; \
> >>  		__val16;						\
> >>  	})
> >>  
> >> @@ -670,7 +672,7 @@ smc_pxa_dma_irq(int dma, void *dummy)
> >>  
> >>  
> >>  /* Because of bank switching, the LAN91x uses only 16 I/O ports */
> >> -#define SMC_IO_EXTENT	(16 << SMC_IO_SHIFT)
> >> +#define SMC_IO_EXTENT	(16 << smc_io_shift)
> >>  #define SMC_DATA_EXTENT (4)
> >>  
> >>  /*
> >> @@ -680,7 +682,7 @@ smc_pxa_dma_irq(int dma, void *dummy)
> >>   .		xx 		= bank number
> >>   .		yyyy yyyy	= 0x33, for identification purposes.
> >>  */
> >> -#define BANK_SELECT		(14 << SMC_IO_SHIFT)
> >> +#define BANK_SELECT		(14 << smc_io_shift)
> >>  
> >>  
> >>  // Transmit Control Register
> >> @@ -1033,7 +1035,7 @@ static const char * chip_ids[ 16 ] =  {
> >>  #define ECSR_PWRDWN		0x04
> >>  #define ECSR_INT		0x02
> >>  
> >> -#define ATTRIB_SIZE		((64*1024) << SMC_IO_SHIFT)
> >> +#define ATTRIB_SIZE		((64*1024) << smc_io_shift)
> >>  
> >>  
> >>  /*
> >> @@ -1058,10 +1060,10 @@ static const char * chip_ids[ 16 ] =  {
> >>  				CARDNAME, __b );			\
> >>  			BUG();						\
> >>  		}							\
> >> -		reg<<SMC_IO_SHIFT;					\
> >> +		reg<<smc_io_shift;					\
> >>  	})
> >>  #else
> >> -#define SMC_REG(lp, reg, bank)	(reg<<SMC_IO_SHIFT)
> >> +#define SMC_REG(lp, reg, bank)	(reg<<smc_io_shift)
> >>  #endif
> >>  
> >>  /*
> >> @@ -1136,7 +1138,7 @@ static const char * chip_ids[ 16 ] =  {
> >>  #define SMC_SELECT_BANK(lp, x)					\
> >>  	do {								\
> >>  		if (SMC_MUST_ALIGN_WRITE(lp))				\
> >> -			SMC_outl((x)<<16, ioaddr, 12<<SMC_IO_SHIFT);	\
> >> +			SMC_outl((x)<<16, ioaddr, 12<<smc_io_shift);	\
> >>  		else							\
> >>  			SMC_outw(x, ioaddr, BANK_SELECT);		\
> >>  	} while (0)
> >> diff --git a/include/linux/smc91x.h b/include/linux/smc91x.h
> >> index 90434db..f77ebe1 100644
> >> --- a/include/linux/smc91x.h
> >> +++ b/include/linux/smc91x.h
> >> @@ -7,6 +7,12 @@
> >>  
> >>  #define SMC91X_NOWAIT		(1 << 3)
> >>  
> >> +#define SMC91X_IO_SHIFT_0	(0 << 4)
> >> +#define SMC91X_IO_SHIFT_1	(1 << 4)
> >> +#define SMC91X_IO_SHIFT_2	(2 << 4)
> >> +#define SMC91X_IO_SHIFT_3	(3 << 4)
> >> +#define SMC91X_IO_SHIFT(x)	(((x) >> 4) & 0x3)
> >> +
> >>  struct smc91x_platdata {
> >>  	unsigned long flags;
> >>  };
> >> -- 
> >> 1.5.4.3
> >>
> > 
> > 
> > Nicolas
> 
> 
> -------------------------------------------------------------------
> List admin: http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel
> FAQ:        http://www.arm.linux.org.uk/mailinglists/faq.php
> Etiquette:  http://www.arm.linux.org.uk/mailinglists/etiquette.php
> 

-- 
Pengutronix e.K. - Linux Solutions for Science and Industry
-----------------------------------------------------------
Kontakt-Informationen finden Sie im Header dieser Mail oder
auf der Webseite -> http://www.pengutronix.de/impressum/ <-
