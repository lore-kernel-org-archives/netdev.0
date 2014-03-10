From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v3 52/52] net/iucv/iucv.c: Fix CPU hotplug callback
 registration
Date: Tue, 11 Mar 2014 02:12:57 +0530
Message-ID: <20140310204257.10746.50242.stgit@srivatsabhat.in.ibm.com>
References: <20140310203312.10746.310.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, tj@kernel.org, walken@google.com,
	ego@linux.vnet.ibm.com, linux@arm.linux.org.uk,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-pm@vger.kernel.org, linuxppc-dev@ozlabs.org,
	srivatsa.bhat@linux.vnet.ibm.com,
	Ursula Braun <ursula.braun@de.ibm.com>,
	Ingo Molnar <mingo@kernel.org>, linux-s390@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	"Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
To: paulus@samba.org, oleg@redhat.com, mingo@kernel.org,
	rjw@rjwysocki.net, rusty@rustcorp.com.au, peterz@infradead.org,
	tglx@linutronix.de, akpm@linux-foundation.org
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20140310203312.10746.310.stgit@srivatsabhat.in.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subsystems that want to register CPU hotplug callbacks, as well as perform
initialization for the CPUs that are already online, often do it as shown
below:

	get_online_cpus();

	for_each_online_cpu(cpu)
		init_cpu(cpu);

	register_cpu_notifier(&foobar_cpu_notifier);

	put_online_cpus();

This is wrong, since it is prone to ABBA deadlocks involving the
cpu_add_remove_lock and the cpu_hotplug.lock (when running concurrently
with CPU hotplug operations).

Instead, the correct and race-free way of performing the callback
registration is:

	cpu_notifier_register_begin();

	for_each_online_cpu(cpu)
		init_cpu(cpu);

	/* Note the use of the double underscored version of the API */
	__register_cpu_notifier(&foobar_cpu_notifier);

	cpu_notifier_register_done();


Fix the code in net/iucv/iucv.c by using this latter form of callback
registration. Also, provide helper functions to perform the common memory
allocations and frees, to condense repetitive code.

Cc: Ursula Braun <ursula.braun@de.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: linux-s390@vger.kernel.org
Cc: netdev@vger.kernel.org
Acked-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 net/iucv/iucv.c |  121 ++++++++++++++++++++++++++-----------------------------
 1 file changed, 57 insertions(+), 64 deletions(-)

diff --git a/net/iucv/iucv.c b/net/iucv/iucv.c
index cd5b8ec..79a0ce9 100644
--- a/net/iucv/iucv.c
+++ b/net/iucv/iucv.c
@@ -621,6 +621,42 @@ static void iucv_disable(void)
 	put_online_cpus();
 }
 
