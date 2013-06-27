From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v3 07/45] CPU hotplug: Add _nocheck() variants of accessor
 functions
Date: Fri, 28 Jun 2013 01:23:44 +0530
Message-ID: <20130627195344.29830.54992.stgit@srivatsabhat.in.ibm.com>
References: <20130627195136.29830.10445.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, sbw@mit.edu, fweisbec@gmail.com,
	zhong@linux.vnet.ibm.com, nikunj@linux.vnet.ibm.com,
	srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	Alex Shi <alex.shi@intel.com>,
	KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>,
	Tejun Heo <tj@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Joonsoo Kim <js1304@gmail.com>,
	"Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	walken@google.com, vincent.guittot@linaro.org,
	laijs@cn.fujitsu.com, David.Laight@aculab.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130627195136.29830.10445.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sometimes, we have situations where the synchronization design of a
particular subsystem handles CPU hotplug properly, but the details are
non-trivial, making it hard to teach this to the rudimentary hotplug
locking validator. In such cases, it would be useful to have a set of
_nocheck() variants of the cpu accessor functions, to avoid false-positive
warnings from the hotplug locking validator.

However, we won't go overboard with that; we'll add them only on a
case-by-case basis and mandate that the call-sites which use them add
a comment explaining why it is hotplug safe and hence justify the use
of the _nocheck() variants.

At the moment, the RCU and the percpu-counter code have legitimate
reasons to use the _nocheck() variants, so let's add them for
cpu_is_offline() and for_each_online_cpu(), for use in those subsystems
respectively.

Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Alex Shi <alex.shi@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <js1304@gmail.com>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/cpumask.h |   59 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 59 insertions(+)

diff --git a/include/linux/cpumask.h b/include/linux/cpumask.h
index 06d2c36..f577a7d 100644
--- a/include/linux/cpumask.h
+++ b/include/linux/cpumask.h
@@ -87,6 +87,7 @@ extern const struct cpumask *const cpu_active_mask;
 #define num_present_cpus()	cpumask_weight(cpu_present_mask)
 #define num_active_cpus()	cpumask_weight(cpu_active_mask)
 #define cpu_online(cpu)		cpumask_test_cpu((cpu), cpu_online_mask)
+#define cpu_online_nocheck(cpu)	cpumask_test_cpu_nocheck((cpu), cpu_online_mask)
 #define cpu_possible(cpu)	cpumask_test_cpu((cpu), cpu_possible_mask)
 #define cpu_present(cpu)	cpumask_test_cpu((cpu), cpu_present_mask)
 #define cpu_active(cpu)		cpumask_test_cpu((cpu), cpu_active_mask)
@@ -96,6 +97,7 @@ extern const struct cpumask *const cpu_active_mask;
 #define num_present_cpus()	1U
 #define num_active_cpus()	1U
 #define cpu_online(cpu)		((cpu) == 0)
+#define cpu_online_nocheck(cpu)	cpu_online((cpu))
 #define cpu_possible(cpu)	((cpu) == 0)
 #define cpu_present(cpu)	((cpu) == 0)
 #define cpu_active(cpu)		((cpu) == 0)
@@ -156,6 +158,8 @@ static inline unsigned int cpumask_any_but(const struct cpumask *mask,
 
 #define for_each_cpu(cpu, mask)			\
 	for ((cpu) = 0; (cpu) < 1; (cpu)++, (void)mask)
+#define for_each_cpu_nocheck(cpu, mask)		\
+			for_each_cpu((cpu), (mask))
 #define for_each_cpu_not(cpu, mask)		\
 	for ((cpu) = 0; (cpu) < 1; (cpu)++, (void)mask)
 #define for_each_cpu_and(cpu, mask, and)	\
@@ -191,6 +195,24 @@ static inline unsigned int cpumask_next(int n, const struct cpumask *srcp)
 }
 
 /**
+ * cpumask_next_nocheck - get the next cpu in a cpumask, without checking
+ * 			  for hotplug safety
+ * @n: the cpu prior to the place to search (ie. return will be > @n)
+ * @srcp: the cpumask pointer
+ *
+ * Returns >= nr_cpu_ids if no further cpus set.
+ */
+static inline unsigned int cpumask_next_nocheck(int n,
+						const struct cpumask *srcp)
+{
+	/* -1 is a legal arg here. */
+	if (n != -1)
+		cpumask_check(n);
+
+	return find_next_bit(cpumask_bits(srcp), nr_cpumask_bits, n+1);
+}
+
+/**
  * cpumask_next_zero - get the next unset cpu in a cpumask
  * @n: the cpu prior to the place to search (ie. return will be > @n)
  * @srcp: the cpumask pointer
@@ -222,6 +244,21 @@ int cpumask_any_but(const struct cpumask *mask, unsigned int cpu);
 		(cpu) = cpumask_next((cpu), (mask)),	\
 		(cpu) < nr_cpu_ids;)
 
+
+/**
+ * for_each_cpu_nocheck - iterate over every cpu in a mask,
+ * 			  without checking for hotplug safety
+ * @cpu: the (optionally unsigned) integer iterator
+ * @mask: the cpumask pointer
+ *
+ * After the loop, cpu is >= nr_cpu_ids.
+ */
+#define for_each_cpu_nocheck(cpu, mask)				\
+	for ((cpu) = -1;					\
+		(cpu) = cpumask_next_nocheck((cpu), (mask)),	\
+		(cpu) < nr_cpu_ids;)
+
+
 /**
  * for_each_cpu_not - iterate over every cpu in a complemented mask
  * @cpu: the (optionally unsigned) integer iterator
@@ -304,6 +341,25 @@ static inline void cpumask_clear_cpu(int cpu, struct cpumask *dstp)
 })
 
 /**
+ * cpumask_test_cpu_nocheck - test for a cpu in a cpumask, without
+ * 			      checking for hotplug safety
+ * @cpu: cpu number (< nr_cpu_ids)
+ * @cpumask: the cpumask pointer
+ *
+ * Returns 1 if @cpu is set in @cpumask, else returns 0
+ *
+ * No static inline type checking - see Subtlety (1) above.
+ */
+#define cpumask_test_cpu_nocheck(cpu, cpumask)			\
+({								\
+	int __ret;						\
+								\
+	__ret = test_bit(cpumask_check(cpu),			\
+				cpumask_bits((cpumask)));	\
+	__ret;							\
+})
+
+/**
  * cpumask_test_and_set_cpu - atomically test and set a cpu in a cpumask
  * @cpu: cpu number (< nr_cpu_ids)
  * @cpumask: the cpumask pointer
@@ -775,6 +831,8 @@ extern const DECLARE_BITMAP(cpu_all_bits, NR_CPUS);
 
 #define for_each_possible_cpu(cpu) for_each_cpu((cpu), cpu_possible_mask)
 #define for_each_online_cpu(cpu)   for_each_cpu((cpu), cpu_online_mask)
+#define for_each_online_cpu_nocheck(cpu)				   \
+				for_each_cpu_nocheck((cpu), cpu_online_mask)
 #define for_each_present_cpu(cpu)  for_each_cpu((cpu), cpu_present_mask)
 
 /* Wrappers for arch boot code to manipulate normally-constant masks */
@@ -823,6 +881,7 @@ static inline const struct cpumask *get_cpu_mask(unsigned int cpu)
 }
 
 #define cpu_is_offline(cpu)	unlikely(!cpu_online(cpu))
+#define cpu_is_offline_nocheck(cpu)	unlikely(!cpu_online_nocheck(cpu))
 
 #if NR_CPUS <= BITS_PER_LONG
 #define CPU_BITS_ALL						\
