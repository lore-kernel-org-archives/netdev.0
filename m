From: Lin Yun Sheng <linyunsheng@huawei.com>
Subject: [PATCH NET V6 1/2] net: phy: Add phy loopback support in net phy framework
Date: Tue, 27 Jun 2017 19:00:44 +0800
Message-ID: <1498561245-93997-2-git-send-email-linyunsheng@huawei.com>
References: <1498561245-93997-1-git-send-email-linyunsheng@huawei.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([45.249.212.187]:9240 "EHLO
        szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752749AbdF0KaJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 06:30:09 -0400
In-Reply-To: <1498561245-93997-1-git-send-email-linyunsheng@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch add set_loopback in phy_driver, which is used by Mac
driver to enable or disable a phy. it also add a generic
genphy_loopback function, which use BMCR loopback bit to enable
or disable a phy.

Signed-off-by: Lin Yun Sheng <linyunsheng@huawei.com>
---
 drivers/net/phy/marvell.c    |  1 +
 drivers/net/phy/phy_device.c | 51 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/phy.h          |  5 +++++
 3 files changed, 57 insertions(+)

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
index 1219eea..1e08d62 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -1123,6 +1123,39 @@ int phy_resume(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(phy_resume);
 
+int phy_loopback(struct phy_device *phydev, bool enable)
+{
+	struct phy_driver *phydrv = to_phy_driver(phydev->mdio.dev.driver);
+	int ret = 0;
+
+	mutex_lock(&phydev->lock);
+
+	if (enable && phydev->loopback_enabled) {
+		ret = -EBUSY;
+		goto out;
+	}
+
+	if (!enable && !phydev->loopback_enabled) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	if (phydev->drv && phydrv->set_loopback)
+		ret = phydrv->set_loopback(phydev, enable);
+	else
+		ret = -EOPNOTSUPP;
+
+	if (ret)
+		goto out;
+
+	phydev->loopback_enabled = enable;
+
+out:
+	mutex_unlock(&phydev->lock);
+	return ret;
+}
+EXPORT_SYMBOL(phy_loopback);
+
 /* Generic PHY support and helper functions */
 
 /**
@@ -1628,6 +1661,23 @@ static int gen10g_resume(struct phy_device *phydev)
 	return 0;
 }
 
+int genphy_loopback(struct phy_device *phydev, bool enable)
+{
+	int value;
+
+	value = phy_read(phydev, MII_BMCR);
+	if (value < 0)
+		return value;
+
+	if (enable)
+		value |= BMCR_LOOPBACK;
+	else
+		value &= ~BMCR_LOOPBACK;
+
+	return phy_write(phydev, MII_BMCR, value);
+}
+EXPORT_SYMBOL(genphy_loopback);
+
 static int __set_phy_supported(struct phy_device *phydev, u32 max_speed)
 {
 	/* The default values for phydev->supported are provided by the PHY
@@ -1874,6 +1924,7 @@ void phy_drivers_unregister(struct phy_driver *drv, int n)
 	.read_status	= genphy_read_status,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
+	.set_loopback	= genphy_loopback,
 }, {
 	.phy_id         = 0xffffffff,
 	.phy_id_mask    = 0xffffffff,
diff --git a/include/linux/phy.h b/include/linux/phy.h
index e76e4ad..49c903dc 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -364,6 +364,7 @@ struct phy_c45_device_ids {
  * is_pseudo_fixed_link: Set to true if this phy is an Ethernet switch, etc.
  * has_fixups: Set to true if this phy has fixups/quirks.
  * suspended: Set to true if this phy has been suspended successfully.
+ * loopback_enabled: Set true if this phy has been loopbacked successfully.
  * state: state of the PHY for management purposes
  * dev_flags: Device-specific flags used by the PHY driver.
  * link_timeout: The number of timer firings to wait before the
@@ -400,6 +401,7 @@ struct phy_device {
 	bool is_pseudo_fixed_link;
 	bool has_fixups;
 	bool suspended;
+	bool loopback_enabled;
 
 	enum phy_state state;
 
@@ -639,6 +641,7 @@ struct phy_driver {
 	int (*set_tunable)(struct phy_device *dev,
 			    struct ethtool_tunable *tuna,
 			    const void *data);
+	int (*set_loopback)(struct phy_device *dev, bool enable);
 };
 #define to_phy_driver(d) container_of(to_mdio_common_driver(d),		\
 				      struct phy_driver, mdiodrv)
@@ -774,6 +777,7 @@ static inline void phy_device_free(struct phy_device *phydev) { }
 int phy_init_hw(struct phy_device *phydev);
 int phy_suspend(struct phy_device *phydev);
 int phy_resume(struct phy_device *phydev);
+int phy_loopback(struct phy_device *phydev, bool enable);
 struct phy_device *phy_attach(struct net_device *dev, const char *bus_id,
 			      phy_interface_t interface);
 struct phy_device *phy_find_first(struct mii_bus *bus);
@@ -825,6 +829,7 @@ void phy_attached_print(struct phy_device *phydev, const char *fmt, ...)
 int genphy_read_status(struct phy_device *phydev);
 int genphy_suspend(struct phy_device *phydev);
 int genphy_resume(struct phy_device *phydev);
+int genphy_loopback(struct phy_device *phydev, bool enable);
 int genphy_soft_reset(struct phy_device *phydev);
 static inline int genphy_no_soft_reset(struct phy_device *phydev)
 {
-- 
1.9.1
