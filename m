From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 8/9] net: phy: fix checkpatch errors
Date: Tue, 17 Dec 2013 21:38:12 -0800
Message-ID: <1387345093-14168-9-git-send-email-f.fainelli@gmail.com>
References: <1387345093-14168-1-git-send-email-f.fainelli@gmail.com>
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:43370 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752142Ab3LRFie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 00:38:34 -0500
Received: by mail-oa0-f54.google.com with SMTP id h16so7845874oag.27
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 21:38:34 -0800 (PST)
In-Reply-To: <1387345093-14168-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

checkpatch spotted a few checkpatch errors such as whitespace damages
and switch/case labels not being on the same column, fix them.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c        | 264 +++++++++++++++++++++----------------------
 drivers/net/phy/phy_device.c |  14 +--
 2 files changed, 139 insertions(+), 139 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index dea609f..2090886 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -332,7 +332,7 @@ int phy_mii_ioctl(struct phy_device *phydev,
 
 	case SIOCSMIIREG:
 		if (mii_data->phy_id == phydev->addr) {
-			switch(mii_data->reg_num) {
+			switch (mii_data->reg_num) {
 			case MII_BMCR:
 				if ((val & (BMCR_RESET|BMCR_ANENABLE)) == 0)
 					phydev->autoneg = AUTONEG_DISABLE;
@@ -714,16 +714,16 @@ void phy_start(struct phy_device *phydev)
 	mutex_lock(&phydev->lock);
 
 	switch (phydev->state) {
-		case PHY_STARTING:
-			phydev->state = PHY_PENDING;
-			break;
-		case PHY_READY:
-			phydev->state = PHY_UP;
-			break;
-		case PHY_HALTED:
-			phydev->state = PHY_RESUMING;
-		default:
-			break;
+	case PHY_STARTING:
+		phydev->state = PHY_PENDING;
+		break;
+	case PHY_READY:
+		phydev->state = PHY_UP;
+		break;
+	case PHY_HALTED:
+		phydev->state = PHY_RESUMING;
+	default:
+		break;
 	}
 	mutex_unlock(&phydev->lock);
 }
@@ -747,153 +747,138 @@ void phy_state_machine(struct work_struct *work)
 	if (phydev->adjust_state)
 		phydev->adjust_state(phydev->attached_dev);
 
-	switch(phydev->state) {
-		case PHY_DOWN:
-		case PHY_STARTING:
-		case PHY_READY:
-		case PHY_PENDING:
-			break;
-		case PHY_UP:
-			needs_aneg = 1;
+	switch (phydev->state) {
+	case PHY_DOWN:
+	case PHY_STARTING:
+	case PHY_READY:
+	case PHY_PENDING:
+		break;
+	case PHY_UP:
+		needs_aneg = 1;
 
-			phydev->link_timeout = PHY_AN_TIMEOUT;
+		phydev->link_timeout = PHY_AN_TIMEOUT;
+
+		break;
+	case PHY_AN:
+		err = phy_read_status(phydev);
 
+		if (err < 0)
 			break;
-		case PHY_AN:
-			err = phy_read_status(phydev);
 
-			if (err < 0)
-				break;
+		/* If the link is down, give up on
+		 * negotiation for now */
+		if (!phydev->link) {
+			phydev->state = PHY_NOLINK;
+			netif_carrier_off(phydev->attached_dev);
+			phydev->adjust_link(phydev->attached_dev);
+			break;
+		}
 
-			/* If the link is down, give up on
-			 * negotiation for now */
-			if (!phydev->link) {
-				phydev->state = PHY_NOLINK;
-				netif_carrier_off(phydev->attached_dev);
-				phydev->adjust_link(phydev->attached_dev);
-				break;
-			}
+		/* Check if negotiation is done.  Break
+		 * if there's an error */
+		err = phy_aneg_done(phydev);
+		if (err < 0)
+			break;
 
-			/* Check if negotiation is done.  Break
-			 * if there's an error */
-			err = phy_aneg_done(phydev);
-			if (err < 0)
-				break;
+		/* If AN is done, we're running */
+		if (err > 0) {
+			phydev->state = PHY_RUNNING;
+			netif_carrier_on(phydev->attached_dev);
+			phydev->adjust_link(phydev->attached_dev);
 
-			/* If AN is done, we're running */
-			if (err > 0) {
-				phydev->state = PHY_RUNNING;
-				netif_carrier_on(phydev->attached_dev);
-				phydev->adjust_link(phydev->attached_dev);
+		} else if (0 == phydev->link_timeout--) {
+			needs_aneg = 1;
+			/* If we have the magic_aneg bit,
+			 * we try again */
+			if (phydev->drv->flags & PHY_HAS_MAGICANEG)
+				break;
+		}
+		break;
+	case PHY_NOLINK:
+		err = phy_read_status(phydev);
 
-			} else if (0 == phydev->link_timeout--) {
-				needs_aneg = 1;
-				/* If we have the magic_aneg bit,
-				 * we try again */
-				if (phydev->drv->flags & PHY_HAS_MAGICANEG)
-					break;
-			}
+		if (err)
 			break;
-		case PHY_NOLINK:
-			err = phy_read_status(phydev);
 
-			if (err)
-				break;
+		if (phydev->link) {
+			phydev->state = PHY_RUNNING;
+			netif_carrier_on(phydev->attached_dev);
+			phydev->adjust_link(phydev->attached_dev);
+		}
+		break;
+	case PHY_FORCING:
+		err = genphy_update_link(phydev);
 
-			if (phydev->link) {
-				phydev->state = PHY_RUNNING;
-				netif_carrier_on(phydev->attached_dev);
-				phydev->adjust_link(phydev->attached_dev);
-			}
+		if (err)
 			break;
-		case PHY_FORCING:
-			err = genphy_update_link(phydev);
 
-			if (err)
-				break;
+		if (phydev->link) {
+			phydev->state = PHY_RUNNING;
+			netif_carrier_on(phydev->attached_dev);
+		} else {
+			if (0 == phydev->link_timeout--)
+				needs_aneg = 1;
+		}
 
-			if (phydev->link) {
-				phydev->state = PHY_RUNNING;
-				netif_carrier_on(phydev->attached_dev);
-			} else {
-				if (0 == phydev->link_timeout--)
-					needs_aneg = 1;
-			}
+		phydev->adjust_link(phydev->attached_dev);
+		break;
+	case PHY_RUNNING:
+		/* Only register a CHANGE if we are
+		 * polling or ignoring interrupts
+		 */
+		if (!phy_interrupt_is_valid(phydev))
+			phydev->state = PHY_CHANGELINK;
+		break;
+	case PHY_CHANGELINK:
+		err = phy_read_status(phydev);
 
-			phydev->adjust_link(phydev->attached_dev);
+		if (err)
 			break;
-		case PHY_RUNNING:
-			/* Only register a CHANGE if we are
-			 * polling or ignoring interrupts
-			 */
-			if (!phy_interrupt_is_valid(phydev))
-				phydev->state = PHY_CHANGELINK;
-			break;
-		case PHY_CHANGELINK:
-			err = phy_read_status(phydev);
 
-			if (err)
-				break;
+		if (phydev->link) {
+			phydev->state = PHY_RUNNING;
+			netif_carrier_on(phydev->attached_dev);
+		} else {
+			phydev->state = PHY_NOLINK;
+			netif_carrier_off(phydev->attached_dev);
+		}
 
-			if (phydev->link) {
-				phydev->state = PHY_RUNNING;
-				netif_carrier_on(phydev->attached_dev);
-			} else {
-				phydev->state = PHY_NOLINK;
-				netif_carrier_off(phydev->attached_dev);
-			}
+		phydev->adjust_link(phydev->attached_dev);
 
+		if (phy_interrupt_is_valid(phydev))
+			err = phy_config_interrupt(phydev,
+					PHY_INTERRUPT_ENABLED);
+		break;
+	case PHY_HALTED:
+		if (phydev->link) {
+			phydev->link = 0;
+			netif_carrier_off(phydev->attached_dev);
 			phydev->adjust_link(phydev->attached_dev);
+			do_suspend = 1;
+		}
+		break;
+	case PHY_RESUMING:
 
-			if (phy_interrupt_is_valid(phydev))
-				err = phy_config_interrupt(phydev,
-						PHY_INTERRUPT_ENABLED);
-			break;
-		case PHY_HALTED:
-			if (phydev->link) {
-				phydev->link = 0;
-				netif_carrier_off(phydev->attached_dev);
-				phydev->adjust_link(phydev->attached_dev);
-				do_suspend = 1;
-			}
-			break;
-		case PHY_RESUMING:
+		err = phy_clear_interrupt(phydev);
 
-			err = phy_clear_interrupt(phydev);
+		if (err)
+			break;
 
-			if (err)
-				break;
+		err = phy_config_interrupt(phydev,
+				PHY_INTERRUPT_ENABLED);
 
-			err = phy_config_interrupt(phydev,
-					PHY_INTERRUPT_ENABLED);
+		if (err)
+			break;
 
-			if (err)
+		if (AUTONEG_ENABLE == phydev->autoneg) {
+			err = phy_aneg_done(phydev);
+			if (err < 0)
 				break;
 
-			if (AUTONEG_ENABLE == phydev->autoneg) {
-				err = phy_aneg_done(phydev);
-				if (err < 0)
-					break;
-
-				/* err > 0 if AN is done.
-				 * Otherwise, it's 0, and we're
-				 * still waiting for AN */
-				if (err > 0) {
-					err = phy_read_status(phydev);
-					if (err)
-						break;
-
-					if (phydev->link) {
-						phydev->state = PHY_RUNNING;
-						netif_carrier_on(phydev->attached_dev);
-					} else
-						phydev->state = PHY_NOLINK;
-					phydev->adjust_link(phydev->attached_dev);
-				} else {
-					phydev->state = PHY_AN;
-					phydev->link_timeout = PHY_AN_TIMEOUT;
-				}
-			} else {
+			/* err > 0 if AN is done.
+			 * Otherwise, it's 0, and we're
+			 * still waiting for AN */
+			if (err > 0) {
 				err = phy_read_status(phydev);
 				if (err)
 					break;
@@ -904,8 +889,23 @@ void phy_state_machine(struct work_struct *work)
 				} else
 					phydev->state = PHY_NOLINK;
 				phydev->adjust_link(phydev->attached_dev);
+			} else {
+				phydev->state = PHY_AN;
+				phydev->link_timeout = PHY_AN_TIMEOUT;
 			}
-			break;
+		} else {
+			err = phy_read_status(phydev);
+			if (err)
+				break;
+
+			if (phydev->link) {
+				phydev->state = PHY_RUNNING;
+				netif_carrier_on(phydev->attached_dev);
+			} else
+				phydev->state = PHY_NOLINK;
+			phydev->adjust_link(phydev->attached_dev);
+		}
+		break;
 	}
 
 	mutex_unlock(&phydev->lock);
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 4eb5bba..d532424 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -162,7 +162,7 @@ struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
 	dev = kzalloc(sizeof(*dev), GFP_KERNEL);
 
 	if (NULL == dev)
-		return (struct phy_device*) PTR_ERR((void*)-ENOMEM);
+		return (struct phy_device *)PTR_ERR((void *)-ENOMEM);
 
 	dev->dev.release = phy_device_release;
 
@@ -459,7 +459,7 @@ EXPORT_SYMBOL(phy_connect_direct);
  *   choose to call only the subset of functions which provide
  *   the desired functionality.
  */
-struct phy_device * phy_connect(struct net_device *dev, const char *bus_id,
+struct phy_device *phy_connect(struct net_device *dev, const char *bus_id,
 		void (*handler)(struct net_device *),
 		phy_interface_t interface)
 {
@@ -494,7 +494,7 @@ void phy_disconnect(struct phy_device *phydev)
 		phy_stop_interrupts(phydev);
 
 	phy_stop_machine(phydev);
-	
+
 	phydev->adjust_link = NULL;
 
 	phy_detach(phydev);
@@ -792,7 +792,7 @@ int genphy_setup_forced(struct phy_device *phydev)
 
 	if (DUPLEX_FULL == phydev->duplex)
 		ctl |= BMCR_FULLDPLX;
-	
+
 	err = phy_write(phydev, MII_BMCR, ctl);
 
 	return err;
@@ -965,14 +965,14 @@ int genphy_read_status(struct phy_device *phydev)
 				phydev->duplex = DUPLEX_FULL;
 		} else if (lpa & (LPA_100FULL | LPA_100HALF)) {
 			phydev->speed = SPEED_100;
-			
+
 			if (lpa & LPA_100FULL)
 				phydev->duplex = DUPLEX_FULL;
 		} else
 			if (lpa & LPA_10FULL)
 				phydev->duplex = DUPLEX_FULL;
 
-		if (phydev->duplex == DUPLEX_FULL){
+		if (phydev->duplex == DUPLEX_FULL) {
 			phydev->pause = lpa & LPA_PAUSE_CAP ? 1 : 0;
 			phydev->asym_pause = lpa & LPA_PAUSE_ASYM ? 1 : 0;
 		}
@@ -1213,7 +1213,7 @@ static struct phy_driver genphy_driver = {
 	.read_status	= genphy_read_status,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
-	.driver		= {.owner= THIS_MODULE, },
+	.driver		= { .owner = THIS_MODULE, },
 };
 
 static int __init phy_init(void)
-- 
1.8.3.2
