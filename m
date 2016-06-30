From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH v2 net-next 9/9] net: hns: get reset registers from DT
Date: Thu, 30 Jun 2016 15:25:09 +0800
Message-ID: <1467271509-63162-10-git-send-email-Yisen.Zhuang@huawei.com>
References: <1467271509-63162-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <akpm@linux-foundation.org>, <gregkh@linuxfoundation.org>,
	<kvalo@codeaurora.org>, <mchehab@osg.samsung.com>,
	<linux@roeck-us.net>, <jslaby@suse.cz>, <yankejian@huawei.com>,
	<huangdaode@hisilicon.com>, <lipeng321@huawei.com>,
	<xieqianqian@huawei.com>, <arnd@arndb.de>, <andrew@lunn.ch>,
	<xypron.glpk@gmx.de>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
	<salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467271509-63162-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kejian Yan <yankejian@huawei.com>

Since the registers of subctrl may be different, it is better to
mv the registers from hns mdio driver routine to device tree node.

Signed-off-by: Kejian Yan <yankejian@huawei.com>
---
change log:
 v2: fix the wrong indentations

 v1: first submit
  link: https://lkml.org/lkml/2016/6/27/182
---
 drivers/net/ethernet/hisilicon/hns_mdio.c | 80 +++++++++++++++++++++++++------
 1 file changed, 66 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns_mdio.c b/drivers/net/ethernet/hisilicon/hns_mdio.c
index 761a32f..33f4c48 100644
--- a/drivers/net/ethernet/hisilicon/hns_mdio.c
+++ b/drivers/net/ethernet/hisilicon/hns_mdio.c
@@ -37,9 +37,19 @@
 
 #define MDIO_TIMEOUT			1000000
 
+struct hns_mdio_sc_reg {
+	u16 mdio_clk_en;
+	u16 mdio_clk_dis;
+	u16 mdio_reset_req;
+	u16 mdio_reset_dreq;
+	u16 mdio_clk_st;
+	u16 mdio_reset_st;
+};
+
 struct hns_mdio_device {
 	void *vbase;		/* mdio reg base address */
 	struct regmap *subctrl_vbase;
+	struct hns_mdio_sc_reg sc_reg;
 };
 
 /* mdio reg */
