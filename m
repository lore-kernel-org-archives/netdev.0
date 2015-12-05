From: yankejian <yankejian@huawei.com>
Subject: [PATCH net-next 1/2] net: hns: enet specisies a reference to dsaf
Date: Sat, 5 Dec 2015 14:10:55 +0800
Message-ID: <1449295856-31068-2-git-send-email-yankejian@huawei.com>
References: <1449295856-31068-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <haifeng.wei@huawei.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: <davem@davemloft.net>, <arnd@arndb.de>, <fengguang.wu@intel.com>,
	<robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<salil.mehta@huawei.com>, <Yisen.Zhuang@huawei.com>,
	<liguozhu@huawei.com>, <lisheng011@huawei.com>,
	<huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449295856-31068-1-git-send-email-yankejian@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

enet is associating with dasf. before this patch, the association is
the same strings between ae-name and dsa-name. in a general way, enet
specifies a reference to dsaf should be a good idea. so this patch
deletes the ae-name in enet, and adds parsing the ae-handle
from DT to set the associating with dsaf.

Signed-off-by: yankejian <yankejian@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hnae.c          | 17 +++++++----------
 drivers/net/ethernet/hisilicon/hns/hnae.h          |  7 +++++--
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |  4 ++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 10 +---------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |  1 +
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      | 13 +++++++++----
 drivers/net/ethernet/hisilicon/hns/hns_enet.h      |  2 +-
 7 files changed, 28 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.c b/drivers/net/ethernet/hisilicon/hns/hnae.c
