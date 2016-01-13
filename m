From: Kejian Yan <yankejian@huawei.com>
Subject: [PATCH v2 next-next] net: hns: enet specifies a reference to dsaf
Date: Wed, 13 Jan 2016 11:01:10 +0800
Message-ID: <1452654073-28039-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <haifeng.wei@huawei.com>, <netdev@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>, <robh+dt@kernel.org>, <pawel.moll@arm.com>,
	<mark.rutland@arm.com>, <ijc+devicetree@hellion.org.uk>,
	<galak@codeaurora.org>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <huangdaode@hisilicon.com>,
	<liguozhu@huawei.com>, <arnd@arndb.de>, <fengguang.wu@intel.com>,
	<salil.mehta@huawei.com>, <andriy.shevchenko@linux.intel.com>,
	<lisheng011@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch replace the assoication between dsaf and enet from string
matching to object reference. It requires the DTS to be updated within
BIOS. Thanks god it can be done for all released boards.

Signed-off-by: Kejian Yan <yankejian@huawei.com>
---
change log:
v2:
 merge the two patches into one to allow bisection.

v1:
 first submit.

v1 patch reference:
 https://lkml.org/lkml/2015/12/5/11
 https://lkml.org/lkml/2015/12/5/12
---
 .../devicetree/bindings/net/hisilicon-hns-dsaf.txt    |  5 +----
 .../devicetree/bindings/net/hisilicon-hns-nic.txt     |  7 ++++---
 arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi          | 19 +++++++++----------
 drivers/net/ethernet/hisilicon/hns/hnae.c             | 17 +++++++----------
 drivers/net/ethernet/hisilicon/hns/hnae.h             |  7 +++++--
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c     |  4 ++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c    | 10 +---------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h    |  1 +
 drivers/net/ethernet/hisilicon/hns/hns_enet.c         | 13 +++++++++----
 drivers/net/ethernet/hisilicon/hns/hns_enet.h         |  2 +-
 10 files changed, 42 insertions(+), 43 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
index 80411b2..ecacfa4 100644
--- a/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
+++ b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
@@ -4,8 +4,6 @@ Required properties:
 - compatible: should be "hisilicon,hns-dsaf-v1" or "hisilicon,hns-dsaf-v2".
   "hisilicon,hns-dsaf-v1" is for hip05.
   "hisilicon,hns-dsaf-v2" is for Hi1610 and Hi1612.
-- dsa-name: dsa fabric name who provide this interface.
-  should be "dsafX", X is the dsaf id.
 - mode: dsa fabric mode string. only support one of dsaf modes like these:
 		"2port-64vf",
 		"6port-16rss",
@@ -26,9 +24,8 @@ Required properties:
 
 Example:
 
