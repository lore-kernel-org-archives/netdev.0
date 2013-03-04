From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 7/8] netback: split event channels support
Date: Mon, 4 Mar 2013 16:22:06 -0500
Message-ID: <20130304212206.GH16762@phenom.dumpdata.com>
References: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com>
 <1360944010-15336-8-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	ian.campbell@citrix.com, annie.li@oracle.com
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:19795 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758726Ab3CDVWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 16:22:44 -0500
Content-Disposition: inline
In-Reply-To: <1360944010-15336-8-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 15, 2013 at 04:00:08PM +0000, Wei Liu wrote:
> Netback and netfront only use one event channel to do tx / rx notification.
> This may cause unnecessary wake-up of process routines. This patch adds a new
> feature called feautre-split-event-channel to netback, enabling it to handle

'feature', not 'feautre'. In the code it looks to also be plural:

feature-split-event-channels

and there is also event-channel-tx and event-channel-rx attribute.


You need to also send an patch to Xen hypervisor tree for this new XenBus
attributes and provide the appropiate syntax.

> Tx and Rx event separately.
> 
> Netback will use tx_irq to notify guest for tx completion, rx_irq for rx
> notification.
> 
> If frontend doesn't support this feature, tx_irq = rx_irq.
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> ---
>  drivers/net/xen-netback/common.h    |   10 +++--
>  drivers/net/xen-netback/interface.c |   78 ++++++++++++++++++++++++++++-------
>  drivers/net/xen-netback/netback.c   |    7 ++--
>  drivers/net/xen-netback/xenbus.c    |   44 ++++++++++++++++----
>  4 files changed, 109 insertions(+), 30 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
> index f541ba9..cc2a9f0 100644
> --- a/drivers/net/xen-netback/common.h
> +++ b/drivers/net/xen-netback/common.h
> @@ -63,8 +63,11 @@ struct xenvif {
>  
>  	u8               fe_dev_addr[6];
>  
> -	/* Physical parameters of the comms window. */
> -	unsigned int     irq;
> +	/* Physical parameters of the comms window.
> +	 * When feature-split-event-channels = 0, tx_irq = rx_irq.
> +	 */
> +	unsigned int tx_irq;
> +	unsigned int rx_irq;
>  
>  	/* List of frontends to notify after a batch of frames sent. */
>  	struct list_head notify_list;
> @@ -122,10 +125,11 @@ struct xenvif *xenvif_alloc(struct device *parent,
>  			    domid_t domid,
>  			    unsigned int handle);
>  
> +/* When feature-split-event-channels == 0, tx_evtchn == rx_evtchn */
>  int xenvif_connect(struct xenvif *vif,
>  		   unsigned long *tx_ring_ref, unsigned int tx_ring_order,
>  		   unsigned long *rx_ring_ref, unsigned int rx_ring_order,
> -		   unsigned int evtchn);
> +		   unsigned int tx_evtchn, unsigned int rx_evtchn);
>  void xenvif_disconnect(struct xenvif *vif);
>  
>  void xenvif_get(struct xenvif *vif);
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index fa4d46d..c9ebe21 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -60,7 +60,8 @@ static int xenvif_rx_schedulable(struct xenvif *vif)
>  	return xenvif_schedulable(vif) && !xen_netbk_rx_ring_full(vif);
>  }
>  
> -static irqreturn_t xenvif_interrupt(int irq, void *dev_id)
> +/* Tx interrupt handler used when feature-split-event-channels == 1 */
> +static irqreturn_t xenvif_tx_interrupt(int tx_irq, void *dev_id)
>  {
>  	struct xenvif *vif = dev_id;
>  
> @@ -69,12 +70,31 @@ static irqreturn_t xenvif_interrupt(int irq, void *dev_id)
>  
>  	xen_netbk_schedule_xenvif(vif);
>  
> +	return IRQ_HANDLED;
> +}
> +
> +/* Rx interrupt handler used when feature-split-event-channels == 1 */
> +static irqreturn_t xenvif_rx_interrupt(int rx_irq, void *dev_id)
> +{
> +	struct xenvif *vif = dev_id;
> +
> +	if (vif->netbk == NULL)
> +		return IRQ_NONE;
> +
>  	if (xenvif_rx_schedulable(vif))
>  		netif_wake_queue(vif->dev);
>  
>  	return IRQ_HANDLED;
>  }
>  
> +/* Used when feature-split-event-channels == 0 */
> +static irqreturn_t xenvif_interrupt(int irq, void *dev_id)
> +{
> +	xenvif_tx_interrupt(irq, dev_id);
> +	xenvif_rx_interrupt(irq, dev_id);
> +	return IRQ_HANDLED;
> +}
> +
>  static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  {
>  	struct xenvif *vif = netdev_priv(dev);
> @@ -125,13 +145,15 @@ static struct net_device_stats *xenvif_get_stats(struct net_device *dev)
>  static void xenvif_up(struct xenvif *vif)
>  {
>  	xen_netbk_add_xenvif(vif);
> -	enable_irq(vif->irq);
> +	enable_irq(vif->tx_irq);
> +	enable_irq(vif->rx_irq);
>  	xen_netbk_check_rx_xenvif(vif);
>  }
>  
>  static void xenvif_down(struct xenvif *vif)
>  {
> -	disable_irq(vif->irq);
> +	disable_irq(vif->tx_irq);
> +	disable_irq(vif->rx_irq);
>  	del_timer_sync(&vif->credit_timeout);
>  	xen_netbk_deschedule_xenvif(vif);
>  	xen_netbk_remove_xenvif(vif);
> @@ -308,7 +330,7 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
>  int xenvif_connect(struct xenvif *vif,
>  		   unsigned long *tx_ring_ref, unsigned int tx_ring_ref_count,
>  		   unsigned long *rx_ring_ref, unsigned int rx_ring_ref_count,
> -		   unsigned int evtchn)
> +		   unsigned int tx_evtchn, unsigned int rx_evtchn)
>  {
>  	int err = -ENOMEM;
>  	void *addr;
> @@ -317,7 +339,7 @@ int xenvif_connect(struct xenvif *vif,
>  	int tmp[NETBK_MAX_RING_PAGES], i;
>  
>  	/* Already connected through? */
> -	if (vif->irq)
> +	if (vif->tx_irq)
>  		return 0;
>  
>  	__module_get(THIS_MODULE);
> @@ -347,13 +369,32 @@ int xenvif_connect(struct xenvif *vif,
>  	BACK_RING_INIT(&vif->rx, rxs, PAGE_SIZE * rx_ring_ref_count);
>  	vif->nr_rx_handles = rx_ring_ref_count;
>  
> -	err = bind_interdomain_evtchn_to_irqhandler(
> -		vif->domid, evtchn, xenvif_interrupt, 0,
> -		vif->dev->name, vif);
> -	if (err < 0)
> -		goto err_rx_unmap;
> -	vif->irq = err;
> -	disable_irq(vif->irq);
> +	if (tx_evtchn == rx_evtchn) { /* feature-split-event-channels == 0 */
> +		err = bind_interdomain_evtchn_to_irqhandler(
> +			vif->domid, tx_evtchn, xenvif_interrupt, 0,
> +			vif->dev->name, vif);
> +		if (err < 0)
> +			goto err_rx_unmap;
> +		vif->tx_irq = vif->rx_irq = err;
> +		disable_irq(vif->tx_irq);
> +		disable_irq(vif->rx_irq);
> +	} else { /* feature-split-event-channels == 1 */
> +		err = bind_interdomain_evtchn_to_irqhandler(
> +			vif->domid, tx_evtchn, xenvif_tx_interrupt, 0,
> +			vif->dev->name, vif);
> +		if (err < 0)
> +			goto err_rx_unmap;
> +		vif->tx_irq = err;
> +		disable_irq(vif->tx_irq);
> +
> +		err = bind_interdomain_evtchn_to_irqhandler(
> +			vif->domid, rx_evtchn, xenvif_rx_interrupt, 0,
> +			vif->dev->name, vif);
> +		if (err < 0)
> +			goto err_tx_unbind;
> +		vif->rx_irq = err;
> +		disable_irq(vif->rx_irq);
> +	}
>  
>  	xenvif_get(vif);
>  
> @@ -367,6 +408,10 @@ int xenvif_connect(struct xenvif *vif,
>  	rtnl_unlock();
>  
>  	return 0;
> +
> +err_tx_unbind:
> +	unbind_from_irqhandler(vif->tx_irq, vif);
> +	vif->tx_irq = 0;
>  err_rx_unmap:
>  	xen_netbk_unmap_frontend_rings(vif, (void *)vif->rx.sring);
>  	vif->nr_rx_handles = 0;
> @@ -406,8 +451,13 @@ void xenvif_disconnect(struct xenvif *vif)
>  	atomic_dec(&vif->refcnt);
>  	wait_event(vif->waiting_to_free, atomic_read(&vif->refcnt) == 0);
>  
> -	if (vif->irq) {
> -		unbind_from_irqhandler(vif->irq, vif);
> +	if (vif->tx_irq) {
> +		if (vif->tx_irq == vif->rx_irq)
> +			unbind_from_irqhandler(vif->tx_irq, vif);
> +		else {
> +			unbind_from_irqhandler(vif->tx_irq, vif);
> +			unbind_from_irqhandler(vif->rx_irq, vif);
> +		}
>  		need_module_put = 1;
>  	}
>  
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 644c760..5ac8c35 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -639,7 +639,7 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
>  {
>  	struct xenvif *vif = NULL, *tmp;
>  	s8 status;
> -	u16 irq, flags;
> +	u16 flags;
>  	struct xen_netif_rx_response *resp;
>  	struct sk_buff_head rxq;
>  	struct sk_buff *skb;
> @@ -750,7 +750,6 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
>  					 sco->meta_slots_used);
>  
>  		RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&vif->rx, ret);
> -		irq = vif->irq;
>  		if (ret && list_empty(&vif->notify_list))
>  			list_add_tail(&vif->notify_list, &notify);
>  
> @@ -762,7 +761,7 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
>  	}
>  
>  	list_for_each_entry_safe(vif, tmp, &notify, notify_list) {
> -		notify_remote_via_irq(vif->irq);
> +		notify_remote_via_irq(vif->rx_irq);
>  		list_del_init(&vif->notify_list);
>  	}
>  
> @@ -1595,7 +1594,7 @@ static void make_tx_response(struct xenvif *vif,
>  	vif->tx.rsp_prod_pvt = ++i;
>  	RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&vif->tx, notify);
>  	if (notify)
> -		notify_remote_via_irq(vif->irq);
> +		notify_remote_via_irq(vif->tx_irq);
>  }
>  
>  static struct xen_netif_rx_response *make_rx_response(struct xenvif *vif,
> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
> index 1791807..6822d89 100644
> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
> @@ -141,6 +141,15 @@ static int netback_probe(struct xenbus_device *dev,
>  			goto abort_transaction;
>  		}
>  
> +		/* Split event channels support */
> +		err = xenbus_printf(xbt, dev->nodename,
> +				    "feature-split-event-channels",
> +				    "%u", 1);
> +		if (err) {
> +			message = "writing feature-split-event-channels";
> +			goto abort_transaction;
> +		}

I wouldn't abort b/c of it. Just continue on without using this.

> +
>  		err = xenbus_transaction_end(xbt, 0);
>  	} while (err == -EAGAIN);
>  
> @@ -419,7 +428,7 @@ static int connect_rings(struct backend_info *be)
>  {
>  	struct xenvif *vif = be->vif;
>  	struct xenbus_device *dev = be->dev;
> -	unsigned int evtchn, rx_copy;
> +	unsigned int tx_evtchn, rx_evtchn, rx_copy;
>  	int err;
>  	int val;
>  	unsigned long tx_ring_ref[NETBK_MAX_RING_PAGES];
> @@ -428,12 +437,22 @@ static int connect_rings(struct backend_info *be)
>  	unsigned int  rx_ring_order;
>  
>  	err = xenbus_gather(XBT_NIL, dev->otherend,
> -			    "event-channel", "%u", &evtchn, NULL);
> +			    "event-channel", "%u", &tx_evtchn, NULL);
>  	if (err) {
> -		xenbus_dev_fatal(dev, err,
> -				 "reading %s/event-channel",
> -				 dev->otherend);
> -		return err;
> +		/* try split event channels */
> +		err = xenbus_gather(XBT_NIL, dev->otherend,
> +				    "event-channel-tx", "%u", &tx_evtchn,
> +				    "event-channel-rx", "%u", &rx_evtchn,
> +				    NULL);
> +		if (err) {
> +			xenbus_dev_fatal(dev, err,
> +					 "reading %s/event-channel(-tx/rx)",
> +					 dev->otherend);
> +			return err;
> +		}
> +	} else { /* frontend doesn't support split event channels */
> +		rx_evtchn = tx_evtchn;
> +		dev_info(&dev->dev, "single event channel\n");
>  	}
>  
>  	err = xenbus_scanf(XBT_NIL, dev->otherend, "tx-ring-order", "%u",
> @@ -568,12 +587,19 @@ static int connect_rings(struct backend_info *be)
>  	/* Map the shared frame, irq etc. */
>  	err = xenvif_connect(vif, tx_ring_ref, (1U << tx_ring_order),
>  			     rx_ring_ref, (1U << rx_ring_order),
> -			     evtchn);
> +			     tx_evtchn, rx_evtchn);
>  	if (err) {
>  		/* construct 1 2 3 / 4 5 6 */
>  		int i;
>  		char txs[3 * (1U << MODPARM_netback_max_tx_ring_page_order)];
>  		char rxs[3 * (1U << MODPARM_netback_max_rx_ring_page_order)];
> +		char evtchns[20];
> +
> +		if (tx_evtchn == rx_evtchn)
> +			snprintf(evtchns, sizeof(evtchns)-1, "%u", tx_evtchn);
> +		else
> +			snprintf(evtchns, sizeof(evtchns)-1, "%u/%u",
> +				 tx_evtchn, rx_evtchn);
>  
>  		txs[0] = rxs[0] = 0;
>  
> @@ -586,8 +612,8 @@ static int connect_rings(struct backend_info *be)
>  				 " %lu", rx_ring_ref[i]);
>  
>  		xenbus_dev_fatal(dev, err,
> -				 "mapping shared-frames%s /%s port %u",
> -				 txs, rxs, evtchn);
> +				 "mapping shared-frames%s /%s port %s",
> +				 txs, rxs, evtchns);
>  		return err;
>  	}
>  	return 0;
> -- 
> 1.7.10.4
> 
