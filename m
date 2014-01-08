From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v4 net-next 2/4] sh_eth: Add support for r7s72100
Date: Wed, 08 Jan 2014 23:58:09 +0300
Message-ID: <52CDBBE1.1010301@cogentembedded.com>
References: <1389168152-9434-1-git-send-email-horms+renesas@verge.net.au> <1389168152-9434-3-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org,
	Magnus Damm <magnus.damm@gmail.com>
To: Simon Horman <horms+renesas@verge.net.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:38617 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753591AbaAHT6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 14:58:07 -0500
Received: by mail-lb0-f178.google.com with SMTP id c11so1626187lbj.23
        for <netdev@vger.kernel.org>; Wed, 08 Jan 2014 11:58:06 -0800 (PST)
In-Reply-To: <1389168152-9434-3-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/08/2014 11:02 AM, Simon Horman wrote:

> This is a fast ethernet controller.

> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

[...]

> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index 4b38533..cc6d4af 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -190,6 +190,59 @@ static const u16 sh_eth_offset_fast_rcar[SH_ETH_MAX_REGISTER_OFFSET] = {
>   	[TRIMD]		= 0x027c,
>   };
>
> +static const u16 sh_eth_offset_fast_rz[SH_ETH_MAX_REGISTER_OFFSET] = {
[...]
> +	[ECMR]		= 0x0500,
> +	[ECSR]		= 0x0510,
> +	[ECSIPR]	= 0x0518,
> +	[PIR]		= 0x0520,
> +	[APR]		= 0x0554,
> +	[MPR]		= 0x0558,
> +	[PFTCR]		= 0x055c,
> +	[PFRCR]		= 0x0560,
> +	[TPAUSER]	= 0x0564,
> +	[MAHR]		= 0x05c0,
> +	[MALR]		= 0x05c8,
> +	[CEFCR]		= 0x0740,
> +	[FRECR]		= 0x0748,
> +	[TSFRCR]	= 0x0750,
> +	[TLFRCR]	= 0x0758,
> +	[RFCR]		= 0x0760,
> +	[MAFCR]		= 0x0778,

    You've missed RFLR @ 0x0508. It's a vital register which the driver 
requires to be always mapped.

> +
> +	[ARSTR]		= 0x0000,
> +	[TSU_CTRST]	= 0x0004,
> +	[TSU_VTAG0]	= 0x0058,
> +	[TSU_ADSBSY]	= 0x0060,
> +	[TSU_TEN]	= 0x0064,
> +	[TSU_ADRH0]	= 0x0100,
> +	[TSU_ADRL0]	= 0x0104,
> +	[TSU_ADRH31]	= 0x01f8,
> +	[TSU_ADRL31]	= 0x01fc,

    Looking at the manual, you've missed [TR]X[NA]LCR regs starting at offset 
0x0080 from TSU block.

    I see that both E-MAC and TSU blocks turned out to be different from the 
Gigabit version upon further scrutiny...

> +};
> +
>   static const u16 sh_eth_offset_fast_sh4[SH_ETH_MAX_REGISTER_OFFSET] = {
>   	[ECMR]		= 0x0100,
>   	[RFLR]		= 0x0108,
[...]
> @@ -701,6 +762,35 @@ static struct sh_eth_cpu_data r8a7740_data = {
>   	.shift_rd0	= 1,
>   };
>
> +/* R7S72100 */
> +static struct sh_eth_cpu_data r7s72100_data = {
> +	.chip_reset	= sh_eth_chip_reset,
> +	.set_duplex	= sh_eth_set_duplex,
> +
> +	.register_type	= SH_ETH_REG_FAST_RZ,
> +
> +	.ecsr_value	= ECSR_ICD,
> +	.ecsipr_value	= ECSIPR_ICDIP,
> +	.eesipr_value	= 0xff7f009f,
> +
> +	.tx_check	= EESR_TC1 | EESR_FTC,
> +	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
> +			  EESR_RFE | EESR_RDE | EESR_RFRMER | EESR_TFE |
> +			  EESR_TDE | EESR_ECI,
> +	.fdr_value	= 0x0000070f,
> +	.rmcr_value	= RMCR_RNC,
> +
> +	.apr		= 1,
> +	.mpr		= 1,
> +	.tpauser	= 1,
> +	.hw_swap	= 1,
> +	.rpadir		= 1,
> +	.rpadir_value   = 2 << 16,
> +	.no_trimd	= 1,
> +	.tsu		= 1,
> +	.shift_rd0	= 1,

    Perhaps this field should be renamed to something talking about check 
summing support (since bits 0..15 of RD0 contain a frame check sum for those 
SoCs). Or maybe it should be just merged with the 'hw_crc' field...

    Well, now the comments about your initializer: you've missed to set the 
'no_psr' field -- this SoC doesn't have PSR (which usually holds the LINK 
signal status). It's not fatal since you're setting 'no_ether_link' in the 
platform data but should be fixed anyway. You've also missed to set 'no_ade' 
field, though 'eesipr_value' correctly has EESIPR.ADEIP cleared. And it looks 
like you've also missed to set 'hw_crc' field since this SoC has CSMR...

[...]
> @@ -880,6 +970,8 @@ static unsigned long sh_eth_get_edtrr_trns(struct sh_eth_private *mdp)
>   {
>   	if (sh_eth_is_gether(mdp))
>   		return EDTRR_TRNS_GETHER;
> +	else if (sh_eth_is_rz_fast_ether(mdp))
> +		return EDTRR_TRNS_RZ_ETHER;

    I'd just merge this with the GEther case.

>   	else
>   		return EDTRR_TRNS_ETHER;
>   }
[...]
> @@ -1062,7 +1155,8 @@ static void sh_eth_ring_format(struct net_device *ndev)
>   		if (i == 0) {
>   			/* Tx descriptor address set */
>   			sh_eth_write(ndev, mdp->tx_desc_dma, TDLAR);
> -			if (sh_eth_is_gether(mdp))
> +			if (sh_eth_is_gether(mdp) ||
> +			    sh_eth_is_rz_fast_ether(mdp))
>   				sh_eth_write(ndev, mdp->tx_desc_dma, TDFAR);

    Hmm, TDFAR exists also on SH4 Ethers...

[...]
> @@ -2564,6 +2666,9 @@ static const u16 *sh_eth_get_register_offset(int register_type)
>   	case SH_ETH_REG_FAST_RCAR:
>   		reg_offset = sh_eth_offset_fast_rcar;
>   		break;
> +	case SH_ETH_REG_FAST_RZ:
> +		reg_offset = sh_eth_offset_fast_rz;
> +		break;

    I think it should precede the R-Car case as this chip is newer than R-Car 
and the SoC families appear here in the reverse order.

>   	case SH_ETH_REG_FAST_SH4:
>   		reg_offset = sh_eth_offset_fast_sh4;
>   		break;
[...]
> diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
> index 0fe35b7..0bcde90 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.h
> +++ b/drivers/net/ethernet/renesas/sh_eth.h
> @@ -156,6 +156,7 @@ enum {
>   enum {
>   	SH_ETH_REG_GIGABIT,
>   	SH_ETH_REG_FAST_RCAR,
> +	SH_ETH_REG_FAST_RZ,

    I think it should precede the R-Car value.

>   	SH_ETH_REG_FAST_SH4,
>   	SH_ETH_REG_FAST_SH3_SH2
>   };
> @@ -169,7 +170,7 @@ enum {
>
>   /* Register's bits
>    */
> -/* EDSR : sh7734, sh7757, sh7763, and r8a7740 only */
> +/* EDSR : sh7734, sh7757, sh7763, r8a7740 and r7s72100 only */

    Need comma before "and". Sorry for the grammar nitpicking. :-)

>   enum EDSR_BIT {
>   	EDSR_ENT = 0x01, EDSR_ENR = 0x02,
>   };
> @@ -191,6 +192,7 @@ enum DMAC_M_BIT {
>   /* EDTRR */
>   enum DMAC_T_BIT {
>   	EDTRR_TRNS_GETHER = 0x03,
> +	EDTRR_TRNS_RZ_ETHER = 0x03,

    I doubt we need a special case here. You didn't introduce one for the 
software reset bits.

>   	EDTRR_TRNS_ETHER = 0x01,
>   };

WBR, Sergei
