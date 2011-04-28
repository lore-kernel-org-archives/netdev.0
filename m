From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] s390, net: convert into new cpumask api
Date: Thu, 28 Apr 2011 23:59:25 +0900 (JST)
Message-ID: <20110429000104.3D5D.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: kosaki.motohiro@jp.fujitsu.com
To: LKML <linux-kernel@vger.kernel.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>,
	"David S. Miller
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:59311 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932882Ab1D1O72 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 10:59:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adapt new api.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Ursula Braun <ursula.braun@de.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: linux390@de.ibm.com
Cc: linux-s390@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 net/iucv/iucv.c |   70 +++++++++++++++++++++++++++---------------------------
 1 files changed, 35 insertions(+), 35 deletions(-)

diff --git a/net/iucv/iucv.c b/net/iucv/iucv.c
index 8f156bd..79f2caf 100644
--- a/net/iucv/iucv.c
+++ b/net/iucv/iucv.c
@@ -128,8 +128,8 @@ struct iucv_irq_list {
 };
 
 static struct iucv_irq_data *iucv_irq_data[NR_CPUS];
-static cpumask_t iucv_buffer_cpumask = CPU_MASK_NONE;
-static cpumask_t iucv_irq_cpumask = CPU_MASK_NONE;
+static cpumask_t iucv_buffer_cpumask = { CPU_BITS_NONE };
+static cpumask_t iucv_irq_cpumask = { CPU_BITS_NONE };
 
 /*
  * Queue of interrupt buffers lock for delivery via the tasklet
@@ -406,7 +406,7 @@ static void iucv_allow_cpu(void *data)
 	parm->set_mask.ipmask = 0xf8;
 	iucv_call_b2f0(IUCV_SETCONTROLMASK, parm);
 	/* Set indication that iucv interrupts are allowed for this cpu. */
-	cpu_set(cpu, iucv_irq_cpumask);
+	cpumask_set_cpu(cpu, &iucv_irq_cpumask);
 }
 
 /**
@@ -426,7 +426,7 @@ static void iucv_block_cpu(void *data)
 	iucv_call_b2f0(IUCV_SETMASK, parm);
 
 	/* Clear indication that iucv interrupts are allowed for this cpu. */
-	cpu_clear(cpu, iucv_irq_cpumask);
+	cpumask_clear_cpu(cpu, &iucv_irq_cpumask);
 }
 
 /**
@@ -451,7 +451,7 @@ static void iucv_block_cpu_almost(void *data)
 	iucv_call_b2f0(IUCV_SETCONTROLMASK, parm);
 
 	/* Clear indication that iucv interrupts are allowed for this cpu. */
-	cpu_clear(cpu, iucv_irq_cpumask);
+	cpumask_clear_cpu(cpu, &iucv_irq_cpumask);
 }
 
 /**
@@ -466,7 +466,7 @@ static void iucv_declare_cpu(void *data)
 	union iucv_param *parm;
 	int rc;
 
-	if (cpu_isset(cpu, iucv_buffer_cpumask))
+	if (cpumask_test_cpu(cpu, &iucv_buffer_cpumask))
 		return;
 
 	/* Declare interrupt buffer. */
@@ -499,9 +499,9 @@ static void iucv_declare_cpu(void *data)
 	}
 
 	/* Set indication that an iucv buffer exists for this cpu. */
-	cpu_set(cpu, iucv_buffer_cpumask);
+	cpumask_set_cpu(cpu, &iucv_buffer_cpumask);
 
-	if (iucv_nonsmp_handler == 0 || cpus_empty(iucv_irq_cpumask))
+	if (iucv_nonsmp_handler == 0 || cpumask_empty(&iucv_irq_cpumask))
 		/* Enable iucv interrupts on this cpu. */
 		iucv_allow_cpu(NULL);
 	else
@@ -520,7 +520,7 @@ static void iucv_retrieve_cpu(void *data)
 	int cpu = smp_processor_id();
 	union iucv_param *parm;
 
