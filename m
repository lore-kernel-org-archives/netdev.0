From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [RFC net-next 4/4] gianfar: Use separate NAPIs for Tx and Rx
 processing
Date: Mon, 13 Aug 2012 20:51:14 -0400
Message-ID: <20120814005114.GA29337@windriver.com>
References: <1344428810-29923-1-git-send-email-claudiu.manoil@freescale.com>
 <1344428810-29923-2-git-send-email-claudiu.manoil@freescale.com>
 <1344428810-29923-3-git-send-email-claudiu.manoil@freescale.com>
 <1344428810-29923-4-git-send-email-claudiu.manoil@freescale.com>
 <1344428810-29923-5-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Pankaj Chauhan <pankaj.chauhan@freescale.com>,
	Eric Dumazet <edumazet@google.com>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:59794 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753590Ab2HNAvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2012 20:51:22 -0400
Content-Disposition: inline
In-Reply-To: <1344428810-29923-5-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[[RFC net-next 4/4] gianfar: Use separate NAPIs for Tx and Rx processing] On 08/08/2012 (Wed 15:26) Claudiu Manoil wrote:

> Add a separate napi poll routine for Tx cleanup, to be triggerred by Tx
> confirmation interrupts only. Existing poll function is modified to handle
> only the Rx path processing. This allows parallel processing of Rx and Tx
> confirmation paths on a smp machine (2 cores).
> The split also results in simpler/cleaner napi poll function implementations,
> where each processing path has its own budget, thus improving the fairness b/w
> the processing paths at the same time.
> 
> Signed-off-by: Pankaj Chauhan <pankaj.chauhan@freescale.com>
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
> ---
>  drivers/net/ethernet/freescale/gianfar.c |  154 +++++++++++++++++++++++-------
>  drivers/net/ethernet/freescale/gianfar.h |   16 +++-
>  2 files changed, 130 insertions(+), 40 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
> index 919acb3..2774961 100644
> --- a/drivers/net/ethernet/freescale/gianfar.c
> +++ b/drivers/net/ethernet/freescale/gianfar.c
> @@ -128,12 +128,14 @@ static void free_skb_resources(struct gfar_private *priv);
>  static void gfar_set_multi(struct net_device *dev);
>  static void gfar_set_hash_for_addr(struct net_device *dev, u8 *addr);
>  static void gfar_configure_serdes(struct net_device *dev);
> -static int gfar_poll(struct napi_struct *napi, int budget);
> +static int gfar_poll_rx(struct napi_struct *napi, int budget);
> +static int gfar_poll_tx(struct napi_struct *napi, int budget);
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  static void gfar_netpoll(struct net_device *dev);
>  #endif
>  int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit);
> -static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue);
> +static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue,
> +			      int tx_work_limit);

I'm looking at this in a bit more detail now (was on vacation last wk).
With the above, you push a work limit down into the clean_tx_ring.
I'm wondering if the above is implicitly involved in the performance
difference you see, since...