+static void free_iucv_data(int cpu)
+{
+	kfree(iucv_param_irq[cpu]);
+	iucv_param_irq[cpu] = NULL;
+	kfree(iucv_param[cpu]);
+	iucv_param[cpu] = NULL;
+	kfree(iucv_irq_data[cpu]);
+	iucv_irq_data[cpu] = NULL;
+}
+
+static int alloc_iucv_data(int cpu)
+{
+	/* Note: GFP_DMA used to get memory below 2G */
+	iucv_irq_data[cpu] = kmalloc_node(sizeof(struct iucv_irq_data),
+			     GFP_KERNEL|GFP_DMA, cpu_to_node(cpu));
+	if (!iucv_irq_data[cpu])
+		goto out_free;
+
+	/* Allocate parameter blocks. */
+	iucv_param[cpu] = kmalloc_node(sizeof(union iucv_param),
+			  GFP_KERNEL|GFP_DMA, cpu_to_node(cpu));
+	if (!iucv_param[cpu])
+		goto out_free;
+
+	iucv_param_irq[cpu] = kmalloc_node(sizeof(union iucv_param),
+			  GFP_KERNEL|GFP_DMA, cpu_to_node(cpu));
+	if (!iucv_param_irq[cpu])
+		goto out_free;
+
+	return 0;
+
+out_free:
+	free_iucv_data(cpu);
+	return -ENOMEM;
+}
+
 static int iucv_cpu_notify(struct notifier_block *self,
 				     unsigned long action, void *hcpu)
 {
@@ -630,38 +666,14 @@ static int iucv_cpu_notify(struct notifier_block *self,
 	switch (action) {
 	case CPU_UP_PREPARE:
 	case CPU_UP_PREPARE_FROZEN:
-		iucv_irq_data[cpu] = kmalloc_node(sizeof(struct iucv_irq_data),
-					GFP_KERNEL|GFP_DMA, cpu_to_node(cpu));
-		if (!iucv_irq_data[cpu])
-			return notifier_from_errno(-ENOMEM);
-
-		iucv_param[cpu] = kmalloc_node(sizeof(union iucv_param),
-				     GFP_KERNEL|GFP_DMA, cpu_to_node(cpu));
-		if (!iucv_param[cpu]) {
-			kfree(iucv_irq_data[cpu]);
-			iucv_irq_data[cpu] = NULL;
+		if (alloc_iucv_data(cpu))
 			return notifier_from_errno(-ENOMEM);
-		}
-		iucv_param_irq[cpu] = kmalloc_node(sizeof(union iucv_param),
-					GFP_KERNEL|GFP_DMA, cpu_to_node(cpu));
-		if (!iucv_param_irq[cpu]) {
-			kfree(iucv_param[cpu]);
-			iucv_param[cpu] = NULL;
-			kfree(iucv_irq_data[cpu]);
-			iucv_irq_data[cpu] = NULL;
-			return notifier_from_errno(-ENOMEM);
-		}
 		break;
 	case CPU_UP_CANCELED:
 	case CPU_UP_CANCELED_FROZEN:
 	case CPU_DEAD:
 	case CPU_DEAD_FROZEN:
-		kfree(iucv_param_irq[cpu]);
-		iucv_param_irq[cpu] = NULL;
-		kfree(iucv_param[cpu]);
-		iucv_param[cpu] = NULL;
-		kfree(iucv_irq_data[cpu]);
-		iucv_irq_data[cpu] = NULL;
+		free_iucv_data(cpu);
 		break;
 	case CPU_ONLINE:
 	case CPU_ONLINE_FROZEN:
@@ -2025,33 +2037,20 @@ static int __init iucv_init(void)
 		goto out_int;
 	}
 
-	for_each_online_cpu(cpu) {
-		/* Note: GFP_DMA used to get memory below 2G */
-		iucv_irq_data[cpu] = kmalloc_node(sizeof(struct iucv_irq_data),
-				     GFP_KERNEL|GFP_DMA, cpu_to_node(cpu));
-		if (!iucv_irq_data[cpu]) {
-			rc = -ENOMEM;
-			goto out_free;
-		}
+	cpu_notifier_register_begin();
 
-		/* Allocate parameter blocks. */
-		iucv_param[cpu] = kmalloc_node(sizeof(union iucv_param),
-				  GFP_KERNEL|GFP_DMA, cpu_to_node(cpu));
-		if (!iucv_param[cpu]) {
-			rc = -ENOMEM;
-			goto out_free;
-		}
-		iucv_param_irq[cpu] = kmalloc_node(sizeof(union iucv_param),
-				  GFP_KERNEL|GFP_DMA, cpu_to_node(cpu));
-		if (!iucv_param_irq[cpu]) {
+	for_each_online_cpu(cpu) {
+		if (alloc_iucv_data(cpu)) {
 			rc = -ENOMEM;
 			goto out_free;
 		}
-
 	}
-	rc = register_hotcpu_notifier(&iucv_cpu_notifier);
+	rc = __register_hotcpu_notifier(&iucv_cpu_notifier);
 	if (rc)
 		goto out_free;
+
+	cpu_notifier_register_done();
+
 	rc = register_reboot_notifier(&iucv_reboot_notifier);
 	if (rc)
 		goto out_cpu;
@@ -2069,16 +2068,14 @@ static int __init iucv_init(void)
 out_reboot:
 	unregister_reboot_notifier(&iucv_reboot_notifier);
 out_cpu:
-	unregister_hotcpu_notifier(&iucv_cpu_notifier);
+	cpu_notifier_register_begin();
+	__unregister_hotcpu_notifier(&iucv_cpu_notifier);
 out_free:
-	for_each_possible_cpu(cpu) {
-		kfree(iucv_param_irq[cpu]);
-		iucv_param_irq[cpu] = NULL;
-		kfree(iucv_param[cpu]);
-		iucv_param[cpu] = NULL;
-		kfree(iucv_irq_data[cpu]);
-		iucv_irq_data[cpu] = NULL;
-	}
+	for_each_possible_cpu(cpu)
+		free_iucv_data(cpu);
+
+	cpu_notifier_register_done();
+
 	root_device_unregister(iucv_root);
 out_int:
 	unregister_external_interrupt(0x4000, iucv_external_interrupt);
@@ -2105,15 +2102,11 @@ static void __exit iucv_exit(void)
 		kfree(p);
 	spin_unlock_irq(&iucv_queue_lock);
 	unregister_reboot_notifier(&iucv_reboot_notifier);
-	unregister_hotcpu_notifier(&iucv_cpu_notifier);
-	for_each_possible_cpu(cpu) {
-		kfree(iucv_param_irq[cpu]);
-		iucv_param_irq[cpu] = NULL;
-		kfree(iucv_param[cpu]);
-		iucv_param[cpu] = NULL;
-		kfree(iucv_irq_data[cpu]);
-		iucv_irq_data[cpu] = NULL;
-	}
+	cpu_notifier_register_begin();
+	__unregister_hotcpu_notifier(&iucv_cpu_notifier);
+	for_each_possible_cpu(cpu)
+		free_iucv_data(cpu);
+	cpu_notifier_register_done();
 	root_device_unregister(iucv_root);
 	bus_unregister(&iucv_bus);
 	unregister_external_interrupt(0x4000, iucv_external_interrupt);
