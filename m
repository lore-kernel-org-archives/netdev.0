From: frank.blaschka@de.ibm.com
Subject: [patch 9/9] [PATCH] convert old cpumask API into new one
Date: Tue, 10 May 2011 13:50:22 +0200
Message-ID: <20110510115047.976954248@de.ibm.com>
References: <20110510115013.363974020@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([194.196.100.163]:55172 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755718Ab1EJLuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 07:50:50 -0400
Content-Disposition: inline; filename=608-cpumask-api.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Adapt new API.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---


 net/iucv/iucv.c |   73 ++++++++++++++++++++++++++++----------------------------
 1 file changed, 37 insertions(+), 36 deletions(-)
diff -urpN linux-2.6/net/iucv/iucv.c linux-2.6-patched/net/iucv/iucv.c
--- linux-2.6/net/iucv/iucv.c	2011-05-10 09:14:27.000000000 +0200
+++ linux-2.6-patched/net/iucv/iucv.c	2011-05-10 09:14:27.000000000 +0200
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
@@ -451,7 +451,7 @@ static void iucv_block_cpu_almost(void *
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
@@ -520,7 +520,7 @@ static void iucv_retrieve_cpu(void *data
 	int cpu = smp_processor_id();
 	union iucv_param *parm;
 
-	if (!cpu_isset(cpu, iucv_buffer_cpumask))
+	if (!cpumask_test_cpu(cpu, &iucv_buffer_cpumask))
 		return;
 
 	/* Block iucv interrupts. */
@@ -531,7 +531,7 @@ static void iucv_retrieve_cpu(void *data
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
@@ -675,15 +675,16 @@ static int __cpuinit iucv_cpu_notify(str
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
-						 iucv_allow_cpu, NULL, 1);
+		if (cpumask_empty(&iucv_irq_cpumask))
+			smp_call_function_single(
+				cpumask_first(&iucv_buffer_cpumask),
+				iucv_allow_cpu, NULL, 1);
 		break;
 	}
 	return NOTIFY_OK;
@@ -866,7 +867,7 @@ int iucv_path_accept(struct iucv_path *p
 	int rc;
 
 	local_bh_disable();
-	if (cpus_empty(iucv_buffer_cpumask)) {
+	if (cpumask_empty(&iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -915,7 +916,7 @@ int iucv_path_connect(struct iucv_path *
 
 	spin_lock_bh(&iucv_table_lock);
 	iucv_cleanup_queue();
-	if (cpus_empty(iucv_buffer_cpumask)) {
+	if (cpumask_empty(&iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -975,7 +976,7 @@ int iucv_path_quiesce(struct iucv_path *
 	int rc;
 
 	local_bh_disable();
-	if (cpus_empty(iucv_buffer_cpumask)) {
+	if (cpumask_empty(&iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -1007,7 +1008,7 @@ int iucv_path_resume(struct iucv_path *p
 	int rc;
 
 	local_bh_disable();
-	if (cpus_empty(iucv_buffer_cpumask)) {
+	if (cpumask_empty(&iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -1036,7 +1037,7 @@ int iucv_path_sever(struct iucv_path *pa
 	int rc;
 
 	preempt_disable();
-	if (cpus_empty(iucv_buffer_cpumask)) {
+	if (cpumask_empty(&iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -1070,7 +1071,7 @@ int iucv_message_purge(struct iucv_path
 	int rc;
 
 	local_bh_disable();
-	if (cpus_empty(iucv_buffer_cpumask)) {
+	if (cpumask_empty(&iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -1162,7 +1163,7 @@ int __iucv_message_receive(struct iucv_p
 	if (msg->flags & IUCV_IPRMDATA)
 		return iucv_message_receive_iprmdata(path, msg, flags,
 						     buffer, size, residual);
-	if (cpus_empty(iucv_buffer_cpumask)) {
+	 if (cpumask_empty(&iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -1235,7 +1236,7 @@ int iucv_message_reject(struct iucv_path
 	int rc;
 
 	local_bh_disable();
-	if (cpus_empty(iucv_buffer_cpumask)) {
+	if (cpumask_empty(&iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -1274,7 +1275,7 @@ int iucv_message_reply(struct iucv_path
 	int rc;
 
 	local_bh_disable();
-	if (cpus_empty(iucv_buffer_cpumask)) {
+	if (cpumask_empty(&iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -1324,7 +1325,7 @@ int __iucv_message_send(struct iucv_path
 	union iucv_param *parm;
 	int rc;
 
-	if (cpus_empty(iucv_buffer_cpumask)) {
+	if (cpumask_empty(&iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -1411,7 +1412,7 @@ int iucv_message_send2way(struct iucv_pa
 	int rc;
 
 	local_bh_disable();
-	if (cpus_empty(iucv_buffer_cpumask)) {
+	if (cpumask_empty(&iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -1888,7 +1889,7 @@ static int iucv_pm_freeze(struct device
 	printk(KERN_WARNING "iucv_pm_freeze\n");
 #endif
 	if (iucv_pm_state != IUCV_PM_FREEZING) {
-		for_each_cpu_mask_nr(cpu, iucv_irq_cpumask)
+		for_each_cpu(cpu, &iucv_irq_cpumask)
 			smp_call_function_single(cpu, iucv_block_cpu_almost,
 						 NULL, 1);
 		cancel_work_sync(&iucv_work);
@@ -1928,7 +1929,7 @@ static int iucv_pm_thaw(struct device *d
 		if (rc)
 			goto out;
 	}
-	if (cpus_empty(iucv_irq_cpumask)) {
+	if (cpumask_empty(&iucv_irq_cpumask)) {
 		if (iucv_nonsmp_handler)
 			/* enable interrupts on one cpu */
 			iucv_allow_cpu(NULL);
@@ -1961,7 +1962,7 @@ static int iucv_pm_restore(struct device
 		pr_warning("Suspending Linux did not completely close all IUCV "
 			"connections\n");
 	iucv_pm_state = IUCV_PM_RESTORING;
-	if (cpus_empty(iucv_irq_cpumask)) {
+	if (cpumask_empty(&iucv_irq_cpumask)) {
 		rc = iucv_query_maxconn();
 		rc = iucv_enable();
 		if (rc)