-	if (!cpu_isset(cpu, iucv_buffer_cpumask))
+	if (!cpumask_test_cpu(cpu, &iucv_buffer_cpumask))
 		return;
 
 	/* Block iucv interrupts. */
@@ -531,7 +531,7 @@ static void iucv_retrieve_cpu(void *data)
 	iucv_call_b2f0(IUCV_RETRIEVE_BUFFER, parm);
 
 	/* Clear indication that an iucv buffer exists for this cpu. */
-	cpu_clear(cpu, iucv_buffer_cpumask);
+	cpumask_clear_cpu(cpu, &iucv_buffer_cpumask);
 }
 
 /**
@@ -546,8 +546,8 @@ static void iucv_setmask_mp(void)
 	get_online_cpus();
 	for_each_online_cpu(cpu)
 		/* Enable all cpus with a declared buffer. */
-		if (cpu_isset(cpu, iucv_buffer_cpumask) &&
-		    !cpu_isset(cpu, iucv_irq_cpumask))
+		if (cpumask_test_cpu(cpu, &iucv_buffer_cpumask) &&
+		    !cpumask_test_cpu(cpu, &iucv_irq_cpumask))
 			smp_call_function_single(cpu, iucv_allow_cpu,
 						 NULL, 1);
 	put_online_cpus();
@@ -564,9 +564,9 @@ static void iucv_setmask_up(void)
 	int cpu;
 
 	/* Disable all cpu but the first in cpu_irq_cpumask. */
-	cpumask = iucv_irq_cpumask;
-	cpu_clear(first_cpu(iucv_irq_cpumask), cpumask);
-	for_each_cpu_mask_nr(cpu, cpumask)
+	cpumask_copy(&cpumask, &iucv_irq_cpumask);
+	cpumask_clear_cpu(cpumask_first(&iucv_irq_cpumask), &cpumask);
+	for_each_cpu(cpu, &cpumask)
 		smp_call_function_single(cpu, iucv_block_cpu, NULL, 1);
 }
 
@@ -593,7 +593,7 @@ static int iucv_enable(void)
 	rc = -EIO;
 	for_each_online_cpu(cpu)
 		smp_call_function_single(cpu, iucv_declare_cpu, NULL, 1);
-	if (cpus_empty(iucv_buffer_cpumask))
+	if (cpumask_empty(&iucv_buffer_cpumask))
 		/* No cpu could declare an iucv buffer. */
 		goto out;
 	put_online_cpus();
