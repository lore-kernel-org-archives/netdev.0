From: Jerome Brunet <jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next v4 1/4] net: phy: add an option to disable EEE advertisement
Date: Mon, 28 Nov 2016 16:50:25 +0100
Message-ID: <1480348229-25672-2-git-send-email-jbrunet@baylibre.com>
References: <1480348229-25672-1-git-send-email-jbrunet@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Jerome Brunet <jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
        Carlo Caione <carlo-KA+7E9HrN00dnm+yROfE0A@public.gmane.org>,
        Kevin Hilman <khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
        Andre Roth <neolynx-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
        linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>,
        Yegor Yefremov <yegorslists-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
        =?UTF-8?q?Andreas=20F=C3=A4rber?= <afaerber-l3A5Bk7waGM@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1480348229-25672-1-git-send-email-jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


This patch adds an option to disable EEE advertisement in the generic PHY
by providing a mask of prohibited modes corresponding to the value found in
the MDIO_AN_EEE_ADV register.

On some platforms, PHY Low power idle seems to be causing issues, even
breaking the link some cases. The patch provides a convenient way for these
platforms to disable EEE advertisement and work around the issue.

Signed-off-by: Jerome Brunet <jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Tested-by: Yegor Yefremov <yegorslists-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Tested-by: Andreas Färber <afaerber-l3A5Bk7waGM@public.gmane.org>
Tested-by: Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
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
index ba86c191a13e..cb4aca205cf8 100644
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
+	int broken = phydev->eee_broken_modes;
+	int old_adv, adv;
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

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
