From: Daniel Walker <dwalker@mvista.com>
Subject: [PATCH 1/5] net: ehea: semaphore to mutex
Date: Thu, 06 Mar 2008 00:00:01 -0800
Message-ID: <20080307032237.517704747@mvista.com>
Cc: Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:64442 "EHLO
	dwalker1.mvista.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932077AbYCGDcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 22:32:13 -0500
Content-Disposition: inline; filename=net-ehea-dlpar_mem_lock-semaphore-to-mutex.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Converted the dlpar_mem_lock. With a bit of cleanup, I converted to
DEFINE_MUTEX() instead of a runtime init. I also made the lock static.

Signed-off-by: Daniel Walker <dwalker@mvista.com>

---
 drivers/net/ehea/ehea_main.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: linux-2.6.24/drivers/net/ehea/ehea_main.c
===================================================================
--- linux-2.6.24.orig/drivers/net/ehea/ehea_main.c
+++ linux-2.6.24/drivers/net/ehea/ehea_main.c
@@ -36,6 +36,7 @@
 #include <linux/notifier.h>
 #include <linux/reboot.h>
 #include <asm/kexec.h>
+#include <linux/mutex.h>
 
 #include <net/ip.h>
 
@@ -99,7 +100,7 @@ static int port_name_cnt;
 static LIST_HEAD(adapter_list);
 u64 ehea_driver_flags;
 struct work_struct ehea_rereg_mr_task;
-struct semaphore dlpar_mem_lock;
+static DEFINE_MUTEX(dlpar_mem_lock);
 struct ehea_fw_handle_array ehea_fw_handles;
 struct ehea_bcmc_reg_array ehea_bcmc_regs;
 
@@ -2830,7 +2831,7 @@ static void ehea_rereg_mrs(struct work_s
 	int ret, i;
 	struct ehea_adapter *adapter;
 
-	down(&dlpar_mem_lock);
+	mutex_lock(&dlpar_mem_lock);
 	ehea_info("LPAR memory enlarged - re-initializing driver");
 
 	list_for_each_entry(adapter, &adapter_list, list)
@@ -2902,7 +2903,7 @@ static void ehea_rereg_mrs(struct work_s
 				}
 			}
 		}
-       up(&dlpar_mem_lock);
+       mutex_unlock(&dlpar_mem_lock);
        ehea_info("re-initializing driver complete");
 out:
 	return;
@@ -3543,7 +3544,6 @@ int __init ehea_module_init(void)
 	memset(&ehea_fw_handles, 0, sizeof(ehea_fw_handles));
 	memset(&ehea_bcmc_regs, 0, sizeof(ehea_bcmc_regs));
 
-	sema_init(&dlpar_mem_lock, 1);
 	sema_init(&ehea_fw_handles.lock, 1);
 	sema_init(&ehea_bcmc_regs.lock, 1);
 

-- 
