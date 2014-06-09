From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V7 1/2] cpumask: Utility function to set n'th cpu - local cpu first
Date: Mon,  9 Jun 2014 10:24:38 +0300
Message-ID: <1402298679-22038-2-git-send-email-amirv@mellanox.com>
References: <1402298679-22038-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Yuval Atias <yuvala@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:42665 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753723AbaFIH0j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2014 03:26:39 -0400
In-Reply-To: <1402298679-22038-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function sets the n'th cpu - local cpu's first.
For example: in a 16 cores server with even cpu's local, will get the
following values:
cpumask_set_cpu_local_first(0, numa, cpumask) => cpu 0 is set
cpumask_set_cpu_local_first(1, numa, cpumask) => cpu 2 is set
...
cpumask_set_cpu_local_first(7, numa, cpumask) => cpu 14 is set
cpumask_set_cpu_local_first(8, numa, cpumask) => cpu 1 is set
cpumask_set_cpu_local_first(9, numa, cpumask) => cpu 3 is set
...
cpumask_set_cpu_local_first(15, numa, cpumask) => cpu 15 is set

Curently this function will be used by multi queue networking devices to
calculate the irq affinity mask, such that as many local cpu's as
possible will be utilized to handle the mq device irq's.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 include/linux/cpumask.h |  8 +++++++
 lib/cpumask.c           | 63 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 71 insertions(+)

diff --git a/include/linux/cpumask.h b/include/linux/cpumask.h
index d08e4d2..d5ef249 100644
--- a/include/linux/cpumask.h
+++ b/include/linux/cpumask.h
@@ -142,6 +142,13 @@ static inline unsigned int cpumask_any_but(const struct cpumask *mask,
 	return 1;
 }
 
+static inline int cpumask_set_cpu_local_first(int i, int numa_node, cpumask_t *dstp)
+{
+	set_bit(0, cpumask_bits(dstp));
+
+	return 0;
+}
+
 #define for_each_cpu(cpu, mask)			\
 	for ((cpu) = 0; (cpu) < 1; (cpu)++, (void)mask)
 #define for_each_cpu_not(cpu, mask)		\
@@ -192,6 +199,7 @@ static inline unsigned int cpumask_next_zero(int n, const struct cpumask *srcp)
 
 int cpumask_next_and(int n, const struct cpumask *, const struct cpumask *);
 int cpumask_any_but(const struct cpumask *mask, unsigned int cpu);
+int cpumask_set_cpu_local_first(int i, int numa_node, cpumask_t *dstp);
 
 /**
  * for_each_cpu - iterate over every cpu in a mask
diff --git a/lib/cpumask.c b/lib/cpumask.c
index b810b75..c101230 100644
--- a/lib/cpumask.c
+++ b/lib/cpumask.c
@@ -164,3 +164,66 @@ void __init free_bootmem_cpumask_var(cpumask_var_t mask)
 	memblock_free_early(__pa(mask), cpumask_size());
 }
 #endif
+
+/**
+ * cpumask_set_cpu_local_first - set i'th cpu with local numa cpu's first
+ *
+ * @i: index number
+ * @numa_node: local numa_node
+ * @dstp: cpumask with the relevant cpu bit set according to the policy
+ *
+ * This function sets the cpumask according to a numa aware policy.
+ * cpumask could be used as an affinity hint for the IRQ related to a
+ * queue. When the policy is to spread queues across cores - local cores
+ * first.
+ *
+ * Returns 0 on success, -ENOMEM for no memory, and -EAGAIN when failed to set
+ * the cpu bit and need to re-call the function.
+ */
+int cpumask_set_cpu_local_first(int i, int numa_node, cpumask_t *dstp)
+{
+	cpumask_var_t mask;
+	int cpu;
+	int ret = 0;
+
+	if (!zalloc_cpumask_var(&mask, GFP_KERNEL))
+		return -ENOMEM;
+
+	i %= num_online_cpus();
+
+	if (!cpumask_of_node(numa_node)) {
+		/* Use all online cpu's for non numa aware system */
+		cpumask_copy(mask, cpu_online_mask);
+	} else {
+		int n;
+
+		cpumask_and(mask,
+			    cpumask_of_node(numa_node), cpu_online_mask);
+
+		n = cpumask_weight(mask);
+		if (i >= n) {
+			i -= n;
+
+			/* If index > number of local cpu's, mask out local
+			 * cpu's
+			 */
+			cpumask_andnot(mask, cpu_online_mask, mask);
+		}
+	}
+
+	for_each_cpu(cpu, mask) {
+		if (--i < 0)
+			goto out;
+	}
+
+	ret = -EAGAIN;
+
+out:
+	free_cpumask_var(mask);
+
+	if (!ret)
+		cpumask_set_cpu(cpu, dstp);
+
+	return ret;
+}
+EXPORT_SYMBOL(cpumask_set_cpu_local_first);
-- 
1.8.3.4
