From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] bcm43xx: Fix low-traffic netdev watchdog TX timeouts
Date: Sat, 28 Oct 2006 17:52:34 -0500
Message-ID: <4543DF32.mailJIW1UTV6A@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de, Stefano Brivio <st3@riseup.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms-smtp-01.rdc-kc.rr.com ([24.94.166.115]:36343 "EHLO
	ms-smtp-01.rdc-kc.rr.com") by vger.kernel.org with ESMTP
	id S932111AbWJ1Www (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Oct 2006 18:52:52 -0400
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Buesch <mb@bu3sch.de>

This fixes a netdev watchdog timeout problem.
The software needs to call netif_tx_disable before running the
hardware calibration code. The problem condition can be shown by the
following timegraph.

|---5secs - ~10 jiffies time---|---|OOPS
^                              ^
last real TX                   periodic work stops netif

At OOPS, the following happens:
The watchdog timer triggers, because the timeout of 5secs
is over. The watchdog first checks for stopped TX.
_Usually_ TX is only stopped from the TX handler to indicate
a full TX queue. But this is different. We need to stop TX here,
regardless of the TX queue state. So the watchdog recognizes
the stopped device and assumes it is stopped due to full
TX queues (Which is a _wrong_ assumption in this case). It then
tests how far the last TX has been in the past. If it's more than
5secs (which is the case for low or no traffic), it will fire
a TX timeout.

Signed-off-by: Michael Buesch <mb@bu3sch.de>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

John,

Please apply this patch to wireless-2.6, and push it upstream to 2.6.19.
It seems to have cured _all_ remaining cases of watchdog timeouts. This
patch replaces the one sent earlier by Michael under the subject
"Re: Fwd: [PATCH] bcm43xx: (hopefully) fix watchdog timeouts." BTW, that
simplified version has been sent to -stable. It isn't quite as good as this
one, but fixes most timeout cases and is more appropriate for stable.

Larry


Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-10-27 16:34:08.000000000 +0200
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-10-28 16:32:36.000000000 +0200
@@ -3232,9 +3232,11 @@ static int estimate_periodic_work_badnes
 static void bcm43xx_periodic_work_handler(void *d)
 {
 	struct bcm43xx_private *bcm = d;
+	struct net_device *net_dev = bcm->net_dev;
 	unsigned long flags;
 	u32 savedirqs = 0;
 	int badness;
+	unsigned long orig_trans_start = 0;
 
 	mutex_lock(&bcm->mutex);
 	badness = estimate_periodic_work_badness(bcm->periodic_state);
@@ -3242,7 +3244,18 @@ static void bcm43xx_periodic_work_handle
 		/* Periodic work will take a long time, so we want it to
 		 * be preemtible.
 		 */
-		netif_tx_disable(bcm->net_dev);
+
+		netif_tx_lock_bh(net_dev);
+		/* We must fake a started transmission here, as we are going to
+		 * disable TX. If we wouldn't fake a TX, it would be possible to
+		 * trigger the netdev watchdog, if the last real TX is already
+		 * some time on the past (slightly less than 5secs)
+		 */
+		orig_trans_start = net_dev->trans_start;
+		net_dev->trans_start = jiffies;
+		netif_stop_queue(net_dev);
+		netif_tx_unlock_bh(net_dev);
+
 		spin_lock_irqsave(&bcm->irq_lock, flags);
 		bcm43xx_mac_suspend(bcm);
 		if (bcm43xx_using_pio(bcm))
@@ -3267,6 +3280,7 @@ static void bcm43xx_periodic_work_handle
 			bcm43xx_pio_thaw_txqueues(bcm);
 		bcm43xx_mac_enable(bcm);
 		netif_wake_queue(bcm->net_dev);
+		net_dev->trans_start = orig_trans_start;
 	}
 	mmiowb();
 	spin_unlock_irqrestore(&bcm->irq_lock, flags);
 
---

