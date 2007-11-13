From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [ofa-general] Re: [PATCH 10/10 REV5] [E1000] Implement batching
Date: Tue, 13 Nov 2007 13:28:14 -0800
Message-ID: <473A16EE.6080101@intel.com>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	<20070914090442.17589.23005.sendpatchset@K50wks273871wss.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, Robert.Olsson@data.slu.se, gaagaan@gmail.com,
	kumarkr@linux.ibm.com, peter.p.waskiewicz.jr@intel.com,
	shemminger@linux-foundation.org, johnpol@2ka.mipt.ru,
	herbert@gondor.apana.org.au, jeff@garzik.org, rdreier@cisco.com,
	mcarlson@broadcom.com, general@lists.openfabrics.org,
	sri@us.ibm.com, jagana@us.ibm.com, hadi@cyberus.ca,
	mchan@broadcom.com, netdev@vger.kernel.org, davem@davemloft.net,
	tgraf@suug.ch, kaber@trash.net
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070914090442.17589.23005.sendpatchset@K50wks273871wss.in.ibm.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Krishna Kumar wrote:
> E1000: Implement batching capability (ported thanks to changes taken from
> 	Jamal).
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>


this doesn't apply anymore and it would help if you could re-spin this for e1000e.
I don't know what the status for merging of the batched xmit patches is right now
but it would help if you could rewrite them against e1000e, which I assume is what
most people want to test with. There are also significant changes upstream right
now in jgarzik/netdev-2.6 #upstream...

I'm still very interested in these patches BTW.

Auke



