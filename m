From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH 1/2] ehea: dynamic add / remove port
Date: Wed, 28 Feb 2007 18:34:02 +0100
Message-ID: <200702281834.02990.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Klein <tklein@de.ibm.com>, Jan-Bernd Themann <themann@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>, Christoph Raisch <raisch@de.ibm.com>,
	Marcus Eder <meder@de.ibm.com>, Stefan Roscher <stefan.roscher@de.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

This patch introduces functionality to dynamically add / remove
ehea ports via an userspace DLPAR tool. It creates a subnode for
each logical port in the sysfs. 


Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
---


diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 42295d6..e595d6b 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -39,7 +39,7 @@ #include <asm/abs_addr.h>
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0046"
+#define DRV_VERSION	"EHEA_0048"
 
 #define EHEA_MSG_DEFAULT (NETIF_MSG_LINK | NETIF_MSG_TIMER \
 	| NETIF_MSG_RX_ERR | NETIF_MSG_TX_ERR)
@@ -380,10 +380,11 @@ struct ehea_port_res {
 };
 
 
+#define EHEA_MAX_PORTS 16
 struct ehea_adapter {
 	u64 handle;
-	u8 num_ports;
-	struct ehea_port *port[16];
+	struct ibmebus_dev *ebus_dev;
+	struct ehea_port *port[EHEA_MAX_PORTS];
 	struct ehea_eq *neq;       /* notification event queue */
 	struct workqueue_struct *ehea_wq;
 	struct tasklet_struct neq_tasklet;
@@ -406,7 +407,7 @@ struct ehea_port {
 	struct net_device *netdev;
 	struct net_device_stats stats;
 	struct ehea_port_res port_res[EHEA_MAX_PORT_RES];
-	struct device_node *of_dev_node; /* Open Firmware Device Node */
+	struct of_device  ofdev; /* Open Firmware Device */
 	struct ehea_mc_list *mc_list;	 /* Multicast MAC addresses */
 	struct vlan_group *vgrp;
 	struct ehea_eq *qp_eq;
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 1ef3846..42edd8d 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -580,7 +580,7 @@ static struct ehea_port *ehea_get_port(s
 {
 	int i;
 
-	for (i = 0; i < adapter->num_ports; i++)
+	for (i = 0; i < EHEA_MAX_PORTS; i++)
 		if (adapter->port[i])
 	                if (adapter->port[i]->logical_port_id == logical_port)
 				return adapter->port[i];
@@ -2274,8 +2274,6 @@ static void ehea_tx_watchdog(struct net_
 int ehea_sense_adapter_attr(struct ehea_adapter *adapter)
 {
 	struct hcp_query_ehea *cb;
-	struct device_node *lhea_dn = NULL;
-	struct device_node *eth_dn = NULL;
 	u64 hret;
 	int ret;
 
@@ -2292,18 +2290,6 @@ int ehea_sense_adapter_attr(struct ehea_
 		goto out_herr;
 	}
 
-	/* Determine the number of available logical ports
-	 * by counting the child nodes of the lhea OFDT entry
-	 */
-	adapter->num_ports = 0;
-	lhea_dn = of_find_node_by_name(lhea_dn, "lhea");
-	do {
-		eth_dn = of_get_next_child(lhea_dn, eth_dn);
-		if (eth_dn)
-			adapter->num_ports++;
-	} while ( eth_dn );
-	of_node_put(lhea_dn);
-
 	adapter->max_mc_mac = cb->max_mc_mac - 1;
 	ret = 0;
 
@@ -2313,79 +2299,150 @@ out:
 	return ret;
 }
 
-static int ehea_setup_single_port(struct ehea_port *port,
-				  struct device_node *dn)
+int ehea_get_jumboframe_status(struct ehea_port *port, int *jumbo)
 {
-	int ret;
-	u64 hret;
-	struct net_device *dev = port->netdev;
-	struct ehea_adapter *adapter = port->adapter;
 	struct hcp_ehea_port_cb4 *cb4;
-	u32 *dn_log_port_id;
-	int jumbo = 0;
-
-	sema_init(&port->port_lock, 1);
-	port->state = EHEA_PORT_DOWN;
-	port->sig_comp_iv = sq_entries / 10;
-
-	if (!dn) {
-		ehea_error("bad device node: dn=%p", dn);
-		ret = -EINVAL;
-		goto out;
-	}
-
-	port->of_dev_node = dn;
-
-	/* Determine logical port id */
-	dn_log_port_id = (u32*)get_property(dn, "ibm,hea-port-no", NULL);
-
-	if (!dn_log_port_id) {
-		ehea_error("bad device node: dn_log_port_id=%p",
-			   dn_log_port_id);
-		ret = -EINVAL;
-		goto out;
-	}
-	port->logical_port_id = *dn_log_port_id;
-
-	port->mc_list = kzalloc(sizeof(struct ehea_mc_list), GFP_KERNEL);
-	if (!port->mc_list) {
-		ret = -ENOMEM;
-		goto out;
-	}
-
-	INIT_LIST_HEAD(&port->mc_list->list);
+	u64 hret;
+	int ret = 0;
 
-	ret = ehea_sense_port_attr(port);
-	if (ret)
-		goto out;
+	*jumbo = 0;
 
-	/* Enable Jumbo frames */
+	/* (Try to) enable *jumbo frames */
 	cb4 = kzalloc(PAGE_SIZE, GFP_KERNEL);
 	if (!cb4) {
 		ehea_error("no mem for cb4");
+		ret = -ENOMEM;
+		goto out;
 	} else {
-		hret = ehea_h_query_ehea_port(adapter->handle,
+		hret = ehea_h_query_ehea_port(port->adapter->handle,
 					      port->logical_port_id,
 					      H_PORT_CB4,
 					      H_PORT_CB4_JUMBO, cb4);
-
 		if (hret == H_SUCCESS) {
 			if (cb4->jumbo_frame)
-				jumbo = 1;
+				*jumbo = 1;
 			else {
 				cb4->jumbo_frame = 1;
-				hret = ehea_h_modify_ehea_port(adapter->handle,
+				hret = ehea_h_modify_ehea_port(port->adapter->
+							       handle,
 							       port->
-							        logical_port_id,
+							       logical_port_id,
 							       H_PORT_CB4,
 							       H_PORT_CB4_JUMBO,
 							       cb4);
 				if (hret == H_SUCCESS)
-					jumbo = 1;
+					*jumbo = 1;
 			}
-		}
+		} else
+			ret = -EINVAL;
+
 		kfree(cb4);
 	}
+out:
+	return ret;
+}
+
+static ssize_t ehea_show_port_id(struct device *dev,
+				 struct device_attribute *attr, char *buf)
+{
+	struct ehea_port *port = container_of(dev, struct ehea_port, ofdev.dev);
+	return sprintf(buf, "0x%X", port->logical_port_id);
+}
+
+static DEVICE_ATTR(log_port_id, S_IRUSR | S_IRGRP | S_IROTH, ehea_show_port_id,
+		   NULL);
+
+static void __devinit logical_port_release(struct device *dev)
+{
+	struct ehea_port *port = container_of(dev, struct ehea_port, ofdev.dev);
+	of_node_put(port->ofdev.node);
+}
+
+static struct device *ehea_register_port(struct ehea_port *port,
+					 struct device_node *dn)
+{
+	int ret;
+
+	port->ofdev.node = of_node_get(dn);
+	port->ofdev.dev.parent = &port->adapter->ebus_dev->ofdev.dev;
+
+	sprintf(port->ofdev.dev.bus_id, "port%d", port->logical_port_id);
+	port->ofdev.dev.release = logical_port_release;
+
+	ret = of_device_register(&port->ofdev);
+	if (ret) {
+		ehea_error("failed to register device. ret=%d", ret);
+		goto out;
+	}
+
+	ret = device_create_file(&port->ofdev.dev, &dev_attr_log_port_id);
+        if (ret) {
+		ehea_error("failed to register attributes, ret=%d", ret);
+		goto out_unreg_of_dev;
+	}
+	
+	return &port->ofdev.dev;
+
+out_unreg_of_dev:
+	of_device_unregister(&port->ofdev);
+out:
+	return NULL;
+}
+
+static void ehea_unregister_port(struct ehea_port *port)
+{
+	device_remove_file(&port->ofdev.dev, &dev_attr_log_port_id);
+	of_device_unregister(&port->ofdev);
+}
+
+struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
+					 u32 logical_port_id,
+					 struct device_node *dn)
+{
+	int ret;
+	struct net_device *dev;
+	struct ehea_port *port;
+	struct device *port_dev;
+	int jumbo;
+
+	/* allocate memory for the port structures */
+	dev = alloc_etherdev(sizeof(struct ehea_port));
+
+	if (!dev) {
+		ehea_error("no mem for net_device");
+		ret = -ENOMEM;
+		goto out_err;
+	}
+
+	port = netdev_priv(dev);
+
+	sema_init(&port->port_lock, 1);
+	port->state = EHEA_PORT_DOWN;
+	port->sig_comp_iv = sq_entries / 10;
+
+	port->adapter = adapter;
+	port->netdev = dev;
+	port->logical_port_id = logical_port_id;
+
+	port->msg_enable = netif_msg_init(msg_level, EHEA_MSG_DEFAULT);
+
+	port->mc_list = kzalloc(sizeof(struct ehea_mc_list), GFP_KERNEL);
+	if (!port->mc_list) {
+		ret = -ENOMEM;
+		goto out_free_ethdev;
+	}
+
+	INIT_LIST_HEAD(&port->mc_list->list);
+
+	ret = ehea_sense_port_attr(port);
+	if (ret)
+		goto out_free_mc_list;
+
+	port_dev = ehea_register_port(port, dn);
+	if (!port_dev)
+		goto out_free_mc_list;
+
+	SET_NETDEV_DEV(dev, port_dev);
 
 	/* initialize net_device structure */
 	SET_MODULE_OWNER(dev);
@@ -2418,79 +2475,216 @@ static int ehea_setup_single_port(struct
 	ret = register_netdev(dev);
 	if (ret) {
 		ehea_error("register_netdev failed. ret=%d", ret);
-		goto out_free;
+		goto out_unreg_port;
 	}
 
+	ret = ehea_get_jumboframe_status(port, &jumbo);
+	if (ret) 
+		ehea_error("failed determining jumbo frame status for %s",
+			   port->netdev->name);
+
 	ehea_info("%s: Jumbo frames are %sabled", dev->name,
 		  jumbo == 1 ? "en" : "dis");
 
-	port->netdev = dev;
-	ret = 0;
-	goto out;
+	return port;
 
-out_free:
+out_unreg_port:
+	ehea_unregister_port(port);
+
+out_free_mc_list:
 	kfree(port->mc_list);
-out:
-	return ret;
+
+out_free_ethdev:
+	free_netdev(dev);
+
+out_err:
+	ehea_error("setting up logical port with id=%d failed, ret=%d",
+		   logical_port_id, ret);
+	return NULL;
+}
+
+static void ehea_shutdown_single_port(struct ehea_port *port)
+{
+	unregister_netdev(port->netdev);
+	ehea_unregister_port(port);
+	kfree(port->mc_list);
+	free_netdev(port->netdev);
 }
 
 static int ehea_setup_ports(struct ehea_adapter *adapter)
 {
-	int ret;
+	struct device_node *lhea_dn;
+	struct device_node *eth_dn = NULL;
+
+	u32 *dn_log_port_id;
 	int port_setup_ok = 0;
-	struct ehea_port *port;
-	struct device_node *dn = NULL;
-	struct net_device *dev;
-	int i;
+	int i = 0;
+
+	lhea_dn = adapter->ebus_dev->ofdev.node;
+	do {
+		eth_dn = of_get_next_child(lhea_dn, eth_dn);
+		if (!eth_dn)
+			break;
 
-	/* get port properties for all ports */
-	for (i = 0; i < adapter->num_ports; i++) {
+		dn_log_port_id = (u32*)get_property(eth_dn, "ibm,hea-port-no",
+						    NULL);
+		if (!dn_log_port_id) {
+			ehea_error("bad device node: eth_dn name=%s",
+				   eth_dn->full_name);
+			continue;
+		}
 
+		adapter->port[i] = ehea_setup_single_port(adapter,
+							  *dn_log_port_id,
+							  eth_dn);
 		if (adapter->port[i])
-			continue;	/* port already up and running */
+			ehea_info("%s -> logical port id #%d",
+				  adapter->port[i]->netdev->name, 
+				  *dn_log_port_id);
+		i++;
+	} while (eth_dn);
+
+	of_node_put(lhea_dn);
 
-		/* allocate memory for the port structures */
-		dev = alloc_etherdev(sizeof(struct ehea_port));
+	/* Check for succesfully set up ports */
+	for (i = 0; i < EHEA_MAX_PORTS; i++)
+		if (adapter->port[i])
+			port_setup_ok++;
 
-		if (!dev) {
-			ehea_error("no mem for net_device");
+	if (port_setup_ok)
+		return 0;	/* At least some ports are setup correctly */
+
+	return -EINVAL;
+}
+
+static struct device_node *ehea_get_eth_dn(struct ehea_adapter *adapter, 
+					   u32 logical_port_id) 
+{
+	struct device_node *lhea_dn;
+	struct device_node *eth_dn = NULL;
+	u32 *dn_log_port_id;
+
+	lhea_dn = adapter->ebus_dev->ofdev.node;
+	do {
+		eth_dn = of_get_next_child(lhea_dn, eth_dn);
+		if (!eth_dn)
 			break;
-		}
 
-		port = netdev_priv(dev);
-		port->adapter = adapter;
-		port->netdev = dev;
-		adapter->port[i] = port;
-		port->msg_enable = netif_msg_init(msg_level, EHEA_MSG_DEFAULT);
+		dn_log_port_id = (u32*)get_property(eth_dn, "ibm,hea-port-no",
+						    NULL);
 
-		dn = of_find_node_by_name(dn, "ethernet");
-		ret = ehea_setup_single_port(port, dn);
-		if (ret) {
-			/* Free mem for this port struct. The others will be
-			   processed on rollback */
-			free_netdev(dev);
-			adapter->port[i] = NULL;
-			ehea_error("eHEA port %d setup failed, ret=%d", i, ret);
-		}
+		if (dn_log_port_id)
+			if (*dn_log_port_id == logical_port_id)
+				return eth_dn;
+
+	} while (eth_dn);
+
+	of_node_put(lhea_dn);
+
+	return NULL;
+}
+
+static ssize_t ehea_probe_port(struct device *dev,
+			       struct device_attribute *attr,
+			       const char *buf, size_t count)
+{
+	struct ehea_adapter *adapter = dev->driver_data;
+	struct ehea_port *port;
+	struct device_node *eth_dn = NULL;
+	int i;
+
+	u32 logical_port_id;
+
+	sscanf(buf, "%X", &logical_port_id);
+
+	port = ehea_get_port(adapter, logical_port_id);
+
+	if (port) {
+		ehea_info("adding port with logical port id=%d failed. port "
+			  "already configured as %s.", logical_port_id,
+			  port->netdev->name);
+		return -EINVAL;
 	}
+	
+	eth_dn = ehea_get_eth_dn(adapter, logical_port_id);
 
-	of_node_put(dn);
+	if (!eth_dn) {
+		ehea_info("no logical port with id %d found", logical_port_id);
+		return -EINVAL;
+	}
+		
+	port = ehea_setup_single_port(adapter, logical_port_id, eth_dn);
 
-	/* Check for succesfully set up ports */
-	for (i = 0; i < adapter->num_ports; i++)
-		if (adapter->port[i])
-			port_setup_ok++;
+	if (port) {
+		for (i=0; i < EHEA_MAX_PORTS; i++)
+			if (!adapter->port[i]) {
+				adapter->port[i] = port;
+				break;
+			}
 
-	if (port_setup_ok)
-		ret = 0;	/* At least some ports are setup correctly */
-	else
-		ret = -EINVAL;
+		ehea_info("added %s (logical port id=%d)", port->netdev->name,
+			  logical_port_id);
+	} else 
+		return -EIO;	       
 
+	return (ssize_t) count;
+}
+
+static ssize_t ehea_remove_port(struct device *dev,
+				struct device_attribute *attr,
+				const char *buf, size_t count)
+{
+	struct ehea_adapter *adapter = dev->driver_data;
+	struct ehea_port *port;
+	int i;
+	u32 logical_port_id;
+
+	sscanf(buf, "%X", &logical_port_id);
+
+	port = ehea_get_port(adapter, logical_port_id);
+
+	if (port) {
+		ehea_info("removed %s (logical port id=%d)", port->netdev->name,
+			  logical_port_id);
+
+		ehea_shutdown_single_port(port);
+
+		for (i=0; i < EHEA_MAX_PORTS; i++)
+			if (adapter->port[i] == port) {
+				adapter->port[i] = NULL;
+				break;
+			}
+	} else {
+		ehea_error("removing port with logical port id=%d failed. port "
+			   "not configured.", logical_port_id);
+		return -EINVAL;
+	}
+
+	return (ssize_t) count;
+}
+
+static DEVICE_ATTR(probe_port, S_IWUSR, NULL, ehea_probe_port);
+static DEVICE_ATTR(remove_port, S_IWUSR, NULL, ehea_remove_port);
+
+int ehea_create_device_sysfs(struct ibmebus_dev *dev)
+{
+	int ret = device_create_file(&dev->ofdev.dev, &dev_attr_probe_port);
+	if (ret)
+		goto out;
+
+	ret = device_create_file(&dev->ofdev.dev, &dev_attr_remove_port);
+out:
 	return ret;
 }
 
-static int __devinit ehea_probe(struct ibmebus_dev *dev,
-				const struct of_device_id *id)
+void ehea_remove_device_sysfs(struct ibmebus_dev *dev)
+{
+	device_remove_file(&dev->ofdev.dev, &dev_attr_probe_port);
+	device_remove_file(&dev->ofdev.dev, &dev_attr_remove_port);
+}
+
+static int __devinit ehea_probe_adapter(struct ibmebus_dev *dev,
+					const struct of_device_id *id)
 {
 	struct ehea_adapter *adapter;
 	u64 *adapter_handle;
@@ -2503,6 +2697,8 @@ static int __devinit ehea_probe(struct i
 		goto out;
 	}
 
+	adapter->ebus_dev = dev;
+
 	adapter_handle = (u64*)get_property(dev->ofdev.node, "ibm,hea-handle",
 					    NULL);
 	if (adapter_handle)
@@ -2532,7 +2728,6 @@ static int __devinit ehea_probe(struct i
 		dev_err(&dev->ofdev.dev, "sense_adapter_attr failed: %d", ret);
 		goto out_free_res;
 	}
-	dev_info(&dev->ofdev.dev, "%d eHEA ports found\n", adapter->num_ports);
 
 	adapter->neq = ehea_create_eq(adapter,
 				      EHEA_NEQ, EHEA_MAX_ENTRIES_EQ, 1);
@@ -2556,15 +2751,21 @@ static int __devinit ehea_probe(struct i
 	if (!adapter->ehea_wq)
 		goto out_free_irq;
 
+	if (ehea_create_device_sysfs(dev))
+		goto out_kill_wq;
+
 	ret = ehea_setup_ports(adapter);
 	if (ret) {
 		dev_err(&dev->ofdev.dev, "setup_ports failed");
-		goto out_kill_wq;
+		goto out_rem_dev_sysfs;
 	}
 
 	ret = 0;
 	goto out;
 
+out_rem_dev_sysfs:
+	ehea_remove_device_sysfs(dev);
+
 out_kill_wq:
 	destroy_workqueue(adapter->ehea_wq);
 
@@ -2583,24 +2784,20 @@ out:
 	return ret;
 }
 
-static void ehea_shutdown_single_port(struct ehea_port *port)
-{
-	unregister_netdev(port->netdev);
-	kfree(port->mc_list);
-	free_netdev(port->netdev);
-}
-
 static int __devexit ehea_remove(struct ibmebus_dev *dev)
 {
 	struct ehea_adapter *adapter = dev->ofdev.dev.driver_data;
 	u64 hret;
 	int i;
 
-	for (i = 0; i < adapter->num_ports; i++)
+	for (i = 0; i < EHEA_MAX_PORTS; i++)
 		if (adapter->port[i]) {
 			ehea_shutdown_single_port(adapter->port[i]);
 			adapter->port[i] = NULL;
 		}
+
+	ehea_remove_device_sysfs(dev);
+
 	destroy_workqueue(adapter->ehea_wq);
 
 	ibmebus_free_irq(NULL, adapter->neq->attr.ist1, adapter);
@@ -2656,7 +2853,7 @@ static struct of_device_id ehea_device_t
 static struct ibmebus_driver ehea_driver = {
 	.name = "ehea",
 	.id_table = ehea_device_table,
-	.probe = ehea_probe,
+	.probe = ehea_probe_adapter,
 	.remove = ehea_remove,
 };
