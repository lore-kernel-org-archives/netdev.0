From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] bcm43xx: remove badness variable and related routine
Date: Wed, 01 Nov 2006 18:11:18 -0600
Message-ID: <454937A6.mailB1311VRT2@lwfinger.net>
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

When the periodic work function in bcm43xx was converted for voluntary preemption
to reduce latency, a new function was created to estimate the "badness" of
each step, and this quantity was used to determine if preemption should be
enabled when periodic work was undertaken. This concept was quite useful
while debugging of periodic work was in progress. Now that this routine
seems to be working correctly, it is time to simplify the code. This
patch keeps the functionality intact, but simplifies the code.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---

John,

Please apply this to wireless-2.6 for ultimate inclusion in 2.6.20. There is
no reason for it to appear in 2.6.19 as it is not a bug fix. The change is
purely janitorial.

Larry

Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -3192,55 +3192,27 @@ static void bcm43xx_periodic_every15sec(
 
 static void do_periodic_work(struct bcm43xx_private *bcm)
 {
-	unsigned int state;
-
-	state = bcm->periodic_state;
-	if (state % 8 == 0)
+	if (bcm->periodic_state % 8 == 0)
 		bcm43xx_periodic_every120sec(bcm);
-	if (state % 4 == 0)
+	if (bcm->periodic_state % 4 == 0)
 		bcm43xx_periodic_every60sec(bcm);
-	if (state % 2 == 0)
+	if (bcm->periodic_state % 2 == 0)
 		bcm43xx_periodic_every30sec(bcm);
-	if (state % 1 == 0)
-		bcm43xx_periodic_every15sec(bcm);
-	bcm->periodic_state = state + 1;
+	bcm43xx_periodic_every15sec(bcm);
 
 	schedule_delayed_work(&bcm->periodic_work, HZ * 15);
 }
 
-/* Estimate a "Badness" value based on the periodic work
- * state-machine state. "Badness" is worse (bigger), if the
- * periodic work will take longer.
- */
-static int estimate_periodic_work_badness(unsigned int state)
-{
-	int badness = 0;
-
-	if (state % 8 == 0) /* every 120 sec */
-		badness += 10;
-	if (state % 4 == 0) /* every 60 sec */
-		badness += 5;
-	if (state % 2 == 0) /* every 30 sec */
-		badness += 1;
-	if (state % 1 == 0) /* every 15 sec */
-		badness += 1;
-
-#define BADNESS_LIMIT	4
-	return badness;
-}
-
 static void bcm43xx_periodic_work_handler(void *d)
 {
 	struct bcm43xx_private *bcm = d;
 	struct net_device *net_dev = bcm->net_dev;
 	unsigned long flags;
 	u32 savedirqs = 0;
-	int badness;
 	unsigned long orig_trans_start = 0;
 
 	mutex_lock(&bcm->mutex);
-	badness = estimate_periodic_work_badness(bcm->periodic_state);
-	if (badness > BADNESS_LIMIT) {
+	if (unlikely(bcm->periodic_state % 4 == 0)) {
 		/* Periodic work will take a long time, so we want it to
 		 * be preemtible.
 		 */
@@ -3272,7 +3244,7 @@ static void bcm43xx_periodic_work_handle
 
 	do_periodic_work(bcm);
 
-	if (badness > BADNESS_LIMIT) {
+	if (unlikely(bcm->periodic_state % 4 == 0)) {
 		spin_lock_irqsave(&bcm->irq_lock, flags);
 		tasklet_enable(&bcm->isr_tasklet);
 		bcm43xx_interrupt_enable(bcm, savedirqs);
@@ -3283,6 +3255,7 @@ static void bcm43xx_periodic_work_handle
 		net_dev->trans_start = orig_trans_start;
 	}
 	mmiowb();
+	bcm->periodic_state++;
 	spin_unlock_irqrestore(&bcm->irq_lock, flags);
 	mutex_unlock(&bcm->mutex);
 }
