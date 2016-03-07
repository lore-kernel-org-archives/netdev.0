From: Ariel Elior <Ariel.Elior@qlogic.com>
Subject: RE: [PATCH 2/2] bnx2x:Fix error handling for functions in
 bnx2x_link.c
Date: Mon, 7 Mar 2016 14:51:13 +0000
Message-ID: <CY1PR11MB082858B2B8153DF1BF51FF848AB10@CY1PR11MB0828.namprd11.prod.outlook.com>
References: <1457316690-19247-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0147.outbound.protection.outlook.com ([207.46.100.147]:10817
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752568AbcCGP0h convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 10:26:37 -0500
In-Reply-To: <1457316690-19247-1-git-send-email-xerofoify@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Nicholas Krause [mailto:xerofoify@gmail.com]
> Sent: Monday, March 07, 2016 4:12 AM
> To: Ariel Elior <Ariel.Elior@qlogic.com>
> Cc: netdev <netdev@vger.kernel.org>; linux-kernel <linux-kernel@vger.kernel.org>
> Subject: [PATCH 2/2] bnx2x:Fix error handling for functions in bnx2x_link.c
> 
> This fixes various functions that call the function
> bnx2x_84833_get_reset_gpios to properly check if this
> function has returned a error code and if so return
> immediately with the error code to signal these function's
> 
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c | 23 ++++++++++++++++++++---
>  1 file changed, 20 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
> b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
> index a0b03c2..b0646d9 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
> @@ -10079,6 +10079,7 @@ static int bnx2x_84833_hw_reset_phy(struct bnx2x_phy
> *phy,
>  {
>  	struct bnx2x *bp = params->bp;
>  	u8 reset_gpios;
> +	int rc;
>  	u32 other_shmem_base_addr = REG_RD(bp, params->shmem2_base +
>  				offsetof(struct shmem2_region,
>  				other_shmem_base_addr));
> @@ -10099,7 +10100,12 @@ static int bnx2x_84833_hw_reset_phy(struct bnx2x_phy
> *phy,
>  	reset_gpios = bnx2x_84833_get_reset_gpios(bp, shmem_base_path,
>  						  params->chip_id);
> 
> -	bnx2x_set_mult_gpio(bp, reset_gpios,
> MISC_REGISTERS_GPIO_OUTPUT_LOW);
> +	rc = bnx2x_set_mult_gpio(bp, reset_gpios,
> MISC_REGISTERS_GPIO_OUTPUT_LOW);
> +	if (rc) {
> +		DP(NETIF_MSG_LINK, "84833 hw reset on pin values 0x%x\n failed ",
> +		   reset_gpios);
> +		return rc;
> +	}
>  	udelay(10);
>  	DP(NETIF_MSG_LINK, "84833 hw reset on pin values 0x%x\n",
>  		reset_gpios);
> @@ -13242,10 +13248,21 @@ static int bnx2x_84833_common_init_phy(struct
> bnx2x *bp,
>  						u32 chip_id)
>  {
>  	u8 reset_gpios;
> +	int ret;
>  	reset_gpios = bnx2x_84833_get_reset_gpios(bp, shmem_base_path, chip_id);
> -	bnx2x_set_mult_gpio(bp, reset_gpios,
> MISC_REGISTERS_GPIO_OUTPUT_LOW);
> +	ret = bnx2x_set_mult_gpio(bp, reset_gpios,
> MISC_REGISTERS_GPIO_OUTPUT_LOW);
> +	if (ret) {
> +		DP(NETIF_MSG_LINK, "84833 reset pulse on pin values 0x%x\n",
> +		   reset_gpios);
> +		return ret;
> +	}
>  	udelay(10);
> -	bnx2x_set_mult_gpio(bp, reset_gpios,
> MISC_REGISTERS_GPIO_OUTPUT_HIGH);
> +	ret = bnx2x_set_mult_gpio(bp, reset_gpios,
> MISC_REGISTERS_GPIO_OUTPUT_HIGH);
> +	if (ret) {
> +		DP(NETIF_MSG_LINK, "84833 reset pulse on pin values 0x%x\n",
> +		   reset_gpios);
> +		return ret;
> +	}
>  	DP(NETIF_MSG_LINK, "84833 reset pulse on pin values 0x%x\n",
>  		reset_gpios);
>  	return 0;
> --
> 2.1.4
Thanks Nicholas.
Acked-by: Ariel Elior <ariel.elior@qlogic.com>
