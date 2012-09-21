From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: removing the timer from cdc-ncm
Date: Fri, 21 Sep 2012 10:35:03 +0200
Message-ID: <6020948.EvS2esPpc0@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: Alexey ORISHKO <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>, bjorn-yOkvZcmFvRU@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

here is the patch that does everything I consider theoretically necessary
to have bundling of frames in usbnet and adapting cdc-ncm to it.

I'd appreciate any review in case I am doing something stupid.

	Regards
		Oliver

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 4cd582a..56ef743 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -135,9 +135,6 @@ struct cdc_ncm_ctx {
 	u16 connected;
 };
 
-static void cdc_ncm_txpath_bh(unsigned long param);
-static void cdc_ncm_tx_timeout_start(struct cdc_ncm_ctx *ctx);
-static enum hrtimer_restart cdc_ncm_tx_timer_cb(struct hrtimer *hr_timer);
 static struct usb_driver cdc_ncm_driver;
 
 static void
@@ -464,10 +461,6 @@ static int cdc_ncm_bind(struct usbnet *dev, struct usb_interface *intf)
 	if (ctx == NULL)
 		return -ENODEV;
 
-	hrtimer_init(&ctx->tx_timer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
-	ctx->tx_timer.function = &cdc_ncm_tx_timer_cb;
-	ctx->bh.data = (unsigned long)ctx;
-	ctx->bh.func = cdc_ncm_txpath_bh;
 	atomic_set(&ctx->stop, 0);
 	spin_lock_init(&ctx->mtx);
 	ctx->netdev = dev->net;
@@ -650,7 +643,7 @@ static void cdc_ncm_zero_fill(u8 *ptr, u32 first, u32 end, u32 max)
 	memset(ptr + first, 0, end - first);
 }
 
-static struct sk_buff *
+static int
 cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb)
 {
 	struct sk_buff *skb_out;
@@ -659,12 +652,7 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb)
 	u32 last_offset;
 	u16 n = 0, index;
 	u8 ready2send = 0;
-
-	/* if there is a remaining skb, it gets priority */
-	if (skb != NULL)
-		swap(skb, ctx->tx_rem_skb);
-	else
-		ready2send = 1;
+	u8 error = 0;
 
 	/*
 	 * +----------------+
@@ -690,7 +678,7 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb)
 				dev_kfree_skb_any(skb);
 				ctx->netdev->stats.tx_dropped++;
 			}
-			goto exit_no_skb;
+			return -EBUSY;
 		}
 
 		/* make room for NTH and NDP */
@@ -719,28 +707,15 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb)
 		/* compute maximum buffer size */
 		rem = ctx->tx_max - offset;
 
-		if (skb == NULL) {
-			skb = ctx->tx_rem_skb;
-			ctx->tx_rem_skb = NULL;
-
-			/* check for end of skb */
-			if (skb == NULL)
-				break;
-		}
-
 		if (skb->len > rem) {
 			if (n == 0) {
 				/* won't fit, MTU problem? */
 				dev_kfree_skb_any(skb);
 				skb = NULL;
 				ctx->netdev->stats.tx_dropped++;
+				error = 1;
 			} else {
-				/* no room for skb - store for later */
-				if (ctx->tx_rem_skb != NULL) {
-					dev_kfree_skb_any(ctx->tx_rem_skb);
-					ctx->netdev->stats.tx_dropped++;
-				}
-				ctx->tx_rem_skb = skb;
+
 				skb = NULL;
 				ready2send = 1;
 			}
@@ -768,13 +743,6 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb)
 		skb = NULL;
 	}
 
-	/* free up any dangling skb */
-	if (skb != NULL) {
-		dev_kfree_skb_any(skb);
-		skb = NULL;
-		ctx->netdev->stats.tx_dropped++;
-	}
-
 	ctx->tx_curr_frame_num = n;
 
 	if (n == 0) {
@@ -791,9 +759,7 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb)
 		ctx->tx_curr_skb = skb_out;
 		ctx->tx_curr_offset = offset;
 		ctx->tx_curr_last_offset = last_offset;
-		/* set the pending count */
-		if (n < CDC_NCM_RESTART_TIMER_DATAGRAM_CNT)
-			ctx->tx_timer_pending = CDC_NCM_TIMER_PENDING_CNT;
+
 		goto exit_no_skb;
 
 	} else {
@@ -874,71 +840,37 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb)
 	/* return skb */
 	ctx->tx_curr_skb = NULL;
 	ctx->netdev->stats.tx_packets += ctx->tx_curr_frame_num;
