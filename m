From: Nicolas Pitre <nico@cam.org>
Subject: Re: [PATCH 5/8] smc91x: add SMC91X_IO_SHIFT* macros and make
 SMC_IO_SHIFT a variable
Date: Thu, 19 Jun 2008 12:41:23 -0400 (EDT)
Message-ID: <alpine.LFD.1.10.0806191223390.2982@xanadu.home>
References: <485A3E0B.1080505@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-netdev <netdev@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	Magnus Damm <magnus.damm@gmail.com>
To: Eric Miao <eric.y.miao@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:26640 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751705AbYFSQlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 12:41:24 -0400
Received: from xanadu.home ([66.131.194.97]) by VL-MH-MR001.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0K2P00MLBYCZXM80@VL-MH-MR001.ip.videotron.ca> for
 netdev@vger.kernel.org; Thu, 19 Jun 2008 12:41:23 -0400 (EDT)
In-reply-to: <485A3E0B.1080505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Jun 2008, Eric Miao wrote:

> 
> SMC_IO_SHIFT is currently hardcoded, which makes some platforms (e.g.
> Lubbock) unable to use the newly introduced platform data. This patch
> introduces SMC91X_IO_SHIFT* macros and make SMC_IO_SHIFT a variable.
> 
> Signed-off-by: Eric Miao <eric.miao@marvell.com>

NAK.

The very point of those macros is actually to optimize the IO accesses 
as much as possible at compile time.  By introducing a variable element 
in the definition of those macros (for when the driver is configured 
with constant params for those macros of course) you add a significant 
overhead to every access to the hardware, including when transferring 
data in and out of the chip.

And this is very important to have the lowest overhead possible with 
this chip that can do 100mbps on platforms with a CPU clock almost as 
slow.



