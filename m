From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [RFC] A change in periodic work scheduling in bcm43xx
Date: Tue, 05 Sep 2006 12:58:00 -0500
Message-ID: <44FDBAA8.6090709@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
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

Michael,

Based on user reports and my own experiences, the current problems with NETDEV WATCHDOG tx timeouts, 
and the device just falling over do not happen when periodic work is not preemptible. These problems 
seem to affect BCM4306 rev 2 & 3 chips. Since I changed BADNESS_LIMIT to 20 to disable preemption 
during periodic work, my device has stayed up continuously for more than 18 hours. Previously, the 
longest time between failures was less than 6 hours, and sometimes as short as 10 minutes.

As you know, the present scheme for periodic work scheduling for bcm43xx in both wireless-2.6 and 
wireless-dev runs all 4 periodic tasks on certain ticks of the 15-second clock. Using your values of 
"badness" of 1, 1, 5, and 10 for the 15, 30, 60, and 120 second periodic tasks, respectively, the 
badness repeat cycle is ..., 1, 2, 1, 7, 1, 2, 1, 17, ...

I propose that we reduce the size of the spike in badness by shifting the 120 second task from a 
clock value of 8n to 8n+7, and the 60 second task from 4n to 4n+1. This way no more than 2 of the 
periodic tasks will be run in any clock period, and the badness repeat cycle becomes ..., 6, 2, 1, 
2, 6, 2, 11, 2, .... The tasks are run with the same periodicity as before, just a little more 
asynchronously. I recall that they were completely asynchronous in early versions of this driver.

Until we can locate and fix the problem that occurs during preemption, should we consider setting 
BADNESS_LIMIT to 20 in the wireless-2.6 kernels? For those of us whose cards have the problem, it 
certainly makes the device a lot more usable.

Larry

The patches to implement the scheduling change are as follows:

Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -3195,9 +3195,9 @@ static void do_periodic_work(struct bcm4
  	unsigned int state;

  	state = bcm->periodic_state;
-	if (state % 8 == 0)
+	if (state % 8 == 7)
  		bcm43xx_periodic_every120sec(bcm);
-	if (state % 4 == 0)
+	if (state % 4 == 1)
  		bcm43xx_periodic_every60sec(bcm);
  	if (state % 2 == 0)
  		bcm43xx_periodic_every30sec(bcm);
@@ -3216,8 +3216,8 @@ static int estimate_periodic_work_badnes
  {
  	int badness = 0;

-	if (state % 8 == 0) /* every 120 sec */
+	if (state % 8 == 7) /* every 120 sec */
  		badness += 10;
-	if (state % 4 == 0) /* every 60 sec */
+	if (state % 4 == 1) /* every 60 sec */
  		badness += 5;
  	if (state % 2 == 0) /* every 30 sec */
