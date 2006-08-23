From: Jason Borg <jcborg@somanetworks.com>
Subject: [PATCH 3/5] smc911x: Fix release of an unheld spinlock
Date: Wed, 23 Aug 2006 15:16:33 -0400
Message-ID: <1156360593.15824.73.camel@borg.yyz.somanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: dustin@sensoria.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.somanetworks.com ([216.126.67.42]:64672 "EHLO
	mail.somanetworks.com") by vger.kernel.org with ESMTP
	id S965123AbWHWTQg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 15:16:36 -0400
Received: from borg.yyz.somanetworks.com ([10.11.11.252])
          (envelope-sender <jcborg@somanetworks.com>)
          by mail.somanetworks.com (qmail-ldap-1.03) with SMTP
          for <netdev@vger.kernel.org>; 23 Aug 2006 19:16:33 -0000
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes the release of a spinlock that can occur without
the spinlock having been taken.

Signed-off-by: Jason Borg <jcborg@somanetworks.com>
---

diff -uprN linux-2.6.18-rc4-orig/drivers/net/smc911x.c linux-2.6.18-rc4/drivers/net/smc911x.c
--- linux-2.6.18-rc4-orig/drivers/net/smc911x.c	2006-08-22 15:41:04.914560562 -0400
+++ linux-2.6.18-rc4/drivers/net/smc911x.c	2006-08-22 15:47:14.057064822 -0400
@@ -967,11 +967,11 @@ static void smc911x_phy_configure(void *
 	 * We should not be called if phy_type is zero.
 	 */
 	if (lp->phy_type == 0)
-		 goto smc911x_phy_configure_exit;
+		goto smc911x_phy_configure_exit_pre_lock;
 
 	if (smc911x_phy_reset(dev, phyaddr)) {
 		printk("%s: PHY reset timed out\n", dev->name);
-		goto smc911x_phy_configure_exit;
+		goto smc911x_phy_configure_exit_pre_lock;
 	}
 	spin_lock_irqsave(&lp->lock, flags);
 
@@ -1040,6 +1040,7 @@ static void smc911x_phy_configure(void *
 
 smc911x_phy_configure_exit:
 	spin_unlock_irqrestore(&lp->lock, flags);
+smc911x_phy_configure_exit_pre_lock:
 	lp->work_pending = 0;
 }
 


