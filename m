From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] fix for system lockups in 2.6.18-rcX caused by bcm43xx
Date: Fri, 08 Sep 2006 20:47:54 -0500
Message-ID: <45021D4A.6040805@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Michael Buesch <mb@bu3sch.de>,
	Stefano Brivio <st3@riseup.net>,
	Broadcom Linux <bcm43xx-dev@lists.berlios.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:62716 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1751307AbWIIBsM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Sep 2006 21:48:12 -0400
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John,

PLease send this upstream for inclusion in 2.6.18, if possible. This patch will not work for
wireless-2.6. That patch will be sent to you soon.

Larry

=============================================


This patch fixes a bug in the bcm43xx driver in 2.6.18-rcX that hangs the machine due to improper
locking. Between 2.6.17 and .18, longer portions of certain periodic work were made preemptible to
improve latency, which is how this bug was introduced. It happens relatively infrequently - every 6
- 10 hours, but when it does, the power button is the only possible recovery.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>

==================================


Index: linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -3182,19 +3182,21 @@ static void bcm43xx_periodic_work_handle
  		/* Periodic work will take a long time, so we want it to
  		 * be preemtible.
  		 */
-		bcm43xx_lock_irqonly(bcm, flags);
+		bcm43xx_lock_noirq(bcm);
  		netif_stop_queue(bcm->net_dev);
+		bcm43xx_lock_irqonly(bcm, flags);
+		bcm43xx_mac_suspend(bcm);
  		if (bcm43xx_using_pio(bcm))
  			bcm43xx_pio_freeze_txqueues(bcm);
  		savedirqs = bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
  		bcm43xx_unlock_irqonly(bcm, flags);
-		bcm43xx_lock_noirq(bcm);
  		bcm43xx_synchronize_irq(bcm);
  	} else {
  		/* Periodic work should take short time, so we want low
  		 * locking overhead.
  		 */
-		bcm43xx_lock_irqsafe(bcm, flags);
+		bcm43xx_lock_noirq(bcm);
+		bcm43xx_lock_irqonly(bcm, flags);
  	}

  	do_periodic_work(bcm);
@@ -3206,6 +3208,7 @@ static void bcm43xx_periodic_work_handle
  			bcm43xx_interrupt_enable(bcm, savedirqs);
  			if (bcm43xx_using_pio(bcm))
  				bcm43xx_pio_thaw_txqueues(bcm);
+			bcm43xx_mac_enable(bcm);
  		}
  		netif_wake_queue(bcm->net_dev);
  		mmiowb();
@@ -3213,7 +3216,8 @@ static void bcm43xx_periodic_work_handle
  		bcm43xx_unlock_noirq(bcm);
  	} else {
  		mmiowb();
-		bcm43xx_unlock_irqsafe(bcm, flags);
+		bcm43xx_unlock_irqonly(bcm, flags);
+		bcm43xx_unlock_noirq(bcm);
  	}
  }


