From: Lin Yun Sheng <linyunsheng@huawei.com>
Subject: [PATCH NET V4 2/2] net: hns: Use phy_driver to setup Phy loopback
Date: Sat, 24 Jun 2017 15:49:14 +0800
Message-ID: <1498290554-237317-3-git-send-email-linyunsheng@huawei.com>
References: <1498290554-237317-1-git-send-email-linyunsheng@huawei.com>
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
In-Reply-To: <1498290554-237317-1-git-send-email-linyunsheng@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use function set_loopback in phy_driver to setup phy loopback
when doing ethtool self test.

Signed-off-by: Lin Yun Sheng <linyunsheng@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hnae.h        |  1 +
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c | 92 +++++++-----------------
 2 files changed, 26 insertions(+), 67 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.h b/drivers/net/ethernet/hisilicon/hns/hnae.h
index 04211ac..7ba653a 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.h
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.h
@@ -360,6 +360,7 @@ enum hnae_loop {
 	MAC_INTERNALLOOP_MAC = 0,
 	MAC_INTERNALLOOP_SERDES,
 	MAC_INTERNALLOOP_PHY,
+	MAC_LOOP_PHY_NONE,
 	MAC_LOOP_NONE,
 };
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index e95795b..10d82df 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -259,67 +259,24 @@ static int hns_nic_set_link_ksettings(struct net_device *net_dev,
 
 static int hns_nic_config_phy_loopback(struct phy_device *phy_dev, u8 en)
 {
-#define COPPER_CONTROL_REG 0
-#define PHY_POWER_DOWN BIT(11)
-#define PHY_LOOP_BACK BIT(14)
-	u16 val = 0;
-
-	if (phy_dev->is_c45) /* c45 branch adding for XGE PHY */
-		return -ENOTSUPP;
+	int err;
 
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
@@ -332,10 +289,8 @@ static int __lb_setup(struct net_device *ndev,
 
 	switch (loop) {
 	case MAC_INTERNALLOOP_PHY:
-		if ((phy_dev) && (!phy_dev->is_c45)) {
-			ret = hns_nic_config_phy_loopback(phy_dev, 0x1);
-			ret |= h->dev->ops->set_loopback(h, loop, 0x1);
-		}
+		ret = hns_nic_config_phy_loopback(phy_dev, 0x1);
+		ret |= h->dev->ops->set_loopback(h, loop, 0x1);
 		break;
 	case MAC_INTERNALLOOP_MAC:
 		if ((h->dev->ops->set_loopback) &&
@@ -346,10 +301,9 @@ static int __lb_setup(struct net_device *ndev,
 		if (h->dev->ops->set_loopback)
 			ret = h->dev->ops->set_loopback(h, loop, 0x1);
 		break;
+	case MAC_LOOP_PHY_NONE:
+		ret |= hns_nic_config_phy_loopback(phy_dev, 0x0);
 	case MAC_LOOP_NONE:
-		if ((phy_dev) && (!phy_dev->is_c45))
-			ret |= hns_nic_config_phy_loopback(phy_dev, 0x0);
-
 		if (h->dev->ops->set_loopback) {
 			if (priv->ae_handle->phy_if != PHY_INTERFACE_MODE_XGMII)
 				ret |= h->dev->ops->set_loopback(h,
@@ -582,13 +536,16 @@ static int __lb_run_test(struct net_device *ndev,
 	return ret_val;
 }
 
-static int __lb_down(struct net_device *ndev)
+static int __lb_down(struct net_device *ndev, enum hnae_loop loop)
 {
 	struct hns_nic_priv *priv = netdev_priv(ndev);
 	struct hnae_handle *h = priv->ae_handle;
 	int ret;
 
-	ret = __lb_setup(ndev, MAC_LOOP_NONE);
+	if (loop == MAC_INTERNALLOOP_PHY)
+		ret = __lb_setup(ndev, MAC_LOOP_PHY_NONE);
+	else
+		ret = __lb_setup(ndev, MAC_LOOP_NONE);
 	if (ret)
 		netdev_err(ndev, "%s: __lb_setup return error(%d)!\n",
 			   __func__,
@@ -644,7 +601,8 @@ static void hns_nic_self_test(struct net_device *ndev,
 			if (!data[test_index]) {
 				data[test_index] = __lb_run_test(
 					ndev, (enum hnae_loop)st_param[i][0]);
-				(void)__lb_down(ndev);
+				(void)__lb_down(ndev,
+						(enum hnae_loop)st_param[i][0]);
 			}
 
 			if (data[test_index])
-- 
1.9.1
