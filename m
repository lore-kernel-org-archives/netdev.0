From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 1/7] [PATCH] iucv: suspend/resume error msg for left over pathes
Date: Wed, 16 Sep 2009 16:37:22 +0200
Message-ID: <20090916144304.145508000@linux.vnet.ibm.com>
References: <20090916143721.863799000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.17.162]:33787 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117AbZIPOnC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 10:43:02 -0400
Content-Disposition: inline; filename=600-iucv-pm-leftover.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

During suspend IUCV exploiters have to close their IUCV connections.
When restoring an image, it can be checked if all IUCV pathes had
been closed before the Linux instance was suspended. If not, an
error message is issued to indicate a problem in one of the
used programs exploiting IUCV communication.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 net/iucv/iucv.c |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff -urpN linux-2.6/net/iucv/iucv.c linux-2.6-patched/net/iucv/iucv.c
--- linux-2.6/net/iucv/iucv.c	2009-09-10 00:13:59.000000000 +0200
+++ linux-2.6-patched/net/iucv/iucv.c	2009-09-15 12:25:31.000000000 +0200
@@ -79,6 +79,14 @@ static int iucv_bus_match(struct device 
 	return 0;
 }
 
+enum iucv_pm_states {
+	IUCV_PM_INITIAL = 0,
+	IUCV_PM_FREEZING = 1,
+	IUCV_PM_THAWING = 2,
+	IUCV_PM_RESTORING = 3,
+};
+static enum iucv_pm_states iucv_pm_state;
+
 static int iucv_pm_prepare(struct device *);
 static void iucv_pm_complete(struct device *);
 static int iucv_pm_freeze(struct device *);
@@ -1875,6 +1883,7 @@ static int iucv_pm_freeze(struct device 
 #ifdef CONFIG_PM_DEBUG
 	printk(KERN_WARNING "iucv_pm_freeze\n");
 #endif
+	iucv_pm_state = IUCV_PM_FREEZING;
 	for_each_cpu_mask_nr(cpu, iucv_irq_cpumask)
 		smp_call_function_single(cpu, iucv_block_cpu_almost, NULL, 1);
 	if (dev->driver && dev->driver->pm && dev->driver->pm->freeze)
@@ -1899,6 +1908,7 @@ static int iucv_pm_thaw(struct device *d
 #ifdef CONFIG_PM_DEBUG
 	printk(KERN_WARNING "iucv_pm_thaw\n");
 #endif
+	iucv_pm_state = IUCV_PM_THAWING;
 	if (!iucv_path_table) {
 		rc = iucv_enable();
 		if (rc)
@@ -1933,6 +1943,10 @@ static int iucv_pm_restore(struct device
 #ifdef CONFIG_PM_DEBUG
 	printk(KERN_WARNING "iucv_pm_restore %p\n", iucv_path_table);
 #endif
+	if ((iucv_pm_state != IUCV_PM_RESTORING) && iucv_path_table)
+		pr_warning("Suspending Linux did not completely close all IUCV "
+			"connections\n");
+	iucv_pm_state = IUCV_PM_RESTORING;
 	if (cpus_empty(iucv_irq_cpumask)) {
 		rc = iucv_query_maxconn();
 		rc = iucv_enable();

