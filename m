From: yankejian <yankejian@huawei.com>
Subject: [PATCH net-next] net: hisilicon: deals with the sub ctrl by syscon
Date: Wed, 21 Oct 2015 17:57:44 +0800
Message-ID: <1445421464-238140-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <liguozhu@huawei.com>, <yisen.zhuang@huawei.com>,
	<huangdaode@hisilicon.com>, <lipeng321@huawei.com>,
	<yankejian@huawei.com>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  the global Soc configuration is treated by syscon, and sub ctrl bus is
Soc bus. it has to be treated by syscon.

Signed-off-by: yankejian <yankejian@huawei.com>
Signed-off-by: lisheng <lisheng011@huawei.com>
Signed-off-by: lipeng <lipeng321@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns_mdio.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns_mdio.c b/drivers/net/ethernet/hisilicon/hns_mdio.c
index e4ec52a..37491c8 100644
--- a/drivers/net/ethernet/hisilicon/hns_mdio.c
+++ b/drivers/net/ethernet/hisilicon/hns_mdio.c
@@ -11,6 +11,7 @@
 #include <linux/etherdevice.h>
 #include <linux/init.h>
 #include <linux/kernel.h>
+#include <linux/mfd/syscon.h>
 #include <linux/module.h>
 #include <linux/mutex.h>
 #include <linux/netdevice.h>
@@ -20,6 +21,7 @@
 #include <linux/of_platform.h>
 #include <linux/phy.h>
 #include <linux/platform_device.h>
+#include <linux/regmap.h>
 #include <linux/spinlock_types.h>
 
 #define MDIO_DRV_NAME "Hi-HNS_MDIO"
@@ -36,7 +38,7 @@
 
 struct hns_mdio_device {
 	void *vbase;		/* mdio reg base address */
-	void *sys_vbase;
+	struct regmap *subctrl_vbase;
 };
 
 /* mdio reg */
@@ -155,10 +157,10 @@ static int mdio_sc_cfg_reg_write(struct hns_mdio_device *mdio_dev,
 	u32 time_cnt;
 	u32 reg_value;
 
-	mdio_write_reg((void *)mdio_dev->sys_vbase, cfg_reg, set_val);
+	regmap_write(mdio_dev->subctrl_vbase, cfg_reg, set_val);
 
 	for (time_cnt = MDIO_TIMEOUT; time_cnt; time_cnt--) {
-		reg_value = mdio_read_reg((void *)mdio_dev->sys_vbase, st_reg);
+		regmap_read(mdio_dev->subctrl_vbase, st_reg, &reg_value);
 		reg_value &= st_msk;
 		if ((!!check_st) == (!!reg_value))
 			break;
@@ -352,7 +354,7 @@ static int hns_mdio_reset(struct mii_bus *bus)
 	struct hns_mdio_device *mdio_dev = (struct hns_mdio_device *)bus->priv;
 	int ret;
 
-	if (!mdio_dev->sys_vbase) {
+	if (!mdio_dev->subctrl_vbase) {
 		dev_err(&bus->dev, "mdio sys ctl reg has not maped\n");
 		return -ENODEV;
 	}
@@ -455,13 +457,12 @@ static int hns_mdio_probe(struct platform_device *pdev)
 		return ret;
 	}
 
-	res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
-	mdio_dev->sys_vbase = devm_ioremap_resource(&pdev->dev, res);
-	if (IS_ERR(mdio_dev->sys_vbase)) {
-		ret = PTR_ERR(mdio_dev->sys_vbase);
-		return ret;
+	mdio_dev->subctrl_vbase =
+		syscon_node_to_regmap(of_parse_phandle(np, "subctrl_vbase", 0));
+	if (IS_ERR(mdio_dev->subctrl_vbase)) {
+		dev_warn(&pdev->dev, "no syscon hisilicon,peri-c-subctrl\n");
+		mdio_dev->subctrl_vbase = NULL;
 	}
-
 	new_bus->irq = devm_kcalloc(&pdev->dev, PHY_MAX_ADDR,
 				    sizeof(int), GFP_KERNEL);
 	if (!new_bus->irq)
-- 
1.9.1
