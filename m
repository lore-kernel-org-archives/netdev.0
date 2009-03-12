From: "Jan-Bernd Themann" <ossthema@de.ibm.com>
Subject: [PATCH net-next-2.6] ehea: fix circular locking problem
Date: Thu, 12 Mar 2009 16:20:18 +0100
Message-ID: <200903121620.19075.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: " linux-kernel" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, raisch@de.ibm.com, tklein@de.ibm.com,
	themann@de.ibm.com, Hannes Hering <hering2@de.ibm.com>,
	linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757235AbZCLPVW@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the circular locking problem by changing the locking strategy
concerning the logging of firmware handles.

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>



---

 drivers/net/ehea/ehea.h      |    2 +-
 drivers/net/ehea/ehea_main.c |   56 ++++++++++++++++++++++-------------------
 2 files changed, 31 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 029631c..6e317ca 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0099"
+#define DRV_VERSION	"EHEA_0100"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 40c34bf..ac0c5b4 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -155,6 +155,8 @@ static void ehea_update_firmware_handles(void)
 	int num_fw_handles, k, l;
 
 	/* Determine number of handles */
+	mutex_lock(&ehea_fw_handles.lock);
+
 	list_for_each_entry(adapter, &adapter_list, list) {
 		num_adapters++;
 
@@ -176,15 +178,19 @@ static void ehea_update_firmware_handles(void)
 	if (num_fw_handles) {
 		arr = kzalloc(num_fw_handles * sizeof(*arr), GFP_KERNEL);
 		if (!arr)
-			return;  /* Keep the existing array */
+			goto out;  /* Keep the existing array */
 	} else
 		goto out_update;
 
 	list_for_each_entry(adapter, &adapter_list, list) {
+		if (num_adapters == 0)
+			break;
+
 		for (k = 0; k < EHEA_MAX_PORTS; k++) {
 			struct ehea_port *port = adapter->port[k];
 
-			if (!port || (port->state != EHEA_PORT_UP))
+			if (!port || (port->state != EHEA_PORT_UP)
+				|| (num_ports == 0))
 				continue;
 
 			for (l = 0;
@@ -207,6 +213,7 @@ static void ehea_update_firmware_handles(void)
 			}
 			arr[i].adh = adapter->handle;
 			arr[i++].fwh = port->qp_eq->fw_handle;
+			num_ports--;
 		}
 
 		arr[i].adh = adapter->handle;
@@ -216,16 +223,20 @@ static void ehea_update_firmware_handles(void)
 			arr[i].adh = adapter->handle;
 			arr[i++].fwh = adapter->mr.handle;
 		}
+		num_adapters--;
 	}
 
 out_update:
 	kfree(ehea_fw_handles.arr);
 	ehea_fw_handles.arr = arr;
 	ehea_fw_handles.num_entries = i;
+out:
+	mutex_unlock(&ehea_fw_handles.lock);
 }
 
 static void ehea_update_bcmc_registrations(void)
 {
+	unsigned long flags;
 	struct ehea_bcmc_reg_entry *arr = NULL;
 	struct ehea_adapter *adapter;
 	struct ehea_mc_list *mc_entry;
@@ -233,6 +244,8 @@ static void ehea_update_bcmc_registrations(void)
 	int i = 0;
 	int k;
 
+	spin_lock_irqsave(&ehea_bcmc_regs.lock, flags);
+
 	/* Determine number of registrations */
 	list_for_each_entry(adapter, &adapter_list, list)
 		for (k = 0; k < EHEA_MAX_PORTS; k++) {
@@ -250,7 +263,7 @@ static void ehea_update_bcmc_registrations(void)
 	if (num_registrations) {
 		arr = kzalloc(num_registrations * sizeof(*arr), GFP_ATOMIC);
 		if (!arr)
-			return;  /* Keep the existing array */
+			goto out;  /* Keep the existing array */
 	} else
 		goto out_update;
 
@@ -261,6 +274,9 @@ static void ehea_update_bcmc_registrations(void)
 			if (!port || (port->state != EHEA_PORT_UP))
 				continue;
 
+			if (num_registrations == 0)
+				goto out_update;
+
 			arr[i].adh = adapter->handle;
 			arr[i].port_id = port->logical_port_id;
 			arr[i].reg_type = EHEA_BCMC_BROADCAST |
@@ -272,9 +288,13 @@ static void ehea_update_bcmc_registrations(void)
 			arr[i].reg_type = EHEA_BCMC_BROADCAST |
 					  EHEA_BCMC_VLANID_ALL;
 			arr[i++].macaddr = port->mac_addr;
+			num_registrations -= 2;
 
 			list_for_each_entry(mc_entry,
 					    &port->mc_list->list, list) {
+				if (num_registrations == 0)
+					goto out_update;
+
 				arr[i].adh = adapter->handle;
 				arr[i].port_id = port->logical_port_id;
 				arr[i].reg_type = EHEA_BCMC_SCOPE_ALL |
@@ -288,6 +308,7 @@ static void ehea_update_bcmc_registrations(void)
 						  EHEA_BCMC_MULTICAST |
 						  EHEA_BCMC_VLANID_ALL;
 				arr[i++].macaddr = mc_entry->macaddr;
+				num_registrations -= 2;
 			}
 		}
 	}
