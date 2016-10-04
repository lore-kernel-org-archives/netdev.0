From: Mike Looijmans <mike.looijmans@topic.nl>
Subject: [PATCH v2] phy: micrel.c: Enable ksz9031 energy-detect power-down mode
Date: Tue,  4 Oct 2016 07:52:04 +0200
Message-ID: <1475560324-23346-1-git-send-email-mike.looijmans@topic.nl>
References: <1475499870-11465-1-git-send-email-mike.looijmans@topic.nl>
Cc: f.fainelli@gmail.com, linux-kernel@vger.kernel.org,
        Mike Looijmans <mike.looijmans@topic.nl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atl4mhob12.myregisteredsite.com ([209.17.115.50]:48556 "EHLO
        atl4mhob12.myregisteredsite.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752014AbcJDFwR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 01:52:17 -0400
Received: from mailpod.hostingplatform.com ([10.30.71.206])
        by atl4mhob12.myregisteredsite.com (8.14.4/8.14.4) with ESMTP id u945qC8h029638
        for <netdev@vger.kernel.org>; Tue, 4 Oct 2016 01:52:14 -0400
In-Reply-To: <1475499870-11465-1-git-send-email-mike.looijmans@topic.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set bit 0 in register 1C.23 to enable the EDPD feature of the
KSZ9031 PHY. This reduces power consumption when the link is
down.

Signed-off-by: Mike Looijmans <mike.looijmans@topic.nl>
---
v2: Unconditionally enable EDPD mode

 drivers/net/phy/micrel.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 885ac9c..081df68 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -439,6 +439,10 @@ static int ksz9021_config_init(struct phy_device *phydev)
 #define MII_KSZ9031RN_TX_DATA_PAD_SKEW	6
 #define MII_KSZ9031RN_CLK_PAD_SKEW	8
 
+/* MMD Address 0x1C */
+#define MII_KSZ9031RN_EDPD		0x23
+#define MII_KSZ9031RN_EDPD_ENABLE	BIT(0)
+
 static int ksz9031_extended_write(struct phy_device *phydev,
 				  u8 mode, u32 dev_addr, u32 regnum, u16 val)
 {
@@ -510,6 +514,18 @@ static int ksz9031_center_flp_timing(struct phy_device *phydev)
 	return genphy_restart_aneg(phydev);
 }
 
+/* Enable energy-detect power-down mode */
+static int ksz9031_enable_edpd(struct phy_device *phydev)
+{
+	int reg;
+
+	reg = ksz9031_extended_read(phydev, OP_DATA, 0x1C, MII_KSZ9031RN_EDPD);
+	if (reg < 0)
+		return reg;
+	return ksz9031_extended_write(phydev, OP_DATA, 0x1C, MII_KSZ9031RN_EDPD,
+				      reg | MII_KSZ9031RN_EDPD_ENABLE);
+}
+
 static int ksz9031_config_init(struct phy_device *phydev)
 {
 	const struct device *dev = &phydev->mdio.dev;
@@ -525,6 +541,11 @@ static int ksz9031_config_init(struct phy_device *phydev)
 	};
 	static const char *control_skews[2] = {"txen-skew-ps", "rxdv-skew-ps"};
 	const struct device *dev_walker;
+	int result;
+
+	result = ksz9031_enable_edpd(phydev);
+	if (result < 0)
+		return result;
 
 	/* The Micrel driver has a deprecated option to place phy OF
 	 * properties in the MAC node. Walk up the tree of devices to
-- 
1.9.1
