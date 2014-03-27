From: Zhao Qiang <B45475@freescale.com>
Subject: [PATCH] phy/at8031: enable at8031 to work on interrupt mode
Date: Thu, 27 Mar 2014 14:18:36 +0800
Message-ID: <1395901116-16034-1-git-send-email-B45475@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <davem@davemloft.net>,
	<mugunthanvnm@ti.com>, <zonque@gmail.com>,
	<helmut.schaa@googlemail.com>, <R63061@freescale.com>,
	Zhao Qiang <B45475@freescale.com>
To: <linuxppc-dev@lists.ozlabs.org>, <netdev@vger.kernel.org>,
	<B07421@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The at8031 can work on polling mode and interrupt mode.
Add ack_interrupt and config intr funcs to enable
interrupt mode for it.

Signed-off-by: Zhao Qiang <B45475@freescale.com>
---
 drivers/net/phy/at803x.c | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index bc71947..d034ef5 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -27,6 +27,9 @@
 #define AT803X_MMD_ACCESS_CONTROL		0x0D
 #define AT803X_MMD_ACCESS_CONTROL_DATA		0x0E
 #define AT803X_FUNC_DATA			0x4003
+#define AT803X_INER				0x0012
+#define AT803X_INER_INIT			0xec00
+#define AT803X_INSR				0x0013
 #define AT803X_DEBUG_ADDR			0x1D
 #define AT803X_DEBUG_DATA			0x1E
 #define AT803X_DEBUG_SYSTEM_MODE_CTRL		0x05
@@ -191,6 +194,31 @@ static int at803x_config_init(struct phy_device *phydev)
 	return 0;
 }
 
+static int at803x_ack_interrupt(struct phy_device *phydev)
+{
+	int err;
+
+	err = phy_read(phydev, AT803X_INSR);
+
+	return (err < 0) ? err : 0;
+}
+
+static int at803x_config_intr(struct phy_device *phydev)
+{
+	int err;
+	int value;
+
+	value = phy_read(phydev, AT803X_INER);
+
+	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
+		err = phy_write(phydev, AT803X_INER,
+				(value | AT803X_INER_INIT));
+	else
+		err = phy_write(phydev, AT803X_INER, value);
+
+	return err;
+}
+
 static struct phy_driver at803x_driver[] = {
 {
 	/* ATHEROS 8035 */
@@ -240,6 +268,8 @@ static struct phy_driver at803x_driver[] = {
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
+	.ack_interrupt  = &at803x_ack_interrupt,
+	.config_intr    = &at803x_config_intr,
 	.driver		= {
 		.owner = THIS_MODULE,
 	},
-- 
1.8.5
