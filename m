From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH] dynticks: avoid flow_cache_flush() interrupting every core
Date: Tue, 19 Mar 2013 17:35:58 -0400
Message-ID: <201303192143.r2JLhZIX020469@farm-0021.internal.tilera.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Gilad Ben Yossef <gilad@benyossef.com>,
	"David S. Miller" <davem@davemloft.net>,
	Sasha Levin <sasha.levin@oracle.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Previously, if you did an "ifconfig down" or similar on one core, and
the kernel had CONFIG_XFRM enabled, every core would be interrupted to
check its percpu flow list for items that could be garbage collected.

With this change, we generate a mask of cores that actually have any
percpu items, and only interrupt those cores.  When we are trying to
isolate a set of cpus from interrupts, this is important to do.

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
This change stands alone so could be taken into the net tree if
desired, but it is most useful in the context of Frederic Weisbecker's
linux-dynticks work.  So it could be taken up through either tree,
but it certainly needs sign-off from someone familiar with net/core/flow.c.

 net/core/flow.c |   42 +++++++++++++++++++++++++++++++++++++++---
 1 file changed, 39 insertions(+), 3 deletions(-)

diff --git a/net/core/flow.c b/net/core/flow.c
index c56ea6f..7fae135 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -323,6 +323,24 @@ static void flow_cache_flush_tasklet(unsigned long data)
 		complete(&info->completion);
 }
 
+/*
+ * Return whether a cpu needs flushing.  Conservatively, we assume
+ * the presence of any entries means the core may require flushing,
+ * since the flow_cache_ops.check() function may assume it's running
+ * on the same core as the per-cpu cache component.
+ */
+static int flow_cache_percpu_empty(struct flow_cache *fc, int cpu)
+{
+	struct flow_cache_percpu *fcp;
+	int i;
+
+	fcp = &per_cpu(*fc->percpu, cpu);
+	for (i = 0; i < flow_cache_hash_size(fc); i++)
+		if (!hlist_empty(&fcp->hash_table[i]))
+			return 0;
+	return 1;
+}
+
 static void flow_cache_flush_per_cpu(void *data)
 {
 	struct flow_flush_info *info = data;
@@ -337,22 +355,40 @@ void flow_cache_flush(void)
 {
 	struct flow_flush_info info;
 	static DEFINE_MUTEX(flow_flush_sem);
+	cpumask_var_t mask;
+	int i, self;
+
+	/* Track which cpus need flushing to avoid disturbing all cores. */
+	if (!alloc_cpumask_var(&mask, GFP_KERNEL))
+		return;
+	cpumask_clear(mask);
 
 	/* Don't want cpus going down or up during this. */
 	get_online_cpus();
 	mutex_lock(&flow_flush_sem);
 	info.cache = &flow_cache_global;
-	atomic_set(&info.cpuleft, num_online_cpus());
+	for_each_online_cpu(i)
+		if (!flow_cache_percpu_empty(info.cache, i))
+			cpumask_set_cpu(i, mask);
+	atomic_set(&info.cpuleft, cpumask_weight(mask));
+	if (atomic_read(&info.cpuleft) == 0)
+		goto done;
+
 	init_completion(&info.completion);
 
 	local_bh_disable();
-	smp_call_function(flow_cache_flush_per_cpu, &info, 0);
-	flow_cache_flush_tasklet((unsigned long)&info);
+	self = cpumask_test_and_clear_cpu(smp_processor_id(), mask);
+	on_each_cpu_mask(mask, flow_cache_flush_per_cpu, &info, 0);
+	if (self)
+		flow_cache_flush_tasklet((unsigned long)&info);
 	local_bh_enable();
 
 	wait_for_completion(&info.completion);
+
+done:
 	mutex_unlock(&flow_flush_sem);
 	put_online_cpus();
+	free_cpumask_var(mask);
 }
 
 static void flow_cache_flush_task(struct work_struct *work)
-- 
1.7.10.3
