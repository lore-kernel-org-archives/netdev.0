From: Thomas Klein <osstklei@de.ibm.com>
Subject: [PATCH] ehea: add kdump support
Date: Wed, 13 Feb 2008 16:18:33 +0100
Message-ID: <47B30A49.8080404@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([195.212.29.135]:30050 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755194AbYBMPSp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 10:18:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds kdump support to the ehea driver. As the firmware doesn't free
resource handles automatically, the driver has to run an as simple as possible
free resource function in case of a crash shutdown. The function iterates over
two arrays freeing all resource handles which are stored there. The arrays are
kept up-to-date during normal runtime. The crash handler fn is triggered by the
recently introduced PPC crash shutdown reg/unreg functions.


Signed-off-by: Thomas Klein <tklein@de.ibm.com>

---
 drivers/net/ehea/ehea.h      |   34 +++++-
 drivers/net/ehea/ehea_main.c |  281 ++++++++++++++++++++++++++++++++++++++----
 2 files changed, 290 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 88fb53e..7c4ead3 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -40,7 +40,7 @@
 #include <asm/io.h>

 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0083"
+#define DRV_VERSION	"EHEA_0087"

 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
@@ -386,6 +386,13 @@ struct ehea_port_res {


 #define EHEA_MAX_PORTS 16
+
+#define EHEA_NUM_PORTRES_FW_HANDLES    6  /* QP handle, SendCQ handle,
+					     RecvCQ handle, EQ handle,
+					     SendMR handle, RecvMR handle */
+#define EHEA_NUM_PORT_FW_HANDLES       1  /* EQ handle */
+#define EHEA_NUM_ADAPTER_FW_HANDLES    2  /* MR handle, NEQ handle */
+
 struct ehea_adapter {
 	u64 handle;
 	struct of_device *ofdev;
@@ -405,6 +412,31 @@ struct ehea_mc_list {
 	u64 macaddr;
 };

+/* kdump support */
+struct ehea_fw_handle_entry {
+	u64 adh;               /* Adapter Handle */
+	u64 fwh;               /* Firmware Handle */
+};
+
+struct ehea_fw_handle_array {
+	struct ehea_fw_handle_entry *arr;
+	int num_entries;
+	struct semaphore lock;
+};
+
+struct ehea_bcmc_reg_entry {
+	u64 adh;               /* Adapter Handle */
+	u32 port_id;           /* Logical Port Id */
+	u8 reg_type;           /* Registration Type */
+	u64 macaddr;
+};
+
+struct ehea_bcmc_reg_array {
+	struct ehea_bcmc_reg_entry *arr;
+	int num_entries;
+	struct semaphore lock;
+};
+
 #define EHEA_PORT_UP 1
 #define EHEA_PORT_DOWN 0
 #define EHEA_PHY_LINK_UP 1
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index c051c7e..21af674 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -35,6 +35,7 @@
 #include <linux/if_ether.h>
 #include <linux/notifier.h>
 #include <linux/reboot.h>
+#include <asm/kexec.h>

 #include <net/ip.h>

@@ -98,8 +99,10 @@ static int port_name_cnt;
 static LIST_HEAD(adapter_list);
 u64 ehea_driver_flags;
 struct work_struct ehea_rereg_mr_task;
-
 struct semaphore dlpar_mem_lock;
+struct ehea_fw_handle_array ehea_fw_handles;
+struct ehea_bcmc_reg_array ehea_bcmc_regs;
+

 static int __devinit ehea_probe_adapter(struct of_device *dev,
 					const struct of_device_id *id);
@@ -132,6 +135,160 @@ void ehea_dump(void *adr, int len, char *msg)
 	}
 }

+static void ehea_update_firmware_handles(void)
+{
+	struct ehea_fw_handle_entry *arr = NULL;
+	struct ehea_adapter *adapter;
+	int num_adapters = 0;
+	int num_ports = 0;
+	int num_portres = 0;
+	int i = 0;
+	int num_fw_handles, k, l;
+
+	/* Determine number of handles */
+	list_for_each_entry(adapter, &adapter_list, list) {
+		num_adapters++;
+
+		for (k = 0; k < EHEA_MAX_PORTS; k++) {
+			struct ehea_port *port = adapter->port[k];
+
+			if (!port || (port->state != EHEA_PORT_UP))
+				continue;
+
+			num_ports++;
+			num_portres += port->num_def_qps + port->num_add_tx_qps;
+		}
+	}
+
+	num_fw_handles = num_adapters * EHEA_NUM_ADAPTER_FW_HANDLES +
+			 num_ports * EHEA_NUM_PORT_FW_HANDLES +
+			 num_portres * EHEA_NUM_PORTRES_FW_HANDLES;
+
+	if (num_fw_handles) {
+		arr = kzalloc(num_fw_handles * sizeof(*arr), GFP_KERNEL);
+		if (!arr)
+			return;  /* Keep the existing array */
+	} else
+		goto out_update;
+
+	list_for_each_entry(adapter, &adapter_list, list) {
+		for (k = 0; k < EHEA_MAX_PORTS; k++) {
+			struct ehea_port *port = adapter->port[k];
+
+			if (!port || (port->state != EHEA_PORT_UP))
+				continue;
+
+			for (l = 0;
+			     l < port->num_def_qps + port->num_add_tx_qps;
+			     l++) {
+				struct ehea_port_res *pr = &port->port_res[l];
+
+				arr[i].adh = adapter->handle;
+				arr[i++].fwh = pr->qp->fw_handle;
+				arr[i].adh = adapter->handle;
+				arr[i++].fwh = pr->send_cq->fw_handle;
+				arr[i].adh = adapter->handle;
+				arr[i++].fwh = pr->recv_cq->fw_handle;
+				arr[i].adh = adapter->handle;
+				arr[i++].fwh = pr->eq->fw_handle;
+				arr[i].adh = adapter->handle;
+				arr[i++].fwh = pr->send_mr.handle;
+				arr[i].adh = adapter->handle;
+				arr[i++].fwh = pr->recv_mr.handle;
+			}
+			arr[i].adh = adapter->handle;
+			arr[i++].fwh = port->qp_eq->fw_handle;
+		}
+
+		arr[i].adh = adapter->handle;
+		arr[i++].fwh = adapter->neq->fw_handle;
+
+		if (adapter->mr.handle) {
+			arr[i].adh = adapter->handle;
+			arr[i++].fwh = adapter->mr.handle;
+		}
+	}
+
+out_update:
+	kfree(ehea_fw_handles.arr);
+	ehea_fw_handles.arr = arr;
+	ehea_fw_handles.num_entries = i;
+}
+
+static void ehea_update_bcmc_registrations(void)
+{
+	struct ehea_bcmc_reg_entry *arr = NULL;
+	struct ehea_adapter *adapter;
+	struct ehea_mc_list *mc_entry;
+	int num_registrations = 0;
+	int i = 0;
+	int k;
+
+	/* Determine number of registrations */
+	list_for_each_entry(adapter, &adapter_list, list)
+		for (k = 0; k < EHEA_MAX_PORTS; k++) {
+			struct ehea_port *port = adapter->port[k];
+
+			if (!port || (port->state != EHEA_PORT_UP))
+				continue;
+
+			num_registrations += 2;	/* Broadcast registrations */
+
+			list_for_each_entry(mc_entry, &port->mc_list->list,list)
+				num_registrations += 2;
+		}
+
+	if (num_registrations) {
+		arr = kzalloc(num_registrations * sizeof(*arr), GFP_KERNEL);
+		if (!arr)
+			return;  /* Keep the existing array */
+	} else
+		goto out_update;
+
+	list_for_each_entry(adapter, &adapter_list, list) {
+		for (k = 0; k < EHEA_MAX_PORTS; k++) {
+			struct ehea_port *port = adapter->port[k];
+
+			if (!port || (port->state != EHEA_PORT_UP))
+				continue;
+
+			arr[i].adh = adapter->handle;
+			arr[i].port_id = port->logical_port_id;
+			arr[i].reg_type = EHEA_BCMC_BROADCAST |
+					  EHEA_BCMC_UNTAGGED;
+			arr[i++].macaddr = port->mac_addr;
+
+			arr[i].adh = adapter->handle;
+			arr[i].port_id = port->logical_port_id;
+			arr[i].reg_type = EHEA_BCMC_BROADCAST |
+					  EHEA_BCMC_VLANID_ALL;
+			arr[i++].macaddr = port->mac_addr;
+
+			list_for_each_entry(mc_entry,
+					    &port->mc_list->list, list) {
+				arr[i].adh = adapter->handle;
+				arr[i].port_id = port->logical_port_id;
+				arr[i].reg_type = EHEA_BCMC_SCOPE_ALL |
+						  EHEA_BCMC_MULTICAST |
+						  EHEA_BCMC_UNTAGGED;
+				arr[i++].macaddr = mc_entry->macaddr;
+
+				arr[i].adh = adapter->handle;
+				arr[i].port_id = port->logical_port_id;
+				arr[i].reg_type = EHEA_BCMC_SCOPE_ALL |
+						  EHEA_BCMC_MULTICAST |
+						  EHEA_BCMC_VLANID_ALL;
+				arr[i++].macaddr = mc_entry->macaddr;
+			}
+		}
+	}
+
+out_update:
+	kfree(ehea_bcmc_regs.arr);
+	ehea_bcmc_regs.arr = arr;
+	ehea_bcmc_regs.num_entries = i;
+}
+
 static struct net_device_stats *ehea_get_stats(struct net_device *dev)
 {
 	struct ehea_port *port = netdev_priv(dev);
@@ -1601,19 +1758,25 @@ static int ehea_set_mac_addr(struct net_device *dev, void *sa)

 	memcpy(dev->dev_addr, mac_addr->sa_data, dev->addr_len);

+	down(&ehea_bcmc_regs.lock);
+
 	/* Deregister old MAC in pHYP */
 	ret = ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
 	if (ret)
-		goto out_free;
+		goto out_upregs;

 	port->mac_addr = cb0->port_mac_addr << 16;

 	/* Register new MAC in pHYP */
 	ret = ehea_broadcast_reg_helper(port, H_REG_BCMC);
 	if (ret)
-		goto out_free;
+		goto out_upregs;

 	ret = 0;
+
+out_upregs:
+	ehea_update_bcmc_registrations();
+	up(&ehea_bcmc_regs.lock);
 out_free:
 	kfree(cb0);
 out:
@@ -1775,9 +1938,11 @@ static void ehea_set_multicast_list(struct net_device *dev)
 	}
 	ehea_promiscuous(dev, 0);

+	down(&ehea_bcmc_regs.lock);
+
 	if (dev->flags & IFF_ALLMULTI) {
 		ehea_allmulti(dev, 1);
-		return;
+		goto out;
 	}
 	ehea_allmulti(dev, 0);

@@ -1803,6 +1968,8 @@ static void ehea_set_multicast_list(struct net_device *dev)

 	}
 out:
