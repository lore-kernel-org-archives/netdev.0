From: Lin Yun Sheng <linyunsheng@huawei.com>
Subject: [PATCH NET 2/2] net: hns: Use phy_driver to setup Phy loopback
Date: Thu, 22 Jun 2017 16:53:33 +0800
Message-ID: <1498121613-64572-1-git-send-email-linyunsheng@huawei.com>
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

Use function set_loopback in phy_driver to setup phy loopback
when doing ethtool self test.

Signed-off-by: Lin Yun Sheng <linyunsheng@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c | 64 ++++--------------------
 1 file changed, 10 insertions(+), 54 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index e95795b..660b51e 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -259,66 +259,22 @@ static int hns_nic_set_link_ksettings(struct net_device *net_dev,
 
 static int hns_nic_config_phy_loopback(struct phy_device *phy_dev, u8 en)
 {
-#define COPPER_CONTROL_REG 0
-#define PHY_POWER_DOWN BIT(11)
-#define PHY_LOOP_BACK BIT(14)
-	u16 val = 0;
 
-	if (phy_dev->is_c45) /* c45 branch adding for XGE PHY */
+	if (phy_dev->is_c45 || !phy_dev->drv)
+		return -ENOTSUPP;
+
+	if (!phy_dev->drv->resume || !phy_dev->drv->suspend ||
+	    !phy_dev->drv->set_loopback)
 		return -ENOTSUPP;
 
 	if (en) {
-		/* speed : 1000M */
-		phy_write(phy_dev, HNS_PHY_PAGE_REG, 2);
-		phy_write(phy_dev, 21, 0x1046);
-
-		phy_write(phy_dev, HNS_PHY_PAGE_REG, 0);
-		/* Force Master */
-		phy_write(phy_dev, 9, 0x1F00);
-
-		/* Soft-reset */
-		phy_write(phy_dev, 0, 0x9140);
-		/* If autoneg disabled,two soft-reset operations */
-		phy_write(phy_dev, 0, 0x9140);
-
-		phy_write(phy_dev, HNS_PHY_PAGE_REG, 0xFA);
-
-		/* Default is 0x0400 */
-		phy_write(phy_dev, 1, 0x418);
-
-		/* Force 1000M Link, Default is 0x0200 */
-		phy_write(phy_dev, 7, 0x20C);
-
-		/* Powerup Fiber */
-		phy_write(phy_dev, HNS_PHY_PAGE_REG, 1);
-		val = phy_read(phy_dev, COPPER_CONTROL_REG);
-		val &= ~PHY_POWER_DOWN;
-		phy_write(phy_dev, COPPER_CONTROL_REG, val);
-
-		/* Enable Phy Loopback */
-		phy_write(phy_dev, HNS_PHY_PAGE_REG, 0);
-		val = phy_read(phy_dev, COPPER_CONTROL_REG);
-		val |= PHY_LOOP_BACK;
-		val &= ~PHY_POWER_DOWN;
-		phy_write(phy_dev, COPPER_CONTROL_REG, val);
+		phy_dev->drv->resume(phy_dev);
+		phy_dev->drv->set_loopback(phy_dev, 1);
 	} else {
-		phy_write(phy_dev, HNS_PHY_PAGE_REG, 0xFA);
-		phy_write(phy_dev, 1, 0x400);
-		phy_write(phy_dev, 7, 0x200);
-
-		phy_write(phy_dev, HNS_PHY_PAGE_REG, 1);
-		val = phy_read(phy_dev, COPPER_CONTROL_REG);
-		val |= PHY_POWER_DOWN;
-		phy_write(phy_dev, COPPER_CONTROL_REG, val);
-
-		phy_write(phy_dev, HNS_PHY_PAGE_REG, 0);
-		phy_write(phy_dev, 9, 0xF00);
-
-		val = phy_read(phy_dev, COPPER_CONTROL_REG);
-		val &= ~PHY_LOOP_BACK;
-		val |= PHY_POWER_DOWN;
-		phy_write(phy_dev, COPPER_CONTROL_REG, val);
+		phy_dev->drv->set_loopback(phy_dev, 0);
+		phy_dev->drv->suspend(phy_dev);
 	}
+
 	return 0;
 }
 
-- 
1.9.1
