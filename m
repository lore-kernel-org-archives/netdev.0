From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [RFC PATCH 1/5] padata: generic interface for parallel processing
Date: Mon, 1 Dec 2008 08:17:09 +0100
Message-ID: <20081201071709.GQ476@secunet.com>
References: <20081201071614.GP476@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	klassert@mathematik.tu-chemnitz.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:46525 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750859AbYLAHsV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Dec 2008 02:48:21 -0500
Content-Disposition: inline
In-Reply-To: <20081201071614.GP476@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>

This patch introduces an interface to process data objects
in parallel. On request it is possible to serialize again.
The parallelized objects return in the same order as they
were before the parallelization.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/linux/interrupt.h |    1 +
 include/linux/padata.h    |  115 +++++++++++
 kernel/Makefile           |    2 +-
 kernel/padata.c           |  489 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 606 insertions(+), 1 deletions(-)
 create mode 100644 include/linux/padata.h
 create mode 100644 kernel/padata.c

diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
index f58a0cf..4d2f4bb 100644
--- a/include/linux/interrupt.h
+++ b/include/linux/interrupt.h
@@ -254,6 +254,7 @@ enum
 #ifdef CONFIG_HIGH_RES_TIMERS
 	HRTIMER_SOFTIRQ,
 #endif
+	PADATA_SOFTIRQ,
 	RCU_SOFTIRQ, 	/* Preferable RCU should always be the last softirq */
 
 	NR_SOFTIRQS
diff --git a/include/linux/padata.h b/include/linux/padata.h
new file mode 100644
index 0000000..6447c93
--- /dev/null
+++ b/include/linux/padata.h
@@ -0,0 +1,115 @@
+/*
+ * padata.h - header for the padata parallelization interface
+ *
+ * Copyright (C) 2008 secunet Security Networks AG
+ * Copyright (C) 2008 Steffen Klassert <steffen.klassert@secunet.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ */
+
+#ifndef PADATA_H
+#define PADATA_H
+
+#include <linux/interrupt.h>
+#include <linux/smp.h>
+#include <linux/list.h>
+
+enum
+{
+	NO_PADATA=0,
+	NR_PADATA
+};
+
+struct padata_priv {
+	struct list_head	list;
+	struct call_single_data	csd;
+	int			cb_cpu;
+	int			seq_nr;
+	unsigned int		nr;
+	int			info;
+};
+
+struct padata_queue {
+	struct list_head        list;
+	atomic_t                num_obj;
+	int               	cpu_index;
+	spinlock_t              lock;
+};
+
+struct parallel_data {
+	struct work_struct	work;
+	struct padata_queue	*queue;
+	atomic_t		seq_nr;
+	atomic_t		queued_objects;
+	cpumask_t		cpu_map;
+	cpumask_t		new_cpu_map;
+	u8			flags;
+#define	PADATA_INIT			1
+#define	PADATA_FLUSH_HARD		2
+#define	PADATA_RESET_IN_PROGRESS	4
+	void			(*serial)(unsigned long data);
+	spinlock_t              lock;
+};
+
+#ifdef CONFIG_USE_GENERIC_SMP_HELPERS
+extern void __init padata_init(unsigned int nr, cpumask_t cpu_map,
+		void (*serial)(unsigned long data));
+extern void padata_dont_wait(unsigned int nr, struct padata_priv *padata);
+extern int padata_do_parallel(unsigned int softirq_nr, unsigned int nr,
+		struct padata_priv *padata, int cb_cpu);
+extern int padata_do_serial(unsigned int nr, struct padata_priv *padata);
+extern cpumask_t padata_get_cpumap(unsigned int nr);
+extern void padata_set_cpumap(unsigned int nr, cpumask_t cpu_map);
+extern void padata_add_cpu(unsigned int nr, int cpu);
+extern void padata_remove_cpu(unsigned int nr, int cpu);
+extern void padata_start(unsigned int nr);
+extern void padata_stop(unsigned int nr);
+#else
+void padata_init(unsigned int nr,cpumask_t cpu_map,
+		void (*serial)(unsigned long data));
+{
+}
+void padata_dont_wait(unsigned int nr, struct padata_priv *padata)
+{
+}
+int padata_do_parallel(unsigned int softirq_nr, unsigned int nr,
+		struct padata_priv *padata, int cb_cpu)
+{
+	return 0;
+}
+int padata_do_serial(unsigned int nr, struct padata_priv *padata)
+{
+	return 0;
+}
+cpumask_t padata_get_cpumap(unsigned int nr)
+{
+	return cpu_online_map;
+}
+void padata_set_cpumap(unsigned int nr, cpumask_t cpu_map)
+{
+}
+padata_add_cpu(unsigned int nr, int cpu)
+{
+}
+padata_remove_cpu(unsigned int nr, int cpu)
+{
+}
+padata_start(unsigned int nr)
+{
+}
+padata_stop(unsigned int nr)
+{
+}
+#endif
+#endif
diff --git a/kernel/Makefile b/kernel/Makefile
index 19fad00..730a401 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -40,7 +40,7 @@ obj-$(CONFIG_RT_MUTEXES) += rtmutex.o
 obj-$(CONFIG_DEBUG_RT_MUTEXES) += rtmutex-debug.o
 obj-$(CONFIG_RT_MUTEX_TESTER) += rtmutex-tester.o
 obj-$(CONFIG_GENERIC_ISA_DMA) += dma.o
