From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH 1/5] ibmebus: convert of_platform_driver to platform_driver
Date: Sun, 21 Apr 2013 21:13:14 -0500
Message-ID: <1366596798-9457-2-git-send-email-robherring2@gmail.com>
References: <1366596798-9457-1-git-send-email-robherring2@gmail.com>
Cc: Grant Likely <grant.likely@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Rob Herring <rob.herring@calxeda.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Hoang-Nam Nguyen <hnguyen@de.ibm.com>,
	Christoph Raisch <raisch@de.ibm.com>,
	Roland Dreier <roland@kernel.org>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	linuxppc-dev@lists.ozlabs.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, devicetree-discuss@lists.ozlabs.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1366596798-9457-1-git-send-email-robherring2@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rob Herring <rob.herring@calxeda.com>

ibmebus is the last remaining user of of_platform_driver and the
conversion to a regular platform driver is trivial.

Signed-off-by: Rob Herring <rob.herring@calxeda.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Hoang-Nam Nguyen <hnguyen@de.ibm.com>
Cc: Christoph Raisch <raisch@de.ibm.com>
Cc: Roland Dreier <roland@kernel.org>
Cc: Sean Hefty <sean.hefty@intel.com>
Cc: Hal Rosenstock <hal.rosenstock@gmail.com>
Cc: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Cc: Grant Likely <grant.likely@linaro.org>
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-rdma@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 arch/powerpc/include/asm/ibmebus.h        |    4 ++--
 arch/powerpc/kernel/ibmebus.c             |   22 ++++++++++------------
 drivers/infiniband/hw/ehca/ehca_main.c    |    5 ++---
 drivers/net/ethernet/ibm/ehea/ehea_main.c |    8 +++-----
 4 files changed, 17 insertions(+), 22 deletions(-)

diff --git a/arch/powerpc/include/asm/ibmebus.h b/arch/powerpc/include/asm/ibmebus.h
index 1a9d9ae..088f95b 100644
--- a/arch/powerpc/include/asm/ibmebus.h
+++ b/arch/powerpc/include/asm/ibmebus.h
@@ -48,8 +48,8 @@
 
 extern struct bus_type ibmebus_bus_type;
 
-int ibmebus_register_driver(struct of_platform_driver *drv);
-void ibmebus_unregister_driver(struct of_platform_driver *drv);
+int ibmebus_register_driver(struct platform_driver *drv);
+void ibmebus_unregister_driver(struct platform_driver *drv);
 
 int ibmebus_request_irq(u32 ist, irq_handler_t handler,
 			unsigned long irq_flags, const char *devname,
diff --git a/arch/powerpc/kernel/ibmebus.c b/arch/powerpc/kernel/ibmebus.c
index 8220baa..16a7c23 100644
--- a/arch/powerpc/kernel/ibmebus.c
+++ b/arch/powerpc/kernel/ibmebus.c
@@ -205,7 +205,7 @@ static int ibmebus_create_devices(const struct of_device_id *matches)
 	return ret;
 }
 
-int ibmebus_register_driver(struct of_platform_driver *drv)
+int ibmebus_register_driver(struct platform_driver *drv)
 {
 	/* If the driver uses devices that ibmebus doesn't know, add them */
 	ibmebus_create_devices(drv->driver.of_match_table);
@@ -215,7 +215,7 @@ int ibmebus_register_driver(struct of_platform_driver *drv)
 }
 EXPORT_SYMBOL(ibmebus_register_driver);
 
-void ibmebus_unregister_driver(struct of_platform_driver *drv)
+void ibmebus_unregister_driver(struct platform_driver *drv)
 {
 	driver_unregister(&drv->driver);
 }
