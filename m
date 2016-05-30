From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH v3 net-next 08/13] net: hns: add uniform interface for phy connection
Date: Mon, 30 May 2016 20:34:19 +0800
Message-ID: <1464611664-93775-9-git-send-email-Yisen.Zhuang@huawei.com>
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

As device_node is only used by DT case, HNS needs to treat the other
cases including ACPI. It needs to use uniform ways to handle both of
DT and ACPI. This patch chooses phy_device, and of_phy_connect and
of_phy_attach are only used by DT case. It needs to use uniform interface
to handle that sequence by both DT and ACPI.

Signed-off-by: Kejian Yan <yankejian@huawei.com>
Reviewed-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
change log:
 v3:
   add Reviewed-by: Andy Shevchenko

 v2:
  1. remove the redundant functions, and
  2. adds fwnode match method beside DT and ACPI.
  link: https://lkml.org/lkml/2016/5/29/175

 v1: first submit
  link: https://lkml.org/lkml/2016/5/13/100
---
 drivers/net/ethernet/hisilicon/hns/hnae.c          |  8 ++++-
 drivers/net/ethernet/hisilicon/hns/hnae.h          |  3 +-
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |  2 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  | 34 +++++++++++++++-------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h  |  2 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c |  2 +-
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      | 21 +++++++------
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c   |  2 +-
 8 files changed, 49 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.c b/drivers/net/ethernet/hisilicon/hns/hnae.c
index d630acd..5d3047c 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.c
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.c
@@ -96,7 +96,13 @@ static int __ae_match(struct device *dev, const void *data)
 {
 	struct hnae_ae_dev *hdev = cls_to_ae_dev(dev);
 
-	return (data == &hdev->dev->of_node->fwnode);
+	if (dev_of_node(hdev->dev))
+		return (data == &hdev->dev->of_node->fwnode);
+	else if (is_acpi_node(hdev->dev->fwnode))
+		return (data == hdev->dev->fwnode);
+
+	dev_err(dev, "__ae_match cannot read cfg data from OF or acpi\n");
+	return 0;
 }
 
 static struct hnae_ae_dev *find_ae(const struct fwnode_handle *fwnode)
diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.h b/drivers/net/ethernet/hisilicon/hns/hnae.h
index f5f8140..529cb13 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.h
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.h
@@ -27,6 +27,7 @@
  * "cb" means control block
  */
 
+#include <linux/acpi.h>
 #include <linux/delay.h>
 #include <linux/device.h>
 #include <linux/module.h>
