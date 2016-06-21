From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net-next 08/19] net: hns: fix ethtool loopback fail bug
Date: Tue, 21 Jun 2016 11:56:28 +0800
Message-ID: <1466481399-70080-9-git-send-email-Yisen.Zhuang@huawei.com>
References: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <liguozhu@huawei.com>, <huangdaode@hisilicon.com>, <arnd@arndb.de>,
	<andriy.shevchenko@linux.intel.com>, <andrew@lunn.ch>,
	<geliangtang@163.com>, <ivecera@redhat.com>,
	<fengguang.wu@intel.com>, <charles.chenxin@huawei.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
	<salil.mehta@huawei.com>, <yankejian@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kejian Yan <yankejian@huawei.com>

When run ethtool cmd(ethtool -t ethx) again and again for a long
time, it will be probabilistically fail. The PHYs' registers may
be on different pages, so it must be switch to the right page
before setting PHYs' registers.
And __lb_up() calls phy_start() to startup the PHYs device, but
this function may change Copper Control Register(Page 0, Register 0)
to an other value. It would cause phy loopback test fail. if we
remove phy_start(), we have to remove the relative phy_stop(),
phy_disconnect() when doing phy loopback to keep the phy stay in
right status.

Reported-by: hejun <hjat2005@huawei.com>
Signed-off-by: Kejian Yan <yankejian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c | 35 ++++++++++--------------
 1 file changed, 14 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index a809f52..5b3dccb 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -242,6 +242,7 @@ static const char hns_nic_test_strs[][ETH_GSTRING_LEN] = {
 static int hns_nic_config_phy_loopback(struct phy_device *phy_dev, u8 en)
 {
 #define COPPER_CONTROL_REG 0
+#define PHY_POWER_DOWN BIT(11)
 #define PHY_LOOP_BACK BIT(14)
 	u16 val = 0;
 
@@ -252,33 +253,40 @@ static int hns_nic_config_phy_loopback(struct phy_device *phy_dev, u8 en)
 		/* speed : 1000M */
 		phy_write(phy_dev, HNS_PHY_PAGE_REG, 2);
 		phy_write(phy_dev, 21, 0x1046);
+
+		phy_write(phy_dev, HNS_PHY_PAGE_REG, 0);
 		/* Force Master */
 		phy_write(phy_dev, 9, 0x1F00);
+
 		/* Soft-reset */
 		phy_write(phy_dev, 0, 0x9140);
 		/* If autoneg disabled,two soft-reset operations */
 		phy_write(phy_dev, 0, 0x9140);
-		phy_write(phy_dev, 22, 0xFA);
+
+		phy_write(phy_dev, HNS_PHY_PAGE_REG, 0xFA);
 
 		/* Default is 0x0400 */
 		phy_write(phy_dev, 1, 0x418);
 
 		/* Force 1000M Link, Default is 0x0200 */
 		phy_write(phy_dev, 7, 0x20C);
-		phy_write(phy_dev, 22, 0);
+		phy_write(phy_dev, HNS_PHY_PAGE_REG, 0);
 
-		/* Enable MAC loop-back */
+		/* Enable PHY loop-back */
 		val = phy_read(phy_dev, COPPER_CONTROL_REG);
 		val |= PHY_LOOP_BACK;
+		val &= ~PHY_POWER_DOWN;
 		phy_write(phy_dev, COPPER_CONTROL_REG, val);
 	} else {
-		phy_write(phy_dev, 22, 0xFA);
+		phy_write(phy_dev, HNS_PHY_PAGE_REG, 0xFA);
 		phy_write(phy_dev, 1, 0x400);
 		phy_write(phy_dev, 7, 0x200);
-		phy_write(phy_dev, 22, 0);
+		phy_write(phy_dev, HNS_PHY_PAGE_REG, 0);
+		phy_write(phy_dev, 9, 0xF00);
 
 		val = phy_read(phy_dev, COPPER_CONTROL_REG);
 		val &= ~PHY_LOOP_BACK;
+		val |= PHY_POWER_DOWN;
 		phy_write(phy_dev, COPPER_CONTROL_REG, val);
 	}
 	return 0;
@@ -339,28 +347,16 @@ static int __lb_up(struct net_device *ndev,
 
 	hns_nic_net_reset(ndev);
 
-	if (priv->phy) {
-		phy_disconnect(priv->phy);
-		msleep(100);
-
-		ret = hns_nic_init_phy(ndev, h);
-		if (ret)
-			return ret;
-	}
-
 	ret = __lb_setup(ndev, loop_mode);
 	if (ret)
 		return ret;
 
-	msleep(100);
+	msleep(200);
 
 	ret = h->dev->ops->start ? h->dev->ops->start(h) : 0;
 	if (ret)
 		return ret;
 
-	if (priv->phy)
-		phy_start(priv->phy);
-
 	/* link adjust duplex*/
 	if (priv->ae_handle->phy_if != PHY_INTERFACE_MODE_XGMII)
 		speed = 1000;
@@ -561,9 +557,6 @@ static int __lb_down(struct net_device *ndev)
 			   __func__,
 			   ret);
 
-	if (priv->phy)
-		phy_stop(priv->phy);
-
 	if (h->dev->ops->stop)
 		h->dev->ops->stop(h);
 
-- 
1.9.1
