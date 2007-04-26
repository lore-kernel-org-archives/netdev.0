From: Thomas Klein <osstklei@de.ibm.com>
Subject: [PATCH 2/2] ehea: fix for dlpar support
Date: Thu, 26 Apr 2007 11:56:43 +0200
Message-ID: <200704261156.43524.osstklei@de.ibm.com>
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
Received: from mtagate2.de.ibm.com ([195.212.29.151]:32786 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161818AbXDZJ4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 05:56:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Certain resources may only be allocated when first logical port is available,
and must be removed when last logical port has been removed.

Signed-off-by: Thomas Klein <tklein@de.ibm.com>
---


This patch applies on top of the netdev upstream branch for 2.6.22


diff -Nurp -X dontdiff linux-2.6.21/drivers/net/ehea/ehea.h patched_kernel/drivers/net/ehea/ehea.h
--- linux-2.6.21/drivers/net/ehea/ehea.h	2007-04-26 11:21:33.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea.h	2007-04-26 11:23:16.000000000 +0200
@@ -39,7 +39,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0057"
+#define DRV_VERSION	"EHEA_0058"
 
 #define EHEA_MSG_DEFAULT (NETIF_MSG_LINK | NETIF_MSG_TIMER \
 	| NETIF_MSG_RX_ERR | NETIF_MSG_TX_ERR)
diff -Nurp -X dontdiff linux-2.6.21/drivers/net/ehea/ehea_main.c patched_kernel/drivers/net/ehea/ehea_main.c
--- linux-2.6.21/drivers/net/ehea/ehea_main.c	2007-04-26 11:21:33.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea_main.c	2007-04-26 11:23:16.000000000 +0200
@@ -2130,6 +2130,28 @@ static int ehea_clean_all_portres(struct
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
@@ -2580,7 +2602,6 @@ static int ehea_setup_ports(struct ehea_
 	struct device_node *eth_dn = NULL;
 
 	u32 *dn_log_port_id;
-	int port_setup_ok = 0;
 	int i = 0;
 
 	lhea_dn = adapter->ebus_dev->ofdev.node;
@@ -2594,6 +2615,12 @@ static int ehea_setup_ports(struct ehea_
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
@@ -2601,18 +2628,13 @@ static int ehea_setup_ports(struct ehea_
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
@@ -2664,6 +2686,11 @@ static ssize_t ehea_probe_port(struct de
 		return -EINVAL;
 	}
 
+	if (ehea_add_adapter_mr(adapter)) {
+		ehea_error("creating MR failed");
+		return -EIO;
+	}
+
 	port = ehea_setup_single_port(adapter, logical_port_id, eth_dn);
 
 	of_node_put(eth_dn);
@@ -2677,8 +2704,10 @@ static ssize_t ehea_probe_port(struct de
 
 		ehea_info("added %s (logical port id=%d)", port->netdev->name,
 			  logical_port_id);
-	} else
+	} else {
+		ehea_remove_adapter_mr(adapter);
 		return -EIO;
+	}
 
 	return (ssize_t) count;
 }
@@ -2713,6 +2742,8 @@ static ssize_t ehea_remove_port(struct d
 		return -EINVAL;
 	}
 
+	ehea_remove_adapter_mr(adapter);
+
 	return (ssize_t) count;
 }
 
@@ -2773,18 +2804,13 @@ static int __devinit ehea_probe_adapter(
 
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
@@ -2792,7 +2818,7 @@ static int __devinit ehea_probe_adapter(
 	if (!adapter->neq) {
 		ret = -EIO;
 		dev_err(&dev->ofdev.dev, "NEQ creation failed");
-		goto out_free_res;
+		goto out_free_ad;
 	}
 
 	tasklet_init(&adapter->neq_tasklet, ehea_neq_tasklet,
@@ -2837,9 +2863,6 @@ out_free_irq:
 out_kill_eq:
 	ehea_destroy_eq(adapter->neq);
 
-out_free_res:
-	ehea_rem_mr(&adapter->mr);
-
 out_free_ad:
 	kfree(adapter);
 out:
@@ -2865,7 +2888,7 @@ static int __devexit ehea_remove(struct 
 	tasklet_kill(&adapter->neq_tasklet);
 
 	ehea_destroy_eq(adapter->neq);
-	ehea_rem_mr(&adapter->mr);
+	ehea_remove_adapter_mr(adapter);
 	kfree(adapter);
 	return 0;
 }