+	ehea_update_bcmc_registrations();
+	up(&ehea_bcmc_regs.lock);
 	return;
 }

@@ -2285,6 +2452,8 @@ static int ehea_up(struct net_device *dev)
 	if (port->state == EHEA_PORT_UP)
 		return 0;

+	down(&ehea_fw_handles.lock);
+
 	ret = ehea_port_res_setup(port, port->num_def_qps,
 				  port->num_add_tx_qps);
 	if (ret) {
@@ -2321,8 +2490,17 @@ static int ehea_up(struct net_device *dev)
 		}
 	}

-	ret = 0;
+	down(&ehea_bcmc_regs.lock);
+
+	ret = ehea_broadcast_reg_helper(port, H_REG_BCMC);
+	if (ret) {
+		ret = -EIO;
+		goto out_free_irqs;
+	}
+
 	port->state = EHEA_PORT_UP;
+
+	ret = 0;
 	goto out;

 out_free_irqs:
@@ -2334,6 +2512,12 @@ out:
 	if (ret)
 		ehea_info("Failed starting %s. ret=%i", dev->name, ret);

+	ehea_update_bcmc_registrations();
+	up(&ehea_bcmc_regs.lock);
+
+	ehea_update_firmware_handles();
+	up(&ehea_fw_handles.lock);
+
 	return ret;
 }