> ---
>  e1000_main.c |  104 ++++++++++++++++++++++++++++++++++++++++++-----------------
>  1 files changed, 75 insertions(+), 29 deletions(-)
> 
> diff -ruNp org/drivers/net/e1000/e1000_main.c new/drivers/net/e1000/e1000_main.c
> --- org/drivers/net/e1000/e1000_main.c	2007-09-14 10:30:57.000000000 +0530
> +++ new/drivers/net/e1000/e1000_main.c	2007-09-14 10:31:02.000000000 +0530
> @@ -990,7 +990,7 @@ e1000_probe(struct pci_dev *pdev,
>  	if (pci_using_dac)
>  		netdev->features |= NETIF_F_HIGHDMA;
>  
> -	netdev->features |= NETIF_F_LLTX;
> +	netdev->features |= NETIF_F_LLTX | NETIF_F_BATCH_SKBS;
>  
>  	adapter->en_mng_pt = e1000_enable_mng_pass_thru(&adapter->hw);
>  
> @@ -3092,6 +3092,17 @@ e1000_tx_map(struct e1000_adapter *adapt
>  	return count;
>  }
>  
> +static void e1000_kick_DMA(struct e1000_adapter *adapter,
> +			   struct e1000_tx_ring *tx_ring, int i)
> +{
> +	wmb();
> +
> +	writel(i, adapter->hw.hw_addr + tx_ring->tdt);
> +	/* we need this if more than one processor can write to our tail
> +	 * at a time, it syncronizes IO on IA64/Altix systems */
> +	mmiowb();
> +}
> +
>  static void
>  e1000_tx_queue(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
>                 int tx_flags, int count)
> @@ -3138,13 +3149,7 @@ e1000_tx_queue(struct e1000_adapter *ada
>  	 * know there are new descriptors to fetch.  (Only
>  	 * applicable for weak-ordered memory model archs,
>  	 * such as IA-64). */
> -	wmb();
> -
>  	tx_ring->next_to_use = i;
> -	writel(i, adapter->hw.hw_addr + tx_ring->tdt);
> -	/* we need this if more than one processor can write to our tail
> -	 * at a time, it syncronizes IO on IA64/Altix systems */
> -	mmiowb();
>  }
>  
>  /**
> @@ -3251,22 +3256,23 @@ static int e1000_maybe_stop_tx(struct ne
>  }
>  
>  #define TXD_USE_COUNT(S, X) (((S) >> (X)) + 1 )
> +
> +#define NETDEV_TX_DROPPED	-5
> +
>  static int
> -e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
> +e1000_prep_queue_frame(struct sk_buff *skb, struct net_device *netdev)
>  {
>  	struct e1000_adapter *adapter = netdev_priv(netdev);
>  	struct e1000_tx_ring *tx_ring;
>  	unsigned int first, max_per_txd = E1000_MAX_DATA_PER_TXD;
>  	unsigned int max_txd_pwr = E1000_MAX_TXD_PWR;
>  	unsigned int tx_flags = 0;
> -	unsigned int len = skb->len;
> -	unsigned long flags;
> -	unsigned int nr_frags = 0;
> -	unsigned int mss = 0;
> +	unsigned int len = skb->len - skb->data_len;
> +	unsigned int nr_frags;
> +	unsigned int mss;
>  	int count = 0;
>  	int tso;
>  	unsigned int f;
> -	len -= skb->data_len;
>  
>  	/* This goes back to the question of how to logically map a tx queue
>  	 * to a flow.  Right now, performance is impacted slightly negatively
> @@ -3276,7 +3282,7 @@ e1000_xmit_frame(struct sk_buff *skb, st
>  
>  	if (unlikely(skb->len <= 0)) {
>  		dev_kfree_skb_any(skb);
> -		return NETDEV_TX_OK;
> +		return NETDEV_TX_DROPPED;
>  	}
>  
>  	/* 82571 and newer doesn't need the workaround that limited descriptor
> @@ -3322,7 +3328,7 @@ e1000_xmit_frame(struct sk_buff *skb, st
>  					DPRINTK(DRV, ERR,
>  						"__pskb_pull_tail failed.\n");
>  					dev_kfree_skb_any(skb);
> -					return NETDEV_TX_OK;
> +					return NETDEV_TX_DROPPED;
>  				}
>  				len = skb->len - skb->data_len;
>  				break;
> @@ -3366,22 +3372,15 @@ e1000_xmit_frame(struct sk_buff *skb, st
>  	    (adapter->hw.mac_type == e1000_82573))
>  		e1000_transfer_dhcp_info(adapter, skb);
>  
> -	if (!spin_trylock_irqsave(&tx_ring->tx_lock, flags))
> -		/* Collision - tell upper layer to requeue */
> -		return NETDEV_TX_LOCKED;
> -
>  	/* need: count + 2 desc gap to keep tail from touching
>  	 * head, otherwise try next time */
> -	if (unlikely(e1000_maybe_stop_tx(netdev, tx_ring, count + 2))) {
> -		spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
> +	if (unlikely(e1000_maybe_stop_tx(netdev, tx_ring, count + 2)))
>  		return NETDEV_TX_BUSY;
> -	}
>  
>  	if (unlikely(adapter->hw.mac_type == e1000_82547)) {
>  		if (unlikely(e1000_82547_fifo_workaround(adapter, skb))) {
>  			netif_stop_queue(netdev);
>  			mod_timer(&adapter->tx_fifo_stall_timer, jiffies + 1);
> -			spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
>  			return NETDEV_TX_BUSY;
>  		}
>  	}
> @@ -3396,8 +3395,7 @@ e1000_xmit_frame(struct sk_buff *skb, st
>  	tso = e1000_tso(adapter, tx_ring, skb);
>  	if (tso < 0) {
>  		dev_kfree_skb_any(skb);
> -		spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
> -		return NETDEV_TX_OK;
> +		return NETDEV_TX_DROPPED;
>  	}
>  
>  	if (likely(tso)) {
> @@ -3416,13 +3414,61 @@ e1000_xmit_frame(struct sk_buff *skb, st
>  	               e1000_tx_map(adapter, tx_ring, skb, first,
>  	                            max_per_txd, nr_frags, mss));
>  
> -	netdev->trans_start = jiffies;
> +	return NETDEV_TX_OK;
> +}
> +
> +static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
> +{
> +	struct e1000_adapter *adapter = netdev_priv(netdev);
> +	struct e1000_tx_ring *tx_ring = adapter->tx_ring;
> +	struct sk_buff_head *blist;
> +	int ret, skbs_done = 0;
> +	unsigned long flags;
> +
> +	if (!spin_trylock_irqsave(&tx_ring->tx_lock, flags)) {
> +		/* Collision - tell upper layer to requeue */
> +		return NETDEV_TX_LOCKED;
> +	}
>  
> -	/* Make sure there is space in the ring for the next send. */
> -	e1000_maybe_stop_tx(netdev, tx_ring, MAX_SKB_FRAGS + 2);
> +	blist = netdev->skb_blist;
> +
> +	if (!skb || (blist && skb_queue_len(blist))) {
> +		/*
> +		 * Either batching xmit call, or single skb case but there are
> +		 * skbs already in the batch list from previous failure to
> +		 * xmit - send the earlier skbs first to avoid out of order.
> +		 */
> +		if (skb)
> +			__skb_queue_tail(blist, skb);
> +		skb = __skb_dequeue(blist);
> +	} else {
> +		blist = NULL;
> +	}
> +
> +	do {
> +		ret = e1000_prep_queue_frame(skb, netdev);
> +		if (likely(ret == NETDEV_TX_OK))
> +			skbs_done++;
> +		else {
> +			if (ret == NETDEV_TX_BUSY) {
> +				if (blist)
> +					__skb_queue_head(blist, skb);
> +				break;
> +			}
> +			/* skb dropped, not a TX error */
> +			ret = NETDEV_TX_OK;
> +		}
> +	} while (blist && (skb = __skb_dequeue(blist)) != NULL);
> +
> +	if (skbs_done) {
> +		e1000_kick_DMA(adapter, tx_ring, adapter->tx_ring->next_to_use);
> +		netdev->trans_start = jiffies;
> +		/* Make sure there is space in the ring for the next send. */
> +		e1000_maybe_stop_tx(netdev, tx_ring, MAX_SKB_FRAGS + 2);
> +	}
>  
>  	spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
> -	return NETDEV_TX_OK;
> +	return ret;
>  }
>  
>  /**
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
