From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH 06/45] CPU hotplug: Sprinkle debugging checks to catch locking
 bugs
Date: Sun, 23 Jun 2013 19:09:15 +0530
Message-ID: <20130623133909.19094.18155.stgit@srivatsabhat.in.ibm.com>
References: <20130623133642.19094.16038.stgit@srivatsabhat.in.ibm.com>
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
	Joonsoo Kim <js1304@gmail.com>
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	walken@google.com, vincent.guittot@linaro.org, laijs@cn.fujitsu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130623133642.19094.16038.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that we have a debug infrastructure in place to detect cases where
get/put_online_cpus_atomic() had to be used, add these checks at the
right spots to help catch places where we missed converting to the new
APIs.

Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Alex Shi <alex.shi@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <js1304@gmail.com>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/cpumask.h |   47 +++++++++++++++++++++++++++++++++++++++++++++--
 lib/cpumask.c           |    8 ++++++++
 2 files changed, 53 insertions(+), 2 deletions(-)

diff --git a/include/linux/cpumask.h b/include/linux/cpumask.h
index 9197ca4..06d2c36 100644
--- a/include/linux/cpumask.h
+++ b/include/linux/cpumask.h
@@ -169,6 +169,7 @@ static inline unsigned int cpumask_any_but(const struct cpumask *mask,
  */
 static inline unsigned int cpumask_first(const struct cpumask *srcp)
 {
+	check_hotplug_safe_cpumask(srcp);
 	return find_first_bit(cpumask_bits(srcp), nr_cpumask_bits);
 }
 
@@ -184,6 +185,8 @@ static inline unsigned int cpumask_next(int n, const struct cpumask *srcp)
 	/* -1 is a legal arg here. */
 	if (n != -1)
 		cpumask_check(n);
+
+	check_hotplug_safe_cpumask(srcp);
 	return find_next_bit(cpumask_bits(srcp), nr_cpumask_bits, n+1);
 }
 
@@ -199,6 +202,8 @@ static inline unsigned int cpumask_next_zero(int n, const struct cpumask *srcp)
 	/* -1 is a legal arg here. */
 	if (n != -1)
 		cpumask_check(n);
+
+	check_hotplug_safe_cpumask(srcp);
 	return find_next_zero_bit(cpumask_bits(srcp), nr_cpumask_bits, n+1);
 }
 
@@ -288,8 +293,15 @@ static inline void cpumask_clear_cpu(int cpu, struct cpumask *dstp)
  *
  * No static inline type checking - see Subtlety (1) above.
  */
