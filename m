From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] bcm43xx: fix bcm43xx lockups and netdev timeouts in
	2.6.18-rcX
Date: Thu, 14 Sep 2006 09:21:54 -0500
Message-ID: <45096582.mailOEU1TCRGO@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

In 2.6.18-rc7, the section that prepares for preemptible periodic work
has two bugs. The first is due to an improper locking sequence that leads
to frozen systems. The second causes netdev watchdog timeouts. Both
are fixed.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---

John,

This patch has been taken against 2.6.18-rc7. It changes more lines
than would be absolutely necessary to affect the fix; however, it
ends up with this section looking exactly like the current code (with
pending patches) that is in wireless-2.6. That way, it should not
mess up any git trees.

Larry

Index: linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -3182,39 +3182,37 @@ static void bcm43xx_periodic_work_handle
 		/* Periodic work will take a long time, so we want it to
 		 * be preemtible.
 		 */
-		bcm43xx_lock_irqonly(bcm, flags);
-		netif_stop_queue(bcm->net_dev);
+		mutex_lock(&bcm->mutex);
+		netif_tx_disable(bcm->net_dev);
+		spin_lock_irqsave(&bcm->irq_lock, flags);
+		bcm43xx_mac_suspend(bcm);
 		if (bcm43xx_using_pio(bcm))
 			bcm43xx_pio_freeze_txqueues(bcm);
 		savedirqs = bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
-		bcm43xx_unlock_irqonly(bcm, flags);
-		bcm43xx_lock_noirq(bcm);
+		spin_unlock_irqrestore(&bcm->irq_lock, flags);
 		bcm43xx_synchronize_irq(bcm);
 	} else {
 		/* Periodic work should take short time, so we want low
 		 * locking overhead.
 		 */
-		bcm43xx_lock_irqsafe(bcm, flags);
+		mutex_lock(&bcm->mutex);
+		spin_lock_irqsave(&bcm->irq_lock, flags);
 	}
 
 	do_periodic_work(bcm);
 
 	if (badness > BADNESS_LIMIT) {
-		bcm43xx_lock_irqonly(bcm, flags);
-		if (likely(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED)) {
-			tasklet_enable(&bcm->isr_tasklet);
-			bcm43xx_interrupt_enable(bcm, savedirqs);
-			if (bcm43xx_using_pio(bcm))
-				bcm43xx_pio_thaw_txqueues(bcm);
-		}
+		spin_lock_irqsave(&bcm->irq_lock, flags);
+		tasklet_enable(&bcm->isr_tasklet);
+		bcm43xx_interrupt_enable(bcm, savedirqs);
+		if (bcm43xx_using_pio(bcm))
+			bcm43xx_pio_thaw_txqueues(bcm);
+		bcm43xx_mac_enable(bcm);
 		netif_wake_queue(bcm->net_dev);
-		mmiowb();
-		bcm43xx_unlock_irqonly(bcm, flags);
-		bcm43xx_unlock_noirq(bcm);
-	} else {
-		mmiowb();
-		bcm43xx_unlock_irqsafe(bcm, flags);
 	}
+	mmiowb();
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 }
 
 static void bcm43xx_periodic_tasks_delete(struct bcm43xx_private *bcm)
