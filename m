From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 4/6] be2net: add ethtool::set_settings support
Date: Fri, 05 Aug 2011 22:43:26 +0100
Message-ID: <1312580606.2715.41.camel@bwh-desktop>
References: <20110805200036.GA13585@akhaparde-VBox>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ajit Khaparde <ajit.khaparde@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:35742 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754501Ab1HEVn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 17:43:29 -0400
In-Reply-To: <20110805200036.GA13585@akhaparde-VBox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-08-05 at 15:00 -0500, Ajit Khaparde wrote:
> Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
> ---
>  drivers/net/benet/be_ethtool.c |   63 ++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 63 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
> index f144a6f..5dd3ed6 100644
> --- a/drivers/net/benet/be_ethtool.c
> +++ b/drivers/net/benet/be_ethtool.c
> @@ -443,6 +443,68 @@ static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
>  	return 0;
>  }
>  
> +static int be_set_settings(struct net_device *netdev,
> +				struct ethtool_cmd *ecmd)
> +{
> +	struct be_adapter *adapter = netdev_priv(netdev);
> +	struct be_phy_info phy_info;
> +	u16 mac_speed = 0;
> +	u16 dac_cable_len = 0;
> +	u16 port_speed = 0;
> +	int status;
> +
> +	status = be_cmd_get_phy_info(adapter, &phy_info);
> +	if (status) {
> +		dev_err(&adapter->pdev->dev, "Get phy info cmd failed.\n");
> +		return status;
> +	}
> +
> +	if (ecmd->autoneg == AUTONEG_ENABLE) {
> +		switch (phy_info.interface_type) {
> +		case PHY_TYPE_SFP_1GB:
> +		case PHY_TYPE_BASET_1GB:
> +		case PHY_TYPE_BASEX_1GB:
> +		case PHY_TYPE_SGMII:
> +			mac_speed = SPEED_AUTONEG_1GB_100MB_10MB;
> +			break;
> +		case PHY_TYPE_SFP_PLUS_10GB:
> +			 dev_warn(&adapter->pdev->dev,
> +				"Autoneg not supported on this module.\n");
> +			 return -EINVAL;
> +		case PHY_TYPE_KR_10GB:
> +		case PHY_TYPE_KX4_10GB:
> +			 mac_speed = SPEED_AUTONEG_10GB_1GB;
> +			 break;
> +		case PHY_TYPE_BASET_10GB:
> +			 mac_speed = SPEED_AUTONEG_10GB_1GB_100MB;
> +			 break;
> +		}
[....]

This is wrong.  When autoneg is enabled, you have to look at the
'advertised' field to find out which link modes you are supposed to
enable.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

