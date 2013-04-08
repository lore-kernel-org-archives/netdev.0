From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 2/2] sh_eth: add R-Car support for real
Date: Mon, 8 Apr 2013 11:39:37 +0900
Message-ID: <20130408023936.GA1643@verge.net.au>
References: <201303290051.32106.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	linux-sh@vger.kernel.org, phil.edworthy@renesas.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201303290051.32106.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 29, 2013 at 12:51:31AM +0300, Sergei Shtylyov wrote:
> Commit d0418bb7123f44b23d69ac349eec7daf9103472f (net: sh_eth: Add eth support
> for R8A7779 device) was a failed attempt to add support for one of members of
> the R-Car SoC family.  That's for three reasons: it treated R8A7779 the  same
> as SH7724 except including quite dirty hack adding ECMR_ELB  bit  to the mask
> in sh_eth_set_rate() while not removing ECMR_RTM bit (despite it's reserved in
> R-Car Ether), and it didn't add a new register offset array despite the closest
> SH_ETH_REG_FAST_SH4 mapping differs by 0x200 to the offsets all the R-Car Ether
> registers have, and also some of the registers in this old mapping don't exist
> on R-Car Ether (due to this, SH7724's 'sh_eth_my_cpu_data' structure is not
> adequeate for R-Car too).  Fix all these shortcomings, restoring the SH7724
> related section to its pristine state...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Hi Sergei,

thanks for this and sorry for not noticing it earlier.
I will try exercising it on the r8a7790 lager.

IIRC you previously mentioned that you were doing work on unravelling
the #define mess in sh_eth. I am wondering if you have made any progress
in that area. In particular, other than sh_eth it looks like
the r8a7740 and r8a7790 could use a common .config. So it would
be nice if sh_eth could support at least those two in the same build.

