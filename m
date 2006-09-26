From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/8] sky2: gigabit full duplex autonegotiate
Date: Tue, 26 Sep 2006 16:17:07 -0700
Message-ID: <20060926161707.10ce4edc@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:25267 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964825AbWIZXRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 19:17:16 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id k8QNHBnW026348
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 26 Sep 2006 16:17:13 -0700
Received: from freekitty (freekitty.pdx.osdl.net [10.8.0.54])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with ESMTP id k8QNHBSf006566
	for <netdev@vger.kernel.org>; Tue, 26 Sep 2006 16:17:11 -0700
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(vger gagged on the quilt version of these patches)

Look at the registers correctly, when doing gigabit full duplex.
Need to look for link partner result.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/sky2.c |   28 +++++++++++++++++++---------
 1 file changed, 19 insertions(+), 9 deletions(-)

--- netdev-2.6.orig/drivers/net/sky2.c	2006-09-25 10:54:17.000000000 -0700
+++ netdev-2.6/drivers/net/sky2.c	2006-09-25 10:58:27.000000000 -0700
@@ -1624,22 +1624,33 @@
 		return -1;
 	}
 
-	if (hw->chip_id != CHIP_ID_YUKON_FE &&
-	    gm_phy_read(hw, port, PHY_MARV_1000T_STAT) & PHY_B_1000S_MSF) {
-		printk(KERN_ERR PFX "%s: master/slave fault",
-		       sky2->netdev->name);
-		return -1;
-	}
-
 	if (!(aux & PHY_M_PS_SPDUP_RES)) {
 		printk(KERN_ERR PFX "%s: speed/duplex mismatch",
 		       sky2->netdev->name);
 		return -1;
 	}
 
-	sky2->duplex = (aux & PHY_M_PS_FULL_DUP) ? DUPLEX_FULL : DUPLEX_HALF;
-
 	sky2->speed = sky2_phy_speed(hw, aux);
+	if (sky2->speed == SPEED_1000) {
+		u16 ctl2 = gm_phy_read(hw, port, PHY_MARV_1000T_CTRL);
+		u16 lpa2 = gm_phy_read(hw, port, PHY_MARV_1000T_STAT);
+		if (lpa2  & PHY_B_1000S_MSF) {
+			printk(KERN_ERR PFX "%s: master/slave fault",
+			       sky2->netdev->name);
+			return -1;
+		}
+
+		if ((ctl2 & PHY_M_1000C_AFD) && (lpa2 & PHY_B_1000S_LP_FD))
+			sky2->duplex = DUPLEX_FULL;
+		else
+			sky2->duplex = DUPLEX_HALF;
+	} else {
+		u16 adv = gm_phy_read(hw, port, PHY_MARV_AUNE_ADV);
+		if ((aux & adv) & PHY_AN_FULL)
+			sky2->duplex = DUPLEX_FULL;
+		else
+			sky2->duplex = DUPLEX_HALF;
+	}
 
 	/* Pause bits are offset (9..8) */
 	if (hw->chip_id == CHIP_ID_YUKON_XL || hw->chip_id == CHIP_ID_YUKON_EC_U)