@@ -2382,16 +2566,27 @@ static int ehea_down(struct net_device *dev)
 	if (port->state == EHEA_PORT_DOWN)
 		return 0;

+	down(&ehea_bcmc_regs.lock);
 	ehea_drop_multicast_list(dev);
+	ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
+
 	ehea_free_interrupts(dev);

+	down(&ehea_fw_handles.lock);
+
 	port->state = EHEA_PORT_DOWN;

+	ehea_update_bcmc_registrations();
+	up(&ehea_bcmc_regs.lock);
+
 	ret = ehea_clean_all_portres(port);
 	if (ret)
 		ehea_info("Failed freeing resources for %s. ret=%i",
 			  dev->name, ret);

+	ehea_update_firmware_handles();
+	up(&ehea_fw_handles.lock);
+
 	return ret;
 }

@@ -2920,19 +3115,12 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 	dev->watchdog_timeo = EHEA_WATCH_DOG_TIMEOUT;

 	INIT_WORK(&port->reset_task, ehea_reset_port);
-
-	ret = ehea_broadcast_reg_helper(port, H_REG_BCMC);
-	if (ret) {
-		ret = -EIO;
-		goto out_unreg_port;
-	}
-
 	ehea_set_ethtool_ops(dev);

 	ret = register_netdev(dev);
 	if (ret) {
 		ehea_error("register_netdev failed. ret=%d", ret);
-		goto out_dereg_bc;
+		goto out_unreg_port;
 	}

 	port->lro_max_aggr = lro_max_aggr;
