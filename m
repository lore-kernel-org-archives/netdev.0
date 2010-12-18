From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: [PATCH 1/2] net: phy: balance disable/enable irq on change
Date: Sat, 18 Dec 2010 19:41:43 +0100
Message-ID: <1292697704-2886-1-git-send-email-jhautbois@gmail.com>
Cc: richard.cochran@omicron.at, shemminger@vyatta.com, tj@kernel.org,
	randy.dunlap@oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Jean-Michel Hautbois <jhautbois@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When phy interface changes its status, it calls phy_change() function.
This function calls the interrupt disabling functions for the driver
registered, but if this driver doesn't implement it, there is no IRQ
disabling. After doing the work, we call enable_irq and not the
respective driver function. This fixes it, as it could lead to an
unbalanced IRQ. Error code changed to EOPNOTSUPP.

Signed-off-by: Jean-Michel Hautbois <jhautbois@gmail.com>
---
 drivers/net/phy/phy.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 7670aac..5f23e8e 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -89,7 +89,8 @@ static int phy_config_interrupt(struct phy_device *phydev, u32 interrupts)
 	phydev->interrupts = interrupts;
 	if (phydev->drv->config_intr)
 		err = phydev->drv->config_intr(phydev);
-
+	else
+		err = -EOPNOTSUPP;
 	return err;
 }
 
@@ -541,6 +542,10 @@ static int phy_enable_interrupts(struct phy_device *phydev)
 		return err;
 
 	err = phy_config_interrupt(phydev, PHY_INTERRUPT_ENABLED);
+	if (err == -EOPNOTSUPP) {
+		err = 0;
+		enable_irq(phydev->irq);
+	}
 
 	return err;
 }
@@ -556,7 +561,10 @@ static int phy_disable_interrupts(struct phy_device *phydev)
 	/* Disable PHY interrupts */
 	err = phy_config_interrupt(phydev, PHY_INTERRUPT_DISABLED);
 
-	if (err)
+	if (err == -EOPNOTSUPP) {
+		err = 0;
+		disable_irq(phydev->irq);
+	} else if (err != 0)
 		goto phy_err;
 
 	/* Clear the interrupt */
-- 
1.7.0.4
