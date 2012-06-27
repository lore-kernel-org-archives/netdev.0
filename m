From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH v2 3/4] netdev/phy/of: Add more methods for binding PHY devices to drivers.
Date: Wed, 27 Jun 2012 10:33:37 -0700
Message-ID: <1340818418-10382-4-git-send-email-ddaney.cavm@gmail.com>
References: <1340818418-10382-1-git-send-email-ddaney.cavm@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
	afleming@gmail.com, David Daney <david.daney@cavium.com>
To: Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	devicetree-discuss@lists.ozlabs.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1340818418-10382-1-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <david.daney@cavium.com>

Allow PHY drivers to supply their own device matching function
(match_phy_device()), or to be matched OF compatible properties.

PHYs following IEEE802.3 clause 45 have more than one device
identifier constants, which breaks the default device matching code.
Other 10G PHYs don't follow the standard manufacturer/device
identifier register layout standards, but they do use the standard
MDIO bus protocols for register access.  Both of these require
adjustments to the PHY driver to device matching code.

If the there is an of_node associated with such a PHY, we can match it
to its driver using the "compatible" properties, just as we do with
certain platform devices.  If the "compatible" property match fails,
first check if there is a driver supplied matching function, and if
not fall back to the existing identifier matching rules.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/net/phy/mdio_bus.c |    7 +++++++
 include/linux/phy.h        |    6 ++++++
 2 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 2cee6d2..170eb41 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -25,6 +25,7 @@
 #include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/device.h>
+#include <linux/of_device.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
@@ -308,6 +309,12 @@ static int mdio_bus_match(struct device *dev, struct device_driver *drv)
 	struct phy_device *phydev = to_phy_device(dev);
 	struct phy_driver *phydrv = to_phy_driver(drv);
 
+	if (of_driver_match_device(dev, drv))
+		return 1;
+
+	if (phydrv->match_phy_device)
+		return phydrv->match_phy_device(phydev);
+
 	return ((phydrv->phy_id & phydrv->phy_id_mask) ==
 		(phydev->phy_id & phydrv->phy_id_mask));
 }
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 597d05d..7eac80a 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -426,6 +426,12 @@ struct phy_driver {
 	/* Clears up any memory if needed */
 	void (*remove)(struct phy_device *phydev);
 
+	/* Returns true if this is a suitable driver for the given
+	 * phydev.  If NULL, matching is based on phy_id and
+	 * phy_id_mask.
+	 */
+	int (*match_phy_device)(struct phy_device *phydev);
+
 	/* Handles ethtool queries for hardware time stamping. */
 	int (*ts_info)(struct phy_device *phydev, struct ethtool_ts_info *ti);
 
-- 
1.7.2.3
