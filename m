From: Prashant Sreedharan <prashant@broadcom.com>
Subject: Re: [PATCH net v3 4/4] tg3: Fix tx_pending checks for tg3_tso_bug
Date: Tue, 26 Aug 2014 20:40:30 -0700
Message-ID: <1409110830.28795.36.camel@prashant>
References: <1409081178-4877-1-git-send-email-bpoirier@suse.de>
	 <1409081178-4877-4-git-send-email-bpoirier@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Benjamin Poirier <bpoirier@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1409081178-4877-4-git-send-email-bpoirier@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>  static inline bool tg3_maybe_stop_txq(struct tg3_napi *tnapi,
>  				      struct netdev_queue *txq,
> @@ -7841,14 +7847,16 @@ static inline bool tg3_maybe_stop_txq(struct tg3_napi *tnapi,
>  		if (!netif_tx_queue_stopped(txq)) {
>  			stopped = true;
>  			netif_tx_stop_queue(txq);
> -			BUG_ON(wakeup_thresh >= tnapi->tx_pending);
> +			tnapi->wakeup_thresh = wakeup_thresh;
> +			BUG_ON(tnapi->wakeup_thresh >= tnapi->tx_pending);
>  		}
>  		/* netif_tx_stop_queue() must be done before checking tx index
>  		 * in tg3_tx_avail(), because in tg3_tx(), we update tx index
> -		 * before checking for netif_tx_queue_stopped().
> +		 * before checking for netif_tx_queue_stopped(). The memory
> +		 * barrier also synchronizes wakeup_thresh changes.
>  		 */
>  		smp_mb();
> -		if (tg3_tx_avail(tnapi) > wakeup_thresh)
> +		if (tg3_tx_avail(tnapi) > tnapi->wakeup_thresh)
>  			netif_tx_wake_queue(txq);

you can add a comment here... stopped is not set to false even if queue
wakes up, to log the netdev_err "BUG! TX Ring.." message.

>  	}
>  	return stopped;
> @@ -7861,10 +7869,10 @@ static int tg3_tso_bug(struct tg3 *tp, struct tg3_napi *tnapi,
>  		       struct netdev_queue *txq, struct sk_buff *skb)


> @@ -12318,9 +12354,7 @@ static int tg3_set_ringparam(struct net_device *dev, struct ethtool_ringparam *e
>  	if ((ering->rx_pending > tp->rx_std_ring_mask) ||
>  	    (ering->rx_jumbo_pending > tp->rx_jmb_ring_mask) ||
>  	    (ering->tx_pending > TG3_TX_RING_SIZE - 1) ||
> -	    (ering->tx_pending <= MAX_SKB_FRAGS + 1) ||
> -	    (tg3_flag(tp, TSO_BUG) &&
> -	     (ering->tx_pending <= (MAX_SKB_FRAGS * 3))))
> +	    (ering->tx_pending <= MAX_SKB_FRAGS + 1))
>  		return -EINVAL;
>  
>  	if (netif_running(dev)) {
> @@ -12340,6 +12374,7 @@ static int tg3_set_ringparam(struct net_device *dev, struct ethtool_ringparam *e
>  	if (tg3_flag(tp, JUMBO_RING_ENABLE))
>  		tp->rx_jumbo_pending = ering->rx_jumbo_pending;
>  
> +	dev->gso_max_segs = TG3_TX_SEG_PER_DESC(ering->tx_pending - 1);

Assuming a LSO skb of 64k size takes the tg3_tso_bug() code path, if the
available TX descriptors is <= 135 assuming gso_segs is 45 for this skb
based on the estimate 45 * 3 driver would stop this TX queue and set the
tnapi->wakeup_thresh to 135 and return NETDEV_TX_BUSY. This skb will be
queued to be resent when the queue wakes up. 

Meanwhile if the user changes the TX ring size tx_pending=135,
dev->gso_max_segs is modified accordingly to 44, the LSO skb which was
queued will now be GSO'ed (in net/dev.c) before calling
tg3_start_xmit(). To note tg3_tx() cannot wake the queue as it is
expecting to be woken up when available free TX descriptors is 136. So
we end up with HW TX ring empty and not able to send any pkts.





>  	for (i = 0; i < tp->irq_max; i++)
>  		tp->napi[i].tx_pending = ering->tx_pending;
>  
> @@ -17816,6 +17851,7 @@ static int tg3_init_one(struct pci_dev *pdev,
>  		else
