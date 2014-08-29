From: Prashant Sreedharan <prashant@broadcom.com>
Subject: Re: [PATCH net v4 4/4] tg3: Fix tx_pending checks for tg3_tso_bug
Date: Thu, 28 Aug 2014 19:45:43 -0700
Message-ID: <1409280343.12635.16.camel@prashant>
References: <1409187858-7698-1-git-send-email-bpoirier@suse.de>
	 <1409187858-7698-4-git-send-email-bpoirier@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Benjamin Poirier <bpoirier@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1409187858-7698-4-git-send-email-bpoirier@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>  	if (netif_running(dev)) {
> @@ -12346,8 +12380,15 @@ static int tg3_set_ringparam(struct net_device *dev, struct ethtool_ringparam *e
>  	if (tg3_flag(tp, JUMBO_RING_ENABLE))
>  		tp->rx_jumbo_pending = ering->rx_jumbo_pending;
>  
> -	for (i = 0; i < tp->irq_max; i++)
> -		tp->napi[i].tx_pending = ering->tx_pending;
> +	dev->gso_max_segs = TG3_TX_SEG_PER_DESC(ering->tx_pending - 1);
> +	for (i = 0; i < tp->irq_max; i++) {
> +		struct tg3_napi *tnapi = &tp->napi[i];
> +
> +		tnapi->tx_pending = ering->tx_pending;
> +		if (netif_tx_queue_stopped(netdev_get_tx_queue(dev, i)) &&
> +		    tnapi->wakeup_thresh >= ering->tx_pending)
> +			tnapi->wakeup_thresh = MAX_SKB_FRAGS + 1;

To maintain consistency wakeup_thresh can be set to TG3_TX_WAKEUP_THRESH
similar to other parts of the code, except the special handling of
tg3_tso_bug() estimate.
 
> +	}
>  
>  	if (netif_running(dev)) {
>  		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
> @@ -17822,6 +17863,7 @@ static int tg3_init_one(struct pci_dev *pdev,
>  		else
>  			sndmbx += 0xc;
>  	}
