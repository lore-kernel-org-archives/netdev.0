From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH] slip: fix spinlock variant
Date: Sat, 26 Apr 2014 21:18:32 +0200
Message-ID: <535C0688.604@hartkopp.net>
References: <CA+s8ZrqFBun4bo2rJJFHb0FrV7m7PLybUVM+jjahKsdW8bdnaQ@mail.gmail.com>	<164afc991761b9eeb0eec6902814d00e@grandegger.com>	<534D0F00.7000202@hartkopp.net> <CA+s8Zrqrd_U0g1GRCDzXncgWLA_kO3Hyhjwy6Oe1S0cYohm2og@mail.gmail.com> <534D1F63.6080101@hartkopp.net> <534D270D.5060705@pengutronix.de> <534D31EF.6050107@hartkopp.net> <534D3748.6060602@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Andre Naujoks <nautsch2@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-can@vger.kernel.org,
	Alexander Stein <alexander.stein@systec-electronic.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <534D3748.6060602@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With commit cc9fa74e2a ("slip/slcan: added locking in wakeup function") a
formerly missing locking was added to slip.c and slcan.c by Andre Naujoks.

Alexander Stein contributed the fix 367525c8c2 ("can: slcan: Fix spinlock
variant") as the kernel lock debugging advised to use spin_lock_bh() instead
of just using spin_lock().

This fix has to be applied to the same code section in slip.c for the same
reason too.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

---

diff --git a/drivers/net/slip/slip.c b/drivers/net/slip/slip.c
index cc70ecf..ad4a94e 100644
--- a/drivers/net/slip/slip.c
+++ b/drivers/net/slip/slip.c
@@ -429,13 +429,13 @@ static void slip_write_wakeup(struct tty_struct *tty)
 	if (!sl || sl->magic != SLIP_MAGIC || !netif_running(sl->dev))
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
 		sl_unlock(sl);
 		return;
 	}
@@ -443,7 +443,7 @@ static void slip_write_wakeup(struct tty_struct *tty)
 	actual = tty->ops->write(tty, sl->xhead, sl->xleft);
 	sl->xleft -= actual;
 	sl->xhead += actual;
-	spin_unlock(&sl->lock);
+	spin_unlock_bh(&sl->lock);
 }
 
 static void sl_tx_timeout(struct net_device *dev)