-obj-$(CONFIG_USE_GENERIC_SMP_HELPERS) += smp.o
+obj-$(CONFIG_USE_GENERIC_SMP_HELPERS) += smp.o padata.o
 obj-$(CONFIG_SMP) += spinlock.o
 obj-$(CONFIG_DEBUG_SPINLOCK) += spinlock.o
 obj-$(CONFIG_PROVE_LOCKING) += spinlock.o
diff --git a/kernel/padata.c b/kernel/padata.c
new file mode 100644
index 0000000..20eccbd
--- /dev/null
+++ b/kernel/padata.c
@@ -0,0 +1,489 @@
+/*
+ * padata.c - generic interface to process data streams in parallel
+ *
+ * Copyright (C) 2008 secunet Security Networks AG
+ * Copyright (C) 2008 Steffen Klassert <steffen.klassert@secunet.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ */
+
+#include <linux/module.h>
+#include <linux/cpumask.h>
+#include <linux/err.h>
+#include <linux/padata.h>
+
+#define MAX_SEQ_NR  1000000000
+
+static struct parallel_data padata_vec[NR_PADATA];
+static struct padata_priv *padata_get_next(struct parallel_data *par_data);
+
+static void padata_flush_hard(struct parallel_data *par_data)
+{
+	int cpu;
+	struct padata_priv *padata;
+	struct padata_queue *queue;
+
+	for_each_cpu_mask(cpu, par_data->cpu_map) {
+		queue = per_cpu_ptr(par_data->queue, cpu);
+
+		while(!list_empty(&queue->list)) {
+		padata = list_entry(queue->list.next, struct padata_priv, list);
+
+		spin_lock(&queue->lock);
+		list_del_init(&padata->list);
+		spin_unlock(&queue->lock);
+
+		atomic_dec(&par_data->queued_objects);
+		par_data->serial((unsigned long ) padata);
+		}
+	}
+}
+
+static void padata_flush_order(struct parallel_data *par_data)
+{
+	struct padata_priv *padata;
+
+	while (1) {
+		padata = padata_get_next(par_data);
+
+		if (padata && !IS_ERR(padata))
+			par_data->serial((unsigned long ) padata);
+		else
+			break;
+	}
+
+	padata_flush_hard(par_data);
+}
+
+static void padata_reset_work(struct work_struct *work)
+{
+	int cpu, cpu_index;
+	struct padata_queue *queue;
+	struct parallel_data *par_data;
+
+	par_data = container_of(work, struct parallel_data, work);
+
+	if (par_data->flags & (PADATA_INIT|PADATA_RESET_IN_PROGRESS))
+		return;
+
+	spin_lock_bh(&par_data->lock);
+	par_data->flags |= PADATA_RESET_IN_PROGRESS;
+
+	if (!(par_data->flags & PADATA_FLUSH_HARD))
+		padata_flush_order(par_data);
+	else
+		padata_flush_hard(par_data);
+
+	cpu_index = 0;
+
+	par_data->cpu_map = par_data->new_cpu_map;
+
+	for_each_cpu_mask(cpu, par_data->cpu_map) {
+		queue = per_cpu_ptr(par_data->queue, cpu);
+
+		atomic_set(&queue->num_obj, 0);
+		queue->cpu_index = cpu_index;
+		cpu_index++;
+	}
+	spin_unlock_bh(&par_data->lock);
+
+	atomic_set(&par_data->seq_nr, -1);
+	par_data->flags &= ~PADATA_RESET_IN_PROGRESS;
+	par_data->flags |= PADATA_INIT;
+}
+
+static struct padata_priv *padata_get_next(struct parallel_data *par_data)
+{
+	int cpu, num_cpus, empty;
+	int seq_nr, calc_seq_nr, next_nr;
+	struct padata_queue *queue, *next_queue;
+	struct padata_priv *padata;
+
+	empty = 0;
+	next_nr = -1;
+	next_queue = NULL;
+
+	num_cpus = cpus_weight(par_data->cpu_map);
+
+	for_each_cpu_mask(cpu, par_data->cpu_map) {
+		queue = per_cpu_ptr(par_data->queue, cpu);
+
+		/*
+		 * Calculate the seq_nr of the object that should be
+		 * next in this queue.
+		 */
+		calc_seq_nr = (atomic_read(&queue->num_obj) * num_cpus)
+						+ queue->cpu_index;
+
+		if (!list_empty(&queue->list)) {
+			padata = list_entry(queue->list.next,
+					struct padata_priv, list);
+
+			seq_nr  = padata->seq_nr;
+
+			if (unlikely(calc_seq_nr != seq_nr)) {
+				par_data->flags &= ~PADATA_INIT;
+				par_data->flags |= PADATA_FLUSH_HARD;
+				padata = NULL;
+				goto out;
+			}
+		} else {
+			seq_nr = calc_seq_nr;
+			empty++;
+		}
+
+		if (next_nr < 0 || seq_nr < next_nr) {
+			next_nr = seq_nr;
+			next_queue = queue;
+		}
+	}
+
+	padata = NULL;
+
+	if (empty == num_cpus)
+		goto out;
+
+	if (!list_empty(&next_queue->list)) {
+		padata = list_entry(next_queue->list.next,
+				struct padata_priv, list);
+
+		spin_lock(&next_queue->lock);
+		list_del_init(&padata->list);
+		spin_unlock(&next_queue->lock);
+
+		atomic_dec(&par_data->queued_objects);
+		atomic_inc(&next_queue->num_obj);
+
+		goto out;
+	}
+
+	if (next_nr % num_cpus == next_queue->cpu_index) {
+		padata = ERR_PTR(-ENODATA);
+		goto out;
+	}
+
+	padata = ERR_PTR(-EINPROGRESS);
+out:
+	return padata;
+}
+
+static void padata_action(struct softirq_action *h)
+{
+	struct list_head *cpu_list, local_list;
+
+	cpu_list = &__get_cpu_var(softirq_work_list[PADATA_SOFTIRQ]);
+
+	local_irq_disable();
+	list_replace_init(cpu_list, &local_list);
+	local_irq_enable();
+
+	while (!list_empty(&local_list)) {
+		struct padata_priv *padata;
+
+		padata = list_entry(local_list.next,
+				struct padata_priv, csd.list);
+
+		list_del_init(&padata->csd.list);
+
+		padata_vec[padata->nr].serial((unsigned long ) padata);
+	}
+}
+
+static int padata_cpu_hash(unsigned int nr, struct padata_priv *padata)
+{
+	int cpu, target_cpu, this_cpu, cpu_index;
+
+	this_cpu = smp_processor_id();
+
+	if (padata->nr != 0)
+		return this_cpu;
+
+	if (!(padata_vec[nr].flags & PADATA_INIT))
+		return this_cpu;
+
+	padata->seq_nr = atomic_inc_return(&padata_vec[nr].seq_nr);
+
+	if (padata->seq_nr > MAX_SEQ_NR) {
+		padata_vec[nr].flags &= ~PADATA_INIT;
+		padata->seq_nr = 0;
+		schedule_work(&padata_vec[nr].work);
+		return this_cpu;
+	}
+
+	padata->nr = nr;
+
+	/*
+	 * Hash the sequence numbers to the cpus by taking
+	 * seq_nr mod. number of cpus in use.
+	 */
+	cpu_index =  padata->seq_nr % cpus_weight(padata_vec[nr].cpu_map);
+
+	target_cpu = first_cpu(padata_vec[nr].cpu_map);
+	for (cpu = 0; cpu < cpu_index; cpu++)
+		target_cpu = next_cpu(target_cpu, padata_vec[nr].cpu_map);
+
+	return target_cpu;
+}
+
+/*
+ * padata_dont_wait - must be called if an object that runs in parallel will
+ * not be serialized with padata_do_serial
+ *
+ * @nr: number of the padata istance
+ * @padata: object that will not be seen by padata_do_serial
+ */
+void padata_dont_wait(unsigned int nr, struct padata_priv *padata)
+{
+	struct padata_queue *queue;
+
+	if (!(padata_vec[nr].flags & PADATA_INIT))
+		return;
+
+	if (padata->nr == 0 || padata->nr != nr)
+		return;
+
+	queue = per_cpu_ptr(padata_vec[nr].queue, smp_processor_id());
+	atomic_inc(&queue->num_obj);
+
+	padata->nr = 0;
+	padata->seq_nr = 0;
+}
+EXPORT_SYMBOL(padata_dont_wait);
+
+/*
+ * padata_do_parallel - padata parallelization function
+ *
+ * @softirq_nr: number of the softirq that will do the parallelization
+ * @nr: number of the padata istance
+ * @padata: object to be paralellized
+ * @cb_cpu: cpu number on which the serialization callback function will run
+ */
+int padata_do_parallel(unsigned int softirq_nr, unsigned int nr,
+			struct padata_priv *padata, int cb_cpu)
+{
+	int target_cpu;
+
+	padata->cb_cpu = cb_cpu;
+
+	local_bh_disable();
+	target_cpu = padata_cpu_hash(nr, padata);
+	local_bh_enable();
+
+	send_remote_softirq(&padata->csd, target_cpu, softirq_nr);
+
+	return 1;
+}
+EXPORT_SYMBOL(padata_do_parallel);
+
+/*
+ * padata_do_serial - padata serialization function
+ *
+ * @nr: number of the padata istance
+ * @padata: object to be serialized
+ *
+ * returns 1 if the serialization callback function will be called
+ * from padata, 0 else
+ */
+int padata_do_serial(unsigned int nr, struct padata_priv *padata)
+{
+	int cpu;
+	struct padata_queue *reorder_queue;
+
+	if (!(padata_vec[nr].flags & PADATA_INIT))
+		return 0;
+
+	if (padata->nr != nr || padata->nr == 0) {
+		padata_vec[nr].serial((unsigned long ) padata);
+		return 1;
+	}
+
+	cpu = smp_processor_id();
+
+	reorder_queue = per_cpu_ptr(padata_vec[nr].queue, cpu);
+
+	spin_lock(&reorder_queue->lock);
+	list_add_tail(&padata->list, &reorder_queue->list);
+	spin_unlock(&reorder_queue->lock);
+
+	atomic_inc(&padata_vec[nr].queued_objects);
+
+try_again:
+	if (!spin_trylock(&padata_vec[nr].lock))
+		goto out;
+
+	while(1) {
+		padata = padata_get_next(&padata_vec[nr]);
+
+		if (!padata || PTR_ERR(padata) == -EINPROGRESS)
+			break;
+		if (PTR_ERR(padata) == -ENODATA) {
+			spin_unlock(&padata_vec[nr].lock);
+			goto out;
+		}
+
+		send_remote_softirq(&padata->csd, padata->cb_cpu,
+				PADATA_SOFTIRQ);
+	}
+
+	if (unlikely(!(padata_vec[nr].flags & PADATA_INIT))) {
+		spin_unlock(&padata_vec[nr].lock);
+		goto reset_out;
+	}
+
+	spin_unlock(&padata_vec[nr].lock);
+
+	if (atomic_read(&padata_vec[nr].queued_objects))
+		goto try_again;
+
+out:
+	return 1;
+reset_out:
+	schedule_work(&padata_vec[nr].work);
+	return 1;
+}
+EXPORT_SYMBOL(padata_do_serial);
+
+/*
+ * padata_get_cpumap - get the cpu map that is actually in use
+ *
+ * @nr: number of the padata istance
+ */
+cpumask_t padata_get_cpumap(unsigned int nr)
+{
+	return padata_vec[nr].cpu_map;
+}
+EXPORT_SYMBOL(padata_get_cpumap);
+
+/*
+ * padata_set_cpumap - set the cpu map that padata uses
+ *
+ * @nr: number of the padata istance
+ * @cpu_map: the cpu map to use
+ */
+void padata_set_cpumap(unsigned int nr, cpumask_t cpu_map)
+{
+	padata_vec[nr].new_cpu_map = cpu_map;
+	padata_vec[nr].flags &= ~PADATA_INIT;
+	padata_vec[nr].flags |= PADATA_FLUSH_HARD;
+
+	schedule_work(&padata_vec[nr].work);
+}
+EXPORT_SYMBOL(padata_set_cpumap);
+
+/*
+ * padata_add_cpu - add a cpu to the padata cpu map
+ *
+ * @nr: number of the padata istance
+ * @cpu: cpu to remove
+ */
+void padata_add_cpu(unsigned int nr, int cpu)
+{
+	cpumask_t cpu_map = padata_vec[nr].cpu_map;
+
+	cpu_set(cpu, cpu_map);
+	padata_set_cpumap(nr, cpu_map);
+}
+EXPORT_SYMBOL(padata_add_cpu);
+
+/*
+ * padata_remove_cpu - remove a cpu from the padata cpu map
+ *
+ * @nr: number of the padata istance
+ * @cpu: cpu to remove
+ */
+void padata_remove_cpu(unsigned int nr, int cpu)
+{
+	cpumask_t cpu_map = padata_vec[nr].cpu_map;
+
+	cpu_clear(cpu, cpu_map);
+	padata_set_cpumap(nr, cpu_map);
+}
+EXPORT_SYMBOL(padata_remove_cpu);
+
+/*
+ * padata_start - start the parallel processing
+ *
+ * @nr: number of the padata istance
+ */
+void padata_start(unsigned int nr)
+{
+	if (padata_vec[nr].flags & PADATA_INIT)
+		return;
+
+	schedule_work(&padata_vec[nr].work);
+}
+EXPORT_SYMBOL(padata_start);
+
+/*
+ * padata_stop - stop the parallel processing
+ *
+ * @nr: number of the padata istance
+ */
+void padata_stop(unsigned int nr)
+{
+	padata_vec[nr].flags &= ~PADATA_INIT;
+}
+EXPORT_SYMBOL(padata_stop);
+
+/*
+ * padata_init - initialize a padata instance
+ *
+ * @nr: number of the padata istance
+ * @cpu_map: map of the cpu set that padata uses for parallelization
+ * @serial: the serialization callback function
+ *
+ * The serialization callback function must be able to run in softirq context.
+ */
+void __init padata_init(unsigned int nr, cpumask_t cpu_map,
+			void (*serial)(unsigned long data))
+{
+	int cpu, cpu_index;
+	struct padata_queue *percpu_queue, *queue;
+
+	percpu_queue = alloc_percpu(struct padata_queue);
+
+	if (!percpu_queue) {
+		printk("padata_init: Failed to alloc the serialization"
+				"queues for padata nr %d, exiting!\n", nr);
+		return;
+	}
+
+	open_softirq(PADATA_SOFTIRQ, padata_action);
+
+	cpu_index = 0;
+
+	for_each_possible_cpu(cpu) {
+		queue = per_cpu_ptr(percpu_queue, cpu);
+
+		if (cpu_isset(cpu, cpu_map)) {
+			queue->cpu_index = cpu_index;
+			cpu_index++;
+		}
+
+		INIT_LIST_HEAD(&queue->list);
+		spin_lock_init(&queue->lock);
+		atomic_set(&queue->num_obj, 0);
+	}
+
+	INIT_WORK(&padata_vec[nr].work, padata_reset_work);
+
+	atomic_set(&padata_vec[nr].seq_nr, -1);
+	atomic_set(&padata_vec[nr].queued_objects, 0);
+	padata_vec[nr].cpu_map = cpu_map;
+	padata_vec[nr].new_cpu_map = cpu_map;
+	padata_vec[nr].queue = percpu_queue;
+	padata_vec[nr].serial = serial;
+	padata_vec[nr].flags = 0;
+}
+EXPORT_SYMBOL(padata_init);
-- 
1.5.4.2

