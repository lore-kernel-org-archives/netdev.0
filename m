From: Rusty Russell <rusty@rustcorp.com.au>
Subject: net/core/flow.c cpu handling?
Date: Sun, 02 Nov 2003 17:22:55 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031102062345.A472E2C0CD@lists.samba.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: anton@samba.org, kuznet@ms2.inr.ac.ru, davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi again,

	Is there something I'm missing, or wouldn't the code in
net/core/flow.c be much simpler if:

1) flow_cache_cpu_prepare() were done for each possible cpu, not
   dynamically as they came up.

2) The cpucontrol lock is held in flow_cache_flush to guarantee that
   cpus don't go up and down.

3) The normal cpu_online_map were used instead of flow_cache_cpu_map.

The patch below is untested, but if you can't see anything wrong with
the approach, I'll test it.

Cheers,
Rusty.
--
  Anyone who quotes me in their sig is an idiot. -- Rusty Russell.

Name: Simplify CPU Handling in net/core/flow.c
Author: Rusty Russell
Status: Booted on 2.6.0-test9-bk6

D: The cpu handling in net/core/flow.c is flawed, because it uses an
D: unsigned long instead of a cpumask_t.  This replaces that code
D: with a much simpler version which allocates for every possible CPU,
D: (the same amount of work on most machines) and takes the cpucontrol
D: semaphore when flushing.

--- linux-2.6.0-test9-bk4/net/core/flow.c	2003-10-09 18:03:03.000000000 +1000
+++ working-2.6.0-test9-bk4-hotcpu-with-kthread/net/core/flow.c	2003-11-02 17:10:55.000000000 +1100
@@ -65,23 +65,18 @@
 
 struct flow_flush_info {
 	atomic_t cpuleft;
-	unsigned long cpumap;
 	struct completion completion;
 };
 static DEFINE_PER_CPU(struct tasklet_struct, flow_flush_tasklets) = { NULL };
 
 #define flow_flush_tasklet(cpu) (&per_cpu(flow_flush_tasklets, cpu))
 
-static DECLARE_MUTEX(flow_cache_cpu_sem);
-static unsigned long flow_cache_cpu_map;
-static unsigned int flow_cache_cpu_count;
-
 static void flow_cache_new_hashrnd(unsigned long arg)
 {
 	int i;
 
 	for (i = 0; i < NR_CPUS; i++)
-		if (test_bit(i, &flow_cache_cpu_map))
+		if (cpu_possible(i))
 			flow_hash_rnd_recalc(i) = 1;
 
 	flow_hash_rnd_timer.expires = jiffies + FLOW_HASH_RND_PERIOD;
@@ -178,7 +173,9 @@
 	cpu = smp_processor_id();
 
 	fle = NULL;
-	if (!test_bit(cpu, &flow_cache_cpu_map))
+	/* Packet really early in init?  Making flow_cache_init a
+	 * pre-smp initcall would solve this.  --RR */
+	if (!flow_table(cpu))
 		goto nocache;
 
 	if (flow_hash_rnd_recalc(cpu))
@@ -277,9 +274,6 @@
 	struct tasklet_struct *tasklet;
 
 	cpu = smp_processor_id();
-	if (!test_bit(cpu, &info->cpumap))
-		return;
-
 	tasklet = flow_flush_tasklet(cpu);
 	tasklet->data = (unsigned long)info;
 	tasklet_schedule(tasklet);
@@ -288,29 +282,23 @@
 void flow_cache_flush(void)
 {
 	struct flow_flush_info info;
-	static DECLARE_MUTEX(flow_flush_sem);
-
-	down(&flow_cache_cpu_sem);
-	info.cpumap = flow_cache_cpu_map;
-	atomic_set(&info.cpuleft, flow_cache_cpu_count);
-	up(&flow_cache_cpu_sem);
 
+	/* Don't want cpus going down or up during this, also protects
+	 * against multiple callers. */
+	down(&cpucontrol);
+	atomic_set(&info.cpuleft, num_online_cpus());
 	init_completion(&info.completion);
 
-	down(&flow_flush_sem);
-
 	local_bh_disable();
 	smp_call_function(flow_cache_flush_per_cpu, &info, 1, 0);
-	if (test_bit(smp_processor_id(), &info.cpumap))
-		flow_cache_flush_tasklet((unsigned long)&info);
+	flow_cache_flush_tasklet((unsigned long)&info);
 	local_bh_enable();
 
 	wait_for_completion(&info.completion);
-
-	up(&flow_flush_sem);
+	up(&cpucontrol);
 }
 
-static int __devinit flow_cache_cpu_prepare(int cpu)
+static void __devinit flow_cache_cpu_prepare(int cpu)
 {
 	struct tasklet_struct *tasklet;
 	unsigned long order;
@@ -323,9 +311,8 @@
 
 	flow_table(cpu) = (struct flow_cache_entry **)
 		__get_free_pages(GFP_KERNEL, order);
-
 	if (!flow_table(cpu))
-		return NOTIFY_BAD;
+		panic("NET: failed to allocate flow cache order %lu\n", order);
 
 	memset(flow_table(cpu), 0, PAGE_SIZE << order);
 
@@ -334,39 +321,8 @@
 
 	tasklet = flow_flush_tasklet(cpu);
 	tasklet_init(tasklet, flow_cache_flush_tasklet, 0);
-
-	return NOTIFY_OK;
-}
-
-static int __devinit flow_cache_cpu_online(int cpu)
-{
-	down(&flow_cache_cpu_sem);
-	set_bit(cpu, &flow_cache_cpu_map);
-	flow_cache_cpu_count++;
-	up(&flow_cache_cpu_sem);
-
-	return NOTIFY_OK;
-}
-
-static int __devinit flow_cache_cpu_notify(struct notifier_block *self,
-					   unsigned long action, void *hcpu)
-{
-	unsigned long cpu = (unsigned long)cpu;
-	switch (action) {
-	case CPU_UP_PREPARE:
-		return flow_cache_cpu_prepare(cpu);
-		break;
-	case CPU_ONLINE:
-		return flow_cache_cpu_online(cpu);
-		break;
-	}
-	return NOTIFY_OK;
 }
 
-static struct notifier_block __devinitdata flow_cache_cpu_nb = {
-	.notifier_call = flow_cache_cpu_notify,
-};
-
 static int __init flow_cache_init(void)
 {
 	int i;
@@ -388,15 +344,9 @@
 	flow_hash_rnd_timer.expires = jiffies + FLOW_HASH_RND_PERIOD;
 	add_timer(&flow_hash_rnd_timer);
 
-	register_cpu_notifier(&flow_cache_cpu_nb);
-	for (i = 0; i < NR_CPUS; i++) {
-		if (!cpu_online(i))
-			continue;
-		if (flow_cache_cpu_prepare(i) == NOTIFY_OK &&
-		    flow_cache_cpu_online(i) == NOTIFY_OK)
-			continue;
-		panic("NET: failed to initialise flow cache hash table\n");
-	}
+	for (i = 0; i < NR_CPUS; i++)
+		if (cpu_possible(i))
+			flow_cache_cpu_prepare(i);
 
 	return 0;
 }