@@ -296,6 +317,8 @@ out_update:
 	kfree(ehea_bcmc_regs.arr);
 	ehea_bcmc_regs.arr = arr;
 	ehea_bcmc_regs.num_entries = i;
+out:
+	spin_unlock_irqrestore(&ehea_bcmc_regs.lock, flags);
 }
 
 static struct net_device_stats *ehea_get_stats(struct net_device *dev)
@@ -1762,8 +1785,6 @@ static int ehea_set_mac_addr(struct net_device *dev, void *sa)
 
 	memcpy(dev->dev_addr, mac_addr->sa_data, dev->addr_len);
 
-	spin_lock(&ehea_bcmc_regs.lock);
-
 	/* Deregister old MAC in pHYP */
 	if (port->state == EHEA_PORT_UP) {
 		ret = ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
@@ -1784,7 +1805,6 @@ static int ehea_set_mac_addr(struct net_device *dev, void *sa)
 
 out_upregs:
 	ehea_update_bcmc_registrations();
-	spin_unlock(&ehea_bcmc_regs.lock);
 out_free:
 	free_page((unsigned long)cb0);
 out:
@@ -1946,8 +1966,6 @@ static void ehea_set_multicast_list(struct net_device *dev)
 	}
 	ehea_promiscuous(dev, 0);
 
-	spin_lock(&ehea_bcmc_regs.lock);
-
 	if (dev->flags & IFF_ALLMULTI) {
 		ehea_allmulti(dev, 1);
 		goto out;
@@ -1977,7 +1995,6 @@ static void ehea_set_multicast_list(struct net_device *dev)
 	}
 out:
 	ehea_update_bcmc_registrations();
-	spin_unlock(&ehea_bcmc_regs.lock);
 	return;
 }
 
@@ -2458,8 +2475,6 @@ static int ehea_up(struct net_device *dev)
 	if (port->state == EHEA_PORT_UP)
 		return 0;
 
-	mutex_lock(&ehea_fw_handles.lock);
-
 	ret = ehea_port_res_setup(port, port->num_def_qps,
 				  port->num_add_tx_qps);
 	if (ret) {
@@ -2496,8 +2511,6 @@ static int ehea_up(struct net_device *dev)
 		}
 	}
 
-	spin_lock(&ehea_bcmc_regs.lock);
-
 	ret = ehea_broadcast_reg_helper(port, H_REG_BCMC);
 	if (ret) {
 		ret = -EIO;
@@ -2519,10 +2532,7 @@ out:
 		ehea_info("Failed starting %s. ret=%i", dev->name, ret);
 
 	ehea_update_bcmc_registrations();
-	spin_unlock(&ehea_bcmc_regs.lock);
-
 	ehea_update_firmware_handles();
-	mutex_unlock(&ehea_fw_handles.lock);
 
 	return ret;
 }
@@ -2572,9 +2582,6 @@ static int ehea_down(struct net_device *dev)
 	if (port->state == EHEA_PORT_DOWN)
 		return 0;
 
-	mutex_lock(&ehea_fw_handles.lock);
-
-	spin_lock(&ehea_bcmc_regs.lock);
 	ehea_drop_multicast_list(dev);
 	ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
 
@@ -2583,7 +2590,6 @@ static int ehea_down(struct net_device *dev)
 	port->state = EHEA_PORT_DOWN;
 
 	ehea_update_bcmc_registrations();
-	spin_unlock(&ehea_bcmc_regs.lock);
 
 	ret = ehea_clean_all_portres(port);
 	if (ret)
@@ -2591,7 +2597,6 @@ static int ehea_down(struct net_device *dev)
 			  dev->name, ret);
 
 	ehea_update_firmware_handles();
-	mutex_unlock(&ehea_fw_handles.lock);
 
 	return ret;
 }
@@ -3368,7 +3373,6 @@ static int __devinit ehea_probe_adapter(struct of_device *dev,
 		ehea_error("Invalid ibmebus device probed");
 		return -EINVAL;
 	}
-	mutex_lock(&ehea_fw_handles.lock);
 
 	adapter = kzalloc(sizeof(*adapter), GFP_KERNEL);
 	if (!adapter) {
@@ -3453,7 +3457,7 @@ out_free_ad:
 
 out:
 	ehea_update_firmware_handles();
-	mutex_unlock(&ehea_fw_handles.lock);
+
 	return ret;
 }
 
@@ -3472,8 +3476,6 @@ static int __devexit ehea_remove(struct of_device *dev)
 
 	flush_scheduled_work();
 
-	mutex_lock(&ehea_fw_handles.lock);
-
 	ibmebus_free_irq(adapter->neq->attr.ist1, adapter);
 	tasklet_kill(&adapter->neq_tasklet);
 
@@ -3483,7 +3485,6 @@ static int __devexit ehea_remove(struct of_device *dev)
 	kfree(adapter);
 
 	ehea_update_firmware_handles();
-	mutex_unlock(&ehea_fw_handles.lock);
 
 	return 0;
 }
@@ -3532,6 +3533,9 @@ static int ehea_mem_notifier(struct notifier_block *nb,
 	default:
 		break;
 	}
+
+	ehea_update_firmware_handles();
+
 	return NOTIFY_OK;
 }
 
-- 
1.5.5
