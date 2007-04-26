From: Thomas Klein <osstklei@de.ibm.com>
Subject: [PATCH 1/2] ehea: fix for sysfs entries
Date: Thu, 26 Apr 2007 11:56:13 +0200
Message-ID: <200704261156.13487.osstklei@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <ossthema@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <ossrosch@linux.vnet.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:19494 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423085AbXDZJ4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 05:56:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Create symbolic link from each logical port to ehea driver

Signed-off-by: Thomas Klein <tklein@de.ibm.com>
---


This patch applies on top of the netdev upstream branch for 2.6.22



diff -Nurp -X dontdiff linux-2.6.21/drivers/net/ehea/ehea.h patched_kernel/drivers/net/ehea/ehea.h
--- linux-2.6.21/drivers/net/ehea/ehea.h	2007-04-26 10:07:59.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea.h	2007-04-26 11:15:25.000000000 +0200
@@ -39,7 +39,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0055"
+#define DRV_VERSION	"EHEA_0057"
 
 #define EHEA_MSG_DEFAULT (NETIF_MSG_LINK | NETIF_MSG_TIMER \
 	| NETIF_MSG_RX_ERR | NETIF_MSG_TX_ERR)
diff -Nurp -X dontdiff linux-2.6.21/drivers/net/ehea/ehea_main.c patched_kernel/drivers/net/ehea/ehea_main.c
--- linux-2.6.21/drivers/net/ehea/ehea_main.c	2007-04-26 10:07:59.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea_main.c	2007-04-26 11:15:25.000000000 +0200
@@ -78,6 +78,28 @@ MODULE_PARM_DESC(sq_entries, " Number of
 		 __MODULE_STRING(EHEA_DEF_ENTRIES_SQ) ")");
 MODULE_PARM_DESC(use_mcs, " 0:NAPI, 1:Multiple receive queues, Default = 1 ");
 
+static int port_name_cnt = 0;
+
+static int __devinit ehea_probe_adapter(struct ibmebus_dev *dev,
+                                        const struct of_device_id *id);
+
+static int __devexit ehea_remove(struct ibmebus_dev *dev);
+
+static struct of_device_id ehea_device_table[] = {
+	{
+		.name = "lhea",
+		.compatible = "IBM,lhea",
+	},
+	{},
+};
+
+static struct ibmebus_driver ehea_driver = {
+	.name = "ehea",
+	.id_table = ehea_device_table,
+	.probe = ehea_probe_adapter,
+	.remove = ehea_remove,
+};
+
 void ehea_dump(void *adr, int len, char *msg) {
 	int x;
 	unsigned char *deb = adr;
@@ -2361,6 +2383,34 @@ static void __devinit logical_port_relea
 	of_node_put(port->ofdev.node);
 }
 
+static int ehea_driver_sysfs_add(struct device *dev,
+                                 struct device_driver *driver)
+{
+	int ret;
+
+	ret = sysfs_create_link(&driver->kobj, &dev->kobj,
+				kobject_name(&dev->kobj));
+	if (ret == 0) {
+		ret = sysfs_create_link(&dev->kobj, &driver->kobj,
+					"driver");
+		if (ret)
+			sysfs_remove_link(&driver->kobj,
+					  kobject_name(&dev->kobj));
+	}
+	return ret;
+}
+
+static void ehea_driver_sysfs_remove(struct device *dev,
+                                     struct device_driver *driver)
+{
+	struct device_driver *drv = driver;
+
+	if (drv) {
+		sysfs_remove_link(&drv->kobj, kobject_name(&dev->kobj));
+		sysfs_remove_link(&dev->kobj, "driver");
+	}
+}
+
 static struct device *ehea_register_port(struct ehea_port *port,
 					 struct device_node *dn)
 {
@@ -2368,8 +2418,9 @@ static struct device *ehea_register_port
 
 	port->ofdev.node = of_node_get(dn);
 	port->ofdev.dev.parent = &port->adapter->ebus_dev->ofdev.dev;
+	port->ofdev.dev.bus = &ibmebus_bus_type;
 
-	sprintf(port->ofdev.dev.bus_id, "port%d", port->logical_port_id);
+	sprintf(port->ofdev.dev.bus_id, "port%d", port_name_cnt++);
 	port->ofdev.dev.release = logical_port_release;
 
 	ret = of_device_register(&port->ofdev);
@@ -2384,8 +2435,16 @@ static struct device *ehea_register_port
 		goto out_unreg_of_dev;
 	}
 
+	ret = ehea_driver_sysfs_add(&port->ofdev.dev, &ehea_driver.driver);
+	if (ret) {
+		ehea_error("failed to register sysfs driver link");
+		goto out_rem_dev_file;
+	}
+
 	return &port->ofdev.dev;
 
+out_rem_dev_file:
+	device_remove_file(&port->ofdev.dev, &dev_attr_log_port_id);
 out_unreg_of_dev:
 	of_device_unregister(&port->ofdev);
 out:
@@ -2394,6 +2453,7 @@ out:
 
 static void ehea_unregister_port(struct ehea_port *port)
 {
+	ehea_driver_sysfs_remove(&port->ofdev.dev, &ehea_driver.driver);
 	device_remove_file(&port->ofdev.dev, &dev_attr_log_port_id);
 	of_device_unregister(&port->ofdev);
 }
@@ -2838,21 +2898,6 @@ static int check_module_parm(void)
 	return ret;
 }
 
-static struct of_device_id ehea_device_table[] = {
-	{
-		.name = "lhea",
-		.compatible = "IBM,lhea",
-	},
-	{},
-};
-
-static struct ibmebus_driver ehea_driver = {
-	.name = "ehea",
-	.id_table = ehea_device_table,
-	.probe = ehea_probe_adapter,
-	.remove = ehea_remove,
-};
-
 int __init ehea_module_init(void)
 {
 	int ret;

