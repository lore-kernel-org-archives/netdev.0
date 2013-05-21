From: "Florian Fainelli" <f.fainelli@gmail.com>
Subject: [PATCH 1/2 net-next v2] phy: allow drivers to flag a PHY device
 as internal
Date: Tue, 21 May 2013 12:09:47 +0100
Message-ID: <1369134588-18339-2-git-send-email-f.fainelli@gmail.com>
References: <1369134588-18339-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, afleming@freescale.com, jogo@openwrt.org,
	"Florian Fainelli" <f.fainelli@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4723 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751580Ab3EULKC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 May 2013 07:10:02 -0400
In-Reply-To: <1369134588-18339-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

libphy currently always reports a PHY as an external transceiver from
the ethtool output. This is inaccurate, because some drivers should be
able to tell that a PHY device is an internal transceiver of an Ethernet
MAC. Add a new flag (PHY_IS_INTERNAL) which can be set by PHY drivers
just like other flags, and a corresponding helper: phy_is_internal()
which can be used by networking drivers to query if a given
PHY device is internal.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes since v1:
- fixed typo in commit message (accurate vs inaccurate)
- add missing phy_is_internal helper

 drivers/net/phy/phy.c        |  3 ++-
 drivers/net/phy/phy_device.c |  3 +++
 include/linux/phy.h          | 12 ++++++++++++
 3 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 2d28a0e..b2a94e4 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -294,7 +294,8 @@ int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd)
 	cmd->duplex = phydev->duplex;
 	cmd->port = PORT_MII;
 	cmd->phy_address = phydev->addr;
-	cmd->transceiver = XCVR_EXTERNAL;
+	cmd->transceiver = phy_is_internal(phydev) ?
+		XCVR_INTERNAL : XCVR_EXTERNAL;
 	cmd->autoneg = phydev->autoneg;
 
 	return 0;
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index b55aa33..74630e9 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -1017,6 +1017,9 @@ static int phy_probe(struct device *dev)
 			phy_interrupt_is_valid(phydev))
 		phydev->irq = PHY_POLL;
 
+	if (phydrv->flags & PHY_IS_INTERNAL)
+		phydev->is_internal = true;
+
 	mutex_lock(&phydev->lock);
 
 	/* Start out supporting everything. Eventually,
diff --git a/include/linux/phy.h b/include/linux/phy.h
index fdfa115..ee411b0 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -49,6 +49,7 @@
 
 #define PHY_HAS_INTERRUPT	0x00000001
 #define PHY_HAS_MAGICANEG	0x00000002
+#define PHY_IS_INTERNAL		0x00000004
 
 /* Interface Mode definitions */
 typedef enum {
@@ -261,6 +262,7 @@ struct phy_c45_device_ids {
  * phy_id: UID for this device found during discovery
  * c45_ids: 802.3-c45 Device Identifers if is_c45.
  * is_c45:  Set to true if this phy uses clause 45 addressing.
+ * is_internal: Set to true if this phy is internal to a MAC.
  * state: state of the PHY for management purposes
  * dev_flags: Device-specific flags used by the PHY driver.
  * addr: Bus address of PHY
@@ -298,6 +300,7 @@ struct phy_device {
 
 	struct phy_c45_device_ids c45_ids;
 	bool is_c45;
+	bool is_internal;
 
 	enum phy_state state;
 
@@ -520,6 +523,15 @@ static inline bool phy_interrupt_is_valid(struct phy_device *phydev)
 	return phydev->irq != PHY_POLL && phydev->irq != PHY_IGNORE_INTERRUPT;
 }
 
+/**
+ * phy_is_internal - Convenience function for testing if a PHY is internal
+ * @phydev: the phy_device struct
+ */
+static inline bool phy_is_internal(struct phy_device *phydev)
+{
+	return phydev->is_internal;
+}
+
 struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
 		bool is_c45, struct phy_c45_device_ids *c45_ids);
 struct phy_device *get_phy_device(struct mii_bus *bus, int addr, bool is_c45);
-- 
1.8.1.2
