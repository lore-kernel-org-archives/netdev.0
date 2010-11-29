From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 4/4] kthread: use kthread_create_on_cpu()
Date: Mon, 29 Nov 2010 16:15:19 +0100
Message-ID: <1291043719.3435.981.camel@edumazet-laptop>
References: <1290972833.29196.90.camel@edumazet-laptop>
	 <20101128224024.GA12300@basil.fritz.box>
	 <1290984712.29196.100.camel@edumazet-laptop>
	 <20101128230146.GB12300@basil.fritz.box>
	 <1290987424.29196.128.camel@edumazet-laptop>
	 <20101129090510.GA15763@basil.fritz.box>
	 <1291023532.3435.29.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	linux-arch@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291023532.3435.29.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ksoftirqd, kworker, migration, and pktgend kthreads can be created with
kthread_create_on_cpu(), to get proper NUMA affinities for their stack
and task_struct.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David Miller <davem@davemloft.net>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Tejun Heo <tj@kernel.org>
Cc: linux-arch@vger.kernel.org
---
 kernel/softirq.c      |    3 ++-
 kernel/stop_machine.c |    4 ++--
 kernel/workqueue.c    |    4 ++--
 net/core/pktgen.c     |    3 ++-
 4 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/kernel/softirq.c b/kernel/softirq.c
index 18f4be0..b2b7044 100644
--- a/kernel/softirq.c
+++ b/kernel/softirq.c
@@ -831,7 +831,8 @@ static int __cpuinit cpu_callback(struct notifier_block *nfb,
 	switch (action) {
 	case CPU_UP_PREPARE:
 	case CPU_UP_PREPARE_FROZEN:
-		p = kthread_create(run_ksoftirqd, hcpu, "ksoftirqd/%d", hotcpu);
+		p = kthread_create_on_cpu(run_ksoftirqd, hcpu, hotcpu,
+					  "ksoftirqd/%d", hotcpu);
 		if (IS_ERR(p)) {
 			printk("ksoftirqd for %i failed\n", hotcpu);
 			return notifier_from_errno(PTR_ERR(p));
diff --git a/kernel/stop_machine.c b/kernel/stop_machine.c
index 2df820b..7c0f287 100644
--- a/kernel/stop_machine.c
+++ b/kernel/stop_machine.c
@@ -301,8 +301,8 @@ static int __cpuinit cpu_stop_cpu_callback(struct notifier_block *nfb,
 	case CPU_UP_PREPARE:
 		BUG_ON(stopper->thread || stopper->enabled ||
 		       !list_empty(&stopper->works));
-		p = kthread_create(cpu_stopper_thread, stopper, "migration/%d",
-				   cpu);
+		p = kthread_create_on_cpu(cpu_stopper_thread, stopper, cpu,
+					  "migration/%d", cpu);
 		if (IS_ERR(p))
 			return notifier_from_errno(PTR_ERR(p));
 		get_task_struct(p);
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 90db1bd..c8feaf4 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -1318,8 +1318,8 @@ static struct worker *create_worker(struct global_cwq *gcwq, bool bind)
 	worker->id = id;
 
 	if (!on_unbound_cpu)
-		worker->task = kthread_create(worker_thread, worker,
-					      "kworker/%u:%d", gcwq->cpu, id);
+		worker->task = kthread_create_on_cpu(worker_thread, worker, gcwq->cpu,
+						     "kworker/%u:%d", gcwq->cpu, id);
 	else
 		worker->task = kthread_create(worker_thread, worker,
 					      "kworker/u:%d", id);
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 33bc382..c921fe9 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3785,7 +3785,8 @@ static int __init pktgen_create_thread(int cpu)
 	list_add_tail(&t->th_list, &pktgen_threads);
 	init_completion(&t->start_done);
 
-	p = kthread_create(pktgen_thread_worker, t, "kpktgend_%d", cpu);
+	p = kthread_create_on_cpu(pktgen_thread_worker, t, cpu,
+				  "kpktgend_%d", cpu);
 	if (IS_ERR(p)) {
 		pr_err("kernel_thread() failed for cpu %d\n", t->cpu);
 		list_del(&t->th_list);
