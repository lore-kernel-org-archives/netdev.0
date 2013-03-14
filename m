From: Kirill Kapranov <kapranoff@inbox.ru>
Subject: [PATCH] phy: Elimination the forced speed reduction algorithm.
Date: Thu, 14 Mar 2013 14:40:52 +0400
Message-ID: <1363257652-8255-1-git-send-email-kapranoff@inbox.ru>
Cc: davem@davemloft.net, bhutchings@solarflare.com,
	peppe.cavallaro@st.com, joe@perches.com, bruce.w.allan@intel.com,
	linux-kernel@vger.kernel.org, Kirill Kapranov <kapranoff@inbox.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp8.mail.ru ([94.100.176.53]:48041 "EHLO smtp8.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757422Ab3CNKl3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Mar 2013 06:41:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of fixed speed set up for a NIC (e.g. ethtool -s eth0 autoneg off speed
100 duplex full) with an ethernet cable plugged off, the mentioned algorithm
slows down a NIC speed, so further cable hook-up leads to nonoperable link state.

Signed-off-by: Kirill Kapranov <kapranoff@inbox.ru>
---
 drivers/net/phy/phy.c |   47 -----------------------------------------------
 1 files changed, 0 insertions(+), 47 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index ef9ea92..0e40170 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -463,33 +463,6 @@ void phy_stop_machine(struct phy_device *phydev)
 }
 
 /**
- * phy_force_reduction - reduce PHY speed/duplex settings by one step
- * @phydev: target phy_device struct
- *
- * Description: Reduces the speed/duplex settings by one notch,
- *   in this order--
- *   1000/FULL, 1000/HALF, 100/FULL, 100/HALF, 10/FULL, 10/HALF.
- *   The function bottoms out at 10/HALF.
- */
-static void phy_force_reduction(struct phy_device *phydev)
-{
-	int idx;
-
-	idx = phy_find_setting(phydev->speed, phydev->duplex);
-	
-	idx++;
-
-	idx = phy_find_valid(idx, phydev->supported);
-
-	phydev->speed = settings[idx].speed;
-	phydev->duplex = settings[idx].duplex;
-
-	pr_info("Trying %d/%s\n",
-		phydev->speed, DUPLEX_FULL == phydev->duplex ? "FULL" : "HALF");
-}
-
-
-/**
  * phy_error - enter HALTED state for this PHY device
  * @phydev: target phy_device struct
  *
@@ -818,30 +791,11 @@ void phy_state_machine(struct work_struct *work)
 				phydev->adjust_link(phydev->attached_dev);
 
 			} else if (0 == phydev->link_timeout--) {
-				int idx;
-
 				needs_aneg = 1;
 				/* If we have the magic_aneg bit,
 				 * we try again */
 				if (phydev->drv->flags & PHY_HAS_MAGICANEG)
 					break;
-
-				/* The timer expired, and we still
-				 * don't have a setting, so we try
-				 * forcing it until we find one that
-				 * works, starting from the fastest speed,
-				 * and working our way down */
-				idx = phy_find_valid(0, phydev->supported);
-
-				phydev->speed = settings[idx].speed;
-				phydev->duplex = settings[idx].duplex;
-
-				phydev->autoneg = AUTONEG_DISABLE;
-
-				pr_info("Trying %d/%s\n",
-					phydev->speed,
-					DUPLEX_FULL == phydev->duplex ?
-					"FULL" : "HALF");
 			}
 			break;
 		case PHY_NOLINK:
@@ -867,7 +821,6 @@ void phy_state_machine(struct work_struct *work)
 				netif_carrier_on(phydev->attached_dev);
 			} else {
 				if (0 == phydev->link_timeout--) {
-					phy_force_reduction(phydev);
 					needs_aneg = 1;
 				}
 			}
-- 
1.7.2.5
