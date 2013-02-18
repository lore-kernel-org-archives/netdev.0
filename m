From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v6 08/46] CPU hotplug: Provide APIs to prevent CPU offline
 from atomic context
Date: Mon, 18 Feb 2013 18:09:20 +0530
Message-ID: <20130218123920.26245.56709.stgit@srivatsabhat.in.ibm.com>
References: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-arch@vger.kernel.org, linux@arm.linux.org.uk,
 nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org, fweisbec@gmail.com,
 linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, rostedt@goodmis.org,
 xiaoguangrong@linux.vnet.ibm.com, rjw@sisk.pl, sbw@mit.edu,
 wangyun@linux.vnet.ibm.com, srivatsa.bhat@linux.vnet.ibm.com,
 netdev@vger.kernel.org, vincent.guittot@linaro.org, walken@google.com,
 linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org, oleg@redhat.com,
 paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au, mingo@kernel.org,
 akpm@linux-foundation.org, namhyung@kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

There are places where preempt_disable() or local_irq_disable() are used
to prevent any CPU from going offline during the critical section. Let us
call them as "atomic hotplug readers" ("atomic" because they run in atomic,
non-preemptible contexts).

Today, preempt_disable() or its equivalent works because the hotplug writer
uses stop_machine() to take CPUs offline. But once stop_machine() is gone
from the CPU hotplug offline path, the readers won't be able to prevent
CPUs from going offline using preempt_disable().

So the intent here is to provide synchronization APIs for such atomic hotplug
readers, to prevent (any) CPUs from going offline, without depending on
stop_machine() at the writer-side. The new APIs will look something like
this:  get_online_cpus_atomic() and put_online_cpus_atomic()

Some important design requirements and considerations:
-----------------------------------------------------

1. Scalable synchronization at the reader-side, especially in the fast-path

   Any synchronization at the atomic hotplug readers side must be highly
   scalable - avoid global single-holder locks/counters etc. Because, these
   paths currently use the extremely fast preempt_disable(); our replacement
   to preempt_disable() should not become ridiculously costly and also should
   not serialize the readers among themselves needlessly.

   At a minimum, the new APIs must be extremely fast at the reader side
   atleast in the fast-path, when no CPU offline writers are active.

2. preempt_disable() was recursive. The replacement should also be recursive.

3. No (new) lock-ordering restrictions

   preempt_disable() was super-flexible. It didn't impose any ordering
   restrictions or rules for nesting. Our replacement should also be equally
   flexible and usable.

4. No deadlock possibilities

   Regular per-cpu locking is not the way to go if we want to have relaxed
   rules for lock-ordering. Because, we can end up in circular-locking
   dependencies as explained in https://lkml.org/lkml/2012/12/6/290

   So, avoid the usual per-cpu locking schemes (per-cpu locks/per-cpu atomic
   counters with spin-on-contention etc) as much as possible, to avoid
   numerous deadlock possibilities from creeping in.


Implementation of the design:
----------------------------

We use per-CPU reader-writer locks for synchronization because:

  a. They are quite fast and scalable in the fast-path (when no writers are
     active), since they use fast per-cpu counters in those paths.

  b. They are recursive at the reader side.

  c. They provide a good amount of safety against deadlocks; they don't
     spring new deadlock possibilities on us from out of nowhere. As a
     result, they have relaxed locking rules and are quite flexible, and
     thus are best suited for replacing usages of preempt_disable() or
     local_irq_disable() at the reader side.

Together, these satisfy all the requirements mentioned above.

I'm indebted to Michael Wang and Xiao Guangrong for their numerous thoughtful
suggestions and ideas, which inspired and influenced many of the decisions in
this as well as previous designs. Thanks a lot Michael and Xiao!

Cc: Russell King <linux@arm.linux.org.uk>
Cc: Mike Frysinger <vapier@gentoo.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: David Howells <dhowells@redhat.com>
Cc: "James E.J. Bottomley" <jejb@parisc-linux.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Paul Mundt <lethal@linux-sh.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: uclinux-dist-devel@blackfin.uclinux.org
Cc: linux-ia64@vger.kernel.org
Cc: linux-mips@linux-mips.org
Cc: linux-am33-list@redhat.com
Cc: linux-parisc@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-s390@vger.kernel.org
Cc: linux-sh@vger.kernel.org
Cc: sparclinux@vger.kernel.org
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
---

 arch/arm/Kconfig      |    1 +
 arch/blackfin/Kconfig |    1 +
 arch/ia64/Kconfig     |    1 +
 arch/mips/Kconfig     |    1 +
 arch/mn10300/Kconfig  |    1 +
 arch/parisc/Kconfig   |    1 +
 arch/powerpc/Kconfig  |    1 +
 arch/s390/Kconfig     |    1 +
 arch/sh/Kconfig       |    1 +
 arch/sparc/Kconfig    |    1 +
 arch/x86/Kconfig      |    1 +
 include/linux/cpu.h   |    4 ++++
 kernel/cpu.c          |   55 +++++++++++++++++++++++++++++++++++++++++++++++--
 13 files changed, 68 insertions(+), 2 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 67874b8..cb6b94b 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -1616,6 +1616,7 @@ config NR_CPUS
 config HOTPLUG_CPU
 	bool "Support for hot-pluggable CPUs"
 	depends on SMP && HOTPLUG
