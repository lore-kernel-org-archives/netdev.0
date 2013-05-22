From: annie li <annie.li@oracle.com>
Subject: Re: [PATCH net-next V2 1/2] xen-netback: split event channels support
 for Xen backend driver
Date: Wed, 22 May 2013 11:40:41 -0400
Message-ID: <519CE6F9.8080307@oracle.com>
References: <1369161310-9529-1-git-send-email-wei.liu2@citrix.com> <1369161310-9529-2-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	ian.campbell@citrix.com, konrad.wilk@oracle.com,
	david.vrabel@citrix.com
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:49774 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755409Ab3EVPk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 11:40:28 -0400
In-Reply-To: <1369161310-9529-2-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013-5-21 14:35, Wei Liu wrote:
> [....]
> +
>   static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
>   {
>   	struct xenvif *vif = netdev_priv(dev);
> @@ -125,13 +143,15 @@ static struct net_device_stats *xenvif_get_stats(struct net_device *dev)
>   static void xenvif_up(struct xenvif *vif)
>   {
>   	xen_netbk_add_xenvif(vif);
> -	enable_irq(vif->irq);
> +	enable_irq(vif->tx_irq);
> +	enable_irq(vif->rx_irq);

enable_irq are called twice in one event channel situation. How about 
adding if condition here to differ one event channel and split event 
channel?

>   	xen_netbk_check_rx_xenvif(vif);
>   }
>   
>   static void xenvif_down(struct xenvif *vif)
>   {
> -	disable_irq(vif->irq);
> +	disable_irq(vif->tx_irq);
> +	disable_irq(vif->rx_irq);

Same as enable_irq.

>   	del_timer_sync(&vif->credit_timeout);
>   	xen_netbk_deschedule_xenvif(vif);
>   	xen_netbk_remove_xenvif(vif);
> @@ -308,12 +328,13 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
>   }
>   
>   int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
> -		   unsigned long rx_ring_ref, unsigned int evtchn)
> +		   unsigned long rx_ring_ref, unsigned int tx_evtchn,
> +		   unsigned int rx_evtchn)
>   {
>   	int err = -ENOMEM;
>   
>   	/* Already connected through? */
> -	if (vif->irq)
> +	if (vif->tx_irq)
>   		return 0;
>   
>   	__module_get(THIS_MODULE);
> @@ -322,13 +343,38 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
>   	if (err < 0)
>   		goto err;
>   
> -	err = bind_interdomain_evtchn_to_irqhandler(
> -		vif->domid, evtchn, xenvif_interrupt, 0,
> -		vif->dev->name, vif);
> -	if (err < 0)
> -		goto err_unmap;
> -	vif->irq = err;
> -	disable_irq(vif->irq);
> +	if (tx_evtchn == rx_evtchn) {
> +		/* feature-split-event-channels == 0 */
> +		err = bind_interdomain_evtchn_to_irqhandler(
> +			vif->domid, tx_evtchn, xenvif_interrupt, 0,
> +			vif->dev->name, vif);
> +		if (err < 0)
> +			goto err_unmap;
> +		vif->tx_irq = vif->rx_irq = err;
> +		disable_irq(vif->tx_irq);
> +		disable_irq(vif->rx_irq);

Same as above.

> +	} else {
> +		/* feature-split-event-channels == 1 */
> +		snprintf(vif->tx_irq_name, sizeof(vif->tx_irq_name),
> +			 "%s-tx", vif->dev->name);
> +		err = bind_interdomain_evtchn_to_irqhandler(
> +			vif->domid, tx_evtchn, xenvif_tx_interrupt, 0,
> +			vif->tx_irq_name, vif);
> +		if (err < 0)
> +			goto err_unmap;
> +		vif->tx_irq = err;
> +		disable_irq(vif->tx_irq);
> +
> +		snprintf(vif->rx_irq_name, sizeof(vif->rx_irq_name),
> +			 "%s-rx", vif->dev->name);
> +		err = bind_interdomain_evtchn_to_irqhandler(
> +			vif->domid, rx_evtchn, xenvif_rx_interrupt, 0,
> +			vif->rx_irq_name, vif);
> +		if (err < 0)
> +			goto err_tx_unbind;
> +		vif->rx_irq = err;
> +		disable_irq(vif->rx_irq);
> +	}
>   
>   	xenvif_get(vif);
>   
> @@ -342,6 +388,9 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
>   	rtnl_unlock();
>   
>   	return 0;
> +err_tx_unbind:
> +	unbind_from_irqhandler(vif->tx_irq, vif);
> +	vif->tx_irq = 0;
>   err_unmap:
>   	xen_netbk_unmap_frontend_rings(vif);
>   err:
> @@ -375,8 +424,13 @@ void xenvif_disconnect(struct xenvif *vif)
>   	atomic_dec(&vif->refcnt);
>   	wait_event(vif->waiting_to_free, atomic_read(&vif->refcnt) == 0);
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
>   		/* vif->irq is valid, we had a module_get in
>   		 * xenvif_connect.
>   		 */
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 2d9477f..ccfbb74 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -47,6 +47,13 @@
>   #include <asm/xen/hypercall.h>
>   #include <asm/xen/page.h>
>   
> +/* Provide an option to disable split event channels at load time as
> + * event channels are limited resource. Split event channels are
> + * enabled by default.
> + */
> +unsigned int feature_split_event_channels = 1;
> +module_param(feature_split_event_channels, uint, 0644);
> +
>   /*
>    * This is the maximum slots a skb can have. If a guest sends a skb
>    * which exceeds this limit it is considered malicious.
> @@ -662,7 +669,7 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
>   {
>   	struct xenvif *vif = NULL, *tmp;
>   	s8 status;
> -	u16 irq, flags;
> +	u16 flags;
>   	struct xen_netif_rx_response *resp;
>   	struct sk_buff_head rxq;
>   	struct sk_buff *skb;
> @@ -771,7 +778,6 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
>   					 sco->meta_slots_used);
>   
>   		RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&vif->rx, ret);
> -		irq = vif->irq;
>   		if (ret && list_empty(&vif->notify_list))
>   			list_add_tail(&vif->notify_list, &notify);
>   
> @@ -783,7 +789,7 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
>   	}
>   
>   	list_for_each_entry_safe(vif, tmp, &notify, notify_list) {
> -		notify_remote_via_irq(vif->irq);
> +		notify_remote_via_irq(vif->rx_irq);
>   		list_del_init(&vif->notify_list);
>   	}
>   
> @@ -1762,7 +1768,7 @@ static void make_tx_response(struct xenvif *vif,
>   	vif->tx.rsp_prod_pvt = ++i;
>   	RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&vif->tx, notify);
>   	if (notify)
> -		notify_remote_via_irq(vif->irq);
> +		notify_remote_via_irq(vif->tx_irq);
>   }
>   
>   static struct xen_netif_rx_response *make_rx_response(struct xenvif *vif,
> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
> index d230c14..461efc6 100644
> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
> @@ -114,6 +114,15 @@ static int netback_probe(struct xenbus_device *dev,
>   			goto abort_transaction;
>   		}
>   
> +		/* Split event channels support */
> +		err = xenbus_printf(xbt, dev->nodename,
> +				"feature-split-event-channels",
> +				"%u", feature_split_event_channels);
> +		if (err) {
> +			message = "writing feature-split-event-channels";
> +			goto abort_transaction;
> +		}
> +
>   		err = xenbus_transaction_end(xbt, 0);
>   	} while (err == -EAGAIN);
>   
> @@ -393,21 +402,36 @@ static int connect_rings(struct backend_info *be)
>   	struct xenvif *vif = be->vif;
>   	struct xenbus_device *dev = be->dev;
>   	unsigned long tx_ring_ref, rx_ring_ref;
> -	unsigned int evtchn, rx_copy;
> +	unsigned int tx_evtchn, rx_evtchn, rx_copy;
>   	int err;
>   	int val;
>   
>   	err = xenbus_gather(XBT_NIL, dev->otherend,
>   			    "tx-ring-ref", "%lu", &tx_ring_ref,
> -			    "rx-ring-ref", "%lu", &rx_ring_ref,
> -			    "event-channel", "%u", &evtchn, NULL);
> +			    "rx-ring-ref", "%lu", &rx_ring_ref, NULL);
>   	if (err) {
>   		xenbus_dev_fatal(dev, err,
> -				 "reading %s/ring-ref and event-channel",
> +				 "reading %s/ring-ref",
>   				 dev->otherend);
>   		return err;
>   	}
>   
> +	/* Try split event channels first, then single event channel. */
> +	err = xenbus_gather(XBT_NIL, dev->otherend,
> +			    "event-channel-tx", "%u", &tx_evtchn,
> +			    "event-channel-rx", "%u", &rx_evtchn, NULL);
> +	if (err) {
> +		err = xenbus_gather(XBT_NIL, dev->otherend,
> +				    "event-channel", "%u", &tx_evtchn, NULL);
> +		if (err) {
> +			xenbus_dev_fatal(dev, err,
> +					 "reading %s/event-channel(-tx/rx)",
> +					 dev->otherend);

This err really comes from reading original implementation(one event 
channel), right? So it is better to not use (-tx/rx) here?
Or using two xenbus_dev_fatal to print log: one for reading tx/rx 
failure, the other for one event channel failure.

Thanks
Annie
