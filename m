From: akpm@linux-foundation.org
Subject: [patch 14/21] netdev: ehea: semaphore to mutex
Date: Fri, 28 Mar 2008 14:41:26 -0700
Message-ID: <200803282141.m2SLfQuG011840@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	dwalker@mvista.com, raisch@de.ibm.com, themann@de.ibm.com,
	tklein@de.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38402 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751277AbYC1Vqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 17:46:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Walker <dwalker@mvista.com>

Converted the dlpar_mem_lock.  With a bit of cleanup, I converted to
DEFINE_MUTEX() instead of a runtime init.  I also made the lock static.

Signed-off-by: Daniel Walker <dwalker@mvista.com>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Christoph Raisch <raisch@de.ibm.com>
Acked-by: Jan-Bernd Themann <themann@de.ibm.com>
Cc: Thomas Klein <tklein@de.ibm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/ehea/ehea_main.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff -puN drivers/net/ehea/ehea_main.c~net-ehea-semaphore-to-mutex drivers/net/ehea/ehea_main.c
--- a/drivers/net/ehea/ehea_main.c~net-ehea-semaphore-to-mutex
+++ a/drivers/net/ehea/ehea_main.c
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
 
_
