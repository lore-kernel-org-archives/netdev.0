From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 1/4][SSB] EXTIF timing initialization
Date: Mon, 6 Aug 2007 10:42:14 +0200
Message-ID: <200708061042.14722.mb@bu3sch.de>
References: <20070805231910.GB13927@hall.aurel32.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Felix Fietkau <nbd@openwrt.org>
To: Aurelien Jarno <aurelien@aurel32.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:52299
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754445AbXHFIm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2007 04:42:27 -0400
In-Reply-To: <20070805231910.GB13927@hall.aurel32.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 06 August 2007, Aurelien Jarno wrote:
> The patch below against 2.6.23-rc1-mm2 implements EXTIF timing 
> initialization, currently marked as TODO.
> 
> It originally comes from the OpenWrt patches.
> 
> Cc: Felix Fietkau <nbd@openwrt.org>
> Signed-off-by: Aurelien Jarno <aurelien@aurel32.net>
> 
> --- a/drivers/ssb/driver_mipscore.c
> +++ b/drivers/ssb/driver_mipscore.c

Please do a seperate file driver_extif.c to implement these functions
and call it from the mipscore driver.
Compilation can also depend on the mipscore kconfig option, so no
additional kconfig is needed.

> @@ -4,6 +4,7 @@
>   *
>   * Copyright 2005, Broadcom Corporation
>   * Copyright 2006, 2007, Michael Buesch <mb@bu3sch.de>
> + * Copyright 2006, 2007, Felix Fietkau <nbd@openwrt.org>
>   *
>   * Licensed under the GNU/GPL. See COPYING for details.
>   */
> @@ -31,6 +32,16 @@
>  	ssb_write32(mcore->dev, offset, value);
>  }
>  
> +static inline u32 extif_read32(struct ssb_extif *extif, u16 offset)
> +{
> +	return ssb_read32(extif->dev, offset);
> +}
> +
> +static inline void extif_write32(struct ssb_extif *extif, u16 offset, u32 value)
> +{
> +	ssb_write32(extif->dev, offset, value);
> +}
> +
>  static const u32 ipsflag_irq_mask[] = {
>  	0,
>  	SSB_IPSFLAG_IRQ1,
> @@ -183,6 +194,26 @@
>  	}
>  }
>  
> +static void ssb_extif_timing_init(struct ssb_extif *extif, u32 ns)
> +{
> +	u32 tmp;
> +
> +	/* Initialize extif so we can get to the LEDs and external UART */
> +	extif_write32(extif, SSB_EXTIF_PROG_CFG, SSB_EXTCFG_EN);
> +
> +	/* Set timing for the flash */
> +	tmp  = DIV_ROUND_UP(10, ns) << SSB_PROG_WCNT_3_SHIFT;
> +	tmp |= DIV_ROUND_UP(40, ns) << SSB_PROG_WCNT_1_SHIFT;
> +	tmp |= DIV_ROUND_UP(120, ns);
> +	extif_write32(extif, SSB_EXTIF_PROG_WAITCNT, tmp);
> +
> +	/* Set programmable interface timing for external uart */
> +	tmp  = DIV_ROUND_UP(10, ns) << SSB_PROG_WCNT_3_SHIFT;
> +	tmp |= DIV_ROUND_UP(20, ns) << SSB_PROG_WCNT_2_SHIFT;
> +	tmp |= DIV_ROUND_UP(100, ns) << SSB_PROG_WCNT_1_SHIFT;
> +	tmp |= DIV_ROUND_UP(120, ns);
> +	extif_write32(extif, SSB_EXTIF_PROG_WAITCNT, tmp);
> +}
>  
>  static void ssb_cpu_clock(struct ssb_mipscore *mcore)
>  {
> @@ -205,27 +236,9 @@
>  		hz = 100000000;
>  	ns = 1000000000 / hz;
>  
> -//TODO
> -#if 0
> -	if (have EXTIF) {
> -		/* Initialize extif so we can get to the LEDs and external UART */
> -		W_REG(&eir->prog_config, CF_EN);
> -
> -		/* Set timing for the flash */
> -		tmp = CEIL(10, ns) << FW_W3_SHIFT;	/* W3 = 10nS */
> -		tmp = tmp | (CEIL(40, ns) << FW_W1_SHIFT); /* W1 = 40nS */
> -		tmp = tmp | CEIL(120, ns);		/* W0 = 120nS */
> -		W_REG(&eir->prog_waitcount, tmp);	/* 0x01020a0c for a 100Mhz clock */
> -
> -		/* Set programmable interface timing for external uart */
> -		tmp = CEIL(10, ns) << FW_W3_SHIFT;	/* W3 = 10nS */
> -		tmp = tmp | (CEIL(20, ns) << FW_W2_SHIFT); /* W2 = 20nS */
> -		tmp = tmp | (CEIL(100, ns) << FW_W1_SHIFT); /* W1 = 100nS */
> -		tmp = tmp | CEIL(120, ns);		/* W0 = 120nS */
> -		W_REG(&eir->prog_waitcount, tmp);
> -	}
> -#endif
> -	if (bus->chipco.dev)
> +	if (bus->extif.dev)
> +		ssb_extif_timing_init(&bus->extif, ns);
> +	else if (bus->chipco.dev)
>  		ssb_chipco_timing_init(&bus->chipco, ns);
>  
>  	/* Assign IRQs to all cores on the bus, start with irq line 2, because serial usually takes 1 */
> 