> ---
> The patch is against the David Miller's 'net-next.git' repo.
> 
> Support for the other members of R-Car family such as R8A7778 and R8A7790 should
> probably be added when they hit mainline (support for the former is already in
> the 'next' branch of Simon Horman's 'renesas.git' repo).
> 
>  drivers/net/ethernet/renesas/sh_eth.c |  107 +++++++++++++++++++++++++++++++---
>  include/linux/sh_eth.h                |    1 
>  2 files changed, 100 insertions(+), 8 deletions(-)
> 
> Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
> ===================================================================
> --- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
> +++ net-next/drivers/net/ethernet/renesas/sh_eth.c
> @@ -2,7 +2,8 @@
>   *  SuperH Ethernet device driver
>   *
>   *  Copyright (C) 2006-2012 Nobuhiro Iwamatsu
> - *  Copyright (C) 2008-2012 Renesas Solutions Corp.
> + *  Copyright (C) 2008-2013 Renesas Solutions Corp.
> + *  Copyright (C) 2013 Cogent Embedded, Inc.
>   *
>   *  This program is free software; you can redistribute it and/or modify it
>   *  under the terms and conditions of the GNU General Public License,
> @@ -147,6 +148,51 @@ static const u16 sh_eth_offset_gigabit[S
>  	[FWALCR1]	= 0x00b4,
>  };
>  
> +static const u16 sh_eth_offset_fast_rcar[SH_ETH_MAX_REGISTER_OFFSET] = {
> +	[ECMR]		= 0x0300,
> +	[RFLR]		= 0x0308,
> +	[ECSR]		= 0x0310,
> +	[ECSIPR]	= 0x0318,
> +	[PIR]		= 0x0320,
> +	[PSR]		= 0x0328,
> +	[RDMLR]		= 0x0340,
> +	[IPGR]		= 0x0350,
> +	[APR]		= 0x0354,
> +	[MPR]		= 0x0358,
> +	[RFCF]		= 0x0360,
> +	[TPAUSER]	= 0x0364,
> +	[TPAUSECR]	= 0x0368,
> +	[MAHR]		= 0x03c0,
> +	[MALR]		= 0x03c8,
> +	[TROCR]		= 0x03d0,
> +	[CDCR]		= 0x03d4,
> +	[LCCR]		= 0x03d8,
> +	[CNDCR]		= 0x03dc,
> +	[CEFCR]		= 0x03e4,
> +	[FRECR]		= 0x03e8,
> +	[TSFRCR]	= 0x03ec,
> +	[TLFRCR]	= 0x03f0,
> +	[RFCR]		= 0x03f4,
> +	[MAFCR]		= 0x03f8,
> +
> +	[EDMR]		= 0x0200,
> +	[EDTRR]		= 0x0208,
> +	[EDRRR]		= 0x0210,
> +	[TDLAR]		= 0x0218,
> +	[RDLAR]		= 0x0220,
> +	[EESR]		= 0x0228,
> +	[EESIPR]	= 0x0230,
> +	[TRSCER]	= 0x0238,
> +	[RMFCR]		= 0x0240,
> +	[TFTR]		= 0x0248,
> +	[FDR]		= 0x0250,
> +	[RMCR]		= 0x0258,
> +	[TFUCR]		= 0x0264,
> +	[RFOCR]		= 0x0268,
> +	[FCFTR]		= 0x0270,
> +	[TRIMD]		= 0x027c,
> +};
> +
>  static const u16 sh_eth_offset_fast_sh4[SH_ETH_MAX_REGISTER_OFFSET] = {
>  	[ECMR]		= 0x0100,
>  	[RFLR]		= 0x0108,
> @@ -296,7 +342,7 @@ static void sh_eth_select_mii(struct net
>  #endif
>  
>  /* There is CPU dependent code */
> -#if defined(CONFIG_CPU_SUBTYPE_SH7724) || defined(CONFIG_ARCH_R8A7779)
> +#if defined(CONFIG_ARCH_R8A7779)
>  #define SH_ETH_RESET_DEFAULT	1
>  static void sh_eth_set_duplex(struct net_device *ndev)
>  {
> @@ -311,18 +357,60 @@ static void sh_eth_set_duplex(struct net
>  static void sh_eth_set_rate(struct net_device *ndev)
>  {
>  	struct sh_eth_private *mdp = netdev_priv(ndev);
> -	unsigned int bits = ECMR_RTM;
>  
> -#if defined(CONFIG_ARCH_R8A7779)
> -	bits |= ECMR_ELB;
> -#endif
> +	switch (mdp->speed) {
> +	case 10: /* 10BASE */
> +		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) & ~ECMR_ELB, ECMR);
> +		break;
> +	case 100:/* 100BASE */
> +		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) | ECMR_ELB, ECMR);
> +		break;
> +	default:
> +		break;
> +	}
> +}
> +
> +/* R8A7779 */
> +static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
> +	.set_duplex	= sh_eth_set_duplex,
> +	.set_rate	= sh_eth_set_rate,
> +
> +	.ecsr_value	= ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD,
> +	.ecsipr_value	= ECSIPR_PSRTOIP | ECSIPR_LCHNGIP | ECSIPR_ICDIP,
> +	.eesipr_value	= 0x01ff009f,
> +
> +	.tx_check	= EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | EESR_RTO,
> +	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RDE |
> +			  EESR_RFRMER | EESR_TFE | EESR_TDE | EESR_ECI,
> +	.tx_error_check	= EESR_TWB | EESR_TABT | EESR_TDE | EESR_TFE,
> +
> +	.apr		= 1,
> +	.mpr		= 1,
> +	.tpauser	= 1,
> +	.hw_swap	= 1,
> +};
> +#elif defined(CONFIG_CPU_SUBTYPE_SH7724)
> +#define SH_ETH_RESET_DEFAULT	1
> +static void sh_eth_set_duplex(struct net_device *ndev)
> +{
> +	struct sh_eth_private *mdp = netdev_priv(ndev);
> +
> +	if (mdp->duplex) /* Full */
> +		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) | ECMR_DM, ECMR);
> +	else		/* Half */
> +		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) & ~ECMR_DM, ECMR);
> +}
> +
> +static void sh_eth_set_rate(struct net_device *ndev)
> +{
> +	struct sh_eth_private *mdp = netdev_priv(ndev);
>  
>  	switch (mdp->speed) {
>  	case 10: /* 10BASE */
> -		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) & ~bits, ECMR);
> +		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) & ~ECMR_RTM, ECMR);
>  		break;
>  	case 100:/* 100BASE */
> -		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) | bits, ECMR);
> +		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) | ECMR_RTM, ECMR);
>  		break;
>  	default:
>  		break;
> @@ -2521,6 +2609,9 @@ static const u16 *sh_eth_get_register_of
>  	case SH_ETH_REG_GIGABIT:
>  		reg_offset = sh_eth_offset_gigabit;
>  		break;
> +	case SH_ETH_REG_FAST_RCAR:
> +		reg_offset = sh_eth_offset_fast_rcar;
> +		break;
>  	case SH_ETH_REG_FAST_SH4:
>  		reg_offset = sh_eth_offset_fast_sh4;
>  		break;
> Index: net-next/include/linux/sh_eth.h
> ===================================================================
> --- net-next.orig/include/linux/sh_eth.h
> +++ net-next/include/linux/sh_eth.h
> @@ -6,6 +6,7 @@
>  enum {EDMAC_LITTLE_ENDIAN, EDMAC_BIG_ENDIAN};
>  enum {
>  	SH_ETH_REG_GIGABIT,
> +	SH_ETH_REG_FAST_RCAR,
>  	SH_ETH_REG_FAST_SH4,
>  	SH_ETH_REG_FAST_SH3_SH2
>  };
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sh" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
