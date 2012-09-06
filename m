From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 11/12] qlcnic: 83xx adpater ethtool
Date: Thu, 6 Sep 2012 18:49:44 +0100
Message-ID: <1346953784.2714.17.camel@bwh-desktop.uk.solarflarecom.com>
References: <1346912529-17406-1-git-send-email-sony.chacko@qlogic.com>
	 <1346912529-17406-12-git-send-email-sony.chacko@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Sony Chacko <sony.chacko@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:9154 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932280Ab2IFRts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 13:49:48 -0400
In-Reply-To: <1346912529-17406-12-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-06 at 02:22 -0400, Sony Chacko wrote:
> From: Sony Chacko <sony.chacko@qlogic.com>
> 
> 83xx ethtool interface routines
> 
> Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
> Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
> Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
> Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
> Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
> Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
> ---
>  .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |  583 +++++++++++++-------
>  1 files changed, 374 insertions(+), 209 deletions(-)
> 
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
> index 4625253..b0d21ac 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
[...]
> @@ -146,6 +188,12 @@ static const u32 diag_registers[] = {
>  	QLCNIC_PEG_ALIVE_COUNTER,
>  	QLCNIC_PEG_HALT_STATUS1,
>  	QLCNIC_PEG_HALT_STATUS2,
> +	-1
> +};
> +
> +static const u32 ext_diag_registers[] = {
> +	CRB_XG_STATE_P3P,
> +	ISR_INT_STATE_REG,
>  	QLCNIC_CRB_PEG_NET_0+0x3c,
>  	QLCNIC_CRB_PEG_NET_1+0x3c,
>  	QLCNIC_CRB_PEG_NET_2+0x3c,
> @@ -154,12 +202,19 @@ static const u32 diag_registers[] = {
>  };
>  
>  #define QLCNIC_MGMT_API_VERSION	2
> -#define QLCNIC_DEV_INFO_SIZE	1
>  #define QLCNIC_ETHTOOL_REGS_VER	2

I think QLCNIC_ETHTOOL_REGS_VER needs to be changed, as you appear to be
dumping more registers from the existing hardware as well.

> +
>  static int qlcnic_get_regs_len(struct net_device *dev)
>  {
> -	return sizeof(diag_registers) + QLCNIC_RING_REGS_LEN +
> -				QLCNIC_DEV_INFO_SIZE + 1;
> +	struct qlcnic_adapter *adapter = netdev_priv(dev);
> +	u32 len;
> +
> +	if (QLCNIC_IS_83XX(adapter))
> +		len = qlcnic_83xx_get_regs_len(adapter);
> +	else
> +		len = sizeof(ext_diag_registers) + sizeof(diag_registers);
> +
> +	return QLCNIC_RING_REGS_LEN + len + QLCNIC_DEV_INFO_SIZE + 1;
>  }
>  
>  static int qlcnic_get_eeprom_len(struct net_device *dev)
[...]
> @@ -509,25 +613,6 @@ qlcnic_set_ringparam(struct net_device *dev,
>  	return qlcnic_reset_context(adapter);
>  }
>  
> -static void qlcnic_get_channels(struct net_device *dev,
> -		struct ethtool_channels *channel)
> -{
> -	struct qlcnic_adapter *adapter = netdev_priv(dev);
> -
> -	channel->max_rx = rounddown_pow_of_two(min_t(int,
> -			adapter->ahw->max_rx_ques, num_online_cpus()));
> -	channel->max_tx = adapter->ahw->max_tx_ques;
> -
> -	channel->rx_count = adapter->max_sds_rings;
> -	channel->tx_count = adapter->ahw->max_tx_ques;
> -}
> -
> -static int qlcnic_set_channels(struct net_device *dev,
> -		struct ethtool_channels *channel)
> -{
> -	return 0;
> -}
> -
>  static void
>  qlcnic_get_pauseparam(struct net_device *netdev,
>  			  struct ethtool_pauseparam *pause)
[...]
> +static void qlcnic_get_channels(struct net_device *dev,
> +				struct ethtool_channels *channel)
> +{
> +	struct qlcnic_adapter *adapter = netdev_priv(dev);
> +
> +	channel->max_rx = rounddown_pow_of_two(min_t(int,
> +					       adapter->ahw->max_rx_ques,
> +					       num_online_cpus()));
> +	channel->max_tx = adapter->ahw->max_tx_ques;
> +
> +	channel->rx_count = adapter->max_sds_rings;
> +	channel->tx_count = adapter->ahw->max_tx_ques;
> +}
> +
> +static int qlcnic_set_channels(struct net_device *dev,
> +			       struct ethtool_channels *channel)
> +{
> +	struct qlcnic_adapter *adapter = netdev_priv(dev);
> +	int err;
> +
> +	if (channel->other_count || channel->combined_count ||
> +	    channel->tx_count != channel->max_tx)
> +		return -EINVAL;
> +
> +	err = qlcnic_validate_max_rss(channel->max_rx, channel->rx_count);
> +	if (err)
> +		return err;
> +
> +	err = qlcnic_set_max_rss(adapter, channel->rx_count, 0);
> +	netdev_info(dev, "allocated 0x%x sds rings\n",
> +		    adapter->max_sds_rings);
> +	return err;
> +}

So you removed the body of qlcnic_set_channels() in an earlier patch,
and now you're moving it and putting the body back how it was...  Please
clean up the patch series so it doesn't have noise like this in it.

[...]
> +static int
> +qlcnic_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
> +{
> +	int err;
> +	struct qlcnic_adapter *adapter = netdev_priv(dev);
> +	u32 wol_cfg;
> +
> +	if (QLCNIC_IS_83XX(adapter))
> +		return -EOPNOTSUPP;
> +	if (wol->wolopts & ~WAKE_MAGIC)
> +		return -EOPNOTSUPP;

Should be -EINVAL in the second error case (the device supports the
operation, but not the mode requested).

> +	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG_NV, &err);
> +	if (!(wol_cfg & (1 << adapter->portnum)))
> +		return -EOPNOTSUPP;
> +
> +	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG, &err);
> +	if (wol->wolopts & WAKE_MAGIC)
> +		wol_cfg |= 1UL << adapter->portnum;
> +	else
> +		wol_cfg &= ~(1UL << adapter->portnum);
> +
> +	QLCWR32(adapter, QLCNIC_WOL_CONFIG, wol_cfg);
> +
> +	return 0;
>  }
>  
>  static int qlcnic_set_led(struct net_device *dev,
[...]
> @@ -1081,50 +1297,6 @@ static int qlcnic_set_led(struct net_device *dev,
>  	return err;
>  }
>  
> -static void
> -qlcnic_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
> -{
> -	int err;
> -	struct qlcnic_adapter *adapter = netdev_priv(dev);
> -	u32 wol_cfg;
> -
> -	wol->supported = 0;
> -	wol->wolopts = 0;
> -
> -	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG_NV, &err);
> -	if (wol_cfg & (1UL << adapter->portnum))
> -		wol->supported |= WAKE_MAGIC;
> -
> -	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG, &err);
> -	if (wol_cfg & (1UL << adapter->portnum))
> -		wol->wolopts |= WAKE_MAGIC;
> -}
> -
> -static int
> -qlcnic_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
> -{
> -	int err;
> -	struct qlcnic_adapter *adapter = netdev_priv(dev);
> -	u32 wol_cfg;
> -
> -	if (wol->wolopts & ~WAKE_MAGIC)
> -		return -EOPNOTSUPP;
> -
> -	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG_NV, &err);
> -	if (!(wol_cfg & (1 << adapter->portnum)))
> -		return -EOPNOTSUPP;
> -
> -	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG, &err);
> -	if (wol->wolopts & WAKE_MAGIC)
> -		wol_cfg |= 1UL << adapter->portnum;
> -	else
> -		wol_cfg &= ~(1UL << adapter->portnum);
> -
> -	QLCWR32(adapter, QLCNIC_WOL_CONFIG, wol_cfg);
> -
> -	return 0;
> -}
[...]

Again you've moved functions around for no obvious reason.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
