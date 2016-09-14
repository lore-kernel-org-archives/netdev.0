From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 1/3] mm: memcontrol: make per-cpu charge cache IRQ-safe for socket accounting
Date: Wed, 14 Sep 2016 15:48:44 -0400
Message-ID: <20160914194846.11153-1-hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>,
	Vladimir Davydov <vdavydov@virtuozzo.com>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
To: Andrew Morton <akpm@linux-foundation.org>,
	Tejun Heo <tj@kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <owner-linux-mm@kvack.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Johannes Weiner <jweiner@fb.com>

During cgroup2 rollout into production, we started encountering css
refcount underflows and css access crashes in the memory controller.
Splitting the heavily shared css reference counter into logical users
narrowed the imbalance down to the cgroup2 socket memory accounting.

The problem turns out to be the per-cpu charge cache. Cgroup1 had a
separate socket counter, but the new cgroup2 socket accounting goes
through the common charge path that uses a shared per-cpu cache for
all memory that is being tracked. Those caches are safe against
scheduling preemption, but not against interrupts - such as the newly
added packet receive path. When cache draining is interrupted by
network RX taking pages out of the cache, the resuming drain operation
will put references of in-use pages, thus causing the imbalance.

Disable IRQs during all per-cpu charge cache operations.

Fixes: f7e1cb6ec51b ("mm: memcontrol: account socket memory in unified hierarchy memory controller")
Cc: <stable@vger.kernel.org> # 4.5+
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 31 ++++++++++++++++++++++---------
 1 file changed, 22 insertions(+), 9 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7a8d6624758a..60bb830abc34 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1710,17 +1710,22 @@ static DEFINE_MUTEX(percpu_charge_mutex);
 static bool consume_stock(struct mem_cgroup *memcg, unsigned int nr_pages)
 {
 	struct memcg_stock_pcp *stock;
+	unsigned long flags;
 	bool ret = false;
 
 	if (nr_pages > CHARGE_BATCH)
 		return ret;
 
-	stock = &get_cpu_var(memcg_stock);
+	local_irq_save(flags);
+
+	stock = this_cpu_ptr(&memcg_stock);
 	if (memcg == stock->cached && stock->nr_pages >= nr_pages) {
 		stock->nr_pages -= nr_pages;
 		ret = true;
 	}
-	put_cpu_var(memcg_stock);
+
+	local_irq_restore(flags);
+
 	return ret;
 }
 
@@ -1741,15 +1746,18 @@ static void drain_stock(struct memcg_stock_pcp *stock)
 	stock->cached = NULL;
 }
 
-/*
- * This must be called under preempt disabled or must be called by
- * a thread which is pinned to local cpu.
- */
 static void drain_local_stock(struct work_struct *dummy)
 {
-	struct memcg_stock_pcp *stock = this_cpu_ptr(&memcg_stock);
+	struct memcg_stock_pcp *stock;
+	unsigned long flags;
+
+	local_irq_save(flags);
+
+	stock = this_cpu_ptr(&memcg_stock);
 	drain_stock(stock);
 	clear_bit(FLUSHING_CACHED_CHARGE, &stock->flags);
+
+	local_irq_restore(flags);
 }
 
 /*
@@ -1758,14 +1766,19 @@ static void drain_local_stock(struct work_struct *dummy)
  */
 static void refill_stock(struct mem_cgroup *memcg, unsigned int nr_pages)
 {
-	struct memcg_stock_pcp *stock = &get_cpu_var(memcg_stock);
+	struct memcg_stock_pcp *stock;
+	unsigned long flags;
+
+	local_irq_save(flags);
 
+	stock = this_cpu_ptr(&memcg_stock);
 	if (stock->cached != memcg) { /* reset if necessary */
 		drain_stock(stock);
 		stock->cached = memcg;
 	}
 	stock->nr_pages += nr_pages;
-	put_cpu_var(memcg_stock);
+
+	local_irq_restore(flags);
 }
 
 /*
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
