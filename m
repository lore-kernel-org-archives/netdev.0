From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 4/5] drivers: net: xgene: fix statistics counters
 race condition
Date: Fri, 13 May 2016 18:41:44 -0700
Message-ID: <1463190104.18194.3.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1463183581-30475-1-git-send-email-isubramanian@apm.com>
 <1463183581-30475-5-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: toanle@apm.com, netdev@vger.kernel.org, patches@apm.com,
 davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: Iyappan Subramanian <isubramanian@apm.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1463183581-30475-5-git-send-email-isubramanian@apm.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-05-13 at 16:53 -0700, Iyappan Subramanian wrote:
> This patch fixes the race condition on updating the statistics
> counters by moving the counters to the ring structure.
> 

...

> @@ -1127,12 +1127,31 @@ static struct rtnl_link_stats64 *xgene_enet_get_stats64(
>  {
>  	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
>  	struct rtnl_link_stats64 *stats = &pdata->stats;
> +	struct xgene_enet_desc_ring *ring;
> +	int i;
> +
> +	memset(stats, 0, sizeof(struct rtnl_link_stats64));

The memset() should already be done in the caller.

> +	for (i = 0; i < pdata->txq_cnt; i++) {
> +		ring = pdata->tx_ring[i];
> +		if (ring) {
> +			stats->tx_packets += ring->tx_packets;
> +			stats->tx_bytes += ring->tx_bytes;
> +		}
> +	}
>  
> -	stats->rx_errors += stats->rx_length_errors +
> -			    stats->rx_crc_errors +
> -			    stats->rx_frame_errors +
> -			    stats->rx_fifo_errors;


Right, this piece was completely buggy.

Not a race, but rx_errors was growing every time stats were fetched on
this device.


stats->rx_errors =   sum(...)    was probably the intent.



> -	memcpy(storage, &pdata->stats, sizeof(struct rtnl_link_stats64));
> +	for (i = 0; i < pdata->rxq_cnt; i++) {
> +		ring = pdata->rx_ring[i];
> +		if (ring) {
> +			stats->rx_packets += ring->rx_packets;
> +			stats->rx_bytes += ring->rx_bytes;
> +			stats->rx_errors += ring->rx_length_errors +
> +				ring->rx_crc_errors +
> +				ring->rx_frame_errors +
> +				ring->rx_fifo_errors;
> +			stats->rx_dropped += ring->rx_dropped;
> +		}
> +	}
> +	memcpy(storage, stats, sizeof(struct rtnl_link_stats64));
>  
>  	return storage;
>  }
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
> index cc40c30..092fbec 100644
> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
> @@ -121,6 +121,16 @@ struct xgene_enet_desc_ring {
>  		struct xgene_enet_raw_desc16 *raw_desc16;
>  	};
>  	__le64 *exp_bufs;
> +	u64 tx_packets;
> +	u64 tx_bytes;
> +	u64 rx_packets;
> +	u64 rx_bytes;
> +	u64 rx_dropped;
> +	u64 rx_errors;
> +	u64 rx_length_errors;
> +	u64 rx_crc_errors;
> +	u64 rx_frame_errors;
> +	u64 rx_fifo_errors;

Note that there is still a race on 32bit arches.

It seems this driver should really use "unsigned long" counters and
provide standard ndo_get_stats()
