From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 3/3] usbnet: handle remote wakeup asap
Date: Wed, 13 Jun 2012 12:20:17 +0800
Message-ID: <1339561217-18151-4-git-send-email-ming.lei@canonical.com>
References: <1339561217-18151-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>,
	stable@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:35728 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750894Ab2FMEVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 00:21:06 -0400
In-Reply-To: <1339561217-18151-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If usbnet is resumed by remote wakeup, generally there are
some packets comming to be handled, so allocate and submit
rx URBs in usbnet_resume to avoid delays introduced by tasklet.
Otherwise, usbnet may have been runtime suspended before the
usbnet_bh is executed to schedule Rx URBs.

Without the patch, usbnet can't recieve any packets from peer
in runtime suspend state if runtime PM is enabled and
autosuspend_delay is set as zero.

Cc: stable@vger.kernel.org
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/usbnet.c |   42 ++++++++++++++++++++++++++----------------
 1 file changed, 26 insertions(+), 16 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 9bfa775..4911efa 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1201,6 +1201,21 @@ deferred:
 }
 EXPORT_SYMBOL_GPL(usbnet_start_xmit);
 
+static void rx_alloc_submit(struct usbnet *dev, gfp_t flags)
+{
+	struct urb	*urb;
+	int		i;
+
+	/* don't refill the queue all at once */
+	for (i = 0; i < 10 && dev->rxq.qlen < RX_QLEN(dev); i++) {
+		urb = usb_alloc_urb(0, GFP_ATOMIC);
+		if (urb != NULL) {
+			if (rx_submit(dev, urb, flags) == -ENOLINK)
+				return;
+		}
+	}
+}
+
 /*-------------------------------------------------------------------------*/
 
 // tasklet (work deferred from completions, in_irq) or timer
@@ -1240,26 +1255,14 @@ static void usbnet_bh (unsigned long param)
 		   !timer_pending (&dev->delay) &&
 		   !test_bit (EVENT_RX_HALT, &dev->flags)) {
 		int	temp = dev->rxq.qlen;
-		int	qlen = RX_QLEN (dev);
-
-		if (temp < qlen) {
-			struct urb	*urb;
-			int		i;
-
-			// don't refill the queue all at once
-			for (i = 0; i < 10 && dev->rxq.qlen < qlen; i++) {
-				urb = usb_alloc_urb (0, GFP_ATOMIC);
-				if (urb != NULL) {
-					if (rx_submit (dev, urb, GFP_ATOMIC) ==
-					    -ENOLINK)
-						return;
-				}
-			}
+
+		if (temp < RX_QLEN(dev)) {
+			rx_alloc_submit(dev, GFP_ATOMIC);
 			if (temp != dev->rxq.qlen)
 				netif_dbg(dev, link, dev->net,
 					  "rxqlen %d --> %d\n",
 					  temp, dev->rxq.qlen);
-			if (dev->rxq.qlen < qlen)
+			if (dev->rxq.qlen < RX_QLEN(dev))
 				tasklet_schedule (&dev->bh);
 		}
 		if (dev->txq.qlen < TX_QLEN (dev))
@@ -1565,6 +1568,13 @@ int usbnet_resume (struct usb_interface *intf)
 		spin_unlock_irq(&dev->txq.lock);
 
 		if (test_bit(EVENT_DEV_OPEN, &dev->flags)) {
+			/* handle remote wakeup ASAP */
+			if (!dev->wait &&
+				netif_device_present(dev->net) &&
+				!timer_pending(&dev->delay) &&
+				!test_bit(EVENT_RX_HALT, &dev->flags))
+					rx_alloc_submit(dev, GFP_KERNEL);
+
 			if (!(dev->txq.qlen >= TX_QLEN(dev)))
 				netif_tx_wake_all_queues(dev->net);
 			tasklet_schedule (&dev->bh);
-- 
1.7.9.5
