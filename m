From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 04/11] tg3: Add a warning during link settings
 change if mgmt enabled
Date: Wed, 10 Apr 2013 13:56:49 +0100
Message-ID: <1365598609.2581.8.camel@bwh-desktop.uk.solarflarecom.com>
References: <1365533291-5672-1-git-send-email-nsujir@broadcom.com>
	 <1365533291-5672-5-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<mchan@broadcom.com>
To: Nithin Nayak Sujir <nsujir@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:33154 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932521Ab3DJM4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 08:56:52 -0400
In-Reply-To: <1365533291-5672-5-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-09 at 11:48 -0700, Nithin Nayak Sujir wrote:
> When the user executes certain ethtool commands such as -s, -A, -G, -L,
> -r a phy reset or autonegotiate is performed which results in management
> traffic being interrupted.
> 
> Add a warning in these cases.

It seems entirely obvious that PHY reconfiguration will break the link
and stop all traffic until the link is re-established; this is nothing
specific to this driver.  Is it more disruptive to management traffic on
these controllers?  Unless it is, I think this is not a helpful warning.

Ben.

> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/tg3.c | 14 ++++++++++++++
>  1 file changed, 14 insertions(+)
> 
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index 3f0d43f..a744998 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -2531,6 +2531,13 @@ static void tg3_carrier_off(struct tg3 *tp)
>  	tp->link_up = false;
>  }
>  
> +static void tg3_warn_mgmt_link_flap(struct tg3 *tp)
> +{
> +	if (tg3_flag(tp, ENABLE_ASF))
> +		netdev_warn(tp->dev,
> +			    "Management side-band traffic will be interrupted during phy settings change\n");
> +}
> +
>  /* This will reset the tigon3 PHY if there is no valid
>   * link unless the FORCE argument is non-zero.
>   */
> @@ -11565,6 +11572,8 @@ static int tg3_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
>  		tp->link_config.duplex = cmd->duplex;
>  	}
>  
> +	tg3_warn_mgmt_link_flap(tp);
> +
>  	if (netif_running(dev))
>  		tg3_setup_phy(tp, 1);
>  
> @@ -11643,6 +11652,8 @@ static int tg3_nway_reset(struct net_device *dev)
>  	if (tp->phy_flags & TG3_PHYFLG_PHY_SERDES)
>  		return -EINVAL;
>  
> +	tg3_warn_mgmt_link_flap(tp);
> +
>  	if (tg3_flag(tp, USE_PHYLIB)) {
>  		if (!(tp->phy_flags & TG3_PHYFLG_IS_CONNECTED))
>  			return -EAGAIN;
> @@ -11755,6 +11766,9 @@ static int tg3_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam
>  	struct tg3 *tp = netdev_priv(dev);
>  	int err = 0;
>  
> +	if (tp->link_config.autoneg == AUTONEG_ENABLE)
> +		tg3_warn_mgmt_link_flap(tp);
> +
>  	if (tg3_flag(tp, USE_PHYLIB)) {
>  		u32 newadv;
>  		struct phy_device *phydev;

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