index b364529..3bfe36f 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.c
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.c
@@ -95,21 +95,17 @@ static struct hnae_buf_ops hnae_bops = {
 static int __ae_match(struct device *dev, const void *data)
 {
 	struct hnae_ae_dev *hdev = cls_to_ae_dev(dev);
-	const char *ae_id = data;
 
-	if (!strncmp(ae_id, hdev->name, AE_NAME_SIZE))
-		return 1;
-
-	return 0;
+	return hdev->dev->of_node == data;
 }
 
-static struct hnae_ae_dev *find_ae(const char *ae_id)
+static struct hnae_ae_dev *find_ae(const struct device_node *ae_node)
 {
 	struct device *dev;
 
-	WARN_ON(!ae_id);
+	WARN_ON(!ae_node);
 
-	dev = class_find_device(hnae_class, NULL, ae_id, __ae_match);
+	dev = class_find_device(hnae_class, NULL, ae_node, __ae_match);
 
 	return dev ? cls_to_ae_dev(dev) : NULL;
 }
@@ -316,7 +312,8 @@ EXPORT_SYMBOL(hnae_reinit_handle);
  * return handle ptr or ERR_PTR
  */
 struct hnae_handle *hnae_get_handle(struct device *owner_dev,
-				    const char *ae_id, u32 port_id,
+				    const struct device_node *ae_node,
+				    u32 port_id,
 				    struct hnae_buf_ops *bops)
 {
 	struct hnae_ae_dev *dev;
@@ -324,7 +321,7 @@ struct hnae_handle *hnae_get_handle(struct device *owner_dev,
 	int i, j;
 	int ret;
 
-	dev = find_ae(ae_id);
+	dev = find_ae(ae_node);
 	if (!dev)
 		return ERR_PTR(-ENODEV);
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.h b/drivers/net/ethernet/hisilicon/hns/hnae.h
index d1f3316..0012664 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.h
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.h
@@ -523,8 +523,11 @@ struct hnae_handle {
 
 #define ring_to_dev(ring) ((ring)->q->dev->dev)
 
-struct hnae_handle *hnae_get_handle(struct device *owner_dev, const char *ae_id,
-				    u32 port_id, struct hnae_buf_ops *bops);
+struct hnae_handle *hnae_get_handle(struct device *owner_dev,
+				    const struct device_node *ae_node,
+				    u32 port_id,
+				    struct hnae_buf_ops *bops);
+
 void hnae_put_handle(struct hnae_handle *handle);
 int hnae_ae_register(struct hnae_ae_dev *dev, struct module *owner);
 void hnae_ae_unregister(struct hnae_ae_dev *dev);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index 77c6edb..ed9a72c 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -848,6 +848,7 @@ static struct hnae_ae_ops hns_dsaf_ops = {
 int hns_dsaf_ae_init(struct dsaf_device *dsaf_dev)
 {
 	struct hnae_ae_dev *ae_dev = &dsaf_dev->ae_dev;
+	static atomic_t id = ATOMIC_INIT(-1);
 
 	switch (dsaf_dev->dsaf_ver) {
 	case AE_VERSION_1:
@@ -859,6 +860,9 @@ int hns_dsaf_ae_init(struct dsaf_device *dsaf_dev)
 	default:
 		break;
 	}
+
+	snprintf(ae_dev->name, AE_NAME_SIZE, "%s%d", DSAF_DEVICE_NAME,
+		 (int)atomic_inc_return(&id));
 	ae_dev->ops = &hns_dsaf_ops;
 	ae_dev->dev = dsaf_dev->dev;
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 636b205..f3de749 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -35,7 +35,7 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 	int ret, i;
 	u32 desc_num;
 	u32 buf_size;
-	const char *name, *mode_str;
+	const char *mode_str;
 	struct device_node *np = dsaf_dev->dev->of_node;
 
 	if (of_device_is_compatible(np, "hisilicon,hns-dsaf-v1"))
@@ -43,14 +43,6 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 	else
 		dsaf_dev->dsaf_ver = AE_VERSION_2;
 
-	ret = of_property_read_string(np, "dsa_name", &name);
-	if (ret) {
-		dev_err(dsaf_dev->dev, "get dsaf name fail, ret=%d!\n", ret);
-		return ret;
-	}
-	strncpy(dsaf_dev->ae_dev.name, name, AE_NAME_SIZE);
-	dsaf_dev->ae_dev.name[AE_NAME_SIZE - 1] = '\0';
-
 	ret = of_property_read_string(np, "mode", &mode_str);
 	if (ret) {
 		dev_err(dsaf_dev->dev, "get dsaf mode fail, ret=%d!\n", ret);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
index 31c312f..40205b9 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
@@ -18,6 +18,7 @@ struct hns_mac_cb;
 
 #define DSAF_DRV_NAME "hns_dsaf"
 #define DSAF_MOD_VERSION "v1.0"
+#define DSAF_DEVICE_NAME "dsaf"
 
 #define HNS_DSAF_DEBUG_NW_REG_OFFSET 0x100000
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index cad2663..33b9aab 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -1778,7 +1778,7 @@ static int hns_nic_try_get_ae(struct net_device *ndev)
 	int ret;
 
 	h = hnae_get_handle(&priv->netdev->dev,
-			    priv->ae_name, priv->port_id, NULL);
+			    priv->ae_node, priv->port_id, NULL);
 	if (IS_ERR_OR_NULL(h)) {
 		ret = PTR_ERR(h);
 		dev_dbg(priv->dev, "has not handle, register notifier!\n");
@@ -1856,9 +1856,12 @@ static int hns_nic_dev_probe(struct platform_device *pdev)
 	else
 		priv->enet_ver = AE_VERSION_2;
 
-	ret = of_property_read_string(node, "ae-name", &priv->ae_name);
-	if (ret)
-		goto out_read_string_fail;
+	priv->ae_node = (void *)of_parse_phandle(node, "ae-handle", 0);
+	if (IS_ERR_OR_NULL(priv->ae_node)) {
+		ret = PTR_ERR(priv->ae_node);
+		dev_err(dev, "not find ae-handle\n");
+		goto out_read_handle_fai;
+	}
 
 	ret = of_property_read_u32(node, "port-id", &priv->port_id);
 	if (ret)
@@ -1921,6 +1924,8 @@ static int hns_nic_dev_probe(struct platform_device *pdev)
 
 out_notify_fail:
 	(void)cancel_work_sync(&priv->service_task);
+out_read_handle_fai:
+
 out_read_string_fail:
 	free_netdev(ndev);
 	return ret;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.h b/drivers/net/ethernet/hisilicon/hns/hns_enet.h
index 4b75270..c68ab3d 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.h
@@ -51,7 +51,7 @@ struct hns_nic_ops {
 };
 
 struct hns_nic_priv {
-	const char *ae_name;
+	const struct device_node *ae_node;
 	u32 enet_ver;
 	u32 port_id;
 	int phy_mode;
-- 
1.9.1