+	select PERCPU_RWLOCK
 	help
 	  Say Y here to experiment with turning CPUs off and on.  CPUs
 	  can be controlled through /sys/devices/system/cpu.
diff --git a/arch/blackfin/Kconfig b/arch/blackfin/Kconfig
index b6f3ad5..83d9882 100644
--- a/arch/blackfin/Kconfig
+++ b/arch/blackfin/Kconfig
@@ -261,6 +261,7 @@ config NR_CPUS
 config HOTPLUG_CPU
 	bool "Support for hot-pluggable CPUs"
 	depends on SMP && HOTPLUG
+	select PERCPU_RWLOCK
 	default y
 
 config BF_REV_MIN
diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 3279646..c246772 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -378,6 +378,7 @@ config HOTPLUG_CPU
 	bool "Support for hot-pluggable CPUs (EXPERIMENTAL)"
 	depends on SMP && EXPERIMENTAL
 	select HOTPLUG
+	select PERCPU_RWLOCK
 	default n
 	---help---
 	  Say Y here to experiment with turning CPUs off and on.  CPUs
diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index 2ac626a..f97c479 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -956,6 +956,7 @@ config SYS_HAS_EARLY_PRINTK
 config HOTPLUG_CPU
 	bool "Support for hot-pluggable CPUs"
 	depends on SMP && HOTPLUG && SYS_SUPPORTS_HOTPLUG_CPU
+	select PERCPU_RWLOCK
 	help
 	  Say Y here to allow turning CPUs off and on. CPUs can be
 	  controlled through /sys/devices/system/cpu.
diff --git a/arch/mn10300/Kconfig b/arch/mn10300/Kconfig
index e70001c..a64e488 100644
--- a/arch/mn10300/Kconfig
+++ b/arch/mn10300/Kconfig
@@ -60,6 +60,7 @@ config ARCH_HAS_ILOG2_U32
 
 config HOTPLUG_CPU
 	def_bool n
+	select PERCPU_RWLOCK
 
 source "init/Kconfig"
 
diff --git a/arch/parisc/Kconfig b/arch/parisc/Kconfig
index b77feff..6f55cd4 100644
--- a/arch/parisc/Kconfig
+++ b/arch/parisc/Kconfig
@@ -226,6 +226,7 @@ config HOTPLUG_CPU
 	bool
 	default y if SMP
 	select HOTPLUG
+	select PERCPU_RWLOCK
 
 config ARCH_SELECT_MEMORY_MODEL
 	def_bool y
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 17903f1..56b1f15 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -336,6 +336,7 @@ config HOTPLUG_CPU
 	bool "Support for enabling/disabling CPUs"
 	depends on SMP && HOTPLUG && EXPERIMENTAL && (PPC_PSERIES || \
 	PPC_PMAC || PPC_POWERNV || (PPC_85xx && !PPC_E500MC))
+	select PERCPU_RWLOCK
 	---help---
 	  Say Y here to be able to disable and re-enable individual
 	  CPUs at runtime on SMP machines.
diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index b5ea38c..a9aafb4 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -299,6 +299,7 @@ config HOTPLUG_CPU
 	prompt "Support for hot-pluggable CPUs"
 	depends on SMP
 	select HOTPLUG
+	select PERCPU_RWLOCK
 	help
 	  Say Y here to be able to turn CPUs off and on. CPUs
 	  can be controlled through /sys/devices/system/cpu/cpu#.
diff --git a/arch/sh/Kconfig b/arch/sh/Kconfig
index babc2b8..8c92eef 100644
--- a/arch/sh/Kconfig
+++ b/arch/sh/Kconfig
@@ -765,6 +765,7 @@ config NR_CPUS
 config HOTPLUG_CPU
 	bool "Support for hot-pluggable CPUs (EXPERIMENTAL)"
 	depends on SMP && HOTPLUG && EXPERIMENTAL
+	select PERCPU_RWLOCK
 	help
 	  Say Y here to experiment with turning CPUs off and on.  CPUs
 	  can be controlled through /sys/devices/system/cpu.
diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index cb9c333..b22f29d 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -254,6 +254,7 @@ config HOTPLUG_CPU
 	bool "Support for hot-pluggable CPUs"
 	depends on SPARC64 && SMP
 	select HOTPLUG
+	select PERCPU_RWLOCK
 	help
 	  Say Y here to experiment with turning CPUs off and on.  CPUs
 	  can be controlled through /sys/devices/system/cpu/cpu#.
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 225543b..1a6d50d 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1689,6 +1689,7 @@ config PHYSICAL_ALIGN
 config HOTPLUG_CPU
 	bool "Support for hot-pluggable CPUs"
 	depends on SMP && HOTPLUG
