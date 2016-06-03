From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH v4 net-next 11/13] net: hns: register phy device in each mac initial sequence
Date: Fri, 3 Jun 2016 10:55:19 +0800
Message-ID: <1464922521-30928-12-git-send-email-Yisen.Zhuang@huawei.com>
References: <1464922521-30928-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <fengguang.wu@intel.com>, <andriy.shevchenko@linux.intel.com>,
	<andrew@lunn.ch>, <ivecera@redhat.com>, <f.fainelli@gmail.com>,
	<haifeng.wei@huawei.com>, <charles.chenxin@huawei.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-acpi@vger.kernel.org>, <linuxarm@huawei.com>
To: <rjw@rjwysocki.net>, <lenb@kernel.org>, <davem@davemloft.net>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1464922521-30928-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kejian Yan <yankejian@huawei.com>

In ACPI case, there is no interface to register phy device to mdio-bus.
Phy device has to be registered itself to mdio-bus, and then enet can
get the phy device's info so that it can config the phy-device to help
to trasmit and receive data.
HNS hardware topology is as below. The MDIO controller may control several
PHY-devices, and each PHY-device connects to a MAC device. PHY-devices
will register when each mac find PHY device in initial sequence.

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

Signed-off-by: Kejian Yan <yankejian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
change log:
 v2: fix the build error by kbuild test robot

 v1: first submit
  link: https://lkml.org/lkml/2016/5/13/97
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c | 133 ++++++++++++++++++++--
 1 file changed, 126 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index 3ef0c9b..c526558 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -7,6 +7,7 @@
  * (at your option) any later version.
  */
 
+#include <linux/acpi.h>
 #include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/kernel.h>
@@ -638,6 +639,115 @@ free_mac_drv:
 	return ret;
 }
 
+static int
+hns_mac_phy_parse_addr(struct device *dev, struct fwnode_handle *fwnode)
+{
+	u32 addr;
+	int ret;
+
+	ret = fwnode_property_read_u32(fwnode, "phy-addr", &addr);
+	if (ret) {
+		dev_err(dev, "has invalid PHY address ret:%d\n", ret);
+		return ret;
+	}
+
+	if (addr >= PHY_MAX_ADDR) {
+		dev_err(dev, "PHY address %i is too large\n", addr);
+		return -EINVAL;
+	}
+
+	return addr;
+}
+
+static int hns_mac_phydev_match(struct device *dev, void *fwnode)
+{
+	return dev->fwnode == fwnode;
+}
+
+static struct
+platform_device *hns_mac_find_platform_device(struct fwnode_handle *fwnode)
+{
+	struct device *dev;
+
+	dev = bus_find_device(&platform_bus_type, NULL,
+			      fwnode, hns_mac_phydev_match);
+	return dev ? to_platform_device(dev) : NULL;
+}
+
+static int
+hns_mac_register_phydev(struct mii_bus *mdio, struct hns_mac_cb *mac_cb,
+			u32 addr)
+{
+	struct phy_device *phy;
+	const char *phy_type;
+	bool is_c45;
+	int rc;
+
+	rc = fwnode_property_read_string(mac_cb->fw_port,
+					 "phy-mode", &phy_type);
+	if (rc < 0)
+		return rc;
+
+	if (!strcmp(phy_type, phy_modes(PHY_INTERFACE_MODE_XGMII)))
+		is_c45 = 1;
+	else if (!strcmp(phy_type, phy_modes(PHY_INTERFACE_MODE_SGMII)))
+		is_c45 = 0;
+	else
+		return -ENODATA;
+
+	phy = get_phy_device(mdio, addr, is_c45);
+	if (!phy || IS_ERR(phy))
+		return -EIO;
+
+	if (mdio->irq)
+		phy->irq = mdio->irq[addr];
+
+	/* All data is now stored in the phy struct;
+	 * register it
+	 */
+	rc = phy_device_register(phy);
+	if (rc) {
+		phy_device_free(phy);
+		return -ENODEV;
+	}
+
+	mac_cb->phy_dev = phy;
+
+	dev_dbg(&mdio->dev, "registered phy at address %i\n", addr);
+
+	return 0;
+}
+
+static void hns_mac_register_phy(struct hns_mac_cb *mac_cb)
+{
+	struct acpi_reference_args args;
+	struct platform_device *pdev;
+	struct mii_bus *mii_bus;
+	int rc;
+	int addr;
+
+	/* Loop over the child nodes and register a phy_device for each one */
+	if (!to_acpi_device_node(mac_cb->fw_port))
+		return;
+
+	rc = acpi_node_get_property_reference(
+			mac_cb->fw_port, "mdio-node", 0, &args);
+	if (rc)
+		return;
+
+	addr = hns_mac_phy_parse_addr(mac_cb->dev, mac_cb->fw_port);
+	if (addr < 0)
+		return;
+
+	/* dev address in adev */
+	pdev = hns_mac_find_platform_device(acpi_fwnode_handle(args.adev));
+	mii_bus = platform_get_drvdata(pdev);
+	rc = hns_mac_register_phydev(mii_bus, mac_cb, addr);
+	if (!rc)
+		dev_dbg(mac_cb->dev, "mac%d register phy addr:%d\n",
+			mac_cb->mac_id, addr);
+}
+
 /**
  *hns_mac_get_info  - get mac information from device node
  *@mac_cb: mac device
@@ -690,13 +800,17 @@ static int  hns_mac_get_info(struct hns_mac_cb *mac_cb)
 	}
 
 	if (is_of_node(mac_cb->fw_port)) {
-	/* parse property from port subnode in dsaf */
-	np = of_parse_phandle(to_of_node(mac_cb->fw_port), "phy-handle", 0);
-	mac_cb->phy_dev = of_phy_find_device(np);
-	if (mac_cb->phy_dev) {
-		put_device(&mac_cb->phy_dev->mdio.dev);
-		dev_dbg(mac_cb->dev, "mac%d phy_node: %s\n",
-			mac_cb->mac_id, np->name);
+		/* parse property from port subnode in dsaf */
+		np = of_parse_phandle(to_of_node(mac_cb->fw_port),
+				      "phy-handle", 0);
+		mac_cb->phy_dev = of_phy_find_device(np);
+		if (mac_cb->phy_dev) {
+			/* refcount is held by of_phy_find_device()
+			 * if the phy_dev is found
+			 */
+			put_device(&mac_cb->phy_dev->mdio.dev);
+			dev_dbg(mac_cb->dev, "mac%d phy_node: %s\n",
+				mac_cb->mac_id, np->name);
 		}
 
 		syscon = syscon_node_to_regmap(
@@ -743,6 +857,11 @@ static int  hns_mac_get_info(struct hns_mac_cb *mac_cb)
 				mac_cb->cpld_ctrl_reg = cpld_args.args[0];
 			}
 		}
+	} else if (is_acpi_node(mac_cb->fw_port)) {
+		hns_mac_register_phy(mac_cb);
+	} else {
+		dev_err(mac_cb->dev, "mac%d cannot find phy node\n",
+			mac_cb->mac_id);
 	}
 
 	return 0;
-- 
1.9.1

