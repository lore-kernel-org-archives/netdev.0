From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 8/8] sky2: hold spinlock around phy_power_down
Date: Thu, 06 Aug 2009 09:12:21 -0700
Message-ID: <20090806161233.085917754@vyatta.com>
References: <20090806161213.148382653@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:38262 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753957AbZHFQol (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Aug 2009 12:44:41 -0400
Content-Disposition: inline; filename=sky2-phy-lock.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid any possible problems with accessing PHY registers on shutdown.
This is a purely theoretical issue and is not related to any of the
outstanding bug reports. Since receiver and transmitter are already
shutdown and phy interrupts for this device are already disabled, 
there should already be enough protection.

Suggested-by: Mike McCormack <mikem@ring3k.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/sky2.c	2009-08-06 08:40:56.097359280 -0700
+++ b/drivers/net/sky2.c	2009-08-06 08:41:38.949377326 -0700
@@ -1883,7 +1883,9 @@ static int sky2_down(struct net_device *
 	synchronize_irq(hw->pdev->irq);
 	napi_synchronize(&hw->napi);
 
+	spin_lock_bh(&sky2->phy_lock);
 	sky2_phy_power_down(hw, port);
+	spin_unlock_bh(&sky2->phy_lock);
 
 	/* turn off LED's */
 	sky2_write16(hw, B0_Y2LED, LED_STAT_OFF);

-- 

