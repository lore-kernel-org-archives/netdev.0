From: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH for-next 2/2] IB/hns: Add support of ACPI to the Hisilicon RoCE driver
Date: Wed, 24 Aug 2016 04:44:50 +0800
Message-ID: <1471985090-202472-3-git-send-email-salil.mehta@huawei.com>
References: <1471985090-202472-1-git-send-email-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        <mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1471985090-202472-1-git-send-email-salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch is meant to add support of ACPI to the Hisilicon RoCE
driver.

Changes done are primarily meant to detect the type and then either
use DT specific or ACPI spcific functions. Where ever possible,
this patch tries to make use of Unified Device Property Interface
APIs to support both DT and ACPI through single interface.

This patch depends upon HNS ethernet driver to Reset RoCE. This
function within HNS ethernet driver has also been enhanced to
support ACPI and is part of other accompanying patch with this
patch-set.

NOTE: The changes in this patch are done over below branch,
https://github.com/dledford/linux/tree/hns-roce

Signed-off-by: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
Change Log

PATCH V1: Initial version to support ACPI in HNS RoCE driver.
---
 drivers/infiniband/hw/hns/hns_roce_device.h |    2 +-
 drivers/infiniband/hw/hns/hns_roce_eq.c     |    2 +-
 drivers/infiniband/hw/hns/hns_roce_hw_v1.c  |   37 ++++++--
 drivers/infiniband/hw/hns/hns_roce_hw_v1.h  |    2 +-
 drivers/infiniband/hw/hns/hns_roce_main.c   |  127 ++++++++++++++++++++++-----
 5 files changed, 136 insertions(+), 34 deletions(-)

diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infiniband/hw/hns/hns_roce_device.h
index 00f01be..ea73580 100644
--- a/drivers/infiniband/hw/hns/hns_roce_device.h
+++ b/drivers/infiniband/hw/hns/hns_roce_device.h
@@ -531,7 +531,7 @@ struct hns_roce_dev {
 	struct ib_device	ib_dev;
 	struct platform_device  *pdev;
 	struct hns_roce_uar     priv_uar;
-	const char		*irq_names;
+	const char		*irq_names[HNS_ROCE_MAX_IRQ_NUM];
 	spinlock_t		sm_lock;
 	spinlock_t		cq_db_lock;
 	spinlock_t		bt_cmd_lock;
diff --git a/drivers/infiniband/hw/hns/hns_roce_eq.c b/drivers/infiniband/hw/hns/hns_roce_eq.c
index 5febbb4..98af7fe 100644
--- a/drivers/infiniband/hw/hns/hns_roce_eq.c
+++ b/drivers/infiniband/hw/hns/hns_roce_eq.c
@@ -713,7 +713,7 @@ int hns_roce_init_eq_table(struct hns_roce_dev *hr_dev)
 
 	for (j = 0; j < eq_num; j++) {
 		ret = request_irq(eq_table->eq[j].irq, hns_roce_msi_x_interrupt,
-				  0, hr_dev->irq_names, eq_table->eq + j);
+				  0, hr_dev->irq_names[j], eq_table->eq + j);
 		if (ret) {
 			dev_err(dev, "request irq error!\n");
 			goto err_request_irq_fail;
diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
index b52f3ba..399f5de 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
@@ -31,6 +31,7 @@
  */
 
 #include <linux/platform_device.h>
+#include <linux/acpi.h>
 #include <rdma/ib_umem.h>
 #include "hns_roce_common.h"
 #include "hns_roce_device.h"
@@ -794,29 +795,47 @@ static void hns_roce_port_enable(struct hns_roce_dev *hr_dev, int enable_flag)
  * @enable: true -- drop reset, false -- reset
  * return 0 - success , negative --fail
  */
-int hns_roce_v1_reset(struct hns_roce_dev *hr_dev, bool enable)
+int hns_roce_v1_reset(struct hns_roce_dev *hr_dev, bool dereset)
 {
 	struct device_node *dsaf_node;
 	struct device *dev = &hr_dev->pdev->dev;
 	struct device_node *np = dev->of_node;
+	struct fwnode_handle *fwnode;
 	int ret;
 
-	dsaf_node = of_parse_phandle(np, "dsaf-handle", 0);
-	if (!dsaf_node) {
-		dev_err(dev, "Unable to get dsaf node by dsaf-handle!\n");
-		return -EINVAL;
+	/* check if this is DT/ACPI case */
+	if (dev_of_node(dev)) {
+		dsaf_node = of_parse_phandle(np, "dsaf-handle", 0);
+		if (!dsaf_node) {
+			dev_err(dev, "could not find dsaf-handle\n");
+			return -EINVAL;
+		}
+		fwnode = &dsaf_node->fwnode;
+	} else if (is_acpi_device_node(dev->fwnode)) {
+		struct acpi_reference_args args;
+
+		ret = acpi_node_get_property_reference(dev->fwnode,
+						       "dsaf-handle", 0, &args);
+		if (ret) {
+			dev_err(dev, "could not find dsaf-handle\n");
+			return ret;
+		}
+		fwnode = acpi_fwnode_handle(args.adev);
+	} else {
+		dev_err(dev, "cannot read data from DT or ACPI\n");
+		return -ENXIO;
 	}
 
-	ret = hns_dsaf_roce_reset(&dsaf_node->fwnode, false);
+	ret = hns_dsaf_roce_reset(fwnode, false);
 	if (ret)
 		return ret;
 
-	if (enable) {
+	if (dereset) {
 		msleep(SLEEP_TIME_INTERVAL);
-		return hns_dsaf_roce_reset(&dsaf_node->fwnode, true);
+		ret = hns_dsaf_roce_reset(fwnode, true);
 	}
 
-	return 0;
+	return ret;
 }
 
 void hns_roce_v1_profile(struct hns_roce_dev *hr_dev)
diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
index 2b3bf21..316b592 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
@@ -976,6 +976,6 @@ struct hns_roce_v1_priv {
 	struct hns_roce_raq_table raq_table;
 };
 
-int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, bool enable);
+int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, bool dereset);
 
 #endif
diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
index 6ead671..f64f0dd 100644
--- a/drivers/infiniband/hw/hns/hns_roce_main.c
+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
@@ -30,7 +30,7 @@
  * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  * SOFTWARE.
  */
-
+#include <linux/acpi.h>
 #include <linux/of_platform.h>
 #include <rdma/ib_addr.h>
 #include <rdma/ib_smi.h>
@@ -694,40 +694,122 @@ error_failed_setup_mtu_gids:
 	return ret;
 }
 
+static const struct of_device_id hns_roce_of_match[] = {
+	{ .compatible = "hisilicon,hns-roce-v1", .data = &hns_roce_hw_v1, },
+	{},
+};
+MODULE_DEVICE_TABLE(of, hns_roce_of_match);
+
+static const struct acpi_device_id hns_roce_acpi_match[] = {
+	{ "HISI00D1", (kernel_ulong_t)&hns_roce_hw_v1 },
+	{},
+};
+MODULE_DEVICE_TABLE(acpi, hns_roce_acpi_match);
+
+static int hns_roce_node_match(struct device *dev, void *fwnode)
+{
+	return dev->fwnode == fwnode;
+}
+
+static struct
+platform_device *hns_roce_find_pdev(struct fwnode_handle *fwnode)
+{
+	struct device *dev;
+
+	/* get the 'device'corresponding to matching 'fwnode' */
+	dev = bus_find_device(&platform_bus_type, NULL,
+			      fwnode, hns_roce_node_match);
+	/* get the platform device */
+	return dev ? to_platform_device(dev) : NULL;
+}
+
 static int hns_roce_get_cfg(struct hns_roce_dev *hr_dev)
 {
 	int i;
+	int ret;
 	u8 phy_port;
 	int port_cnt = 0;
 	struct device *dev = &hr_dev->pdev->dev;
-	struct device_node *np = dev->of_node;
 	struct device_node *net_node;
 	struct net_device *netdev = NULL;
 	struct platform_device *pdev = NULL;
 	struct resource *res;
 
-	if (of_device_is_compatible(np, "hisilicon,hns-roce-v1")) {
-		hr_dev->hw = &hns_roce_hw_v1;
+	/* check if we are compatible with the underlying SoC */
+	if (dev_of_node(dev)) {
+		const struct of_device_id *of_id;
+
+		of_id = of_match_node(hns_roce_of_match, dev->of_node);
+		if (!of_id) {
+			dev_err(dev, "device is not compatible!\n");
+			return -ENXIO;
+		}
+		hr_dev->hw = (struct hns_roce_hw *)of_id->data;
+		if (!hr_dev->hw) {
+			dev_err(dev, "couldn't get H/W specific DT data!\n");
+			return -ENXIO;
+		}
+	} else if (is_acpi_device_node(dev->fwnode)) {
+		const struct acpi_device_id *acpi_id;
+
+		acpi_id = acpi_match_device(hns_roce_acpi_match, dev);
+		if (!acpi_id) {
+			dev_err(dev, "device is not compatible!\n");
+			return -ENXIO;
+		}
+		hr_dev->hw = (struct hns_roce_hw *) acpi_id->driver_data;
+		if (!hr_dev->hw) {
+			dev_err(dev, "couldn't get H/W specific ACPI data!\n");
+			return -ENXIO;
+		}
 	} else {
-		dev_err(dev, "device no compatible!\n");
-		return -EINVAL;
+		dev_err(dev, "can't read compatibility data from DT or ACPI\n");
+		return -ENXIO;
 	}
 
+	/* get the mapped register base address */
 	res = platform_get_resource(hr_dev->pdev, IORESOURCE_MEM, 0);
+	if (!res) {
+		dev_err(dev, "memory resource not found!\n");
+		return -EINVAL;
+	}
 	hr_dev->reg_base = devm_ioremap_resource(dev, res);
 	if (IS_ERR(hr_dev->reg_base))
 		return PTR_ERR(hr_dev->reg_base);
 
+	/* get the RoCE associated ethernet ports or netdevices */
 	for (i = 0; i < HNS_ROCE_MAX_PORTS; i++) {
-		net_node = of_parse_phandle(np, "eth-handle", i);
-		if (net_node) {
+		if (dev_of_node(dev)) {
+			net_node = of_parse_phandle(dev->of_node, "eth-handle",
+						    i);
+			if (!net_node)
+				continue;
 			pdev = of_find_device_by_node(net_node);
+		} else if (is_acpi_device_node(dev->fwnode)) {
+			struct acpi_reference_args args;
+			struct fwnode_handle *fwnode;
+
+			ret = acpi_node_get_property_reference(dev->fwnode,
+							       "eth-handle",
+							       i, &args);
+			if (ret)
+				continue;
+			fwnode = acpi_fwnode_handle(args.adev);
+			pdev = hns_roce_find_pdev(fwnode);
+		} else {
+			dev_err(dev, "cannot read data from DT or ACPI\n");
+			return -ENXIO;
+		}
+
+		if (pdev) {
 			netdev = platform_get_drvdata(pdev);
 			phy_port = (u8)i;
 			if (netdev) {
 				hr_dev->iboe.netdevs[port_cnt] = netdev;
 				hr_dev->iboe.phy_port[port_cnt] = phy_port;
 			} else {
+				dev_err(dev, "no netdev found with pdev %s\n",
+					pdev->name);
 				return -ENODEV;
 			}
 			port_cnt++;
@@ -735,26 +817,32 @@ static int hns_roce_get_cfg(struct hns_roce_dev *hr_dev)
 	}
 
 	if (port_cnt == 0) {
-		dev_err(dev, "Unable to get available port by eth-handle!\n");
+		dev_err(dev, "unable to get eth-handle for available ports!\n");
 		return -EINVAL;
 	}
 
 	hr_dev->caps.num_ports = port_cnt;
 
-	/* Cmd issue mode: 0 is poll, 1 is event */
+	/* cmd issue mode: 0 is poll, 1 is event */
 	hr_dev->cmd_mod = 1;
 	hr_dev->loop_idc = 0;
 
+	/* read the interrupt names from the DT or ACPI */
+	ret = device_property_read_string_array(dev, "interrupt-names",
+						hr_dev->irq_names,
+						HNS_ROCE_MAX_IRQ_NUM);
+	if (ret < 0) {
+		dev_err(dev, "couldn't get interrupt names from DT or ACPI!\n");
+		return ret;
+	}
+
+	/* fetch the interrupt numbers */
 	for (i = 0; i < HNS_ROCE_MAX_IRQ_NUM; i++) {
 		hr_dev->irq[i] = platform_get_irq(hr_dev->pdev, i);
 		if (hr_dev->irq[i] <= 0) {
-			dev_err(dev, "Get No.%d irq resource failed!\n", i);
+			dev_err(dev, "platform get of irq[=%d] failed!\n", i);
 			return -EINVAL;
 		}
-
-		if (of_property_read_string_index(np, "interrupt-names", i,
-						  &hr_dev->irq_names))
-			return -EINVAL;
 	}
 
 	return 0;
@@ -917,7 +1005,7 @@ static int hns_roce_probe(struct platform_device *pdev)
 
 	if (dma_set_mask_and_coherent(dev, DMA_BIT_MASK(64ULL)) &&
 	    dma_set_mask_and_coherent(dev, DMA_BIT_MASK(32ULL))) {
-		dev_err(dev, "No usable DMA addressing mode\n");
+		dev_err(dev, "Not usable DMA addressing mode\n");
 		ret = -EIO;
 		goto error_failed_get_cfg;
 	}
@@ -1035,18 +1123,13 @@ static int hns_roce_remove(struct platform_device *pdev)
 	return 0;
 }
 
-static const struct of_device_id hns_roce_of_match[] = {
-	{ .compatible = "hisilicon,hns-roce-v1",},
-	{},
-};
-MODULE_DEVICE_TABLE(of, hns_roce_of_match);
-
 static struct platform_driver hns_roce_driver = {
 	.probe = hns_roce_probe,
 	.remove = hns_roce_remove,
 	.driver = {
 		.name = DRV_NAME,
 		.of_match_table = hns_roce_of_match,
+		.acpi_match_table = ACPI_PTR(hns_roce_acpi_match),
 	},
 };
 
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
