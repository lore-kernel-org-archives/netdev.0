From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH 2/2] net: phy: at803x: soft-reset PHY when link goes down
Date: Wed, 13 Nov 2013 22:07:50 +0100
Message-ID: <1384376870-7810-2-git-send-email-zonque@gmail.com>
References: <1384376870-7810-1-git-send-email-zonque@gmail.com>
Cc: davem@davemloft.net, marek.belisko@gmail.com, ujhelyi.m@gmail.com,
	Daniel Mack <zonque@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f50.google.com ([209.85.214.50]:34145 "EHLO
	mail-bk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981Ab3KMVH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 16:07:58 -0500
Received: by mail-bk0-f50.google.com with SMTP id v16so622920bkz.37
        for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 13:07:57 -0800 (PST)
In-Reply-To: <1384376870-7810-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the link goes down and up again quickly and multiple times in a
row, the AT803x PHY gets stuck and won't recover unless it is soft-reset
via the BMCR register.

Unfortunately, there is no way to detect this state, as all registers
contain perfectly sane values in such cases. Hence, the only option is
to always soft-reset the PHY when the link goes down.

Reset logic is based on a patch from Marek Belisko.

Signed-off-by: Daniel Mack <zonque@gmail.com>
Reported-and-tested-by: Marek Belisko <marek.belisko@gmail.com>
---
 drivers/net/phy/at803x.c | 52 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 52 insertions(+)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index bc71947..303c5ae 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -32,10 +32,56 @@
 #define AT803X_DEBUG_SYSTEM_MODE_CTRL		0x05
 #define AT803X_DEBUG_RGMII_TX_CLK_DLY		BIT(8)
 
+#define AT803X_BMCR_SOFTRESET			BIT(15)
+
 MODULE_DESCRIPTION("Atheros 803x PHY driver");
 MODULE_AUTHOR("Matus Ujhelyi");
 MODULE_LICENSE("GPL");
 
+struct at803x_priv {
+	bool phy_reset;
+};
+
+static void at803x_adjust_state(struct phy_device *phydev)
+{
+	struct at803x_priv *priv = phydev->priv;
+
+	if (phydev->state == PHY_NOLINK) {
+		unsigned long timeout;
+		unsigned int val;
+
+		if (priv->phy_reset)
+			return;
+
+		val = phy_read(phydev, MII_BMCR);
+		val |= AT803X_BMCR_SOFTRESET;
+		phy_write(phydev, MII_BMCR, val);
+
+		timeout = jiffies + HZ/10;
+		do {
+			cpu_relax();
+		} while ((phy_read(phydev, MII_BMCR) & AT803X_BMCR_SOFTRESET) &&
+			 time_after(timeout, jiffies));
+
+		WARN(phy_read(phydev, MII_BMCR) & AT803X_BMCR_SOFTRESET,
+		     "failed to soft-reset phy\n");
+
+		priv->phy_reset = true;
+	} else {
+		priv->phy_reset = false;
+	}
+}
+
+static int at803x_probe(struct phy_device *phydev)
+{
+	phydev->priv = devm_kzalloc(&phydev->dev, sizeof(struct at803x_priv),
+				    GFP_KERNEL);
+	if (!phydev->priv)
+		return -ENOMEM;
+
+	return 0;
+}
+
 static int at803x_set_wol(struct phy_device *phydev,
 			  struct ethtool_wolinfo *wol)
 {
@@ -197,6 +243,7 @@ static struct phy_driver at803x_driver[] = {
 	.phy_id		= 0x004dd072,
 	.name		= "Atheros 8035 ethernet",
 	.phy_id_mask	= 0xffffffef,
+	.probe		= at803x_probe,
 	.config_init	= at803x_config_init,
 	.set_wol	= at803x_set_wol,
 	.get_wol	= at803x_get_wol,
@@ -206,6 +253,7 @@ static struct phy_driver at803x_driver[] = {
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
+	.adjust_state	= at803x_adjust_state,
 	.driver		= {
 		.owner = THIS_MODULE,
 	},
@@ -214,6 +262,7 @@ static struct phy_driver at803x_driver[] = {
 	.phy_id		= 0x004dd076,
 	.name		= "Atheros 8030 ethernet",
 	.phy_id_mask	= 0xffffffef,
+	.probe		= at803x_probe,
 	.config_init	= at803x_config_init,
 	.set_wol	= at803x_set_wol,
 	.get_wol	= at803x_get_wol,
@@ -223,6 +272,7 @@ static struct phy_driver at803x_driver[] = {
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
+	.adjust_state	= at803x_adjust_state,
 	.driver		= {
 		.owner = THIS_MODULE,
 	},
@@ -231,6 +281,7 @@ static struct phy_driver at803x_driver[] = {
 	.phy_id		= 0x004dd074,
 	.name		= "Atheros 8031 ethernet",
 	.phy_id_mask	= 0xffffffef,
+	.probe		= at803x_probe,
 	.config_init	= at803x_config_init,
 	.set_wol	= at803x_set_wol,
 	.get_wol	= at803x_get_wol,
@@ -240,6 +291,7 @@ static struct phy_driver at803x_driver[] = {
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
+	.adjust_state	= at803x_adjust_state,
 	.driver		= {
 		.owner = THIS_MODULE,
 	},
-- 
1.8.4.2
