From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next v9 0/3] add hisilicon hip04 ethernet driver
Date: Tue, 16 Dec 2014 15:57:21 +0800
Message-ID: <548FE5E1.1090300@huawei.com>
References: <1418298150-4944-1-git-send-email-dingtianhong@huawei.com> <2708715.thQWqYuW6a@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <zhangfei.gao@linaro.org>, <davem@davemloft.net>,
	<linux@arm.linux.org.uk>, <f.fainelli@gmail.com>,
	<sergei.shtylyov@cogentembedded.com>, <mark.rutland@arm.com>,
	<David.Laight@aculab.com>, <eric.dumazet@gmail.com>,
	<xuwei5@hisilicon.com>, <netdev@vger.kernel.org>,
	<devicetree@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>,
	<linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:65182 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899AbaLPH6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 02:58:07 -0500
In-Reply-To: <2708715.thQWqYuW6a@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/12/15 21:29, Arnd Bergmann wrote:
> On Thursday 11 December 2014 19:42:27 Ding Tianhong wrote:
>> v9:
>> - There is no tx completion interrupts to free DMAd Tx packets, it means taht
>>   we rely on new tx packets arriving to run the destructors of completed packets,
>>   which open up space in their sockets's send queues. Sometimes we don't get such
>>   new packets causing Tx to stall, a single UDP transmitter is a good example of
>>   this situation, so we need a clean up workqueue to reclaims completed packets,
>>   the workqueue will only free the last packets which is already stay for several jiffies.
>>   Also fix some format cleanups.
> 
> You must have missed the reply in which David Miller explained why
> you can't call skb_orphan and rely on an occasional cleanup of the
> queue. Please use something like the patch below:
> 
> - drop the broken skb_orphan call
> - drop the workqueue
> - batch cleanup based on tx_coalesce_frames/usecs for better throughput
> - use a reasonable default tx timeout (200us, could be shorted
>   based on measurements) with a range timer
> - fix napi poll function return value
> - use a lockless queue for cleanup
> 

Ok, agree, my comments see below.

> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> 
> Feel free to fold this into your patch rather than keeping it separate.
> Completely untested, probably contains some bugs. Please ask if you
> have questions about this.
> 
> diff --git a/drivers/net/ethernet/hisilicon/hip04_eth.c b/drivers/net/ethernet/hisilicon/hip04_eth.c
> index 9d37b670db6a..d85c5287654e 100644
> --- a/drivers/net/ethernet/hisilicon/hip04_eth.c
> +++ b/drivers/net/ethernet/hisilicon/hip04_eth.c
> @@ -12,6 +12,7 @@
>  #include <linux/etherdevice.h>
>  #include <linux/platform_device.h>
>  #include <linux/interrupt.h>
> +#include <linux/ktime.h>
>  #include <linux/of_address.h>
>  #include <linux/phy.h>
>  #include <linux/of_mdio.h>
> @@ -157,9 +158,11 @@ struct hip04_priv {
>  	struct sk_buff *tx_skb[TX_DESC_NUM];
>  	dma_addr_t tx_phys[TX_DESC_NUM];
>  	unsigned int tx_head;
> -	unsigned int tx_tail;
> -	int tx_count;
> -	unsigned long last_tx;
> +
> +	/* FIXME: make these adjustable through ethtool */
> +	int tx_coalesce_frames;
> +	int tx_coalesce_usecs;
> +	struct hrtimer tx_coalesce_timer;
>  
>  	unsigned char *rx_buf[RX_DESC_NUM];
>  	dma_addr_t rx_phys[RX_DESC_NUM];
> @@ -171,10 +174,15 @@ struct hip04_priv {
>  	struct regmap *map;
>  	struct work_struct tx_timeout_task;
>  
> -	struct workqueue_struct *wq;
> -	struct delayed_work tx_clean_task;
> +	/* written only by tx cleanup */
> +	unsigned int tx_tail ____cacheline_aligned_in_smp;
>  };
>  
> +static inline unsigned int tx_count(unsigned int head, unsigned int tail)
> +{
> +	return (head - tail) % (TX_DESC_NUM - 1);
> +}
> +
>  static void hip04_config_port(struct net_device *ndev, u32 speed, u32 duplex)
>  {
>  	struct hip04_priv *priv = netdev_priv(ndev);
> @@ -351,18 +359,21 @@ static int hip04_set_mac_address(struct net_device *ndev, void *addr)
>  	return 0;
>  }
>  
> -static void hip04_tx_reclaim(struct net_device *ndev, bool force)
> +static int hip04_tx_reclaim(struct net_device *ndev, bool force)
>  {
>  	struct hip04_priv *priv = netdev_priv(ndev);
>  	unsigned tx_tail = priv->tx_tail;
>  	struct tx_desc *desc;
>  	unsigned int bytes_compl = 0, pkts_compl = 0;
> +	unsigned int count;
>  
> -	if (priv->tx_count == 0)
> +	smp_rmb();
> +	count = tx_count(ACCESS_ONCE(priv->tx_head), tx_tail);
> +	if (count == 0)
>  		goto out;
>  
> -	while ((tx_tail != priv->tx_head) || (priv->tx_count == TX_DESC_NUM)) {
> -		desc = &priv->tx_desc[priv->tx_tail];
> +	while (count) {
> +		desc = &priv->tx_desc[tx_tail];
>  		if (desc->send_addr != 0) {
>  			if (force)
>  				desc->send_addr = 0;
> @@ -381,57 +392,37 @@ static void hip04_tx_reclaim(struct net_device *ndev, bool force)
>  		dev_kfree_skb(priv->tx_skb[tx_tail]);
>  		priv->tx_skb[tx_tail] = NULL;
>  		tx_tail = TX_NEXT(tx_tail);
> -		priv->tx_count--;
> -
> -		if (priv->tx_count <= 0)
> -			break;
> +		count--;
>  	}
>  
>  	priv->tx_tail = tx_tail;
> +	smp_wmb(); /* Ensure tx_tail visible to xmit */
>  
> -	/* Ensure tx_tail & tx_count visible to xmit */
> -	smp_mb();
>  out:
> -
>  	if (pkts_compl || bytes_compl)
>  		netdev_completed_queue(ndev, pkts_compl, bytes_compl);
>  
> -	if (unlikely(netif_queue_stopped(ndev)) &&
> -	    (priv->tx_count < TX_DESC_NUM))
> +	if (unlikely(netif_queue_stopped(ndev)) && (count < (TX_DESC_NUM - 1)))
>  		netif_wake_queue(ndev);
> -}
>  
> -static void hip04_tx_clean_monitor(struct work_struct *work)
> -{
> -	struct hip04_priv *priv = container_of(work, struct hip04_priv,
> -					       tx_clean_task.work);
> -	struct net_device *ndev = priv->ndev;
> -	int delta_in_ticks = msecs_to_jiffies(1000);
> -
> -	if (!time_in_range(jiffies, priv->last_tx,
> -			   priv->last_tx + delta_in_ticks)) {
> -		netif_tx_lock(ndev);
> -		hip04_tx_reclaim(ndev, false);
> -		netif_tx_unlock(ndev);
> -	}
> -	queue_delayed_work(priv->wq, &priv->tx_clean_task, delta_in_ticks);
> +	return count;

I think should return pkts_compl, because may break from the loop, the pkts_compl may smaller than count.
and we need to add netif_tx_lock() to protect this function to avoid concurrency conflict.

>  }
>  
>  static int hip04_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>  {
>  	struct hip04_priv *priv = netdev_priv(ndev);
>  	struct net_device_stats *stats = &ndev->stats;
> -	unsigned int tx_head = priv->tx_head;
> +	unsigned int tx_head = priv->tx_head, count;
>  	struct tx_desc *desc = &priv->tx_desc[tx_head];
>  	dma_addr_t phys;
>  
> -	if (priv->tx_count >= TX_DESC_NUM) {
> +	smp_rmb();
> +	count = tx_count(tx_head, ACCESS_ONCE(priv->tx_tail));
> +	if (count == (TX_DESC_NUM - 1)) {
>  		netif_stop_queue(ndev);
>  		return NETDEV_TX_BUSY;
>  	}
>  
> -	hip04_tx_reclaim(ndev, false);
> -
>  	phys = dma_map_single(&ndev->dev, skb->data, skb->len, DMA_TO_DEVICE);
>  	if (dma_mapping_error(&ndev->dev, phys)) {
>  		dev_kfree_skb(skb);
> @@ -447,20 +438,33 @@ static int hip04_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>  	desc->wb_addr = cpu_to_be32(phys);
>  	skb_tx_timestamp(skb);
>  
> -	/* Don't wait up for transmitted skbs to be freed. */
> -	skb_orphan(skb);
> -
> +	/* FIXME: eliminate this mmio access if xmit_more is set */
>  	hip04_set_xmit_desc(priv, phys);
>  	priv->tx_head = TX_NEXT(tx_head);
> +	count++;
>  	netdev_sent_queue(ndev, skb->len);
>  
>  	stats->tx_bytes += skb->len;
>  	stats->tx_packets++;
> -	priv->tx_count++;
> -	priv->last_tx = jiffies;
>  
> -	/* Ensure tx_head & tx_count update visible to tx reclaim */
> -	smp_mb();
> +	/* Ensure tx_head update visible to tx reclaim */
> +	smp_wmb();
> +
> +	/* queue is getting full, better start cleaning up now */
> +	if (count >= priv->tx_coalesce_frames) {
> +		if (napi_schedule_prep(&priv->napi)) {
> +			/* disable rx interrupt and timer */
> +			priv->reg_inten &= ~(RCV_INT);
> +			writel_relaxed(DEF_INT_MASK & ~RCV_INT,
> +				       priv->base + PPE_INTEN);
> +			hrtimer_cancel(&priv->tx_coalesce_timer);
> +			__napi_schedule(&priv->napi);
> +		}
> +	} else if (!hrtimer_is_queued(&priv->tx_coalesce_timer)) {
> +		/* cleanup not pending yet, start a new timer */
> +		hrtimer_start_expires(&priv->tx_coalesce_timer,
> +				      HRTIMER_MODE_REL);
> +	}
>  
>  	return NETDEV_TX_OK;
>  }
> @@ -477,6 +481,7 @@ static int hip04_rx_poll(struct napi_struct *napi, int budget)
>  	bool last = false;
>  	dma_addr_t phys;
>  	int rx = 0;
> +	int tx_remaining;
>  	u16 len;
>  	u32 err;
>  
> @@ -513,11 +518,11 @@ static int hip04_rx_poll(struct napi_struct *napi, int budget)
>  
>  		buf = netdev_alloc_frag(priv->rx_buf_size);
>  		if (!buf)
> -			return -ENOMEM;
> +			goto done;
>  		phys = dma_map_single(&ndev->dev, buf,
>  				      RX_BUF_SIZE, DMA_FROM_DEVICE);
>  		if (dma_mapping_error(&ndev->dev, phys))
> -			return -EIO;
> +			goto done;
>  		priv->rx_buf[priv->rx_head] = buf;
>  		priv->rx_phys[priv->rx_head] = phys;
>  		hip04_set_recv_desc(priv, phys);
> @@ -537,6 +542,11 @@ static int hip04_rx_poll(struct napi_struct *napi, int budget)
>  	}
>  	napi_complete(napi);
>  done:
> +	/* clean up tx descriptors and start a new timer if necessary */
> +	tx_remaining = hip04_tx_reclaim(ndev, false);
> +	if (rx < budget && tx_remaining)
> +		hrtimer_start_expires(&priv->tx_coalesce_timer, HRTIMER_MODE_REL);
> +
>  	return rx;
>  }
>  
> @@ -547,6 +557,9 @@ static irqreturn_t hip04_mac_interrupt(int irq, void *dev_id)
>  	struct net_device_stats *stats = &ndev->stats;
>  	u32 ists = readl_relaxed(priv->base + PPE_INTSTS);
>  
> +	if (!ists)
> +		return IRQ_NONE;
> +
>  	writel_relaxed(DEF_INT_MASK, priv->base + PPE_RINT);
>  
>  	if (unlikely(ists & DEF_INT_ERR)) {
> @@ -560,16 +573,32 @@ static irqreturn_t hip04_mac_interrupt(int irq, void *dev_id)
>  		}
>  	}
>  
> -	if (ists & RCV_INT) {
> +	if (ists & RCV_INT && napi_schedule_prep(&priv->napi)) {
>  		/* disable rx interrupt */
>  		priv->reg_inten &= ~(RCV_INT);
> -		writel_relaxed(priv->reg_inten, priv->base + PPE_INTEN);
> -		napi_schedule(&priv->napi);
> +		writel_relaxed(DEF_INT_MASK & ~RCV_INT, priv->base + PPE_INTEN);
> +		hrtimer_cancel(&priv->tx_coalesce_timer);
> +		__napi_schedule(&priv->napi);
>  	}
>  
>  	return IRQ_HANDLED;
>  }
>  
> +enum hrtimer_restart tx_done(struct hrtimer *hrtimer)
> +{
> +	struct hip04_priv *priv;
> +	priv = container_of(hrtimer, struct hip04_priv, tx_coalesce_timer);
> +
> +	if (napi_schedule_prep(&priv->napi)) {
> +		/* disable rx interrupt */
> +		priv->reg_inten &= ~(RCV_INT);
> +		writel_relaxed(DEF_INT_MASK & ~RCV_INT, priv->base + PPE_INTEN);
> +		__napi_schedule(&priv->napi);
> +	}
> +
> +	return HRTIMER_NORESTART;
> +}
> +
>  static void hip04_adjust_link(struct net_device *ndev)
>  {
>  	struct hip04_priv *priv = netdev_priv(ndev);
> @@ -589,7 +618,6 @@ static int hip04_mac_open(struct net_device *ndev)
>  	priv->rx_head = 0;
>  	priv->tx_head = 0;
>  	priv->tx_tail = 0;
> -	priv->tx_count = 0;
>  	hip04_reset_ppe(priv);
>  
>  	for (i = 0; i < RX_DESC_NUM; i++) {
> @@ -612,9 +640,6 @@ static int hip04_mac_open(struct net_device *ndev)
>  	hip04_mac_enable(ndev);
>  	napi_enable(&priv->napi);
>  
> -	INIT_DELAYED_WORK(&priv->tx_clean_task, hip04_tx_clean_monitor);
> -	queue_delayed_work(priv->wq, &priv->tx_clean_task, 0);
> -
>  	return 0;
>  }
>  
> @@ -623,8 +648,6 @@ static int hip04_mac_stop(struct net_device *ndev)
>  	struct hip04_priv *priv = netdev_priv(ndev);
>  	int i;
>  
> -	cancel_delayed_work_sync(&priv->tx_clean_task);
> -
I think we should cancle the hrtimer when closed and queue the timer when open.

>  	napi_disable(&priv->napi);
>  	netif_stop_queue(ndev);
>  	hip04_mac_disable(ndev);
> @@ -725,6 +748,7 @@ static int hip04_mac_probe(struct platform_device *pdev)
>  	struct hip04_priv *priv;
>  	struct resource *res;
>  	unsigned int irq;
> +	ktime_t txtime;
>  	int ret;
>  
>  	ndev = alloc_etherdev(sizeof(struct hip04_priv));
> @@ -751,6 +775,21 @@ static int hip04_mac_probe(struct platform_device *pdev)
>  	priv->port = arg.args[0];
>  	priv->chan = arg.args[1] * RX_DESC_NUM;
>  
> +	hrtimer_init(&priv->tx_coalesce_timer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
> +
> +	/*
> +	 * BQL will try to keep the TX queue as short as possible, but it can't
> +	 * be faster than tx_coalesce_usecs, so we need a fast timeout here,
> +	 * but also long enough to gather up enough frames to ensure we don't
> +	 * get more interrupts than necessary.
> +	 * 200us is enough for 16 frames of 1500 bytes at gigabit ethernet rate
> +	 */
> +	priv->tx_coalesce_frames = TX_DESC_NUM * 3 / 4;
> +	priv->tx_coalesce_usecs = 200;
> +	/* allow timer to fire after half the time at the earliest */
> +	txtime = ktime_set(0, priv->tx_coalesce_usecs * NSEC_PER_USEC / 2);
> +	hrtimer_set_expires_range(&priv->tx_coalesce_timer, txtime, txtime);
> +

I think miss the line:
 priv->tx_coalesce_timer.function = tx_done;


Regards
Ding
>  	priv->map = syscon_node_to_regmap(arg.np);
>  	if (IS_ERR(priv->map)) {
>  		dev_warn(d, "no syscon hisilicon,hip04-ppe\n");
> @@ -788,12 +827,6 @@ static int hip04_mac_probe(struct platform_device *pdev)
>  		}
>  	}
>  
> -	priv->wq = create_singlethread_workqueue(ndev->name);
> -	if (!priv->wq) {
> -		ret = -ENOMEM;
> -		goto init_fail;
> -	}
> -
>  	INIT_WORK(&priv->tx_timeout_task, hip04_tx_timeout_task);
>  
>  	ether_setup(ndev);
> @@ -848,8 +881,6 @@ static int hip04_remove(struct platform_device *pdev)
>  	free_irq(ndev->irq, ndev);
>  	of_node_put(priv->phy_node);
>  	cancel_work_sync(&priv->tx_timeout_task);
> -	if (priv->wq)
> -		destroy_workqueue(priv->wq);
>  	free_netdev(ndev);
>  
>  	return 0;
> 
> 
> .
> 
