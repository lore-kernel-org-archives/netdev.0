From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 12/20] net/iucv: Convert to hotplug state machine
Date: Thu, 17 Nov 2016 19:35:33 +0100
Message-ID: <20161117183541.8588-13-bigeasy@linutronix.de>
References: <20161117183541.8588-1-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Cc: rt@linuxtronix.de,
        Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-s390@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161117183541.8588-1-bigeasy@linutronix.de>
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
 include/linux/cpuhotplug.h |   1 +
 net/iucv/iucv.c            | 118 +++++++++++++++++------------------------=
----
 2 files changed, 45 insertions(+), 74 deletions(-)

diff --git a/include/linux/cpuhotplug.h b/include/linux/cpuhotplug.h
index fd5598b8353a..69abf2c09f6c 100644
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
diff --git a/net/iucv/iucv.c b/net/iucv/iucv.c
index 88a2a3ba4212..f0d6afc5d4a9 100644
--- a/net/iucv/iucv.c
+++ b/net/iucv/iucv.c
@@ -639,7 +639,7 @@ static void iucv_disable(void)
 	put_online_cpus();
 }
=20
-static void free_iucv_data(int cpu)
+static int iucv_cpu_dead(unsigned int cpu)
 {
 	kfree(iucv_param_irq[cpu]);
 	iucv_param_irq[cpu] =3D NULL;
@@ -647,9 +647,10 @@ static void free_iucv_data(int cpu)
 	iucv_param[cpu] =3D NULL;
 	kfree(iucv_irq_data[cpu]);
 	iucv_irq_data[cpu] =3D NULL;
+	return 0;
 }
=20
-static int alloc_iucv_data(int cpu)
+static int iucv_cpu_prepare(unsigned int cpu)
 {
 	/* Note: GFP_DMA used to get memory below 2G */
 	iucv_irq_data[cpu] =3D kmalloc_node(sizeof(struct iucv_irq_data),
@@ -671,58 +672,38 @@ static int alloc_iucv_data(int cpu)
 	return 0;
=20
 out_free:
-	free_iucv_data(cpu);
+	iucv_cpu_dead(cpu);
 	return -ENOMEM;
 }
=20
-static int iucv_cpu_notify(struct notifier_block *self,
-				     unsigned long action, void *hcpu)
+static int iucv_cpu_online(unsigned int cpu)
 {
-	cpumask_t cpumask;
-	long cpu =3D (long) hcpu;
-
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
+	if (!iucv_path_table)
+		return 0;
+	iucv_declare_cpu(NULL);
+	return 0;
 }
=20
-static struct notifier_block __refdata iucv_cpu_notifier =3D {
-	.notifier_call =3D iucv_cpu_notify,
-};
+static int iucv_cpu_down_prep(unsigned int cpu)
+{
+	cpumask_t cpumask;
+
+	if (!iucv_path_table)
+		return 0;
+
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
=20
 /**
  * iucv_sever_pathid
@@ -2027,6 +2008,7 @@ struct iucv_interface iucv_if =3D {
 };
 EXPORT_SYMBOL(iucv_if);
=20
+static enum cpuhp_state iucv_online;
 /**
  * iucv_init
  *
@@ -2035,7 +2017,6 @@ EXPORT_SYMBOL(iucv_if);
 static int __init iucv_init(void)
 {
 	int rc;
-	int cpu;
=20
 	if (!MACHINE_IS_VM) {
 		rc =3D -EPROTONOSUPPORT;
@@ -2054,23 +2035,19 @@ static int __init iucv_init(void)
 		goto out_int;
 	}
=20
-	cpu_notifier_register_begin();
-
-	for_each_online_cpu(cpu) {
-		if (alloc_iucv_data(cpu)) {
-			rc =3D -ENOMEM;
-			goto out_free;
-		}
-	}
-	rc =3D __register_hotcpu_notifier(&iucv_cpu_notifier);
+	rc =3D cpuhp_setup_state(CPUHP_NET_IUCV_PREPARE, "net/iucv:prepare",
+			       iucv_cpu_prepare, iucv_cpu_dead);
 	if (rc)
 		goto out_free;
-
-	cpu_notifier_register_done();
+	rc =3D cpuhp_setup_state(CPUHP_AP_ONLINE_DYN, "net/iucv:online",
+			       iucv_cpu_online, iucv_cpu_down_prep);
+	if (rc < 0)
+		goto out_free;
+	iucv_online =3D rc;
=20
 	rc =3D register_reboot_notifier(&iucv_reboot_notifier);
 	if (rc)
-		goto out_cpu;
+		goto out_free;
 	ASCEBC(iucv_error_no_listener, 16);
 	ASCEBC(iucv_error_no_memory, 16);
 	ASCEBC(iucv_error_pathid, 16);
@@ -2084,14 +2061,10 @@ static int __init iucv_init(void)
=20
 out_reboot:
 	unregister_reboot_notifier(&iucv_reboot_notifier);
-out_cpu:
-	cpu_notifier_register_begin();
-	__unregister_hotcpu_notifier(&iucv_cpu_notifier);
 out_free:
-	for_each_possible_cpu(cpu)
-		free_iucv_data(cpu);
-
-	cpu_notifier_register_done();
+	if (iucv_online)
+		cpuhp_remove_state(iucv_online);
+	cpuhp_remove_state(CPUHP_NET_IUCV_PREPARE);
=20
 	root_device_unregister(iucv_root);
 out_int:
@@ -2110,7 +2083,6 @@ static int __init iucv_init(void)
 static void __exit iucv_exit(void)
 {
 	struct iucv_irq_list *p, *n;
-	int cpu;
=20
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
--=20
2.10.2
