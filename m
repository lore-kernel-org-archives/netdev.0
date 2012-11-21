From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: [PATCH 1/1 v2] net: add micrel KSZ8873MLL switch support
Date: Wed, 21 Nov 2012 16:38:07 +0100
Message-ID: <1353512287-24048-1-git-send-email-plagnioj@jcrosoft.com>
References: <1353493630-30867-1-git-send-email-plagnioj@jcrosoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
 Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1353493630-30867-1-git-send-email-plagnioj@jcrosoft.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

this will allow to detect the link between the switch and the soc

Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Cc: netdev@vger.kernel.org
---
v2:

	fix typo in the phy_driver name

Best Regards,
J.
 drivers/net/phy/micrel.c   |   44 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/micrel_phy.h |    1 +
 2 files changed, 45 insertions(+)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 2165d5f..b983596 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -127,6 +127,39 @@ static int ks8051_config_init(struct phy_device *phydev)
 	return 0;
 }
 
+#define KSZ8873MLL_GLOBAL_CONTROL_4	0x06
+#define KSZ8873MLL_GLOBAL_CONTROL_4_DUPLEX	(1 << 6)
+#define KSZ8873MLL_GLOBAL_CONTROL_4_SPEED	(1 << 4)
+int ksz8873mll_read_status(struct phy_device *phydev)
+{
+	int regval;
+
+	/* dummy read */
+	regval = phy_read(phydev, KSZ8873MLL_GLOBAL_CONTROL_4);
+
+	regval = phy_read(phydev, KSZ8873MLL_GLOBAL_CONTROL_4);
+
+	if (regval & KSZ8873MLL_GLOBAL_CONTROL_4_DUPLEX)
+		phydev->duplex = DUPLEX_HALF;
+	else
+		phydev->duplex = DUPLEX_FULL;
+
+	if (regval & KSZ8873MLL_GLOBAL_CONTROL_4_SPEED)
+		phydev->speed = SPEED_10;
+	else
+		phydev->speed = SPEED_100;
+
+	phydev->link = 1;
+	phydev->pause = phydev->asym_pause = 0;
+
+	return 0;
+}
+
+static int ksz8873mll_config_aneg(struct phy_device *phydev)
+{
+	return 0;
+}
+
 static struct phy_driver ksphy_driver[] = {
 {
 	.phy_id		= PHY_ID_KS8737,
@@ -204,6 +237,16 @@ static struct phy_driver ksphy_driver[] = {
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= ksz9021_config_intr,
 	.driver		= { .owner = THIS_MODULE, },
+}, {
+	.phy_id		= PHY_ID_KSZ8873MLL,
+	.phy_id_mask	= 0x00fffff0,
+	.name		= "Micrel KSZ8873MLL Switch",
+	.features	= (SUPPORTED_Pause | SUPPORTED_Asym_Pause),
+	.flags		= PHY_HAS_MAGICANEG,
+	.config_init	= kszphy_config_init,
+	.config_aneg	= ksz8873mll_config_aneg,
+	.read_status	= ksz8873mll_read_status,
+	.driver		= { .owner = THIS_MODULE, },
 } };
 
 static int __init ksphy_init(void)
@@ -232,6 +275,7 @@ static struct mdio_device_id __maybe_unused micrel_tbl[] = {
 	{ PHY_ID_KSZ8021, 0x00ffffff },
 	{ PHY_ID_KSZ8041, 0x00fffff0 },
 	{ PHY_ID_KSZ8051, 0x00fffff0 },
+	{ PHY_ID_KSZ8873MLL, 0x00fffff0 },
 	{ }
 };
 
diff --git a/include/linux/micrel_phy.h b/include/linux/micrel_phy.h
index de20120..adfe8c0 100644
--- a/include/linux/micrel_phy.h
+++ b/include/linux/micrel_phy.h
@@ -15,6 +15,7 @@
 
 #define MICREL_PHY_ID_MASK	0x00fffff0
 
+#define PHY_ID_KSZ8873MLL	0x000e7237
 #define PHY_ID_KSZ9021		0x00221610
 #define PHY_ID_KS8737		0x00221720
 #define PHY_ID_KSZ8021		0x00221555
-- 
1.7.10.4
