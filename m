From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH RFC 05/13] net: phy: provide a hook for link up/link down
 events
Date: Tue, 25 Jul 2017 15:02:58 +0100
Message-ID: <E1da0QM-0007LS-3T@rmk-PC.armlinux.org.uk>
References: <20170725140138.GK31807@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:50868 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752205AbdGYODC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 10:03:02 -0400
In-Reply-To: <20170725140138.GK31807@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sometimes, we need to do additional work between the PHY coming up and
marking the carrier present - for example, we may need to wait for the
PHY to MAC link to finish negotiation.  This changes phylib to provide
a notification function pointer which avoids the built-in
netif_carrier_on() and netif_carrier_off() functions.

Standard ->adjust_link functionality is provided by hooking a helper
into the new ->phy_link_change method.

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/phy/phy.c        | 42 ++++++++++++++++++++----------------------
 drivers/net/phy/phy_device.c | 14 ++++++++++++++
 include/linux/phy.h          |  1 +
 3 files changed, 35 insertions(+), 22 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 74873bc3a565..5fd411ed3b85 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -863,9 +863,15 @@ void phy_start(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(phy_start);
 
-static void phy_adjust_link(struct phy_device *phydev)
+static void phy_link_up(struct phy_device *phydev)
 {
-	phydev->adjust_link(phydev->attached_dev);
+	phydev->phy_link_change(phydev, true, true);
+	phy_led_trigger_change_speed(phydev);
+}
+
+static void phy_link_down(struct phy_device *phydev, bool do_carrier)
+{
+	phydev->phy_link_change(phydev, false, do_carrier);
 	phy_led_trigger_change_speed(phydev);
 }
 
@@ -910,8 +916,7 @@ void phy_state_machine(struct work_struct *work)
 		/* If the link is down, give up on negotiation for now */
 		if (!phydev->link) {
 			phydev->state = PHY_NOLINK;
-			netif_carrier_off(phydev->attached_dev);
-			phy_adjust_link(phydev);
+			phy_link_down(phydev, true);
 			break;
 		}
 
@@ -923,9 +928,7 @@ void phy_state_machine(struct work_struct *work)
 		/* If AN is done, we're running */
 		if (err > 0) {
 			phydev->state = PHY_RUNNING;
-			netif_carrier_on(phydev->attached_dev);
-			phy_adjust_link(phydev);
-
+			phy_link_up(phydev);
 		} else if (0 == phydev->link_timeout--)
 			needs_aneg = true;
 		break;
@@ -950,8 +953,7 @@ void phy_state_machine(struct work_struct *work)
 				}
 			}
 			phydev->state = PHY_RUNNING;
-			netif_carrier_on(phydev->attached_dev);
-			phy_adjust_link(phydev);
+			phy_link_up(phydev);
 		}
 		break;
 	case PHY_FORCING:
@@ -961,13 +963,12 @@ void phy_state_machine(struct work_struct *work)
 
 		if (phydev->link) {
 			phydev->state = PHY_RUNNING;
-			netif_carrier_on(phydev->attached_dev);
+			phy_link_up(phydev);
 		} else {
 			if (0 == phydev->link_timeout--)
 				needs_aneg = true;
+			phy_link_down(phydev, false);
 		}
-
-		phy_adjust_link(phydev);
 		break;
 	case PHY_RUNNING:
 		/* Only register a CHANGE if we are polling and link changed
@@ -999,14 +1000,12 @@ void phy_state_machine(struct work_struct *work)
 
 		if (phydev->link) {
 			phydev->state = PHY_RUNNING;
-			netif_carrier_on(phydev->attached_dev);
+			phy_link_up(phydev);
 		} else {
 			phydev->state = PHY_NOLINK;
-			netif_carrier_off(phydev->attached_dev);
+			phy_link_down(phydev, true);
 		}
 
-		phy_adjust_link(phydev);
-
 		if (phy_interrupt_is_valid(phydev))
 			err = phy_config_interrupt(phydev,
 						   PHY_INTERRUPT_ENABLED);
@@ -1014,8 +1013,7 @@ void phy_state_machine(struct work_struct *work)
 	case PHY_HALTED:
 		if (phydev->link) {
 			phydev->link = 0;
-			netif_carrier_off(phydev->attached_dev);
-			phy_adjust_link(phydev);
+			phy_link_down(phydev, true);
 			do_suspend = true;
 		}
 		break;
@@ -1035,11 +1033,11 @@ void phy_state_machine(struct work_struct *work)
 
 				if (phydev->link) {
 					phydev->state = PHY_RUNNING;
-					netif_carrier_on(phydev->attached_dev);
+					phy_link_up(phydev);
 				} else	{
 					phydev->state = PHY_NOLINK;
+					phy_link_down(phydev, false);
 				}
-				phy_adjust_link(phydev);
 			} else {
 				phydev->state = PHY_AN;
 				phydev->link_timeout = PHY_AN_TIMEOUT;
@@ -1051,11 +1049,11 @@ void phy_state_machine(struct work_struct *work)
 
 			if (phydev->link) {
 				phydev->state = PHY_RUNNING;
-				netif_carrier_on(phydev->attached_dev);
+				phy_link_up(phydev);
 			} else	{
 				phydev->state = PHY_NOLINK;
+				phy_link_down(phydev, false);
 			}
-			phy_adjust_link(phydev);
 		}
 		break;
 	}
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 1790f7fec125..d536a9a7cd2b 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -688,6 +688,19 @@ struct phy_device *phy_find_first(struct mii_bus *bus)
 }
 EXPORT_SYMBOL(phy_find_first);
 
+static void phy_link_change(struct phy_device *phydev, bool up, bool do_carrier)
+{
+	struct net_device *netdev = phydev->attached_dev;
+
+	if (do_carrier) {
+		if (up)
+			netif_carrier_on(netdev);
+		else
+			netif_carrier_off(netdev);
+	}
+	phydev->adjust_link(netdev);
+}
+
 /**
  * phy_prepare_link - prepares the PHY layer to monitor link status
  * @phydev: target phy_device struct
@@ -951,6 +964,7 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 		goto error;
 	}
 
+	phydev->phy_link_change = phy_link_change;
 	phydev->attached_dev = dev;
 	dev->phydev = phydev;
 
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 46a47d8efb95..8ca2d8d6d5bd 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -474,6 +474,7 @@ struct phy_device {
 	u8 mdix;
 	u8 mdix_ctrl;
 
+	void (*phy_link_change)(struct phy_device *, bool up, bool do_carrier);
 	void (*adjust_link)(struct net_device *dev);
 };
 #define to_phy_device(d) container_of(to_mdio_device(d), \
-- 
2.7.4
