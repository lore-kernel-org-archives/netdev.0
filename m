From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] bcm43xx: fix race condition in periodic work handler
Date: Tue, 26 Sep 2006 13:22:41 -0500
Message-ID: <45196FF1.mail6VJ18HN93@lwfinger.net>
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

From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>

There is a potential race condition in the periodic_work_handler routine
of bcm43xx-softmac. In addition to fixing this condition, the size of code is
reduced by moving the mutex lock outside the if.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---

Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -3164,12 +3164,12 @@ static void bcm43xx_periodic_work_handle
 	u32 savedirqs = 0;
 	int badness;
 
+	mutex_lock(&bcm->mutex);
 	badness = estimate_periodic_work_badness(bcm->periodic_state);
 	if (badness > BADNESS_LIMIT) {
 		/* Periodic work will take a long time, so we want it to
 		 * be preemtible.
 		 */
-		mutex_lock(&bcm->mutex);
 		netif_tx_disable(bcm->net_dev);
 		spin_lock_irqsave(&bcm->irq_lock, flags);
 		bcm43xx_mac_suspend(bcm);
@@ -3182,7 +3182,6 @@ static void bcm43xx_periodic_work_handle
 		/* Periodic work should take short time, so we want low
 		 * locking overhead.
 		 */
-		mutex_lock(&bcm->mutex);
 		spin_lock_irqsave(&bcm->irq_lock, flags);
 	}
