From: Shirley Ma <mashirle@us.ibm.com>
Subject: [RFC PATCH 1/1] sched: Add a new API to find the prefer idlest cpu
Date: Sun, 22 Jul 2012 23:59:43 -0700
Message-ID: <1343026783.13461.17.camel@oc3660625478.ibm.com>
References: <1343026634.13461.15.camel@oc3660625478.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	vivek@us.ibm.com, sri@us.ibm.com
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1343026634.13461.15.camel@oc3660625478.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
index c099cc6..7240868 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -26,6 +26,7 @@
 #include <linux/slab.h>
 #include <linux/profile.h>
 #include <linux/interrupt.h>
+#include <linux/export.h>
 
 #include <trace/events/sched.h>
 
@@ -2809,6 +2810,35 @@ unlock:
 
 	return new_cpu;
 }
+
+/*
+ * This API is used to find the most idle cpu from both preferred and
+ * allowed cpuset (such as cgroup controls cpuset). It helps per-cpu thread
+ * model to pick up the allowed local cpu to be scheduled.
+ * If these two cpusets have intersects, the cpu is chose from the intersects,
+ * if there is no intersects, then the cpu is chose from the allowed cpuset.
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

Shirley
