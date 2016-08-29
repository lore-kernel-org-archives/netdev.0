From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH net-next] amd-xgbe: Reset running devices after resume
 from hibernate
Date: Mon, 29 Aug 2016 08:47:27 -0500
Message-ID: <ef2e1a02-30b8-7ce3-2295-661943f76d7d@amd.com>
References: <1472199683-12098-1-git-send-email-james.morse@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
To: James Morse <james.morse@arm.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0046.outbound.protection.outlook.com ([104.47.42.46]:59132
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751277AbcH2RWI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 Aug 2016 13:22:08 -0400
In-Reply-To: <1472199683-12098-1-git-send-email-james.morse@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2016 03:21 AM, James Morse wrote:
> After resume from hibernate on arm64, any amd-xgbe devices that were
> running when we hibernated are reported as down, even when it is not.
> 
> Re-plugging the cables does not cause the interface to come back, the
> link must be marked as down then up via 'ip set link' using the serial
> console.
> 
> This happens because the device has been power-cycled and possibly
> re-initialised by firmware, whereas the driver's memory structures have
> been restored from the hibernate image and the two do not agree.
> 
> Schedule a restart of the device after powerup in case the world changed
> while we were asleep.
> 
> Signed-off-by: James Morse <james.morse@arm.com>

Acked-by: Tom Lendacky <thomas.lendacky@amd.com>

> ---
>  drivers/net/ethernet/amd/xgbe/xgbe-main.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
> index 3eee3201b58f..9de078819aa6 100644
> --- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
> +++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
> @@ -861,9 +861,15 @@ static int xgbe_resume(struct device *dev)
>  	pdata->lpm_ctrl &= ~MDIO_CTRL1_LPOWER;
>  	XMDIO_WRITE(pdata, MDIO_MMD_PCS, MDIO_CTRL1, pdata->lpm_ctrl);
>  
> -	if (netif_running(netdev))
> +	if (netif_running(netdev)) {
>  		ret = xgbe_powerup(netdev, XGMAC_DRIVER_CONTEXT);
>  
> +		/* Schedule a restart in case the link or phy state changed
> +		 * while we were powered down.
> +		 */
> +		schedule_work(&pdata->restart_work);
> +	}
> +
>  	DBGPR("<--xgbe_resume\n");
>  
>  	return ret;
> 