-#define cpumask_test_cpu(cpu, cpumask) \
-	test_bit(cpumask_check(cpu), cpumask_bits((cpumask)))
+#define cpumask_test_cpu(cpu, cpumask)				\
+({								\
+	int __ret;						\
+								\
+	check_hotplug_safe_cpu(cpu, cpumask);			\
+	__ret = test_bit(cpumask_check(cpu),			\
+				cpumask_bits((cpumask)));	\
+	__ret;							\
+})
 
 /**
  * cpumask_test_and_set_cpu - atomically test and set a cpu in a cpumask
@@ -349,6 +361,9 @@ static inline int cpumask_and(struct cpumask *dstp,
 			       const struct cpumask *src1p,
 			       const struct cpumask *src2p)
 {
+	check_hotplug_safe_cpumask(src1p);
+	check_hotplug_safe_cpumask(src2p);
+
 	return bitmap_and(cpumask_bits(dstp), cpumask_bits(src1p),
 				       cpumask_bits(src2p), nr_cpumask_bits);
 }
@@ -362,6 +377,9 @@ static inline int cpumask_and(struct cpumask *dstp,
 static inline void cpumask_or(struct cpumask *dstp, const struct cpumask *src1p,
 			      const struct cpumask *src2p)
 {
+	check_hotplug_safe_cpumask(src1p);
+	check_hotplug_safe_cpumask(src2p);
+
 	bitmap_or(cpumask_bits(dstp), cpumask_bits(src1p),
 				      cpumask_bits(src2p), nr_cpumask_bits);
 }
@@ -376,6 +394,9 @@ static inline void cpumask_xor(struct cpumask *dstp,
 			       const struct cpumask *src1p,
 			       const struct cpumask *src2p)
 {
+	check_hotplug_safe_cpumask(src1p);
+	check_hotplug_safe_cpumask(src2p);
+
 	bitmap_xor(cpumask_bits(dstp), cpumask_bits(src1p),
 				       cpumask_bits(src2p), nr_cpumask_bits);
 }
@@ -392,6 +413,9 @@ static inline int cpumask_andnot(struct cpumask *dstp,
 				  const struct cpumask *src1p,
 				  const struct cpumask *src2p)
 {
+	check_hotplug_safe_cpumask(src1p);
+	check_hotplug_safe_cpumask(src2p);
+
 	return bitmap_andnot(cpumask_bits(dstp), cpumask_bits(src1p),
 					  cpumask_bits(src2p), nr_cpumask_bits);
 }
@@ -404,6 +428,8 @@ static inline int cpumask_andnot(struct cpumask *dstp,
 static inline void cpumask_complement(struct cpumask *dstp,
 				      const struct cpumask *srcp)
 {
+	check_hotplug_safe_cpumask(srcp);
+
 	bitmap_complement(cpumask_bits(dstp), cpumask_bits(srcp),
 					      nr_cpumask_bits);
 }
@@ -416,6 +442,9 @@ static inline void cpumask_complement(struct cpumask *dstp,
 static inline bool cpumask_equal(const struct cpumask *src1p,
 				const struct cpumask *src2p)
 {
+	check_hotplug_safe_cpumask(src1p);
+	check_hotplug_safe_cpumask(src2p);
+
 	return bitmap_equal(cpumask_bits(src1p), cpumask_bits(src2p),
 						 nr_cpumask_bits);
 }
@@ -428,6 +457,10 @@ static inline bool cpumask_equal(const struct cpumask *src1p,
 static inline bool cpumask_intersects(const struct cpumask *src1p,
 				     const struct cpumask *src2p)
 {
+
+	check_hotplug_safe_cpumask(src1p);
+	check_hotplug_safe_cpumask(src2p);
+
 	return bitmap_intersects(cpumask_bits(src1p), cpumask_bits(src2p),
 						      nr_cpumask_bits);
 }
@@ -442,6 +475,9 @@ static inline bool cpumask_intersects(const struct cpumask *src1p,
 static inline int cpumask_subset(const struct cpumask *src1p,
 				 const struct cpumask *src2p)
 {
+	check_hotplug_safe_cpumask(src1p);
+	check_hotplug_safe_cpumask(src2p);
+
 	return bitmap_subset(cpumask_bits(src1p), cpumask_bits(src2p),
 						  nr_cpumask_bits);
 }
@@ -470,6 +506,12 @@ static inline bool cpumask_full(const struct cpumask *srcp)
  */
 static inline unsigned int cpumask_weight(const struct cpumask *srcp)
 {
+	/*
+	 * Often, we just want to have a rough estimate of the number of
+	 * online CPUs, without going to the trouble of synchronizing with
+	 * CPU hotplug. So don't invoke check_hotplug_safe_cpumask() here.
+	 */
+
 	return bitmap_weight(cpumask_bits(srcp), nr_cpumask_bits);
 }
 
@@ -507,6 +549,7 @@ static inline void cpumask_shift_left(struct cpumask *dstp,
 static inline void cpumask_copy(struct cpumask *dstp,
 				const struct cpumask *srcp)
 {
+	check_hotplug_safe_cpumask(srcp);
 	bitmap_copy(cpumask_bits(dstp), cpumask_bits(srcp), nr_cpumask_bits);
 }
 
diff --git a/lib/cpumask.c b/lib/cpumask.c
index d327b87..481df57 100644
--- a/lib/cpumask.c
+++ b/lib/cpumask.c
@@ -7,12 +7,14 @@
 
 int __first_cpu(const cpumask_t *srcp)
 {
+	check_hotplug_safe_cpumask(srcp);
 	return min_t(int, NR_CPUS, find_first_bit(srcp->bits, NR_CPUS));
 }
 EXPORT_SYMBOL(__first_cpu);
 
 int __next_cpu(int n, const cpumask_t *srcp)
 {
+	check_hotplug_safe_cpumask(srcp);
 	return min_t(int, NR_CPUS, find_next_bit(srcp->bits, NR_CPUS, n+1));
 }
 EXPORT_SYMBOL(__next_cpu);
@@ -20,6 +22,7 @@ EXPORT_SYMBOL(__next_cpu);
 #if NR_CPUS > 64
 int __next_cpu_nr(int n, const cpumask_t *srcp)
 {
+	check_hotplug_safe_cpumask(srcp);
 	return min_t(int, nr_cpu_ids,
 				find_next_bit(srcp->bits, nr_cpu_ids, n+1));
 }
@@ -37,6 +40,9 @@ EXPORT_SYMBOL(__next_cpu_nr);
 int cpumask_next_and(int n, const struct cpumask *src1p,
 		     const struct cpumask *src2p)
 {
+	check_hotplug_safe_cpumask(src1p);
+	check_hotplug_safe_cpumask(src2p);
+
 	while ((n = cpumask_next(n, src1p)) < nr_cpu_ids)
 		if (cpumask_test_cpu(n, src2p))
 			break;
@@ -57,6 +63,8 @@ int cpumask_any_but(const struct cpumask *mask, unsigned int cpu)
 	unsigned int i;
 
 	cpumask_check(cpu);
+	check_hotplug_safe_cpumask(mask);
+
 	for_each_cpu(i, mask)
 		if (i != cpu)
 			break;
