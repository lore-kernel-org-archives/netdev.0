From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v4 net-next-2.6] netfilter: x_tables: dont block BH while
 reading counters
Date: Sat, 18 Dec 2010 05:29:39 +0100
Message-ID: <1292646579.7894.42.camel@edumazet-laptop>
References: <1292337974.9155.68.camel@firesoul.comx.local>
	 <1292340702.5934.5.camel@edumazet-laptop>
	 <1292342958.9155.91.camel@firesoul.comx.local>
	 <1292343855.5934.27.camel@edumazet-laptop>
	 <1292508266.31289.12.camel@firesoul.comx.local>
	 <1292508733.2883.152.camel@edumazet-laptop>
	 <1292509489.31289.20.camel@firesoul.comx.local>
	 <1292509775.2883.187.camel@edumazet-laptop>
	 <1292511761.2883.236.camel@edumazet-laptop>
	 <1292515625.2883.336.camel@edumazet-laptop>
	 <1292518436.2883.393.camel@edumazet-laptop>
	 <20101216093149.71f082c7@nehalam>
	 <1292521986.2883.472.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@comx.dk>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1292521986.2883.472.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using "iptables -L" with a lot of rules have a too big BH latency.
Jesper mentioned ~6 ms and worried of frame drops.

Switch to a per_cpu seqlock scheme, so that taking a snapshot of
counters doesnt need to block BH (for this cpu, but also other cpus).

This adds two increments on seqlock sequence per ipt_do_table() call,
its a reasonable cost for allowing "iptables -L" not block BH
processing.

Reported-by: Jesper Dangaard Brouer <hawk@comx.dk>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>
---
v4: I forgot net/netfilter/x_tables.c change in v3

 include/linux/netfilter/x_tables.h |   10 +++---
 net/ipv4/netfilter/arp_tables.c    |   45 ++++++++-------------------
 net/ipv4/netfilter/ip_tables.c     |   45 ++++++++-------------------
 net/ipv6/netfilter/ip6_tables.c    |   45 ++++++++-------------------
 net/netfilter/x_tables.c           |    3 +
 5 files changed, 49 insertions(+), 99 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 742bec0..6712e71 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -472,7 +472,7 @@ extern void xt_free_table_info(struct xt_table_info *info);
  *  necessary for reading the counters.
  */
 struct xt_info_lock {
-	spinlock_t lock;
+	seqlock_t lock;
 	unsigned char readers;
 };
 DECLARE_PER_CPU(struct xt_info_lock, xt_info_locks);
@@ -497,7 +497,7 @@ static inline void xt_info_rdlock_bh(void)
 	local_bh_disable();
 	lock = &__get_cpu_var(xt_info_locks);
 	if (likely(!lock->readers++))
-		spin_lock(&lock->lock);
+		write_seqlock(&lock->lock);
 }
 
 static inline void xt_info_rdunlock_bh(void)
@@ -505,7 +505,7 @@ static inline void xt_info_rdunlock_bh(void)
 	struct xt_info_lock *lock = &__get_cpu_var(xt_info_locks);
 
 	if (likely(!--lock->readers))
-		spin_unlock(&lock->lock);
+		write_sequnlock(&lock->lock);
 	local_bh_enable();
 }
 
