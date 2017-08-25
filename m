From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2] e1000e: Be drop monitor friendly
Date: Fri, 25 Aug 2017 09:47:50 -0700
Message-ID: <f5ceb680-39a2-60ae-b1b6-fe82f639cb2e@gmail.com>
References: <20170825035824.26935-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@gmail.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        "moderated list:INTEL ETHERNET DRIVERS"
        <intel-wired-lan@lists.osuosl.org>,
        open list <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170825035824.26935-1-f.fainelli@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/24/2017 08:58 PM, Florian Fainelli wrote:
> e1000_put_txbuf() cleans up the successfully transmitted TX packets,
> e1000e_tx_hwtstamp_work() also does the successfully completes the
> timestamped TX packets, e1000_clean_rx_ring() cleans up the RX ring and
> e1000_remove() cleans up the timestampted packets. None of these
> functions should be reporting dropped packets, so make them use
> dev_consume_skb_any() to be drop monitor friendly.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
> index 327dfe5bedc0..a90e459c5b8a 100644
> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> @@ -1085,7 +1085,7 @@ static void e1000_put_txbuf(struct e1000_ring *tx_ring,
>  		buffer_info->dma = 0;
>  	}
>  	if (buffer_info->skb) {
> -		dev_kfree_skb_any(buffer_info->skb);
> +		dev_consume_skb_any(buffer_info->skb);
>  		buffer_info->skb = NULL;
>  	}
>  	buffer_info->time_stamp = 0;
> @@ -1199,7 +1199,7 @@ static void e1000e_tx_hwtstamp_work(struct work_struct *work)
>  		wmb(); /* force write prior to skb_tstamp_tx */
>  
>  		skb_tstamp_tx(skb, &shhwtstamps);
> -		dev_kfree_skb_any(skb);
> +		dev_consume_skb_any(skb);
>  	} else if (time_after(jiffies, adapter->tx_hwtstamp_start
>  			      + adapter->tx_timeout_factor * HZ)) {
>  		dev_kfree_skb_any(adapter->tx_hwtstamp_skb);
> @@ -1716,7 +1716,7 @@ static void e1000_clean_rx_ring(struct e1000_ring *rx_ring)
>  		}
>  
>  		if (buffer_info->skb) {
> -			dev_kfree_skb(buffer_info->skb);
> +			dev_consume_skb_any(buffer_info->skb);

This one is not actually needed since dev_kfree_skb() is an alias for
consume_skb().

>  			buffer_info->skb = NULL;
>  		}
>  
> @@ -1734,7 +1734,7 @@ static void e1000_clean_rx_ring(struct e1000_ring *rx_ring)
>  
>  	/* there also may be some cached data from a chained receive */
>  	if (rx_ring->rx_skb_top) {
> -		dev_kfree_skb(rx_ring->rx_skb_top);
> +		dev_consume_skb_any(rx_ring->rx_skb_top);

Same here.

I will make a repost of this patch later, Jeff please drop it if you
have it queued already, thanks!
-- 
Florian
