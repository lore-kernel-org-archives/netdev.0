From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH] RFC: Broadcom PHY forcing fix
Date: Fri, 26 Jan 2007 14:36:29 +0000 (GMT)
Message-ID: <Pine.LNX.4.64N.0701261426040.15582@blysk.ds.pg.gda.pl>
References: <Pine.LNX.4.64.0701251718270.4944@gate.crashing.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pollux.ds.pg.gda.pl ([153.19.208.7]:2363 "EHLO
	pollux.ds.pg.gda.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030658AbXAZOyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jan 2007 09:54:49 -0500
In-Reply-To: <Pine.LNX.4.64.0701251718270.4944@gate.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kumar,

> I've got a BCM5461 that requires this fix to be able to force the speeds 
> on the PHY.  Not sure if its needed on the other variants or not.  The 
> problem is the genphy_config_aneg resets the PHY when forcing the speed 
> and once we reset the BCM5461 it doesn't remember any of its settings.

 I recall seeing a similar problem before and having checked with the IEEE 
spec I believe it's the generic code that is incorrect.  Following is my 
fix to address this problem.  Please try and see if it works for you.

 I am waiting for 2.6.20 to happen before I recheck my list of patches 
related to the BCM1250 MAC and the PHY library and (re)submit whatever is 
still relevant.  This patch is one of candidates.

  Maciej

patch-mips-2.6.18-20060920-phy-forcing-1
diff -up --recursive --new-file linux-mips-2.6.18-20060920.macro/drivers/net/phy/phy.c linux-mips-2.6.18-20060920/drivers/net/phy/phy.c
--- linux-mips-2.6.18-20060920.macro/drivers/net/phy/phy.c	2006-08-05 04:58:46.000000000 +0000
+++ linux-mips-2.6.18-20060920/drivers/net/phy/phy.c	2006-09-25 03:03:45.000000000 +0000
@@ -713,6 +713,8 @@ static void phy_timer(unsigned long data
 				} else {
 					phydev->state = PHY_NOLINK;
 					netif_carrier_off(phydev->attached_dev);
+					phydev->link_timeout =
+						PHY_NOLINK_TIMEOUT;
 				}
 
 				phydev->adjust_link(phydev->attached_dev);
@@ -759,6 +761,9 @@ static void phy_timer(unsigned long data
 				phydev->state = PHY_RUNNING;
 				netif_carrier_on(phydev->attached_dev);
 				phydev->adjust_link(phydev->attached_dev);
+			} else if (0 == phydev->link_timeout--) {
+				phydev->autoneg = AUTONEG_ENABLE;
+				needs_aneg = 1;
 			}
 			break;
 		case PHY_FORCING:
@@ -797,6 +802,7 @@ static void phy_timer(unsigned long data
 			} else {
 				phydev->state = PHY_NOLINK;
 				netif_carrier_off(phydev->attached_dev);
+				phydev->link_timeout = PHY_NOLINK_TIMEOUT;
 			}
 
 			phydev->adjust_link(phydev->attached_dev);
diff -up --recursive --new-file linux-mips-2.6.18-20060920.macro/drivers/net/phy/phy_device.c linux-mips-2.6.18-20060920/drivers/net/phy/phy_device.c
--- linux-mips-2.6.18-20060920.macro/drivers/net/phy/phy_device.c	2006-09-20 20:50:26.000000000 +0000
+++ linux-mips-2.6.18-20060920/drivers/net/phy/phy_device.c	2006-09-25 01:51:34.000000000 +0000
@@ -325,10 +325,18 @@ EXPORT_SYMBOL(genphy_config_advert);
  *   Please see phy_sanitize_settings() */
 int genphy_setup_forced(struct phy_device *phydev)
 {
-	int ctl = BMCR_RESET;
+	int ctl;
 
 	phydev->pause = phydev->asym_pause = 0;
 
+	ctl = phy_read(phydev, MII_BMCR);
+
+	ctl &= ~(BMCR_ANENABLE | BMCR_ANRESTART);
+
+	ctl &= ~(BMCR_ISOLATE);
+
+	ctl &= ~(BMCR_SPEED1000 | BMCR_SPEED100 | BMCR_FULLDPLX);
+
 	if (SPEED_1000 == phydev->speed)
 		ctl |= BMCR_SPEED1000;
 	else if (SPEED_100 == phydev->speed)
@@ -336,16 +344,8 @@ int genphy_setup_forced(struct phy_devic
 
 	if (DUPLEX_FULL == phydev->duplex)
 		ctl |= BMCR_FULLDPLX;
-	
-	ctl = phy_write(phydev, MII_BMCR, ctl);
-
-	if (ctl < 0)
-		return ctl;
 
-	/* We just reset the device, so we'd better configure any
-	 * settings the PHY requires to operate */
-	if (phydev->drv->config_init)
-		ctl = phydev->drv->config_init(phydev);
+	ctl = phy_write(phydev, MII_BMCR, ctl);
 
 	return ctl;
 }
diff -up --recursive --new-file linux-mips-2.6.18-20060920.macro/include/linux/phy.h linux-mips-2.6.18-20060920/include/linux/phy.h
--- linux-mips-2.6.18-20060920.macro/include/linux/phy.h	2006-08-29 04:58:59.000000000 +0000
+++ linux-mips-2.6.18-20060920/include/linux/phy.h	2006-09-29 14:19:10.000000000 +0000
@@ -50,6 +50,7 @@
 #define PHY_STATE_TIME		1
 #define PHY_FORCE_TIMEOUT	10
 #define PHY_AN_TIMEOUT		10
+#define PHY_NOLINK_TIMEOUT	3
 
 #define PHY_MAX_ADDR 32
 
