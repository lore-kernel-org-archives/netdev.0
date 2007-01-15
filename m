From: Samuel Ortiz <samuel@sortiz.org>
Subject: [PATCH 1/2] [IrDA] irda-usb TX path optimization (was Re: IrDA spams logfiles - since 2.6.19)
Date: Mon, 15 Jan 2007 11:15:11 +0200
Message-ID: <20070115091511.GA3532@sortiz.org>
References: <20070107005150.GE22817@gamma.logic.tuwien.ac.at> <20070110.152607.125896247.davem@davemloft.net> <20070111120154.GA4175@sortiz.org>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: avl@logic.at, netdev@vger.kernel.org,
	irda-users@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 30.mail-out.ovh.net ([213.186.62.213]:33878 "HELO
	30.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932135AbXAOJWE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jan 2007 04:22:04 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20070111120154.GA4175@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

Since we stop using dev_alloc_skb on the IrDA TX frame, we constantly run
into the case of the skb headroom being 0, and thus we call skb_cow for
every IrDA TX frame.
This patch uses a local buffer and memcpy the skb to it, saving us a
kmalloc for each of those IrDA TX frames.

Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

---
 drivers/net/irda/irda-usb.c |   43 ++++++++++++++++++++-----------------------
 drivers/net/irda/irda-usb.h |    1 +
 2 files changed, 21 insertions(+), 23 deletions(-)

diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index 3ca1082..8381c04 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -441,25 +441,13 @@ static int irda_usb_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
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
@@ -472,17 +460,17 @@ static int irda_usb_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
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
+                      self->tx_buff, skb->len + self->header_length,
                       write_bulk_callback, skb);
-	urb->transfer_buffer_length = skb->len;
+
 	/* This flag (URB_ZERO_PACKET) indicates that what we send is not
 	 * a continuous stream of data but separate packets.
 	 * In this case, the USB layer will insert an empty USB frame (TD)
@@ -1455,6 +1443,9 @@ static inline void irda_usb_close(struct irda_usb_cb *self)
 	/* Remove the speed buffer */
 	kfree(self->speed_buff);
 	self->speed_buff = NULL;
+
+	kfree(self->tx_buff);
+	self->tx_buff = NULL;
 }
 
 /********************** USB CONFIG SUBROUTINES **********************/
@@ -1753,9 +1744,14 @@ static int irda_usb_probe(struct usb_interface *intf,
 
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
@@ -1766,14 +1762,14 @@ static int irda_usb_probe(struct usb_interface *intf,
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
@@ -1782,9 +1778,10 @@ static int irda_usb_probe(struct usb_interface *intf,
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
-- 
1.4.4.4

