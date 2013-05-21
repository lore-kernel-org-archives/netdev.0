From: "Florian Fainelli" <f.fainelli@gmail.com>
Subject: [PATCH 1/2 net-next] phy: allow drivers to flag a PHY device as
 internal
Date: Tue, 21 May 2013 11:37:05 +0100
Message-ID: <1369132626-13776-2-git-send-email-f.fainelli@gmail.com>
References: <1369132626-13776-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, afleming@freescale.com, jogo@openwrt.org,
	"Florian Fainelli" <f.fainelli@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2721 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752316Ab3EUKqP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 May 2013 06:46:15 -0400
In-Reply-To: <1369132626-13776-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

libphy currently always reports a PHY as an external transceiver from
the ethtool output. This is accurate, because some drivers should be
able to tell that a PHY device is an internal transceiver of an Ethernet
MAC. Add a new flag (PHY_IS_INTERNAL) which can be set by PHY drivers
just like other flags, and which is used by the PHY ethtool code to
report it to userspace.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c        | 2 +-
 drivers/net/phy/phy_device.c | 3 +++
 include/linux/phy.h          | 3 +++
 3 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 2d28a0e..bcfcca1 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -294,7 +294,7 @@ int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd)
 	cmd->duplex = phydev->duplex;
 	cmd->port = PORT_MII;
 	cmd->phy_address = phydev->addr;
-	cmd->transceiver = XCVR_EXTERNAL;
+	cmd->transceiver = phydev->is_internal ? XCVR_INTERNAL : XCVR_EXTERNAL;
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
index fdfa115..271d623 100644
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
 
-- 
1.8.1.2
