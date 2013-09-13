From: Andre Naujoks <nautsch2@gmail.com>
Subject: [PATCH net 1/3] slip/slcan: added locking in wakeup function
Date: Fri, 13 Sep 2013 19:37:11 +0200
Message-ID: <1379093833-4949-2-git-send-email-nautsch2@gmail.com>
References: <1379093833-4949-1-git-send-email-nautsch2@gmail.com>
To: davem@davemloft.net, Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f51.google.com ([209.85.214.51]:36755 "EHLO
	mail-bk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751733Ab3IMRhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 13:37:23 -0400
In-Reply-To: <1379093833-4949-1-git-send-email-nautsch2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The locking is needed, since the the internal buffer for the CAN frames is
changed during the wakeup call. This could cause buffer inconsistencies
under high loads, especially for the outgoing short CAN packet skbuffs.

The needed locks led to deadlocks before commit
"5ede52538ee2b2202d9dff5b06c33bfde421e6e4 tty: Remove extra wakeup from pty
write() path", which removed the direct callback to the wakeup function from the
tty layer.

As slcan.c is based on slip.c the issue in the original code is fixed, too.

Signed-off-by: Andre Naujoks <nautsch2@gmail.com>
---
 drivers/net/can/slcan.c | 3 +++
 drivers/net/slip/slip.c | 3 +++
 2 files changed, 6 insertions(+)

diff --git a/drivers/net/can/slcan.c b/drivers/net/can/slcan.c
index 874188b..d571e2e 100644
--- a/drivers/net/can/slcan.c
+++ b/drivers/net/can/slcan.c
@@ -286,11 +286,13 @@ static void slcan_write_wakeup(struct tty_struct *tty)
 	if (!sl || sl->magic != SLCAN_MAGIC || !netif_running(sl->dev))
 		return;
 
+	spin_lock(&sl->lock);
 	if (sl->xleft <= 0)  {
 		/* Now serial buffer is almost free & we can start
 		 * transmission of another packet */
 		sl->dev->stats.tx_packets++;
 		clear_bit(TTY_DO_WRITE_WAKEUP, &tty->flags);
+		spin_unlock(&sl->lock);
 		netif_wake_queue(sl->dev);
 		return;
 	}
@@ -298,6 +300,7 @@ static void slcan_write_wakeup(struct tty_struct *tty)
 	actual = tty->ops->write(tty, sl->xhead, sl->xleft);
 	sl->xleft -= actual;
 	sl->xhead += actual;
+	spin_unlock(&sl->lock);
 }
 
 /* Send a can_frame to a TTY queue. */
diff --git a/drivers/net/slip/slip.c b/drivers/net/slip/slip.c
index a34d6bf..cc70ecf 100644
--- a/drivers/net/slip/slip.c
+++ b/drivers/net/slip/slip.c
@@ -429,11 +429,13 @@ static void slip_write_wakeup(struct tty_struct *tty)
 	if (!sl || sl->magic != SLIP_MAGIC || !netif_running(sl->dev))
 		return;
 
+	spin_lock(&sl->lock);
 	if (sl->xleft <= 0)  {
 		/* Now serial buffer is almost free & we can start
 		 * transmission of another packet */
 		sl->dev->stats.tx_packets++;
 		clear_bit(TTY_DO_WRITE_WAKEUP, &tty->flags);
+		spin_unlock(&sl->lock);
 		sl_unlock(sl);
 		return;
 	}
@@ -441,6 +443,7 @@ static void slip_write_wakeup(struct tty_struct *tty)
 	actual = tty->ops->write(tty, sl->xhead, sl->xleft);
 	sl->xleft -= actual;
 	sl->xhead += actual;
+	spin_unlock(&sl->lock);
 }
 
 static void sl_tx_timeout(struct net_device *dev)
-- 
1.8.4.rc3
