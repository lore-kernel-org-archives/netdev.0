From: Matt Wilson <msw@amzn.com>
Subject: Re: [PATCH V2 net 07/20] net/ena: refactor ena_get_stats64 to be
 atomic context safe
Date: Sun, 4 Dec 2016 20:24:35 -0800
Message-ID: <20161205042435.GG4310@u54ee753d2d1854bda401.ant.amazon.com>
References: <1480857578-5065-1-git-send-email-netanel@annapurnalabs.com>
 <1480857578-5065-8-git-send-email-netanel@annapurnalabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-kernel@vger.kernel.org>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>, <dwmw@amazon.com>,
        <zorik@annapurnalabs.com>, <alex@annapurnalabs.com>,
        <saeed@annapurnalabs.com>, <msw@amazon.com>, <aliguori@amazon.com>,
        <nafea@annapurnalabs.com>
To: Netanel Belgazal <netanel@annapurnalabs.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1480857578-5065-8-git-send-email-netanel@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 04, 2016 at 03:19:25PM +0200, Netanel Belgazal wrote:
> ndo_get_stat64 can be called from atomic context.
> However the current implementation sends an admin command to retrieve
> the statistics from the device.
> This admin commands uses sleep.

Suggest some comment edits:

ndo_get_stat64() can be called from atomic context, but the current
implementation sends an admin command to retrieve the statistics from
the device. This admin command can sleep.

> Refactor the implementation of ena_get_stats64 to take the
> {rx,tx}bytes/cnt from the driver's inner counters
> and to take the rx drops counter
> from the asynchronous keep alive (heart bit) event.

This patch re-factors the implementation of ena_get_stats64() to use
the {rx,tx}bytes/count from the driver's inner counters, and to obtain
the rx drop counter from the asynchronous keep alive (heart bit)
event.

--msw

> Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
> ---
>  drivers/net/ethernet/amazon/ena/ena_admin_defs.h |  8 ++++
>  drivers/net/ethernet/amazon/ena/ena_netdev.c     | 57 +++++++++++++++++-------
>  drivers/net/ethernet/amazon/ena/ena_netdev.h     |  1 +
>  3 files changed, 51 insertions(+), 15 deletions(-)
> 
> diff --git a/drivers/net/ethernet/amazon/ena/ena_admin_defs.h b/drivers/net/ethernet/amazon/ena/ena_admin_defs.h
> index f48c886..6d70bf5 100644
> --- a/drivers/net/ethernet/amazon/ena/ena_admin_defs.h
> +++ b/drivers/net/ethernet/amazon/ena/ena_admin_defs.h
> @@ -873,6 +873,14 @@ struct ena_admin_aenq_link_change_desc {
>  	u32 flags;
>  };
>  
> +struct ena_admin_aenq_keep_alive_desc {
> +	struct ena_admin_aenq_common_desc aenq_common_desc;
> +
> +	u32 rx_drops_low;
> +
> +	u32 rx_drops_high;
> +};
> +
>  struct ena_admin_ena_mmio_req_read_less_resp {
>  	u16 req_id;
>  
> diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
> index ad5f78f..962ffb5 100644
> --- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
> +++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
> @@ -2176,28 +2176,46 @@ static struct rtnl_link_stats64 *ena_get_stats64(struct net_device *netdev,
>  						 struct rtnl_link_stats64 *stats)
>  {
>  	struct ena_adapter *adapter = netdev_priv(netdev);
> -	struct ena_admin_basic_stats ena_stats;
> -	int rc;
> +	struct ena_ring *rx_ring, *tx_ring;
> +	unsigned int start;
> +	u64 rx_drops;
> +	int i;
>  
>  	if (!test_bit(ENA_FLAG_DEV_UP, &adapter->flags))
>  		return NULL;
>  
> -	rc = ena_com_get_dev_basic_stats(adapter->ena_dev, &ena_stats);
> -	if (rc)
> -		return NULL;
> +	for (i = 0; i < adapter->num_queues; i++) {
> +		u64 bytes, packets;
> +
> +		tx_ring = &adapter->tx_ring[i];
> +
> +		do {
> +			start = u64_stats_fetch_begin_irq(&tx_ring->syncp);
> +			packets = tx_ring->tx_stats.cnt;
> +			bytes = tx_ring->tx_stats.bytes;
> +		} while (u64_stats_fetch_retry_irq(&tx_ring->syncp, start));
> +
> +		stats->tx_packets += packets;
> +		stats->tx_bytes += bytes;
>  
> -	stats->tx_bytes = ((u64)ena_stats.tx_bytes_high << 32) |
> -		ena_stats.tx_bytes_low;
> -	stats->rx_bytes = ((u64)ena_stats.rx_bytes_high << 32) |
> -		ena_stats.rx_bytes_low;
> +		rx_ring = &adapter->rx_ring[i];
> +
> +		do {
> +			start = u64_stats_fetch_begin_irq(&rx_ring->syncp);
> +			packets = rx_ring->rx_stats.cnt;
> +			bytes = rx_ring->rx_stats.bytes;
> +		} while (u64_stats_fetch_retry_irq(&rx_ring->syncp, start));
>  
> -	stats->rx_packets = ((u64)ena_stats.rx_pkts_high << 32) |
> -		ena_stats.rx_pkts_low;
> -	stats->tx_packets = ((u64)ena_stats.tx_pkts_high << 32) |
> -		ena_stats.tx_pkts_low;
> +		stats->rx_packets += packets;
> +		stats->rx_bytes += bytes;
> +	}
> +
> +	do {
> +		start = u64_stats_fetch_begin_irq(&adapter->syncp);
> +		rx_drops = adapter->dev_stats.rx_drops;
> +	} while (u64_stats_fetch_retry_irq(&adapter->syncp, start));
>  
> -	stats->rx_dropped = ((u64)ena_stats.rx_drops_high << 32) |
> -		ena_stats.rx_drops_low;
> +	stats->rx_dropped = rx_drops;
>  
>  	stats->multicast = 0;
>  	stats->collisions = 0;
> @@ -3221,8 +3239,17 @@ static void ena_keep_alive_wd(void *adapter_data,
>  			      struct ena_admin_aenq_entry *aenq_e)
>  {
>  	struct ena_adapter *adapter = (struct ena_adapter *)adapter_data;
> +	struct ena_admin_aenq_keep_alive_desc *desc;
> +	u64 rx_drops;
>  
> +	desc = (struct ena_admin_aenq_keep_alive_desc *)aenq_e;
>  	adapter->last_keep_alive_jiffies = jiffies;
> +
> +	rx_drops = ((u64)desc->rx_drops_high << 32) | desc->rx_drops_low;
> +
> +	u64_stats_update_begin(&adapter->syncp);
> +	adapter->dev_stats.rx_drops = rx_drops;
> +	u64_stats_update_end(&adapter->syncp);
>  }
>  
>  static void ena_notification(void *adapter_data,
> diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.h b/drivers/net/ethernet/amazon/ena/ena_netdev.h
> index 69d7e9e..f0ddc11 100644
> --- a/drivers/net/ethernet/amazon/ena/ena_netdev.h
> +++ b/drivers/net/ethernet/amazon/ena/ena_netdev.h
> @@ -241,6 +241,7 @@ struct ena_stats_dev {
>  	u64 interface_up;
>  	u64 interface_down;
>  	u64 admin_q_pause;
> +	u64 rx_drops;
>  };
>  
>  enum ena_flags_t {
