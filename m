From: akpm@linux-foundation.org
Subject: [patch 17/21] netdev: ehea: bcmc_regs semaphore to mutex
Date: Fri, 28 Mar 2008 14:41:28 -0700
Message-ID: <200803282141.m2SLfSG3011849@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	dwalker@mvista.com, raisch@de.ibm.com, themann@de.ibm.com,
	tklein@de.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58614 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757998AbYC1Vnj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 17:43:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Walker <dwalker@mvista.com>

Convert the ehea_bcmc_regs.lock to a mutex.

Signed-off-by: Daniel Walker <dwalker@mvista.com>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Christoph Raisch <raisch@de.ibm.com>
Cc: Jan-Bernd Themann <themann@de.ibm.com>
Cc: Thomas Klein <tklein@de.ibm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/ehea/ehea.h      |    2 +-
 drivers/net/ehea/ehea_main.c |   18 +++++++++---------
 2 files changed, 10 insertions(+), 10 deletions(-)

diff -puN drivers/net/ehea/ehea.h~net-ehea-bcmc_regs-semaphore-to-mutex drivers/net/ehea/ehea.h
--- a/drivers/net/ehea/ehea.h~net-ehea-bcmc_regs-semaphore-to-mutex
+++ a/drivers/net/ehea/ehea.h
@@ -434,7 +434,7 @@ struct ehea_bcmc_reg_entry {
 struct ehea_bcmc_reg_array {
 	struct ehea_bcmc_reg_entry *arr;
 	int num_entries;
-	struct semaphore lock;
+	struct mutex lock;
 };
 
 #define EHEA_PORT_UP 1
diff -puN drivers/net/ehea/ehea_main.c~net-ehea-bcmc_regs-semaphore-to-mutex drivers/net/ehea/ehea_main.c
--- a/drivers/net/ehea/ehea_main.c~net-ehea-bcmc_regs-semaphore-to-mutex
+++ a/drivers/net/ehea/ehea_main.c
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
_
