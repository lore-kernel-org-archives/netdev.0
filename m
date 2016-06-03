From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH v4 net-next 13/13] net: hns: net: hns: enet adds support of acpi
Date: Fri, 3 Jun 2016 10:55:21 +0800
Message-ID: <1464922521-30928-14-git-send-email-Yisen.Zhuang@huawei.com>
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

Enet needs to get configration parameter by acpi. This patch
adds support of ACPI for enet. The configuration parameter will
be configed in BIOS.

Signed-off-by: Kejian Yan <yankejian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
change log:
 v2:
     1. use acpi_dev_found() instead of acpi_match_device_ids()
     2. use is_acpi_node() to check if it works by ACPI case
     3. use dev_of_node() to check if it works by DT case

 v1: first submit
  link: https://lkml.org/lkml/2016/5/13/99
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c | 56 +++++++++++++++++++++------
 1 file changed, 44 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 3ec3c27..ad742a6 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -132,6 +132,13 @@ static void fill_v2_desc(struct hnae_ring *ring, void *priv,
 	ring_ptr_move_fw(ring, next_to_use);
 }
 
+static const struct acpi_device_id hns_enet_acpi_match[] = {
+	{ "HISI00C1", 0 },
+	{ "HISI00C2", 0 },
+	{ },
+};
+MODULE_DEVICE_TABLE(acpi, hns_enet_acpi_match);
+
 static void fill_desc(struct hnae_ring *ring, void *priv,
 		      int size, dma_addr_t dma, int frag_end,
 		      int buf_num, enum hns_desc_type type, int mtu)
@@ -1870,7 +1877,6 @@ static int hns_nic_dev_probe(struct platform_device *pdev)
 	struct device *dev = &pdev->dev;
 	struct net_device *ndev;
 	struct hns_nic_priv *priv;
-	struct device_node *ae_node;
 	u32 port_id;
 	int ret;
 
@@ -1884,20 +1890,45 @@ static int hns_nic_dev_probe(struct platform_device *pdev)
 	priv->dev = dev;
 	priv->netdev = ndev;
 
-	if (of_device_is_compatible(dev->of_node, "hisilicon,hns-nic-v1"))
-		priv->enet_ver = AE_VERSION_1;
-	else
-		priv->enet_ver = AE_VERSION_2;
+	if (dev_of_node(dev)) {
+		struct device_node *ae_node;
 
-	ae_node = of_parse_phandle(dev->of_node, "ae-handle", 0);
-	if (IS_ERR_OR_NULL(ae_node)) {
-		ret = PTR_ERR(ae_node);
-		dev_err(dev, "not find ae-handle\n");
-		goto out_read_prop_fail;
+		if (of_device_is_compatible(dev->of_node,
+					    "hisilicon,hns-nic-v1"))
+			priv->enet_ver = AE_VERSION_1;
+		else
+			priv->enet_ver = AE_VERSION_2;
+
+		ae_node = of_parse_phandle(dev->of_node, "ae-handle", 0);
+		if (IS_ERR_OR_NULL(ae_node)) {
+			ret = PTR_ERR(ae_node);
+			dev_err(dev, "not find ae-handle\n");
+			goto out_read_prop_fail;
+		}
+		priv->fwnode = &ae_node->fwnode;
+	} else if (is_acpi_node(dev->fwnode)) {
+		struct acpi_reference_args args;
+
+		if (acpi_dev_found(hns_enet_acpi_match[0].id))
+			priv->enet_ver = AE_VERSION_1;
+		else if (acpi_dev_found(hns_enet_acpi_match[1].id))
+			priv->enet_ver = AE_VERSION_2;
+		else
+			return -ENXIO;
+
+		/* try to find port-idx-in-ae first */
+		ret = acpi_node_get_property_reference(dev->fwnode,
+						       "ae-handle", 0, &args);
+		if (ret) {
+			dev_err(dev, "not find ae-handle\n");
+			goto out_read_prop_fail;
+		}
+		priv->fwnode = acpi_fwnode_handle(args.adev);
+	} else {
+		dev_err(dev, "cannot read cfg data from OF or acpi\n");
+		return -ENXIO;
 	}
-	priv->fwnode = &ae_node->fwnode;
 
-	/* try to find port-idx-in-ae first */
 	ret = device_property_read_u32(dev, "port-idx-in-ae", &port_id);
 	if (ret) {
 		/* only for old code compatible */
@@ -2014,6 +2045,7 @@ static struct platform_driver hns_nic_dev_driver = {
 	.driver = {
 		.name = "hns-nic",
 		.of_match_table = hns_enet_of_match,
+		.acpi_match_table = ACPI_PTR(hns_enet_acpi_match),
 	},
 	.probe = hns_nic_dev_probe,
 	.remove = hns_nic_dev_remove,
-- 
1.9.1
