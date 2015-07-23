From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: [net-next PATCH v0 3/6] net: netcp: Fixes error in oversized
 memory allocation for statistics storage
Date: Thu, 23 Jul 2015 10:01:21 -0400
Message-ID: <55B0F3B1.60303@ti.com>
References: <1437658368-1679-1-git-send-email-w-kwok2@ti.com> <1437658368-1679-4-git-send-email-w-kwok2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
To: WingMan Kwok <w-kwok2@ti.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:39466 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752437AbbGWOBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 10:01:23 -0400
In-Reply-To: <1437658368-1679-4-git-send-email-w-kwok2@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/23/2015 09:32 AM, WingMan Kwok wrote:
> The CPSW driver keeps internally some, but not all, of
> the statistics available in the hw statistics modules.  Furthermore,
> some of the locations in the hw statistics modules are reserved and
> contain no useful information.  Prior to this patch, the driver
> allocates memory of the size of the the whole hw statistics modules,
> instead of the size of statistics-entries-interested-in (i.e. et_stats),
> for internal storage.  This patch fixes that.
>
> Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
> ---
>   drivers/net/ethernet/ti/netcp_ethss.c |   42 ++++++++++++++++-----------------
>   1 file changed, 21 insertions(+), 21 deletions(-)
>
> diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
> index b954856..a1f16e1 100644
> --- a/drivers/net/ethernet/ti/netcp_ethss.c
> +++ b/drivers/net/ethernet/ti/netcp_ethss.c
> @@ -2555,10 +2555,12 @@ static int set_xgbe_ethss10_priv(struct gbe_priv *gbe_dev,
>   	}
>   	gbe_dev->xgbe_serdes_regs = regs;
>
> +	gbe_dev->et_stats = xgbe10_et_stats;
> +	gbe_dev->num_et_stats = ARRAY_SIZE(xgbe10_et_stats);
> +
>   	gbe_dev->hw_stats = devm_kzalloc(gbe_dev->dev,
> -				  XGBE10_NUM_STAT_ENTRIES *
> -				  (gbe_dev->max_num_ports) * sizeof(u64),
> -	

			  GFP_KERNEL);
Looks like XGBE10_NUM_STAT_ENTRIES is used only here and this is being 
replaced. So could you please remove the #define as well? same for other 
instances if any below.

> +					 gbe_dev->num_et_stats * sizeof(u64),
> +					 GFP_KERNEL);
>   	if (!gbe_dev->hw_stats) {
>   		dev_err(gbe_dev->dev, "hw_stats memory allocation failed\n");
>   		return -ENOMEM;
> @@ -2577,8 +2579,6 @@ static int set_xgbe_ethss10_priv(struct gbe_priv *gbe_dev,
>   	gbe_dev->ale_ports = gbe_dev->max_num_ports;
>   	gbe_dev->host_port = XGBE10_HOST_PORT_NUM;
>   	gbe_dev->ale_entries = XGBE10_NUM_ALE_ENTRIES;
> -	gbe_dev->et_stats = xgbe10_et_stats;
> -	gbe_dev->num_et_stats = ARRAY_SIZE(xgbe10_et_stats);
>   	gbe_dev->stats_en_mask = (1 << (gbe_dev->max_num_ports)) - 1;
>
>   	/* Subsystem registers */
> @@ -2663,10 +2663,12 @@ static int set_gbe_ethss14_priv(struct gbe_priv *gbe_dev,
>   	}
>   	gbe_dev->switch_regs = regs;
>
> +	gbe_dev->et_stats = gbe13_et_stats;
> +	gbe_dev->num_et_stats = ARRAY_SIZE(gbe13_et_stats);
> +
>   	gbe_dev->hw_stats = devm_kzalloc(gbe_dev->dev,
> -					  GBE13_NUM_HW_STAT_ENTRIES *
> -					  gbe_dev->max_num_slaves * sizeof(u64),
> -					  GFP_KERNEL);
> +					 gbe_dev->num_et_stats * sizeof(u64),
> +					 GFP_KERNEL);
>   	if (!gbe_dev->hw_stats) {
>   		dev_err(gbe_dev->dev, "hw_stats memory allocation failed\n");
>   		return -ENOMEM;
> @@ -2689,8 +2691,6 @@ static int set_gbe_ethss14_priv(struct gbe_priv *gbe_dev,
>   	gbe_dev->ale_ports = gbe_dev->max_num_ports;
>   	gbe_dev->host_port = GBE13_HOST_PORT_NUM;
>   	gbe_dev->ale_entries = GBE13_NUM_ALE_ENTRIES;
> -	gbe_dev->et_stats = gbe13_et_stats;
> -	gbe_dev->num_et_stats = ARRAY_SIZE(gbe13_et_stats);
>   	gbe_dev->stats_en_mask = GBE13_REG_VAL_STAT_ENABLE_ALL;
>
>   	/* Subsystem registers */
> @@ -2717,10 +2717,18 @@ static int set_gbenu_ethss_priv(struct gbe_priv *gbe_dev,
>   	void __iomem *regs;
>   	int i, ret;
>
> +	gbe_dev->et_stats = gbenu_et_stats;
> +
> +	if (IS_SS_ID_NU(gbe_dev))
> +		gbe_dev->num_et_stats = GBENU_ET_STATS_HOST_SIZE +
> +			(gbe_dev->max_num_slaves * GBENU_ET_STATS_PORT_SIZE);
> +	else
> +		gbe_dev->num_et_stats = GBENU_ET_STATS_HOST_SIZE +
> +					GBENU_ET_STATS_PORT_SIZE;
> +
>   	gbe_dev->hw_stats = devm_kzalloc(gbe_dev->dev,
> -				  GBENU_NUM_HW_STAT_ENTRIES *
> -				  (gbe_dev->max_num_ports) * sizeof(u64),
> -				  GFP_KERNEL);
> +					 gbe_dev->num_et_stats * sizeof(u64),
> +					 GFP_KERNEL);
>   	if (!gbe_dev->hw_stats) {
>   		dev_err(gbe_dev->dev, "hw_stats memory allocation failed\n");
>   		return -ENOMEM;
> @@ -2753,16 +2761,8 @@ static int set_gbenu_ethss_priv(struct gbe_priv *gbe_dev,
>   	gbe_dev->ale_ports = gbe_dev->max_num_ports;
>   	gbe_dev->host_port = GBENU_HOST_PORT_NUM;
>   	gbe_dev->ale_entries = GBE13_NUM_ALE_ENTRIES;
> -	gbe_dev->et_stats = gbenu_et_stats;
>   	gbe_dev->stats_en_mask = (1 << (gbe_dev->max_num_ports)) - 1;
>
> -	if (IS_SS_ID_NU(gbe_dev))
> -		gbe_dev->num_et_stats = GBENU_ET_STATS_HOST_SIZE +
> -			(gbe_dev->max_num_slaves * GBENU_ET_STATS_PORT_SIZE);
> -	else
> -		gbe_dev->num_et_stats = GBENU_ET_STATS_HOST_SIZE +
> -					GBENU_ET_STATS_PORT_SIZE;
> -
>   	/* Subsystem registers */
>   	GBENU_SET_REG_OFS(gbe_dev, ss_regs, id_ver);
>
>


-- 
Murali Karicheri
Linux Kernel, Keystone
