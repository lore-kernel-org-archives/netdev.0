From: Kunihiko Hayashi <hayashi.kunihiko@socionext.com>
Subject: [PATCH net-next 3/3] net: phy: realtek: add RTL8201F phy-id and functions
Date: Fri,  8 Sep 2017 22:02:11 +0900
Message-ID: <1504875731-3680-4-git-send-email-hayashi.kunihiko@socionext.com>
References: <1504875731-3680-1-git-send-email-hayashi.kunihiko@socionext.com>
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        devicetree@vger.kernel.org,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Masami Hiramatsu <masami.hiramatsu@linaro.org>,
        Jassi Brar <jaswinder.singh@linaro.org>,
        Jongsung Kim <neidhard.kim@lge.com>,
        Kunihiko Hayashi <hayashi.kunihiko@socionext.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504875731-3680-1-git-send-email-hayashi.kunihiko@socionext.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jassi Brar <jaswinder.singh@linaro.org>

Add RTL8201F phy-id and the related functions to the driver.

The original patch is as follows:
https://patchwork.kernel.org/patch/2538341/

Signed-off-by: Jongsung Kim <neidhard.kim@lge.com>
Signed-off-by: Jassi Brar <jaswinder.singh@linaro.org>
Signed-off-by: Kunihiko Hayashi <hayashi.kunihiko@socionext.com>
---
 drivers/net/phy/realtek.c | 45 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 45 insertions(+)

diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
index 9cbe645..d9974ce 100644
--- a/drivers/net/phy/realtek.c
+++ b/drivers/net/phy/realtek.c
@@ -29,10 +29,23 @@
 #define RTL8211F_PAGE_SELECT	0x1f
 #define RTL8211F_TX_DELAY	0x100
 
+#define RTL8201F_ISR		0x1e
+#define RTL8201F_PAGE_SELECT	0x1f
+#define RTL8201F_IER		0x13
+
 MODULE_DESCRIPTION("Realtek PHY driver");
 MODULE_AUTHOR("Johnson Leung");
 MODULE_LICENSE("GPL");
 
+static int rtl8201_ack_interrupt(struct phy_device *phydev)
+{
+	int err;
+
+	err = phy_read(phydev, RTL8201F_ISR);
+
+	return (err < 0) ? err : 0;
+}
+
 static int rtl821x_ack_interrupt(struct phy_device *phydev)
 {
 	int err;
@@ -54,6 +67,25 @@ static int rtl8211f_ack_interrupt(struct phy_device *phydev)
 	return (err < 0) ? err : 0;
 }
 
+static int rtl8201_config_intr(struct phy_device *phydev)
+{
+	int err;
+
+	/* switch to page 7 */
+	phy_write(phydev, RTL8201F_PAGE_SELECT, 0x7);
+
+	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
+		err = phy_write(phydev, RTL8201F_IER,
+				BIT(13) | BIT(12) | BIT(11));
+	else
+		err = phy_write(phydev, RTL8201F_IER, 0);
+
+	/* restore to default page 0 */
+	phy_write(phydev, RTL8201F_PAGE_SELECT, 0x0);
+
+	return err;
+}
+
 static int rtl8211b_config_intr(struct phy_device *phydev)
 {
 	int err;
@@ -129,6 +161,18 @@ static struct phy_driver realtek_drvs[] = {
 		.config_aneg    = &genphy_config_aneg,
 		.read_status    = &genphy_read_status,
 	}, {
+		.phy_id		= 0x001cc816,
+		.name		= "RTL8201F 10/100Mbps Ethernet",
+		.phy_id_mask	= 0x001fffff,
+		.features	= PHY_BASIC_FEATURES,
+		.flags		= PHY_HAS_INTERRUPT,
+		.config_aneg	= &genphy_config_aneg,
+		.read_status	= &genphy_read_status,
+		.ack_interrupt	= &rtl8201_ack_interrupt,
+		.config_intr	= &rtl8201_config_intr,
+		.suspend	= genphy_suspend,
+		.resume		= genphy_resume,
+	}, {
 		.phy_id		= 0x001cc912,
 		.name		= "RTL8211B Gigabit Ethernet",
 		.phy_id_mask	= 0x001fffff,
@@ -181,6 +225,7 @@ static struct phy_driver realtek_drvs[] = {
 module_phy_driver(realtek_drvs);
 
 static struct mdio_device_id __maybe_unused realtek_tbl[] = {
+	{ 0x001cc816, 0x001fffff },
 	{ 0x001cc912, 0x001fffff },
 	{ 0x001cc914, 0x001fffff },
 	{ 0x001cc915, 0x001fffff },
-- 
2.7.4
