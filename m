From: Daniel Walker <dwalker@mvista.com>
Subject: [PATCH 4/5] net: ehea: bcmc_regs semaphore to mutex
Date: Thu, 06 Mar 2008 00:00:04 -0800
Message-ID: <20080307031633.576183680@mvista.com>
References: <20080307031621.590778480@mvista.com>
Cc: Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:63394 "EHLO
	dwalker1.mvista.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756808AbYCGD0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 22:26:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-- 
Content-Disposition: inline; filename=net-ehea-bcmc_regs-semaphore-to-mutex.patch

Convert the ehea_bcmb_regs.lock to a mutex.

Signed-off-by: Daniel Walker <dwalker@mvista.com>

---
 drivers/net/ehea/ehea.h      |    2 +-
 drivers/net/ehea/ehea_main.c |   18 +++++++++---------
 2 files changed, 10 insertions(+), 10 deletions(-)

Index: linux-2.6.24/drivers/net/ehea/ehea.h
===================================================================
--- linux-2.6.24.orig/drivers/net/ehea/ehea.h
+++ linux-2.6.24/drivers/net/ehea/ehea.h
@@ -434,7 +434,7 @@ struct ehea_bcmc_reg_entry {
 struct ehea_bcmc_reg_array {
 	struct ehea_bcmc_reg_entry *arr;
 	int num_entries;
-	struct semaphore lock;
+	struct mutex lock;
 };
 
 #define EHEA_PORT_UP 1
Index: linux-2.6.24/drivers/net/ehea/ehea_main.c
===================================================================
--- linux-2.6.24.orig/drivers/net/ehea/ehea_main.c
+++ linux-2.6.24/drivers/net/ehea/ehea_main.c
@@ -1759,7 +1759,7 @@ static int ehea_set_mac_addr(struct net_
 
 	memcpy(dev->dev_addr, mac_addr->sa_data, dev->addr_len);
 
-	down(&ehea_bcmc_regs.lock);
+	mutex_lock(&ehea_bcmc_regs.lock);
 
 	/* Deregister old MAC in pHYP */
 	ret = ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
@@ -1777,7 +1777,7 @@ static int ehea_set_mac_addr(struct net_
 
 out_upregs:
 	ehea_update_bcmc_registrations();
-	up(&ehea_bcmc_regs.lock);
+	mutex_unlock(&ehea_bcmc_regs.lock);
 out_free:
 	kfree(cb0);
 out:
@@ -1939,7 +1939,7 @@ static void ehea_set_multicast_list(stru
 	}
 	ehea_promiscuous(dev, 0);
 
-	down(&ehea_bcmc_regs.lock);
+	mutex_lock(&ehea_bcmc_regs.lock);
 
 	if (dev->flags & IFF_ALLMULTI) {
 		ehea_allmulti(dev, 1);
@@ -1970,7 +1970,7 @@ static void ehea_set_multicast_list(stru
 	}
 out:
 	ehea_update_bcmc_registrations();
-	up(&ehea_bcmc_regs.lock);
+	mutex_unlock(&ehea_bcmc_regs.lock);
 	return;
 }
 
@@ -2491,7 +2491,7 @@ static int ehea_up(struct net_device *de
 		}
 	}
 
-	down(&ehea_bcmc_regs.lock);
+	mutex_lock(&ehea_bcmc_regs.lock);
 
 	ret = ehea_broadcast_reg_helper(port, H_REG_BCMC);
 	if (ret) {
@@ -2514,7 +2514,7 @@ out:
 		ehea_info("Failed starting %s. ret=%i", dev->name, ret);
 
 	ehea_update_bcmc_registrations();
-	up(&ehea_bcmc_regs.lock);
+	mutex_unlock(&ehea_bcmc_regs.lock);
 
 	ehea_update_firmware_handles();
 	mutex_unlock(&ehea_fw_handles.lock);
@@ -2569,7 +2569,7 @@ static int ehea_down(struct net_device *
 
 	mutex_lock(&ehea_fw_handles.lock);
 
-	down(&ehea_bcmc_regs.lock);
+	mutex_lock(&ehea_bcmc_regs.lock);
 	ehea_drop_multicast_list(dev);
 	ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
 
@@ -2578,7 +2578,7 @@ static int ehea_down(struct net_device *
 	port->state = EHEA_PORT_DOWN;
 
 	ehea_update_bcmc_registrations();
-	up(&ehea_bcmc_regs.lock);
+	mutex_unlock(&ehea_bcmc_regs.lock);
 
 	ret = ehea_clean_all_portres(port);
 	if (ret)
@@ -3545,7 +3545,7 @@ int __init ehea_module_init(void)
 	memset(&ehea_bcmc_regs, 0, sizeof(ehea_bcmc_regs));
 
 	mutex_init(&ehea_fw_handles.lock);
-	sema_init(&ehea_bcmc_regs.lock, 1);
+	mutex_init(&ehea_bcmc_regs.lock);
 
 	ret = check_module_parm();
 	if (ret)

-- 
