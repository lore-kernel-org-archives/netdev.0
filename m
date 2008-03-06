From: Daniel Walker <dwalker@mvista.com>
Subject: [PATCH 2/5] net: ehea: ehea_fw_handles semaphore to mutex
Date: Thu, 06 Mar 2008 00:00:02 -0800
Message-ID: <20080307031633.040677497@mvista.com>
References: <20080307031621.590778480@mvista.com>
Cc: Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:63397 "EHLO
	dwalker1.mvista.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757079AbYCGD0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 22:26:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-- 
Content-Disposition: inline; filename=net-ehea-fw_handles-semaphore-to-mutex.patch

Converted the ehea_fw_handles.lock to a mutex.

Signed-off-by: Daniel Walker <dwalker@mvista.com>

---
 drivers/net/ehea/ehea.h      |    2 +-
 drivers/net/ehea/ehea_main.c |   18 +++++++++---------
 2 files changed, 10 insertions(+), 10 deletions(-)

Index: linux-2.6.24/drivers/net/ehea/ehea.h
===================================================================
--- linux-2.6.24.orig/drivers/net/ehea/ehea.h
+++ linux-2.6.24/drivers/net/ehea/ehea.h
@@ -421,7 +421,7 @@ struct ehea_fw_handle_entry {
 struct ehea_fw_handle_array {
 	struct ehea_fw_handle_entry *arr;
 	int num_entries;
-	struct semaphore lock;
+	struct mutex lock;
 };
 
 struct ehea_bcmc_reg_entry {
Index: linux-2.6.24/drivers/net/ehea/ehea_main.c
===================================================================
--- linux-2.6.24.orig/drivers/net/ehea/ehea_main.c
+++ linux-2.6.24/drivers/net/ehea/ehea_main.c
@@ -2453,7 +2453,7 @@ static int ehea_up(struct net_device *de
 	if (port->state == EHEA_PORT_UP)
 		return 0;
 
-	down(&ehea_fw_handles.lock);
+	mutex_lock(&ehea_fw_handles.lock);
 
 	ret = ehea_port_res_setup(port, port->num_def_qps,
 				  port->num_add_tx_qps);
@@ -2517,7 +2517,7 @@ out:
 	up(&ehea_bcmc_regs.lock);
 
 	ehea_update_firmware_handles();
-	up(&ehea_fw_handles.lock);
+	mutex_unlock(&ehea_fw_handles.lock);
 
 	return ret;
 }
@@ -2573,7 +2573,7 @@ static int ehea_down(struct net_device *
 
 	ehea_free_interrupts(dev);
 
-	down(&ehea_fw_handles.lock);
+	mutex_lock(&ehea_fw_handles.lock);
 
 	port->state = EHEA_PORT_DOWN;
 
@@ -2586,7 +2586,7 @@ static int ehea_down(struct net_device *
 			  dev->name, ret);
 
 	ehea_update_firmware_handles();
-	up(&ehea_fw_handles.lock);
+	mutex_unlock(&ehea_fw_handles.lock);
 
 	return ret;
 }
@@ -3343,7 +3343,7 @@ static int __devinit ehea_probe_adapter(
 		ehea_error("Invalid ibmebus device probed");
 		return -EINVAL;
 	}
-	down(&ehea_fw_handles.lock);
+	mutex_lock(&ehea_fw_handles.lock);
 
 	adapter = kzalloc(sizeof(*adapter), GFP_KERNEL);
 	if (!adapter) {
@@ -3427,7 +3427,7 @@ out_free_ad:
 
 out:
 	ehea_update_firmware_handles();
-	up(&ehea_fw_handles.lock);
+	mutex_unlock(&ehea_fw_handles.lock);
 	return ret;
 }
 
@@ -3446,7 +3446,7 @@ static int __devexit ehea_remove(struct 
 
 	flush_scheduled_work();
 
-	down(&ehea_fw_handles.lock);
+	mutex_lock(&ehea_fw_handles.lock);
 
 	ibmebus_free_irq(adapter->neq->attr.ist1, adapter);
 	tasklet_kill(&adapter->neq_tasklet);
@@ -3457,7 +3457,7 @@ static int __devexit ehea_remove(struct 
 	kfree(adapter);
 
 	ehea_update_firmware_handles();
-	up(&ehea_fw_handles.lock);
+	mutex_unlock(&ehea_fw_handles.lock);
 
 	return 0;
 }
@@ -3544,7 +3544,7 @@ int __init ehea_module_init(void)
 	memset(&ehea_fw_handles, 0, sizeof(ehea_fw_handles));
 	memset(&ehea_bcmc_regs, 0, sizeof(ehea_bcmc_regs));
 
-	sema_init(&ehea_fw_handles.lock, 1);
+	mutex_init(&ehea_fw_handles.lock);
 	sema_init(&ehea_bcmc_regs.lock, 1);
 
 	ret = check_module_parm();

-- 
