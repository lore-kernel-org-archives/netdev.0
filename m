From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH v2 3/3] net: phy: at803x: Add support for hardware reset
Date: Wed, 18 Jun 2014 11:01:43 +0200
Message-ID: <1403082103-23709-4-git-send-email-zonque@gmail.com>
References: <1403082103-23709-1-git-send-email-zonque@gmail.com>
Cc: davem@davemloft.net, marek.belisko@gmail.com, ujhelyi.m@gmail.com,
	Daniel Mack <zonque@gmail.com>
To: netdev@vger.kernel.org, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:41038 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965346AbaFRJB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 05:01:58 -0400
Received: by mail-wi0-f171.google.com with SMTP id n15so7199458wiw.4
        for <netdev@vger.kernel.org>; Wed, 18 Jun 2014 02:01:56 -0700 (PDT)
In-Reply-To: <1403082103-23709-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The AT8030 will enter a FIFO error mode if a packet is transmitted while
the cable is unplugged. This hardware issue is acknowledged by the
vendor, and the only proposed solution is to conduct a hardware reset
via the external pin each time the link goes down. There is apparantly
no way to fix up the state via the register set.

This patch adds support for reading a 'reset-gpios' property from the DT
node of the PHY. If present, this gpio is used to apply a hardware reset
each time a 'link down' condition is detected. All relevant registers
are read out before, and written back after the reset cycle.

Doing this every time the link goes down might seem like overkill, but
there is unfortunately no way of figuring out whether the PHY is in
such a lock-up state. Hence, this is the only way of reliably fixing up
things.

Signed-off-by: Daniel Mack <zonque@gmail.com>
---
 drivers/net/phy/at803x.c | 185 ++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 144 insertions(+), 41 deletions(-)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index 045e446..ce502f0 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -16,9 +16,13 @@
 #include <linux/string.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/of_gpio.h>
+#include <linux/gpio/consumer.h>
 
 #define AT803X_INTR_ENABLE			0x12
 #define AT803X_INTR_STATUS			0x13
+#define AT803X_SMART_SPEED			0x14
+#define AT803X_LED_CONTROL			0x18
 #define AT803X_WOL_ENABLE			0x01
 #define AT803X_DEVICE_ADDR			0x03
 #define AT803X_LOC_MAC_ADDR_0_15_OFFSET		0x804C
@@ -43,6 +47,44 @@ MODULE_DESCRIPTION("Atheros 803x PHY driver");
 MODULE_AUTHOR("Matus Ujhelyi");
 MODULE_LICENSE("GPL");
 
+struct at803x_priv {
+	bool phy_reset:1;
+	struct gpio_desc *gpiod_reset;
+};
+
+struct at803x_context {
+	u16 bmcr;
+	u16 advertise;
+	u16 control1000;
+	u16 int_enable;
+	u16 smart_speed;
+	u16 led_control;
+};
+
+/* save relevant PHY registers to private copy */
+static void at803x_context_save(struct phy_device *phydev,
+				struct at803x_context *context)
+{
+	context->bmcr = phy_read(phydev, MII_BMCR);
+	context->advertise = phy_read(phydev, MII_ADVERTISE);
+	context->control1000 = phy_read(phydev, MII_CTRL1000);
+	context->int_enable = phy_read(phydev, AT803X_INTR_ENABLE);
+	context->smart_speed = phy_read(phydev, AT803X_SMART_SPEED);
+	context->led_control = phy_read(phydev, AT803X_LED_CONTROL);
+}
+
+/* restore relevant PHY registers from private copy */
+static void at803x_context_restore(struct phy_device *phydev,
+				   const struct at803x_context *context)
+{
+	phy_write(phydev, MII_BMCR, context->bmcr);
+	phy_write(phydev, MII_ADVERTISE, context->advertise);
+	phy_write(phydev, MII_CTRL1000, context->control1000);
+	phy_write(phydev, AT803X_INTR_ENABLE, context->int_enable);
+	phy_write(phydev, AT803X_SMART_SPEED, context->smart_speed);
+	phy_write(phydev, AT803X_LED_CONTROL, context->led_control);
+}
+
 static int at803x_set_wol(struct phy_device *phydev,
 			  struct ethtool_wolinfo *wol)
 {
@@ -146,6 +188,26 @@ static int at803x_resume(struct phy_device *phydev)
 	return 0;
 }
 
+static int at803x_probe(struct phy_device *phydev)
+{
+	struct device *dev = &phydev->dev;
+	struct at803x_priv *priv;
+
+	priv = devm_kzalloc(dev, sizeof(priv), GFP_KERNEL);
+	if (!priv)
+		return -ENOMEM;
+
+	priv->gpiod_reset = devm_gpiod_get(dev, "reset");
+	if (IS_ERR(priv->gpiod_reset))
+		priv->gpiod_reset = NULL;
+	else
+		gpiod_direction_output(priv->gpiod_reset, 1);
+
+	phydev->priv = priv;
+
+	return 0;
+}
+
 static int at803x_config_init(struct phy_device *phydev)
 {
 	int ret;
@@ -193,58 +255,99 @@ static int at803x_config_intr(struct phy_device *phydev)
 	return err;
 }
 