> ---
>  drivers/net/smc91x.c   |   25 ++++++++++++++-----------
>  drivers/net/smc91x.h   |   18 ++++++++++--------
>  include/linux/smc91x.h |    6 ++++++
>  3 files changed, 30 insertions(+), 19 deletions(-)
> 
> diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
> index caa0308..85eceab 100644
> --- a/drivers/net/smc91x.c
> +++ b/drivers/net/smc91x.c
> @@ -105,6 +105,8 @@ MODULE_PARM_DESC(watchdog, "transmit timeout in milliseconds");
>  MODULE_LICENSE("GPL");
>  MODULE_ALIAS("platform:smc91x");
>  
> +int smc_io_shift = SMC_IO_SHIFT;
> +
>  /*
>   * The internal workings of the driver.  If you are changing anything
>   * here with the SMC stuff, you should have the datasheet and know
> @@ -1794,8 +1796,8 @@ static int __init smc_probe(struct net_device *dev, void __iomem *ioaddr,
>  	 */
>  	SMC_SELECT_BANK(lp, 1);
>  	val = SMC_GET_BASE(lp);
> -	val = ((val & 0x1F00) >> 3) << SMC_IO_SHIFT;
> -	if (((unsigned int)ioaddr & (0x3e0 << SMC_IO_SHIFT)) != val) {
> +	val = ((val & 0x1F00) >> 3) << smc_io_shift;
> +	if (((unsigned int)ioaddr & (0x3e0 << smc_io_shift)) != val) {
>  		printk("%s: IOADDR %p doesn't match configuration (%x).\n",
>  			CARDNAME, ioaddr, val);
>  	}
> @@ -1994,9 +1996,9 @@ static int smc_enable_device(struct platform_device *pdev)
>  	 * since a reset causes the IRQ line become active.
>  	 */
>  	local_irq_save(flags);
> -	ecor = readb(addr + (ECOR << SMC_IO_SHIFT)) & ~ECOR_RESET;
> -	writeb(ecor | ECOR_RESET, addr + (ECOR << SMC_IO_SHIFT));
> -	readb(addr + (ECOR << SMC_IO_SHIFT));
> +	ecor = readb(addr + (ECOR << smc_io_shift)) & ~ECOR_RESET;
> +	writeb(ecor | ECOR_RESET, addr + (ECOR << smc_io_shift));
> +	readb(addr + (ECOR << smc_io_shift));
>  
>  	/*
>  	 * Wait 100us for the chip to reset.
> @@ -2008,16 +2010,16 @@ static int smc_enable_device(struct platform_device *pdev)
>  	 * reset is asserted, even if the reset bit is cleared in the
>  	 * same write.  Must clear reset first, then enable the device.
>  	 */
> -	writeb(ecor, addr + (ECOR << SMC_IO_SHIFT));
> -	writeb(ecor | ECOR_ENABLE, addr + (ECOR << SMC_IO_SHIFT));
> +	writeb(ecor, addr + (ECOR << smc_io_shift));
> +	writeb(ecor | ECOR_ENABLE, addr + (ECOR << smc_io_shift));
>  
>  	/*
>  	 * Set the appropriate byte/word mode.
>  	 */
> -	ecsr = readb(addr + (ECSR << SMC_IO_SHIFT)) & ~ECSR_IOIS8;
> +	ecsr = readb(addr + (ECSR << smc_io_shift)) & ~ECSR_IOIS8;
>  	if (!SMC_16BIT(lp))
>  		ecsr |= ECSR_IOIS8;
> -	writeb(ecsr, addr + (ECSR << SMC_IO_SHIFT));
> +	writeb(ecsr, addr + (ECSR << smc_io_shift));
>  	local_irq_restore(flags);
>  
>  	iounmap(addr);
> @@ -2136,9 +2138,10 @@ static int smc_drv_probe(struct platform_device *pdev)
>  
>  	lp = netdev_priv(ndev);
>  
> -	if (pd)
> +	if (pd) {
>  		memcpy(&lp->cfg, pd, sizeof(lp->cfg));
> -	else {
> +		smc_io_shift = SMC91X_IO_SHIFT(lp->cfg.flags);
> +	} else {
>  		lp->cfg.flags |= (SMC_CAN_USE_8BIT)  ? SMC91X_USE_8BIT  : 0;
>  		lp->cfg.flags |= (SMC_CAN_USE_16BIT) ? SMC91X_USE_16BIT : 0;
>  		lp->cfg.flags |= (SMC_CAN_USE_32BIT) ? SMC91X_USE_32BIT : 0;
> diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
> index 6a90400..3ce1ca4 100644
> --- a/drivers/net/smc91x.h
> +++ b/drivers/net/smc91x.h
> @@ -610,6 +610,8 @@ smc_pxa_dma_irq(int dma, void *dummy)
>  #define SMC_outsl(a, r, p, l)		BUG()
>  #endif
>  
> +extern int smc_io_shift;
> +
>  #if ! SMC_CAN_USE_16BIT
>  
>  /*
> @@ -620,13 +622,13 @@ smc_pxa_dma_irq(int dma, void *dummy)
>  	do {								\
>  		unsigned int __val16 = (x);				\
>  		SMC_outb( __val16, ioaddr, reg );			\
> -		SMC_outb( __val16 >> 8, ioaddr, reg + (1 << SMC_IO_SHIFT));\
> +		SMC_outb( __val16 >> 8, ioaddr, reg + (1 << smc_io_shift));\
>  	} while (0)
>  #define SMC_inw(ioaddr, reg)						\
>  	({								\
>  		unsigned int __val16;					\
>  		__val16 =  SMC_inb( ioaddr, reg );			\
> -		__val16 |= SMC_inb( ioaddr, reg + (1 << SMC_IO_SHIFT)) << 8; \
> +		__val16 |= SMC_inb( ioaddr, reg + (1 << smc_io_shift)) << 8; \
>  		__val16;						\
>  	})
>  
> @@ -670,7 +672,7 @@ smc_pxa_dma_irq(int dma, void *dummy)
>  
>  
>  /* Because of bank switching, the LAN91x uses only 16 I/O ports */
> -#define SMC_IO_EXTENT	(16 << SMC_IO_SHIFT)
> +#define SMC_IO_EXTENT	(16 << smc_io_shift)
>  #define SMC_DATA_EXTENT (4)
>  
>  /*
> @@ -680,7 +682,7 @@ smc_pxa_dma_irq(int dma, void *dummy)
>   .		xx 		= bank number
>   .		yyyy yyyy	= 0x33, for identification purposes.
>  */
> -#define BANK_SELECT		(14 << SMC_IO_SHIFT)
> +#define BANK_SELECT		(14 << smc_io_shift)
>  
>  
>  // Transmit Control Register
> @@ -1033,7 +1035,7 @@ static const char * chip_ids[ 16 ] =  {
>  #define ECSR_PWRDWN		0x04
>  #define ECSR_INT		0x02
>  
> -#define ATTRIB_SIZE		((64*1024) << SMC_IO_SHIFT)
> +#define ATTRIB_SIZE		((64*1024) << smc_io_shift)
>  
>  
>  /*
> @@ -1058,10 +1060,10 @@ static const char * chip_ids[ 16 ] =  {
>  				CARDNAME, __b );			\
>  			BUG();						\
>  		}							\
> -		reg<<SMC_IO_SHIFT;					\
> +		reg<<smc_io_shift;					\
>  	})
>  #else
> -#define SMC_REG(lp, reg, bank)	(reg<<SMC_IO_SHIFT)
> +#define SMC_REG(lp, reg, bank)	(reg<<smc_io_shift)
>  #endif
>  
>  /*
> @@ -1136,7 +1138,7 @@ static const char * chip_ids[ 16 ] =  {
>  #define SMC_SELECT_BANK(lp, x)					\
>  	do {								\
>  		if (SMC_MUST_ALIGN_WRITE(lp))				\
> -			SMC_outl((x)<<16, ioaddr, 12<<SMC_IO_SHIFT);	\
> +			SMC_outl((x)<<16, ioaddr, 12<<smc_io_shift);	\
>  		else							\
>  			SMC_outw(x, ioaddr, BANK_SELECT);		\
>  	} while (0)
> diff --git a/include/linux/smc91x.h b/include/linux/smc91x.h
> index 90434db..f77ebe1 100644
> --- a/include/linux/smc91x.h
> +++ b/include/linux/smc91x.h
> @@ -7,6 +7,12 @@
>  
>  #define SMC91X_NOWAIT		(1 << 3)
>  
> +#define SMC91X_IO_SHIFT_0	(0 << 4)
> +#define SMC91X_IO_SHIFT_1	(1 << 4)
> +#define SMC91X_IO_SHIFT_2	(2 << 4)
> +#define SMC91X_IO_SHIFT_3	(3 << 4)
> +#define SMC91X_IO_SHIFT(x)	(((x) >> 4) & 0x3)
> +
>  struct smc91x_platdata {
>  	unsigned long flags;
>  };
> -- 
> 1.5.4.3
> 


Nicolas