@@ -2949,9 +3137,6 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,

 	return port;

-out_dereg_bc:
-	ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
-
 out_unreg_port:
 	ehea_unregister_port(port);

@@ -2971,7 +3156,6 @@ static void ehea_shutdown_single_port(struct ehea_port *port)
 {
 	unregister_netdev(port->netdev);
 	ehea_unregister_port(port);
-	ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
 	kfree(port->mc_list);
 	free_netdev(port->netdev);
 	port->adapter->active_ports--;
@@ -3014,7 +3198,6 @@ static int ehea_setup_ports(struct ehea_adapter *adapter)

 		i++;
 	};
-
 	return 0;
 }

@@ -3159,6 +3342,7 @@ static int __devinit ehea_probe_adapter(struct of_device *dev,
 		ehea_error("Invalid ibmebus device probed");
 		return -EINVAL;
 	}
+	down(&ehea_fw_handles.lock);

 	adapter = kzalloc(sizeof(*adapter), GFP_KERNEL);
 	if (!adapter) {
@@ -3239,7 +3423,10 @@ out_kill_eq:

 out_free_ad:
 	kfree(adapter);
+
 out:
+	ehea_update_firmware_handles();
+	up(&ehea_fw_handles.lock);
 	return ret;
 }

@@ -3258,18 +3445,41 @@ static int __devexit ehea_remove(struct of_device *dev)

 	flush_scheduled_work();