@@ -675,14 +675,14 @@ static int __cpuinit iucv_cpu_notify(struct notifier_block *self,
 	case CPU_DOWN_PREPARE_FROZEN:
 		if (!iucv_path_table)
 			break;
-		cpumask = iucv_buffer_cpumask;
-		cpu_clear(cpu, cpumask);
-		if (cpus_empty(cpumask))
+		cpumask_copy(&cpumask, &iucv_buffer_cpumask);
+		cpumask_clear_cpu(cpu, &cpumask);
+		if (cpumask_empty(&cpumask))
 			/* Can't offline last IUCV enabled cpu. */
 			return notifier_from_errno(-EINVAL);
 		smp_call_function_single(cpu, iucv_retrieve_cpu, NULL, 1);
-		if (cpus_empty(iucv_irq_cpumask))
-			smp_call_function_single(first_cpu(iucv_buffer_cpumask),
+		if (cpumask_empty(&iucv_irq_cpumask))
+			smp_call_function_single(cpumask_first(&iucv_buffer_cpumask),
 						 iucv_allow_cpu, NULL, 1);
 		break;
 	}
@@ -866,7 +866,7 @@ int iucv_path_accept(struct iucv_path *path, struct iucv_handler *handler,
 	int rc;
 
 	local_bh_disable();
-	if (cpus_empty(iucv_buffer_cpumask)) {
+	if (cpumask_empty(&iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -915,7 +915,7 @@ int iucv_path_connect(struct iucv_path *path, struct iucv_handler *handler,
 
 	spin_lock_bh(&iucv_table_lock);
 	iucv_cleanup_queue();
-	if (cpus_empty(iucv_buffer_cpumask)) {
+	if (cpumask_empty(&iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -975,7 +975,7 @@ int iucv_path_quiesce(struct iucv_path *path, u8 userdata[16])
 	int rc;
 
 	local_bh_disable();
-	if (cpus_empty(iucv_buffer_cpumask)) {
+	if (cpumask_empty(&iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -1007,7 +1007,7 @@ int iucv_path_resume(struct iucv_path *path, u8 userdata[16])
 	int rc;
 
 	local_bh_disable();
-	if (cpus_empty(iucv_buffer_cpumask)) {
+	if (cpumask_empty(&iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -1036,7 +1036,7 @@ int iucv_path_sever(struct iucv_path *path, u8 userdata[16])
 	int rc;
 
 	preempt_disable();
-	if (cpus_empty(iucv_buffer_cpumask)) {
+	if (cpumask_empty(&iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -1070,7 +1070,7 @@ int iucv_message_purge(struct iucv_path *path, struct iucv_message *msg,
 	int rc;
 
 	local_bh_disable();
-	if (cpus_empty(iucv_buffer_cpumask)) {
+	if (cpumask_empty(&iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -1162,7 +1162,7 @@ int __iucv_message_receive(struct iucv_path *path, struct iucv_message *msg,
 	if (msg->flags & IUCV_IPRMDATA)
 		return iucv_message_receive_iprmdata(path, msg, flags,
 						     buffer, size, residual);
-	if (cpus_empty(iucv_buffer_cpumask)) {
+	if (cpumask_empty(&iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -1235,7 +1235,7 @@ int iucv_message_reject(struct iucv_path *path, struct iucv_message *msg)
 	int rc;
 
 	local_bh_disable();
-	if (cpus_empty(iucv_buffer_cpumask)) {
+	if (cpumask_empty(&iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -1274,7 +1274,7 @@ int iucv_message_reply(struct iucv_path *path, struct iucv_message *msg,
 	int rc;
 
 	local_bh_disable();
-	if (cpus_empty(iucv_buffer_cpumask)) {
+	if (cpumask_empty(&iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -1324,7 +1324,7 @@ int __iucv_message_send(struct iucv_path *path, struct iucv_message *msg,
 	union iucv_param *parm;
 	int rc;
 
-	if (cpus_empty(iucv_buffer_cpumask)) {
+	if (cpumask_empty(&iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -1411,7 +1411,7 @@ int iucv_message_send2way(struct iucv_path *path, struct iucv_message *msg,
 	int rc;
 
 	local_bh_disable();
-	if (cpus_empty(iucv_buffer_cpumask)) {
+	if (cpumask_empty(&iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -1888,7 +1888,7 @@ static int iucv_pm_freeze(struct device *dev)
 	printk(KERN_WARNING "iucv_pm_freeze\n");
 #endif
 	if (iucv_pm_state != IUCV_PM_FREEZING) {
-		for_each_cpu_mask_nr(cpu, iucv_irq_cpumask)
+		for_each_cpu(cpu, &iucv_irq_cpumask)
 			smp_call_function_single(cpu, iucv_block_cpu_almost,
 						 NULL, 1);
 		cancel_work_sync(&iucv_work);
@@ -1928,7 +1928,7 @@ static int iucv_pm_thaw(struct device *dev)
 		if (rc)
 			goto out;
 	}
-	if (cpus_empty(iucv_irq_cpumask)) {
+	if (cpumask_empty(&iucv_irq_cpumask)) {
 		if (iucv_nonsmp_handler)
 			/* enable interrupts on one cpu */
 			iucv_allow_cpu(NULL);
@@ -1961,7 +1961,7 @@ static int iucv_pm_restore(struct device *dev)
 		pr_warning("Suspending Linux did not completely close all IUCV "
 			"connections\n");
 	iucv_pm_state = IUCV_PM_RESTORING;
-	if (cpus_empty(iucv_irq_cpumask)) {
+	if (cpumask_empty(&iucv_irq_cpumask)) {
 		rc = iucv_query_maxconn();
 		rc = iucv_enable();
 		if (rc)
-- 
1.7.3.1



