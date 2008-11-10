From: =?ISO-8859-1?Q?Alex_Villac=ED=ADs_Lasso?=
	<avillaci@ceibo.fiec.espol.edu.ec>
Subject: [3/3] IRDA drivers should call irda_get_skb_cb
Date: Mon, 10 Nov 2008 11:13:00 -0500
Message-ID: <49185D8C.90502@ceibo.fiec.espol.edu.ec>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010904040904070408040403"
To: irda-users@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host-200-93-199-98.telconet.net ([200.93.199.98]:58441 "EHLO
	elastix.palosanto.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752991AbYKJQNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2008 11:13:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010904040904070408040403
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

The original patch by Samuel Ortiz, which applies without changes for 
the tx_extra implementation.


Tested-by: Alex Villacís Lasso <a_villacis@palosanto.com>

-- 
perl -e '$x=2.4;print sprintf("%.0f + %.0f = %.0f\n",$x,$x,$x+$x);'


--------------010904040904070408040403
Content-Type: text/x-patch;
 name="0003-irda-irda-drivers-should-call-irda_get_skb_cb.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0003-irda-irda-drivers-should-call-irda_get_skb_cb.patch"

>From 444d4cd5f7e13bfba44c08d6f205b67db9ff2bcc Mon Sep 17 00:00:00 2001
From: Samuel Ortiz <samuel@sortiz.org>
Date: Mon, 27 Oct 2008 21:15:04 +0100
Subject: [PATCH] irda: irda drivers should call irda_get_skb_cb()

Instead of accessing irda_skb_cb directly, irda drivers should call
irda_get_skb_cb().

Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
---
 drivers/net/irda/donauboe.c |   11 ++---------
 drivers/net/irda/irda-usb.c |   21 +++++++++++++++------
 2 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
index 69d16b3..8e234c7 100644
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -977,21 +977,14 @@ toshoboe_hard_xmit (struct sk_buff *skb, struct net_device *dev)
   __s32 speed;
   int mtt, len, ctl;
   unsigned long flags;
-  struct irda_skb_cb *cb = (struct irda_skb_cb *) skb->cb;
 
   self = (struct toshoboe_cb *) dev->priv;
 
   IRDA_ASSERT (self != NULL, return 0; );
 
   IRDA_DEBUG (1, "%s.tx:%x(%x)%x\n", __func__
-      ,skb->len,self->txpending,INB (OBOE_ENABLEH));
-  if (!cb->magic) {
-      IRDA_DEBUG (2, "%s.Not IrLAP:%x\n", __func__, cb->magic);
-#ifdef DUMP_PACKETS
-      _dumpbufs(skb->data,skb->len,'>');
-#endif
-    }
-
+	      ,skb->len,self->txpending,INB (OBOE_ENABLEH));
+  
   /* change speed pending, wait for its execution */
   if (self->new_speed)
       return -EBUSY;
diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index b5d6b9a..8ddfa5e 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -385,6 +385,7 @@ static void speed_bulk_callback(struct urb *urb)
 static int irda_usb_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct irda_usb_cb *self = netdev->priv;
+	struct irda_skb_cb *cb;
 	struct urb *urb = self->tx_urb;
 	unsigned long flags;
 	s32 speed;
@@ -463,8 +464,9 @@ static int irda_usb_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
 		irda_usb_build_header(self, self->tx_buff, 0);
 	}
 
-	/* FIXME: Make macro out of this one */
-	((struct irda_skb_cb *)skb->cb)->context = self;
+	/* FIXME: Make macro out of this one */	
+	cb = irda_get_skb_cb(skb);
+	cb->context = self;
 
 	usb_fill_bulk_urb(urb, self->usbdev,
 		      usb_sndbulkpipe(self->usbdev, self->bulk_out_ep),
@@ -554,10 +556,16 @@ static void write_bulk_callback(struct urb *urb)
 {
 	unsigned long flags;
 	struct sk_buff *skb = urb->context;
-	struct irda_usb_cb *self = ((struct irda_skb_cb *) skb->cb)->context;
+	struct irda_skb_cb *cb;
+	struct irda_usb_cb *self;
 	
 	IRDA_DEBUG(2, "%s()\n", __func__);
 
+	cb = irda_get_skb_cb(skb);
+	IRDA_ASSERT(cb != NULL, return;);
+
+	self = cb->context;
+
 	/* We should always have a context */
 	IRDA_ASSERT(self != NULL, return;);
 	/* We should always be called for the speed URB */
@@ -770,7 +778,7 @@ static void irda_usb_submit(struct irda_usb_cb *self, struct sk_buff *skb, struc
 	IRDA_ASSERT(urb != NULL, return;);
 
 	/* Save ourselves in the skb */
-	cb = (struct irda_skb_cb *) skb->cb;
+	cb = irda_get_skb_cb(skb);
 	cb->context = self;
 
 	/* Reinitialize URB */
@@ -810,7 +818,7 @@ static void irda_usb_receive(struct urb *urb)
 	IRDA_DEBUG(2, "%s(), len=%d\n", __func__, urb->actual_length);
 	
 	/* Find ourselves */
-	cb = (struct irda_skb_cb *) skb->cb;
+	cb = irda_get_skb_cb(skb);
 	IRDA_ASSERT(cb != NULL, return;);
 	self = (struct irda_usb_cb *) cb->context;
 	IRDA_ASSERT(self != NULL, return;);
@@ -970,7 +978,8 @@ static void irda_usb_rx_defer_expired(unsigned long data)
 	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Find ourselves */
-	cb = (struct irda_skb_cb *) skb->cb;
+	cb = irda_get_skb_cb(skb);
+
 	IRDA_ASSERT(cb != NULL, return;);
 	self = (struct irda_usb_cb *) cb->context;
 	IRDA_ASSERT(self != NULL, return;);
-- 
1.5.3.8


--------------010904040904070408040403--