>  static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
>  			      int amount_pull, struct napi_struct *napi);
>  void gfar_halt(struct net_device *dev);
> @@ -543,16 +545,20 @@ static void disable_napi(struct gfar_private *priv)
>  {
>  	int i;
>  
> -	for (i = 0; i < priv->num_grps; i++)
> -		napi_disable(&priv->gfargrp[i].napi);
> +	for (i = 0; i < priv->num_grps; i++) {
> +		napi_disable(&priv->gfargrp[i].napi_rx);
> +		napi_disable(&priv->gfargrp[i].napi_tx);
> +	}
>  }
>  
>  static void enable_napi(struct gfar_private *priv)
>  {
>  	int i;
>  
> -	for (i = 0; i < priv->num_grps; i++)
> -		napi_enable(&priv->gfargrp[i].napi);
> +	for (i = 0; i < priv->num_grps; i++) {
> +		napi_enable(&priv->gfargrp[i].napi_rx);
> +		napi_enable(&priv->gfargrp[i].napi_tx);
> +	}
>  }
>  
>  static int gfar_parse_group(struct device_node *np,
> @@ -1028,9 +1034,12 @@ static int gfar_probe(struct platform_device *ofdev)
>  	dev->ethtool_ops = &gfar_ethtool_ops;
>  
>  	/* Register for napi ...We are registering NAPI for each grp */
> -	for (i = 0; i < priv->num_grps; i++)
> -		netif_napi_add(dev, &priv->gfargrp[i].napi, gfar_poll,
> -			       GFAR_DEV_WEIGHT);
> +	for (i = 0; i < priv->num_grps; i++) {
> +		netif_napi_add(dev, &priv->gfargrp[i].napi_rx, gfar_poll_rx,
> +			       GFAR_DEV_RX_WEIGHT);
> +		netif_napi_add(dev, &priv->gfargrp[i].napi_tx, gfar_poll_tx,
> +			       GFAR_DEV_TX_WEIGHT);
> +	}
>  
>  	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_CSUM) {
>  		dev->hw_features = NETIF_F_IP_CSUM | NETIF_F_SG |
> @@ -2465,7 +2474,8 @@ static void gfar_align_skb(struct sk_buff *skb)
>  }
>  
>  /* Interrupt Handler for Transmit complete */
> -static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
> +static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue,
> +			      int tx_work_limit)
>  {
>  	struct net_device *dev = tx_queue->dev;
>  	struct netdev_queue *txq;
> @@ -2490,7 +2500,7 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
>  	bdp = tx_queue->dirty_tx;
>  	skb_dirtytx = tx_queue->skb_dirtytx;
>  
> -	while ((skb = tx_queue->tx_skbuff[skb_dirtytx])) {
> +	while ((skb = tx_queue->tx_skbuff[skb_dirtytx]) && tx_work_limit--) {

...code like this provides a new exit point that did not exist before,
for the case of a massive transmit blast.  Do you have any data on how
often the work limit is hit?  The old Don Becker ether drivers which
originally introduced the idea of work limits (on IRQs) used to printk a
message when they hit it, since ideally it shouldn't be happening all
the time.

In any case, it might be worth while to split this change out into a
separate commit; something like:

   gianfar: push transmit cleanup work limit down to clean_tx_ring

The advantage being (1) we can test this change in isolation, and
(2) it makes your remaining rx/tx separate thread patch smaller and
easier to review.

Thanks,
Paul.
--

>  		unsigned long flags;
>  
>  		frags = skb_shinfo(skb)->nr_frags;
> @@ -2580,29 +2590,50 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
>  	return howmany;
>  }
>  
> -static void gfar_schedule_cleanup(struct gfar_priv_grp *gfargrp)
> +static void gfar_schedule_rx_cleanup(struct gfar_priv_grp *gfargrp)
>  {
>  	unsigned long flags;
>  
> -	spin_lock_irqsave(&gfargrp->grplock, flags);
> -	if (napi_schedule_prep(&gfargrp->napi)) {
> -		gfar_write(&gfargrp->regs->imask, IMASK_RTX_DISABLED);
> -		__napi_schedule(&gfargrp->napi);
> +	if (napi_schedule_prep(&gfargrp->napi_rx)) {
> +		u32 imask;
> +		spin_lock_irqsave(&gfargrp->grplock, flags);
> +		imask = gfar_read(&gfargrp->regs->imask);
> +		imask &= ~(IMASK_RX_DEFAULT);
> +		gfar_write(&gfargrp->regs->imask, imask);
> +		__napi_schedule(&gfargrp->napi_rx);
> +		spin_unlock_irqrestore(&gfargrp->grplock, flags);
>  	}
>  
>  	/* Clear IEVENT, so interrupts aren't called again
>  	 * because of the packets that have already arrived.
>  	 */
> -	gfar_write(&gfargrp->regs->ievent, IEVENT_RTX_MASK);
> +	gfar_write(&gfargrp->regs->ievent, IEVENT_RX_MASK);
> +}
>  
> -	spin_unlock_irqrestore(&gfargrp->grplock, flags);
> +static void gfar_schedule_tx_cleanup(struct gfar_priv_grp *gfargrp)
> +{
> +	unsigned long flags;
> +
> +	if (napi_schedule_prep(&gfargrp->napi_tx)) {
> +		u32 imask;
> +		spin_lock_irqsave(&gfargrp->grplock, flags);
> +		imask = gfar_read(&gfargrp->regs->imask);
> +		imask &= ~(IMASK_TX_DEFAULT);
> +		gfar_write(&gfargrp->regs->imask, imask);
> +		__napi_schedule(&gfargrp->napi_tx);
> +		spin_unlock_irqrestore(&gfargrp->grplock, flags);
> +	}
>  
> +	/* Clear IEVENT, so interrupts aren't called again
> +	 * because of the packets that have already arrived.
> +	 */
> +	gfar_write(&gfargrp->regs->ievent, IEVENT_TX_MASK);
>  }
>  
>  /* Interrupt Handler for Transmit complete */
>  static irqreturn_t gfar_transmit(int irq, void *grp_id)
>  {
> -	gfar_schedule_cleanup((struct gfar_priv_grp *)grp_id);
> +	gfar_schedule_tx_cleanup((struct gfar_priv_grp *)grp_id);
>  	return IRQ_HANDLED;
>  }
>  
> @@ -2683,7 +2714,7 @@ static inline void count_errors(unsigned short status, struct net_device *dev)
>  
>  irqreturn_t gfar_receive(int irq, void *grp_id)
>  {
> -	gfar_schedule_cleanup((struct gfar_priv_grp *)grp_id);
> +	gfar_schedule_rx_cleanup((struct gfar_priv_grp *)grp_id);
>  	return IRQ_HANDLED;
>  }
>  
> @@ -2813,7 +2844,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
>  				rx_queue->stats.rx_bytes += pkt_len;
>  				skb_record_rx_queue(skb, rx_queue->qindex);
>  				gfar_process_frame(dev, skb, amount_pull,
> -						   &rx_queue->grp->napi);
> +						   &rx_queue->grp->napi_rx);
>  
>  			} else {
>  				netif_warn(priv, rx_err, dev, "Missing skb!\n");
> @@ -2842,21 +2873,19 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
>  	return howmany;
>  }
>  
> -static int gfar_poll(struct napi_struct *napi, int budget)
> +static int gfar_poll_rx(struct napi_struct *napi, int budget)
>  {
>  	struct gfar_priv_grp *gfargrp =
> -		container_of(napi, struct gfar_priv_grp, napi);
> +		container_of(napi, struct gfar_priv_grp, napi_rx);
>  	struct gfar_private *priv = gfargrp->priv;
>  	struct gfar __iomem *regs = gfargrp->regs;
> -	struct gfar_priv_tx_q *tx_queue = NULL;
>  	struct gfar_priv_rx_q *rx_queue = NULL;
> -	int rx_cleaned = 0, budget_per_queue = 0, rx_cleaned_per_queue = 0;
> -	int tx_cleaned = 0, i, left_over_budget = budget;
> +	int rx_cleaned = 0, budget_per_queue, rx_cleaned_per_queue;
> +	int i, left_over_budget = budget;
>  	unsigned long serviced_queues = 0;
>  	int num_queues = 0;
>  
>  	num_queues = gfargrp->num_rx_queues;
> -	budget_per_queue = budget/num_queues;
>  
>  	while (num_queues && left_over_budget) {
>  		budget_per_queue = left_over_budget/num_queues;
> @@ -2866,9 +2895,6 @@ static int gfar_poll(struct napi_struct *napi, int budget)
>  			if (test_bit(i, &serviced_queues))
>  				continue;
>  			rx_queue = priv->rx_queue[i];
> -			tx_queue = priv->tx_queue[rx_queue->qindex];
> -
> -			tx_cleaned += gfar_clean_tx_ring(tx_queue);
>  			rx_cleaned_per_queue =
>  				gfar_clean_rx_ring(rx_queue, budget_per_queue);
>  			rx_cleaned += rx_cleaned_per_queue;
> @@ -2882,27 +2908,83 @@ static int gfar_poll(struct napi_struct *napi, int budget)
>  		}
>  	}
>  
> -	if (tx_cleaned)
> -		return budget;
> -
>  	if (rx_cleaned < budget) {
> +		u32 imask;
>  		napi_complete(napi);
>  
>  		/* Clear the halt bit in RSTAT */
>  		gfar_write(&regs->rstat, gfargrp->rstat);
>  
> -		gfar_write(&regs->imask, IMASK_DEFAULT);
> +		spin_lock_irq(&gfargrp->grplock);
> +		imask = gfar_read(&regs->imask);
> +		imask |= IMASK_RX_DEFAULT;
> +		gfar_write(&regs->imask, imask);
> +		spin_unlock_irq(&gfargrp->grplock);
>  
>  		/* If we are coalescing interrupts, update the timer
>  		 * Otherwise, clear it
>  		 */
> -		gfar_configure_coalescing(priv, gfargrp->rx_bit_map,
> -					  gfargrp->tx_bit_map);
> +		gfar_configure_rx_coalescing(priv, gfargrp->rx_bit_map);
>  	}
>  
>  	return rx_cleaned;
>  }
>  
> +static int gfar_poll_tx(struct napi_struct *napi, int budget)
> +{
> +	struct gfar_priv_grp *gfargrp =
> +		container_of(napi, struct gfar_priv_grp, napi_tx);
> +	struct gfar_private *priv = gfargrp->priv;
> +	struct gfar __iomem *regs = gfargrp->regs;
> +	struct gfar_priv_tx_q *tx_queue = NULL;
> +	int tx_cleaned = 0, budget_per_queue, tx_cleaned_per_queue;
> +	int i, left_over_budget = budget;
> +	unsigned long serviced_queues = 0;
> +	int num_queues = 0;
> +
> +	num_queues = gfargrp->num_tx_queues;
> +
> +	while (num_queues && left_over_budget) {
> +		budget_per_queue = left_over_budget/num_queues;
> +		left_over_budget = 0;
> +
> +		for_each_set_bit(i, &gfargrp->tx_bit_map, priv->num_tx_queues) {
> +			if (test_bit(i, &serviced_queues))
> +				continue;
> +			tx_queue = priv->tx_queue[i];
> +			tx_cleaned_per_queue =
> +				gfar_clean_tx_ring(tx_queue, budget_per_queue);
> +			tx_cleaned += tx_cleaned_per_queue;
> +			if (tx_cleaned_per_queue < budget_per_queue) {
> +				left_over_budget = left_over_budget +
> +					(budget_per_queue -
> +					 tx_cleaned_per_queue);
> +				set_bit(i, &serviced_queues);
> +				num_queues--;
> +			}
> +		}
> +	}
> +
> +	if (tx_cleaned < budget) {
> +		u32 imask;
> +		napi_complete(napi);
> +
> +		gfar_write(&regs->imask, IMASK_DEFAULT);
> +		spin_lock_irq(&gfargrp->grplock);
> +		imask = gfar_read(&regs->imask);
> +		imask |= IMASK_TX_DEFAULT;
> +		gfar_write(&regs->imask, imask);
> +		spin_unlock_irq(&gfargrp->grplock);
> +
> +		/* If we are coalescing interrupts, update the timer
> +		 * Otherwise, clear it
> +		 */
> +		gfar_configure_tx_coalescing(priv, gfargrp->tx_bit_map);
> +	}
> +
> +	return tx_cleaned;
> +}
> +
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  /* Polling 'interrupt' - used by things like netconsole to send skbs
>   * without having to re-enable interrupts. It's not called while
> diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
> index 2136c7f..f5be234 100644
> --- a/drivers/net/ethernet/freescale/gianfar.h
> +++ b/drivers/net/ethernet/freescale/gianfar.h
> @@ -57,8 +57,10 @@ struct ethtool_rx_list {
>  	unsigned int count;
>  };
>  
> -/* The maximum number of packets to be handled in one call of gfar_poll */
> -#define GFAR_DEV_WEIGHT 64
> +/* The maximum number of packets to be handled in one call of gfar_poll_rx */
> +#define GFAR_DEV_RX_WEIGHT 64
> +/* The maximum number of packets to be handled in one call of gfar_poll_tx */
> +#define GFAR_DEV_TX_WEIGHT 64
>  
>  /* Length for FCB */
>  #define GMAC_FCB_LEN 8
> @@ -366,6 +368,10 @@ extern const char gfar_driver_version[];
>  		| IMASK_PERR)
>  #define IMASK_RTX_DISABLED ((~(IMASK_RXFEN0 | IMASK_TXFEN | IMASK_BSY)) \
>  			   & IMASK_DEFAULT)
> +#define IMASK_RX_DEFAULT  (IMASK_RXFEN0 | IMASK_BSY)
> +#define IMASK_TX_DEFAULT  (IMASK_TXFEN)
> +#define IMASK_RX_DISABLED ((~(IMASK_RX_DEFAULT)) & IMASK_DEFAULT)
> +#define IMASK_TX_DISABLED ((~(IMASK_TX_DEFAULT)) & IMASK_DEFAULT)
>  
>  /* Fifo management */
>  #define FIFO_TX_THR_MASK	0x01ff
> @@ -993,7 +999,8 @@ struct gfar_priv_rx_q {
>  
>  /**
>   *	struct gfar_priv_grp - per group structure
> - *	@napi: the napi poll function
> + *	@napi_rx: the RX napi poll function
> + *	@napi_tx: the TX confirmation napi poll function
>   *	@priv: back pointer to the priv structure
>   *	@regs: the ioremapped register space for this group
>   *	@grp_id: group id for this group
> @@ -1007,7 +1014,8 @@ struct gfar_priv_rx_q {
>  
>  struct gfar_priv_grp {
>  	spinlock_t grplock __attribute__ ((aligned (SMP_CACHE_BYTES)));
> -	struct	napi_struct napi;
> +	struct	napi_struct napi_rx;
> +	struct	napi_struct napi_tx;
>  	struct gfar_private *priv;
>  	struct gfar __iomem *regs;
>  	unsigned int grp_id;
> -- 
> 1.6.6
> 
> 
