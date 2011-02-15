From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: Re: [PATCH] bnx2x: Support for managing RX indirection table
Date: Tue, 15 Feb 2011 19:31:34 +0200
Message-ID: <201102151931.35197.vladz@broadcom.com>
References: <alpine.DEB.2.00.1102150815060.27695@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Tom Herbert" <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1396 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755742Ab1BORbt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Feb 2011 12:31:49 -0500
In-Reply-To: <alpine.DEB.2.00.1102150815060.27695@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 15 February 2011 18:24:40 Tom Herbert wrote:
> Support fetching and retrieving RX indirection table via ethtool.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  drivers/net/bnx2x/bnx2x.h         |    2 +
>  drivers/net/bnx2x/bnx2x_ethtool.c |   58 +++++++++++++++++++++++++++++++++++++
>  drivers/net/bnx2x/bnx2x_main.c    |   23 +++++++++++----
>  3 files changed, 77 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
> index 236d79a..bf16119 100644
> --- a/drivers/net/bnx2x/bnx2x.h
> +++ b/drivers/net/bnx2x/bnx2x.h
> @@ -1076,6 +1076,7 @@ struct bnx2x {
>  	int			num_queues;
>  	int			disable_tpa;
>  	int			int_mode;
> +	u32			rx_indir_table[128];
>  
>  	struct tstorm_eth_mac_filter_config	mac_filters;
>  #define BNX2X_ACCEPT_NONE		0x0000
> @@ -1799,5 +1800,6 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
>  BNX2X_EXTERN int load_count[2][3]; /* per path: 0-common, 1-port0, 2-port1 */
>  
>  extern void bnx2x_set_ethtool_ops(struct net_device *netdev);
> +extern void bnx2x_push_indir_table(struct bnx2x *bp);

Why to use "extern" for the prototype here and "static" for the implementation 
below? Pls., declare it in .h (without an "extern") and use it as u do in 
bnx2x_ethtool.c and bnx2x_main.c as u do.

thanks,
vlad

>  
>  #endif /* bnx2x.h */
> diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
> index 816fef6..a99fee4 100644
> --- a/drivers/net/bnx2x/bnx2x_ethtool.c
> +++ b/drivers/net/bnx2x/bnx2x_ethtool.c
> @@ -2134,6 +2134,61 @@ static int bnx2x_phys_id(struct net_device *dev, u32 data)
>  	return 0;
>  }
>  
> +static int
> +bnx2x_get_rxnfc(struct net_device *dev,
> +		struct ethtool_rxnfc *info, void *rules __always_unused)
> +{
> +	struct bnx2x *bp = netdev_priv(dev);
> +
> +	switch (info->cmd) {
> +	case ETHTOOL_GRXRINGS:
> +		info->data = bp->num_queues - NONE_ETH_CONTEXT_USE;
> +		return 0;
> +
> +	default:
> +		return -EOPNOTSUPP;
> +	}
> +}
> +
> +static int bnx2x_get_rxfh_indir(struct net_device *dev,
> +				struct ethtool_rxfh_indir *indir)
> +{
> +	struct bnx2x *bp = netdev_priv(dev);
> +	size_t copy_size =
> +		min_t(size_t, indir->size, TSTORM_INDIRECTION_TABLE_SIZE);
> +
> +	if (bp->multi_mode == ETH_RSS_MODE_DISABLED)
> +		return -ENOENT;
> +
> +	indir->size = TSTORM_INDIRECTION_TABLE_SIZE;
> +	memcpy(indir->ring_index, bp->rx_indir_table,
> +	       copy_size * sizeof(bp->rx_indir_table[0]));
> +	return 0;
> +}
> +
> +static int bnx2x_set_rxfh_indir(struct net_device *dev,
> +				const struct ethtool_rxfh_indir *indir)
> +{
> +	struct bnx2x *bp = netdev_priv(dev);
> +	size_t i;
> +
> +	if (bp->multi_mode == ETH_RSS_MODE_DISABLED)
> +		return -ENOENT;
> +
> +	/* Validate size and indices */
> +	if (indir->size != TSTORM_INDIRECTION_TABLE_SIZE)
> +		return -EINVAL;
> +	for (i = 0; i < TSTORM_INDIRECTION_TABLE_SIZE; i++)
> +		if (indir->ring_index[i] >=
> +		    bp->num_queues - NONE_ETH_CONTEXT_USE)
> +			return -EINVAL;
> +
> +	memcpy(bp->rx_indir_table, indir->ring_index,
> +	       sizeof(bp->rx_indir_table));
> +	bnx2x_push_indir_table(bp);
> +	return 0;
> +}
> +
>  static const struct ethtool_ops bnx2x_ethtool_ops = {
>  	.get_settings		= bnx2x_get_settings,
>  	.set_settings		= bnx2x_set_settings,
> @@ -2170,6 +2225,9 @@ static const struct ethtool_ops bnx2x_ethtool_ops = {
>  	.get_strings		= bnx2x_get_strings,
>  	.phys_id		= bnx2x_phys_id,
>  	.get_ethtool_stats	= bnx2x_get_ethtool_stats,
> +	.get_rxnfc		= bnx2x_get_rxnfc,
> +	.get_rxfh_indir		= bnx2x_get_rxfh_indir,
> +	.set_rxfh_indir		= bnx2x_set_rxfh_indir,
>  };
>  
>  void bnx2x_set_ethtool_ops(struct net_device *netdev)
> diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
> index c238c4d..b1a84d4 100644
> --- a/drivers/net/bnx2x/bnx2x_main.c
> +++ b/drivers/net/bnx2x/bnx2x_main.c
> @@ -4254,7 +4254,7 @@ static void bnx2x_init_eq_ring(struct bnx2x *bp)
>  		min_t(int, MAX_SP_DESC_CNT - MAX_SPQ_PENDING, NUM_EQ_DESC) - 1);
>  }
>  
> -static void bnx2x_init_ind_table(struct bnx2x *bp)
> +void bnx2x_push_indir_table(struct bnx2x *bp)
>  {
>  	int func = BP_FUNC(bp);
>  	int i;
> @@ -4262,13 +4262,24 @@ static void bnx2x_init_ind_table(struct bnx2x *bp)
>  	if (bp->multi_mode == ETH_RSS_MODE_DISABLED)
>  		return;
>  
> -	DP(NETIF_MSG_IFUP,
> -	   "Initializing indirection table  multi_mode %d\n", bp->multi_mode);
>  	for (i = 0; i < TSTORM_INDIRECTION_TABLE_SIZE; i++)
>  		REG_WR8(bp, BAR_TSTRORM_INTMEM +
>  			TSTORM_INDIRECTION_TABLE_OFFSET(func) + i,
> -			bp->fp->cl_id + (i % (bp->num_queues -
> -				NONE_ETH_CONTEXT_USE)));
> +			bp->fp->cl_id + bp->rx_indir_table[i]);
> +}
> +
> +static void bnx2x_init_indir_table(struct bnx2x *bp)
> +{
> +	int i;
> +
> +	BUG_ON(ARRAY_SIZE(bp->rx_indir_table) <
> +	    TSTORM_INDIRECTION_TABLE_SIZE);
> +
> +	for (i = 0; i < TSTORM_INDIRECTION_TABLE_SIZE; i++)
> +		bp->rx_indir_table[i] =
> +		    (i % (bp->num_queues - NONE_ETH_CONTEXT_USE));
> +
> +	bnx2x_push_indir_table(bp);
>  }
>  
>  void bnx2x_set_storm_rx_mode(struct bnx2x *bp)
> @@ -4496,7 +4507,7 @@ void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
>  	bnx2x_init_eq_ring(bp);
>  	bnx2x_init_internal(bp, load_code);
>  	bnx2x_pf_init(bp);
> -	bnx2x_init_ind_table(bp);
> +	bnx2x_init_indir_table(bp);
>  	bnx2x_stats_init(bp);
>  
>  	/* At this point, we are ready for interrupts */
> 