+	select PERCPU_RWLOCK
 	---help---
 	  Say Y here to allow turning CPUs off and on. CPUs can be
 	  controlled through /sys/devices/system/cpu.
diff --git a/include/linux/cpu.h b/include/linux/cpu.h
index ce7a074..cf24da1 100644
--- a/include/linux/cpu.h
+++ b/include/linux/cpu.h
@@ -175,6 +175,8 @@ extern struct bus_type cpu_subsys;
 
 extern void get_online_cpus(void);
 extern void put_online_cpus(void);
+extern void get_online_cpus_atomic(void);
+extern void put_online_cpus_atomic(void);
 #define hotcpu_notifier(fn, pri)	cpu_notifier(fn, pri)
 #define register_hotcpu_notifier(nb)	register_cpu_notifier(nb)
 #define unregister_hotcpu_notifier(nb)	unregister_cpu_notifier(nb)
@@ -198,6 +200,8 @@ static inline void cpu_hotplug_driver_unlock(void)
 
 #define get_online_cpus()	do { } while (0)
 #define put_online_cpus()	do { } while (0)
+#define get_online_cpus_atomic()	do { } while (0)
+#define put_online_cpus_atomic()	do { } while (0)
 #define hotcpu_notifier(fn, pri)	do { (void)(fn); } while (0)
 /* These aren't inline functions due to a GCC bug. */
 #define register_hotcpu_notifier(nb)	({ (void)(nb); 0; })
diff --git a/kernel/cpu.c b/kernel/cpu.c
index 3046a50..58dd1df 100644
--- a/kernel/cpu.c
+++ b/kernel/cpu.c
@@ -1,6 +1,18 @@
 /* CPU control.
  * (C) 2001, 2002, 2003, 2004 Rusty Russell
  *
+ * Rework of the CPU hotplug offline mechanism to remove its dependence on
+ * the heavy-weight stop_machine() primitive, by Srivatsa S. Bhat and
+ * Paul E. McKenney.
+ *
+ * Copyright (C) IBM Corporation, 2012-2013
+ * Authors: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
+ *          Paul E. McKenney <paulmck@linux.vnet.ibm.com>
+ *
+ * With lots of invaluable suggestions from:
+ *	    Oleg Nesterov <oleg@redhat.com>
+ *	    Tejun Heo <tj@kernel.org>
+ *
  * This code is licenced under the GPL.
  */
 #include <linux/proc_fs.h>
@@ -19,6 +31,7 @@
 #include <linux/mutex.h>
 #include <linux/gfp.h>
 #include <linux/suspend.h>
+#include <linux/percpu-rwlock.h>
 
 #include "smpboot.h"
 
@@ -133,6 +146,38 @@ static void cpu_hotplug_done(void)
 	mutex_unlock(&cpu_hotplug.lock);
 }
 
+/*
+ * Per-CPU Reader-Writer lock to synchronize between atomic hotplug
+ * readers and the CPU offline hotplug writer.
+ */
+DEFINE_STATIC_PERCPU_RWLOCK(hotplug_pcpu_rwlock);
+
+/*
+ * Invoked by atomic hotplug reader (a task which wants to prevent
+ * CPU offline, but which can't afford to sleep), to prevent CPUs from
+ * going offline. So, you can call this function from atomic contexts
+ * (including interrupt handlers).
+ *
+ * Note: This does NOT prevent CPUs from coming online! It only prevents
+ * CPUs from going offline.
+ *
+ * You can call this function recursively.
+ *
+ * Returns with preemption disabled (but interrupts remain as they are;
+ * they are not disabled).
+ */
+void get_online_cpus_atomic(void)
+{
+	percpu_read_lock_irqsafe(&hotplug_pcpu_rwlock);
+}
+EXPORT_SYMBOL_GPL(get_online_cpus_atomic);
+
+void put_online_cpus_atomic(void)
+{
+	percpu_read_unlock_irqsafe(&hotplug_pcpu_rwlock);
+}
+EXPORT_SYMBOL_GPL(put_online_cpus_atomic);
+
 #else /* #if CONFIG_HOTPLUG_CPU */
 static void cpu_hotplug_begin(void) {}
 static void cpu_hotplug_done(void) {}
@@ -246,15 +291,21 @@ struct take_cpu_down_param {
 static int __ref take_cpu_down(void *_param)
 {
 	struct take_cpu_down_param *param = _param;
+	unsigned long flags;
 	int err;
 
+	percpu_write_lock_irqsave(&hotplug_pcpu_rwlock, &flags);
+
 	/* Ensure this CPU doesn't handle any more interrupts. */
 	err = __cpu_disable();
 	if (err < 0)
-		return err;
+		goto out;
 
 	cpu_notify(CPU_DYING | param->mod, param->hcpu);
-	return 0;
+
+out:
+	percpu_write_unlock_irqrestore(&hotplug_pcpu_rwlock, &flags);
+	return err;
 }
 
 /* Requires cpu_add_remove_lock to be held */
