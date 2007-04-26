From: akpm@linux-foundation.org
Subject: [patch 10/11] ehea: fix for dlpar and sysfs entries
Date: Thu, 26 Apr 2007 00:23:24 -0700
Message-ID: <200704260723.l3Q7NOev023847@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	ossthema@de.ibm.com, themann@de.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:43775 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933630AbXDZIAC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 04:00:02 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan-Bernd Themann <ossthema@de.ibm.com>

- dlpar fix:
	certain resources may only be allocated when first
	logical port is available, and must be removed when
	last logical port has been removed

- sysfs entries:
	create symbolic link from each logical port to ehea driver

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/ehea/ehea.h      |    2 
 drivers/net/ehea/ehea_main.c |  144 ++++++++++++++++++++++++---------
 2 files changed, 107 insertions(+), 39 deletions(-)

diff -puN drivers/net/ehea/ehea.h~ehea-fix-for-dlpar-and-sysfs-entries drivers/net/ehea/ehea.h
--- a/drivers/net/ehea/ehea.h~ehea-fix-for-dlpar-and-sysfs-entries
+++ a/drivers/net/ehea/ehea.h
@@ -39,7 +39,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0055"
+#define DRV_VERSION	"EHEA_0056"
 
 #define EHEA_MSG_DEFAULT (NETIF_MSG_LINK | NETIF_MSG_TIMER \
 	| NETIF_MSG_RX_ERR | NETIF_MSG_TX_ERR)
diff -puN drivers/net/ehea/ehea_main.c~ehea-fix-for-dlpar-and-sysfs-entries drivers/net/ehea/ehea_main.c
--- a/drivers/net/ehea/ehea_main.c~ehea-fix-for-dlpar-and-sysfs-entries
+++ a/drivers/net/ehea/ehea_main.c
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
@@ -2108,6 +2130,28 @@ static int ehea_clean_all_portres(struct
 	return ret;
 }
 
+static void ehea_remove_adapter_mr (struct ehea_adapter *adapter)
+{
+	int i;
+
+	for (i=0; i < EHEA_MAX_PORTS; i++)
+		if (adapter->port[i])
+			return;
+
+	ehea_rem_mr(&adapter->mr);
+}
+
+static int ehea_add_adapter_mr (struct ehea_adapter *adapter)
+{
+	int i;
+
+	for (i=0; i < EHEA_MAX_PORTS; i++)
+		if (adapter->port[i])
+			return 0;
+
+	return ehea_reg_kernel_mr(adapter, &adapter->mr);
+}
+
 static int ehea_up(struct net_device *dev)
 {
 	int ret, i;
@@ -2361,6 +2405,34 @@ static void __devinit logical_port_relea
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
@@ -2368,8 +2440,9 @@ static struct device *ehea_register_port
 
 	port->ofdev.node = of_node_get(dn);
 	port->ofdev.dev.parent = &port->adapter->ebus_dev->ofdev.dev;
+	port->ofdev.dev.bus = &ibmebus_bus_type;
 
-	sprintf(port->ofdev.dev.bus_id, "port%d", port->logical_port_id);
+	sprintf(port->ofdev.dev.bus_id, "port%d", port_name_cnt++);
 	port->ofdev.dev.release = logical_port_release;
 
 	ret = of_device_register(&port->ofdev);
@@ -2384,8 +2457,16 @@ static struct device *ehea_register_port
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
@@ -2394,6 +2475,7 @@ out:
 
 static void ehea_unregister_port(struct ehea_port *port)
 {
+	ehea_driver_sysfs_remove(&port->ofdev.dev, &ehea_driver.driver);
 	device_remove_file(&port->ofdev.dev, &dev_attr_log_port_id);
 	of_device_unregister(&port->ofdev);
 }
@@ -2519,7 +2601,6 @@ static int ehea_setup_ports(struct ehea_
 	struct device_node *lhea_dn;
 	struct device_node *eth_dn = NULL;
 	const u32 *dn_log_port_id;
-	int port_setup_ok = 0;
 	int i = 0;
 
 	lhea_dn = adapter->ebus_dev->ofdev.node;
@@ -2533,6 +2614,12 @@ static int ehea_setup_ports(struct ehea_
 			continue;
 		}
 
+		if (ehea_add_adapter_mr(adapter)) {
+			ehea_error("creating MR failed");
+			of_node_put(eth_dn);
+			return -EIO;
+		}
+
 		adapter->port[i] = ehea_setup_single_port(adapter,
 							  *dn_log_port_id,
 							  eth_dn);
@@ -2540,18 +2627,13 @@ static int ehea_setup_ports(struct ehea_
 			ehea_info("%s -> logical port id #%d",
 				  adapter->port[i]->netdev->name,
 				  *dn_log_port_id);
+		else
+			ehea_remove_adapter_mr(adapter);
+
 		i++;
 	};
 
-	/* Check for succesfully set up ports */
-	for (i = 0; i < EHEA_MAX_PORTS; i++)
-		if (adapter->port[i])
-			port_setup_ok++;
-
-	if (port_setup_ok)
-		return 0;	/* At least some ports are setup correctly */
-
-	return -EINVAL;
+	return 0;
 }
 
 static struct device_node *ehea_get_eth_dn(struct ehea_adapter *adapter,
@@ -2603,6 +2685,11 @@ static ssize_t ehea_probe_port(struct de
 		return -EINVAL;
 	}
 
+	if (ehea_add_adapter_mr(adapter)) {
+		ehea_error("creating MR failed");
+		return -EIO;
+	}
+
 	port = ehea_setup_single_port(adapter, logical_port_id, eth_dn);
 
 	of_node_put(eth_dn);
@@ -2616,8 +2703,10 @@ static ssize_t ehea_probe_port(struct de
 
 		ehea_info("added %s (logical port id=%d)", port->netdev->name,
 			  logical_port_id);
-	} else
+	} else {
+		ehea_remove_adapter_mr(adapter);
 		return -EIO;
+	}
 
 	return (ssize_t) count;
 }
