From: Jerome Brunet <jbrunet@baylibre.com>
Subject: [PATCH net 1/3] net: phy: realtek: add eee advertisement disable options
Date: Tue, 15 Nov 2016 15:29:12 +0100
Message-ID: <1479220154-25851-2-git-send-email-jbrunet@baylibre.com>
References: <1479220154-25851-1-git-send-email-jbrunet@baylibre.com>
Cc: Jerome Brunet <jbrunet@baylibre.com>,
        Carlo Caione <carlo@caione.org>,
        Kevin Hilman <khilman@baylibre.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre TORGUE <alexandre.torgue@st.com>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Andre Roth <neolynx@gmail.com>,
        Neil Armstrong <narmstrong@baylibre.com>,
        linux-amlogic@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479220154-25851-1-git-send-email-jbrunet@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On some platforms, energy efficient ethernet with rtl8211 devices is
causing issue, like throughput drop or broken link.

This was reported on the OdroidC2 (DWMAC + RTL8211F). While the issue root
cause is not fully understood yet, disabling EEE advertisement prevent auto
negotiation from enabling EEE.

This patch provides options to disable 1000T and 100TX EEE advertisement
individually for the realtek phys supporting this feature.

Reported-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Alexandre TORGUE <alexandre.torgue@st.com>
Signed-off-by: Jerome Brunet <jbrunet@baylibre.com>
Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
Tested-by: Andre Roth <neolynx@gmail.com>
---
 drivers/net/phy/realtek.c | 65 ++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 64 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
index aadd6e9f54ad..77235fd5faaf 100644
--- a/drivers/net/phy/realtek.c
+++ b/drivers/net/phy/realtek.c
@@ -15,6 +15,12 @@
  */
 #include <linux/phy.h>
 #include <linux/module.h>
+#include <linux/of.h>
+
+struct rtl8211x_phy_priv {
+	bool eee_1000t_disable;
+	bool eee_100tx_disable;
+};
 
 #define RTL821x_PHYSR		0x11
 #define RTL821x_PHYSR_DUPLEX	0x2000
@@ -93,12 +99,44 @@ static int rtl8211f_config_intr(struct phy_device *phydev)
 	return err;
 }
 
+static void rtl8211x_clear_eee_adv(struct phy_device *phydev)
+{
+	struct rtl8211x_phy_priv *priv = phydev->priv;
+	u16 val;
+
+	if (priv->eee_1000t_disable || priv->eee_100tx_disable) {
+		val = phy_read_mmd_indirect(phydev, MDIO_AN_EEE_ADV,
+					    MDIO_MMD_AN);
+
+		if (priv->eee_1000t_disable)
+			val &= ~MDIO_AN_EEE_ADV_1000T;
+		if (priv->eee_100tx_disable)
+			val &= ~MDIO_AN_EEE_ADV_100TX;
+
+		phy_write_mmd_indirect(phydev, MDIO_AN_EEE_ADV,
+				       MDIO_MMD_AN, val);
+	}
+}
+
+static int rtl8211x_config_init(struct phy_device *phydev)
+{
+	int ret;
+
+	ret = genphy_config_init(phydev);
+	if (ret < 0)
+		return ret;
+
+	rtl8211x_clear_eee_adv(phydev);
+
+	return 0;
+}
+
 static int rtl8211f_config_init(struct phy_device *phydev)
 {
 	int ret;
 	u16 reg;
 
-	ret = genphy_config_init(phydev);
+	ret = rtl8211x_config_init(phydev);
 	if (ret < 0)
 		return ret;
 
@@ -115,6 +153,26 @@ static int rtl8211f_config_init(struct phy_device *phydev)
 	return 0;
 }
 
+static int rtl8211x_phy_probe(struct phy_device *phydev)
+{
+	struct device *dev = &phydev->mdio.dev;
+	struct device_node *of_node = dev->of_node;
+	struct rtl8211x_phy_priv *priv;
+
+	priv = devm_kzalloc(dev, sizeof(*priv), GFP_KERNEL);
+	if (!priv)
+		return -ENOMEM;
+
+	priv->eee_1000t_disable =
+		of_property_read_bool(of_node, "realtek,disable-eee-1000t");
+	priv->eee_100tx_disable =
+		of_property_read_bool(of_node, "realtek,disable-eee-100tx");
+
+	phydev->priv = priv;
+
+	return 0;
+}
+
 static struct phy_driver realtek_drvs[] = {
 	{
 		.phy_id         = 0x00008201,
@@ -140,7 +198,9 @@ static struct phy_driver realtek_drvs[] = {
 		.phy_id_mask	= 0x001fffff,
 		.features	= PHY_GBIT_FEATURES,
 		.flags		= PHY_HAS_INTERRUPT,
+		.probe		= &rtl8211x_phy_probe,
 		.config_aneg	= genphy_config_aneg,
+		.config_init	= &rtl8211x_config_init,
 		.read_status	= genphy_read_status,
 		.ack_interrupt	= rtl821x_ack_interrupt,
 		.config_intr	= rtl8211e_config_intr,
@@ -152,7 +212,9 @@ static struct phy_driver realtek_drvs[] = {
 		.phy_id_mask	= 0x001fffff,
 		.features	= PHY_GBIT_FEATURES,
 		.flags		= PHY_HAS_INTERRUPT,
+		.probe		= &rtl8211x_phy_probe,
 		.config_aneg	= &genphy_config_aneg,
+		.config_init	= &rtl8211x_config_init,
 		.read_status	= &genphy_read_status,
 		.ack_interrupt	= &rtl821x_ack_interrupt,
 		.config_intr	= &rtl8211e_config_intr,
@@ -164,6 +226,7 @@ static struct phy_driver realtek_drvs[] = {
 		.phy_id_mask	= 0x001fffff,
 		.features	= PHY_GBIT_FEATURES,
 		.flags		= PHY_HAS_INTERRUPT,
+		.probe		= &rtl8211x_phy_probe,
 		.config_aneg	= &genphy_config_aneg,
 		.config_init	= &rtl8211f_config_init,
 		.read_status	= &genphy_read_status,
-- 
2.7.4
