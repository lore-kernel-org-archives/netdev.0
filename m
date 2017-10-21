From: Tobias Jakobi <tjakobi@math.uni-bielefeld.de>
Subject: Re: [RFC PATCH] net: realtek: r8169: implement set_link_ksettings()
Date: Sat, 21 Oct 2017 21:37:52 +0200
Message-ID: <3fe5db89-1059-c7af-8e55-54543e0415ae@math.uni-bielefeld.de>
References: <20171013164424.4480-1-tjakobi@math.uni-bielefeld.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tremyfr@gmail.com, davem@davemloft.net
To: nic_swsd@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.math.uni-bielefeld.de ([129.70.45.10]:40614 "EHLO
        smtp.math.uni-bielefeld.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932159AbdJUThz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 15:37:55 -0400
In-Reply-To: <20171013164424.4480-1-tjakobi@math.uni-bielefeld.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Any comment on this one? I have been using this in my tree since submission. No
issues to far.

I guess I could also put a Fixes-tag?

- Tobias


Tobias Jakobi wrote:
> Commit 6fa1ba61520576cf1346c4ff09a056f2950cb3bf partially
> implemented the new ethtool API, by replacing get_settings()
> with get_link_ksettings(). This breaks ethtool, since the
> userspace tool (according to the new API specs) never tries
> the legacy set() call, when the new get() call succeeds.
> 
> All attempts to chance some setting from userspace result in:
>> Cannot set new settings: Operation not supported
> 
> Implement the missing set() call.
> 
> Signed-off-by: Tobias Jakobi <tjakobi@math.uni-bielefeld.de>
> ---
>  drivers/net/ethernet/realtek/r8169.c | 40 +++++++++++++++++++++---------------
>  1 file changed, 24 insertions(+), 16 deletions(-)
> 
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index e03fcf914690..24e8f7133038 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -2025,21 +2025,6 @@ static int rtl8169_set_speed(struct net_device *dev,
>  	return ret;
>  }
>  
> -static int rtl8169_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
> -{
> -	struct rtl8169_private *tp = netdev_priv(dev);
> -	int ret;
> -
> -	del_timer_sync(&tp->timer);
> -
> -	rtl_lock_work(tp);
> -	ret = rtl8169_set_speed(dev, cmd->autoneg, ethtool_cmd_speed(cmd),
> -				cmd->duplex, cmd->advertising);
> -	rtl_unlock_work(tp);
> -
> -	return ret;
> -}
> -
>  static netdev_features_t rtl8169_fix_features(struct net_device *dev,
>  	netdev_features_t features)
>  {
> @@ -2166,6 +2151,29 @@ static int rtl8169_get_link_ksettings(struct net_device *dev,
>  	return rc;
>  }
>  
> +static int rtl8169_set_link_ksettings(struct net_device *dev,
> +				      const struct ethtool_link_ksettings *cmd)
> +{
> +	struct rtl8169_private *tp = netdev_priv(dev);
> +	int rc;
> +	u32 advertising;
> +
> +	if (!ethtool_convert_link_mode_to_legacy_u32(&advertising,
> +	    cmd->link_modes.advertising))
> +		return -EINVAL;
> +
> +	del_timer_sync(&tp->timer);
> +
> +	rtl_lock_work(tp);
> +
> +	rc = rtl8169_set_speed(dev, cmd->base.autoneg, cmd->base.speed,
> +			       cmd->base.duplex, advertising);
> +
> +	rtl_unlock_work(tp);
> +
> +	return rc;
> +}
> +
>  static void rtl8169_get_regs(struct net_device *dev, struct ethtool_regs *regs,
>  			     void *p)
>  {
> @@ -2367,7 +2375,6 @@ static const struct ethtool_ops rtl8169_ethtool_ops = {
>  	.get_drvinfo		= rtl8169_get_drvinfo,
>  	.get_regs_len		= rtl8169_get_regs_len,
>  	.get_link		= ethtool_op_get_link,
> -	.set_settings		= rtl8169_set_settings,
>  	.get_msglevel		= rtl8169_get_msglevel,
>  	.set_msglevel		= rtl8169_set_msglevel,
>  	.get_regs		= rtl8169_get_regs,
> @@ -2379,6 +2386,7 @@ static const struct ethtool_ops rtl8169_ethtool_ops = {
>  	.get_ts_info		= ethtool_op_get_ts_info,
>  	.nway_reset		= rtl8169_nway_reset,
>  	.get_link_ksettings	= rtl8169_get_link_ksettings,
> +	.set_link_ksettings	= rtl8169_set_link_ksettings,
>  };
>  
>  static void rtl8169_get_mac_version(struct rtl8169_private *tp,
> 
