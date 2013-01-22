From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: add register dump support for SMSC LAN9420
Date: Tue, 22 Jan 2013 20:43:28 +0000
Message-ID: <1358887408.2892.21.camel@bwh-desktop.uk.solarflarecom.com>
References: <1355823279-5533-1-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:30972 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752136Ab3AVUnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 15:43:31 -0500
In-Reply-To: <1355823279-5533-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for the slow response.

On Tue, 2012-12-18 at 09:34 +0000, Steve Glendinning wrote:
> This patch adds support for SMSC's LAN9420 PCI ethernet controller
> to ethtool's dump registers (-d) command.
> 
> This patch is for use with the smsc9420 driver.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
> ---
>  Makefile.am |    2 +-
>  ethtool.c   |    2 ++
>  internal.h  |    3 ++
>  smsc9420.c  |   95 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 101 insertions(+), 1 deletion(-)
>  create mode 100644 smsc9420.c
> 
> diff --git a/Makefile.am b/Makefile.am
> index ba1faa6..728be0a 100644
> --- a/Makefile.am
> +++ b/Makefile.am
> @@ -10,7 +10,7 @@ ethtool_SOURCES = ethtool.c ethtool-copy.h internal.h net_tstamp-copy.h \
>  		  fec_8xx.c ibm_emac.c ixgb.c ixgbe.c natsemi.c	\
>  		  pcnet32.c realtek.c tg3.c marvell.c vioc.c	\
>  		  smsc911x.c at76c50x-usb.c sfc.c stmmac.c	\
> -		  rxclass.c sfpid.c sfpdiag.c
> +		  rxclass.c sfpid.c sfpdiag.c smsc9420.c
>  
>  TESTS = test-cmdline test-features
>  check_PROGRAMS = test-cmdline test-features
> diff --git a/ethtool.c b/ethtool.c
> index 345c21c..97c3d76 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -15,6 +15,7 @@
>   * amd8111e support by Reeja John <reeja.john@amd.com>
>   * long arguments by Andi Kleen.
>   * SMSC LAN911x support by Steve Glendinning <steve.glendinning@smsc.com>
> + * SMSC LAN9420 support by Steve Glendinning <steve.glendinning@shawell.net>

I don't think it makes sense to add credits for features in ethtool.c
when they're entirely implemented in other source files.  I know there
are a lot of these already but I'd guess these date from before those
separate files existed.  Put your name and copyright in smsc9420.c, and
in AUTHORS if you like.

