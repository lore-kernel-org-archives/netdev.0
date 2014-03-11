From: Oliver Neukum <oneukum@suse.de>
Subject: Re: usbnet: driver_info->stop required to stop USB interrupts?
Date: Tue, 11 Mar 2014 10:14:23 +0100
Message-ID: <1394529263.16128.6.camel@linux-fkkt.site>
References: <CANEJEGsvqkT_H4i+UZpBaWMYmgXHmpD8SZ4tU1OHzLd8gyznow@mail.gmail.com>
	 <CANEJEGv03ohVwoS0Pd1Z3az9k-C=dTzG4qE1SBL6Um97QC1Ehw@mail.gmail.com>
	 <CAODwPW_t9COeg0LWfkiqXC_yTbSNhUHX-8T95KRZHfOTSiZK1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Grant Grundler <grundler@google.com>,
	netdev <netdev@vger.kernel.org>, Freddy Xin <freddy@asix.com.tw>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Allan Chou <allan@asix.com.tw>
To: Julius Werner <jwerner@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:49486 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751299AbaCKJOZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Mar 2014 05:14:25 -0400
In-Reply-To: <CAODwPW_t9COeg0LWfkiqXC_yTbSNhUHX-8T95KRZHfOTSiZK1Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-10 at 19:53 -0700, Julius Werner wrote:

> I think the best solution would be to just make dev->wait a directly
> embedded structure inside struct usbnet instead of a pointer to
> something stack-allocated. usbnet_bh() could just call wake_up()
> unconditionally (if empty it will be a noop), and then one other check
> for !dev->wait could be replaced with a call to waitqueue_active().
> Then the waitqueue-internal locks should be enough to protect all
> accesses.

What do you think?

	Regards
		Oliver

>From 5ea2cb8a2893953fc7067aeae093ab20239d5108 Mon Sep 17 00:00:00 2001
From: Oliver Neukum <oneukum@suse.de>
Date: Tue, 11 Mar 2014 09:59:48 +0100
Subject: [PATCH] usbnet: include wait queue head in device structure

This fixes a race which happens by freeing an object on the stack.
Quoting Julius:
> The issue is
> that it calls usbnet_terminate_urbs() before that, which temporarily
> installs a waitqueue in dev->wait in order to be able to wait on the
> tasklet to run and finish up some queues. The waiting itself looks
> okay, but the access to 'dev->wait' is totally unprotected and can
> race arbitrarily. I think in this case usbnet_bh() managed to succeed
> it's dev->wait check just before usbnet_terminate_urbs() sets it back
> to NULL. The latter then finishes and the waitqueue_t structure on its
> stack gets overwritten by other functions halfway through the
> wake_up() call in usbnet_bh().

The fix is to just not allocate the data structure on the stack.
As dev->wait is abused as a flag it also takes a runtime PM change
to fix this bug.

Signed-off-by: Oliver Neukum <oneukum@suse.de>
---
 drivers/net/usb/usbnet.c   | 27 ++++++++++++++-------------
 include/linux/usb/usbnet.h |  2 +-
 2 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index dd10d58..b5bcb48 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -752,14 +752,12 @@ EXPORT_SYMBOL_GPL(usbnet_unlink_rx_urbs);
 // precondition: never called in_interrupt
 static void usbnet_terminate_urbs(struct usbnet *dev)
 {
-	DECLARE_WAIT_QUEUE_HEAD_ONSTACK(unlink_wakeup);
 	DECLARE_WAITQUEUE(wait, current);
 	int temp;
 
 	/* ensure there are no more active urbs */
-	add_wait_queue(&unlink_wakeup, &wait);
+	add_wait_queue(&dev->wait, &wait);
 	set_current_state(TASK_UNINTERRUPTIBLE);
-	dev->wait = &unlink_wakeup;
 	temp = unlink_urbs(dev, &dev->txq) +
 		unlink_urbs(dev, &dev->rxq);
 
@@ -773,15 +771,14 @@ static void usbnet_terminate_urbs(struct usbnet *dev)
 				  "waited for %d urb completions\n", temp);
 	}
 	set_current_state(TASK_RUNNING);
-	dev->wait = NULL;
-	remove_wait_queue(&unlink_wakeup, &wait);
+	remove_wait_queue(&dev->wait, &wait);
 }
 
 int usbnet_stop (struct net_device *net)
 {
 	struct usbnet		*dev = netdev_priv(net);
 	struct driver_info	*info = dev->driver_info;
-	int			retval;
+	int			retval, pm;
 
 	clear_bit(EVENT_DEV_OPEN, &dev->flags);
 	netif_stop_queue (net);
@@ -791,6 +788,8 @@ int usbnet_stop (struct net_device *net)
 		   net->stats.rx_packets, net->stats.tx_packets,
 		   net->stats.rx_errors, net->stats.tx_errors);
 
+	/* to not race resume */
+	pm = usb_autopm_get_interface(dev->intf);
 	/* allow minidriver to stop correctly (wireless devices to turn off
 	 * radio etc) */
 	if (info->stop) {
@@ -817,6 +816,9 @@ int usbnet_stop (struct net_device *net)
 	dev->flags = 0;
 	del_timer_sync (&dev->delay);
 	tasklet_kill (&dev->bh);
+	if (!pm)
+		usb_autopm_put_interface(dev->intf);
+
 	if (info->manage_power &&
 	    !test_and_clear_bit(EVENT_NO_RUNTIME_PM, &dev->flags))
 		info->manage_power(dev, 0);
@@ -1438,10 +1440,8 @@ static void usbnet_bh (unsigned long param)
 	clear_bit(EVENT_RX_KILL, &dev->flags);
 
 	// waiting for all pending urbs to complete?
-	if (dev->wait) {
-		if ((dev->txq.qlen + dev->rxq.qlen + dev->done.qlen) == 0) {
-			wake_up (dev->wait);
-		}
+	if ((dev->txq.qlen + dev->rxq.qlen + dev->done.qlen) == 0) {
+		wake_up (&dev->wait);
 
 	// or are we maybe short a few urbs?
 	} else if (netif_running (dev->net) &&
@@ -1791,9 +1791,10 @@ int usbnet_resume (struct usb_interface *intf)
 		spin_unlock_irq(&dev->txq.lock);
 
 		if (test_bit(EVENT_DEV_OPEN, &dev->flags)) {
-			/* handle remote wakeup ASAP */
-			if (!dev->wait &&
-				netif_device_present(dev->net) &&
+			/* handle remote wakeup ASAP
+			 * we cannot race against stop
+			 */
+			if (netif_device_present(dev->net) &&
 				!timer_pending(&dev->delay) &&
 				!test_bit(EVENT_RX_HALT, &dev->flags))
 					rx_alloc_submit(dev, GFP_NOIO);
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index e303eef..0662e98 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -30,7 +30,7 @@ struct usbnet {
 	struct driver_info	*driver_info;
 	const char		*driver_name;
 	void			*driver_priv;
-	wait_queue_head_t	*wait;
+	wait_queue_head_t	wait;
 	struct mutex		phy_mutex;
 	unsigned char		suspend_count;
 	unsigned char		pkt_cnt, pkt_err;
-- 
1.8.4.5
