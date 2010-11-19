From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC][PATCH 2/5] lib: cpu_rmap: CPU affinity reverse-mapping
Date: Fri, 19 Nov 2010 18:44:50 +0000
Message-ID: <1290192290.2671.40.camel@bwh-desktop>
References: <1290192176.2671.38.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1290192176.2671.38.camel@bwh-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When initiating I/O on a multiqueue and multi-IRQ device, we may want
to select a queue for which the response will be handled on the same
or a nearby CPU.  This requires a reverse-map of IRQ affinity.  Add
library functions to support a generic reverse-mapping from CPUs to
objects with affinity and the specific case where the objects are
IRQs.
---
 include/linux/cpu_rmap.h |   73 ++++++++++++
 lib/Kconfig              |    4 +
 lib/Makefile             |    2 +
 lib/cpu_rmap.c           |  272 ++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 351 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/cpu_rmap.h
 create mode 100644 lib/cpu_rmap.c

diff --git a/include/linux/cpu_rmap.h b/include/linux/cpu_rmap.h
new file mode 100644
index 0000000..4771e95
--- /dev/null
+++ b/include/linux/cpu_rmap.h
@@ -0,0 +1,73 @@
+/*
+ * cpu_rmap.c: CPU affinity reverse-map support
+ * Copyright 2010 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <linux/cpumask.h>
+#include <linux/gfp.h>
+#include <linux/slab.h>
+
+/**
+ * struct cpu_rmap - CPU affinity reverse-map
+ * @near: For each CPU, the index and distance to the nearest object,
+ *      based on affinity masks
+ * @size: Number of objects to be reverse-mapped
+ * @used: Number of objects added
+ * @obj: Array of object pointers
+ */
+struct cpu_rmap {
+	struct {
+		u16     index;
+		u16     dist;
+	} near[NR_CPUS];
+	u16		size, used;
+	void		*obj[0];
+};
+#define CPU_RMAP_DIST_INF 0xffff
+
+extern struct cpu_rmap *alloc_cpu_rmap(unsigned int size, gfp_t flags);
+
+/**
+ * free_cpu_rmap - free CPU affinity reverse-map
+ * @rmap: Reverse-map allocated with alloc_cpu_rmap(), or %NULL
+ */
+static inline void free_cpu_rmap(struct cpu_rmap *rmap)
+{
+	kfree(rmap);
+}
+
+extern int cpu_rmap_add(struct cpu_rmap *rmap, void *obj);
+extern void cpu_rmap_update(struct cpu_rmap *rmap, u16 index,
+			    const struct cpumask *affinity);
+
+static inline u16 cpu_rmap_lookup_index(struct cpu_rmap *rmap, unsigned int cpu)
+{
+	return rmap->near[cpu].index;
+}
+
+static inline void *cpu_rmap_lookup_obj(struct cpu_rmap *rmap, unsigned int cpu)
+{
+	return rmap->obj[rmap->near[cpu].index];
+}
+
+#ifdef CONFIG_GENERIC_HARDIRQS
+
+/**
+ * alloc_irq_cpu_rmap - allocate CPU affinity reverse-map for IRQs
+ * @size: Number of objects to be mapped
+ *
+ * Must be called in process context.
+ */
+static inline struct cpu_rmap *alloc_irq_cpu_rmap(unsigned int size)
+{
+	return alloc_cpu_rmap(size, GFP_KERNEL);
+}
+extern void free_irq_cpu_rmap(struct cpu_rmap *rmap);
+
+extern int irq_cpu_rmap_add(struct cpu_rmap *rmap, int irq);
+
+#endif
diff --git a/lib/Kconfig b/lib/Kconfig
index fa9bf2c..a66c76d 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -195,6 +195,10 @@ config DISABLE_OBSOLETE_CPUMASK_FUNCTIONS
        bool "Disable obsolete cpumask functions" if DEBUG_PER_CPU_MAPS
        depends on EXPERIMENTAL && BROKEN
 
+config CPU_RMAP
+	bool
+	depends on SMP
+
 #
 # Netlink attribute parsing support is select'ed if needed
 #
diff --git a/lib/Makefile b/lib/Makefile
index e6a3763..ded1a81 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -106,6 +106,8 @@ obj-$(CONFIG_GENERIC_ATOMIC64) += atomic64.o
 
 obj-$(CONFIG_ATOMIC64_SELFTEST) += atomic64_test.o
 
+obj-$(CONFIG_CPU_RMAP) += cpu_rmap.o
+
 hostprogs-y	:= gen_crc32table
 clean-files	:= crc32table.h
 
