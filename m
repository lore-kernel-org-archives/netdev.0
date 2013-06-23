From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH 01/45] CPU hotplug: Provide APIs to prevent CPU offline from
 atomic context
Date: Sun, 23 Jun 2013 19:08:01 +0530
Message-ID: <20130623133756.19094.41723.stgit@srivatsabhat.in.ibm.com>
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
	Thomas Gleixner <tglx@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tejun Heo <tj@kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>,
	Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	walken@google.com, vincent.guittot@linaro.org, laijs@cn.fujitsu.com
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <20130623133642.19094.16038.stgit@srivatsabhat.in.ibm.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current CPU offline code uses stop_machine() internally. And disabling
preemption prevents stop_machine() from taking effect, thus also preventing
CPUs from going offline, as a side effect.

There are places where this side-effect of preempt_disable() (or equivalent)
is used to synchronize with CPU hotplug. Typically these are in atomic
sections of code, where they can't make use of get/put_online_cpus(), because
the latter set of APIs can sleep.

Going forward, we want to get rid of stop_machine() from the CPU hotplug
offline path. And then, with stop_machine() gone, disabling preemption will
no longer prevent CPUs from going offline.

So provide a set of APIs for such atomic hotplug readers, to prevent (any)
CPUs from going offline. For now, they will default to preempt_disable()
and preempt_enable() itself, but this will help us do the tree-wide conversion,
as a preparatory step to remove stop_machine() from CPU hotplug.

(Besides, it is good documentation as well, since it clearly marks places
where we synchronize with CPU hotplug, instead of combining it subtly with
disabling preemption).

In future, when actually removing stop_machine(), we will alter the
implementation of these APIs to a suitable synchronization scheme.

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/cpu.h |   18 ++++++++++++++++++
 kernel/cpu.c        |   38 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 56 insertions(+)

diff --git a/include/linux/cpu.h b/include/linux/cpu.h
index 9f3c7e8..e06c3ad 100644
--- a/include/linux/cpu.h
+++ b/include/linux/cpu.h
@@ -175,6 +175,8 @@ extern struct bus_type cpu_subsys;
 
 extern void get_online_cpus(void);
 extern void put_online_cpus(void);
+extern unsigned int get_online_cpus_atomic(void);
+extern void put_online_cpus_atomic(void);
 extern void cpu_hotplug_disable(void);
 extern void cpu_hotplug_enable(void);
 #define hotcpu_notifier(fn, pri)	cpu_notifier(fn, pri)
@@ -202,6 +204,22 @@ static inline void cpu_hotplug_driver_unlock(void)
 #define put_online_cpus()	do { } while (0)
 #define cpu_hotplug_disable()	do { } while (0)
 #define cpu_hotplug_enable()	do { } while (0)
+
+static inline unsigned int get_online_cpus_atomic(void)
+{
+	/*
+	 * Disable preemption to avoid getting complaints from the
+	 * debug_smp_processor_id() code.
+	 */
+	preempt_disable();
+	return smp_processor_id();
+}
+
+static inline void put_online_cpus_atomic(void)
+{
+	preempt_enable();
+}
+
 #define hotcpu_notifier(fn, pri)	do { (void)(fn); } while (0)
 /* These aren't inline functions due to a GCC bug. */
 #define register_hotcpu_notifier(nb)	({ (void)(nb); 0; })
diff --git a/kernel/cpu.c b/kernel/cpu.c
index 198a388..2d03398 100644
--- a/kernel/cpu.c
+++ b/kernel/cpu.c
@@ -154,6 +154,44 @@ void cpu_hotplug_enable(void)
 	cpu_maps_update_done();
 }
 
+/*
+ * get_online_cpus_atomic - Prevent any CPU from going offline
+ *
+ * Atomic hotplug readers (tasks which wish to prevent CPUs from going
+ * offline during their critical section, but can't afford to sleep)
+ * can invoke this function to synchronize with CPU offline. This function
+ * can be called recursively, provided it is matched with an equal number
+ * of calls to put_online_cpus_atomic().
+ *
+ * Note: This does NOT prevent CPUs from coming online! It only prevents
+ * CPUs from going offline.
+ *
+ * Lock ordering rule: Strictly speaking, there is no lock ordering
+ * requirement here, but it is advisable to keep the locking consistent.
+ * As a simple rule-of-thumb, use these functions in the outer-most blocks
+ * of your critical sections, outside of other locks.
+ *
+ * Returns the current CPU number, with preemption disabled.
+ */
+unsigned int get_online_cpus_atomic(void)
+{
+	/*
+	 * The current CPU hotplug implementation uses stop_machine() in
+	 * the CPU offline path. And disabling preemption prevents
+	 * stop_machine() from taking effect. Thus, this prevents any CPU
+	 * from going offline.
+	 */
+	preempt_disable();
+	return smp_processor_id();
+}
+EXPORT_SYMBOL_GPL(get_online_cpus_atomic);
+
+void put_online_cpus_atomic(void)
+{
+	preempt_enable();
+}
+EXPORT_SYMBOL_GPL(put_online_cpus_atomic);
+
 #else /* #if CONFIG_HOTPLUG_CPU */
 static void cpu_hotplug_begin(void) {}
 static void cpu_hotplug_done(void) {}

