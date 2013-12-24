From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFC net-next 1/3] [RFC] sh_eth: Add support for r7s72100
Date: Wed, 25 Dec 2013 00:25:05 +0300
Message-ID: <52B9FBB1.6000200@cogentembedded.com>
References: <1387095886-15163-1-git-send-email-horms+renesas@verge.net.au> <1387095886-15163-2-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Magnus Damm <magnus.damm@gmail.com>
To: Simon Horman <horms+renesas@verge.net.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:57024 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916Ab3LXUZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Dec 2013 15:25:05 -0500
Received: by mail-la0-f46.google.com with SMTP id eh20so2991494lab.5
        for <netdev@vger.kernel.org>; Tue, 24 Dec 2013 12:25:02 -0800 (PST)
In-Reply-To: <1387095886-15163-2-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/15/2013 11:24 AM, Simon Horman wrote:

> This appears to be quite similar to the r8a7740.

    Not quite, as it's only capable of 100/10 Mbit/s and lacks some registers.
It's good that you marjed the patch RFC as it doesn't seem correct in some 
places...

> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
> ---
>   drivers/net/ethernet/renesas/sh_eth.c | 37 ++++++++++++++++++++++++++++++++---
>   drivers/net/ethernet/renesas/sh_eth.h |  2 +-
>   2 files changed, 35 insertions(+), 4 deletions(-)

> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index d256ce1..c7c1daf 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -705,6 +705,36 @@ static struct sh_eth_cpu_data r8a7740_data = {
>   	.shift_rd0	= 1,
>   };
>
> +/* R7S72100 */
> +static struct sh_eth_cpu_data r7s72100_data = {
> +	.chip_reset	= sh_eth_chip_reset_r8a7740,

    Doesn't seem right: it calls sh_eth_slect_mii() and RMII_MII register that 
function writes to is not documented in the v0.60 of the manual.

> +	.set_duplex	= sh_eth_set_duplex,
> +	.set_rate	= sh_eth_set_rate_gether,

    Last one does not seem right: it uses GECMR register which doesn't exist, 
according to the v0.60 of the manual. Looks like neither of the existing 
methods fit here and I don't see anything in the manual, so I guess this 
should be NULL instead...

> +
> +	.register_type	= SH_ETH_REG_GIGABIT,
> +
> +	.ecsr_value	= ECSR_LCHNG | ECSR_ICD,

    Hm, ECSR.LCHNG is reserved in my manual.

> +	.ecsipr_value	= ECSIPR_LCHNGIP | ECSIPR_ICDIP,

    Likewise ECSIPR.LCHNGIP. And I don't see the LINK signal in the signal 
list at all...

> +	.eesipr_value	= 0xff7f009f,
> +
> +	.tx_check	= EESR_TC1 | EESR_FTC,

    Note that both these bits mirror themselves.

> +	.eesr_err_check	= EESR_TWB1 | EESR_TWB

    These two mirror themselves too.

> @@ -1316,9 +1346,9 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
>   		/*
>   		 * In case of almost all GETHER/ETHERs, the Receive Frame State
>   		 * (RFS) bits in the Receive Descriptor 0 are from bit 9 to
> -		 * bit 0. However, in case of the R8A7740's GETHER, the RFS
> -		 * bits are from bit 25 to bit 16. So, the driver needs right
> -		 * shifting by 16.
> +		 * bit 0. However, in case of the R8A7740 and R7S72100's
> +		 * GETHER, the RFS bits are from bit 25 to bit 16.

    Not only these SoCs, R8A779x also, if you want to list them all. And 
R7S72100 is not GETHER, it's explicitly called ETHER in the manual.
    Fortunately, this deviation is documented for this SoC. :-)

> +		 * So, the driver needs right shifting by 16.
>   		 */
>   		if (mdp->cd->shift_rd0)
>   			desc_status >>= 16;
> @@ -2805,6 +2835,7 @@ static struct platform_device_id sh_eth_id_table[] = {
>   	{ "sh7757-ether", (kernel_ulong_t)&sh7757_data },
>   	{ "sh7757-gether", (kernel_ulong_t)&sh7757_data_giga },
>   	{ "sh7763-gether", (kernel_ulong_t)&sh7763_data },
> +	{ "r7s72100-gether", (kernel_ulong_t)&r7s72100_data },

    "-ether" as it doesn't support 1000 Mbit/s.

>   	{ "r8a7740-gether", (kernel_ulong_t)&r8a7740_data },
>   	{ "r8a777x-ether", (kernel_ulong_t)&r8a777x_data },
>   	{ "r8a7790-ether", (kernel_ulong_t)&r8a7790_data },
> diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
> index f32c169..f2d3a9f 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.h
> +++ b/drivers/net/ethernet/renesas/sh_eth.h
> @@ -180,7 +180,7 @@ enum EDSR_BIT {
>   };
>   #define EDSR_ENALL (EDSR_ENT|EDSR_ENR)
>
> -/* GECMR : sh7734, sh7763 and r8a7740 only */
> +/* GECMR : sh7734, sh7763, r8a7740 and r7s72100 only */

    Where have you seen this register on R7S72100?

>   enum GECMR_BIT {
>   	GECMR_10 = 0x0, GECMR_100 = 0x04, GECMR_1000 = 0x01,
>   };

WBR, Sergei
