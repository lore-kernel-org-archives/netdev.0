From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 12/20 v2] net/iucv: Convert to hotplug state machine
Date: Thu, 24 Nov 2016 15:14:15 +0100
Message-ID: <20161124141415.llqki5vo7nqdusqv@linutronix.de>
References: <20161117183541.8588-1-bigeasy@linutronix.de>
 <20161117183541.8588-13-bigeasy@linutronix.de>
 <62f8abea-093c-cac5-ffb1-7b8710aa0a91@linux.vnet.ibm.com>
 <20161124091046.hixy3j4ibt7xzezr@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, rt@linutronix.de,
        "David S. Miller" <davem@davemloft.net>,
        linux-s390@vger.kernel.org, netdev@vger.kernel.org
To: Ursula Braun <ubraun@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161124091046.hixy3j4ibt7xzezr@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Install the callbacks via the state machine and let the core invoke the
callbacks on the already online CPUs. The smp function calls in the
online/downprep callbacks are not required as the callback is guaranteed to
be invoked on the upcoming/outgoing cpu.

Cc: Ursula Braun <ubraun@linux.vnet.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: linux-s390@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
v1…v2: Use explicit labels for clean up in iucv_init() as suggested by
       Ursula.

 include/linux/cpuhotplug.h |    1 
 net/iucv/iucv.c            |  122 ++++++++++++++++-----------------------------
 2 files changed, 47 insertions(+), 76 deletions(-)

--- a/include/linux/cpuhotplug.h
+++ b/include/linux/cpuhotplug.h
@@ -63,6 +63,7 @@ enum cpuhp_state {
 	CPUHP_X86_THERM_PREPARE,
 	CPUHP_X86_CPUID_PREPARE,
 	CPUHP_X86_MSR_PREPARE,
+	CPUHP_NET_IUCV_PREPARE,
 	CPUHP_TIMERS_DEAD,
 	CPUHP_NOTF_ERR_INJ_PREPARE,
 	CPUHP_MIPS_SOC_PREPARE,
--- a/net/iucv/iucv.c
+++ b/net/iucv/iucv.c
@@ -639,7 +639,7 @@ static void iucv_disable(void)
 	put_online_cpus();
 }
 
-static void free_iucv_data(int cpu)
+static int iucv_cpu_dead(unsigned int cpu)
 {
 	kfree(iucv_param_irq[cpu]);
 	iucv_param_irq[cpu] = NULL;
@@ -647,9 +647,10 @@ static void free_iucv_data(int cpu)
 	iucv_param[cpu] = NULL;
 	kfree(iucv_irq_data[cpu]);
 	iucv_irq_data[cpu] = NULL;
+	return 0;
 }
 
