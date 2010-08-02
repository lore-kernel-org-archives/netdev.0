From: kaber@trash.net
Subject: [PATCH 21/28] netfilter: {ip,ip6,arp}_tables: dont block bottom half more than necessary
Date: Mon,  2 Aug 2010 21:57:38 +0200
Message-ID: <1280779065-9333-22-git-send-email-kaber@trash.net>
References: <1280779065-9333-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1280779065-9333-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>

We currently disable BH for the whole duration of get_counters()

On machines with a lot of cpus and large tables, this might be too long.

We can disable preemption during the whole function, and disable BH only
while fetching counters for the current cpu.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/arp_tables.c |   10 ++++++----
 net/ipv4/netfilter/ip_tables.c  |   10 ++++++----
 net/ipv6/netfilter/ip6_tables.c |   10 ++++++----
 3 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index c868dd5..6bccba3 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -710,7 +710,7 @@ static void get_counters(const struct xt_table_info *t,
 	struct arpt_entry *iter;
 	unsigned int cpu;
 	unsigned int i;
-	unsigned int curcpu;
+	unsigned int curcpu = get_cpu();
 
 	/* Instead of clearing (by a previous call to memset())
 	 * the counters and using adds, we set the counters
@@ -720,14 +720,16 @@ static void get_counters(const struct xt_table_info *t,
 	 * if new softirq were to run and call ipt_do_table
 	 */
 	local_bh_disable();
-	curcpu = smp_processor_id();
-
 	i = 0;
 	xt_entry_foreach(iter, t->entries[curcpu], t->size) {
 		SET_COUNTER(counters[i], iter->counters.bcnt,
 			    iter->counters.pcnt);
 		++i;
 	}
+	local_bh_enable();
+	/* Processing counters from other cpus, we can let bottom half enabled,
+	 * (preemption is disabled)
+	 */
 
 	for_each_possible_cpu(cpu) {
 		if (cpu == curcpu)
@@ -741,7 +743,7 @@ static void get_counters(const struct xt_table_info *t,
 		}
 		xt_info_wrunlock(cpu);
 	}
-	local_bh_enable();
+	put_cpu();
 }
 
 static struct xt_counters *alloc_counters(const struct xt_table *table)
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 3c584a6..c439721 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -884,7 +884,7 @@ get_counters(const struct xt_table_info *t,
 	struct ipt_entry *iter;
 	unsigned int cpu;
 	unsigned int i;
-	unsigned int curcpu;
+	unsigned int curcpu = get_cpu();
 
 	/* Instead of clearing (by a previous call to memset())
 	 * the counters and using adds, we set the counters
@@ -894,14 +894,16 @@ get_counters(const struct xt_table_info *t,
 	 * if new softirq were to run and call ipt_do_table
 	 */
 	local_bh_disable();
-	curcpu = smp_processor_id();
-
 	i = 0;
 	xt_entry_foreach(iter, t->entries[curcpu], t->size) {
 		SET_COUNTER(counters[i], iter->counters.bcnt,
 			    iter->counters.pcnt);
 		++i;
 	}
+	local_bh_enable();
+	/* Processing counters from other cpus, we can let bottom half enabled,
+	 * (preemption is disabled)
+	 */
 
 	for_each_possible_cpu(cpu) {
 		if (cpu == curcpu)
@@ -915,7 +917,7 @@ get_counters(const struct xt_table_info *t,
 		}
 		xt_info_wrunlock(cpu);
 	}
-	local_bh_enable();
+	put_cpu();
 }
 
 static struct xt_counters *alloc_counters(const struct xt_table *table)
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 33113c1..5359ef4 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -897,7 +897,7 @@ get_counters(const struct xt_table_info *t,
 	struct ip6t_entry *iter;
 	unsigned int cpu;
 	unsigned int i;
-	unsigned int curcpu;
+	unsigned int curcpu = get_cpu();
 
 	/* Instead of clearing (by a previous call to memset())
 	 * the counters and using adds, we set the counters
@@ -907,14 +907,16 @@ get_counters(const struct xt_table_info *t,
 	 * if new softirq were to run and call ipt_do_table
 	 */
 	local_bh_disable();
-	curcpu = smp_processor_id();
-
 	i = 0;
 	xt_entry_foreach(iter, t->entries[curcpu], t->size) {
 		SET_COUNTER(counters[i], iter->counters.bcnt,
 			    iter->counters.pcnt);
 		++i;
 	}
+	local_bh_enable();
+	/* Processing counters from other cpus, we can let bottom half enabled,
+	 * (preemption is disabled)
+	 */
 
 	for_each_possible_cpu(cpu) {
 		if (cpu == curcpu)
@@ -928,7 +930,7 @@ get_counters(const struct xt_table_info *t,
 		}
 		xt_info_wrunlock(cpu);
 	}
-	local_bh_enable();
+	put_cpu();
 }
 
 static struct xt_counters *alloc_counters(const struct xt_table *table)
-- 
1.7.1

