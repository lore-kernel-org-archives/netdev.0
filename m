From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH RFC net-next 2/3] net: phy: read whether PHY supports stopping clock during LPI
Date: Mon, 27 Mar 2017 11:47:20 -0700
Message-ID: <20170327184721.30275-3-f.fainelli@gmail.com>
References: <20170327184721.30275-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, rmk+kernel@armlinux.org.uk,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:36417 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751522AbdC0Sr3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 14:47:29 -0400
Received: by mail-qk0-f196.google.com with SMTP id r142so5423048qke.3
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 11:47:28 -0700 (PDT)
In-Reply-To: <20170327184721.30275-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to use phy_init_eee() correctly, in particular the clk_stop
argument, we need to know whether the Ethernet PHY supports stopping its
clock.

Right now, we would have to call phy_init_eee(phydev, 1), see if that
tails, and call again with phy_init_eee(phydev, 0) to enable EEE this is
not an acceptable API use.

Update phy_init_hw() to read whether the PHY supports this, and retain
that information in the phydev structure so we can re-use it later.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy_device.c | 23 ++++++++++++++++++++++-
 include/linux/phy.h          |  2 ++
 2 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 1219eeab69d1..2755d77626f7 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -837,6 +837,21 @@ static int phy_poll_reset(struct phy_device *phydev)
 	return 0;
 }
 
+static void phy_read_clock_stop_capable(struct phy_device *phydev)
+{
+	int ret;
+
+	/* Read if the PHY supports stopping its clocks (reg 3.1) */
+	ret = phy_read_mmd_indirect(phydev, MDIO_MMD_PCS, MDIO_STAT1,
+			            phydev->addr);
+	if (ret < 0)
+		return;
+
+	/* Do not make this fatal */
+	if (ret & MDIO_STAT1_CLOCK_STOP_CAPABLE)
+		phydev->clk_stop_cap = true;
+}
+
 int phy_init_hw(struct phy_device *phydev)
 {
 	int ret = 0;
@@ -856,7 +871,13 @@ int phy_init_hw(struct phy_device *phydev)
 	if (ret < 0)
 		return ret;
 
-	return phydev->drv->config_init(phydev);
+	ret = phydev->drv->config_init(phydev);
+	if (ret < 0)
+		return ret;
+
+	phy_read_clock_stop_capable(phydev);
+
+	return 0;
 }
 EXPORT_SYMBOL(phy_init_hw);
 
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 624cecf69c28..c61fd519f341 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -357,6 +357,7 @@ struct phy_c45_device_ids {
  * is_pseudo_fixed_link: Set to true if this phy is an Ethernet switch, etc.
  * has_fixups: Set to true if this phy has fixups/quirks.
  * suspended: Set to true if this phy has been suspended successfully.
+ * clk_stop_cap: Set to true if this phy supports TX clock stopping during EEE.
  * state: state of the PHY for management purposes
  * dev_flags: Device-specific flags used by the PHY driver.
  * link_timeout: The number of timer firings to wait before the
@@ -393,6 +394,7 @@ struct phy_device {
 	bool is_pseudo_fixed_link;
 	bool has_fixups;
 	bool suspended;
+	bool clk_stop_cap;
 
 	enum phy_state state;
 
-- 
2.9.3
