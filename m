From: Clemens Gruber <clemens.gruber@pqgruber.com>
Subject: [PATCH] Revert "net: phy: turn carrier off on phy attach"
Date: Fri, 12 Feb 2016 19:01:53 +0100
Message-ID: <1455300113-2335-1-git-send-email-clemens.gruber@pqgruber.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org,
	Sjoerd Simons <sjoerd.simons@collabora.co.uk>,
	"David S . Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Clemens Gruber <clemens.gruber@pqgruber.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 113c74d83eef ("net: phy: turn carrier off on phy attach") breaks
the eth0 link coming up on all my i.MX6Q boards with a Marvell 88E1510.
If I then do a ifconfig eth0 down/up cycle I first get a MDIO read
timeout but then the link becomes ready and everything is back to
normal.
Without this step however, the link stays down forever, an unusually
high amount of phy interrupts occur (about 10000/second) and kworker/0:2
is constantly using over 60% of the CPU.

Reverting it fixes the problems with the link not coming up at boot as
well as the high amount of phy interrupts and kworker load in that
state.

This reverts commit 113c74d83eef870e43a0d9279044e9d5435f0d07.

Signed-off-by: Clemens Gruber <clemens.gruber@pqgruber.com>
---
 drivers/net/phy/phy_device.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index bad3f00..903737a 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -901,11 +901,6 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 
 	phydev->state = PHY_READY;
 
-	/* Initial carrier state is off as the phy is about to be
-	 * (re)initialized.
-	 */
-	netif_carrier_off(phydev->attached_dev);
-
 	/* Do initial configuration here, now that
 	 * we have certain key parameters
 	 * (dev_flags and interface)
-- 
2.7.1
