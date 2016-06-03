From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH v4 net-next 04/13] net: hisilicon: add support of acpi for hns-mdio
Date: Fri, 3 Jun 2016 10:55:12 +0800
Message-ID: <1464922521-30928-5-git-send-email-Yisen.Zhuang@huawei.com>
References: <1464922521-30928-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <fengguang.wu@intel.com>, <andriy.shevchenko@linux.intel.com>,
	<andrew@lunn.ch>, <ivecera@redhat.com>, <f.fainelli@gmail.com>,
	<haifeng.wei@huawei.com>, <charles.chenxin@huawei.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-acpi@vger.kernel.org>, <linuxarm@huawei.com>
To: <rjw@rjwysocki.net>, <lenb@kernel.org>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464922521-30928-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kejian Yan <yankejian@huawei.com>

hns-mdio needs to register itself to mii-bus. The info of the device can
be read by both DT and ACPI.
HNS tries to call Linux PHY driver to help access PHY-devices, the HNS
hardware topology is as below. The MDIO controller may control several
PHY-devices, and each PHY-device connects to a MAC device. The MDIO will
be registered to mdiobus, then PHY-devices will register when each mac
find PHY device.
                       cpu
                        |
                        |
     -------------------------------------------
    |                   |                       |
    |                   |                       |
    |                  dsaf                     |
   MDIO                 |                      MDIO
    |      ---------------------------          |
    |     |         |         |       |         |
    |     |         |         |       |         |
    |    MAC       MAC       MAC     MAC        |
    |     |         |         |       |         |
     ---- |-------- |-------- |       | --------
         ||        ||        ||       ||
         PHY       PHY       PHY     PHY

And the driver can handle reset sequence by _RST method in DSDT in ACPI
case.

Signed-off-by: Kejian Yan <yankejian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
change log:
 v2:
        1. use dev_of_node instead of IS_ENABLED macro
        2. Add ACPI bits
 v1: first submit
    Link: https://lkml.org/lkml/2016/5/13/93
---
 drivers/net/ethernet/hisilicon/hns_mdio.c | 106 +++++++++++++++++++-----------
 1 file changed, 69 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns_mdio.c b/drivers/net/ethernet/hisilicon/hns_mdio.c
index 297edc4..761a32f 100644
--- a/drivers/net/ethernet/hisilicon/hns_mdio.c
+++ b/drivers/net/ethernet/hisilicon/hns_mdio.c
@@ -7,6 +7,7 @@
  * (at your option) any later version.
  */
 
+#include <linux/acpi.h>
 #include <linux/errno.h>
 #include <linux/etherdevice.h>
 #include <linux/init.h>
@@ -354,48 +355,60 @@ static int hns_mdio_reset(struct mii_bus *bus)
 	struct hns_mdio_device *mdio_dev = (struct hns_mdio_device *)bus->priv;
 	int ret;
 