diff --git a/lib/cpu_rmap.c b/lib/cpu_rmap.c
new file mode 100644
index 0000000..394f277
--- /dev/null
+++ b/lib/cpu_rmap.c
@@ -0,0 +1,272 @@
+/*
+ * cpu_rmap.c: CPU affinity reverse-map support
+ * Copyright 2010 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <linux/cpu_rmap.h>
+#ifdef CONFIG_GENERIC_HARDIRQS
+#include <linux/interrupt.h>
+#endif
+#include <linux/module.h>
+
+/*
+ * These functions maintain a mapping from CPUs to some ordered set of
+ * objects with CPU affinities.  This can be seen as a reverse-map of
+ * CPU affinity.  However, we do not assume that the object affinities
+ * cover all CPUs in the system.  For those CPUs not directly covered
+ * by object affinities, we attempt to find a nearest object based on
+ * CPU topology.
+ */
+
+/**
+ * alloc_cpu_rmap - allocate CPU affinity reverse-map
+ * @size: Number of objects to be mapped
+ * @flags: Allocation flags e.g. %GFP_KERNEL
+ */
+struct cpu_rmap *alloc_cpu_rmap(unsigned int size, gfp_t flags)
+{
+	struct cpu_rmap *rmap;
+	unsigned int cpu;
+
+	/* This is a silly number of objects, and we use u16 indices. */
+	if (size > 0xffff)
+		return NULL;
+
+	rmap = kzalloc(sizeof(*rmap) + size * sizeof(rmap->obj[0]), flags);
+	if (!rmap)
+		return NULL;
+
+	/* Initially assign CPUs to objects on a rota, since we have
+	 * no idea where the objects are.  Use infinite distance, so
+	 * any object with known distance is preferable.  Include the
+	 * CPUs that are not present/online, since we definitely want
+	 * any newly-hotplugged CPUs to have some object assigned.
+	 */
+	for (cpu = 0; cpu < NR_CPUS; cpu++) {
+		rmap->near[cpu].index = cpu % size;
+		rmap->near[cpu].dist = CPU_RMAP_DIST_INF;
+	}
+
+	rmap->size = size;
+	return rmap;
+}
+EXPORT_SYMBOL(alloc_cpu_rmap);
+
+/* Reevaluate nearest object for neighbours of given object at the
+ * given distance.
+ */
+static void cpu_rmap_update_neigh(struct cpu_rmap *rmap,
+				  const struct cpumask *mask,
+				  u16 index, u16 dist)
+{
+	int neigh;
+
+	for_each_cpu(neigh, mask) {
+		if (dist < rmap->near[neigh].dist) {
+			rmap->near[neigh].index = index;
+			rmap->near[neigh].dist = dist;
+		}
+	}
+}
+
+/* Reevaluate nearest object for given CPU, comparing with the given
+ * neighbours at the given distance.
+ */
+static bool cpu_rmap_copy_neigh(struct cpu_rmap *rmap, unsigned int cpu,
+				const struct cpumask *mask, u16 dist)
+{
+	int neigh;
+
+	for_each_cpu(neigh, mask) {
+		if (rmap->near[neigh].dist <= dist) {
+			rmap->near[cpu].index = rmap->near[neigh].index;
+			rmap->near[cpu].dist = dist;
+			return true;
+		}
+	}
+	return false;
+}
+
+#ifdef DEBUG
+static void debug_print_rmap(const struct cpu_rmap *rmap, const char *prefix)
+{
+	unsigned index;
+	unsigned int cpu;
+
+	pr_info("cpu_rmap %p, %s:\n", rmap, prefix);
+
+	for_each_possible_cpu(cpu) {
+		index = rmap->near[cpu].index;
+		pr_info("cpu %d -> obj %u (distance %u)\n",
+			cpu, index, rmap->near[cpu].dist);
+	}
+}
+#else
+static inline void
+debug_print_rmap(const struct cpu_rmap *rmap, const char *prefix)
+{
+}
+#endif
+
+/**
+ * cpu_rmap_add - add object to a rmap
+ * @rmap: CPU rmap allocated with alloc_cpu_rmap()
+ * @obj: Object to add to rmap
+ *
+ * Return index of object.
+ */
+int cpu_rmap_add(struct cpu_rmap *rmap, void *obj)
+{
+	u16 index;
+
+	BUG_ON(rmap->used >= rmap->size);
+	index = rmap->used++;
+	rmap->obj[index] = obj;
+	return index;
+}
+EXPORT_SYMBOL(cpu_rmap_add);
+
+/**
+ * cpu_rmap_update - update CPU rmap following a change of object affinity
+ * @rmap: CPU rmap to update
+ * @index: Index of object whose affinity changed
+ * @affinity: New CPU affinity of object
+ */
+void cpu_rmap_update(struct cpu_rmap *rmap, u16 index,
+		     const struct cpumask *affinity)
+{
+	unsigned int cpu;
+
+	/* Invalidate old distances to this object */
+	for_each_online_cpu(cpu)
+		if (rmap->near[cpu].index == index)
+			rmap->near[cpu].dist = CPU_RMAP_DIST_INF;
+
+	debug_print_rmap(rmap, "after invalidating old distances");
+
+	/* Set this as the nearest object for all CPUs in the affinity mask,
+	 * plus the following CPUs if they don't have a nearer object:
+	 * - all other threads in the same core (distance 1);
+	 * - all other cores in the same package (distance 2);
+	 * - all other packages in the same NUMA node (distance 3).
+	 */
+	for_each_cpu(cpu, affinity) {
+		rmap->near[cpu].index = index;
+		rmap->near[cpu].dist = 0;
+		cpu_rmap_update_neigh(rmap, topology_thread_cpumask(cpu),
+				      index, 1);
+		cpu_rmap_update_neigh(rmap, topology_core_cpumask(cpu),
+				      index, 2);
+		cpu_rmap_update_neigh(rmap, cpumask_of_node(cpu_to_node(cpu)),
+				      index, 3);
+	}
+
+	debug_print_rmap(rmap, "after updating neighbours");
+
+	/* Find new nearest object for any CPUs left with invalid distances */
+	for_each_online_cpu(cpu) {
+		if (!(rmap->near[cpu].index == index &&
+		      rmap->near[cpu].dist == CPU_RMAP_DIST_INF))
+			continue;
+		if (cpu_rmap_copy_neigh(rmap, cpu,
+					topology_thread_cpumask(cpu), 1))
+			continue;
+		if (cpu_rmap_copy_neigh(rmap, cpu,
+					topology_core_cpumask(cpu), 2))
+			continue;
+		if (cpu_rmap_copy_neigh(rmap, cpu,
+					cpumask_of_node(cpu_to_node(cpu)), 3))
+			continue;
+		/* We could continue into NUMA node distances, but for now
+		 * we give up.
+		 */
+	}
+
+	debug_print_rmap(rmap, "after copying neighbours");
+}
+EXPORT_SYMBOL(cpu_rmap_update);
+
+#ifdef CONFIG_GENERIC_HARDIRQS
+
+/* Glue between IRQ affinity notifiers and CPU rmaps */
+
+struct irq_glue {
+	struct irq_affinity_notify notify;
+	struct cpu_rmap *rmap;
+	u16 index;
+};
+
+/**
+ * free_irq_cpu_rmap - free a CPU affinity reverse-map used for IRQs
+ * @rmap: Reverse-map allocated with alloc_irq_cpu_map(), or %NULL
+ *
+ * Must be called in process context, before freeing the IRQs, and
+ * without holding any locks required by global workqueue items.
+ */
+void free_irq_cpu_rmap(struct cpu_rmap *rmap)
+{
+	struct irq_glue *glue;
+	u16 index;
+
+	if (!rmap)
+		return;
+
+	for (index = 0; index < rmap->used; index++) {
+		glue = rmap->obj[index];
+		irq_set_affinity_notifier(glue->notify.irq, NULL);
+	}
+	irq_run_affinity_notifiers();
+
+	kfree(rmap);
+}
+EXPORT_SYMBOL(free_irq_cpu_rmap);
+
+static void
+irq_cpu_rmap_notify(struct irq_affinity_notify *notify, const cpumask_t *mask)
+{
+	struct irq_glue *glue =
+		container_of(notify, struct irq_glue, notify);
+	cpu_rmap_update(glue->rmap, glue->index, mask);
+}
+
+static void irq_cpu_rmap_release(struct kref *ref)
+{
+	struct irq_glue *glue =
+		container_of(ref, struct irq_glue, notify.kref);
+	kfree(glue);
+}
+
+/**
+ * irq_cpu_rmap_add - add an IRQ to a CPU affinity reverse-map
+ * @rmap: The reverse-map
+ * @irq: The IRQ number
+ *
+ * This adds an IRQ affinity notifier that will update the reverse-map
+ * automatically.
+ *
+ * Must be called in process context, after the IRQ is allocated but
+ * before it is bound with request_irq().
+ */
+int irq_cpu_rmap_add(struct cpu_rmap *rmap, int irq)
+{
+	struct irq_glue *glue = kzalloc(sizeof(*glue), GFP_KERNEL);
+	int rc;
+
+	if (!glue)
+		return -ENOMEM;
+	glue->notify.notify = irq_cpu_rmap_notify;
+	glue->notify.release = irq_cpu_rmap_release;
+	glue->rmap = rmap;
+	glue->index = cpu_rmap_add(rmap, glue);
+	rc = irq_set_affinity_notifier(irq, &glue->notify);
+	if (rc)
+		kfree(glue);
+	return rc;
+}
+EXPORT_SYMBOL(irq_cpu_rmap_add);
+
+#endif /* CONFIG_GENERIC_HARDIRQS */
-- 
1.7.3.2



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
