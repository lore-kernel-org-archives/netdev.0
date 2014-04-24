From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 26/26] can: slcan: Fix spinlock variant
Date: Fri, 25 Apr 2014 00:00:29 +0200
Message-ID: <1398376829-6771-27-git-send-email-mkl@pengutronix.de>
References: <1398376829-6771-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	Alexander Stein <alexander.stein@systec-electronic.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1398376829-6771-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Stein <alexander.stein@systec-electronic.com>

slc_xmit is called within softirq context and locks sl->lock, but
slcan_write_wakeup is not softirq context, so we need to use
spin_[un]lock_bh!
Detected using kernel lock debugging mechanism.

Signed-off-by: Alexander Stein <alexander.stein@systec-electronic.com>
Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/slcan.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/slcan.c b/drivers/net/can/slcan.c
index f5b16e0..dcf9196 100644
--- a/drivers/net/can/slcan.c
+++ b/drivers/net/can/slcan.c
@@ -322,13 +322,13 @@ static void slcan_write_wakeup(struct tty_struct *tty)
 	if (!sl || sl->magic != SLCAN_MAGIC || !netif_running(sl->dev))
 		return;
 
-	spin_lock(&sl->lock);
+	spin_lock_bh(&sl->lock);
 	if (sl->xleft <= 0)  {
 		/* Now serial buffer is almost free & we can start
 		 * transmission of another packet */
 		sl->dev->stats.tx_packets++;
 		clear_bit(TTY_DO_WRITE_WAKEUP, &tty->flags);
-		spin_unlock(&sl->lock);
+		spin_unlock_bh(&sl->lock);
 		netif_wake_queue(sl->dev);
 		return;
 	}
@@ -336,7 +336,7 @@ static void slcan_write_wakeup(struct tty_struct *tty)
 	actual = tty->ops->write(tty, sl->xhead, sl->xleft);
 	sl->xleft -= actual;
 	sl->xhead += actual;
-	spin_unlock(&sl->lock);
+	spin_unlock_bh(&sl->lock);
 }
 
 /* Send a can_frame to a TTY queue. */
-- 
1.9.0.279.gdc9e3eb