-	if (!dev_of_node(bus->parent))
-		return -ENOTSUPP;
+	if (dev_of_node(bus->parent)) {
+		if (!mdio_dev->subctrl_vbase) {
+			dev_err(&bus->dev, "mdio sys ctl reg has not maped\n");
+			return -ENODEV;
+		}
 
-	if (!mdio_dev->subctrl_vbase) {
-		dev_err(&bus->dev, "mdio sys ctl reg has not maped\n");
-		return -ENODEV;
-	}
+		/* 1. reset req, and read reset st check */
+		ret = mdio_sc_cfg_reg_write(mdio_dev, MDIO_SC_RESET_REQ, 0x1,
+					    MDIO_SC_RESET_ST, 0x1,
+					    MDIO_CHECK_SET_ST);
+		if (ret) {
+			dev_err(&bus->dev, "MDIO reset fail\n");
+			return ret;
+		}
 
-	/*1. reset req, and read reset st check*/
-	ret = mdio_sc_cfg_reg_write(mdio_dev, MDIO_SC_RESET_REQ, 0x1,
-				    MDIO_SC_RESET_ST, 0x1,
-				    MDIO_CHECK_SET_ST);
-	if (ret) {
-		dev_err(&bus->dev, "MDIO reset fail\n");
-		return ret;
-	}
+		/* 2. dis clk, and read clk st check */
+		ret = mdio_sc_cfg_reg_write(mdio_dev, MDIO_SC_CLK_DIS,
+					    0x1, MDIO_SC_CLK_ST, 0x1,
+					    MDIO_CHECK_CLR_ST);
+		if (ret) {
+			dev_err(&bus->dev, "MDIO dis clk fail\n");
+			return ret;
+		}
 
-	/*2. dis clk, and read clk st check*/
-	ret = mdio_sc_cfg_reg_write(mdio_dev, MDIO_SC_CLK_DIS,
-				    0x1, MDIO_SC_CLK_ST, 0x1,
-				    MDIO_CHECK_CLR_ST);
-	if (ret) {
-		dev_err(&bus->dev, "MDIO dis clk fail\n");
-		return ret;
-	}
+		/* 3. reset dreq, and read reset st check */
+		ret = mdio_sc_cfg_reg_write(mdio_dev, MDIO_SC_RESET_DREQ, 0x1,
+					    MDIO_SC_RESET_ST, 0x1,
+					    MDIO_CHECK_CLR_ST);
+		if (ret) {
+			dev_err(&bus->dev, "MDIO dis clk fail\n");
+			return ret;
+		}
 
-	/*3. reset dreq, and read reset st check*/
-	ret = mdio_sc_cfg_reg_write(mdio_dev, MDIO_SC_RESET_DREQ, 0x1,
-				    MDIO_SC_RESET_ST, 0x1,
-				    MDIO_CHECK_CLR_ST);
-	if (ret) {
-		dev_err(&bus->dev, "MDIO dis clk fail\n");
-		return ret;
+		/* 4. en clk, and read clk st check */
+		ret = mdio_sc_cfg_reg_write(mdio_dev, MDIO_SC_CLK_EN,
+					    0x1, MDIO_SC_CLK_ST, 0x1,
+					    MDIO_CHECK_SET_ST);
+		if (ret)
+			dev_err(&bus->dev, "MDIO en clk fail\n");
+	} else if (is_acpi_node(bus->parent->fwnode)) {
+		acpi_status s;
+
+		s = acpi_evaluate_object(ACPI_HANDLE(bus->parent),
+					 "_RST", NULL, NULL);
+		if (ACPI_FAILURE(s)) {
+			dev_err(&bus->dev, "Reset failed, return:%#x\n", s);
+			ret = -EBUSY;
+		} else {
+			ret = 0;
+		}
+	} else {
+		dev_err(&bus->dev, "Can not get cfg data from DT or ACPI\n");
+		ret = -ENXIO;
 	}
-
-	/*4. en clk, and read clk st check*/
-	ret = mdio_sc_cfg_reg_write(mdio_dev, MDIO_SC_CLK_EN,
-				    0x1, MDIO_SC_CLK_ST, 0x1,
-				    MDIO_CHECK_SET_ST);
-	if (ret)
-		dev_err(&bus->dev, "MDIO en clk fail\n");
-
 	return ret;
 }
 
@@ -453,6 +466,18 @@ static int hns_mdio_probe(struct platform_device *pdev)
 			mdio_dev->subctrl_vbase = NULL;
 		}
 		ret = of_mdiobus_register(new_bus, pdev->dev.of_node);
+	} else if (is_acpi_node(pdev->dev.fwnode)) {
+		/* Clear all the IRQ properties */
+		memset(new_bus->irq, PHY_POLL, 4 * PHY_MAX_ADDR);
+
+		/* Mask out all PHYs from auto probing. */
+		new_bus->phy_mask = ~0;
+
+		/* Register the MDIO bus */
+		ret = mdiobus_register(new_bus);
+	} else {
+		dev_err(&pdev->dev, "Can not get cfg data from DT or ACPI\n");
+		ret = -ENXIO;
 	}
 
 	if (ret) {
@@ -487,12 +512,19 @@ static const struct of_device_id hns_mdio_match[] = {
 	{}
 };
 
+static const struct acpi_device_id hns_mdio_acpi_match[] = {
+	{ "HISI0141", 0 },
+	{ },
+};
+MODULE_DEVICE_TABLE(acpi, hns_mdio_acpi_match);
+
 static struct platform_driver hns_mdio_driver = {
 	.probe = hns_mdio_probe,
 	.remove = hns_mdio_remove,
 	.driver = {
 		   .name = MDIO_DRV_NAME,
 		   .of_match_table = hns_mdio_match,
+		   .acpi_match_table = ACPI_PTR(hns_mdio_acpi_match),
 		   },
 };
 
-- 
1.9.1
