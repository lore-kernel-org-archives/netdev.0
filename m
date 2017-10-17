From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 04/58] net/irda-usb: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:28:48 -0700
Message-ID: <1508200182-104605-5-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Samuel Ortiz <samuel@sortiz.org>, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly. This requires adding a pointer to
hold the timer's target URB, as there won't be a way to pass this in the
future.

Cc: Samuel Ortiz <samuel@sortiz.org>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/staging/irda/drivers/irda-usb.c | 20 ++++++--------------
 drivers/staging/irda/drivers/irda-usb.h |  1 +
 2 files changed, 7 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/irda/drivers/irda-usb.c b/drivers/staging/irda/drivers/irda-usb.c
index 82bfc051e1de..bda6bdc6c70b 100644
--- a/drivers/staging/irda/drivers/irda-usb.c
+++ b/drivers/staging/irda/drivers/irda-usb.c
@@ -117,7 +117,7 @@ static void irda_usb_close(struct irda_usb_cb *self);
 static void speed_bulk_callback(struct urb *urb);
 static void write_bulk_callback(struct urb *urb);
 static void irda_usb_receive(struct urb *urb);
-static void irda_usb_rx_defer_expired(unsigned long data);
+static void irda_usb_rx_defer_expired(struct timer_list *t);
 static int irda_usb_net_open(struct net_device *dev);
 static int irda_usb_net_close(struct net_device *dev);
 static int irda_usb_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
@@ -846,8 +846,7 @@ static void irda_usb_receive(struct urb *urb)
 		 * hot unplug of the dongle...
 		 * Lowest effective timer is 10ms...
 		 * Jean II */
-		self->rx_defer_timer.function = irda_usb_rx_defer_expired;
-		self->rx_defer_timer.data = (unsigned long) urb;
+		self->rx_defer_timer_urb = urb;
 		mod_timer(&self->rx_defer_timer,
 			  jiffies + msecs_to_jiffies(10));
 
@@ -953,20 +952,13 @@ static void irda_usb_receive(struct urb *urb)
  * In case of errors, we want the USB layer to have time to recover.
  * Now, it is time to resubmit ouur Rx URB...
  */
-static void irda_usb_rx_defer_expired(unsigned long data)
+static void irda_usb_rx_defer_expired(struct timer_list *t)
 {
-	struct urb *urb = (struct urb *) data;
+	struct irda_usb_cb *self = from_timer(self, t, rx_defer_timer);
+	struct urb *urb = self->rx_defer_timer_urb;
 	struct sk_buff *skb = (struct sk_buff *) urb->context;
-	struct irda_usb_cb *self; 
-	struct irda_skb_cb *cb;
 	struct urb *next_urb;
 
-	/* Find ourselves */
-	cb = (struct irda_skb_cb *) skb->cb;
-	IRDA_ASSERT(cb != NULL, return;);
-	self = (struct irda_usb_cb *) cb->context;
-	IRDA_ASSERT(self != NULL, return;);
-
 	/* Same stuff as when Rx is done, see above... */
 	next_urb = self->idle_rx_urb;
 	urb->context = NULL;
@@ -1622,7 +1614,7 @@ static int irda_usb_probe(struct usb_interface *intf,
 	self = netdev_priv(net);
 	self->netdev = net;
 	spin_lock_init(&self->lock);
-	init_timer(&self->rx_defer_timer);
+	timer_setup(&self->rx_defer_timer, irda_usb_rx_defer_expired, 0);
 
 	self->capability = id->driver_info;
 	self->needspatch = ((self->capability & IUC_STIR421X) != 0);
diff --git a/drivers/staging/irda/drivers/irda-usb.h b/drivers/staging/irda/drivers/irda-usb.h
index 8ac389fa9348..56ee8c16c5e2 100644
--- a/drivers/staging/irda/drivers/irda-usb.h
+++ b/drivers/staging/irda/drivers/irda-usb.h
@@ -170,5 +170,6 @@ struct irda_usb_cb {
 	int needspatch;        		/* device needs firmware patch */
 
 	struct timer_list rx_defer_timer;	/* Wait for Rx error to clear */
+	struct urb *rx_defer_timer_urb;	/* URB attached to rx_defer_timer */
 };
 
-- 
2.7.4
