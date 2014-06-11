From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 1/4] bnx2x: Fix link for KR with swapped polarity
 lane
Date: Wed, 11 Jun 2014 17:36:05 +0400
Message-ID: <53985B45.9020604@cogentembedded.com>
References: <1402493248-5427-1-git-send-email-yuval.mintz@qlogic.com> <1402493248-5427-2-git-send-email-yuval.mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yuval Mintz <yuval.mintz@qlogic.com>, davem@davemloft.net,
	ariel.elior@qlogic.com
To: netdev@vger.kernel.org, Yaniv Rosner <yaniv.rosner@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:56742 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755302AbaFKNgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 09:36:08 -0400
Received: by mail-lb0-f173.google.com with SMTP id 10so4805716lbg.4
        for <netdev@vger.kernel.org>; Wed, 11 Jun 2014 06:36:04 -0700 (PDT)
In-Reply-To: <1402493248-5427-2-git-send-email-yuval.mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/11/2014 05:27 PM, Yuval Mintz wrote:

> From: Yaniv Rosner <yaniv.rosner@qlogic.com>

> This avoids clearing the RX polarity setting in KR mode when polarity lane
> is swapped, as otherwise this will result in failed link.

> Signed-off-by: Yaniv Rosner <yaniv.rosner@qlogic.com>
> Signed-off-by: Yuval Mintz <yuval.mintz@qlogic.com>
> Signed-off-by: Ariel Elior <ariel.elior@qlogic.com>
> ---
>   drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c | 25 ++++++++++++++++++------
>   1 file changed, 19 insertions(+), 6 deletions(-)

> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
> index 9b6b3d7..b052f56 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
[...]
> @@ -3822,15 +3823,27 @@ static void bnx2x_warpcore_enable_AN_KR(struct bnx2x_phy *phy,
>   		/* Enable Auto-Detect to support 1G over CL37 as well */
>   		bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
>   				 MDIO_WC_REG_SERDESDIGITAL_CONTROL1000X1, 0x10);
> -
> +		wc_lane_config = REG_RD(bp, params->shmem_base +
> +					offsetof(struct shmem_region, dev_info.
> +					shared_hw_config.wc_lane_config));
> +		bnx2x_cl45_read(bp, phy, MDIO_WC_DEVAD,
> +				MDIO_WC_REG_RX0_PCI_CTRL + (0x10 * lane), &val);

    () around * not needed. You could also replace it by (lane << 4).

>   		/* Force cl48 sync_status LOW to avoid getting stuck in CL73
>   		 * parallel-detect loop when CL73 and CL37 are enabled.
>   		 */
> -		CL22_WR_OVER_CL45(bp, phy, MDIO_REG_BANK_AER_BLOCK,
> -				  MDIO_AER_BLOCK_AER_REG, 0);
> +		val |= (1<<11);

    () not needed here. And could you please enclose << with spaces for 
consistency?

> +
> +		/* Restore Polarity settings in case it was run over by
> +		 * previous link owner
> +		 */
> +		if (wc_lane_config &
> +		    (SHARED_HW_CFG_RX_LANE0_POL_FLIP_ENABLED << lane))
> +			val |= (3<<2);
> +		else
> +			val &= ~(3<<2);

    Same comments here (2nd case needs parens though).

WBR, Sergei
