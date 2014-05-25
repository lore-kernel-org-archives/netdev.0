From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V6 1/2] cpumask: Utility function to set n'th cpu - local cpu first
Date: Sun, 25 May 2014 17:47:26 +0300
Message-ID: <1401029247-15196-2-git-send-email-amirv@mellanox.com>
References: <1401029247-15196-1-git-send-email-amirv@mellanox.com>
Cc: Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Yuval Atias <yuvala@mellanox.com>, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401029247-15196-1-git-send-email-amirv@mellanox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
 include/linux/cpumask.h |  2 ++
 lib/cpumask.c           | 64 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 66 insertions(+)

diff --git a/include/linux/cpumask.h b/include/linux/cpumask.h
index d08e4d2..3551d66 100644
--- a/include/linux/cpumask.h
+++ b/include/linux/cpumask.h
@@ -257,6 +257,8 @@ static inline void cpumask_set_cpu(unsigned int cpu, struct cpumask *dstp)
 	set_bit(cpumask_check(cpu), cpumask_bits(dstp));
 }
 
+int cpumask_set_cpu_local_first(int i, int numa_node, cpumask_t *dstp);
+
 /**
  * cpumask_clear_cpu - clear a cpu in a cpumask
  * @cpu: cpu number (< nr_cpu_ids)
diff --git a/lib/cpumask.c b/lib/cpumask.c
index b810b75..14049a9 100644
--- a/lib/cpumask.c
+++ b/lib/cpumask.c
@@ -163,4 +163,68 @@ void __init free_bootmem_cpumask_var(cpumask_var_t mask)
 {
 	memblock_free_early(__pa(mask), cpumask_size());
 }
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
+
 #endif
-- 
1.8.3.4
