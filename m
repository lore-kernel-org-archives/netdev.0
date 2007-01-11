From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: IrDA spams logfiles - since 2.6.19
Date: Thu, 11 Jan 2007 14:01:54 +0200
Message-ID: <20070111120154.GA4175@sortiz.org>
References: <20070107005150.GE22817@gamma.logic.tuwien.ac.at> <20070110.152607.125896247.davem@davemloft.net>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: avl@logic.at, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 42.mail-out.ovh.net ([213.251.189.42]:50741 "HELO
	42.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1030256AbXAKMJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jan 2007 07:09:41 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20070110.152607.125896247.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

On Wed, Jan 10, 2007 at 03:26:07PM -0800, David Miller wrote:
> The warning is a bit extreme because the skb_cow() call does fix
> things up and makes space available.
> 
> But it's not the most efficient thing in the world, so it's good
> that we know about this so we can have a closer work.
> 
> I want to remove that warning, but first let's figure out what the
> call chain is that causes skb_headroom() to end up being zero.
In Andreas case, the device is probably in discovery mode, sending IrDA
discovery frames periodically. For each of them, the path is the following:
irlap_slot_timer_expired()
  irlap_do_event()
    irlap_state_query()
      irlap_send_discovery_xid_frame()
        dev_hard_start_xmit()
          irda_usb_hard_xmit()

irlap_send_discovery_xid_frame() is the one allocating and building the
discovery frame. It is an IrLAP frame.
As you might remember, this routine used to call dev_alloc_skb() for 
allocation but now calls alloc_skb(). So, it used to reserve a 16 bytes
header, while now it doesn't.
The issue here is that the USB-IrDA specification tells us that we have to add
a 1 byte header to the IrLAP frame (and this becomes 3 bytes for some devices
playing with the spec) before pushing it to the USB bus.
So, while the discovery routine returns a correct IrLAP skb, with no headroom,
the irda-usb code needs to add a 1 (or 3) bytes header to it.

One solution to fix that problem could be to systematically add a header for
every allocated IrLAP frame on the IrDA TX path. Since the USB-IrDA spec is
defined by the USB-IF, not by the IrDA, I don't really like this solution. It
would create code changes all over the IrDA stack only for handling the
USB-IrDA case.
The second solution would consist of copying the skb->data into some irda-usb.c
pre-allocated buffer, instead of always calling skb_cow(). That would save us
one kmalloc(). Obviously, there is a performance hit as we're doing one memcpy
for each and every packet sent. I think this is a cleaner solution but the
performance hit must be taken to account since the IrDA USB dongles are among
the most popular IrDA devices.

Dave, please let me know what you think about it, and if you agree with my
problem description, please let me know which solution you would advice for.

The patch for the second solution would look something like that (although
I could use some of the skb routines - skb_copy_bits() - to copy the skb
data). It's been tested with my USB stir4220 based IrDA dongle:

diff --git a/drivers/net/irda/irda-usb.h b/drivers/net/irda/irda-usb.h
index 6b2271f..e846c38 100644
--- a/drivers/net/irda/irda-usb.h
+++ b/drivers/net/irda/irda-usb.h
@@ -156,6 +156,7 @@ struct irda_usb_cb {
 	struct irlap_cb   *irlap;	/* The link layer we are binded to */
 	struct qos_info qos;
 	char *speed_buff;		/* Buffer for speed changes */
+	char *tx_buff;
 
 	struct timeval stamp;
 	struct timeval now;
diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index 3ca1082..5f22a8e 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -441,25 +441,14 @@ static int irda_usb_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
 		goto drop;
 	}
 
-	/* Make sure there is room for IrDA-USB header. The actual
-	 * allocation will be done lower in skb_push().
-	 * Also, we don't use directly skb_cow(), because it require
-	 * headroom >= 16, which force unnecessary copies - Jean II */
-	if (skb_headroom(skb) < self->header_length) {
-		IRDA_DEBUG(0, "%s(), Insuficient skb headroom.\n", __FUNCTION__);
-		if (skb_cow(skb, self->header_length)) {
-			IRDA_WARNING("%s(), failed skb_cow() !!!\n", __FUNCTION__);
-			goto drop;
-		}
-	}
+	memset(self->tx_buff, 0, IRDA_SKB_MAX_MTU + self->header_length);
+	memcpy(self->tx_buff + self->header_length, skb->data, skb->len);
 
 	/* Change setting for next frame */
-
 	if (self->capability & IUC_STIR421X) {
 		__u8 turnaround_time;
-		__u8* frame;
+		__u8* frame = self->tx_buff;
 		turnaround_time = get_turnaround_time( skb );
-		frame= skb_push(skb, self->header_length);
 		irda_usb_build_header(self, frame, 0);
 		frame[2] = turnaround_time;
 		if ((skb->len != 0) &&
@@ -472,17 +461,18 @@ static int irda_usb_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
 			frame[1] = 0;
 		}
 	} else {
-		irda_usb_build_header(self, skb_push(skb, self->header_length), 0);
+		irda_usb_build_header(self, self->tx_buff, 0);
 	}
 
 	/* FIXME: Make macro out of this one */
 	((struct irda_skb_cb *)skb->cb)->context = self;
 
-        usb_fill_bulk_urb(urb, self->usbdev, 
+	usb_fill_bulk_urb(urb, self->usbdev, 
 		      usb_sndbulkpipe(self->usbdev, self->bulk_out_ep),
-                      skb->data, IRDA_SKB_MAX_MTU,
+                      self->tx_buff, IRDA_SKB_MAX_MTU + self->header_length,
                       write_bulk_callback, skb);
-	urb->transfer_buffer_length = skb->len;
+	urb->transfer_buffer_length = skb->len + self->header_length;
+
 	/* This flag (URB_ZERO_PACKET) indicates that what we send is not
 	 * a continuous stream of data but separate packets.
 	 * In this case, the USB layer will insert an empty USB frame (TD)
@@ -1455,6 +1445,9 @@ static inline void irda_usb_close(struct irda_usb_cb *self)
 	/* Remove the speed buffer */
 	kfree(self->speed_buff);
 	self->speed_buff = NULL;
+
+	kfree(self->tx_buff);
+	self->tx_buff = NULL;
 }
 
 /********************** USB CONFIG SUBROUTINES **********************/
@@ -1753,9 +1746,14 @@ static int irda_usb_probe(struct usb_interface *intf,
 
 	memset(self->speed_buff, 0, IRDA_USB_SPEED_MTU);
 
+	self->tx_buff = kzalloc(IRDA_SKB_MAX_MTU + self->header_length,
+				GFP_KERNEL);
+	if (self->tx_buff == NULL) 
+		goto err_out_4;
+
 	ret = irda_usb_open(self);
 	if (ret) 
-		goto err_out_4;
+		goto err_out_5;
 
 	IRDA_MESSAGE("IrDA: Registered device %s\n", net->name);
 	usb_set_intfdata(intf, self);
@@ -1766,14 +1764,14 @@ static int irda_usb_probe(struct usb_interface *intf,
 		self->needspatch = (ret < 0);
 		if (self->needspatch) {
 			IRDA_ERROR("STIR421X: Couldn't upload patch\n");
-			goto err_out_5;
+			goto err_out_6;
 		}
 
 		/* replace IrDA class descriptor with what patched device is now reporting */
 		irda_desc = irda_usb_find_class_desc (self->usbintf);
 		if (irda_desc == NULL) {
 			ret = -ENODEV;
-			goto err_out_5;
+			goto err_out_6;
 		}
 		if (self->irda_desc)
 			kfree (self->irda_desc);
@@ -1782,9 +1780,10 @@ static int irda_usb_probe(struct usb_interface *intf,
 	}
 
 	return 0;
-
-err_out_5:
+err_out_6:
 	unregister_netdev(self->netdev);
+err_out_5:
+	kfree(self->tx_buff);
 err_out_4:
 	kfree(self->speed_buff);
 err_out_3:
 