@@ -2652,6 +2741,8 @@ static ssize_t ehea_remove_port(struct d
 		return -EINVAL;
 	}
 
+	ehea_remove_adapter_mr(adapter);
+
 	return (ssize_t) count;
 }
 
@@ -2712,18 +2803,13 @@ static int __devinit ehea_probe_adapter(
 
 	dev->ofdev.dev.driver_data = adapter;
 
-	ret = ehea_reg_kernel_mr(adapter, &adapter->mr);
-	if (ret) {
-		dev_err(&dev->ofdev.dev, "reg_mr_adapter failed\n");
-		goto out_free_ad;
-	}
 
 	/* initialize adapter and ports */
 	/* get adapter properties */
 	ret = ehea_sense_adapter_attr(adapter);
 	if (ret) {
 		dev_err(&dev->ofdev.dev, "sense_adapter_attr failed: %d", ret);
-		goto out_free_res;
+		goto out_free_ad;
 	}
 
 	adapter->neq = ehea_create_eq(adapter,
@@ -2731,7 +2817,7 @@ static int __devinit ehea_probe_adapter(
 	if (!adapter->neq) {
 		ret = -EIO;
 		dev_err(&dev->ofdev.dev, "NEQ creation failed");
-		goto out_free_res;
+		goto out_free_ad;
 	}
 
 	tasklet_init(&adapter->neq_tasklet, ehea_neq_tasklet,
@@ -2776,9 +2862,6 @@ out_free_irq:
 out_kill_eq:
 	ehea_destroy_eq(adapter->neq);
 
-out_free_res:
-	ehea_rem_mr(&adapter->mr);
-
 out_free_ad:
 	kfree(adapter);
 out:
@@ -2804,7 +2887,7 @@ static int __devexit ehea_remove(struct 
 	tasklet_kill(&adapter->neq_tasklet);
 
 	ehea_destroy_eq(adapter->neq);
-	ehea_rem_mr(&adapter->mr);
+	ehea_remove_adapter_mr(adapter);
 	kfree(adapter);
 	return 0;
 }
@@ -2837,21 +2920,6 @@ static int check_module_parm(void)
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
_