+static void at803x_link_change_notify(struct phy_device *phydev)
+{
+	struct at803x_priv *priv = phydev->priv;
+
+	/*
+	 * Conduct a hardware reset for AT8030 every time a link loss is
+	 * signalled. This is necessary to circumvent a hardware bug that
+	 * occurs when the cable is unplugged while TX packets are pending
+	 * in the FIFO. In such cases, the FIFO enters an error mode it
+	 * cannot recover from by software.
+	 */
+	if (phydev->drv->phy_id == ATH8030_PHY_ID) {
+		if (phydev->state == PHY_NOLINK) {
+			if (priv->gpiod_reset && !priv->phy_reset) {
+				struct at803x_context context;
+
+				at803x_context_save(phydev, &context);
+
+				gpiod_set_value(priv->gpiod_reset, 0);
+				msleep(1);
+				gpiod_set_value(priv->gpiod_reset, 1);
+				msleep(1);
+
+				at803x_context_restore(phydev, &context);
+
+				dev_dbg(&phydev->dev, "%s(): phy was reset\n",
+					__func__);
+				priv->phy_reset = true;
+			}
+		} else {
+			priv->phy_reset = false;
+		}
+	}
+}
+
 static struct phy_driver at803x_driver[] = {
 {
 	/* ATHEROS 8035 */
-	.phy_id		= ATH8035_PHY_ID,
-	.name		= "Atheros 8035 ethernet",
-	.phy_id_mask	= 0xffffffef,
-	.config_init	= at803x_config_init,
-	.set_wol	= at803x_set_wol,
-	.get_wol	= at803x_get_wol,
-	.suspend	= at803x_suspend,
-	.resume		= at803x_resume,
-	.features	= PHY_GBIT_FEATURES,
-	.flags		= PHY_HAS_INTERRUPT,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
-	.driver		= {
+	.phy_id			= ATH8035_PHY_ID,
+	.name			= "Atheros 8035 ethernet",
+	.phy_id_mask		= 0xffffffef,
+	.probe			= at803x_probe,
+	.config_init		= at803x_config_init,
+	.link_change_notify	= at803x_link_change_notify,
+	.set_wol		= at803x_set_wol,
+	.get_wol		= at803x_get_wol,
+	.suspend		= at803x_suspend,
+	.resume			= at803x_resume,
+	.features		= PHY_GBIT_FEATURES,
+	.flags			= PHY_HAS_INTERRUPT,
+	.config_aneg		= genphy_config_aneg,
+	.read_status		= genphy_read_status,
+	.driver			= {
 		.owner = THIS_MODULE,
 	},
 }, {
 	/* ATHEROS 8030 */
-	.phy_id		= ATH8030_PHY_ID,
-	.name		= "Atheros 8030 ethernet",
-	.phy_id_mask	= 0xffffffef,
-	.config_init	= at803x_config_init,
-	.set_wol	= at803x_set_wol,
-	.get_wol	= at803x_get_wol,
-	.suspend	= at803x_suspend,
-	.resume		= at803x_resume,
-	.features	= PHY_GBIT_FEATURES,
-	.flags		= PHY_HAS_INTERRUPT,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
-	.driver		= {
+	.phy_id			= ATH8030_PHY_ID,
+	.name			= "Atheros 8030 ethernet",
+	.phy_id_mask		= 0xffffffef,
+	.probe			= at803x_probe,
+	.config_init		= at803x_config_init,
+	.link_change_notify	= at803x_link_change_notify,
+	.set_wol		= at803x_set_wol,
+	.get_wol		= at803x_get_wol,
+	.suspend		= at803x_suspend,
+	.resume			= at803x_resume,
+	.features		= PHY_GBIT_FEATURES,
+	.flags			= PHY_HAS_INTERRUPT,
+	.config_aneg		= genphy_config_aneg,
+	.read_status		= genphy_read_status,
+	.driver			= {
 		.owner = THIS_MODULE,
 	},
 }, {
 	/* ATHEROS 8031 */
-	.phy_id		= ATH8031_PHY_ID,
-	.name		= "Atheros 8031 ethernet",
-	.phy_id_mask	= 0xffffffef,
-	.config_init	= at803x_config_init,
-	.set_wol	= at803x_set_wol,
-	.get_wol	= at803x_get_wol,
-	.suspend	= at803x_suspend,
-	.resume		= at803x_resume,
-	.features	= PHY_GBIT_FEATURES,
-	.flags		= PHY_HAS_INTERRUPT,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
-	.ack_interrupt  = &at803x_ack_interrupt,
-	.config_intr    = &at803x_config_intr,
-	.driver		= {
+	.phy_id			= ATH8031_PHY_ID,
+	.name			= "Atheros 8031 ethernet",
+	.phy_id_mask		= 0xffffffef,
+	.probe			= at803x_probe,
+	.config_init		= at803x_config_init,
+	.link_change_notify	= at803x_link_change_notify,
+	.set_wol		= at803x_set_wol,
+	.get_wol		= at803x_get_wol,
+	.suspend		= at803x_suspend,
+	.resume			= at803x_resume,
+	.features		= PHY_GBIT_FEATURES,
+	.flags			= PHY_HAS_INTERRUPT,
+	.config_aneg		= genphy_config_aneg,
+	.read_status		= genphy_read_status,
+	.ack_interrupt		= &at803x_ack_interrupt,
+	.config_intr		= &at803x_config_intr,
+	.driver			= {
 		.owner = THIS_MODULE,
 	},
 } };
-- 
1.9.3
