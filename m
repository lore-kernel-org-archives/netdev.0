From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH v3 net-next 07/13] net: hns: enet specify a reference to dsaf by fwnode_handle
Date: Mon, 30 May 2016 20:34:18 +0800
Message-ID: <1464611664-93775-8-git-send-email-Yisen.Zhuang@huawei.com>
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

As device_node is only used by DT case, it is expected to find uniform
ways. So fwnode_handle is the suitable method.

Signed-off-by: Kejian Yan <yankejian@huawei.com>
Reviewed-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
change log:
 v3: add Reviewed-by: Andy Shevchenko

 v2: remove the redundant line
  Link: https://lkml.org/lkml/2016/5/29/178

 v1: first submit
 link: https://lkml.org/lkml/2016/5/13/98
---
 drivers/net/ethernet/hisilicon/hns/hnae.c     | 12 ++++++------
 drivers/net/ethernet/hisilicon/hns/hnae.h     |  2 +-
 drivers/net/ethernet/hisilicon/hns/hns_enet.c | 14 ++++++++------
 drivers/net/ethernet/hisilicon/hns/hns_enet.h |  2 +-
 4 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.c b/drivers/net/ethernet/hisilicon/hns/hnae.c
index 3bfe36f..d630acd 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.c
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.c
@@ -96,16 +96,16 @@ static int __ae_match(struct device *dev, const void *data)
 {
 	struct hnae_ae_dev *hdev = cls_to_ae_dev(dev);
 
-	return hdev->dev->of_node == data;
+	return (data == &hdev->dev->of_node->fwnode);
 }
 
-static struct hnae_ae_dev *find_ae(const struct device_node *ae_node)
+static struct hnae_ae_dev *find_ae(const struct fwnode_handle *fwnode)
 {
 	struct device *dev;
 
-	WARN_ON(!ae_node);
+	WARN_ON(!fwnode);
 
-	dev = class_find_device(hnae_class, NULL, ae_node, __ae_match);
+	dev = class_find_device(hnae_class, NULL, fwnode, __ae_match);
 
 	return dev ? cls_to_ae_dev(dev) : NULL;
 }
@@ -312,7 +312,7 @@ EXPORT_SYMBOL(hnae_reinit_handle);
  * return handle ptr or ERR_PTR
  */
 struct hnae_handle *hnae_get_handle(struct device *owner_dev,
-				    const struct device_node *ae_node,
+				    const struct fwnode_handle	*fwnode,
 				    u32 port_id,
 				    struct hnae_buf_ops *bops)
 {
@@ -321,7 +321,7 @@ struct hnae_handle *hnae_get_handle(struct device *owner_dev,
 	int i, j;
 	int ret;
 
-	dev = find_ae(ae_node);
+	dev = find_ae(fwnode);
 	if (!dev)
 		return ERR_PTR(-ENODEV);
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.h b/drivers/net/ethernet/hisilicon/hns/hnae.h
index e8d36aa..f5f8140 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.h
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.h
@@ -528,7 +528,7 @@ struct hnae_handle {
 #define ring_to_dev(ring) ((ring)->q->dev->dev)
 
 struct hnae_handle *hnae_get_handle(struct device *owner_dev,
-				    const struct device_node *ae_node,
+				    const struct fwnode_handle	*fwnode,
 				    u32 port_id,
 				    struct hnae_buf_ops *bops);
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 8851420..93f6ccb 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -1807,7 +1807,7 @@ static int hns_nic_try_get_ae(struct net_device *ndev)
 	int ret;
 
 	h = hnae_get_handle(&priv->netdev->dev,
-			    priv->ae_node, priv->port_id, NULL);
+			    priv->fwnode, priv->port_id, NULL);
 	if (IS_ERR_OR_NULL(h)) {
 		ret = -ENODEV;
 		dev_dbg(priv->dev, "has not handle, register notifier!\n");
@@ -1867,7 +1867,7 @@ static int hns_nic_dev_probe(struct platform_device *pdev)
 	struct device *dev = &pdev->dev;
 	struct net_device *ndev;
 	struct hns_nic_priv *priv;
-	struct device_node *node = dev->of_node;
+	struct device_node *ae_node;
 	u32 port_id;
 	int ret;
 
@@ -1881,17 +1881,19 @@ static int hns_nic_dev_probe(struct platform_device *pdev)
 	priv->dev = dev;
 	priv->netdev = ndev;
 
-	if (of_device_is_compatible(node, "hisilicon,hns-nic-v1"))
+	if (of_device_is_compatible(dev->of_node, "hisilicon,hns-nic-v1"))
 		priv->enet_ver = AE_VERSION_1;
 	else
 		priv->enet_ver = AE_VERSION_2;
 
-	priv->ae_node = (void *)of_parse_phandle(node, "ae-handle", 0);
-	if (IS_ERR_OR_NULL(priv->ae_node)) {
-		ret = PTR_ERR(priv->ae_node);
+	ae_node = of_parse_phandle(dev->of_node, "ae-handle", 0);
+	if (IS_ERR_OR_NULL(ae_node)) {
+		ret = PTR_ERR(ae_node);
 		dev_err(dev, "not find ae-handle\n");
 		goto out_read_prop_fail;
 	}
+	priv->fwnode = &ae_node->fwnode;
+
 	/* try to find port-idx-in-ae first */
 	ret = device_property_read_u32(dev, "port-idx-in-ae", &port_id);
 	if (ret) {
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.h b/drivers/net/ethernet/hisilicon/hns/hns_enet.h
index 337efa5..44bb301 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.h
@@ -54,7 +54,7 @@ struct hns_nic_ops {
 };
 
 struct hns_nic_priv {
-	const struct device_node *ae_node;
+	const struct fwnode_handle      *fwnode;
 	u32 enet_ver;
 	u32 port_id;
 	int phy_mode;
-- 
1.9.1