@@ -512,7 +513,7 @@ struct hnae_ae_dev {
 struct hnae_handle {
 	struct device *owner_dev; /* the device which make use of this handle */
 	struct hnae_ae_dev *dev;  /* the device who provides this handle */
-	struct device_node *phy_node;
+	struct phy_device *phy_dev;
 	phy_interface_t phy_if;
 	u32 if_support;
 	int q_num;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index 7a757e8..8e009f4 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -131,7 +131,7 @@ struct hnae_handle *hns_ae_get_handle(struct hnae_ae_dev *dev,
 	vf_cb->mac_cb = dsaf_dev->mac_cb[port_id];
 
 	ae_handle->phy_if = vf_cb->mac_cb->phy_if;
-	ae_handle->phy_node = vf_cb->mac_cb->phy_node;
+	ae_handle->phy_dev = vf_cb->mac_cb->phy_dev;
 	ae_handle->if_support = vf_cb->mac_cb->if_support;
 	ae_handle->port_type = vf_cb->mac_cb->mac_type;
 	ae_handle->dport_id = port_id;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index 611581f..527b49d 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -15,7 +15,8 @@
 #include <linux/netdevice.h>
 #include <linux/of.h>
 #include <linux/of_address.h>
-#include <linux/phy_fixed.h>
+#include <linux/of_mdio.h>
+#include <linux/phy.h>
 #include <linux/platform_device.h>
 
 #include "hns_dsaf_main.h"
@@ -645,7 +646,7 @@ free_mac_drv:
  */
 static int  hns_mac_get_info(struct hns_mac_cb *mac_cb)
 {
-	struct device_node *np = mac_cb->dev->of_node;
+	struct device_node *np;
 	struct regmap *syscon;
 	struct of_phandle_args cpld_args;
 	u32 ret;
@@ -672,21 +673,34 @@ static int  hns_mac_get_info(struct hns_mac_cb *mac_cb)
 	 * from dsaf node
 	 */
 	if (!mac_cb->fw_port) {
-		mac_cb->phy_node = of_parse_phandle(np, "phy-handle",
-						    mac_cb->mac_id);
-		if (mac_cb->phy_node)
+		np = of_parse_phandle(mac_cb->dev->of_node, "phy-handle",
+				      mac_cb->mac_id);
+		mac_cb->phy_dev = of_phy_find_device(np);
+		if (mac_cb->phy_dev) {
+			/* refcount is held by of_phy_find_device()
+			 * if the phy_dev is found
+			 */
+			put_device(&mac_cb->phy_dev->mdio.dev);
+
 			dev_dbg(mac_cb->dev, "mac%d phy_node: %s\n",
-				mac_cb->mac_id, mac_cb->phy_node->name);
+				mac_cb->mac_id, np->name);
+		}
+
 		return 0;
 	}
+
 	if (!is_of_node(mac_cb->fw_port))
 		return -EINVAL;
+
 	/* parse property from port subnode in dsaf */
-	mac_cb->phy_node = of_parse_phandle(to_of_node(mac_cb->fw_port),
-					    "phy-handle", 0);
-	if (mac_cb->phy_node)
+	np = of_parse_phandle(to_of_node(mac_cb->fw_port), "phy-handle", 0);
+	mac_cb->phy_dev = of_phy_find_device(np);
+	if (mac_cb->phy_dev) {
+		put_device(&mac_cb->phy_dev->mdio.dev);
 		dev_dbg(mac_cb->dev, "mac%d phy_node: %s\n",
-			mac_cb->mac_id, mac_cb->phy_node->name);
+			mac_cb->mac_id, np->name);
+		}
+
 	syscon = syscon_node_to_regmap(
 			of_parse_phandle(to_of_node(mac_cb->fw_port),
 					 "serdes-syscon", 0));
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
index 97ce9a7..89b49d7 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
@@ -338,7 +338,7 @@ struct hns_mac_cb {
 	phy_interface_t phy_if;
 	enum hnae_loop loop_mode;
 
-	struct device_node *phy_node;
+	struct phy_device *phy_dev;
 
 	struct mac_hw_stats hw_stats;
 };
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
index a837bb9..a843a86 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
@@ -332,7 +332,7 @@ int hns_mac_config_sds_loopback(struct hns_mac_cb *mac_cb, u8 en)
 	int sfp_prsnt;
 	int ret = hns_mac_get_sfp_prsnt(mac_cb, &sfp_prsnt);
 
-	if (!mac_cb->phy_node) {
+	if (!mac_cb->phy_dev) {
 		if (ret)
 			pr_info("please confirm sfp is present or not\n");
 		else
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 93f6ccb..3ec3c27 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -996,19 +996,22 @@ static void hns_nic_adjust_link(struct net_device *ndev)
 int hns_nic_init_phy(struct net_device *ndev, struct hnae_handle *h)
 {
 	struct hns_nic_priv *priv = netdev_priv(ndev);
-	struct phy_device *phy_dev = NULL;
+	struct phy_device *phy_dev = h->phy_dev;
+	int ret;
 
-	if (!h->phy_node)
+	if (!h->phy_dev)
 		return 0;
 
-	if (h->phy_if != PHY_INTERFACE_MODE_XGMII)
-		phy_dev = of_phy_connect(ndev, h->phy_node,
-					 hns_nic_adjust_link, 0, h->phy_if);
-	else
-		phy_dev = of_phy_attach(ndev, h->phy_node, 0, h->phy_if);
+	if (h->phy_if != PHY_INTERFACE_MODE_XGMII) {
+		phy_dev->dev_flags = 0;
 
-	if (unlikely(!phy_dev) || IS_ERR(phy_dev))
-		return !phy_dev ? -ENODEV : PTR_ERR(phy_dev);
+		ret = phy_connect_direct(ndev, phy_dev, hns_nic_adjust_link,
+					 h->phy_if);
+	} else {
+		ret = phy_attach_direct(ndev, phy_dev, 0, h->phy_if);
+	}
+	if (unlikely(ret))
+		return -ENODEV;
 
 	phy_dev->supported &= h->if_support;
 	phy_dev->advertising = phy_dev->supported;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index 3d746c8..03007d2 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -597,7 +597,7 @@ static void hns_nic_self_test(struct net_device *ndev,
 	st_param[1][0] = MAC_INTERNALLOOP_SERDES;
 	st_param[1][1] = 1; /*serdes must exist*/
 	st_param[2][0] = MAC_INTERNALLOOP_PHY; /* only supporte phy node*/
-	st_param[2][1] = ((!!(priv->ae_handle->phy_node)) &&
+	st_param[2][1] = ((!!(priv->ae_handle->phy_dev)) &&
 		(priv->ae_handle->phy_if != PHY_INTERFACE_MODE_XGMII));
 
 	if (eth_test->flags == ETH_TEST_FL_OFFLINE) {
-- 
1.9.1
