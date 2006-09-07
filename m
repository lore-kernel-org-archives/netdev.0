From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: RFC/T: Possible fix for bcm43xx periodic work bug
Date: Thu, 07 Sep 2006 17:08:26 -0500
Message-ID: <4500985A.7000701@lwfinger.net>
References: <45006221.4090603@lwfinger.net> <200609072239.20074.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070503010406030504030906"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
In-Reply-To: <200609072239.20074.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
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

This is a multi-part message in MIME format.
--------------070503010406030504030906
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Michael Buesch wrote:
> 
> The real question is: Why does this patch help?
> 
> Let's explain it. We don't stop networking just for fun there.
> While executing long preemptible periodic work, we must ensure
> that the TX path into the driver is not entered. It's the same
> reason why we disable IRQs in the first place. We can't take the
> mutex in the TX path and the IRQ handler. (That are the only places
> where we can't take the mutex).
> Short: We must stop netif here.
> The question is: Why does stopping netif queue cause a watchdog
> trigger here? The maximum time it can take for the periodic
> work inside of the critical section is about 0.2sec. So the queue
> is stopped for about 0.2sec max. Why does the watchdog trigger?
> Any idea from some networking guru?
> Could synchronize_net() take over 5sec in some worst case? Why?
> Questions over questions :D
> 

To check if it takes more than 5 seconds, I restored the original network disabling code and 
increased the timeout to 30 seconds. If this works without error, I'll try to margin the time. I'm 
still running that branch every second.

Larry


Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -4147,6 +4147,7 @@ static int __devinit bcm43xx_init_one(st
  	SET_MODULE_OWNER(net_dev);
  	SET_NETDEV_DEV(net_dev, &pdev->dev);

+	net_dev->watchdog_timeo = 30 * HZ;
  	net_dev->open = bcm43xx_net_open;
  	net_dev->stop = bcm43xx_net_stop;
  	net_dev->get_stats = bcm43xx_net_get_stats;



--------------070503010406030504030906
Content-Type: text/plain;
 name="patch_periodic"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch_periodic"


Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -3207,7 +3207,7 @@ static void do_periodic_work(struct bcm4
 		bcm43xx_periodic_every15sec(bcm);
 	bcm->periodic_state = state + 1;
 
-	schedule_delayed_work(&bcm->periodic_work, HZ * 15);
+	schedule_delayed_work(&bcm->periodic_work, HZ * 1);
 }
 
 /* Estimate a "Badness" value based on the periodic work
@@ -3227,7 +3227,7 @@ static int estimate_periodic_work_badnes
 	if (state % 1 == 0) /* every 15 sec */
 		badness += 1;
 
-#define BADNESS_LIMIT	4
+#define BADNESS_LIMIT	0
 	return badness;
 }
 
@@ -4147,6 +4147,7 @@ static int __devinit bcm43xx_init_one(st
 	SET_MODULE_OWNER(net_dev);
 	SET_NETDEV_DEV(net_dev, &pdev->dev);
 
+	net_dev->watchdog_timeo = 30 * HZ;
 	net_dev->open = bcm43xx_net_open;
 	net_dev->stop = bcm43xx_net_stop;
 	net_dev->get_stats = bcm43xx_net_get_stats;


--------------070503010406030504030906
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Bcm43xx-dev mailing list
Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/bcm43xx-dev

--------------070503010406030504030906--
