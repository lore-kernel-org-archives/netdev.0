From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net-next 07/10] net: hns: separate debug and service device from dsaf device
Date: Fri, 22 Apr 2016 15:20:16 +0800
Message-ID: <1461309619-167621-8-git-send-email-Yisen.Zhuang@huawei.com>
References: <1461309619-167621-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<davem@davemloft.net>, <yankejian@huawei.com>,
	<huangdaode@hisilicon.com>, <salil.mehta@huawei.com>,
	<lipeng321@huawei.com>, <liguozhu@huawei.com>,
	<xieqianqian@huawei.com>, <linuxarm@huawei.com>
To: <devicetree@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:23775 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753018AbcDVHDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 03:03:15 -0400
In-Reply-To: <1461309619-167621-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two kinds of dsaf device in hns. One is for service ports,
contains crossbar in it, can work under different mode. Another is for
debug port, only can work under "single-port" mode. The current code only
declare a dsaf device for both service ports and debug ports. This patch
separate it to three platform devices. The modification makes the code
easier to be read and maintained.

Here is the diagram of all port in one platform device(old):
                                        CPU
                                         |
                                         |        DSAF(one platform device)
    --------------------------------------------------------------      /
    |                           |                  |      |      |     /
    |                          PPE                PPE    PPE     |    /
    |                           |                  |      |      |   /
    |                           |                  |      |      |  /
    |                        crossbar              |      |      | /
    |                           |                  |      |      |/
    |    -----------------------------------       |      |      |
    |    |      |      |      |      |      |      |      |      |
    |    |      |      |      |      |      |      |      |      |
    |   MAC    MAC    MAC    MAC    MAC    MAC    MAC    MAC     |
    |    |      |      |      |      |      |      |      |      |
    --------------------------------------------------------------
         |      |      |      |      |      |      |      |
        PHY    PHY    PHY    PHY    PHY    PHY    PHY    PHY

Here is the diagram of separate all ports to three platform(new):
                                                         CPU
                                                          |
                                    -----------------------------------
                                    |                     |           |
    ----------------------------------------------    ---------   ---------
    |                         |                  |    |       |   |   |   |
    |                        PPE                 |    |  PPE  |   |  PPE  |
    |                         |                  |    |   |   |   |   |   |
    |                         |                  |    |   |   |   |   |   |
    |                      crossbar              |    |   |   |   |   |   |
    |                         |                  |    |   |   |   |   |   |
    |   ----------------------------------       |    |   |   |   |   |   |
    |   |     |     |      |      |      |       |    |   |   |   |   |   |
    |   |     |     |      |      |      |       |    |   |   |   |   |   |
    |  MAC   MAC   MAC    MAC    MAC    MAC      |    |  MAC  |   |  MAC  |
    |   |     |     |      |      |      |       |    |   |   |   |   |   |
    ----------------------------------------------    ---------   ---------
        |     |     |      |      |      |    \        /  |        /  |
       PHY   PHY   PHY    PHY    PHY    PHY    \      /  PHY      /  PHY
                                                \    /           /
                                                 \  /           /
                                             DSAF(three platform device)

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Signed-off-by: Yisen Zhuang <yisen.zhuang@huawei.com>
---
 .../devicetree/bindings/net/hisilicon-hns-dsaf.txt |  50 +++++--
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |  40 ++----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  | 152 +++++++++++++++------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h  |   7 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |  93 ++++++++-----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |  12 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c |  72 ++++++----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c  |  57 ++------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h  |   1 -
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c  |  53 ++-----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |  15 +-
 11 files changed, 301 insertions(+), 251 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
index 291b3d8..0add911 100644
--- a/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
+++ b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
@@ -7,21 +7,40 @@ Required properties:
 - mode: dsa fabric mode string. only support one of dsaf modes like these:
 		"2port-64vf",
 		"6port-16rss",
-		"6port-16vf".
+		"6port-16vf",
+		"single-port".
 - interrupt-parent: the interrupt parent of this device.
 - interrupts: should contain the DSA Fabric and rcb interrupt.
 - reg: specifies base physical address(es) and size of the device registers.
