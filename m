From: Samuel Ortiz <samuel@sortiz.org>
Subject: [RFC PATCH 3/9] irda: IrDA drivers should call irda_get_skb_cb()
Date: Mon, 15 Dec 2008 02:57:32 +0100
Message-ID: <20081215015858.436580648@sortiz.org>
References: <20081215015729.587697008@sortiz.org>
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 42.mail-out.ovh.net ([213.251.189.42]:36073 "HELO
	42.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751960AbYLOCDu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2008 21:03:50 -0500
Content-Disposition: inline; filename=0003-irda-IrDA-drivers-should-call-irda_get_skb_cb.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of accessing irda_skb_cb directly, irda drivers should call
irda_get_skb_cb().

Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
---
 drivers/net/irda/donauboe.c |    9 +--------
 drivers/net/irda/irda-usb.c |   19 ++++++++++++++-----
 2 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
index 69d16b3..1f0f9ee 100644
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -977,20 +977,13 @@ toshoboe_hard_xmit (struct sk_buff *skb, struct net_device *dev)
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
+	      , skb->len, self->txpending, INB(OBOE_ENABLEH));
 
   /* change speed pending, wait for its execution */
   if (self->new_speed)
diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index b5d6b9a..f5c13af 100644
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
@@ -464,7 +465,8 @@ static int irda_usb_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
 	}
 
 	/* FIXME: Make macro out of this one */
-	((struct irda_skb_cb *)skb->cb)->context = self;
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
1.6.0.4.766.g6fc4a.dirty

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
