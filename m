From: "Torgny Johansson" <torgny.johansson@ericsson.com>
Subject: RE: autosuspend for cdc-ether
Date: Fri, 28 Aug 2009 16:09:51 +0200
Message-ID: <E86B0C24322D8648AC7F41E7CDA658E903DDD31C@esealmw114.eemea.ericsson.se>
References: <200908281554.55780.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "Oliver Neukum" <oliver@neukum.org>,
	"David Brownell" <david-b@pacbell.net>, <netdev@vger.kernel.org>,
	<linux-usb@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:54445 "EHLO
	mailgw4.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750984AbZH1OJx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 10:09:53 -0400
Content-class: urn:content-classes:message
In-Reply-To: <200908281554.55780.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tested-by: Torgny Johansson <torgny.johansson@ericsson.com> 

> -----Original Message-----
> From: Oliver Neukum [mailto:oliver@neukum.org] 
> Sent: den 28 augusti 2009 15:55
> To: David Brownell; Torgny Johansson; netdev@vger.kernel.org; 
> linux-usb@vger.kernel.org
> Subject: autosuspend for cdc-ether
> 
> Hi,
> 
> this allows the use of remote wakeup to autosuspend online 
> devices. What do you think?
> 
> 	Regards
> 		Oliver
> 
> --
> 
> commit 7f2d9a0440f6453462bd7bf95f77eda17c16d865
> Author: Oliver Neukum <oliver@neukum.org>
> Date:   Fri Aug 28 15:49:15 2009 +0200
> 
>     usb: usbnet: runtime power management for active connections
>     
>     Devices that support remote wakeup can be autosuspended 
> even while the
>     interface is up. Transmissions are queued and processed 
> after the device
>     has been woken up.
> 
> diff --git a/drivers/net/usb/cdc_ether.c 
> b/drivers/net/usb/cdc_ether.c index 4a6aff5..8ee5bd7 100644
> --- a/drivers/net/usb/cdc_ether.c
> +++ b/drivers/net/usb/cdc_ether.c
> @@ -411,6 +411,12 @@ static int cdc_bind(struct usbnet *dev, 
> struct usb_interface *intf)
>  	return 0;
>  }
>  
> +static int cdc_manage_power(struct usbnet *dev, int on) {
> +	dev->intf->needs_remote_wakeup = on;
> +	return 0;
> +}
> +
>  static const struct driver_info	cdc_info = {
>  	.description =	"CDC Ethernet Device",
>  	.flags =	FLAG_ETHER,
> @@ -418,6 +424,7 @@ static const struct driver_info	cdc_info = {
>  	.bind =		cdc_bind,
>  	.unbind =	usbnet_cdc_unbind,
>  	.status =	cdc_status,
> +	.manage_power =	cdc_manage_power,
>  };
>  
>  
> /*------------------------------------------------------------
> -------------*/
> @@ -570,6 +577,7 @@ static struct usb_driver cdc_driver = {
>  	.disconnect =	usbnet_disconnect,
>  	.suspend =	usbnet_suspend,
>  	.resume =	usbnet_resume,
> +	.supports_autosuspend = 1,
>  };
>  
>  
> diff --git a/drivers/net/usb/usbnet.c 
> b/drivers/net/usb/usbnet.c index edfd9e1..c21b3d2 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -575,6 +575,7 @@ EXPORT_SYMBOL_GPL(usbnet_unlink_rx_urbs);
>  int usbnet_stop (struct net_device *net)  {
>  	struct usbnet		*dev = netdev_priv(net);
> +	struct driver_info	*info = dev->driver_info;
>  	int			temp;
>  	DECLARE_WAIT_QUEUE_HEAD_ONSTACK (unlink_wakeup);
>  	DECLARE_WAITQUEUE (wait, current);
> @@ -612,7 +613,10 @@ int usbnet_stop (struct net_device *net)
>  	dev->flags = 0;
>  	del_timer_sync (&dev->delay);
>  	tasklet_kill (&dev->bh);
> -	usb_autopm_put_interface(dev->intf);
> +	if (info->manage_power)
> +		info->manage_power(dev, 0);
> +	else
> +		usb_autopm_put_interface(dev->intf);
>  
>  	return 0;
>  }
> @@ -693,6 +697,13 @@ int usbnet_open (struct net_device *net)
>  
>  	// delay posting reads until we're fully open
>  	tasklet_schedule (&dev->bh);
> +
> +	if (info->manage_power) {
> +		retval = info->manage_power(dev, 1);
> +		if (retval < 0)
> +			goto done;
> +		usb_autopm_put_interface(dev->intf);
> +	}
>  	return retval;
>  done:
>  	usb_autopm_put_interface(dev->intf);
> @@ -822,6 +833,7 @@ kevent (struct work_struct *work)
>  	if (test_bit (EVENT_TX_HALT, &dev->flags)) {
>  		unlink_urbs (dev, &dev->txq);
>  		status = usb_clear_halt (dev->udev, dev->out);
> +		usb_autopm_put_interface(dev->intf);
>  		if (status < 0
>  				&& status != -EPIPE
>  				&& status != -ESHUTDOWN) {
> @@ -893,17 +905,20 @@ static void tx_complete (struct urb *urb)
>  	if (urb->status == 0) {
>  		dev->net->stats.tx_packets++;
>  		dev->net->stats.tx_bytes += entry->length;
> +		usb_autopm_put_interface_async(dev->intf);
>  	} else {
>  		dev->net->stats.tx_errors++;
>  
>  		switch (urb->status) {
>  		case -EPIPE:
> +			/* we do not allow autosuspension */
>  			usbnet_defer_kevent (dev, EVENT_TX_HALT);
>  			break;
>  
>  		/* software-driven interface shutdown */
>  		case -ECONNRESET:		// async unlink
>  		case -ESHUTDOWN:		// hardware gone
> +			usb_autopm_put_interface_async(dev->intf);
>  			break;
>  
>  		// like rx, tx gets controller i/o faults 
> during khubd delays @@ -911,6 +926,7 @@ static void 
> tx_complete (struct urb *urb)
>  		case -EPROTO:
>  		case -ETIME:
>  		case -EILSEQ:
> +			usb_mark_last_busy(dev->udev);
>  			if (!timer_pending (&dev->delay)) {
>  				mod_timer (&dev->delay,
>  					jiffies + THROTTLE_JIFFIES);
> @@ -919,8 +935,10 @@ static void tx_complete (struct urb *urb)
>  							urb->status);
>  			}
>  			netif_stop_queue (dev->net);
> +			usb_autopm_put_interface_async(dev->intf);
>  			break;
>  		default:
> +			usb_autopm_put_interface_async(dev->intf);
>  			if (netif_msg_tx_err (dev))
>  				devdbg (dev, "tx err %d", 
> entry->urb->status);
>  			break;
> @@ -996,8 +1014,29 @@ int usbnet_start_xmit (struct sk_buff 
> *skb, struct net_device *net)
>  		}
>  	}
>  
> +	
> +
>  	spin_lock_irqsave (&dev->txq.lock, flags);
>  
> +	retval = usb_autopm_get_interface_async(dev->intf);
> +	if (retval < 0) {
> +		spin_unlock_irqrestore (&dev->txq.lock, flags);
> +		goto drop;
> +	}
> +
> +#ifdef CONFIG_PM
> +	/* if this triggers the device is still a sleep */
> +	if (test_bit(EVENT_DEV_ASLEEP, &dev->flags)) {
> +		/* transmission will be done in resume */
> +		dev->deferred = urb;
> +		/* no use to process more packets */
> +		netif_stop_queue(net);
> +		spin_unlock_irqrestore(&dev->txq.lock, flags);
> +		retval = NET_XMIT_SUCCESS;
> +		goto deferred;
> +	}
> +#endif
> +
>  	switch ((retval = usb_submit_urb (urb, GFP_ATOMIC))) {
>  	case -EPIPE:
>  		netif_stop_queue (net);
> @@ -1028,6 +1067,7 @@ drop:
>  		devdbg (dev, "> tx, len %d, type 0x%x",
>  			length, skb->protocol);
>  	}
> +deferred:
>  	return retval;
>  }
>  EXPORT_SYMBOL_GPL(usbnet_start_xmit);
> @@ -1303,6 +1343,15 @@ int usbnet_suspend (struct 
> usb_interface *intf, pm_message_t message)
>  	struct usbnet		*dev = usb_get_intfdata(intf);
>  
>  	if (!dev->suspend_count++) {
> +		spin_lock_irq(&dev->txq.lock);
> +		/* don't autosuspend while transmitting */
> +		if (dev->txq.qlen && (message.event & PM_EVENT_AUTO)) {
> +			spin_unlock_irq(&dev->txq.lock);
> +			return -EBUSY;
> +		} else {
> +			set_bit(EVENT_DEV_ASLEEP, &dev->flags);
> +			spin_unlock_irq(&dev->txq.lock);
> +		}
>  		/*
>  		 * accelerate emptying of the rx and queues, to avoid
>  		 * having everything error out.
> @@ -1322,11 +1371,34 @@ EXPORT_SYMBOL_GPL(usbnet_suspend);
>  
>  int usbnet_resume (struct usb_interface *intf)  {
> -	struct usbnet		*dev = usb_get_intfdata(intf);
> -
> -	if (!--dev->suspend_count)
> +	struct usbnet           *dev = usb_get_intfdata(intf);
> +	struct sk_buff          *skb;
> +	struct urb              *res;
> +	int                     retval;
> +	
> +	if (!--dev->suspend_count) {
> +		spin_lock_irq(&dev->txq.lock);
> +		res = dev->deferred;
> +		dev->deferred = NULL;
> +		clear_bit(EVENT_DEV_ASLEEP, &dev->flags);
> +		spin_unlock_irq(&dev->txq.lock);
> +		if (res) {
> +			retval = usb_submit_urb(res, GFP_NOIO);
> +			if (retval < 0) {
> +				usb_free_urb(res);
> +				netif_start_queue(dev->net);
> +				
> usb_autopm_put_interface_async(dev->intf);
> +			} else {
> +				skb = (struct sk_buff *)res->context;
> +				dev->net->trans_start = jiffies;
> +				__skb_queue_tail (&dev->txq, skb);
> +				if (!(dev->txq.qlen >= TX_QLEN(dev)))
> +					netif_start_queue(dev->net);
> +			}
> +		}
>  		tasklet_schedule (&dev->bh);
> -
> +	}
> +	
>  	return 0;
>  }
>  EXPORT_SYMBOL_GPL(usbnet_resume);
> diff --git a/include/linux/usb/usbnet.h 
> b/include/linux/usb/usbnet.h index 310e18a..6fa0545 100644
> --- a/include/linux/usb/usbnet.h
> +++ b/include/linux/usb/usbnet.h
> @@ -54,6 +54,7 @@ struct usbnet {
>  	struct sk_buff_head	txq;
>  	struct sk_buff_head	done;
>  	struct urb		*interrupt;
> +	struct urb		*deferred;
>  	struct tasklet_struct	bh;
>  
>  	struct work_struct	kevent;
> @@ -63,6 +64,8 @@ struct usbnet {
>  #		define EVENT_RX_MEMORY	2
>  #		define EVENT_STS_SPLIT	3
>  #		define EVENT_LINK_RESET	4
> +#		define EVENT_DEV_WAKING 5
> +#		define EVENT_DEV_ASLEEP 6
>  };
>  
>  static inline struct usb_driver *driver_of(struct 
> usb_interface *intf) @@ -100,6 +103,9 @@ struct driver_info {
>  	/* see if peer is connected ... can sleep */
>  	int	(*check_connect)(struct usbnet *);
>  
> +	/* (dis)activate runtime power management */
> +	int	(*manage_power)(struct usbnet *, int);
> +
>  	/* for status polling */
>  	void	(*status)(struct usbnet *, struct urb *);
>  
> 
> 
