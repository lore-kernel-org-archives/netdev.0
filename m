From: Lin Yun Sheng <linyunsheng@huawei.com>
Subject: [PATCH NET v2 2/2] net: hns: Use phy_driver to setup Phy loopback
Date: Fri, 23 Jun 2017 15:54:33 +0800
Message-ID: <1498204473-194648-3-git-send-email-linyunsheng@huawei.com>
References: <1498204473-194648-1-git-send-email-linyunsheng@huawei.com>
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
Received: from szxga02-in.huawei.com ([45.249.212.188]:8824 "EHLO
        szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752370AbdFWHXr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 03:23:47 -0400
In-Reply-To: <1498204473-194648-1-git-send-email-linyunsheng@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use function set_loopback in phy_driver to setup phy loopback
when doing ethtool self test.

Signed-off-by: Lin Yun Sheng <linyunsheng@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c | 68 +++++-------------------
 1 file changed, 14 insertions(+), 54 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index e95795b..1cd5161 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -259,67 +259,27 @@ static int hns_nic_set_link_ksettings(struct net_device *net_dev,
 
 static int hns_nic_config_phy_loopback(struct phy_device *phy_dev, u8 en)
 {
-#define COPPER_CONTROL_REG 0
-#define PHY_POWER_DOWN BIT(11)
-#define PHY_LOOP_BACK BIT(14)
-	u16 val = 0;
+	int err;
 
 	if (phy_dev->is_c45) /* c45 branch adding for XGE PHY */
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
+		err = phy_resume(phy_dev);
+		if (err)
+			goto out;
+
+		err = phy_loopback(phy_dev, true);
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
+		err = phy_loopback(phy_dev, false);
+		if (err)
+			goto out;
+
+		err = phy_suspend(phy_dev);
 	}
-	return 0;
+
+out:
+	return err;
 }
 
 static int __lb_setup(struct net_device *ndev,
-- 
1.9.1
