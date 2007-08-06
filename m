From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 2/4][SSB] EXTIF serial port initialization
Date: Mon, 6 Aug 2007 10:43:20 +0200
Message-ID: <200708061043.20592.mb@bu3sch.de>
References: <20070805231959.GC13927@hall.aurel32.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Felix Fietkau <nbd@openwrt.org>
To: Aurelien Jarno <aurelien@aurel32.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:52416
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755993AbXHFInc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2007 04:43:32 -0400
In-Reply-To: <20070805231959.GC13927@hall.aurel32.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 06 August 2007, Aurelien Jarno wrote:
> The patch below against 2.6.23-rc1-mm2 implements EXTIF serial
> initialization, currently marked as TODO.
> 
> It originally comes from the OpenWrt patches.
> 
> Cc: Felix Fietkau <nbd@openwrt.org>
> Signed-off-by: Aurelien Jarno <aurelien@aurel32.net>
> 
> --- a/drivers/ssb/driver_mipscore.c
> +++ b/drivers/ssb/driver_mipscore.c

Also to driver_extif.c, please.

> @@ -128,51 +128,52 @@
>  	ssb_write32(mdev, SSB_IPSFLAG, irqflag);
>  }
>  
> -/* XXX: leave here or move into separate extif driver? */
> -static int ssb_extif_serial_init(struct ssb_device *dev, struct ssb_serial_ports *ports)
> +static inline bool serial_exists(u8 *regs)
>  {
> +	u8 save_mcr, msr = 0;
>  
> +	if (regs) {
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
> 


