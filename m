From: Kirill Kapranov <kapranoff@inbox.ru>
Subject: Re3: [PATCH] NET/PHY: Eliminate the algorithm of forced ethernet
 speed reduction
Date: Fri, 15 Feb 2013 14:50:59 +0400
Message-ID: <1360925459.4709.23.camel@kkk.nita.ru>
Reply-To: kapranoff@inbox.ru
Mime-Version: 1.0
Content-Type: text/plain; charset="KOI8-R"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NET/PHY: Eliminate the forced speed reduction algorithm.
In case of the fixed speed set up for NIC 
	(e.g. ethtool -s eth0 autoneg off speed 100 duplex full)
	with ethernet cable plugged off, mentioned algorithm 
	slows down NIC speed, so the further "hooking up" gives 
	no result. AFAIK, this behaviour is not RFCs' recommended.
Tested at 2.6.38.7, applicable up to for 3.0.4. 
Signed-off-by: Kirill Kapranov <kkk@nita.ru>,<kapranoff@inbox.ru>
 --- linux/drivers/net/phy/phy.c.orig	2011-05-22 02:13:59.000000000 +0400
+++ linux/drivers/net/phy/phy.c	2012-04-28 12:49:37.000000000 +0400
@@ -457,34 +457,6 @@ void phy_stop_machine(struct phy_device
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
-	pr_info("Trying %d/%s\n", phydev->speed,
-			DUPLEX_FULL == phydev->duplex ?
-			"FULL" : "HALF");
-}
-
-
-/**
  * phy_error - enter HALTED state for this PHY device
  * @phydev: target phy_device struct
  *
@@ -814,30 +786,12 @@ void phy_state_machine(struct work_struc
 				phydev->adjust_link(phydev->attached_dev);
 
 			} else if (0 == phydev->link_timeout--) {
-				int idx;
 
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
-				pr_info("Trying %d/%s\n", phydev->speed,
-						DUPLEX_FULL ==
-						phydev->duplex ?
-						"FULL" : "HALF");
 			}
 			break;
 		case PHY_NOLINK:
@@ -863,7 +817,6 @@ void phy_state_machine(struct work_struc
 				netif_carrier_on(phydev->attached_dev);
 			} else {
 				if (0 == phydev->link_timeout--) {
-					phy_force_reduction(phydev);
 					needs_aneg = 1;
 				}
 			}
