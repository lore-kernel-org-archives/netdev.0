From: "Florian Fainelli" <f.fainelli@gmail.com>
Subject: [PATCH 1/2 net-next] phy: fix the use of PHY_IGNORE_INTERRUPT
Date: Thu, 16 May 2013 18:04:55 +0000
Message-ID: <1368727496-25638-2-git-send-email-f.fainelli@gmail.com>
References: <1368727496-25638-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jogo@openwrt.org,
	thomas.petazzoni@free-electrons.com, afleming@freescale.com,
	"Florian Fainelli" <f.fainelli@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2507 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753514Ab3EPSFb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 May 2013 14:05:31 -0400
In-Reply-To: <1368727496-25638-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a PHY device is registered with the special IRQ value
PHY_IGNORE_INTERRUPT (-2) it will not properly be handled by the PHY
library:

- it continues to poll its register, while we do not want this
  because such PHY link events or register changes are serviced by an
  Ethernet MAC interrupt line
- it will still try to configure PHY interrupts at the PHY level, such
  interrupts do not exist at the PHY but at the MAC level
- the state machine only handles PHY_POLL, but should also handle
  PHY_IGNORE_INTERRUPT similarly

This patch updates the PHY state machine and initialization paths to
account for the specific PHY_IGNORE_INTERRUPT. Based on an earlier patch
by Thomas Petazzoni, and reworked to add the missing bits.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c        | 6 +++---
 drivers/net/phy/phy_device.c | 5 +++--
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index c14f147..2de4290 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -682,7 +682,7 @@ void phy_stop(struct phy_device *phydev)
 	if (PHY_HALTED == phydev->state)
 		goto out_unlock;
 
-	if (phydev->irq != PHY_POLL) {
+	if (phydev->irq >= 0) {
 		/* Disable PHY Interrupts */
 		phy_config_interrupt(phydev, PHY_INTERRUPT_DISABLED);
 
@@ -829,7 +829,7 @@ void phy_state_machine(struct work_struct *work)
 		case PHY_RUNNING:
 			/* Only register a CHANGE if we are
 			 * polling */
-			if (PHY_POLL == phydev->irq)
+			if (phydev->irq < 0)
 				phydev->state = PHY_CHANGELINK;
 			break;
 		case PHY_CHANGELINK:
@@ -848,7 +848,7 @@ void phy_state_machine(struct work_struct *work)
 
 			phydev->adjust_link(phydev->attached_dev);
 
-			if (PHY_POLL != phydev->irq)
+			if (phydev->irq >= 0)
 				err = phy_config_interrupt(phydev,
 						PHY_INTERRUPT_ENABLED);
 			break;
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 3657b4a..3cb80b8 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -1009,8 +1009,9 @@ static int phy_probe(struct device *dev)
 	phydrv = to_phy_driver(drv);
 	phydev->drv = phydrv;
 
-	/* Disable the interrupt if the PHY doesn't support it */
-	if (!(phydrv->flags & PHY_HAS_INTERRUPT))
+	/* Disable the interrupt if the PHY doesn't support it
+	 * but the interrupt is still a valid one */
+	if (!(phydrv->flags & PHY_HAS_INTERRUPT) && phydev->irq >= 0)
 		phydev->irq = PHY_POLL;
 
 	mutex_lock(&phydev->lock);
-- 
1.8.1.2
