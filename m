From: =?utf-8?q?Hans-J=C3=BCrgen_Koch?= <hjk@linutronix.de>
Subject: [PATCH] Fix a lock problem in generic phy code
Date: Fri, 31 Aug 2007 14:30:08 +0200
Message-ID: <200708311430.09590.hjk@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	afleming@freescale.com
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.osadl.org ([213.239.205.134]:37377 "EHLO mail.tglx.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S964798AbXHaMaM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 08:30:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lock debugging finds a problem in phy.c and phy_device.c,
this patch fixes it. Tested on an AT91SAM9263-EK board, 
kernel 2.6.23-rc4.

Signed-off-by: Hans J. Koch <hjk@linutronix.de>
---

Index: linux-2.6.23-rc/drivers/net/phy/phy_device.c
===================================================================
--- linux-2.6.23-rc.orig/drivers/net/phy/phy_device.c	2007-08-31 
14:07:47.000000000 +0200
+++ linux-2.6.23-rc/drivers/net/phy/phy_device.c	2007-08-31 14:08:22.000000000 
+0200
@@ -644,7 +644,7 @@
 	if (!(phydrv->flags & PHY_HAS_INTERRUPT))
 		phydev->irq = PHY_POLL;
 
-	spin_lock(&phydev->lock);
+	spin_lock_bh(&phydev->lock);
 
 	/* Start out supporting everything. Eventually,
 	 * a controller will attach, and may modify one
@@ -658,7 +658,7 @@
 	if (phydev->drv->probe)
 		err = phydev->drv->probe(phydev);
 
-	spin_unlock(&phydev->lock);
+	spin_unlock_bh(&phydev->lock);
 
 	return err;
 
Index: linux-2.6.23-rc/drivers/net/phy/phy.c
===================================================================
--- linux-2.6.23-rc.orig/drivers/net/phy/phy.c	2007-08-31 14:15:20.000000000 
+0200
+++ linux-2.6.23-rc/drivers/net/phy/phy.c	2007-08-31 14:15:43.000000000 +0200
@@ -755,7 +755,7 @@
  */
 void phy_start(struct phy_device *phydev)
 {
-	spin_lock(&phydev->lock);
+	spin_lock_bh(&phydev->lock);
 
 	switch (phydev->state) {
 		case PHY_STARTING:
@@ -769,7 +769,7 @@
 		default:
 			break;
 	}
-	spin_unlock(&phydev->lock);
+	spin_unlock_bh(&phydev->lock);
 }
 EXPORT_SYMBOL(phy_stop);
 EXPORT_SYMBOL(phy_start);
