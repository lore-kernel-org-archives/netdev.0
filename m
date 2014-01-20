From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v5 8/9] xen-netback: Timeout packets in RX path
Date: Mon, 20 Jan 2014 22:03:48 +0000
Message-ID: <20140120220348.GA5058@zion.uk.xensource.com>
References: <1390253069-25507-1-git-send-email-zoltan.kiss@citrix.com>
 <1390253069-25507-9-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1390253069-25507-9-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 20, 2014 at 09:24:28PM +0000, Zoltan Kiss wrote:
> A malicious or buggy guest can leave its queue filled indefinitely, in which
> case qdisc start to queue packets for that VIF. If those packets came from an
> another guest, it can block its slots and prevent shutdown. To avoid that, we
> make sure the queue is drained in every 10 seconds.
> The QDisc queue in worst case takes 3 round to flush usually.
> 
> v3:
> - remove stale debug log
> - tie unmap timeout in xenvif_free to this timeout
> 
> v4:
> - due to RX flow control changes now start_xmit doesn't drop the packets but
>   place them on the internal queue. So the timer set rx_queue_purge and kick in
>   the thread to drop the packets there
> - we shoot down the timer if a previously filled internal queue drains
> - adjust the teardown timeout as in worst case it can take more time now
> 
> v5:
> - create separate variable worst_case_skb_lifetime and add an explanation about
>   why is it so long
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> ---
>  drivers/net/xen-netback/common.h    |    6 ++++++
>  drivers/net/xen-netback/interface.c |   37 +++++++++++++++++++++++++++++++++--
>  drivers/net/xen-netback/netback.c   |   23 +++++++++++++++++++---
>  3 files changed, 61 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
> index 109c29f..d1cd8ce 100644
> --- a/drivers/net/xen-netback/common.h
> +++ b/drivers/net/xen-netback/common.h
> @@ -129,6 +129,9 @@ struct xenvif {
>  	struct xen_netif_rx_back_ring rx;
>  	struct sk_buff_head rx_queue;
>  	RING_IDX rx_last_skb_slots;
> +	bool rx_queue_purge;
> +
> +	struct timer_list wake_queue;
>  
>  	/* This array is allocated seperately as it is large */
>  	struct gnttab_copy *grant_copy_op;
> @@ -225,4 +228,7 @@ void xenvif_idx_unmap(struct xenvif *vif, u16 pending_idx);
>  
>  extern bool separate_tx_rx_irq;
>  
> +extern unsigned int rx_drain_timeout_msecs;
> +extern unsigned int rx_drain_timeout_jiffies;
> +
>  #endif /* __XEN_NETBACK__COMMON_H__ */
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index af6b3e1..40aa500 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -114,6 +114,18 @@ static irqreturn_t xenvif_interrupt(int irq, void *dev_id)
>  	return IRQ_HANDLED;
>  }
>  
> +static void xenvif_wake_queue(unsigned long data)
> +{
> +	struct xenvif *vif = (struct xenvif *)data;
> +
> +	if (netif_queue_stopped(vif->dev)) {
> +		netdev_err(vif->dev, "draining TX queue\n");
> +		vif->rx_queue_purge = true;
> +		xenvif_kick_thread(vif);
> +		netif_wake_queue(vif->dev);
> +	}
> +}
> +
>  static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  {
>  	struct xenvif *vif = netdev_priv(dev);
> @@ -143,8 +155,13 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	 * then turn off the queue to give the ring a chance to
>  	 * drain.
>  	 */
> -	if (!xenvif_rx_ring_slots_available(vif, min_slots_needed))
> +	if (!xenvif_rx_ring_slots_available(vif, min_slots_needed)) {
> +		vif->wake_queue.function = xenvif_wake_queue;
> +		vif->wake_queue.data = (unsigned long)vif;
>  		xenvif_stop_queue(vif);
> +		mod_timer(&vif->wake_queue,
> +			jiffies + rx_drain_timeout_jiffies);
> +	}
>  
>  	skb_queue_tail(&vif->rx_queue, skb);
>  	xenvif_kick_thread(vif);
> @@ -352,6 +369,8 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
>  	init_timer(&vif->credit_timeout);
>  	vif->credit_window_start = get_jiffies_64();
>  
> +	init_timer(&vif->wake_queue);
> +
>  	dev->netdev_ops	= &xenvif_netdev_ops;
>  	dev->hw_features = NETIF_F_SG |
>  		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
> @@ -532,6 +551,7 @@ void xenvif_disconnect(struct xenvif *vif)
>  		xenvif_carrier_off(vif);
>  
>  	if (vif->task) {
> +		del_timer_sync(&vif->wake_queue);
>  		kthread_stop(vif->task);
>  		vif->task = NULL;
>  	}
> @@ -557,12 +577,25 @@ void xenvif_disconnect(struct xenvif *vif)
>  void xenvif_free(struct xenvif *vif)
>  {
>  	int i, unmap_timeout = 0;
> +	/* Here we want to avoid timeout messages if an skb can be legitimatly
> +	 * stucked somewhere else. Realisticly this could be an another vif's
> +	 * internal or QDisc queue. That another vif also has this
> +	 * rx_drain_timeout_msecs timeout, but the timer only ditches the
> +	 * internal queue. After that, the QDisc queue can put in worst case
> +	 * XEN_NETIF_RX_RING_SIZE / MAX_SKB_FRAGS skbs into that another vif's
> +	 * internal queue, so we need several rounds of such timeouts until we
> +	 * can be sure that no another vif should have skb's from us. We are
> +	 * not sending more skb's, so newly stucked packets are not interesting
> +	 * for us here.
> +	 */

You beat me to this. Was about to reply to your other email. :-)

It's also worth mentioning that DIV_ROUND_UP part is merely estimation,
as you cannot possible know the maximum / miminum queue length of all
other vifs (as they can be changed during runtime). In practice most
users will stick with the default, but some advanced users might want to
tune this value for individual vif (whether that's a good idea or not is
another topic).

So, in order to convince myself this is safe. I also did some analysis
on the impact of having queue length other than default value.  If
queue_len < XENVIF_QUEUE_LENGTH, that means you can queue less packets
in qdisc than default and drain it faster than calculated, which is
safe. On the other hand if queue_len > XENVIF_QUEUE_LENGTH, it means
actually you need more time than calculated. I'm in two minded here. The
default value seems sensible to me but I'm still a bit worried about the
queue_len > XENVIF_QUEUE_LENGTH case.

An idea is to book-keep maximum tx queue len among all vifs and use that
to calculate worst scenario.

Wei.
