From: Ming Lei <ming.lei@canonical.com>
Subject: Re: usbnet transmit path problems
Date: Wed, 11 Sep 2013 19:34:30 +0800
Message-ID: <20130911193430.0825ac95@tom-ThinkPad-T410>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B7325@saturn3.aculab.com>
	<1378894312.28160.15.camel@linux-fkkt.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>, netdev@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:39800 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914Ab3IKLeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 07:34:46 -0400
In-Reply-To: <1378894312.28160.15.camel@linux-fkkt.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 Sep 2013 12:11:52 +0200
Oliver Neukum <oliver@neukum.org> wrote:

> On Wed, 2013-09-11 at 10:10 +0100, David Laight wrote:
> > I've been looking at the code in drivers/net/usb/usbnet.c that
> > processes tx data after the tx_fixup() function has run.
> > 
> > The code currently looks like:
> 
> > 1) I can't see where skb_linearize() gets called if 'can_dma_sg' is unset.
> 
> That is the job of subdrivers.
> 
> > 2) If 'length % dev->maxpacket == 0' for a multi-fragment packet then
> >    the extra byte isn't added correctly (the code probably falls off
> >    the end of the scatter-gather list).
> 
> Indeed. Ming Lei, should usbnet handle this in the sg case or better
> leave it to the subdriver you introduced this for?

IMO, it should be handled by usbnet, could you comment on below patch?

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 534b60b..929270b 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1241,7 +1241,9 @@ static int build_dma_sg(const struct sk_buff *skb, struct urb *urb)
 	if (num_sgs == 1)
 		return 0;
 
-	urb->sg = kmalloc(num_sgs * sizeof(struct scatterlist), GFP_ATOMIC);
+	/* reserve one for zero packet */
+	urb->sg = kmalloc((num_sgs + 1) * sizeof(struct scatterlist),
+			  GFP_ATOMIC);
 	if (!urb->sg)
 		return -ENOMEM;
 
@@ -1305,7 +1307,7 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 		if (build_dma_sg(skb, urb) < 0)
 			goto drop;
 	}
-	entry->length = length = urb->transfer_buffer_length;
+	length = urb->transfer_buffer_length;
 
 	/* don't assume the hardware handles USB_ZERO_PACKET
 	 * NOTE:  strictly conforming cdc-ether devices should expect
@@ -1317,15 +1319,18 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 	if (length % dev->maxpacket == 0) {
 		if (!(info->flags & FLAG_SEND_ZLP)) {
 			if (!(info->flags & FLAG_MULTI_PACKET)) {
-				urb->transfer_buffer_length++;
-				if (skb_tailroom(skb)) {
+				length++;
+				if (skb_tailroom(skb) && !dev->can_dma_sg) {
 					skb->data[skb->len] = 0;
 					__skb_put(skb, 1);
-				}
+				} else if (dev->can_dma_sg)
+					sg_set_buf(&urb->sg[urb->num_sgs++],
+							dev->zlp, 1);
 			}
 		} else
 			urb->transfer_flags |= URB_ZERO_PACKET;
 	}
+	entry->length = urb->transfer_buffer_length = length;
 
 	spin_lock_irqsave(&dev->txq.lock, flags);
 	retval = usb_autopm_get_interface_async(dev->intf);
@@ -1509,6 +1514,7 @@ void usbnet_disconnect (struct usb_interface *intf)
 
 	usb_kill_urb(dev->interrupt);
 	usb_free_urb(dev->interrupt);
+	kfree(dev->zlp);
 
 	free_netdev(net);
 }
@@ -1675,9 +1681,16 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	/* initialize max rx_qlen and tx_qlen */
 	usbnet_update_max_qlen(dev);
 
+	if (dev->can_dma_sg && !(info->flags & FLAG_SEND_ZLP) &&
+		!(info->flags & FLAG_MULTI_PACKET)) {
+		dev->zlp = kzalloc(1, GFP_KERNEL);
+		if (!dev->zlp)
+			goto out4;
+	}
+
 	status = register_netdev (net);
 	if (status)
-		goto out4;
+		goto out5;
 	netif_info(dev, probe, dev->net,
 		   "register '%s' at usb-%s-%s, %s, %pM\n",
 		   udev->dev.driver->name,
@@ -1695,6 +1708,8 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 
 	return 0;
 
+out5:
+	kfree(dev->zlp);
 out4:
 	usb_free_urb(dev->interrupt);
 out3:
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 9cb2fe8..3f1b081 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -42,6 +42,7 @@ struct usbnet {
 	struct usb_host_endpoint *status;
 	unsigned		maxpacket;
 	struct timer_list	delay;
+	char			*zlp;
 
 	/* protocol/interface state */
 	struct net_device	*net;


> 
> > 4) I read that USB3 has a different scheme for terminating bulk data
> >    that is a multiple of the packet size.
> >    Does this mean that the pad byte isn't needed for USB3?
> >    (Or are USB3 controllers/targets just as buggy?)
> 
> We don't have enough examples to tell.

I should depend on how device deals with termination of bulk data.


Thanks,
-- 
Ming Lei
