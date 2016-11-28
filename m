From: Jerome Brunet <jbrunet@baylibre.com>
Subject: [PATCH net-next v3 1/4] net: phy: add an option to disable EEE advertisement
Date: Mon, 28 Nov 2016 10:46:46 +0100
Message-ID: <1480326409-25419-2-git-send-email-jbrunet@baylibre.com>
References: <1480326409-25419-1-git-send-email-jbrunet@baylibre.com>
Cc: Jerome Brunet <jbrunet@baylibre.com>,
        Carlo Caione <carlo@caione.org>,
        Kevin Hilman <khilman@baylibre.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre TORGUE <alexandre.torgue@st.com>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Andre Roth <neolynx@gmail.com>, Andrew Lunn <andrew@lunn.ch>,
        Neil Armstrong <narmstrong@baylibre.com>,
        linux-amlogic@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480326409-25419-1-git-send-email-jbrunet@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds an option to disable EEE advertisement in the generic PHY
by providing a mask of prohibited modes corresponding to the value found in
the MDIO_AN_EEE_ADV register.

On some platforms, PHY Low power idle seems to be causing issues, even
breaking the link some cases. The patch provides a convenient way for these
platforms to disable EEE advertisement and work around the issue.

Signed-off-by: Jerome Brunet <jbrunet@baylibre.com>
---
 drivers/net/phy/phy.c        |  3 ++
 drivers/net/phy/phy_device.c | 80 +++++++++++++++++++++++++++++++++++++++-----
 include/linux/phy.h          |  3 ++
 3 files changed, 77 insertions(+), 9 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 73adbaa9ac86..a3981cc6448a 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -1396,6 +1396,9 @@ int phy_ethtool_set_eee(struct phy_device *phydev, struct ethtool_eee *data)
 {
 	int val = ethtool_adv_to_mmd_eee_adv_t(data->advertised);
 
+	/* Mask prohibited EEE modes */
+	val &= ~phydev->eee_broken_modes;
+
 	phy_write_mmd_indirect(phydev, MDIO_AN_EEE_ADV, MDIO_MMD_AN, val);
 
 	return 0;
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index ba86c191a13e..83e52f1b80f2 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -1121,6 +1121,43 @@ static int genphy_config_advert(struct phy_device *phydev)
 }
 
 /**
+ * genphy_config_eee_advert - disable unwanted eee mode advertisement
+ * @phydev: target phy_device struct
+ *
+ * Description: Writes MDIO_AN_EEE_ADV after disabling unsupported energy
+ *   efficent ethernet modes. Returns 0 if the PHY's advertisement hasn't
+ *   changed, and 1 if it has changed.
+ */
+static int genphy_config_eee_advert(struct phy_device *phydev)
+{
+	u32 broken = phydev->eee_broken_modes;
+	u32 old_adv, adv;
+
+	/* Nothing to disable */
+	if (!broken)
+		return 0;
+
+	/* If the following call fails, we assume that EEE is not
+	 * supported by the phy. If we read 0, EEE is not advertised
+	 * In both case, we don't need to continue
+	 */
+	adv = phy_read_mmd_indirect(phydev, MDIO_AN_EEE_ADV, MDIO_MMD_AN);
+	if (adv <= 0)
+		return 0;
+
+	old_adv = adv;
+	adv &= ~broken;
+
+	/* Advertising remains unchanged with the broken mask */
+	if (old_adv == adv)
+		return 0;
+
+	phy_write_mmd_indirect(phydev, MDIO_AN_EEE_ADV, MDIO_MMD_AN, adv);
+
+	return 1;
+}
+
+/**
  * genphy_setup_forced - configures/forces speed/duplex from @phydev
  * @phydev: target phy_device struct
  *
@@ -1178,15 +1215,20 @@ EXPORT_SYMBOL(genphy_restart_aneg);
  */
 int genphy_config_aneg(struct phy_device *phydev)
 {
-	int result;
+	int err, changed;
+
+	changed = genphy_config_eee_advert(phydev);
 
 	if (AUTONEG_ENABLE != phydev->autoneg)
 		return genphy_setup_forced(phydev);
 
-	result = genphy_config_advert(phydev);
-	if (result < 0) /* error */
-		return result;
-	if (result == 0) {
+	err = genphy_config_advert(phydev);
+	if (err < 0) /* error */
+		return err;
+
+	changed |= err;
+
+	if (changed == 0) {
 		/* Advertisement hasn't changed, but maybe aneg was never on to
 		 * begin with?  Or maybe phy was isolated?
 		 */
@@ -1196,16 +1238,16 @@ int genphy_config_aneg(struct phy_device *phydev)
 			return ctl;
 
 		if (!(ctl & BMCR_ANENABLE) || (ctl & BMCR_ISOLATE))
-			result = 1; /* do restart aneg */
+			changed = 1; /* do restart aneg */
 	}
 
 	/* Only restart aneg if we are advertising something different
 	 * than we were before.
 	 */
-	if (result > 0)
-		result = genphy_restart_aneg(phydev);
+	if (changed > 0)
+		return genphy_restart_aneg(phydev);
 
-	return result;
+	return 0;
 }
 EXPORT_SYMBOL(genphy_config_aneg);
 
@@ -1563,6 +1605,21 @@ static void of_set_phy_supported(struct phy_device *phydev)
 		__set_phy_supported(phydev, max_speed);
 }
 
+static void of_set_phy_eee_broken(struct phy_device *phydev)
+{
+	struct device_node *node = phydev->mdio.dev.of_node;
+	u32 broken;
+
+	if (!IS_ENABLED(CONFIG_OF_MDIO))
+		return;
+
+	if (!node)
+		return;
+
+	if (!of_property_read_u32(node, "eee-broken-modes", &broken))
+		phydev->eee_broken_modes = broken;
+}
+
 /**
  * phy_probe - probe and init a PHY device
  * @dev: device to probe and init
@@ -1600,6 +1657,11 @@ static int phy_probe(struct device *dev)
 	of_set_phy_supported(phydev);
 	phydev->advertising = phydev->supported;
 
+	/* Get the EEE modes we want to prohibit. We will ask
+	 * the PHY stop advertising these mode later on
+	 */
+	of_set_phy_eee_broken(phydev);
+
 	/* Set the state to READY by default */
 	phydev->state = PHY_READY;
 
diff --git a/include/linux/phy.h b/include/linux/phy.h
index edde28ce163a..b53177fd38af 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -417,6 +417,9 @@ struct phy_device {
 	u32 advertising;
 	u32 lp_advertising;
 
+	/* Energy efficient ethernet modes which should be prohibited */
+	u32 eee_broken_modes;
+
 	int autoneg;
 
 	int link_timeout;
-- 
2.7.4
