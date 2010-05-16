From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH] r6040: fix link checking with switches
Date: Sun, 16 May 2010 14:30:56 +0200
Message-ID: <201005161430.57429.florian@openwrt.org>
Reply-To: Florian Fainelli <florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:41965 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751463Ab0EPMbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 08:31:05 -0400
Received: by wwg30 with SMTP id 30so291582wwg.19
        for <netdev@vger.kernel.org>; Sun, 16 May 2010 05:31:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current link checking logic only works for one port, which is not correct
for swiches were multiple ports can have different link status. As a result
we would only check for link status on port 1 of the switch. Move the calls
to mii_check_media in r6040_timer which will be polling a single PHY chip
correctly and assume link is up for switches.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/r6040.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 4122916..eeee379 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -400,9 +400,6 @@ static void r6040_init_mac_regs(struct net_device *dev)
 	 * we may got called by r6040_tx_timeout which has left
 	 * some unsent tx buffers */
 	iowrite16(0x01, ioaddr + MTPR);
-
-	/* Check media */
-	mii_check_media(&lp->mii_if, 1, 1);
 }
 
 static void r6040_tx_timeout(struct net_device *dev)
@@ -530,8 +527,6 @@ static int r6040_phy_mode_chk(struct net_device *dev)
 			phy_dat = 0x0000;
 	}
 
-	mii_check_media(&lp->mii_if, 0, 1);
-
 	return phy_dat;
 };
 
@@ -813,6 +808,9 @@ static void r6040_timer(unsigned long data)
 
 	/* Timer active again */
 	mod_timer(&lp->timer, round_jiffies(jiffies + HZ));
+
+	/* Check media */
+	mii_check_media(&lp->mii_if, 1, 1);
 }
 
 /* Read/set MAC address routines */
-- 
1.7.1


