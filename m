From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [PATCH 2/4][SSB] EXTIF serial port initialization
Date: Sun, 5 Aug 2007 21:21:17 -0300
Message-ID: <20070806002117.GJ2469@ghostprotocols.net>
References: <20070805231959.GC13927@hall.aurel32.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	Felix Fietkau <nbd@openwrt.org>
To: Aurelien Jarno <aurelien@aurel32.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:58083 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751567AbXHFAVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Aug 2007 20:21:25 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1321000wxd
        for <netdev@vger.kernel.org>; Sun, 05 Aug 2007 17:21:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20070805231959.GC13927@hall.aurel32.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Mon, Aug 06, 2007 at 01:19:59AM +0200, Aurelien Jarno escreveu:
> The patch below against 2.6.23-rc1-mm2 implements EXTIF serial
> initialization, currently marked as TODO.
> 
> It originally comes from the OpenWrt patches.

Comments below
 
> Cc: Felix Fietkau <nbd@openwrt.org>
> Signed-off-by: Aurelien Jarno <aurelien@aurel32.net>
> 
> --- a/drivers/ssb/driver_mipscore.c
> +++ b/drivers/ssb/driver_mipscore.c
> @@ -128,51 +128,52 @@
>  	ssb_write32(mdev, SSB_IPSFLAG, irqflag);
>  }
>  
> -/* XXX: leave here or move into separate extif driver? */
> -static int ssb_extif_serial_init(struct ssb_device *dev, struct ssb_serial_ports *ports)
> +static inline bool serial_exists(u8 *regs)
>  {
> +	u8 save_mcr, msr = 0;

Why declare save_mcr here...

>  
> +	if (regs) {

if it is just used here?

> +		save_mcr = regs[UART_MCR];
> +		regs[UART_MCR] = (UART_MCR_LOOP | UART_MCR_OUT2 | UART_MCR_RTS);
> +		msr = regs[UART_MSR] & (UART_MSR_DCD | UART_MSR_RI \
> +					| UART_MSR_CTS | UART_MSR_DSR);
> +		regs[UART_MCR] = save_mcr;
> +	}
> +	return (msr == (UART_MSR_DCD | UART_MSR_CTS));
>  }
>  
> -
> -static void ssb_mips_serial_init(struct ssb_mipscore *mcore)
> +static int ssb_extif_serial_init(struct ssb_extif *dev, struct ssb_serial_port *ports)
>  {
> -	struct ssb_bus *bus = mcore->dev->bus;
> +	u32 i, nr_ports = 0;
>  
> -	//TODO if (EXTIF available
> -#if 0
> -		extifregs_t *eir = (extifregs_t *) regs;
> -		sbconfig_t *sb;
> -
> -		/* Determine external UART register base */
> -		sb = (sbconfig_t *)((ulong) eir + SBCONFIGOFF);
> -		base = EXTIF_CFGIF_BASE(sb_base(R_REG(&sb->sbadmatch1)));
> -
> -		/* Determine IRQ */
> -		irq = sb_irq(sbh);
> -
> -		/* Disable GPIO interrupt initially */
> -		W_REG(&eir->gpiointpolarity, 0);
> -		W_REG(&eir->gpiointmask, 0);
> -
> -		/* Search for external UARTs */
> -		n = 2;
> -		for (i = 0; i < 2; i++) {
> -			regs = (void *) REG_MAP(base + (i * 8), 8);
> -			if (BCMINIT(serial_exists)(regs)) {
> -				/* Set GPIO 1 to be the external UART IRQ */
> -				W_REG(&eir->gpiointmask, 2);
> -				if (add)
> -					add(regs, irq, 13500000, 0);
> -			}
> +	/* Disable GPIO interrupt initially */
> +	extif_write32(dev, SSB_EXTIF_GPIO_INTPOL, 0);
> +	extif_write32(dev, SSB_EXTIF_GPIO_INTMASK, 0);
> +
> +	for (i = 0; i < 2; i++) {
> +		void __iomem *uart_regs;
> +
> +		uart_regs = ioremap_nocache(SSB_EUART, 16);

ioremap_nocache can fail, even if just on, say, an instrumented kernel
that inserts failures in such functions to catch possible errors not
being handled.

> +		uart_regs += (i * 8);
> +
> +		if (serial_exists(uart_regs) && ports) {
> +			extif_write32(dev, SSB_EXTIF_GPIO_INTMASK, 2);
> +
> +			nr_ports++;
> +			ports[i].regs = uart_regs;
> +			ports[i].irq = 2;
> +			ports[i].baud_base = 13500000;
> +			ports[i].reg_shift = 0;
>  		}
> +		iounmap(uart_regs);
> +	}
> +	return nr_ports;
> +}
>  
> -		/* Add internal UART if enabled */
> -		if (R_REG(&eir->corecontrol) & CC_UE)
> -			if (add)
> -				add((void *) &eir->uartdata, irq, sb_clock(sbh), 2);
> +static void ssb_mips_serial_init(struct ssb_mipscore *mcore)
> +{
> +	struct ssb_bus *bus = mcore->dev->bus;
>  
> -#endif
>  	if (bus->extif.dev)
>  		mcore->nr_serial_ports = ssb_extif_serial_init(&bus->extif, mcore->serial_ports);
>  	else if (bus->chipco.dev)
