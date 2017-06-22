From: Lin Yun Sheng <linyunsheng@huawei.com>
Subject: [PATCH NET 1/2] net: phy: Add phy loopback support in net phy framework
Date: Thu, 22 Jun 2017 16:53:22 +0800
Message-ID: <1498121602-64322-1-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
        <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
        <gabriele.paoloni@huawei.com>, <john.garry@huawei.com>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>,
        <tremyfr@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>, <andrew@lunn.ch>, <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch add set_loopback in phy_driver, which is used by Mac
driver to enable or disable a phy. it also add a generic
genphy_loopback function, which use BMCR loopback bit to enable
or disable a phy.

Signed-off-by: Lin Yun Sheng <linyunsheng@huawei.com>
---
 drivers/net/phy/marvell.c    |  1 +
 drivers/net/phy/phy_device.c | 23 +++++++++++++++++++++++
 include/linux/phy.h          |  2 ++
 3 files changed, 26 insertions(+)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 57297ba..01a1586 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -2094,6 +2094,7 @@ static int m88e1510_probe(struct phy_device *phydev)
 		.get_sset_count = marvell_get_sset_count,
 		.get_strings = marvell_get_strings,
 		.get_stats = marvell_get_stats,
+		.set_loopback = genphy_loopback,
 	},
 	{
 		.phy_id = MARVELL_PHY_ID_88E1540,
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 1219eea..13b36fa 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -1628,6 +1628,27 @@ static int gen10g_resume(struct phy_device *phydev)
 	return 0;
 }
 
+int genphy_loopback(struct phy_device *phydev, bool enable)
+{
+	int value;
+
+	if (enable) {
+		value = phy_read(phydev, MII_BMCR);
+		phy_write(phydev, MII_BMCR, value | BMCR_LOOPBACK);
+	} else {
+		value = phy_read(phydev, MII_BMCR);
+		phy_write(phydev, MII_BMCR, value & ~BMCR_LOOPBACK);
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(genphy_loopback);
+
+static int gen10g_loopback(struct phy_device *phydev, bool enable)
+{
+	return 0;
+}
+
 static int __set_phy_supported(struct phy_device *phydev, u32 max_speed)
 {
 	/* The default values for phydev->supported are provided by the PHY
@@ -1874,6 +1895,7 @@ void phy_drivers_unregister(struct phy_driver *drv, int n)
 	.read_status	= genphy_read_status,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
+	.set_loopback	= genphy_loopback,
 }, {
 	.phy_id         = 0xffffffff,
 	.phy_id_mask    = 0xffffffff,
@@ -1885,6 +1907,7 @@ void phy_drivers_unregister(struct phy_driver *drv, int n)
 	.read_status    = gen10g_read_status,
 	.suspend        = gen10g_suspend,
 	.resume         = gen10g_resume,
+	.set_loopback	= gen10g_loopback,
 } };
 
 static int __init phy_init(void)
diff --git a/include/linux/phy.h b/include/linux/phy.h
index e76e4ad..9362e22 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -639,6 +639,7 @@ struct phy_driver {
 	int (*set_tunable)(struct phy_device *dev,
 			    struct ethtool_tunable *tuna,
 			    const void *data);
+	int (*set_loopback)(struct phy_device *dev, bool enable);
 };
 #define to_phy_driver(d) container_of(to_mdio_common_driver(d),		\
 				      struct phy_driver, mdiodrv)
@@ -825,6 +826,7 @@ void phy_attached_print(struct phy_device *phydev, const char *fmt, ...)
 int genphy_read_status(struct phy_device *phydev);
 int genphy_suspend(struct phy_device *phydev);
 int genphy_resume(struct phy_device *phydev);
+int genphy_loopback(struct phy_device *phydev, bool enable);
 int genphy_soft_reset(struct phy_device *phydev);
 static inline int genphy_no_soft_reset(struct phy_device *phydev)
 {
-- 
1.9.1
