From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: RFC/T: Possible fix for bcm43xx periodic work bug
Date: Thu, 07 Sep 2006 13:17:05 -0500
Message-ID: <45006221.4090603@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bcm43xx-dev@lists.berlios.de, Michael Buesch <mb@bu3sch.de>,
	Stefano Brivio <st3@riseup.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:42197 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1751026AbWIGSRJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Sep 2006 14:17:09 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I think I have a fix for the bcm43xx bug that leads to NETDEV WATCHDOG tx timeouts and would like it
to get as much testing as possible as this bug affects V2.6.18-rcX. If the problem is truly
fixed, I hope to get the fix into mainline before release of the bug into the stable series.

I got the idea for the fix when I discovered that the timeout interval used for the watchdog is the 
default value of 5 seconds. Obviously, the few milliseconds used in the periodic work handler 
weren't causing us to "just miss".

To exacerbate the problem, I changed the repeat timer for periodic work from 15 to 1 sec. I also set 
BADNESS_LIMIT to 0. As a result, I was running the problem code once per second instead of once per 
minute. Now failures would occur in minutes instead of hours.

Operating from the premise that the DMA needed some time to reach the idle state after the MAC was 
suspended, I tried various delays, but nothing worked.

Then I decided to test the premise that the problem was associated with shutting down and restarting 
the network. That lead to the current patch, which has run for what is effectively 100 times longer 
than previous versions.

Larry
-------------------------------------------------------------------


Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -3244,8 +3244,6 @@ static void bcm43xx_periodic_work_handle
  		 * be preemtible.
  		 */
  		mutex_lock(&bcm->mutex);
-		netif_stop_queue(bcm->net_dev);
-		synchronize_net();
  		spin_lock_irqsave(&bcm->irq_lock, flags);
  		bcm43xx_mac_suspend(bcm);
  		if (bcm43xx_using_pio(bcm))
@@ -3270,7 +3268,6 @@ static void bcm43xx_periodic_work_handle
  		if (bcm43xx_using_pio(bcm))
  			bcm43xx_pio_thaw_txqueues(bcm);
  		bcm43xx_mac_enable(bcm);
-		netif_wake_queue(bcm->net_dev);
  	}
  	mmiowb();
  	spin_unlock_irqrestore(&bcm->irq_lock, flags);



----------------------------------------------------------