-static int alloc_iucv_data(int cpu)
+static int iucv_cpu_prepare(unsigned int cpu)
 {
 	/* Note: GFP_DMA used to get memory below 2G */
 	iucv_irq_data[cpu] = kmalloc_node(sizeof(struct iucv_irq_data),
@@ -671,58 +672,38 @@ static int alloc_iucv_data(int cpu)
 	return 0;
 
 out_free:
-	free_iucv_data(cpu);
+	iucv_cpu_dead(cpu);
 	return -ENOMEM;
 }
 
-static int iucv_cpu_notify(struct notifier_block *self,
-				     unsigned long action, void *hcpu)
+static int iucv_cpu_online(unsigned int cpu)
+{
+	if (!iucv_path_table)
+		return 0;
+	iucv_declare_cpu(NULL);
+	return 0;
+}
+
+static int iucv_cpu_down_prep(unsigned int cpu)
 {
 	cpumask_t cpumask;
-	long cpu = (long) hcpu;
 
-	switch (action) {
-	case CPU_UP_PREPARE:
-	case CPU_UP_PREPARE_FROZEN:
-		if (alloc_iucv_data(cpu))
-			return notifier_from_errno(-ENOMEM);
-		break;
-	case CPU_UP_CANCELED:
-	case CPU_UP_CANCELED_FROZEN:
-	case CPU_DEAD:
-	case CPU_DEAD_FROZEN:
-		free_iucv_data(cpu);
-		break;
-	case CPU_ONLINE:
-	case CPU_ONLINE_FROZEN:
-	case CPU_DOWN_FAILED:
-	case CPU_DOWN_FAILED_FROZEN:
-		if (!iucv_path_table)
-			break;
-		smp_call_function_single(cpu, iucv_declare_cpu, NULL, 1);
-		break;
-	case CPU_DOWN_PREPARE:
-	case CPU_DOWN_PREPARE_FROZEN:
-		if (!iucv_path_table)
-			break;
-		cpumask_copy(&cpumask, &iucv_buffer_cpumask);
-		cpumask_clear_cpu(cpu, &cpumask);
-		if (cpumask_empty(&cpumask))
-			/* Can't offline last IUCV enabled cpu. */
-			return notifier_from_errno(-EINVAL);
-		smp_call_function_single(cpu, iucv_retrieve_cpu, NULL, 1);
-		if (cpumask_empty(&iucv_irq_cpumask))
-			smp_call_function_single(
-				cpumask_first(&iucv_buffer_cpumask),
-				iucv_allow_cpu, NULL, 1);
-		break;
-	}
-	return NOTIFY_OK;
-}
+	if (!iucv_path_table)
+		return 0;
 
-static struct notifier_block __refdata iucv_cpu_notifier = {
-	.notifier_call = iucv_cpu_notify,
-};
+	cpumask_copy(&cpumask, &iucv_buffer_cpumask);
+	cpumask_clear_cpu(cpu, &cpumask);
+	if (cpumask_empty(&cpumask))
+		/* Can't offline last IUCV enabled cpu. */
+		return -EINVAL;
+
+	iucv_retrieve_cpu(NULL);
+	if (!cpumask_empty(&iucv_irq_cpumask))
+		return 0;
+	smp_call_function_single(cpumask_first(&iucv_buffer_cpumask),
+				 iucv_allow_cpu, NULL, 1);
+	return 0;
+}
 
 /**
  * iucv_sever_pathid
@@ -2027,6 +2008,7 @@ struct iucv_interface iucv_if = {
 };
 EXPORT_SYMBOL(iucv_if);
 
+static enum cpuhp_state iucv_online;
 /**
  * iucv_init
  *
@@ -2035,7 +2017,6 @@ EXPORT_SYMBOL(iucv_if);
 static int __init iucv_init(void)
 {
 	int rc;
-	int cpu;
 
 	if (!MACHINE_IS_VM) {
 		rc = -EPROTONOSUPPORT;
@@ -2054,23 +2035,19 @@ static int __init iucv_init(void)
 		goto out_int;
 	}
 
-	cpu_notifier_register_begin();
-
-	for_each_online_cpu(cpu) {
-		if (alloc_iucv_data(cpu)) {
-			rc = -ENOMEM;
-			goto out_free;
-		}
-	}
-	rc = __register_hotcpu_notifier(&iucv_cpu_notifier);
+	rc = cpuhp_setup_state(CPUHP_NET_IUCV_PREPARE, "net/iucv:prepare",
+			       iucv_cpu_prepare, iucv_cpu_dead);
 	if (rc)
-		goto out_free;
-
-	cpu_notifier_register_done();
+		goto out_dev;
+	rc = cpuhp_setup_state(CPUHP_AP_ONLINE_DYN, "net/iucv:online",
+			       iucv_cpu_online, iucv_cpu_down_prep);
+	if (rc < 0)
+		goto out_prep;
+	iucv_online = rc;
 
 	rc = register_reboot_notifier(&iucv_reboot_notifier);
 	if (rc)
-		goto out_cpu;
+		goto out_remove_hp;
 	ASCEBC(iucv_error_no_listener, 16);
 	ASCEBC(iucv_error_no_memory, 16);
 	ASCEBC(iucv_error_pathid, 16);
@@ -2084,15 +2061,11 @@ static int __init iucv_init(void)
 
 out_reboot:
 	unregister_reboot_notifier(&iucv_reboot_notifier);
-out_cpu:
-	cpu_notifier_register_begin();
-	__unregister_hotcpu_notifier(&iucv_cpu_notifier);
-out_free:
-	for_each_possible_cpu(cpu)
-		free_iucv_data(cpu);
-
-	cpu_notifier_register_done();
-
+out_remove_hp:
+	cpuhp_remove_state(iucv_online);
+out_prep:
+	cpuhp_remove_state(CPUHP_NET_IUCV_PREPARE);
+out_dev:
 	root_device_unregister(iucv_root);
 out_int:
 	unregister_external_irq(EXT_IRQ_IUCV, iucv_external_interrupt);
@@ -2110,7 +2083,6 @@ static int __init iucv_init(void)
 static void __exit iucv_exit(void)
 {
 	struct iucv_irq_list *p, *n;
-	int cpu;
 
 	spin_lock_irq(&iucv_queue_lock);
 	list_for_each_entry_safe(p, n, &iucv_task_queue, list)
@@ -2119,11 +2091,9 @@ static void __exit iucv_exit(void)
 		kfree(p);
 	spin_unlock_irq(&iucv_queue_lock);
 	unregister_reboot_notifier(&iucv_reboot_notifier);
-	cpu_notifier_register_begin();
-	__unregister_hotcpu_notifier(&iucv_cpu_notifier);
-	for_each_possible_cpu(cpu)
-		free_iucv_data(cpu);
-	cpu_notifier_register_done();
+
+	cpuhp_remove_state_nocalls(iucv_online);
+	cpuhp_remove_state(CPUHP_NET_IUCV_PREPARE);
 	root_device_unregister(iucv_root);
 	bus_unregister(&iucv_bus);
 	unregister_external_irq(EXT_IRQ_IUCV, iucv_external_interrupt);
