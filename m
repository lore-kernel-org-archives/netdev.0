From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [ofa-general] Re: [PATCH 10/10 REV5] [E1000] Implement batching
Date: Fri, 14 Sep 2007 16:47:14 +0400
Message-ID: <20070914124714.GD18517@2ka.mipt.ru>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	<20070914090442.17589.23005.sendpatchset@K50wks273871wss.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se,
	peter.p.waskiewicz.jr@intel.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com, rdreier@cisco.com,
	hadi@cyberus.ca, netdev@vger.kernel.org, kaber@trash.net,
	randy.dunlap@oracle.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	mcarlson@broadcom.com, sri@us.ibm.com,
	shemminger@linux-foundation.org, davem@davemloft.net
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
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

On Fri, Sep 14, 2007 at 02:34:42PM +0530, Krishna Kumar (krkumar2@in.ibm.com) wrote:
> @@ -3276,7 +3282,7 @@ e1000_xmit_frame(struct sk_buff *skb, st
>  
>  	if (unlikely(skb->len <= 0)) {
>  		dev_kfree_skb_any(skb);
> -		return NETDEV_TX_OK;
> +		return NETDEV_TX_DROPPED;
>  	}

This changes could actually go as own patch, although not sure it is
ever used. just a though, not a stopper.

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

Why is it put at the end?


-- 
	Evgeniy Polyakov