-  The first region is external interface control register base and size.
-  The second region is SerDes base register and size.
+  The first region is external interface control register base and size(optional,
+  only be used when subctrl-syscon is not exists). It is recommended using
+  subctrl-syscon rather than this address.
+  The second region is SerDes base register and size(optional, only be used when
+  serdes-syscon in port node is not exists. It is recommended using
+  serdes-syscon rather than this address.
   The third region is the PPE register base and size.
-  The fourth region is dsa fabric base register and size.
-  The fifth region is cpld base register and size, it is not required if do not use cpld.
-- phy-handle: phy handle of physicl port, 0 if not any phy device. see ethernet.txt [1].
+  The fourth region is dsa fabric base register and size. It is not required for
+  single-port mode.
+- reg-names: may be ppe-base and(or) dsaf-base. It is used to find the
+  corresponding reg's index.
+
+- phy-handle: phy handle of physicl port, 0 if not any phy device. It is optional
+  attribute. If port node is exists, phy-handle in each port node will be used.
+  see ethernet.txt [1].
+- subctrl-syscon: is syscon handle for external interface control register.
 - reset-field-offset: is offset of reset field. Its value depends on the hardware
   user manual.
 - buf-size: rx buffer size, should be 16-1024.
 - desc-num: number of description in TX and RX queue, should be 512, 1024, 2048 or 4096.
 
+- port: subnodes of dsaf. A dsaf node may contain several port nodes(Depending
+  on mode of dsaf). Port node contain some attributes listed below:
+- port-id: is physical port index in one dsaf.
+- phy-handle: phy handle of physicl port. It is not required if there isn't
+  phy device. see ethernet.txt [1].
+- serdes-syscon: is syscon handle for SerDes register.
+
+
 [1] Documentation/devicetree/bindings/net/phy.txt
 
 Example:
@@ -30,11 +49,11 @@ dsaf0: dsa@c7000000 {
 	compatible = "hisilicon,hns-dsaf-v1";
 	mode = "6port-16rss";
 	interrupt-parent = <&mbigen_dsa>;
-	reg = <0x0 0xC0000000 0x0 0x420000
-	       0x0 0xC2000000 0x0 0x300000
-	       0x0 0xc5000000 0x0 0x890000
+	reg = <0x0 0xc5000000 0x0 0x890000
 	       0x0 0xc7000000 0x0 0x60000>;
-	phy-handle = <0 0 0 0 &soc0_phy4 &soc0_phy5 0 0>;
+	reg-names = "ppe-base", "dsaf-base";
+	subctrl-syscon = <&subctrl>;
+	reset-field-offset = 0;
 	interrupts = <131 4>,<132 4>, <133 4>,<134 4>,
 		     <135 4>,<136 4>, <137 4>,<138 4>,
 		     <139 4>,<140 4>, <141 4>,<142 4>,
@@ -45,4 +64,15 @@ dsaf0: dsa@c7000000 {
 	buf-size = <4096>;
 	desc-num = <1024>;
 	dma-coherent;
+
+	prot@0 {
+		port-id = 0;
+		phy-handle = <&phy0>;
+		serdes-syscon = <&serdes>;
+	};
+
+	prot@1 {
+                port-id = 1;
+                serdes-syscon = <&serdes>;
+        };
 };
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index 1c86336..58341da 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -37,50 +37,35 @@ static struct dsaf_device *hns_ae_get_dsaf_dev(struct hnae_ae_dev *dev)
 static struct hns_ppe_cb *hns_get_ppe_cb(struct hnae_handle *handle)
 {
 	int ppe_index;
-	int ppe_common_index;
 	struct ppe_common_cb *ppe_comm;
 	struct  hnae_vf_cb *vf_cb = hns_ae_get_vf_cb(handle);
 
-	if (vf_cb->port_index < DSAF_SERVICE_PORT_NUM_PER_DSAF) {
-		ppe_index = vf_cb->port_index;
-		ppe_common_index = 0;
-	} else {
-		ppe_index = 0;
-		ppe_common_index =
-			vf_cb->port_index - DSAF_SERVICE_PORT_NUM_PER_DSAF + 1;
-	}
-	ppe_comm = vf_cb->dsaf_dev->ppe_common[ppe_common_index];
+	ppe_comm = vf_cb->dsaf_dev->ppe_common[0];
+	ppe_index = vf_cb->port_index;
+
 	return &ppe_comm->ppe_cb[ppe_index];
 }
 
 static int hns_ae_get_q_num_per_vf(
 	struct dsaf_device *dsaf_dev, int port)
 {
-	int common_idx = hns_dsaf_get_comm_idx_by_port(port);
-
-	return dsaf_dev->rcb_common[common_idx]->max_q_per_vf;
+	return dsaf_dev->rcb_common[0]->max_q_per_vf;
 }
 
 static int hns_ae_get_vf_num_per_port(
 	struct dsaf_device *dsaf_dev, int port)
 {
-	int common_idx = hns_dsaf_get_comm_idx_by_port(port);
-
-	return dsaf_dev->rcb_common[common_idx]->max_vfn;
+	return dsaf_dev->rcb_common[0]->max_vfn;
 }
 
 static struct ring_pair_cb *hns_ae_get_base_ring_pair(
 	struct dsaf_device *dsaf_dev, int port)
 {
-	int common_idx = hns_dsaf_get_comm_idx_by_port(port);
-	struct rcb_common_cb *rcb_comm = dsaf_dev->rcb_common[common_idx];
+	struct rcb_common_cb *rcb_comm = dsaf_dev->rcb_common[0];
 	int q_num = rcb_comm->max_q_per_vf;
 	int vf_num = rcb_comm->max_vfn;
 
-	if (!HNS_DSAF_IS_DEBUG(dsaf_dev))
-		return &rcb_comm->ring_pair_cb[port * q_num * vf_num];
-	else
-		return &rcb_comm->ring_pair_cb[0];
+	return &rcb_comm->ring_pair_cb[port * q_num * vf_num];
 }
 
 static struct ring_pair_cb *hns_ae_get_ring_pair(struct hnae_queue *q)
@@ -143,7 +128,7 @@ struct hnae_handle *hns_ae_get_handle(struct hnae_ae_dev *dev,
 
 	vf_cb->dsaf_dev = dsaf_dev;
 	vf_cb->port_index = port_id;
-	vf_cb->mac_cb = &dsaf_dev->mac_cb[port_id];
+	vf_cb->mac_cb = dsaf_dev->mac_cb[port_id];
 
 	ae_handle->phy_if = vf_cb->mac_cb->phy_if;
 	ae_handle->phy_node = vf_cb->mac_cb->phy_node;
@@ -299,11 +284,8 @@ static void hns_ae_reset(struct hnae_handle *handle)
 	struct hnae_vf_cb *vf_cb = hns_ae_get_vf_cb(handle);
 
 	if (vf_cb->mac_cb->mac_type == HNAE_PORT_DEBUG) {
-		u8 ppe_common_index =
-			vf_cb->port_index - DSAF_SERVICE_PORT_NUM_PER_DSAF + 1;
-
 		hns_mac_reset(vf_cb->mac_cb);
-		hns_ppe_reset_common(vf_cb->dsaf_dev, ppe_common_index);
+		hns_ppe_reset_common(vf_cb->dsaf_dev, 0);
 	}
 }
 
@@ -702,7 +684,6 @@ int hns_ae_cpld_set_led_id(struct hnae_handle *handle,
 void hns_ae_get_regs(struct hnae_handle *handle, void *data)
 {
 	u32 *p = data;
-	u32 rcb_com_idx;
 	int i;
 	struct hnae_vf_cb *vf_cb = hns_ae_get_vf_cb(handle);
 	struct hns_ppe_cb *ppe_cb = hns_get_ppe_cb(handle);
@@ -710,8 +691,7 @@ void hns_ae_get_regs(struct hnae_handle *handle, void *data)
 	hns_ppe_get_regs(ppe_cb, p);
 	p += hns_ppe_get_regs_count();
 
-	rcb_com_idx = hns_dsaf_get_comm_idx_by_port(vf_cb->port_index);
-	hns_rcb_get_common_regs(vf_cb->dsaf_dev->rcb_common[rcb_com_idx], p);
+	hns_rcb_get_common_regs(vf_cb->dsaf_dev->rcb_common[0], p);
 	p += hns_rcb_get_common_regs_count();
 
 	for (i = 0; i < handle->q_num; i++) {
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index 3730385..a731777 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -10,6 +10,7 @@
 #include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/kernel.h>
+#include <linux/mfd/syscon.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/of.h>
@@ -168,10 +169,9 @@ static int hns_mac_get_inner_port_num(struct hns_mac_cb *mac_cb,
 				      u8 vmid, u8 *port_num)
 {
 	u8 tmp_port;
-	u32 comm_idx;
 
 	if (mac_cb->dsaf_dev->dsaf_mode <= DSAF_MODE_ENABLE) {
-		if (mac_cb->mac_id != DSAF_MAX_PORT_NUM_PER_CHIP) {
+		if (mac_cb->mac_id != DSAF_MAX_PORT_NUM) {
 			dev_err(mac_cb->dev,
 				"input invalid,%s mac%d vmid%d !\n",
 				mac_cb->dsaf_dev->ae_dev.name,
@@ -179,7 +179,7 @@ static int hns_mac_get_inner_port_num(struct hns_mac_cb *mac_cb,
 			return -EINVAL;
 		}
 	} else if (mac_cb->dsaf_dev->dsaf_mode < DSAF_MODE_MAX) {
-		if (mac_cb->mac_id >= DSAF_MAX_PORT_NUM_PER_CHIP) {
+		if (mac_cb->mac_id >= DSAF_MAX_PORT_NUM) {
 			dev_err(mac_cb->dev,
 				"input invalid,%s mac%d vmid%d!\n",
 				mac_cb->dsaf_dev->ae_dev.name,
@@ -192,9 +192,7 @@ static int hns_mac_get_inner_port_num(struct hns_mac_cb *mac_cb,
 		return -EINVAL;
 	}
 
-	comm_idx = hns_dsaf_get_comm_idx_by_port(mac_cb->mac_id);
-
-	if (vmid >= mac_cb->dsaf_dev->rcb_common[comm_idx]->max_vfn) {
+	if (vmid >= mac_cb->dsaf_dev->rcb_common[0]->max_vfn) {
 		dev_err(mac_cb->dev, "input invalid,%s mac%d vmid%d !\n",
 			mac_cb->dsaf_dev->ae_dev.name, mac_cb->mac_id, vmid);
 		return -EINVAL;
@@ -234,7 +232,7 @@ static int hns_mac_get_inner_port_num(struct hns_mac_cb *mac_cb,
 }
 
 /**
- *hns_mac_get_inner_port_num - change vf mac address
+ *hns_mac_change_vf_addr - change vf mac address
  *@mac_cb: mac device
  *@vmid: vmid
  *@addr:mac address
@@ -651,14 +649,15 @@ free_mac_drv:
 }
 
 /**
- *mac_free_dev  - get mac information from device node
+ *hns_mac_get_info  - get mac information from device node
  *@mac_cb: mac device
  *@np:device node
- *@mac_mode_idx:mac mode index
+ * return: 0 --success, negative --fail
  */
-static void hns_mac_get_info(struct hns_mac_cb *mac_cb,
-			     struct device_node *np, u32 mac_mode_idx)
+static int  hns_mac_get_info(struct hns_mac_cb *mac_cb)
 {
+	struct device_node *np = mac_cb->dev->of_node;
+	struct regmap *syscon;
 	mac_cb->link = false;
 	mac_cb->half_duplex = false;
 	mac_cb->speed = mac_phy_to_speed[mac_cb->phy_if];
@@ -675,11 +674,34 @@ static void hns_mac_get_info(struct hns_mac_cb *mac_cb,
 	mac_cb->max_frm = MAC_DEFAULT_MTU;
 	mac_cb->tx_pause_frm_time = MAC_DEFAULT_PAUSE_TIME;
 
-	/* Get the rest of the PHY information */
-	mac_cb->phy_node = of_parse_phandle(np, "phy-handle", mac_cb->mac_id);
+	/* if the dsaf node doesn't contain a port subnode, get phy-handle
+	 * from dsaf node
+	 */
+	if (!mac_cb->fw_port) {
+		mac_cb->phy_node = of_parse_phandle(np, "phy-handle",
+						    mac_cb->mac_id);
+		if (mac_cb->phy_node)
+			dev_dbg(mac_cb->dev, "mac%d phy_node: %s\n",
+				mac_cb->mac_id, mac_cb->phy_node->name);
+		return 0;
+	}
+	if (!is_of_node(mac_cb->fw_port))
+		return -EINVAL;
+	/* parse property from port subnode in dsaf */
+	mac_cb->phy_node = of_parse_phandle(to_of_node(mac_cb->fw_port),
+					    "phy-handle", 0);
 	if (mac_cb->phy_node)
 		dev_dbg(mac_cb->dev, "mac%d phy_node: %s\n",
 			mac_cb->mac_id, mac_cb->phy_node->name);
+	syscon = syscon_node_to_regmap(
+			of_parse_phandle(to_of_node(mac_cb->fw_port),
+					 "serdes-syscon", 0));
+	if (IS_ERR_OR_NULL(syscon)) {
+		dev_err(mac_cb->dev, "serdes-syscon is needed!\n");
+		return -EINVAL;
+	}
+	mac_cb->serdes_ctrl = syscon;
+	return 0;
 }
 
 /**
@@ -709,31 +731,27 @@ u8 __iomem *hns_mac_get_vaddr(struct dsaf_device *dsaf_dev,
 		return base + 0x40000 + mac_id * 0x4000 -
 				mac_mode_idx * 0x20000;
 	else
-		return mac_cb->serdes_vaddr + 0x1000
-			+ (mac_id - DSAF_SERVICE_PORT_NUM_PER_DSAF) * 0x100000;
+		return dsaf_dev->ppe_base + 0x1000;
 }
 
 /**
  * hns_mac_get_cfg - get mac cfg from dtb or acpi table
  * @dsaf_dev: dsa fabric device struct pointer
- * @mac_idx: mac index
- * retuen 0 - success , negative --fail
+ * @mac_cb: mac control block
+ * return 0 - success , negative --fail
  */
-int hns_mac_get_cfg(struct dsaf_device *dsaf_dev, int mac_idx)
+int hns_mac_get_cfg(struct dsaf_device *dsaf_dev, struct hns_mac_cb *mac_cb)
 {
 	int ret;
 	u32 mac_mode_idx;
-	struct hns_mac_cb *mac_cb = &dsaf_dev->mac_cb[mac_idx];
 
 	mac_cb->dsaf_dev = dsaf_dev;
 	mac_cb->dev = dsaf_dev->dev;
-	mac_cb->mac_id = mac_idx;
 
 	mac_cb->sys_ctl_vaddr =	dsaf_dev->sc_base;
 	mac_cb->serdes_vaddr = dsaf_dev->sds_base;
 
-	if (dsaf_dev->cpld_base &&
-	    mac_idx < DSAF_SERVICE_PORT_NUM_PER_DSAF) {
+	if (dsaf_dev->cpld_base && !HNS_DSAF_IS_DEBUG(dsaf_dev)) {
 		mac_cb->cpld_vaddr = dsaf_dev->cpld_base +
 			mac_cb->mac_id * CPLD_ADDR_PORT_OFFSET;
 		cpld_led_reset(mac_cb);
@@ -742,7 +760,7 @@ int hns_mac_get_cfg(struct dsaf_device *dsaf_dev, int mac_idx)
 	mac_cb->txpkt_for_led = 0;
 	mac_cb->rxpkt_for_led = 0;
 
-	if (mac_idx < DSAF_SERVICE_PORT_NUM_PER_DSAF)
+	if (!HNS_DSAF_IS_DEBUG(dsaf_dev))
 		mac_cb->mac_type = HNAE_PORT_SERVICE;
 	else
 		mac_cb->mac_type = HNAE_PORT_DEBUG;
@@ -758,53 +776,99 @@ int hns_mac_get_cfg(struct dsaf_device *dsaf_dev, int mac_idx)
 	}
 	mac_mode_idx = (u32)ret;
 
-	hns_mac_get_info(mac_cb, mac_cb->dev->of_node, mac_mode_idx);
+	ret  = hns_mac_get_info(mac_cb);
+	if (ret)
+		return ret;
 
 	mac_cb->vaddr = hns_mac_get_vaddr(dsaf_dev, mac_cb, mac_mode_idx);
 
 	return 0;
 }
 
+static int hns_mac_get_max_port_num(struct dsaf_device *dsaf_dev)
+{
+	if (HNS_DSAF_IS_DEBUG(dsaf_dev))
+		return 1;
+	else
+		return  DSAF_MAX_PORT_NUM;
+}
+
 /**
  * hns_mac_init - init mac
  * @dsaf_dev: dsa fabric device struct pointer
- * retuen 0 - success , negative --fail
+ * return 0 - success , negative --fail
  */
 int hns_mac_init(struct dsaf_device *dsaf_dev)
 {
-	int i;
+	bool found = false;
 	int ret;
-	size_t size;
+	u32 port_id;
+	int max_port_num = hns_mac_get_max_port_num(dsaf_dev);
 	struct hns_mac_cb *mac_cb;
+	struct fwnode_handle *child;
 
-	size = sizeof(struct hns_mac_cb) * DSAF_MAX_PORT_NUM_PER_CHIP;
-	dsaf_dev->mac_cb = devm_kzalloc(dsaf_dev->dev, size, GFP_KERNEL);
-	if (!dsaf_dev->mac_cb)
-		return -ENOMEM;
+	device_for_each_child_node(dsaf_dev->dev, child) {
+		ret = fwnode_property_read_u32(child, "port-id", &port_id);
+		if (ret) {
+			dev_err(dsaf_dev->dev,
+				"get port-id fail, ret=%d!\n", ret);
+			return ret;
+		}
+		if (port_id >= max_port_num) {
+			dev_err(dsaf_dev->dev,
+				"port-id(%u) out of range!\n", port_id);
+			return -EINVAL;
+		}
+		mac_cb = devm_kzalloc(dsaf_dev->dev, sizeof(*mac_cb),
+				      GFP_KERNEL);
+		if (!mac_cb)
+			return -ENOMEM;
+		mac_cb->fw_port = child;
+		mac_cb->mac_id = (u8)port_id;
+		dsaf_dev->mac_cb[port_id] = mac_cb;
+		found = true;
+	}
 
-	for (i = 0; i < DSAF_MAX_PORT_NUM_PER_CHIP; i++) {
-		ret = hns_mac_get_cfg(dsaf_dev, i);
-		if (ret)
-			goto free_mac_cb;
+	/* if don't get any port subnode from dsaf node
+	 * will init all port then, this is compatible with the old dts
+	 */
+	if (!found) {
+		for (port_id = 0; port_id < max_port_num; port_id++) {
+			mac_cb = devm_kzalloc(dsaf_dev->dev, sizeof(*mac_cb),
+					      GFP_KERNEL);
+			if (!mac_cb)
+				return -ENOMEM;
+
+			mac_cb->mac_id = port_id;
+			dsaf_dev->mac_cb[port_id] = mac_cb;
+		}
+	}
+	/* init mac_cb for all port */
+	for (port_id = 0; port_id < max_port_num; port_id++) {
+		mac_cb = dsaf_dev->mac_cb[port_id];
+		if (!mac_cb)
+			continue;
 
-		mac_cb = &dsaf_dev->mac_cb[i];
+		ret = hns_mac_get_cfg(dsaf_dev, mac_cb);
+		if (ret)
+			return ret;
 		ret = hns_mac_init_ex(mac_cb);
 		if (ret)
-			goto free_mac_cb;
+			return ret;
 	}
 
 	return 0;
-
-free_mac_cb:
-	dsaf_dev->mac_cb = NULL;
-
-	return ret;
 }
 
 void hns_mac_uninit(struct dsaf_device *dsaf_dev)
 {
-	cpld_led_reset(dsaf_dev->mac_cb);
-	dsaf_dev->mac_cb = NULL;
+	int i;
+	int max_port_num = hns_mac_get_max_port_num(dsaf_dev);
+
+	for (i = 0; i < max_port_num; i++) {
+		cpld_led_reset(dsaf_dev->mac_cb[i]);
+		dsaf_dev->mac_cb[i] = NULL;
+	}
 }
 
 int hns_mac_config_mac_loopback(struct hns_mac_cb *mac_cb,
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
index 823b6e7..45c5f16 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
@@ -10,9 +10,10 @@
 #ifndef _HNS_DSAF_MAC_H
 #define _HNS_DSAF_MAC_H
 
-#include <linux/phy.h>
-#include <linux/kernel.h>
 #include <linux/if_vlan.h>
+#include <linux/kernel.h>
+#include <linux/phy.h>
+#include <linux/regmap.h>
 #include "hns_dsaf_main.h"
 
 struct dsaf_device;
@@ -310,10 +311,12 @@ struct hns_mac_cb {
 	struct device *dev;
 	struct dsaf_device *dsaf_dev;
 	struct mac_priv priv;
+	struct fwnode_handle *fw_port;
 	u8 __iomem *vaddr;
 	u8 __iomem *cpld_vaddr;
 	u8 __iomem *sys_ctl_vaddr;
 	u8 __iomem *serdes_vaddr;
+	struct regmap *serdes_ctrl;
 	struct mac_entry_idx addr_entry_idx[DSAF_MAX_VM_NUM];
 	u8 sfp_prsnt;
 	u8 cpld_led_value;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 98e0e83..33cdb21 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -13,6 +13,7 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
+#include <linux/mfd/syscon.h>
 #include <linux/of.h>
 #include <linux/of_address.h>
 #include <linux/of_irq.h>
@@ -37,8 +38,12 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 	u32 desc_num;
 	u32 buf_size;
 	u32 reset_offset = 0;
+	u32 res_idx = 0;
 	const char *mode_str;
+	struct regmap *syscon;
+	struct resource *res;
 	struct device_node *np = dsaf_dev->dev->of_node;
+	struct platform_device *pdev = to_platform_device(dsaf_dev->dev);
 
 	if (of_device_is_compatible(np, "hisilicon,hns-dsaf-v1"))
 		dsaf_dev->dsaf_ver = AE_VERSION_1;
@@ -75,42 +80,68 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 	else
 		dsaf_dev->dsaf_tc_mode = HRD_DSAF_4TC_MODE;
 
-	dsaf_dev->sc_base = of_iomap(np, 0);
-	if (!dsaf_dev->sc_base) {
-		dev_err(dsaf_dev->dev,
-			"%s of_iomap 0 fail!\n", dsaf_dev->ae_dev.name);
-		ret = -ENOMEM;
-		goto unmap_base_addr;
-	}
+	syscon = syscon_node_to_regmap(
+			of_parse_phandle(np, "subctrl-syscon", 0));
+	if (IS_ERR_OR_NULL(syscon)) {
+		res = platform_get_resource(pdev, IORESOURCE_MEM, res_idx++);
+		if (!res) {
+			dev_err(dsaf_dev->dev, "subctrl info is needed!\n");
+			return -ENOMEM;
+		}
+		dsaf_dev->sc_base = devm_ioremap_resource(&pdev->dev, res);
+		if (!dsaf_dev->sc_base) {
+			dev_err(dsaf_dev->dev, "subctrl can not map!\n");
+			return -ENOMEM;
+		}
 
-	dsaf_dev->sds_base = of_iomap(np, 1);
-	if (!dsaf_dev->sds_base) {
-		dev_err(dsaf_dev->dev,
-			"%s of_iomap 1 fail!\n", dsaf_dev->ae_dev.name);
-		ret = -ENOMEM;
-		goto unmap_base_addr;
+		res = platform_get_resource(pdev, IORESOURCE_MEM, res_idx++);
+		if (!res) {
+			dev_err(dsaf_dev->dev, "serdes-ctrl info is needed!\n");
+			return -ENOMEM;
+		}
+		dsaf_dev->sds_base = devm_ioremap_resource(&pdev->dev, res);
+		if (!dsaf_dev->sds_base) {
+			dev_err(dsaf_dev->dev, "serdes-ctrl can not map!\n");
+			return -ENOMEM;
+		}
+	} else {
+		dsaf_dev->sub_ctrl = syscon;
 	}
 
-	dsaf_dev->ppe_base = of_iomap(np, 2);
-	if (!dsaf_dev->ppe_base) {
-		dev_err(dsaf_dev->dev,
-			"%s of_iomap 2 fail!\n", dsaf_dev->ae_dev.name);
-		ret = -ENOMEM;
-		goto unmap_base_addr;
+	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "ppe-base");
+	if (!res) {
+		res = platform_get_resource(pdev, IORESOURCE_MEM, res_idx++);
+		if (!res) {
+			dev_err(dsaf_dev->dev, "ppe-base info is needed!\n");
+			return -ENOMEM;
+		}
 	}
-
-	dsaf_dev->io_base = of_iomap(np, 3);
-	if (!dsaf_dev->io_base) {
-		dev_err(dsaf_dev->dev,
-			"%s of_iomap 3 fail!\n", dsaf_dev->ae_dev.name);
-		ret = -ENOMEM;
-		goto unmap_base_addr;
+	dsaf_dev->ppe_base = devm_ioremap_resource(&pdev->dev, res);
+	if (!dsaf_dev->ppe_base) {
+		dev_err(dsaf_dev->dev, "ppe-base resource can not map!\n");
+		return -ENOMEM;
+	}
+	dsaf_dev->ppe_paddr = res->start;
+
+	if (!HNS_DSAF_IS_DEBUG(dsaf_dev)) {
+		res = platform_get_resource_byname(pdev, IORESOURCE_MEM,
+						   "dsaf-base");
+		if (!res) {
+			res = platform_get_resource(pdev, IORESOURCE_MEM,
+						    res_idx);
+			if (!res) {
+				dev_err(dsaf_dev->dev,
+					"dsaf-base info is needed!\n");
+				return -ENOMEM;
+			}
+		}
+		dsaf_dev->io_base = devm_ioremap_resource(&pdev->dev, res);
+		if (!dsaf_dev->io_base) {
+			dev_err(dsaf_dev->dev, "dsaf-base resource can not map!\n");
+			return -ENOMEM;
+		}
 	}
 
-	dsaf_dev->cpld_base = of_iomap(np, 4);
-	if (!dsaf_dev->cpld_base)
-		dev_dbg(dsaf_dev->dev, "NO CPLD ADDR");
-
 	ret = of_property_read_u32(np, "desc-num", &desc_num);
 	if (ret < 0 || desc_num < HNS_DSAF_MIN_DESC_CNT ||
 	    desc_num > HNS_DSAF_MAX_DESC_CNT) {
@@ -725,7 +756,7 @@ void hns_dsaf_set_promisc_mode(struct dsaf_device *dsaf_dev, u32 en)
 void hns_dsaf_set_inner_lb(struct dsaf_device *dsaf_dev, u32 mac_id, u32 en)
 {
 	if (AE_IS_VER1(dsaf_dev->dsaf_ver) ||
-	    dsaf_dev->mac_cb[mac_id].mac_type == HNAE_PORT_DEBUG)
+	    dsaf_dev->mac_cb[mac_id]->mac_type == HNAE_PORT_DEBUG)
 		return;
 
 	dsaf_set_dev_bit(dsaf_dev, DSAFV2_SERDES_LBK_0_REG + 4 * mac_id,
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
index 47e768b..a48ef26 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
@@ -278,6 +278,8 @@ struct dsaf_device {
 	u8 __iomem *ppe_base;
 	u8 __iomem *io_base;
 	u8 __iomem *cpld_base;
+	struct regmap *sub_ctrl;
+	phys_addr_t ppe_paddr;
 
 	u32 desc_num; /*  desc num per queue*/
 	u32 buf_size; /*  ring buffer size */
@@ -290,7 +292,7 @@ struct dsaf_device {
 
 	struct ppe_common_cb *ppe_common[DSAF_COMM_DEV_NUM];
 	struct rcb_common_cb *rcb_common[DSAF_COMM_DEV_NUM];
-	struct hns_mac_cb *mac_cb;
+	struct hns_mac_cb *mac_cb[DSAF_MAX_PORT_NUM];
 
 	struct dsaf_hw_stats hw_stats[DSAF_NODE_NUM];
 	struct dsaf_int_stat int_stat;
@@ -362,14 +364,6 @@ static inline void hns_dsaf_tbl_line_addr_cfg(struct dsaf_device *dsaf_dev,
 			   tab_line_addr);
 }
 
-static inline int hns_dsaf_get_comm_idx_by_port(int port)
-{
-	if ((port < DSAF_COMM_CHN) || (port == DSAF_MAX_PORT_NUM_PER_CHIP))
-		return 0;
-	else
-		return (port - DSAF_COMM_CHN + 1);
-}
-
 static inline struct hnae_vf_cb *hns_ae_get_vf_cb(
 	struct hnae_handle *handle)
 {
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
index 67c8b9e..972eab0 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
@@ -12,6 +12,26 @@
 #include "hns_dsaf_ppe.h"
 #include "hns_dsaf_reg.h"
 
+static void dsaf_write_sub(struct dsaf_device *dsaf_dev, u32 reg, u32 val)
+{
+	if (dsaf_dev->sub_ctrl)
+		dsaf_write_syscon(dsaf_dev->sub_ctrl, reg, val);
+	else
+		dsaf_write_reg(dsaf_dev->sc_base, reg, val);
+}
+
+static u32 dsaf_read_sub(struct dsaf_device *dsaf_dev, u32 reg)
+{
+	u32 ret;
+
+	if (dsaf_dev->sub_ctrl)
+		ret = dsaf_read_syscon(dsaf_dev->sub_ctrl, reg);
+	else
+		ret = dsaf_read_reg(dsaf_dev->sc_base, reg);
+
+	return ret;
+}
+
 void hns_cpld_set_led(struct hns_mac_cb *mac_cb, int link_status,
 		      u16 speed, int data)
 {
@@ -95,10 +115,8 @@ void hns_dsaf_rst(struct dsaf_device *dsaf_dev, u32 val)
 		nt_reg_addr = DSAF_SUB_SC_NT_RESET_DREQ_REG;
 	}
 
-	dsaf_write_reg(dsaf_dev->sc_base, xbar_reg_addr,
-		       RESET_REQ_OR_DREQ);
-	dsaf_write_reg(dsaf_dev->sc_base, nt_reg_addr,
-		       RESET_REQ_OR_DREQ);
+	dsaf_write_sub(dsaf_dev, xbar_reg_addr, RESET_REQ_OR_DREQ);
+	dsaf_write_sub(dsaf_dev, nt_reg_addr, RESET_REQ_OR_DREQ);
 }
 
 void hns_dsaf_xge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
@@ -121,7 +139,7 @@ void hns_dsaf_xge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
 	else
 		reg_addr = DSAF_SUB_SC_XGE_RESET_DREQ_REG;
 
-	dsaf_write_reg(dsaf_dev->sc_base, reg_addr, reg_val);
+	dsaf_write_sub(dsaf_dev, reg_addr, reg_val);
 }
 
 void hns_dsaf_xge_core_srst_by_port(struct dsaf_device *dsaf_dev,
@@ -144,7 +162,7 @@ void hns_dsaf_xge_core_srst_by_port(struct dsaf_device *dsaf_dev,
 	else
 		reg_addr = DSAF_SUB_SC_XGE_RESET_DREQ_REG;
 
-	dsaf_write_reg(dsaf_dev->sc_base, reg_addr, reg_val);
+	dsaf_write_sub(dsaf_dev, reg_addr, reg_val);
 }
 
 void hns_dsaf_ge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
@@ -164,20 +182,16 @@ void hns_dsaf_ge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
 			reg_val_2  = 0x2082082 << port;
 
 		if (val == 0) {
-			dsaf_write_reg(dsaf_dev->sc_base,
-				       DSAF_SUB_SC_GE_RESET_REQ1_REG,
+			dsaf_write_sub(dsaf_dev, DSAF_SUB_SC_GE_RESET_REQ1_REG,
 				       reg_val_1);
 
-			dsaf_write_reg(dsaf_dev->sc_base,
-				       DSAF_SUB_SC_GE_RESET_REQ0_REG,
+			dsaf_write_sub(dsaf_dev, DSAF_SUB_SC_GE_RESET_REQ0_REG,
 				       reg_val_2);
 		} else {
-			dsaf_write_reg(dsaf_dev->sc_base,
-				       DSAF_SUB_SC_GE_RESET_DREQ0_REG,
+			dsaf_write_sub(dsaf_dev, DSAF_SUB_SC_GE_RESET_DREQ0_REG,
 				       reg_val_2);
 
-			dsaf_write_reg(dsaf_dev->sc_base,
-				       DSAF_SUB_SC_GE_RESET_DREQ1_REG,
+			dsaf_write_sub(dsaf_dev, DSAF_SUB_SC_GE_RESET_DREQ1_REG,
 				       reg_val_1);
 		}
 	} else {
@@ -185,20 +199,16 @@ void hns_dsaf_ge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
 		reg_val_2 = 0x100 << dsaf_dev->reset_offset;
 
 		if (val == 0) {
-			dsaf_write_reg(dsaf_dev->sc_base,
-				       DSAF_SUB_SC_GE_RESET_REQ1_REG,
+			dsaf_write_sub(dsaf_dev, DSAF_SUB_SC_GE_RESET_REQ1_REG,
 				       reg_val_1);
 
-			dsaf_write_reg(dsaf_dev->sc_base,
-				       DSAF_SUB_SC_PPE_RESET_REQ_REG,
+			dsaf_write_sub(dsaf_dev, DSAF_SUB_SC_PPE_RESET_REQ_REG,
 				       reg_val_2);
 		} else {
-			dsaf_write_reg(dsaf_dev->sc_base,
-				       DSAF_SUB_SC_GE_RESET_DREQ1_REG,
+			dsaf_write_sub(dsaf_dev, DSAF_SUB_SC_GE_RESET_DREQ1_REG,
 				       reg_val_1);
 
-			dsaf_write_reg(dsaf_dev->sc_base,
-				       DSAF_SUB_SC_PPE_RESET_DREQ_REG,
+			dsaf_write_sub(dsaf_dev, DSAF_SUB_SC_PPE_RESET_DREQ_REG,
 				       reg_val_2);
 		}
 	}
@@ -220,7 +230,7 @@ void hns_ppe_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
 	else
 		reg_addr = DSAF_SUB_SC_PPE_RESET_DREQ_REG;
 
-	dsaf_write_reg(dsaf_dev->sc_base, reg_addr, reg_val);
+	dsaf_write_sub(dsaf_dev, reg_addr, reg_val);
 }
 
 void hns_ppe_com_srst(struct ppe_common_cb *ppe_common, u32 val)
@@ -245,7 +255,7 @@ void hns_ppe_com_srst(struct ppe_common_cb *ppe_common, u32 val)
 			reg_addr = DSAF_SUB_SC_PPE_RESET_DREQ_REG;
 	}
 
-	dsaf_write_reg(dsaf_dev->sc_base, reg_addr, reg_val);
+	dsaf_write_sub(dsaf_dev, reg_addr, reg_val);
 }
 
 /**
@@ -260,7 +270,6 @@ phy_interface_t hns_mac_get_phy_if(struct hns_mac_cb *mac_cb)
 	u32 shift;
 	u32 phy_offset;
 	bool is_ver1 = AE_IS_VER1(mac_cb->dsaf_dev->dsaf_ver);
-	void __iomem *sys_ctl_vaddr = mac_cb->sys_ctl_vaddr;
 	int mac_id = mac_cb->mac_id;
 	phy_interface_t phy_if = PHY_INTERFACE_MODE_NA;
 
@@ -269,7 +278,7 @@ phy_interface_t hns_mac_get_phy_if(struct hns_mac_cb *mac_cb)
 	} else if (mac_id >= 0 && mac_id <= 3 &&
 		   !HNS_DSAF_IS_DEBUG(mac_cb->dsaf_dev)) {
 		reg = is_ver1 ? HNS_MAC_HILINK4_REG : HNS_MAC_HILINK4V2_REG;
-		mode = dsaf_read_reg(sys_ctl_vaddr, reg);
+		mode = dsaf_read_sub(mac_cb->dsaf_dev, reg);
 		/* mac_id 0, 1, 2, 3 ---> hilink4 lane 0, 1, 2, 3 */
 		shift = is_ver1 ? 0 : mac_id;
 		if (dsaf_get_bit(mode, shift))
@@ -278,7 +287,7 @@ phy_interface_t hns_mac_get_phy_if(struct hns_mac_cb *mac_cb)
 			phy_if = PHY_INTERFACE_MODE_SGMII;
 	} else {
 		reg = is_ver1 ? HNS_MAC_HILINK3_REG : HNS_MAC_HILINK3V2_REG;
-		mode = dsaf_read_reg(sys_ctl_vaddr, reg);
+		mode = dsaf_read_sub(mac_cb->dsaf_dev, reg);
 		/* mac_id 4, 5,---> hilink3 lane 2, 3
 		 * debug port 0(6), 1(7) ---> hilink3 lane 0, 1
 		 */
@@ -328,7 +337,14 @@ int hns_mac_config_sds_loopback(struct hns_mac_cb *mac_cb, u8 en)
 				pr_info("no sfp in this eth\n");
 	}
 
-	dsaf_set_reg_field(base_addr, reg_offset, 1ull << 10, 10, !!en);
+	if (mac_cb->serdes_ctrl) {
+		u32 origin = dsaf_read_syscon(mac_cb->serdes_ctrl, reg_offset);
+
+		dsaf_set_field(origin, 1ull << 10, 10, !!en);
+		dsaf_write_syscon(mac_cb->serdes_ctrl, reg_offset, origin);
+	} else {
+		dsaf_set_reg_field(base_addr, reg_offset, 1ull << 10, 10, !!en);
+	}
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
index 3f59a8a..8cd151a 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
@@ -61,22 +61,10 @@ void hns_ppe_set_indir_table(struct hns_ppe_cb *ppe_cb,
 	}
 }
 
-static void __iomem *hns_ppe_common_get_ioaddr(
-	struct ppe_common_cb *ppe_common)
+static void __iomem *
+hns_ppe_common_get_ioaddr(struct ppe_common_cb *ppe_common)
 {
-	void __iomem *base_addr;
-
-	int idx = ppe_common->comm_index;
-
-	if (!HNS_DSAF_IS_DEBUG(ppe_common->dsaf_dev))
-		base_addr = ppe_common->dsaf_dev->ppe_base
-			+ PPE_COMMON_REG_OFFSET;
-	else
-		base_addr = ppe_common->dsaf_dev->sds_base
-			+ (idx - 1) * HNS_DSAF_DEBUG_NW_REG_OFFSET
-			+ PPE_COMMON_REG_OFFSET;
-
-	return base_addr;
+	return ppe_common->dsaf_dev->ppe_base + PPE_COMMON_REG_OFFSET;
 }
 
 /**
@@ -124,32 +112,8 @@ void hns_ppe_common_free_cfg(struct dsaf_device *dsaf_dev, u32 comm_index)
 static void __iomem *hns_ppe_get_iobase(struct ppe_common_cb *ppe_common,
 					int ppe_idx)
 {
-	void __iomem *base_addr;
-	int common_idx = ppe_common->comm_index;
-
-	if (ppe_common->ppe_mode == PPE_COMMON_MODE_SERVICE) {
-		base_addr = ppe_common->dsaf_dev->ppe_base +
-			ppe_idx * PPE_REG_OFFSET;
-
-	} else {
-		base_addr = ppe_common->dsaf_dev->sds_base +
-			(common_idx - 1) * HNS_DSAF_DEBUG_NW_REG_OFFSET;
-	}
 
-	return base_addr;
-}
-
-static int hns_ppe_get_port(struct ppe_common_cb *ppe_common, int idx)
-{
-	int port;
-
-	if (ppe_common->ppe_mode == PPE_COMMON_MODE_SERVICE)
-		port = idx;
-	else
-		port = HNS_PPE_SERVICE_NW_ENGINE_NUM
-			+ ppe_common->comm_index - 1;
-
-	return port;
+	return ppe_common->dsaf_dev->ppe_base + ppe_idx * PPE_REG_OFFSET;
 }
 
 static void hns_ppe_get_cfg(struct ppe_common_cb *ppe_common)
@@ -164,7 +128,6 @@ static void hns_ppe_get_cfg(struct ppe_common_cb *ppe_common)
 		ppe_cb->next = NULL;
 		ppe_cb->ppe_common_cb = ppe_common;
 		ppe_cb->index = i;
-		ppe_cb->port = hns_ppe_get_port(ppe_common, i);
 		ppe_cb->io_base = hns_ppe_get_iobase(ppe_common, i);
 		ppe_cb->virq = 0;
 	}
@@ -318,7 +281,7 @@ static void hns_ppe_exc_irq_en(struct hns_ppe_cb *ppe_cb, int en)
 static void hns_ppe_init_hw(struct hns_ppe_cb *ppe_cb)
 {
 	struct ppe_common_cb *ppe_common_cb = ppe_cb->ppe_common_cb;
-	u32 port = ppe_cb->port;
+	u32 port = ppe_cb->index;
 	struct dsaf_device *dsaf_dev = ppe_common_cb->dsaf_dev;
 	int i;
 
@@ -377,7 +340,8 @@ void hns_ppe_uninit_ex(struct ppe_common_cb *ppe_common)
 	u32 i;
 
 	for (i = 0; i < ppe_common->ppe_num; i++) {
-		hns_ppe_uninit_hw(&ppe_common->ppe_cb[i]);
+		if (ppe_common->dsaf_dev->mac_cb[i])
+			hns_ppe_uninit_hw(&ppe_common->ppe_cb[i]);
 		memset(&ppe_common->ppe_cb[i], 0, sizeof(struct hns_ppe_cb));
 	}
 }
@@ -410,8 +374,11 @@ void hns_ppe_reset_common(struct dsaf_device *dsaf_dev, u8 ppe_common_index)
 	if (ret)
 		return;
 
-	for (i = 0; i < ppe_common->ppe_num; i++)
-		hns_ppe_init_hw(&ppe_common->ppe_cb[i]);
+	for (i = 0; i < ppe_common->ppe_num; i++) {
+		/* We only need to initiate ppe when the port exists */
+		if (dsaf_dev->mac_cb[i])
+			hns_ppe_init_hw(&ppe_common->ppe_cb[i]);
+	}
 
 	ret = hns_rcb_common_init_hw(dsaf_dev->rcb_common[ppe_common_index]);
 	if (ret)
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h
index e9c0ec2..9d8e643 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h
@@ -80,7 +80,6 @@ struct hns_ppe_cb {
 	struct hns_ppe_hw_stats hw_stats;
 
 	u8 index;	/* index in a ppe common device */
-	u8 port;			 /* port id in dsaf  */
 	void __iomem *io_base;
 	int virq;
 	u32 rss_indir_table[HNS_PPEV2_RSS_IND_TBL_SIZE]; /*shadow indir tab */
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
index 054f391..4ef6d23 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
@@ -430,17 +430,8 @@ static void hns_rcb_ring_pair_get_cfg(struct ring_pair_cb *ring_pair_cb)
 static int hns_rcb_get_port_in_comm(
 	struct rcb_common_cb *rcb_common, int ring_idx)
 {
-	int port;
-	int q_num;
 
-	if (!HNS_DSAF_IS_DEBUG(rcb_common->dsaf_dev)) {
-		q_num = (int)rcb_common->max_q_per_vf * rcb_common->max_vfn;
-		port = ring_idx / q_num;
-	} else {
-		port = 0; /* config debug-ports port_id_in_comm to 0*/
-	}
-
-	return port;
+	return ring_idx / (rcb_common->max_q_per_vf * rcb_common->max_vfn);
 }
 
 #define SERVICE_RING_IRQ_IDX(v1) \
@@ -658,42 +649,18 @@ int hns_rcb_get_ring_num(struct dsaf_device *dsaf_dev)
 	}
 }
 
-void __iomem *hns_rcb_common_get_vaddr(struct dsaf_device *dsaf_dev,
-				       int comm_index)
+void __iomem *hns_rcb_common_get_vaddr(struct rcb_common_cb *rcb_common)
 {
-	void __iomem *base_addr;
-
-	if (!HNS_DSAF_IS_DEBUG(dsaf_dev))
-		base_addr = dsaf_dev->ppe_base + RCB_COMMON_REG_OFFSET;
-	else
-		base_addr = dsaf_dev->sds_base
-			+ (comm_index - 1) * HNS_DSAF_DEBUG_NW_REG_OFFSET
-			+ RCB_COMMON_REG_OFFSET;
+	struct dsaf_device *dsaf_dev = rcb_common->dsaf_dev;
 
-	return base_addr;
+	return dsaf_dev->ppe_base + RCB_COMMON_REG_OFFSET;
 }
 
-static phys_addr_t hns_rcb_common_get_paddr(struct dsaf_device *dsaf_dev,
-					    int comm_index)
+static phys_addr_t hns_rcb_common_get_paddr(struct rcb_common_cb *rcb_common)
 {
-	struct device_node *np = dsaf_dev->dev->of_node;
-	phys_addr_t phy_addr;
-	const __be32 *tmp_addr;
-	u64 addr_offset = 0;
-	u64 size = 0;
-	int index = 0;
-
-	if (!HNS_DSAF_IS_DEBUG(dsaf_dev)) {
-		index    = 2;
-		addr_offset = RCB_COMMON_REG_OFFSET;
-	} else {
-		index    = 1;
-		addr_offset = (comm_index - 1) * HNS_DSAF_DEBUG_NW_REG_OFFSET +
-				RCB_COMMON_REG_OFFSET;
-	}
-	tmp_addr  = of_get_address(np, index, &size, NULL);
-	phy_addr  = of_translate_address(np, tmp_addr);
-	return phy_addr + addr_offset;
+	struct dsaf_device *dsaf_dev = rcb_common->dsaf_dev;
+
+	return dsaf_dev->ppe_paddr + RCB_COMMON_REG_OFFSET;
 }
 
 int hns_rcb_common_get_cfg(struct dsaf_device *dsaf_dev,
@@ -722,8 +689,8 @@ int hns_rcb_common_get_cfg(struct dsaf_device *dsaf_dev,
 	rcb_common->max_vfn = max_vfn;
 	rcb_common->max_q_per_vf = max_q_per_vf;
 
-	rcb_common->io_base = hns_rcb_common_get_vaddr(dsaf_dev, comm_index);
-	rcb_common->phy_base = hns_rcb_common_get_paddr(dsaf_dev, comm_index);
+	rcb_common->io_base = hns_rcb_common_get_vaddr(rcb_common);
+	rcb_common->phy_base = hns_rcb_common_get_paddr(rcb_common);
 
 	dsaf_dev->rcb_common[comm_index] = rcb_common;
 	return 0;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
index 6a03c94..7c3b510 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -11,16 +11,15 @@
 #define _DSAF_REG_H_
 
 #include <linux/regmap.h>
-#define HNS_DEBUG_RING_IRQ_IDX 0
-#define HNS_SERVICE_RING_IRQ_IDX 59
-#define HNSV2_SERVICE_RING_IRQ_IDX 25
+#define HNS_DEBUG_RING_IRQ_IDX		0
+#define HNS_SERVICE_RING_IRQ_IDX	59
+#define HNSV2_SERVICE_RING_IRQ_IDX	25
 
-#define DSAF_MAX_PORT_NUM_PER_CHIP 8
-#define DSAF_SERVICE_PORT_NUM_PER_DSAF 6
-#define DSAF_MAX_VM_NUM 128
+#define DSAF_MAX_PORT_NUM	6
+#define DSAF_MAX_VM_NUM		128
 
-#define DSAF_COMM_DEV_NUM 3
-#define DSAF_PPE_INODE_BASE 6
+#define DSAF_COMM_DEV_NUM	1
+#define DSAF_PPE_INODE_BASE	6
 #define DSAF_DEBUG_NW_NUM	2
 #define DSAF_SERVICE_NW_NUM	6
 #define DSAF_COMM_CHN		DSAF_SERVICE_NW_NUM
-- 
1.9.1
