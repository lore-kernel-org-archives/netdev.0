From: Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>
Subject: [PATCH v2 3/4] net: phy: realtek: add disable RX
 internal delay mode
Date: Tue, 22 Aug 2017 12:03:59 +0800
Message-ID: <20170822040400.12166-4-icenowy@aosc.io>
References: <20170822040400.12166-1-icenowy@aosc.io>
Reply-To: icenowy-h8G6r0blFSE@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	Icenowy Zheng <icenowy-ymACFijhrKM@public.gmane.org>
To: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-sunxi+bncBDS6XAN6ZADRBVW253GAKGQE7TNTAAI-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20170822040400.12166-1-icenowy-h8G6r0blFSE@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

From: Icenowy Zheng <icenowy-ymACFijhrKM@public.gmane.org>

Some RTL8211E chips have broken GbE function, which needs a hack to
fix. It's said that this fix will affect the performance on not-buggy
PHYs, so it should only be enabled on boards with the broken PHY.
Currently only some Pine64+ boards are known to have this issue.

This hack is said to disable RX relay for RTL8211E according to Realtek.
So implement it as RGMII-TXID mode.

As this hack is not documented on the datasheet at all, it contains
magic numbers, and could not be revealed. These magic numbers are
received from Realtek via Pine64.

Signed-off-by: Icenowy Zheng <icenowy-ymACFijhrKM@public.gmane.org>
---
Changes in v2:
- Used RGMII_TXID phy mode.

 drivers/net/phy/realtek.c | 31 +++++++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)

diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
index d820d00addf6..8306b6abaaa8 100644
--- a/drivers/net/phy/realtek.c
+++ b/drivers/net/phy/realtek.c
@@ -13,6 +13,7 @@
  * option) any later version.
  *
  */
+#include <linux/of.h>
 #include <linux/phy.h>
 #include <linux/module.h>
 
@@ -26,6 +27,8 @@
 #define RTL8211_PAGE_SELECT	0x1f
 
 #define RTL8211E_INER_LINK_STATUS 0x400
+#define RTL8211E_EXT_PAGE_SELECT 0x1e
+#define RTL8211E_EXT_PAGE	0x7
 
 #define RTL8211F_INER_LINK_STATUS 0x0010
 #define RTL8211F_INSR		0x1d
@@ -121,6 +124,33 @@ static int rtl8211f_config_init(struct phy_device *phydev)
 	return 0;
 }
 
+static int rtl8211e_config_init(struct phy_device *phydev)
+{
+	struct device *dev = &phydev->mdio.dev;
+	struct device_node *of_node = dev->of_node;
+	int ret;
+
+	ret = genphy_config_init(phydev);
+	if (ret < 0)
+		return ret;
+
+	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID) {
+		/* Disable the RX internal delay here.
+		 *
+		 * All the magic numbers are not documented on RTL8211E
+		 * datasheet. They're said to be from Realtek by Pine64.
+		 */
+		phy_write(phydev, RTL8211_PAGE_SELECT, RTL8211E_EXT_PAGE);
+		phy_write(phydev, RTL8211E_EXT_PAGE_SELECT, 0xa4);
+		phy_write(phydev, 0x1c, 0xb591);
+
+		/* Restore to default page 0 */
+		phy_write(phydev, RTL8211_PAGE_SELECT, 0);
+	}
+
+	return 0;
+}
+
 static struct phy_driver realtek_drvs[] = {
 	{
 		.phy_id         = 0x00008201,
@@ -159,6 +189,7 @@ static struct phy_driver realtek_drvs[] = {
 		.features	= PHY_GBIT_FEATURES,
 		.flags		= PHY_HAS_INTERRUPT,
 		.config_aneg	= &genphy_config_aneg,
+		.config_init	= rtl8211e_config_init,
 		.read_status	= &genphy_read_status,
 		.ack_interrupt	= &rtl821x_ack_interrupt,
 		.config_intr	= &rtl8211e_config_intr,
-- 
2.13.5
