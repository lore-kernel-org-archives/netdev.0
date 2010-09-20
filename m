From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC][PATCH 1/4] IRQ: IRQ groups for multiqueue devices
Date: Mon, 20 Sep 2010 20:08:05 +0100
Message-ID: <1285009685.2282.127.camel@achroite.uk.solarflarecom.com>
References: <1285009290.2282.121.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:9446 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756688Ab0ITTII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 15:08:08 -0400
In-Reply-To: <1285009290.2282.121.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When initiating I/O on multiqueue devices, we usually want to select a
queue for which the response will be handled on the same or a nearby
CPU.  IRQ groups hold a mapping of CPU to IRQ which will be updated
based on the inverse of IRQ CPU-affinities plus CPU topology
information.
---
 include/linux/irq.h |   52 ++++++++++++++++++
 kernel/irq/manage.c |  149 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 201 insertions(+), 0 deletions(-)

diff --git a/include/linux/irq.h b/include/linux/irq.h
index c03243a..bbddd5f 100644
--- a/include/linux/irq.h
+++ b/include/linux/irq.h
@@ -196,6 +196,8 @@ struct irq_desc {
 #ifdef CONFIG_SMP
 	cpumask_var_t		affinity;
 	const struct cpumask	*affinity_hint;
+	struct irq_group	*group;
+	u16			group_index;
 	unsigned int		node;
 #ifdef CONFIG_GENERIC_PENDING_IRQ
 	cpumask_var_t		pending_mask;
@@ -498,6 +500,33 @@ static inline void free_desc_masks(struct irq_desc *old_desc,
 #endif
 }
 
+/**
+ * struct irq_group - IRQ group for multiqueue devices
+ * @closest: For each CPU, the index and distance to the closest IRQ,
+ *	based on affinity masks
+ * @size: Size of the group
+ * @used: Number of IRQs currently included in the group
+ * @irq: Descriptors for IRQs in the group
+ */
+struct irq_group {
+	struct {
+		u16	index;
+		u16	dist;
+	} closest[NR_CPUS];
+	unsigned int	size, used;
+	struct irq_desc *irq[0];
+};
+#define IRQ_CPU_DIST_INF 0xffff
+
+extern struct irq_group *alloc_irq_group(unsigned int size, gfp_t flags);
+extern void free_irq_group(struct irq_group *group);
+extern void irq_group_add(struct irq_group *group, unsigned int irq);
+
+static inline u16 irq_group_get_index(struct irq_group *group, int cpu)
+{
+	return group->closest[cpu].index;
+}
+
 #else /* !CONFIG_SMP */
 
 static inline bool alloc_desc_masks(struct irq_desc *desc, int node,
@@ -519,6 +548,29 @@ static inline void free_desc_masks(struct irq_desc *old_desc,
 				   struct irq_desc *new_desc)
 {
 }
+
+struct irq_group {
+};
+
+static inline struct irq_group *alloc_irq_group(unsigned int size, gfp_t flags)
+{
+	static struct irq_group dummy;
+	return &dummy;
+}
+
+static inline void free_irq_group(struct irq_group *group)
+{
+}
+
+static inline void irq_group_add(struct irq_group *group, unsigned int irq)
+{
+}
+
+static inline u16 irq_group_get_index(struct irq_group *group, int cpu)
+{
+	return 0;
+}
+
 #endif	/* CONFIG_SMP */
 
 #endif /* _LINUX_IRQ_H */
diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
index c3003e9..3f2b1a9 100644
--- a/kernel/irq/manage.c
+++ b/kernel/irq/manage.c
@@ -100,6 +100,154 @@ void irq_set_thread_affinity(struct irq_desc *desc)
 	}
 }
 
