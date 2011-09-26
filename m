From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: [PATCH] net/flow: remove sleeping and deferral mechanism from flow_cache_flush
Date: Mon, 26 Sep 2011 20:09:16 +0300
Message-ID: <1317056956-23644-1-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<timo.teras@iki.fi>, Madalin Bucur <madalin.bucur@freescale.com>
To: <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe001.messaging.microsoft.com ([65.55.88.11]:32247 "EHLO
	TX2EHSOBE001.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191Ab1IZRL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 13:11:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

flow_cache_flush must not sleep as it can be called in atomic context;
removed the schedule_work as the deferred processing lead to the flow
cache gc never being actually run under heavy network load

Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
---
 net/core/flow.c |   21 +++++++++------------
 1 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/net/core/flow.c b/net/core/flow.c
index 555a456..0950f97 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -14,7 +14,6 @@
 #include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/smp.h>
-#include <linux/completion.h>
 #include <linux/percpu.h>
 #include <linux/bitops.h>
 #include <linux/notifier.h>
@@ -49,7 +48,6 @@ struct flow_cache_percpu {
 struct flow_flush_info {
 	struct flow_cache		*cache;
 	atomic_t			cpuleft;
-	struct completion		completion;
 };
 
 struct flow_cache {
@@ -100,7 +98,7 @@ static void flow_entry_kill(struct flow_cache_entry *fle)
 	kmem_cache_free(flow_cachep, fle);
 }
 
-static void flow_cache_gc_task(struct work_struct *work)
+static void flow_cache_gc_task(void)
 {
 	struct list_head gc_list;
 	struct flow_cache_entry *fce, *n;
@@ -113,7 +111,6 @@ static void flow_cache_gc_task(struct work_struct *work)
 	list_for_each_entry_safe(fce, n, &gc_list, u.gc_list)
 		flow_entry_kill(fce);
 }
-static DECLARE_WORK(flow_cache_gc_work, flow_cache_gc_task);
 
 static void flow_cache_queue_garbage(struct flow_cache_percpu *fcp,
 				     int deleted, struct list_head *gc_list)
@@ -123,7 +120,7 @@ static void flow_cache_queue_garbage(struct flow_cache_percpu *fcp,
 		spin_lock_bh(&flow_cache_gc_lock);
 		list_splice_tail(gc_list, &flow_cache_gc_list);
 		spin_unlock_bh(&flow_cache_gc_lock);
-		schedule_work(&flow_cache_gc_work);
+		flow_cache_gc_task();
 	}
 }
 
@@ -320,8 +317,7 @@ static void flow_cache_flush_tasklet(unsigned long data)
 
 	flow_cache_queue_garbage(fcp, deleted, &gc_list);
 
-	if (atomic_dec_and_test(&info->cpuleft))
-		complete(&info->completion);
+	atomic_dec(&info->cpuleft);
 }
 
 static void flow_cache_flush_per_cpu(void *data)
@@ -339,22 +335,23 @@ static void flow_cache_flush_per_cpu(void *data)
 void flow_cache_flush(void)
 {
 	struct flow_flush_info info;
-	static DEFINE_MUTEX(flow_flush_sem);
+	static DEFINE_SPINLOCK(flow_flush_lock);
 
 	/* Don't want cpus going down or up during this. */
 	get_online_cpus();
-	mutex_lock(&flow_flush_sem);
+	spin_lock_bh(&flow_flush_lock);
 	info.cache = &flow_cache_global;
 	atomic_set(&info.cpuleft, num_online_cpus());
-	init_completion(&info.completion);
 
 	local_bh_disable();
 	smp_call_function(flow_cache_flush_per_cpu, &info, 0);
 	flow_cache_flush_tasklet((unsigned long)&info);
 	local_bh_enable();
 
-	wait_for_completion(&info.completion);
-	mutex_unlock(&flow_flush_sem);
+	while (atomic_read(&info.cpuleft) != 0)
+		cpu_relax();
+
+	spin_unlock_bh(&flow_flush_lock);
 	put_online_cpus();
 }
 
-- 
1.7.0.1