-	return skb_out;
 
-exit_no_skb:
-	/* Start timer, if there is a remaining skb */
-	if (ctx->tx_curr_skb != NULL)
-		cdc_ncm_tx_timeout_start(ctx);
-	return NULL;
-}
-
-static void cdc_ncm_tx_timeout_start(struct cdc_ncm_ctx *ctx)
-{
-	/* start timer, if not already started */
-	if (!(hrtimer_active(&ctx->tx_timer) || atomic_read(&ctx->stop)))
-		hrtimer_start(&ctx->tx_timer,
-				ktime_set(0, CDC_NCM_TIMER_INTERVAL),
-				HRTIMER_MODE_REL);
-}
+	if (error)
+		return -EBUSY;
+	if (ready2send)
+		return -EBUSY;
+	else
+		return 0;
 
-static enum hrtimer_restart cdc_ncm_tx_timer_cb(struct hrtimer *timer)
-{
-	struct cdc_ncm_ctx *ctx =
-			container_of(timer, struct cdc_ncm_ctx, tx_timer);
+exit_no_skb:
 
-	if (!atomic_read(&ctx->stop))
-		tasklet_schedule(&ctx->bh);
-	return HRTIMER_NORESTART;
+	return -EAGAIN;
 }
 
-static void cdc_ncm_txpath_bh(unsigned long param)
+static int cdc_ncm_tx_bundle(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
 {
-	struct cdc_ncm_ctx *ctx = (struct cdc_ncm_ctx *)param;
-
-	spin_lock_bh(&ctx->mtx);
-	if (ctx->tx_timer_pending != 0) {
-		ctx->tx_timer_pending--;
-		cdc_ncm_tx_timeout_start(ctx);
-		spin_unlock_bh(&ctx->mtx);
-	} else if (ctx->netdev != NULL) {
-		spin_unlock_bh(&ctx->mtx);
-		netif_tx_lock_bh(ctx->netdev);
-		usbnet_start_xmit(NULL, ctx->netdev);
-		netif_tx_unlock_bh(ctx->netdev);
-	}
+	int err;
+	struct cdc_ncm_ctx *ctx = (struct cdc_ncm_ctx *)dev->data[0];
+	
+	err = cdc_ncm_fill_tx_frame(ctx, skb);
+	return err;
 }
 
 static struct sk_buff *
 cdc_ncm_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
 {
-	struct sk_buff *skb_out;
 	struct cdc_ncm_ctx *ctx = (struct cdc_ncm_ctx *)dev->data[0];
 
-	/*
-	 * The Ethernet API we are using does not support transmitting
-	 * multiple Ethernet frames in a single call. This driver will
-	 * accumulate multiple Ethernet frames and send out a larger
-	 * USB frame when the USB buffer is full or when a single jiffies
-	 * timeout happens.
-	 */
 	if (ctx == NULL)
 		goto error;
 
-	spin_lock_bh(&ctx->mtx);
-	skb_out = cdc_ncm_fill_tx_frame(ctx, skb);
-	spin_unlock_bh(&ctx->mtx);
-	return skb_out;
+	return ctx->tx_curr_skb;
 
 error:
 	if (skb != NULL)
@@ -1197,6 +1129,7 @@ static const struct driver_info cdc_ncm_info = {
 	.manage_power = cdc_ncm_manage_power,
 	.status = cdc_ncm_status,
 	.rx_fixup = cdc_ncm_rx_fixup,
+	.tx_bundle = cdc_ncm_tx_bundle,
 	.tx_fixup = cdc_ncm_tx_fixup,
 };
 
@@ -1211,6 +1144,7 @@ static const struct driver_info wwan_info = {
 	.manage_power = cdc_ncm_manage_power,
 	.status = cdc_ncm_status,
 	.rx_fixup = cdc_ncm_rx_fixup,
+	.tx_bundle = cdc_ncm_tx_bundle,
 	.tx_fixup = cdc_ncm_tx_fixup,
 };
 
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 8531c1c..67b6ea0 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -86,6 +86,9 @@ static u8	node_id [ETH_ALEN];
 
 static const char driver_name [] = "usbnet";
 
+static void tx_complete(struct urb *urb);
+static int submit_next_bundle(struct usbnet *dev, struct sk_buff *skb);
+
 /* use ethtool to change the level for any given device */
 static int msg_level = -1;
 module_param (msg_level, int, 0);
@@ -923,7 +926,9 @@ kevent (struct work_struct *work)
 {
 	struct usbnet		*dev =
 		container_of(work, struct usbnet, kevent);
+	struct driver_info	*info = dev->driver_info;
 	int			status;
+	struct sk_buff		*skb;
 
 	/* usb_clear_halt() needs a thread context */
 	if (test_bit (EVENT_TX_HALT, &dev->flags)) {
@@ -942,8 +947,13 @@ fail_pipe:
 					   status);
 		} else {
 			clear_bit (EVENT_TX_HALT, &dev->flags);
-			if (status != -ESHUTDOWN)
+			if (status != -ESHUTDOWN) {
+				/* queue halted, no race */
+				skb = info->tx_fixup(dev, NULL, GFP_KERNEL);
+				if (skb)
+					submit_next_bundle(dev, skb);
 				netif_wake_queue (dev->net);
+			}
 		}
 	}
 	if (test_bit (EVENT_RX_HALT, &dev->flags)) {
@@ -1008,6 +1018,11 @@ skip_reset:
 				    dev->udev->devpath,
 				    info->description);
 		} else {
+			spin_lock_irq(&dev->txlock);
+			skb = info->tx_fixup(dev, NULL, GFP_ATOMIC);
+			if (skb)
+				submit_next_bundle(dev, skb);
+			spin_unlock_irq(&dev->txlock);
 			usb_autopm_put_interface(dev->intf);
 		}
 	}