+static void irq_group_update_neigh(struct irq_group *group,
+				   const struct cpumask *mask,
+				   u16 index, u16 dist)
+{
+	int cpu;
+
+	for_each_cpu(cpu, mask) {
+		if (dist < group->closest[cpu].dist) {
+			group->closest[cpu].index = index;
+			group->closest[cpu].dist = dist;
+		}
+	}
+}
+
+static bool irq_group_copy_neigh(struct irq_group *group, int cpu,
+				 const struct cpumask *mask, u16 dist)
+{
+	int neigh;
+
+	for_each_cpu(neigh, mask) {
+		if (group->closest[neigh].dist <= dist) {
+			group->closest[cpu].index = group->closest[neigh].index;
+			group->closest[cpu].dist = dist;
+			return true;
+		}
+	}
+	return false;
+}
+
+/* Update the per-CPU closest IRQs following a change of affinity */
+static void
+irq_update_group(struct irq_desc *desc, const struct cpumask *affinity)
+{
+	struct irq_group *group = desc->group;
+	unsigned index = desc->group_index;
+	int cpu;
+
+	if (!group)
+		return;
+
+	/* Invalidate old distances to this IRQ */
+	for_each_online_cpu(cpu)
+		if (group->closest[cpu].index == index)
+			group->closest[cpu].dist = IRQ_CPU_DIST_INF;
+
+	/*
+	 * Set this as the closest IRQ for all CPUs in the affinity mask,
+	 * plus the following CPUs if they don't have a closer IRQ:
+	 * - all other threads in the same core (distance 1);
+	 * - all other cores in the same package (distance 2);
+	 * - all other packages in the same NUMA node (distance 3).
+	 */
+	for_each_cpu(cpu, affinity) {
+		group->closest[cpu].index = index;
+		group->closest[cpu].dist = 0;
+		irq_group_update_neigh(group, topology_thread_cpumask(cpu),
+				       index, 1);
+		irq_group_update_neigh(group, topology_core_cpumask(cpu),
+				       index, 2);
+		irq_group_update_neigh(group, cpumask_of_node(cpu_to_node(cpu)),
+				       index, 3);
+	}
+
+	/* Find new closest IRQ for any CPUs left with invalid distances */
+	for_each_online_cpu(cpu) {
+		if (!(group->closest[cpu].index == index &&
+		      group->closest[cpu].dist == IRQ_CPU_DIST_INF))
+			continue;
+		if (irq_group_copy_neigh(group, cpu,
+					 topology_thread_cpumask(cpu), 1))
+			continue;
+		if (irq_group_copy_neigh(group, cpu,
+					 topology_core_cpumask(cpu), 2))
+			continue;
+		if (irq_group_copy_neigh(group, cpu,
+					 cpumask_of_node(cpu_to_node(cpu)), 3))
+			continue;
+		/* We could continue into NUMA node distances, but for now
+		 * we give up. */
+	}
+}
+
+/**
+ *	alloc_irq_group - allocate IRQ group
+ *	@size:		Size of the group
+ *	@flags:		Allocation flags e.g. %GFP_KERNEL
+ */
+struct irq_group *alloc_irq_group(unsigned int size, gfp_t flags)
+{
+	struct irq_group *group =
+		kzalloc(sizeof(*group) + size * sizeof(group->irq[0]), flags);
+	int cpu;
+
+	if (!group)
+		return NULL;
+
+	/* Initially assign CPUs to IRQs on a rota */
+	for (cpu = 0; cpu < NR_CPUS; cpu++) {
+		group->closest[cpu].index = cpu % size;
+		group->closest[cpu].dist = IRQ_CPU_DIST_INF;
+	}
+
+	group->size = size;
+	return group;
+}
+EXPORT_SYMBOL(alloc_irq_group);
+
+/**
+ *	free_irq_group - free IRQ group
+ *	@group:		IRQ group allocated with alloc_irq_group(), or %NULL
+ */
+void free_irq_group(struct irq_group *group)
+{
+	struct irq_desc *desc;
+	unsigned int i;
+
+	if (!group)
+		return;
+
+	/* Remove all descriptors from the group */
+	for (i = 0; i < group->used; i++) {
+		desc = group->irq[i];
+		BUG_ON(desc->group != group || desc->group_index != i);
+		desc->group = NULL;
+	}
+
+	kfree(group);
+}
+EXPORT_SYMBOL(free_irq_group);
+
+/**
+ *	irq_group_add - add IRQ to a group
+ *	@group:		IRQ group allocated with alloc_irq_group()
+ *	@irq:		Interrupt to add to group
+ */
+void irq_group_add(struct irq_group *group, unsigned int irq)
+{
+	struct irq_desc *desc = irq_to_desc(irq);
+
+	BUG_ON(desc->group);
+	BUG_ON(group->used >= group->size);
+
+	desc->group = group;
+	desc->group_index = group->used;
+	group->irq[group->used++] = desc;
+}
+EXPORT_SYMBOL(irq_group_add);
+
 /**
  *	irq_set_affinity - Set the irq affinity of a given irq
  *	@irq:		Interrupt to set affinity
@@ -134,6 +282,7 @@ int irq_set_affinity(unsigned int irq, const struct cpumask *cpumask)
 	}
 #endif
 	desc->status |= IRQ_AFFINITY_SET;
+	irq_update_group(desc, cpumask);
 	raw_spin_unlock_irqrestore(&desc->lock, flags);
 	return 0;
 }
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

