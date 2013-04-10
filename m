From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 1/2 v4] usbnet: allow status interrupt URB to always be
 active
Date: Wed, 10 Apr 2013 10:01:20 -0500
Message-ID: <1365606080.28888.72.camel@dcbw.foobar.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	 <1542762.9EJvNHlBNo@linux-5eaq.site>
	 <1365602083.28888.40.camel@dcbw.foobar.com>
	 <21345916.cd7DzC6Ttz@linux-5eaq.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ming Lei <tom.leiming@gmail.com>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33603 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934984Ab3DJPAc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Apr 2013 11:00:32 -0400
In-Reply-To: <21345916.cd7DzC6Ttz@linux-5eaq.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-10 at 15:58 +0200, Oliver Neukum wrote:
> On Wednesday 10 April 2013 08:54:43 Dan Williams wrote:
> > > The refcounting is very good. Just don't mess around with "force"
> > 
> > That's easy to do if the helpers aren't used for suspend/resume, which
> > is what I had previously in my v2 patches until Ming suggested that I
> > use the helpers there.  I can go back to that approach if you'd like, it
> > is a bit less complicated at the expense of sprinkling the interrupt urb
> > submit/kill code around more widely.
> 
> If you introduce a third helper like "forcibly_stop_interrupt" or something,
> I'll be perfectly happy. Just don't use flags which completely alter behavior.
> 
> 	Regards
> 		Oliver

Do you mean something more like this?  If so, I'll go ahead and do the
formal submission.  Thanks!

Dan
---
 drivers/net/usb/usbnet.c   | 79 ++++++++++++++++++++++++++++++++++++++++++----
 include/linux/usb/usbnet.h |  5 +++
 2 files changed, 77 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 51f3192..f903beb 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -252,6 +252,70 @@ static int init_status (struct usbnet *dev, struct usb_interface *intf)
 	return 0;
 }
 
+/* Submit the interrupt URB if not previously submitted, increasing refcount */
+int usbnet_status_start(struct usbnet *dev, gfp_t mem_flags)
+{
+	int ret = 0;
+
+	WARN_ON_ONCE(dev->interrupt == NULL);
+	if (dev->interrupt) {
+		mutex_lock(&dev->interrupt_mutex);
+
+		if (++dev->interrupt_count == 1)
+			ret = usb_submit_urb(dev->interrupt, mem_flags);
+
+		dev_dbg(&dev->udev->dev, "incremented interrupt URB count to %d\n",
+			dev->interrupt_count);
+		mutex_unlock(&dev->interrupt_mutex);
+	}
+	return ret;
+}
+EXPORT_SYMBOL_GPL(usbnet_status_start);
+
+/* For resume; submit interrupt URB if previously submitted */
+static int __usbnet_status_start_force(struct usbnet *dev, gfp_t mem_flags)
+{
+	int ret = 0;
+
+	mutex_lock(&dev->interrupt_mutex);
+	if (dev->interrupt_count) {
+		ret = usb_submit_urb(dev->interrupt, mem_flags);
+		dev_dbg(&dev->udev->dev,
+		        "submitted interrupt URB for resume\n");
+	}
+	mutex_unlock(&dev->interrupt_mutex);
+	return ret;
+}
+
+/* Kill the interrupt URB if all submitters want it killed */
+void usbnet_status_stop(struct usbnet *dev)
+{
+	if (dev->interrupt) {
+		mutex_lock(&dev->interrupt_mutex);
+		WARN_ON(dev->interrupt_count == 0);
+
+		if (dev->interrupt_count && --dev->interrupt_count == 0)
+			usb_kill_urb(dev->interrupt);
+
+		dev_dbg(&dev->udev->dev,
+			"decremented interrupt URB count to %d\n",
+			dev->interrupt_count);
+		mutex_unlock(&dev->interrupt_mutex);
+	}
+}
+EXPORT_SYMBOL_GPL(usbnet_status_stop);
+
+/* For suspend; always kill interrupt URB */
+static void __usbnet_status_stop_force(struct usbnet *dev)
+{
+	if (dev->interrupt) {
+		mutex_lock(&dev->interrupt_mutex);
+		usb_kill_urb(dev->interrupt);
+		dev_dbg(&dev->udev->dev, "killed interrupt URB for suspend\n");
+		mutex_unlock(&dev->interrupt_mutex);
+	}
+}
+
 /* Passes this packet up the stack, updating its accounting.
  * Some link protocols batch packets, so their rx_fixup paths
  * can return clones as well as just modify the original skb.
@@ -725,7 +789,7 @@ int usbnet_stop (struct net_device *net)
 	if (!(info->flags & FLAG_AVOID_UNLINK_URBS))
 		usbnet_terminate_urbs(dev);
 
-	usb_kill_urb(dev->interrupt);
+	usbnet_status_stop(dev);
 
 	usbnet_purge_paused_rxq(dev);
 
@@ -787,7 +851,7 @@ int usbnet_open (struct net_device *net)
 
 	/* start any status interrupt transfer */
 	if (dev->interrupt) {
-		retval = usb_submit_urb (dev->interrupt, GFP_KERNEL);
+		retval = usbnet_status_start(dev, GFP_KERNEL);
 		if (retval < 0) {
 			netif_err(dev, ifup, dev->net,
 				  "intr submit %d\n", retval);
@@ -1430,6 +1494,8 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	dev->delay.data = (unsigned long) dev;
 	init_timer (&dev->delay);
 	mutex_init (&dev->phy_mutex);
+	mutex_init(&dev->interrupt_mutex);
+	dev->interrupt_count = 0;
 
 	dev->net = net;
 	strcpy (net->name, "usb%d");
@@ -1565,7 +1631,7 @@ int usbnet_suspend (struct usb_interface *intf, pm_message_t message)
 		 */
 		netif_device_detach (dev->net);
 		usbnet_terminate_urbs(dev);
-		usb_kill_urb(dev->interrupt);
+		__usbnet_status_stop_force(dev);
 
 		/*
 		 * reattach so runtime management can use and
@@ -1585,9 +1651,8 @@ int usbnet_resume (struct usb_interface *intf)
 	int                     retval;
 
 	if (!--dev->suspend_count) {
-		/* resume interrupt URBs */
-		if (dev->interrupt && test_bit(EVENT_DEV_OPEN, &dev->flags))
-			usb_submit_urb(dev->interrupt, GFP_NOIO);
+		/* resume interrupt URB if it was previously submitted */
+		__usbnet_status_start_force(dev, GFP_NOIO);
 
 		spin_lock_irq(&dev->txq.lock);
 		while ((res = usb_get_from_anchor(&dev->deferred))) {
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 0e5ac93..d71f44c 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -56,6 +56,8 @@ struct usbnet {
 	struct sk_buff_head	done;
 	struct sk_buff_head	rxq_pause;
 	struct urb		*interrupt;
+	unsigned		interrupt_count;
+	struct mutex            interrupt_mutex;
 	struct usb_anchor	deferred;
 	struct tasklet_struct	bh;
 
@@ -246,4 +248,7 @@ extern int usbnet_nway_reset(struct net_device *net);
 
 extern int usbnet_manage_power(struct usbnet *, int);
 
+int usbnet_status_start(struct usbnet *dev, gfp_t mem_flags);
+void usbnet_status_stop(struct usbnet *dev);
+
 #endif /* __LINUX_USB_USBNET_H */
-- 
1.8.1.4