@@ -1016,17 +1031,78 @@ skip_reset:
 		netdev_dbg(dev->net, "kevent done, flags = 0x%lx\n", dev->flags);
 }
 
+static int submit_next_bundle(struct usbnet *dev, struct sk_buff *skb)
+{
+	struct skb_data *entry;
+	int length = skb->len;
+	int retval;
+	struct driver_info *info = dev->driver_info;
+	struct urb *urb;
+
+	urb = usb_alloc_urb(0, GFP_ATOMIC);
+	if (!urb)
+		return -ENOMEM;
+
+	entry = (struct skb_data *) skb->cb;
+	entry->urb = urb;
+	entry->dev = dev;
+	entry->length = length;
+
+	usb_fill_bulk_urb (urb, dev->udev, dev->out,
+			skb->data, skb->len, tx_complete, skb);
+
+	/* don't assume the hardware handles USB_ZERO_PACKET
+	 * NOTE:  strictly conforming cdc-ether devices should expect
+	 * the ZLP here, but ignore the one-byte packet.
+	 * NOTE2: CDC NCM specification is different from CDC ECM when
+	 * handling ZLP/short packets, so cdc_ncm driver will make short
+	 * packet itself if needed.
+	 */
+	if (length % dev->maxpacket == 0) {
+		if (!(info->flags & FLAG_SEND_ZLP)) {
+			if (!(info->flags & FLAG_MULTI_PACKET)) {
+				urb->transfer_buffer_length++;
+				if (skb_tailroom(skb)) {
+					skb->data[skb->len] = 0;
+					__skb_put(skb, 1);
+				}
+			}
+		} else
+			urb->transfer_flags |= URB_ZERO_PACKET;
+	}
+
+	atomic_inc(&dev->tx_in_flight);
+	retval = usb_submit_urb(urb, GFP_ATOMIC);
+	if (retval < 0)
+		atomic_dec(&dev->tx_in_flight);
+	//FIXME: full error handling
+
+	return retval;
+}
 /*-------------------------------------------------------------------------*/
 
 static void tx_complete (struct urb *urb)
 {
 	struct sk_buff		*skb = (struct sk_buff *) urb->context;
+	struct sk_buff		*skb2;
 	struct skb_data		*entry = (struct skb_data *) skb->cb;
 	struct usbnet		*dev = entry->dev;
+	struct driver_info	*info = dev->driver_info;
+	int			in_flight;
 
+	in_flight = atomic_dec_return(&dev->tx_in_flight);
 	if (urb->status == 0) {
-		if (!(dev->driver_info->flags & FLAG_MULTI_PACKET))
+		if (!(dev->driver_info->flags & FLAG_MULTI_PACKET)) {
 			dev->net->stats.tx_packets++;
+		} else {
+			if (in_flight < 2) {
+				spin_lock(&dev->txlock);
+				skb2 = info->tx_fixup(dev, NULL, GFP_ATOMIC);
+				if (skb2)
+					submit_next_bundle(dev, skb2);
+				spin_unlock(&dev->txlock);
+			}
+		}
 		dev->net->stats.tx_bytes += entry->length;
 	} else {
 		dev->net->stats.tx_errors++;
@@ -1089,23 +1165,51 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 	struct urb		*urb = NULL;
 	struct skb_data		*entry;
 	struct driver_info	*info = dev->driver_info;
+	struct sk_buff		*skb_old = NULL;
 	unsigned long		flags;
 	int retval;
+	int transmit_now = 1;
+	int bundle_again = 0;
 
 	if (skb)
 		skb_tx_timestamp(skb);
 
+	/*
+	 * first we allow drivers to bundle packets together
+	 * maintainance of the buffer is the responsibility
+	 * of the lower layer
+	 */
+	spin_lock(&dev->txlock);
+rebundle:
+	if (info->tx_bundle) {
+		bundle_again = 0;
+		retval = info->tx_bundle(dev, skb, GFP_ATOMIC);
+
+		switch (retval) {
+		case 0: /* the package has been bundled */
+			if (atomic_read(&dev->tx_in_flight) < 2)
+				transmit_now = 1;
+			else
+				transmit_now = 0;
+			break;
+		case -EAGAIN:
+			transmit_now = 1;
+			bundle_again = 1;
+			skb_old = skb;
+			break;
+		case -EBUSY:
+			transmit_now = 1;
+			break;
+		}
+	}
 	// some devices want funky USB-level framing, for
 	// win32 driver (usually) and/or hardware quirks
-	if (info->tx_fixup) {
+	if (transmit_now && info->tx_fixup) {
 		skb = info->tx_fixup (dev, skb, GFP_ATOMIC);
 		if (!skb) {
 			if (netif_msg_tx_err(dev)) {
 				netif_dbg(dev, tx_err, dev->net, "can't tx_fixup skb\n");
 				goto drop;
-			} else {
-				/* cdc_ncm collected packet; waits for more */
-				goto not_drop;
 			}
 		}
 	}
@@ -1164,14 +1268,17 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 	}
 #endif
 
+	atomic_inc(&dev->tx_in_flight);
 	switch ((retval = usb_submit_urb (urb, GFP_ATOMIC))) {
 	case -EPIPE:
 		netif_stop_queue (net);
 		usbnet_defer_kevent (dev, EVENT_TX_HALT);
+		atomic_dec(&dev->tx_in_flight);
 		usb_autopm_put_interface_async(dev->intf);
 		break;
 	default:
 		usb_autopm_put_interface_async(dev->intf);
+		atomic_dec(&dev->tx_in_flight);
 		netif_dbg(dev, tx_err, dev->net,
 			  "tx: submit urb err %d\n", retval);
 		break;
@@ -1187,7 +1294,6 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 		netif_dbg(dev, tx_err, dev->net, "drop, code %d\n", retval);
 drop:
 		dev->net->stats.tx_dropped++;
-not_drop:
 		if (skb)
 			dev_kfree_skb_any (skb);
 		usb_free_urb (urb);
@@ -1197,6 +1303,11 @@ not_drop:
 #ifdef CONFIG_PM
 deferred:
 #endif
+	if (bundle_again) {
+		skb = skb_old;
+		goto rebundle;
+	}
+	spin_unlock(&dev->txlock);
 	return NETDEV_TX_OK;
 }
 EXPORT_SYMBOL_GPL(usbnet_start_xmit);
@@ -1393,6 +1504,8 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	dev->delay.data = (unsigned long) dev;
 	init_timer (&dev->delay);
 	mutex_init (&dev->phy_mutex);
+	spin_lock_init(&dev->txlock);
+	atomic_set(&dev->tx_in_flight, 0); 
 
 	dev->net = net;
 	strcpy (net->name, "usb%d");
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index f87cf62..544ddd2 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -33,6 +33,8 @@ struct usbnet {
 	wait_queue_head_t	*wait;
 	struct mutex		phy_mutex;
 	unsigned char		suspend_count;
+	atomic_t		tx_in_flight;
+	spinlock_t		txlock;
 
 	/* i/o info: pipes etc */
 	unsigned		in, out;
@@ -133,6 +135,12 @@ struct driver_info {
 	/* fixup rx packet (strip framing) */
 	int	(*rx_fixup)(struct usbnet *dev, struct sk_buff *skb);
 
+	/* bundle individual package for transmission as
+	 * larger package. This cannot sleep
+	 */
+	int	(*tx_bundle)(struct usbnet *dev,
+				struct sk_buff *skb, gfp_t flags);
+
 	/* fixup tx packet (add framing) */
 	struct sk_buff	*(*tx_fixup)(struct usbnet *dev,
 				struct sk_buff *skb, gfp_t flags);

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
