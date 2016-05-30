From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH v3 net-next 03/13] net: hisilicon: cleanup to prepare for other cases
Date: Mon, 30 May 2016 20:34:14 +0800
Message-ID: <1464611664-93775-4-git-send-email-Yisen.Zhuang@huawei.com>
References: <1464611664-93775-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <fengguang.wu@intel.com>, <andriy.shevchenko@linux.intel.com>,
	<andrew@lunn.ch>, <ivecera@redhat.com>, <f.fainelli@gmail.com>,
	<haifeng.wei@huawei.com>, <charles.chenxin@huawei.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-acpi@vger.kernel.org>, <linuxarm@huawei.com>
To: <rjw@rjwysocki.net>, <lenb@kernel.org>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464611664-93775-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kejian Yan <yankejian@huawei.com>

Hns-mdio only supports DT case now. do some cleanup to prepare
for introducing other cases later, no functional change.

Signed-off-by: Kejian Yan <yankejian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns_mdio.c | 46 +++++++++++++++----------------
 1 file changed, 23 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns_mdio.c b/drivers/net/ethernet/hisilicon/hns_mdio.c
index 765ddb3..381cf0a 100644
--- a/drivers/net/ethernet/hisilicon/hns_mdio.c
+++ b/drivers/net/ethernet/hisilicon/hns_mdio.c
@@ -354,6 +354,9 @@ static int hns_mdio_reset(struct mii_bus *bus)
 	struct hns_mdio_device *mdio_dev = (struct hns_mdio_device *)bus->priv;
 	int ret;
 
+	if (!dev_of_node(bus->parent))
+		return -ENOTSUPP;
+
 	if (!mdio_dev->subctrl_vbase) {
 		dev_err(&bus->dev, "mdio sys ctl reg has not maped\n");
 		return -ENODEV;
@@ -399,19 +402,12 @@ static int hns_mdio_reset(struct mii_bus *bus)
 /**
  * hns_mdio_bus_name - get mdio bus name
  * @name: mdio bus name
- * @np: mdio device node pointer
+ * @addr: mdio physical address
  */
-static void hns_mdio_bus_name(char *name, struct device_node *np)
+static void hns_mdio_bus_name(char *name, phys_addr_t addr)
 {
-	const u32 *addr;
-	u64 taddr = OF_BAD_ADDR;
-
-	addr = of_get_address(np, 0, NULL, NULL);
-	if (addr)
-		taddr = of_translate_address(np, addr);
-
-	snprintf(name, MII_BUS_ID_SIZE, "%s@%llx", np->name,
-		 (unsigned long long)taddr);
+	snprintf(name, MII_BUS_ID_SIZE,
+		 "hns-mdio@%llx", (unsigned long long)addr);
 }
 
 /**
@@ -422,17 +418,16 @@ static void hns_mdio_bus_name(char *name, struct device_node *np)
  */
 static int hns_mdio_probe(struct platform_device *pdev)
 {
-	struct device_node *np;
 	struct hns_mdio_device *mdio_dev;
 	struct mii_bus *new_bus;
 	struct resource *res;
-	int ret;
+	int ret = -ENODEV;
 
 	if (!pdev) {
 		dev_err(NULL, "pdev is NULL!\r\n");
 		return -ENODEV;
 	}
-	np = pdev->dev.of_node;
+
 	mdio_dev = devm_kzalloc(&pdev->dev, sizeof(*mdio_dev), GFP_KERNEL);
 	if (!mdio_dev)
 		return -ENOMEM;
@@ -448,7 +443,7 @@ static int hns_mdio_probe(struct platform_device *pdev)
 	new_bus->write = hns_mdio_write;
 	new_bus->reset = hns_mdio_reset;
 	new_bus->priv = mdio_dev;
-	hns_mdio_bus_name(new_bus->id, np);
+	new_bus->parent = &pdev->dev;
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	mdio_dev->vbase = devm_ioremap_resource(&pdev->dev, res);
@@ -457,18 +452,23 @@ static int hns_mdio_probe(struct platform_device *pdev)
 		return ret;
 	}
 
-	mdio_dev->subctrl_vbase =
-		syscon_node_to_regmap(of_parse_phandle(np, "subctrl-vbase", 0));
-	if (IS_ERR(mdio_dev->subctrl_vbase)) {
-		dev_warn(&pdev->dev, "no syscon hisilicon,peri-c-subctrl\n");
-		mdio_dev->subctrl_vbase = NULL;
-	}
-	new_bus->parent = &pdev->dev;
 	platform_set_drvdata(pdev, new_bus);
 
-	ret = of_mdiobus_register(new_bus, np);
+	hns_mdio_bus_name(new_bus->id, res->start);
+	if (dev_of_node(&pdev->dev)) {
+		mdio_dev->subctrl_vbase = syscon_node_to_regmap(
+			of_parse_phandle(pdev->dev.of_node,
+					 "subctrl-vbase", 0));
+		if (IS_ERR(mdio_dev->subctrl_vbase)) {
+			dev_warn(&pdev->dev, "no syscon hisilicon,peri-c-subctrl\n");
+			mdio_dev->subctrl_vbase = NULL;
+		}
+		ret = of_mdiobus_register(new_bus, pdev->dev.of_node);
+	}
+
 	if (ret) {
 		dev_err(&pdev->dev, "Cannot register as MDIO bus!\n");
+
 		platform_set_drvdata(pdev, NULL);
 		return ret;
 	}
-- 
1.9.1
