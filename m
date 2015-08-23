From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 1/9] net: phy: Allow PHY devices to identify themselves as Ethernet switches, etc.
Date: Sun, 23 Aug 2015 11:46:52 +0200
Message-ID: <1440323220-20438-2-git-send-email-andrew@lunn.ch>
References: <1440323220-20438-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38079 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751971AbbHWJzB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Aug 2015 05:55:01 -0400
In-Reply-To: <1440323220-20438-1-git-send-email-andrew@lunn.ch>
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
v2: set is_pseudo_fixed_link before registering the phy
---
 drivers/net/phy/fixed_phy.c |  1 +
 include/linux/phy.h         | 12 ++++++++++++
 2 files changed, 13 insertions(+)

diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.c
index 479b93f9581c..1a400ef92d65 100644
--- a/drivers/net/phy/fixed_phy.c
+++ b/drivers/net/phy/fixed_phy.c
@@ -294,6 +294,7 @@ struct phy_device *fixed_phy_register(unsigned int irq,
 
 	of_node_get(np);
 	phy->dev.of_node = np;
+	phy->is_pseudo_fixed_link = true;
 
 	ret = phy_device_register(phy);
 	if (ret) {
diff --git a/include/linux/phy.h b/include/linux/phy.h
index e5fb1d415961..962387a192f1 100644
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
 
@@ -688,6 +690,16 @@ static inline bool phy_interface_is_rgmii(struct phy_device *phydev)
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
2.5.0
