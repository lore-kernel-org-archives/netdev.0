From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH] Fixed a number of bugs in the PHY Layer
Date: Mon, 16 Oct 2006 16:19:17 -0500 (CDT)
Message-ID: <Pine.LNX.4.61.0610161603370.6266@ld0175-tx32.am.freescale.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:5576 "EHLO
	de01egw01.freescale.net") by vger.kernel.org with ESMTP
	id S1422900AbWJPVVn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Oct 2006 17:21:43 -0400
To: Netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* genphy_update_link is now exported
* Added a fix from ncase@xes-inc.com which changes forcing so it
  only updates the link.  Otherwise, it never tries the lower
  values, since it is always overwriting the speed/duplex values
  with the current ones, rather than the intended ones.
* Fixed a bug where bringing up a PHY with no link caused it to
  timeout, and enter forcing mode.  Once in forcing mode,
  plugging in the link didn't autonegotiate.  Now the AN state
  detects the lack of link, and enters the NO_LINK state.  AN
  only times out if the link is up and AN fails
* Cleaned up the PHY_AN case, reducing one level of indentation
  for the timeout code.
---
 drivers/net/phy/phy.c        |   81 ++++++++++++++++++++----------------------
 drivers/net/phy/phy_device.c |    1 +
 2 files changed, 40 insertions(+), 42 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 3af9fcf..c81536d 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -693,60 +693,57 @@ static void phy_timer(unsigned long data
 
 			break;
 		case PHY_AN:
+			err = phy_read_status(phydev);
+
+			if (err < 0)
+				break;
+
+			/* If the link is down, give up on
+			 * negotiation for now */
+			if (!phydev->link) {
+				phydev->state = PHY_NOLINK;
+				netif_carrier_off(phydev->attached_dev);
+				phydev->adjust_link(phydev->attached_dev);
+				break;
+			}
+
 			/* Check if negotiation is done.  Break
 			 * if there's an error */
 			err = phy_aneg_done(phydev);
 			if (err < 0)
 				break;
 
-			/* If auto-negotiation is done, we change to
-			 * either RUNNING, or NOLINK */
+			/* If AN is done, we're running */
 			if (err > 0) {
-				err = phy_read_status(phydev);
+				phydev->state = PHY_RUNNING;
+				netif_carrier_on(phydev->attached_dev);
+				phydev->adjust_link(phydev->attached_dev);
+
+			} else if (0 == phydev->link_timeout--) {
+				int idx;
 
-				if (err)
+				needs_aneg = 1;
+				/* If we have the magic_aneg bit,
+				 * we try again */
+				if (phydev->drv->flags & PHY_HAS_MAGICANEG)
 					break;
 
-				if (phydev->link) {
-					phydev->state = PHY_RUNNING;
-					netif_carrier_on(phydev->attached_dev);
-				} else {
-					phydev->state = PHY_NOLINK;
-					netif_carrier_off(phydev->attached_dev);
-				}
+				/* The timer expired, and we still
+				 * don't have a setting, so we try
+				 * forcing it until we find one that
+				 * works, starting from the fastest speed,
+				 * and working our way down */
+				idx = phy_find_valid(0, phydev->supported);
 
-				phydev->adjust_link(phydev->attached_dev);
+				phydev->speed = settings[idx].speed;
+				phydev->duplex = settings[idx].duplex;
 
-			} else if (0 == phydev->link_timeout--) {
-				/* The counter expired, so either we
-				 * switch to forced mode, or the
-				 * magic_aneg bit exists, and we try aneg
-				 * again */
-				if (!(phydev->drv->flags & PHY_HAS_MAGICANEG)) {
-					int idx;
-
-					/* We'll start from the
-					 * fastest speed, and work
-					 * our way down */
-					idx = phy_find_valid(0,
-							phydev->supported);
-
-					phydev->speed = settings[idx].speed;
-					phydev->duplex = settings[idx].duplex;
-					
-					phydev->autoneg = AUTONEG_DISABLE;
-					phydev->state = PHY_FORCING;
-					phydev->link_timeout =
-						PHY_FORCE_TIMEOUT;
-
-					pr_info("Trying %d/%s\n",
-							phydev->speed,
-							DUPLEX_FULL ==
-							phydev->duplex ?
-							"FULL" : "HALF");
-				}
+				phydev->autoneg = AUTONEG_DISABLE;
 
-				needs_aneg = 1;
+				pr_info("Trying %d/%s\n", phydev->speed,
+						DUPLEX_FULL ==
+						phydev->duplex ?
+						"FULL" : "HALF");
 			}
 			break;
 		case PHY_NOLINK:
@@ -762,7 +759,7 @@ static void phy_timer(unsigned long data
 			}
 			break;
 		case PHY_FORCING:
-			err = phy_read_status(phydev);
+			err = genphy_update_link(phydev);
 
 			if (err)
 				break;
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 3bbd5e7..2a08b2b 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -427,6 +427,7 @@ int genphy_update_link(struct phy_device
 
 	return 0;
 }
+EXPORT_SYMBOL(genphy_update_link);
 
 /* genphy_read_status
  *
-- 
1.4.2.3