@@ -93,7 +103,6 @@ enum mdio_c45_op_seq {
 #define MDIO_SC_CLK_DIS		0x33C
 #define MDIO_SC_RESET_REQ	0xA38
 #define MDIO_SC_RESET_DREQ	0xA3C
-#define MDIO_SC_CTRL		0x2010
 #define MDIO_SC_CLK_ST		0x531C
 #define MDIO_SC_RESET_ST	0x5A1C
 
@@ -353,6 +362,7 @@ static int hns_mdio_read(struct mii_bus *bus, int phy_id, int regnum)
 static int hns_mdio_reset(struct mii_bus *bus)
 {
 	struct hns_mdio_device *mdio_dev = (struct hns_mdio_device *)bus->priv;
+	const struct hns_mdio_sc_reg *sc_reg;
 	int ret;
 
 	if (dev_of_node(bus->parent)) {
@@ -361,9 +371,10 @@ static int hns_mdio_reset(struct mii_bus *bus)
 			return -ENODEV;
 		}
 
+		sc_reg = &mdio_dev->sc_reg;
 		/* 1. reset req, and read reset st check */
-		ret = mdio_sc_cfg_reg_write(mdio_dev, MDIO_SC_RESET_REQ, 0x1,
-					    MDIO_SC_RESET_ST, 0x1,
+		ret = mdio_sc_cfg_reg_write(mdio_dev, sc_reg->mdio_reset_req,
+					    0x1, sc_reg->mdio_reset_st, 0x1,
 					    MDIO_CHECK_SET_ST);
 		if (ret) {
 			dev_err(&bus->dev, "MDIO reset fail\n");
@@ -371,8 +382,8 @@ static int hns_mdio_reset(struct mii_bus *bus)
 		}
 
 		/* 2. dis clk, and read clk st check */
-		ret = mdio_sc_cfg_reg_write(mdio_dev, MDIO_SC_CLK_DIS,
-					    0x1, MDIO_SC_CLK_ST, 0x1,
+		ret = mdio_sc_cfg_reg_write(mdio_dev, sc_reg->mdio_clk_dis,
+					    0x1, sc_reg->mdio_clk_st, 0x1,
 					    MDIO_CHECK_CLR_ST);
 		if (ret) {
 			dev_err(&bus->dev, "MDIO dis clk fail\n");
@@ -380,8 +391,8 @@ static int hns_mdio_reset(struct mii_bus *bus)
 		}
 
 		/* 3. reset dreq, and read reset st check */
-		ret = mdio_sc_cfg_reg_write(mdio_dev, MDIO_SC_RESET_DREQ, 0x1,
-					    MDIO_SC_RESET_ST, 0x1,
+		ret = mdio_sc_cfg_reg_write(mdio_dev, sc_reg->mdio_reset_dreq,
+					    0x1, sc_reg->mdio_reset_st, 0x1,
 					    MDIO_CHECK_CLR_ST);
 		if (ret) {
 			dev_err(&bus->dev, "MDIO dis clk fail\n");
@@ -389,8 +400,8 @@ static int hns_mdio_reset(struct mii_bus *bus)
 		}
 
 		/* 4. en clk, and read clk st check */
-		ret = mdio_sc_cfg_reg_write(mdio_dev, MDIO_SC_CLK_EN,
-					    0x1, MDIO_SC_CLK_ST, 0x1,
+		ret = mdio_sc_cfg_reg_write(mdio_dev, sc_reg->mdio_clk_en,
+					    0x1, sc_reg->mdio_clk_st, 0x1,
 					    MDIO_CHECK_SET_ST);
 		if (ret)
 			dev_err(&bus->dev, "MDIO en clk fail\n");
@@ -458,13 +469,54 @@ static int hns_mdio_probe(struct platform_device *pdev)
 	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%s-%s", "Mii",
 		 dev_name(&pdev->dev));
 	if (dev_of_node(&pdev->dev)) {
-		mdio_dev->subctrl_vbase = syscon_node_to_regmap(
-			of_parse_phandle(pdev->dev.of_node,
-					 "subctrl-vbase", 0));
-		if (IS_ERR(mdio_dev->subctrl_vbase)) {
-			dev_warn(&pdev->dev, "no syscon hisilicon,peri-c-subctrl\n");
+		struct of_phandle_args reg_args;
+
+		ret = of_parse_phandle_with_fixed_args(pdev->dev.of_node,
+						       "subctrl-vbase",
+						       4,
+						       0,
+						       &reg_args);
+		if (!ret) {
+			mdio_dev->subctrl_vbase =
+				syscon_node_to_regmap(reg_args.np);
+			if (IS_ERR(mdio_dev->subctrl_vbase)) {
+				dev_warn(&pdev->dev, "syscon_node_to_regmap error\n");
+				mdio_dev->subctrl_vbase = NULL;
+			} else {
+				if (reg_args.args_count == 4) {
+					mdio_dev->sc_reg.mdio_clk_en =
+						(u16)reg_args.args[0];
+					mdio_dev->sc_reg.mdio_clk_dis =
+						(u16)reg_args.args[0] + 4;
+					mdio_dev->sc_reg.mdio_reset_req =
+						(u16)reg_args.args[1];
+					mdio_dev->sc_reg.mdio_reset_dreq =
+						(u16)reg_args.args[1] + 4;
+					mdio_dev->sc_reg.mdio_clk_st =
+						(u16)reg_args.args[2];
+					mdio_dev->sc_reg.mdio_reset_st =
+						(u16)reg_args.args[3];
+				} else {
+					/* for compatible */
+					mdio_dev->sc_reg.mdio_clk_en =
+						MDIO_SC_CLK_EN;
+					mdio_dev->sc_reg.mdio_clk_dis =
+						MDIO_SC_CLK_DIS;
+					mdio_dev->sc_reg.mdio_reset_req =
+						MDIO_SC_RESET_REQ;
+					mdio_dev->sc_reg.mdio_reset_dreq =
+						MDIO_SC_RESET_DREQ;
+					mdio_dev->sc_reg.mdio_clk_st =
+						MDIO_SC_CLK_ST;
+					mdio_dev->sc_reg.mdio_reset_st =
+						MDIO_SC_RESET_ST;
+				}
+			}
+		} else {
+			dev_warn(&pdev->dev, "find syscon ret = %#x\n", ret);
 			mdio_dev->subctrl_vbase = NULL;
 		}
+
 		ret = of_mdiobus_register(new_bus, pdev->dev.of_node);
 	} else if (is_acpi_node(pdev->dev.fwnode)) {
 		/* Clear all the IRQ properties */
-- 
1.9.1