@@ -516,12 +516,12 @@ static inline void xt_info_rdunlock_bh(void)
  */
 static inline void xt_info_wrlock(unsigned int cpu)
 {
-	spin_lock(&per_cpu(xt_info_locks, cpu).lock);
+	write_seqlock(&per_cpu(xt_info_locks, cpu).lock);
 }
 
 static inline void xt_info_wrunlock(unsigned int cpu)
 {
-	spin_unlock(&per_cpu(xt_info_locks, cpu).lock);
+	write_sequnlock(&per_cpu(xt_info_locks, cpu).lock);
 }
 
 /*
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 3fac340..e855fff 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -710,42 +710,25 @@ static void get_counters(const struct xt_table_info *t,
 	struct arpt_entry *iter;
 	unsigned int cpu;
 	unsigned int i;
-	unsigned int curcpu = get_cpu();
-
-	/* Instead of clearing (by a previous call to memset())
-	 * the counters and using adds, we set the counters
-	 * with data used by 'current' CPU
-	 *
-	 * Bottom half has to be disabled to prevent deadlock
-	 * if new softirq were to run and call ipt_do_table
-	 */
-	local_bh_disable();
-	i = 0;
-	xt_entry_foreach(iter, t->entries[curcpu], t->size) {
-		SET_COUNTER(counters[i], iter->counters.bcnt,
-			    iter->counters.pcnt);
-		++i;
-	}
-	local_bh_enable();
-	/* Processing counters from other cpus, we can let bottom half enabled,
-	 * (preemption is disabled)
-	 */
 
 	for_each_possible_cpu(cpu) {
-		if (cpu == curcpu)
-			continue;
+		seqlock_t *lock = &per_cpu(xt_info_locks, cpu).lock;
+
 		i = 0;
-		local_bh_disable();
-		xt_info_wrlock(cpu);
 		xt_entry_foreach(iter, t->entries[cpu], t->size) {
-			ADD_COUNTER(counters[i], iter->counters.bcnt,
-				    iter->counters.pcnt);
+			u64 bcnt, pcnt;
+			unsigned int start;
+
+			do {
+				start = read_seqbegin(lock);
+				bcnt = iter->counters.bcnt;
+				pcnt = iter->counters.pcnt;
+			} while (read_seqretry(lock, start));
+
+			ADD_COUNTER(counters[i], bcnt, pcnt);
 			++i;
 		}
-		xt_info_wrunlock(cpu);
-		local_bh_enable();
 	}
-	put_cpu();
 }
 
 static struct xt_counters *alloc_counters(const struct xt_table *table)
@@ -759,7 +742,7 @@ static struct xt_counters *alloc_counters(const struct xt_table *table)
 	 * about).
 	 */
 	countersize = sizeof(struct xt_counters) * private->number;
-	counters = vmalloc(countersize);
+	counters = vzalloc(countersize);
 
 	if (counters == NULL)
 		return ERR_PTR(-ENOMEM);
