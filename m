From: Jes Sorensen <jes@trained-monkey.org>
Subject: [patch] net/core/flow.c
Date: Mon, 17 Nov 2003 10:20:04 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16312.59172.153904.436145@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave and Alexey,

While browsing some of the net dev code I noticed that net/core/flow.c
still uses an unsigned long and test_bit/set_bit for it's cpu mask
instead of cpumask_t.

Patch against 2.6.0-test9 included.

Cheers,
Jes

--- linux-2.6.0-test9/net/core/flow.c~	Sat Oct 25 11:42:49 2003
+++ linux-2.6.0-test9/net/core/flow.c	Mon Nov 17 07:27:38 2003
@@ -65,7 +65,7 @@
 
 struct flow_flush_info {
 	atomic_t cpuleft;
-	unsigned long cpumap;
+	cpumask_t cpumap;
 	struct completion completion;
 };
 static DEFINE_PER_CPU(struct tasklet_struct, flow_flush_tasklets) = { NULL };
@@ -73,7 +73,7 @@
 #define flow_flush_tasklet(cpu) (&per_cpu(flow_flush_tasklets, cpu))
 
 static DECLARE_MUTEX(flow_cache_cpu_sem);
-static unsigned long flow_cache_cpu_map;
+static cpumask_t flow_cache_cpu_map;
 static unsigned int flow_cache_cpu_count;
 
 static void flow_cache_new_hashrnd(unsigned long arg)
@@ -81,7 +81,7 @@
 	int i;
 
 	for (i = 0; i < NR_CPUS; i++)
-		if (test_bit(i, &flow_cache_cpu_map))
+		if (cpu_isset(i, flow_cache_cpu_map))
 			flow_hash_rnd_recalc(i) = 1;
 
 	flow_hash_rnd_timer.expires = jiffies + FLOW_HASH_RND_PERIOD;
@@ -178,7 +178,7 @@
 	cpu = smp_processor_id();
 
 	fle = NULL;
-	if (!test_bit(cpu, &flow_cache_cpu_map))
+	if (!cpu_isset(cpu, flow_cache_cpu_map))
 		goto nocache;
 
 	if (flow_hash_rnd_recalc(cpu))
@@ -277,7 +277,7 @@
 	struct tasklet_struct *tasklet;
 
 	cpu = smp_processor_id();
-	if (!test_bit(cpu, &info->cpumap))
+	if (!cpu_isset(cpu, info->cpumap))
 		return;
 
 	tasklet = flow_flush_tasklet(cpu);
@@ -301,7 +301,7 @@
 
 	local_bh_disable();
 	smp_call_function(flow_cache_flush_per_cpu, &info, 1, 0);
-	if (test_bit(smp_processor_id(), &info.cpumap))
+	if (cpu_isset(smp_processor_id(), info.cpumap))
 		flow_cache_flush_tasklet((unsigned long)&info);
 	local_bh_enable();
 
@@ -341,7 +341,7 @@
 static int __devinit flow_cache_cpu_online(int cpu)
 {
 	down(&flow_cache_cpu_sem);
-	set_bit(cpu, &flow_cache_cpu_map);
+	cpu_set(cpu, flow_cache_cpu_map);
 	flow_cache_cpu_count++;
 	up(&flow_cache_cpu_sem);
 