@@ -338,11 +338,10 @@ static int ibmebus_bus_bus_match(struct device *dev, struct device_driver *drv)
 static int ibmebus_bus_device_probe(struct device *dev)
 {
 	int error = -ENODEV;
-	struct of_platform_driver *drv;
+	struct platform_driver *drv;
 	struct platform_device *of_dev;
-	const struct of_device_id *match;
 
-	drv = to_of_platform_driver(dev->driver);
+	drv = to_platform_driver(dev->driver);
 	of_dev = to_platform_device(dev);
 
 	if (!drv->probe)
@@ -350,9 +349,8 @@ static int ibmebus_bus_device_probe(struct device *dev)
 
 	of_dev_get(of_dev);
 
-	match = of_match_device(drv->driver.of_match_table, dev);
-	if (match)
-		error = drv->probe(of_dev, match);
+	if (of_driver_match_device(dev, dev->driver))
+		error = drv->probe(of_dev);
 	if (error)
 		of_dev_put(of_dev);
 
@@ -362,7 +360,7 @@ static int ibmebus_bus_device_probe(struct device *dev)
 static int ibmebus_bus_device_remove(struct device *dev)
 {
 	struct platform_device *of_dev = to_platform_device(dev);
-	struct of_platform_driver *drv = to_of_platform_driver(dev->driver);
+	struct platform_driver *drv = to_platform_driver(dev->driver);
 
 	if (dev->driver && drv->remove)
 		drv->remove(of_dev);
@@ -372,7 +370,7 @@ static int ibmebus_bus_device_remove(struct device *dev)
 static void ibmebus_bus_device_shutdown(struct device *dev)
 {
 	struct platform_device *of_dev = to_platform_device(dev);
-	struct of_platform_driver *drv = to_of_platform_driver(dev->driver);
+	struct platform_driver *drv = to_platform_driver(dev->driver);
 
 	if (dev->driver && drv->shutdown)
 		drv->shutdown(of_dev);
@@ -419,7 +417,7 @@ struct device_attribute ibmebus_bus_device_attrs[] = {
 static int ibmebus_bus_legacy_suspend(struct device *dev, pm_message_t mesg)
 {
 	struct platform_device *of_dev = to_platform_device(dev);
-	struct of_platform_driver *drv = to_of_platform_driver(dev->driver);
+	struct platform_driver *drv = to_platform_driver(dev->driver);
 	int ret = 0;
 
 	if (dev->driver && drv->suspend)
@@ -430,7 +428,7 @@ static int ibmebus_bus_legacy_suspend(struct device *dev, pm_message_t mesg)
 static int ibmebus_bus_legacy_resume(struct device *dev)
 {
 	struct platform_device *of_dev = to_platform_device(dev);
-	struct of_platform_driver *drv = to_of_platform_driver(dev->driver);
+	struct platform_driver *drv = to_platform_driver(dev->driver);
 	int ret = 0;
 
 	if (dev->driver && drv->resume)
diff --git a/drivers/infiniband/hw/ehca/ehca_main.c b/drivers/infiniband/hw/ehca/ehca_main.c
index f8a6291..982e3ef 100644
--- a/drivers/infiniband/hw/ehca/ehca_main.c
+++ b/drivers/infiniband/hw/ehca/ehca_main.c
@@ -713,8 +713,7 @@ static struct attribute_group ehca_dev_attr_grp = {
 	.attrs = ehca_dev_attrs
 };
 
-static int ehca_probe(struct platform_device *dev,
-		      const struct of_device_id *id)
+static int ehca_probe(struct platform_device *dev)
 {
 	struct ehca_shca *shca;
 	const u64 *handle;
@@ -937,7 +936,7 @@ static struct of_device_id ehca_device_table[] =
 };
 MODULE_DEVICE_TABLE(of, ehca_device_table);
 
-static struct of_platform_driver ehca_driver = {
+static struct platform_driver ehca_driver = {
 	.probe       = ehca_probe,
 	.remove      = ehca_remove,
 	.driver = {
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 328f47c..c6ecf70 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -98,8 +98,7 @@ static struct ehea_fw_handle_array ehea_fw_handles;
 static struct ehea_bcmc_reg_array ehea_bcmc_regs;
 
 
-static int ehea_probe_adapter(struct platform_device *dev,
-			      const struct of_device_id *id);
+static int ehea_probe_adapter(struct platform_device *dev);
 
 static int ehea_remove(struct platform_device *dev);
 
@@ -112,7 +111,7 @@ static struct of_device_id ehea_device_table[] = {
 };
 MODULE_DEVICE_TABLE(of, ehea_device_table);
 
-static struct of_platform_driver ehea_driver = {
+static struct platform_driver ehea_driver = {
 	.driver = {
 		.name = "ehea",
 		.owner = THIS_MODULE,
@@ -3255,8 +3254,7 @@ static void ehea_remove_device_sysfs(struct platform_device *dev)
 	device_remove_file(&dev->dev, &dev_attr_remove_port);
 }
 
-static int ehea_probe_adapter(struct platform_device *dev,
-			      const struct of_device_id *id)
+static int ehea_probe_adapter(struct platform_device *dev)
 {
 	struct ehea_adapter *adapter;
 	const u64 *adapter_handle;
-- 
1.7.10.4
