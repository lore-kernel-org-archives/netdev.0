From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 1/4] [PATCH] iucv: add work_queue cleanup for suspend
Date: Fri, 13 Nov 2009 08:46:27 +0100
Message-ID: <20091113075050.470146000@linux.vnet.ibm.com>
References: <20091113074626.078348000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.17.166]:43510 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752530AbZKMHuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 02:50:46 -0500
Content-Disposition: inline; filename=603-iucv-suspend-cleanup.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

If iucv_work_queue is not empty during kernel freeze, a kernel panic
occurs. This suspend-patch adds flushing of the work queue for
pending connection requests and severing of remaining pending
connections.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 net/iucv/iucv.c |   16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

Index: linux-next-uschi/net/iucv/iucv.c
===================================================================
--- linux-next-uschi.orig/net/iucv/iucv.c
+++ linux-next-uschi/net/iucv/iucv.c
@@ -1768,7 +1768,6 @@ static void iucv_tasklet_fn(unsigned lon
  */
 static void iucv_work_fn(struct work_struct *work)
 {
-	typedef void iucv_irq_fn(struct iucv_irq_data *);
 	LIST_HEAD(work_queue);
 	struct iucv_irq_list *p, *n;
 
@@ -1878,14 +1877,25 @@ int iucv_path_table_empty(void)
 static int iucv_pm_freeze(struct device *dev)
 {
 	int cpu;
+	struct iucv_irq_list *p, *n;
 	int rc = 0;
 
 #ifdef CONFIG_PM_DEBUG
 	printk(KERN_WARNING "iucv_pm_freeze\n");
 #endif
+	if (iucv_pm_state != IUCV_PM_FREEZING) {
+		for_each_cpu_mask_nr(cpu, iucv_irq_cpumask)
+			smp_call_function_single(cpu, iucv_block_cpu_almost,
+						 NULL, 1);
+		cancel_work_sync(&iucv_work);
+		list_for_each_entry_safe(p, n, &iucv_work_queue, list) {
+			list_del_init(&p->list);
+			iucv_sever_pathid(p->data.ippathid,
+					  iucv_error_no_listener);
+			kfree(p);
+		}
+	}
 	iucv_pm_state = IUCV_PM_FREEZING;
-	for_each_cpu_mask_nr(cpu, iucv_irq_cpumask)
-		smp_call_function_single(cpu, iucv_block_cpu_almost, NULL, 1);
 	if (dev->driver && dev->driver->pm && dev->driver->pm->freeze)
 		rc = dev->driver->pm->freeze(dev);
 	if (iucv_path_table_empty())