@@ -1007,7 +990,7 @@ static int __do_replace(struct net *net, const char *name,
 	struct arpt_entry *iter;
 
 	ret = 0;
-	counters = vmalloc(num_counters * sizeof(struct xt_counters));
+	counters = vzalloc(num_counters * sizeof(struct xt_counters));
 	if (!counters) {
 		ret = -ENOMEM;
 		goto out;
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index a846d63..652efea 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -884,42 +884,25 @@ get_counters(const struct xt_table_info *t,
 	struct ipt_entry *iter;
 	unsigned int cpu;
 	unsigned int i;
-	unsigned int curcpu = get_cpu();
-
-	/* Instead of clearing (by a previous call to memset())
-	 * the counters and using adds, we set the counters
-	 * with data used by 'current' CPU.
-	 *
-	 * Bottom half has to be disabled to prevent deadlock
-	 * if new softirq were to run and call ipt_do_table
-	 */
-	local_bh_disable();
-	i = 0;
-	xt_entry_foreach(iter, t->entries[curcpu], t->size) {
-		SET_COUNTER(counters[i], iter->counters.bcnt,
-			    iter->counters.pcnt);
-		++i;
-	}
-	local_bh_enable();
-	/* Processing counters from other cpus, we can let bottom half enabled,
-	 * (preemption is disabled)
-	 */
 
 	for_each_possible_cpu(cpu) {
-		if (cpu == curcpu)
-			continue;
+		seqlock_t *lock = &per_cpu(xt_info_locks, cpu).lock;
+
 		i = 0;
-		local_bh_disable();
-		xt_info_wrlock(cpu);
 		xt_entry_foreach(iter, t->entries[cpu], t->size) {
-			ADD_COUNTER(counters[i], iter->counters.bcnt,
-				    iter->counters.pcnt);
+			u64 bcnt, pcnt;
+			unsigned int start;
+
+			do {
+				start = read_seqbegin(lock);
+				bcnt = iter->counters.bcnt;
+				pcnt = iter->counters.pcnt;
+			} while (read_seqretry(lock, start));
+
+			ADD_COUNTER(counters[i], bcnt, pcnt);
 			++i; /* macro does multi eval of i */
 		}
-		xt_info_wrunlock(cpu);
-		local_bh_enable();
 	}
-	put_cpu();
 }
 
 static struct xt_counters *alloc_counters(const struct xt_table *table)
@@ -932,7 +915,7 @@ static struct xt_counters *alloc_counters(const struct xt_table *table)
 	   (other than comefrom, which userspace doesn't care
 	   about). */
 	countersize = sizeof(struct xt_counters) * private->number;
-	counters = vmalloc(countersize);
+	counters = vzalloc(countersize);
 
 	if (counters == NULL)
 		return ERR_PTR(-ENOMEM);
@@ -1203,7 +1186,7 @@ __do_replace(struct net *net, const char *name, unsigned int valid_hooks,
 	struct ipt_entry *iter;
 
 	ret = 0;
-	counters = vmalloc(num_counters * sizeof(struct xt_counters));
+	counters = vzalloc(num_counters * sizeof(struct xt_counters));
 	if (!counters) {
 		ret = -ENOMEM;
 		goto out;
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 4555823..7d227c6 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -897,42 +897,25 @@ get_counters(const struct xt_table_info *t,
 	struct ip6t_entry *iter;
 	unsigned int cpu;
 	unsigned int i;
-	unsigned int curcpu = get_cpu();
-
-	/* Instead of clearing (by a previous call to memset())
-	 * the counters and using adds, we set the counters
-	 * with data used by 'current' CPU
-	 *
-	 * Bottom half has to be disabled to prevent deadlock
-	 * if new softirq were to run and call ipt_do_table
-	 */
-	local_bh_disable();
-	i = 0;
-	xt_entry_foreach(iter, t->entries[curcpu], t->size) {
-		SET_COUNTER(counters[i], iter->counters.bcnt,
-			    iter->counters.pcnt);
-		++i;
-	}
-	local_bh_enable();
-	/* Processing counters from other cpus, we can let bottom half enabled,
-	 * (preemption is disabled)
-	 */
 
 	for_each_possible_cpu(cpu) {
-		if (cpu == curcpu)
-			continue;
+		seqlock_t *lock = &per_cpu(xt_info_locks, cpu).lock;
+
 		i = 0;
-		local_bh_disable();
-		xt_info_wrlock(cpu);
 		xt_entry_foreach(iter, t->entries[cpu], t->size) {
-			ADD_COUNTER(counters[i], iter->counters.bcnt,
-				    iter->counters.pcnt);
+			u64 bcnt, pcnt;
+			unsigned int start;
+
+			do {
+				start = read_seqbegin(lock);
+				bcnt = iter->counters.bcnt;
+				pcnt = iter->counters.pcnt;
+			} while (read_seqretry(lock, start));
+
+			ADD_COUNTER(counters[i], bcnt, pcnt);
 			++i;
 		}
-		xt_info_wrunlock(cpu);
-		local_bh_enable();
 	}
-	put_cpu();
 }
 
 static struct xt_counters *alloc_counters(const struct xt_table *table)
@@ -945,7 +928,7 @@ static struct xt_counters *alloc_counters(const struct xt_table *table)
 	   (other than comefrom, which userspace doesn't care
 	   about). */
 	countersize = sizeof(struct xt_counters) * private->number;
-	counters = vmalloc(countersize);
+	counters = vzalloc(countersize);
 
 	if (counters == NULL)
 		return ERR_PTR(-ENOMEM);
@@ -1216,7 +1199,7 @@ __do_replace(struct net *net, const char *name, unsigned int valid_hooks,
 	struct ip6t_entry *iter;
 
 	ret = 0;
-	counters = vmalloc(num_counters * sizeof(struct xt_counters));
+	counters = vzalloc(num_counters * sizeof(struct xt_counters));
 	if (!counters) {
 		ret = -ENOMEM;
 		goto out;
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 8046350..c942376 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -1325,7 +1325,8 @@ static int __init xt_init(void)
 
 	for_each_possible_cpu(i) {
 		struct xt_info_lock *lock = &per_cpu(xt_info_locks, i);
-		spin_lock_init(&lock->lock);
+
+		seqlock_init(&lock->lock);
 		lock->readers = 0;
 	}
 