-dsa: dsa@c7000000 {
+dsaf0: dsa@c7000000 {
 	compatible = "hisilicon,hns-dsaf-v1";
-	dsa_name = "dsaf0";
 	mode = "6port-16rss";
 	interrupt-parent = <&mbigen_dsa>;
 	reg = <0x0 0xC0000000 0x0 0x420000
diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt
index 41d19be..e6a9d1c 100644
--- a/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt
+++ b/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt
@@ -4,8 +4,9 @@ Required properties:
 - compatible: "hisilicon,hns-nic-v1" or "hisilicon,hns-nic-v2".
   "hisilicon,hns-nic-v1" is for hip05.
   "hisilicon,hns-nic-v2" is for Hi1610 and Hi1612.
-- ae-name: accelerator name who provides this interface,
-  is simply a name referring to the name of name in the accelerator node.
+- ae-handle: accelerator engine handle for hns,
+  specifies a reference to the associating hardware driver node.
+  see Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
 - port-id: is the index of port provided by DSAF (the accelerator). DSAF can
   connect to 8 PHYs. Port 0 to 1 are both used for adminstration purpose. They
   are called debug ports.
@@ -41,7 +42,7 @@ Example:
 
 	ethernet@0{
 		compatible = "hisilicon,hns-nic-v1";
-		ae-name = "dsaf0";
+		ae-handle = <&dsaf0>;
 		port-id = <0>;
 		local-mac-address = [a2 14 e4 4b 56 76];
 	};
diff --git a/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi b/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
index 606dd5a..89c883e 100644
--- a/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
+++ b/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
@@ -23,9 +23,8 @@ soc0: soc@000000000 {
 		};
 	};
 
-	dsa: dsa@c7000000 {
+	dsaf0: dsa@c7000000 {
 		compatible = "hisilicon,hns-dsaf-v1";
-		dsa_name = "dsaf0";
 		mode = "6port-16rss";
 		interrupt-parent = <&mbigen_dsa>;
 
@@ -127,7 +126,7 @@ soc0: soc@000000000 {
 
 	eth0: ethernet@0{
 		compatible = "hisilicon,hns-nic-v1";
-		ae-name = "dsaf0";
+		ae-handle = <&dsaf0>;
 		port-id = <0>;
 		local-mac-address = [00 00 00 01 00 58];
 		status = "disabled";
@@ -135,14 +134,14 @@ soc0: soc@000000000 {
 	};
 	eth1: ethernet@1{
 		compatible = "hisilicon,hns-nic-v1";
-		ae-name = "dsaf0";
+		ae-handle = <&dsaf0>;
 		port-id = <1>;
 		status = "disabled";
 		dma-coherent;
 	};
 	eth2: ethernet@2{
 		compatible = "hisilicon,hns-nic-v1";
-		ae-name = "dsaf0";
+		ae-handle = <&dsaf0>;
 		port-id = <2>;
 		local-mac-address = [00 00 00 01 00 5a];
 		status = "disabled";
@@ -150,7 +149,7 @@ soc0: soc@000000000 {
 	};
 	eth3: ethernet@3{
 		compatible = "hisilicon,hns-nic-v1";
-		ae-name = "dsaf0";
+		ae-handle = <&dsaf0>;
 		port-id = <3>;
 		local-mac-address = [00 00 00 01 00 5b];
 		status = "disabled";
@@ -158,7 +157,7 @@ soc0: soc@000000000 {
 	};
 	eth4: ethernet@4{
 		compatible = "hisilicon,hns-nic-v1";
-		ae-name = "dsaf0";
+		ae-handle = <&dsaf0>;
 		port-id = <4>;
 		local-mac-address = [00 00 00 01 00 5c];
 		status = "disabled";
@@ -166,7 +165,7 @@ soc0: soc@000000000 {
 	};
 	eth5: ethernet@5{
 		compatible = "hisilicon,hns-nic-v1";
-		ae-name = "dsaf0";
+		ae-handle = <&dsaf0>;
 		port-id = <5>;
 		local-mac-address = [00 00 00 01 00 5d];
 		status = "disabled";
@@ -174,7 +173,7 @@ soc0: soc@000000000 {
 	};
 	eth6: ethernet@6{
 		compatible = "hisilicon,hns-nic-v1";
-		ae-name = "dsaf0";
+		ae-handle = <&dsaf0>;
 		port-id = <6>;
 		local-mac-address = [00 00 00 01 00 5e];
 		status = "disabled";
@@ -182,7 +181,7 @@ soc0: soc@000000000 {
 	};
 	eth7: ethernet@7{
 		compatible = "hisilicon,hns-nic-v1";
-		ae-name = "dsaf0";
+		ae-handle = <&dsaf0>;
 		port-id = <7>;
 		local-mac-address = [00 00 00 01 00 5f];
 		status = "disabled";
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
index 6ca94dc..1cbcb9f 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.h
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.h
@@ -524,8 +524,11 @@ struct hnae_handle {
 
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
index 522b264..a0070d0 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -847,6 +847,7 @@ static struct hnae_ae_ops hns_dsaf_ops = {
 int hns_dsaf_ae_init(struct dsaf_device *dsaf_dev)
 {
 	struct hnae_ae_dev *ae_dev = &dsaf_dev->ae_dev;
+	static atomic_t id = ATOMIC_INIT(-1);
 
 	switch (dsaf_dev->dsaf_ver) {
 	case AE_VERSION_1:
@@ -858,6 +859,9 @@ int hns_dsaf_ae_init(struct dsaf_device *dsaf_dev)
 	default:
 		break;
 	}
+
+	snprintf(ae_dev->name, AE_NAME_SIZE, "%s%d", DSAF_DEVICE_NAME,
+		 (int)atomic_inc_return(&id));
 	ae_dev->ops = &hns_dsaf_ops;
 	ae_dev->dev = dsaf_dev->dev;
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 1c33bd0..9439f04 100644
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
index 0e30846..340ca54 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -1802,7 +1802,7 @@ static int hns_nic_try_get_ae(struct net_device *ndev)
 	int ret;
 
 	h = hnae_get_handle(&priv->netdev->dev,
-			    priv->ae_name, priv->port_id, NULL);
+			    priv->ae_node, priv->port_id, NULL);
 	if (IS_ERR_OR_NULL(h)) {
 		ret = PTR_ERR(h);
 		dev_dbg(priv->dev, "has not handle, register notifier!\n");
@@ -1880,9 +1880,12 @@ static int hns_nic_dev_probe(struct platform_device *pdev)
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
@@ -1945,6 +1948,8 @@ static int hns_nic_dev_probe(struct platform_device *pdev)
 
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
2.4.1
