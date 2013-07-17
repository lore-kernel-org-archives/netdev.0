From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/2] igb: Expose RSS indirection table for ethtool
Date: Wed, 17 Jul 2013 17:52:20 +0100
Message-ID: <1374079940.3861.10.camel@bwh-desktop.uk.level5networks.com>
References: <1374043806-17284-1-git-send-email-laura.vasilescu@rosedu.org>
	 <1374043806-17284-2-git-send-email-laura.vasilescu@rosedu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <jeffrey.t.kirsher@intel.com>,
	<carolyn.wyborny@intel.com>, <anjali.singhai@intel.com>
To: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:51039 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932757Ab3GQQwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jul 2013 12:52:25 -0400
In-Reply-To: <1374043806-17284-2-git-send-email-laura.vasilescu@rosedu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is wrong, as there are 4 entries packed into each register.

On Wed, 2013-07-17 at 09:50 +0300, Laura Mihaela Vasilescu wrote:
> Signed-off-by: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
> ---
>  drivers/net/ethernet/intel/igb/igb_ethtool.c |   32 ++++++++++++++++++++++++++
>  1 file changed, 32 insertions(+)
> 
> diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
> index 85fe7b5..7e18dfa 100644
> --- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
> +++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
> @@ -2771,6 +2771,35 @@ static void igb_ethtool_complete(struct net_device *netdev)
>  	pm_runtime_put(&adapter->pdev->dev);
>  }
>  
> +static u32 igb_get_rss_table_size(struct net_device *netdev)
> +{
> +	return IGB_RETA_SIZE;

* 4

> +}
> +
> +static int igb_get_rss_table(struct net_device *netdev, u32 *rxfh_indir_tbl)
> +{
> +	struct igb_adapter *adapter = netdev_priv(netdev);
> +	struct e1000_hw *hw = &adapter->hw;
> +	int i;
> +
> +	for (i = 0; i < IGB_RETA_SIZE; i++)
> +		rxfh_indir_tbl[i] = rd32(E1000_RETA(i));

Unpack each register into entries i*4, i*4+1, i*4+2, i*4+3.

> +
> +	return 0;
> +}
> +
> +static int igb_set_rss_table(struct net_device *netdev, const u32 *rxfh_indir_tbl)
> +{
> +	struct igb_adapter *adapter = netdev_priv(netdev);
> +	struct e1000_hw *hw = &adapter->hw;
> +	int i;
> +
> +	for (i = 0; i < IGB_RETA_SIZE; i++)
> +		wr32(E1000_RETA(i), rxfh_indir_tbl[i]);

Pack entries i*4, i*4+1, i*4+2, i*4+3 into each register (as in
igb_setup_mrqc()).

> +
> +	return 0;
> +}

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
