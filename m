From: Oliver Neukum <oneukum@suse.de>
Subject: Re: usbnet: driver_info->stop required to stop USB interrupts?
Date: Thu, 20 Mar 2014 08:15:05 +0100
Message-ID: <1395299705.5432.12.camel@linux-fkkt.site>
References: <CANEJEGsvqkT_H4i+UZpBaWMYmgXHmpD8SZ4tU1OHzLd8gyznow@mail.gmail.com>
	 <CANEJEGv03ohVwoS0Pd1Z3az9k-C=dTzG4qE1SBL6Um97QC1Ehw@mail.gmail.com>
	 <CAODwPW_t9COeg0LWfkiqXC_yTbSNhUHX-8T95KRZHfOTSiZK1Q@mail.gmail.com>
	 <1394529263.16128.6.camel@linux-fkkt.site>
	 <CAODwPW8rQptt+jnfZ+KjpuOOpKi9ktb-y2kCYGZJo_ava1ktjg@mail.gmail.com>
	 <CAODwPW-CqigMBvwZtb+KLY5XbT+LDssPpvDZj86ej183DMiPkQ@mail.gmail.com>
	 <1395093343.3961.2.camel@linux-fkkt.site>
	 <CANEJEGuaVPNZKFiXY9CywFuqghgiQqV_sii7TE3STCNvXLQ3pQ@mail.gmail.com>
	 <CAODwPW-E-3HcXCGEmp9JpW6hU-Xt-FHwBtqeSSTDGaRPqO49Sw@mail.gmail.com>
	 <CANEJEGscbVF3gRLNtTAcRSpHGVm1iDDKEeBscXcwj2-YdkiDXA@mail.gmail.com>
	 <CANEJEGtZF30=bqkErvi1CFZLbk=PJ-p_gKf9eBGU7sWwJcrefg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Freddy Xin <freddy@asix.com.tw>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Allan Chou <allan@asix.com.tw>,
	Julius Werner <jwerner@chromium.org>
To: Grant Grundler <grundler@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:45534 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750863AbaCTIj5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Mar 2014 04:39:57 -0400
In-Reply-To: <CANEJEGtZF30=bqkErvi1CFZLbk=PJ-p_gKf9eBGU7sWwJcrefg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-03-19 at 17:58 -0700, Grant Grundler wrote:

> Oliver,
> So even with this additional change to usbnet_probe, the device is
> reporting a link but can't transmit packets.
> I've tried with three different USB dongles (AX88178, AX88772B, SMSC75xx).
> 
> In the last case, I ran "ifconfig eth0 192.168.1.100" and then tried
> to ping 192.168.1.1. "ifconfig eth0" then reports "RX packets 0 bytes
> 0" and "TX packets 0 bytes 10796". The TX packets != bytes seems odd
> and suggests (to me) that data getting discarded someplace in the
> stack. I confirmed by running tcpdump on the other end of the link
> (192.168.1.1 side) and got nothing from 192.168.1.100.
> 
> I believe the "10796" TX bytes is due to the connection manager
> "trying really hard" to get an IP address (via DHCP).
> 
> Your patch looks like it should work. But it's missing something and I
> don't have a clue what it is. Ideas?

I have an idea. Could you test this patch?

	Regards
		Oliver

>From 9a4c4a62c113c5a1abd8345418ccbf95706efdd2 Mon Sep 17 00:00:00 2001
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
 drivers/net/usb/usbnet.c   | 29 ++++++++++++++++-------------
 include/linux/usb/usbnet.h |  2 +-
 2 files changed, 17 insertions(+), 14 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index dd10d58..a8da1af 100644
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
@@ -1438,10 +1440,9 @@ static void usbnet_bh (unsigned long param)
 	clear_bit(EVENT_RX_KILL, &dev->flags);
 
 	// waiting for all pending urbs to complete?
-	if (dev->wait) {
-		if ((dev->txq.qlen + dev->rxq.qlen + dev->done.qlen) == 0) {
-			wake_up (dev->wait);
-		}
+	if (waitqueue_active(&dev->wait)) {
+		if (dev->txq.qlen + dev->rxq.qlen + dev->done.qlen == 0)
+			wake_up_all(&dev->wait);
 
 	// or are we maybe short a few urbs?
 	} else if (netif_running (dev->net) &&
@@ -1580,6 +1581,7 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	dev->driver_name = name;
 	dev->msg_enable = netif_msg_init (msg_level, NETIF_MSG_DRV
 				| NETIF_MSG_PROBE | NETIF_MSG_LINK);
+	init_waitqueue_head(&dev->wait);
 	skb_queue_head_init (&dev->rxq);
 	skb_queue_head_init (&dev->txq);
 	skb_queue_head_init (&dev->done);
@@ -1791,9 +1793,10 @@ int usbnet_resume (struct usb_interface *intf)
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
