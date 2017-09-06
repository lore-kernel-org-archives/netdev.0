From: "Neftin, Sasha" <sasha.neftin@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH net-next v3] e1000e: Be drop monitor
 friendly
Date: Wed, 6 Sep 2017 10:06:39 +0300
Message-ID: <bdd7d5a3-2004-ad2e-3c09-8198d76acafa@intel.com>
References: <20170826011424.27251-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: edumazet@gmail.com, open list <linux-kernel@vger.kernel.org>,
        "moderated list:INTEL ETHERNET DRIVERS"
        <intel-wired-lan@lists.osuosl.org>, davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:15531 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750832AbdIFHGn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 03:06:43 -0400
In-Reply-To: <20170826011424.27251-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/26/2017 04:14, Florian Fainelli wrote:
> e1000e_put_txbuf() can be called from normal reclamation path as well as
> when a DMA mapping failure, so we need to differentiate these two cases
> when freeing SKBs to be drop monitor friendly. e1000e_tx_hwtstamp_work()
> and e1000_remove() are processing TX timestamped SKBs and those should
> not be accounted as drops either.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> Changes in v3:
>
> - differentiate normal reclamation from TX DMA fragment mapping errors
> - removed a few invalid dev_kfree_skb() replacements (those are already
>    drop monitor friendly)
>
> Changes in v2:
>
> - make it compile
>
>   drivers/net/ethernet/intel/e1000e/netdev.c | 18 +++++++++++-------
>   1 file changed, 11 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
> index 327dfe5bedc0..cfd21858c095 100644
> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> @@ -1071,7 +1071,8 @@ static bool e1000_clean_rx_irq(struct e1000_ring *rx_ring, int *work_done,
>   }
>   
>   static void e1000_put_txbuf(struct e1000_ring *tx_ring,
> -			    struct e1000_buffer *buffer_info)
> +			    struct e1000_buffer *buffer_info,
> +			    bool drop)
>   {
>   	struct e1000_adapter *adapter = tx_ring->adapter;
>   
> @@ -1085,7 +1086,10 @@ static void e1000_put_txbuf(struct e1000_ring *tx_ring,
>   		buffer_info->dma = 0;
>   	}
>   	if (buffer_info->skb) {
> -		dev_kfree_skb_any(buffer_info->skb);
> +		if (drop)
> +			dev_kfree_skb_any(buffer_info->skb);
> +		else
> +			dev_consume_skb_any(buffer_info->skb);
>   		buffer_info->skb = NULL;
>   	}
>   	buffer_info->time_stamp = 0;
> @@ -1199,7 +1203,7 @@ static void e1000e_tx_hwtstamp_work(struct work_struct *work)
>   		wmb(); /* force write prior to skb_tstamp_tx */
>   
>   		skb_tstamp_tx(skb, &shhwtstamps);
> -		dev_kfree_skb_any(skb);
> +		dev_consume_skb_any(skb);
>   	} else if (time_after(jiffies, adapter->tx_hwtstamp_start
>   			      + adapter->tx_timeout_factor * HZ)) {
>   		dev_kfree_skb_any(adapter->tx_hwtstamp_skb);
> @@ -1254,7 +1258,7 @@ static bool e1000_clean_tx_irq(struct e1000_ring *tx_ring)
>   				}
>   			}
>   
> -			e1000_put_txbuf(tx_ring, buffer_info);
> +			e1000_put_txbuf(tx_ring, buffer_info, false);
>   			tx_desc->upper.data = 0;
>   
>   			i++;
> @@ -2421,7 +2425,7 @@ static void e1000_clean_tx_ring(struct e1000_ring *tx_ring)
>   
>   	for (i = 0; i < tx_ring->count; i++) {
>   		buffer_info = &tx_ring->buffer_info[i];
> -		e1000_put_txbuf(tx_ring, buffer_info);
> +		e1000_put_txbuf(tx_ring, buffer_info, false);
>   	}
>   
>   	netdev_reset_queue(adapter->netdev);
> @@ -5614,7 +5618,7 @@ static int e1000_tx_map(struct e1000_ring *tx_ring, struct sk_buff *skb,
>   			i += tx_ring->count;
>   		i--;
>   		buffer_info = &tx_ring->buffer_info[i];
> -		e1000_put_txbuf(tx_ring, buffer_info);
> +		e1000_put_txbuf(tx_ring, buffer_info, true);
>   	}
>   
>   	return 0;
> @@ -7411,7 +7415,7 @@ static void e1000_remove(struct pci_dev *pdev)
>   	if (adapter->flags & FLAG_HAS_HW_TIMESTAMP) {
>   		cancel_work_sync(&adapter->tx_hwtstamp_work);
>   		if (adapter->tx_hwtstamp_skb) {
> -			dev_kfree_skb_any(adapter->tx_hwtstamp_skb);
> +			dev_consume_skb_any(adapter->tx_hwtstamp_skb);
>   			adapter->tx_hwtstamp_skb = NULL;
>   		}
>   	}

i am ok with this patch
