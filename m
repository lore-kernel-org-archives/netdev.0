From: Shirley Ma <mashirle@us.ibm.com>
Subject: [RFC PATCH 1/1] fair.c: Add/Export find_idlest_perfer_cpu API
Date: Fri, 17 Aug 2012 12:46:10 -0700
Message-ID: <1345232770.16533.234.camel@oc3660625478.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mingo@redhat.com, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, sri@us.ibm.com, vivek@us.ibm.com
To: linux-kernel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>, mingo@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add/Export a new API for per-cpu thread model networking device driver
to choose a preferred idlest cpu within allowed cpumask.

The receiving CPUs of a networking device are not under cgroup controls.
Normally the receiving work will be scheduled on the cpu on which the
interrupts are received. When such a networking device uses per-cpu
thread model, the cpu which is chose to process the packets might not be
part of cgroup cpusets without using such an API here. 

On NUMA system, by using the preferred cpumask from the same NUMA node
would help to reduce expensive cross memory access to/from the other
NUMA node.

KVM per-cpu vhost will be the first one to use this API. Any other
device driver which uses per-cpu thread model and has cgroup cpuset
control will use this API later.

Signed-off-by: Shirley Ma <xma@us.ibm.com>
---
 include/linux/sched.h |    2 ++
 kernel/sched/fair.c   |   41 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+), 0 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 64d9df5..46cc4a7 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2806,4 +2806,6 @@ static inline unsigned long rlimit_max(unsigned int limit)
 
 #endif /* __KERNEL__ */
 
+extern int find_idlest_prefer_cpu(struct cpumask *prefer,
+				 struct cpumask *allowed, int prev_cpu);
 #endif
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index c099cc6..d3da151 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -26,6 +26,7 @@
 #include <linux/slab.h>
 #include <linux/profile.h>
 #include <linux/interrupt.h>
+#include <linux/export.h>
 
 #include <trace/events/sched.h>
 
@@ -2809,6 +2810,46 @@ unlock:
 
 	return new_cpu;
 }
+
+/*
+ * This API is used to find the most idle cpu from both preferred and
+ * allowed cpuset.
+ *
+ * allowed: The allowed cpumask is the caller's task allowed cpuset, which could * be from cgroup cpuset control.
+ * prefer: The perfer cpumask is caller's perferred cpuset choice, which could
+ * be a cpuset of a NUMA node for better performance.
+ *
+ * It helps per-cpu thread model to choose the preferred cpu in the allowed
+ * cpuset to be scheduled when the work doesn't want to be scheduled on the
+ * same cpu on which the work is received for better performance. For example
+ * the network work doesn't want to be on the same cpu on which the
+ * interrupt is received.
+ *
+ * If these two cpusets have intersects, the cpu is chose from the intersects;
+ * if there is no intersects, then the cpu is chose from the allowed cpuset.
+ *
+ * prev_cpu helps to better local cache when prev_cpu is not busy.
+ */
+int find_idlest_prefer_cpu(struct cpumask *prefer, struct cpumask *allowed,
+			  int prev_cpu)
+{
+	unsigned long load, min_load = ULONG_MAX;
+	int check, i, idlest = -1;
+
+	check = cpumask_intersects(prefer, allowed);
+	/* Traverse only the allowed CPUs */
+	if (check == 0)
+		prefer = allowed;
+	for_each_cpu_and(i, prefer, allowed) {
+		load = weighted_cpuload(i);
+		if (load < min_load || (load == min_load && i == prev_cpu)) {
+			min_load = load;
+			idlest = i;
+		}
+	}
+	return idlest;
+}
+EXPORT_SYMBOL(find_idlest_prefer_cpu);
 #endif /* CONFIG_SMP */
 
 static unsigned long

thanks
Shirley
