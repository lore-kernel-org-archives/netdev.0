From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v2 3/3] net: phy: Fix PHY driver bind and unbind events
Date: Tue,  7 Feb 2017 23:37:46 -0800
Message-ID: <20170208073746.10963-4-f.fainelli@gmail.com>
References: <20170208073746.10963-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, rmk+kernel@armlinux.org.uk,
        maowenan@huawei.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f193.google.com ([74.125.82.193]:33934 "EHLO
        mail-ot0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932143AbdBHHja (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 02:39:30 -0500
Received: by mail-ot0-f193.google.com with SMTP id 73so17118959otj.1
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 23:37:53 -0800 (PST)
In-Reply-To: <20170208073746.10963-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PHY library does not deal very well with bind and unbind events. The first
thing we would see is that we were not properly canceling the PHY state machine
workqueue, so we would be crashing while dereferencing phydev->drv since there
is no driver attached anymore.

Once we fix that, there are several things that did not quite work as expected:

- if the PHY state machine was running, we were not stopping it properly, and
  the state machine state would not be marked as such
- when we rebind the driver, nothing would happen, since we would not know which
  state we were before the unbind

This patch takes the following approach:

- if the PHY was attached, and the state machine was running we would stop it,
  remember where we left, and schedule the state machine for restart upong
  driver bind
- if the PHY was attached, but HALTED, we would let it in that state, and do not
  alter the state upon driver bind
- in all other cases (detached) we would keep the PHY in DOWN state waiting for
  a network driver to show up, and set PHY_READY on driver bind

Suggested-by: Russell King <rmk+kernel@armlinux.org.uk>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy_device.c | 27 +++++++++++++++++++++++++--
 1 file changed, 25 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index bde240bf8d7b..5314e764a387 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -1711,6 +1711,7 @@ static int phy_probe(struct device *dev)
 	struct phy_device *phydev = to_phy_device(dev);
 	struct device_driver *drv = phydev->mdio.dev.driver;
 	struct phy_driver *phydrv = to_phy_driver(drv);
+	bool should_start = false;
 	int err = 0;
 
 	phydev->drv = phydrv;
@@ -1760,24 +1761,46 @@ static int phy_probe(struct device *dev)
 	}
 
 	/* Set the state to READY by default */
-	phydev->state = PHY_READY;
+	if (phydev->state > PHY_UP && phydev->state != PHY_HALTED)
+		should_start = true;
+	else
+		phydev->state = PHY_READY;
 
 	if (phydev->drv->probe)
 		err = phydev->drv->probe(phydev);
 
 	mutex_unlock(&phydev->lock);
 
+	if (should_start)
+		phy_start(phydev);
+
 	return err;
 }
 
 static int phy_remove(struct device *dev)
 {
 	struct phy_device *phydev = to_phy_device(dev);
+	bool should_stop = false;
+	enum phy_state state;
+
+	cancel_delayed_work_sync(&phydev->state_queue);
 
 	mutex_lock(&phydev->lock);
-	phydev->state = PHY_DOWN;
+	state = phydev->state;
+	if (state > PHY_UP && state != PHY_HALTED)
+		should_stop = true;
+	else
+		phydev->state = PHY_DOWN;
 	mutex_unlock(&phydev->lock);
 
+	/* phy_stop() sets the state to HALTED, undo that for the ->probe() function
+	 * to have a chance to resume where we left
+	 */
+	if (should_stop) {
+		phy_stop(phydev);
+		phydev->state = state;
+	}
+
 	if (phydev->drv->remove)
 		phydev->drv->remove(phydev);
 	phydev->drv = NULL;
-- 
2.9.3