+	down(&ehea_fw_handles.lock);
+
 	ibmebus_free_irq(adapter->neq->attr.ist1, adapter);
 	tasklet_kill(&adapter->neq_tasklet);

 	ehea_destroy_eq(adapter->neq);
 	ehea_remove_adapter_mr(adapter);
 	list_del(&adapter->list);
-
 	kfree(adapter);

+	ehea_update_firmware_handles();
+	up(&ehea_fw_handles.lock);
+
 	return 0;
 }

+void ehea_crash_handler(void)
+{
+	int i;
+
+	if (ehea_fw_handles.arr)
+		for (i = 0; i < ehea_fw_handles.num_entries; i++)
+			ehea_h_free_resource(ehea_fw_handles.arr[i].adh,
+					     ehea_fw_handles.arr[i].fwh,
+					     FORCE_FREE);
+
+	if (ehea_bcmc_regs.arr)
+		for (i = 0; i < ehea_bcmc_regs.num_entries; i++)
+			ehea_h_reg_dereg_bcmc(ehea_bcmc_regs.arr[i].adh,
+					      ehea_bcmc_regs.arr[i].port_id,
+					      ehea_bcmc_regs.arr[i].reg_type,
+					      ehea_bcmc_regs.arr[i].macaddr,
+					      0, H_DEREG_BCMC);
+}
+
 static int ehea_reboot_notifier(struct notifier_block *nb,
 				unsigned long action, void *unused)
 {
@@ -3330,7 +3540,12 @@ int __init ehea_module_init(void)


 	INIT_WORK(&ehea_rereg_mr_task, ehea_rereg_mrs);
+	memset(&ehea_fw_handles, 0, sizeof(ehea_fw_handles));
+	memset(&ehea_bcmc_regs, 0, sizeof(ehea_bcmc_regs));
+
 	sema_init(&dlpar_mem_lock, 1);
+	sema_init(&ehea_fw_handles.lock, 1);
+	sema_init(&ehea_bcmc_regs.lock, 1);

 	ret = check_module_parm();
 	if (ret)
@@ -3340,12 +3555,18 @@ int __init ehea_module_init(void)
 	if (ret)
 		goto out;

-	register_reboot_notifier(&ehea_reboot_nb);
+	ret = register_reboot_notifier(&ehea_reboot_nb);
+	if (ret)
+		ehea_info("failed registering reboot notifier");
+
+	ret = crash_shutdown_register(&ehea_crash_handler);
+	if (ret)
+		ehea_info("failed registering crash handler");

 	ret = ibmebus_register_driver(&ehea_driver);
 	if (ret) {
 		ehea_error("failed registering eHEA device driver on ebus");
-		goto out;
+		goto out2;
 	}

 	ret = driver_create_file(&ehea_driver.driver,
@@ -3353,21 +3574,33 @@ int __init ehea_module_init(void)
 	if (ret) {
 		ehea_error("failed to register capabilities attribute, ret=%d",
 			   ret);
-		unregister_reboot_notifier(&ehea_reboot_nb);
-		ibmebus_unregister_driver(&ehea_driver);
-		goto out;
+		goto out3;
 	}

+	return ret;
+
+out3:
+	ibmebus_unregister_driver(&ehea_driver);
+out2:
+	unregister_reboot_notifier(&ehea_reboot_nb);
+	crash_shutdown_unregister(&ehea_crash_handler);
 out:
 	return ret;
 }

 static void __exit ehea_module_exit(void)
 {
+	int ret;
+
 	flush_scheduled_work();
 	driver_remove_file(&ehea_driver.driver, &driver_attr_capabilities);
 	ibmebus_unregister_driver(&ehea_driver);
 	unregister_reboot_notifier(&ehea_reboot_nb);
+	ret = crash_shutdown_unregister(&ehea_crash_handler);
+	if (ret)
+		ehea_info("failed unregistering crash handler");
+	kfree(ehea_fw_handles.arr);
+	kfree(ehea_bcmc_regs.arr);
 	ehea_destroy_busmap();
 }

-- 
1.5.2