>   * Rx Network Flow Control configuration support <santwona.behera@sun.com>
>   * Various features by Ben Hutchings <bhutchings@solarflare.com>;
>   *	Copyright 2009, 2010 Solarflare Communications
> @@ -884,6 +885,7 @@ static const struct {
>  	{ "sky2", sky2_dump_regs },
>          { "vioc", vioc_dump_regs },
>          { "smsc911x", smsc911x_dump_regs },
> +	{ "smsc9420", smsc9420_dump_regs },
>          { "at76c50x-usb", at76c50x_usb_dump_regs },
>          { "sfc", sfc_dump_regs },
>  	{ "st_mac100", st_mac100_dump_regs },
> diff --git a/internal.h b/internal.h
> index e977a81..8873cd1 100644
> --- a/internal.h
> +++ b/internal.h
> @@ -228,6 +228,9 @@ int vioc_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
>  /* SMSC LAN911x/LAN921x embedded ethernet controller */
>  int smsc911x_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
>  
> +/* SMSC LAN9420 PCI ethernet controller */
> +int smsc9420_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
> +
>  int at76c50x_usb_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
>  
>  /* Solarflare Solarstorm controllers */
> diff --git a/smsc9420.c b/smsc9420.c
> new file mode 100644
> index 0000000..b6a24a0
> --- /dev/null
> +++ b/smsc9420.c
> @@ -0,0 +1,95 @@
> +#include <stdio.h>
> +#include <string.h>
> +#include "internal.h"
> +
> +int smsc9420_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
> +{
> +	unsigned int *smsc_reg = (unsigned int *)regs->data;

No version check?

> +	fprintf(stdout, "LAN9420 DMAC Control & Status Registers\n");
> +	fprintf(stdout, "offset 0x00, BUS_MODE        = 0x%08X\n",*smsc_reg++);

There should be a space after each comma.

> +	fprintf(stdout, "offset 0x04, TX_POLL_DEMAND  = 0x%08X\n",*smsc_reg++);
> +	fprintf(stdout, "offset 0x08, TX_POLL_DEMAND  = 0x%08X\n",*smsc_reg++);
> +	fprintf(stdout, "offset 0x0C, RX_BASE_ADDR    = 0x%08X\n",*smsc_reg++);
> +	fprintf(stdout, "offset 0x10, TX_BASE_ADDR    = 0x%08X\n",*smsc_reg++);
> +	fprintf(stdout, "offset 0x14, DMAC_STATUS     = 0x%08X\n",*smsc_reg++);
> +	fprintf(stdout, "offset 0x18, DMAC_CONTROL    = 0x%08X\n",*smsc_reg++);
> +	fprintf(stdout, "offset 0x1C, DMAC_INTR_ENA   = 0x%08X\n",*smsc_reg++);
> +	fprintf(stdout, "offset 0x20, MISS_FRAME_CNT  = 0x%08X\n",*smsc_reg++);
> +	smsc_reg += 11; /* 0x24 - 0x4C RESERVED */
> +	fprintf(stdout, "offset 0x50, CUR_TX_BUF_ADDR = 0x%08X\n",*smsc_reg++);
> +	fprintf(stdout, "offset 0x54, CUR_RX_BUF_ADDR = 0x%08X\n",*smsc_reg++);
> +	smsc_reg += 10; /* 0x58 - 0x7C RESERVED */
> +	fprintf(stdout, "\n");
> +
> +	fprintf(stdout, "LAN9420 MAC Control & Status Registers\n");
> +	fprintf(stdout, "offset 0x80, MAC_CR          = 0x%08X\n",*smsc_reg++);
> +	fprintf(stdout, "offset 0x84, ADDRH           = 0x%08X\n",*smsc_reg++);
> +	fprintf(stdout, "offset 0x88, ADDRL           = 0x%08X\n",*smsc_reg++);
> +	fprintf(stdout, "offset 0x8C, HASHH           = 0x%08X\n",*smsc_reg++);
> +	fprintf(stdout, "offset 0x90, HASHL           = 0x%08X\n",*smsc_reg++);
> +	fprintf(stdout, "offset 0x94, MIIADDR         = 0x%08X\n",*smsc_reg++);
> +	fprintf(stdout, "offset 0x98, MIIDATA         = 0x%08X\n",*smsc_reg++);
> +	fprintf(stdout, "offset 0x9C, FLOW            = 0x%08X\n",*smsc_reg++);
> +	fprintf(stdout, "offset 0xA0, VLAN1           = 0x%08X\n",*smsc_reg++);
> +	fprintf(stdout, "offset 0xA4, VLAN2           = 0x%08X\n",*smsc_reg++);
> +	fprintf(stdout, "offset 0xA8, WUFF            = 0x%08X\n",*smsc_reg++);
> +	fprintf(stdout, "offset 0xAC, WUCSR           = 0x%08X\n",*smsc_reg++);
> +	fprintf(stdout, "offset 0xB0, COE_CR          = 0x%08X\n",*smsc_reg++);
> +	smsc_reg += 3; /* 0xB4 - 0xBC RESERVED */
> +	fprintf(stdout, "\n");
> +
> +	fprintf(stdout, "LAN9420 System Control & Status Registers\n");
> +	fprintf(stdout, "offset 0xC0, ID_REV          = 0x%08X\n",*smsc_reg++);
> +	fprintf(stdout, "offset 0xC4, INT_CTL         = 0x%08X\n",*smsc_reg++);
> +	fprintf(stdout, "offset 0xC8, INT_STS         = 0x%08X\n",*smsc_reg++);
> +	fprintf(stdout, "offset 0xCC, INT_CFG         = 0x%08X\n",*smsc_reg++);
> +	fprintf(stdout, "offset 0xD0, GPIO_CFG        = 0x%08X\n",*smsc_reg++);
> +	fprintf(stdout, "offset 0xD4, GPT_CFG         = 0x%08X\n",*smsc_reg++);
> +	fprintf(stdout, "offset 0xD8, GPT_CNT         = 0x%08X\n",*smsc_reg++);
> +	fprintf(stdout, "offset 0xDC, BUS_CFG         = 0x%08X\n",*smsc_reg++);
> +	fprintf(stdout, "offset 0xE0, PMT_CTRL        = 0x%08X\n",*smsc_reg++);
> +	smsc_reg += 4; /* 0xE4 - 0xF0 RESERVED */
> +	fprintf(stdout, "offset 0xF4, FREE_RUN        = 0x%08X\n",*smsc_reg++);
> +	fprintf(stdout, "offset 0xF8, E2P_CMD         = 0x%08X\n",*smsc_reg++);
> +	fprintf(stdout, "offset 0xFC, E2P_DATA        = 0x%08X\n",*smsc_reg++);
> +	fprintf(stdout, "\n");
> +
> +	fprintf(stdout, "PHY Registers\n");
> +	fprintf(stdout, "index 0, Basic Control Reg = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "index 1, Basic Status Reg  = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "index 2, PHY identifier 1  = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "index 3, PHY identifier 2  = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "index 4, Auto Negotiation Advertisement Reg = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "index 5, Auto Negotiation Link Partner Ability Reg = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "index 6, Auto Negotiation Expansion Register = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "index 7, Reserved = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "index 8, Reserved = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "index 9, Reserved = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "index 10, Reserved = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "index 11, Reserved = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "index 12, Reserved = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "index 13, Reserved = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "index 14, Reserved = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "index 15, Reserved = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "index 16, Reserved = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "index 17, Mode Control/Status Reg = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "index 18, Special Modes = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "index 19, Reserved = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "index 20, Reserved = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "index 21, Reserved = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "index 22, Reserved = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "index 23, Reserved = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "index 24, Reserved = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "index 25, Reserved = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "index 26, Reserved = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "index 27, Control/Status Indication = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "index 28, Reserved = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "index 29, Interrupt Source Register = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "index 30, Interrupt Mask Register = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "index 31, PHY Special Control/Status Register = 0x%04X\n",*smsc_reg++);
> +	fprintf(stdout, "\n");

Why aren't the PHY register values horizontally aligned while the MAC
and DMA registers are?

> +	return 0;
> +}
> +

My git complains about the blank line on the end, so please remove that.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
