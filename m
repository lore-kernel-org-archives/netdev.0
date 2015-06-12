From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 1/3] net: phy: Allow PHY devices to identify themselves as Ethernet switches, etc.
Date: Fri, 12 Jun 2015 19:18:55 +0200
Message-ID: <1434129537-15252-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55366 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750773AbbFLRYl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Jun 2015 13:24:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>

Some Ethernet MAC drivers using the PHY library require the hardcoding
of link parameters when interfaced to a switch device, SFP module,
switch to switch port, etc. This has typically lead to various ad-hoc
implementations looking like this:

- using a "fixed PHY" emulated device, which will provide link
  indication towards the Ethernet MAC driver and hardware

- pretend there is no PHY and hardcode link parameters, ala mv643x_eth

Based on that, it is desireable to have the PHY drivers advertise the
correct link parameters, just like regular Ethernet PHYs towards their
CPU Ethernet MAC drivers, however, Ethernet MAC drivers should be able
to tell whether this link should be monitored or not. In the context
of an Ethernet switch, SFP module, switch to switch link, we do not
need to monitor this link since it should be always up.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 include/linux/phy.h | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index a26c3f84b8dd..5c3b87c0773c 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -330,6 +330,7 @@ struct phy_c45_device_ids {
  * c45_ids: 802.3-c45 Device Identifers if is_c45.
  * is_c45:  Set to true if this phy uses clause 45 addressing.
  * is_internal: Set to true if this phy is internal to a MAC.
+ * is_pseudo_fixed_link: Set to true if this phy is an Ethernet switch, etc.
  * has_fixups: Set to true if this phy has fixups/quirks.
  * suspended: Set to true if this phy has been suspended successfully.
  * state: state of the PHY for management purposes
@@ -368,6 +369,7 @@ struct phy_device {
 	struct phy_c45_device_ids c45_ids;
 	bool is_c45;
 	bool is_internal;
+	bool is_pseudo_fixed_link;
 	bool has_fixups;
 	bool suspended;
 
@@ -686,6 +688,16 @@ static inline bool phy_interface_is_rgmii(struct phy_device *phydev)
 {
 	return phydev->interface >= PHY_INTERFACE_MODE_RGMII &&
 		phydev->interface <= PHY_INTERFACE_MODE_RGMII_TXID;
+};
+
+/*
+ * phy_is_pseudo_fixed_link - Convenience function for testing if this
+ * PHY is the CPU port facing side of an Ethernet switch, or similar.
+ * @phydev: the phy_device struct
+ */
+static inline bool phy_is_pseudo_fixed_link(struct phy_device *phydev)
+{
+	return phydev->is_pseudo_fixed_link;
 }
 
 /**
-- 
2.1.4
