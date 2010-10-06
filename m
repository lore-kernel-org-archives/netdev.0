From: Peppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] ethtool: add the stmmac support
Date: Wed, 6 Oct 2010 07:36:40 +0200
Message-ID: <4CAC0AE8.2060808@st.com>
References: <1285667519-4621-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:59634 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755421Ab0JFFhT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Oct 2010 01:37:19 -0400
Received: from zeta.dmz-us.st.com (ns4.st.com [167.4.80.115])
	by beta.dmz-us.st.com (STMicroelectronics) with ESMTP id 5EB323E
	for <netdev@vger.kernel.org>; Wed,  6 Oct 2010 05:33:53 +0000 (GMT)
Received: from Webmail-eu.st.com (safex1hubcas2.st.com [10.75.90.16])
	by zeta.dmz-us.st.com (STMicroelectronics) with ESMTP id 3A8D74D2
	for <netdev@vger.kernel.org>; Wed,  6 Oct 2010 05:37:10 +0000 (GMT)
In-Reply-To: <1285667519-4621-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 09/28/2010 11:51 AM, Giuseppe CAVALLARO wrote:
> Add the stmmac support into the ethtool to
> dump both the Mac Core and Dma registers.

Any news for this patch?

The stmmac is now working on several platforms (not only on STM ST40
based boxes). I think it's worth having the ethtool support for the driver.

Welcome review and advice as usual.

Regards
Peppe

> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> ---
> Makefile.am | 2 +-
> ethtool-util.h | 4 +++
> ethtool.c | 2 +
> stmmac.c | 66 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
> 4 files changed, 73 insertions(+), 1 deletions(-)
> create mode 100644 stmmac.c
> 
> diff --git a/Makefile.am b/Makefile.am
> index 632f054..a0d2116 100644
> --- a/Makefile.am
> +++ b/Makefile.am
> @@ -8,7 +8,7 @@ ethtool_SOURCES = ethtool.c ethtool-copy.h ethtool-util.h \
> amd8111e.c de2104x.c e100.c e1000.c igb.c \
> fec_8xx.c ibm_emac.c ixgb.c ixgbe.c natsemi.c \
> pcnet32.c realtek.c tg3.c marvell.c vioc.c \
> - smsc911x.c at76c50x-usb.c sfc.c
> + smsc911x.c at76c50x-usb.c sfc.c stmmac.c
> 
> dist-hook:
> cp $(top_srcdir)/ethtool.spec $(distdir)
> diff --git a/ethtool-util.h b/ethtool-util.h
> index 01b1d03..4ef3a9f 100644
> --- a/ethtool-util.h
> +++ b/ethtool-util.h
> @@ -93,4 +93,8 @@ int at76c50x_usb_dump_regs(struct ethtool_drvinfo *info, 
> struct ethtool_regs *re
> /* Solarflare Solarstorm controllers */
> int sfc_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
> 
> +/* STMMAC embedded ethernet controller */
> +int st_mac100_dump_regs(struct ethtool_drvinfo *info,
> + struct ethtool_regs *regs);
> +int st_gmac_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
> #endif
> diff --git a/ethtool.c b/ethtool.c
> index 6b2b7c8..ab69b95 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -1539,6 +1539,8 @@ static struct {
> { "smsc911x", smsc911x_dump_regs },
> { "at76c50x-usb", at76c50x_usb_dump_regs },
> { "sfc", sfc_dump_regs },
> + { "st_mac100", st_mac100_dump_regs },
> + { "st_gmac", st_gmac_dump_regs },
> };
> 
> static int dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
> diff --git a/stmmac.c b/stmmac.c
> new file mode 100644
> index 0000000..ad4311c
> --- /dev/null
> +++ b/stmmac.c
> @@ -0,0 +1,66 @@
> +/****************************************************************************
> + * Support for the Synopsys MAC 10/100/1000 on-chip Ethernet controllers
> + *
> + * Copyright (C) 2010 STMicroelectronics Ltd
> + *
> + * Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of the GNU General Public License version 2 as published
> + * by the Free Software Foundation, incorporated herein by reference.
> + */
> +
> +#include <stdio.h>
> +#include <string.h>
> +#include "ethtool-util.h"
> +
> +int st_mac100_dump_regs(struct ethtool_drvinfo *info,
> + struct ethtool_regs *regs)
> +{
> + int i;
> + unsigned int *stmmac_reg = (unsigned int *)regs->data;
> +
> + fprintf(stdout, "ST MAC 10/100 Registers\n");
> + fprintf(stdout, "control reg 0x%08X\n", *stmmac_reg++);
> + fprintf(stdout, "addr HI 0x%08X\n", *stmmac_reg++);
> + fprintf(stdout, "addr LO 0x%08X\n", *stmmac_reg++);
> + fprintf(stdout, "multicast hash HI 0x%08X\n", *stmmac_reg++);
> + fprintf(stdout, "multicast hash LO 0x%08X\n", *stmmac_reg++);
> + fprintf(stdout, "MII addr 0x%08X\n", *stmmac_reg++);
> + fprintf(stdout, "MII data %08X\n", *stmmac_reg++);
> + fprintf(stdout, "flow control 0x%08X\n", *stmmac_reg++);
> + fprintf(stdout, "VLAN1 tag 0x%08X\n", *stmmac_reg++);
> + fprintf(stdout, "VLAN2 tag 0x%08X\n", *stmmac_reg++);
> + fprintf(stdout, "mac wakeup frame 0x%08X\n", *stmmac_reg++);
> + fprintf(stdout, "mac wakeup crtl 0x%08X\n", *stmmac_reg++);
> +
> + fprintf(stdout, "\n");
> + fprintf(stdout, "DMA Registers\n");
> + for (i = 0; i < 9; i++)
> + fprintf(stdout, "CSR%d 0x%08X\n", i, *stmmac_reg++);
> +
> + fprintf(stdout, "DMA cur tx buf addr 0x%08X\n", *stmmac_reg++);
> + fprintf(stdout, "DMA cur rx buf addr 0x%08X\n", *stmmac_reg++);
> +
> + fprintf(stdout, "\n");
> +
> + return 0;
> +}
> +
> +int st_gmac_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
> +{
> + int i;
> + unsigned int *stmmac_reg = (unsigned int *)regs->data;
> +
> + fprintf(stdout, "ST GMAC Registers\n");
> + fprintf(stdout, "GMAC Registers\n");
> + for (i = 0; i < 55; i++)
> + fprintf(stdout, "Reg%d 0x%08X\n", i, *stmmac_reg++);
> +
> + fprintf(stdout, "\n");
> + fprintf(stdout, "DMA Registers\n");
> + for (i = 0; i < 22; i++)
> + fprintf(stdout, "Reg%d 0x%08X\n", i, *stmmac_reg++);
> +
> + return 0;
> +}
> --
> 1.5.5.6
> 
