From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V5 1/2] irq: Utility function to get affinity_hint by policy
Date: Tue, 11 Mar 2014 09:33:26 +0200
Message-ID: <1394523207-7338-2-git-send-email-amirv@mellanox.com>
References: <1394523207-7338-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Amir Vadai <amirv@mellanox.com>,
	Prarit Bhargava <prarit@redhat.com>,
	Govindarajulu Varadarajan <gvaradar@cisco.com>
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394523207-7338-1-git-send-email-amirv@mellanox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This function sets the affinity_mask for a multi queue device according
to a numa aware policy. affinity_mask could be used as an affinity hint
for the IRQ related to this queue.
Current policy is to spread queues accross cores - local cores first.
It could be extended in the future.

CC: Prarit Bhargava <prarit@redhat.com>
CC: Govindarajulu Varadarajan <gvaradar@cisco.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 include/linux/interrupt.h |  9 ++++++++
 kernel/irq/manage.c       | 58 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 67 insertions(+)

diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
index a2678d3..81baefb 100644
--- a/include/linux/interrupt.h
+++ b/include/linux/interrupt.h
@@ -208,6 +208,8 @@ extern int irq_select_affinity(unsigned int irq);
 
 extern int irq_set_affinity_hint(unsigned int irq, const struct cpumask *m);
 
+extern int irq_set_mq_dev_affinit_hint(int q, int numa_node,
+				       cpumask_t *affinity_mask);
 /**
  * struct irq_affinity_notify - context for notification of IRQ affinity changes
  * @irq:		Interrupt to which notification applies
@@ -250,6 +252,13 @@ static inline int irq_set_affinity_hint(unsigned int irq,
 {
 	return -EINVAL;
 }
+
+static inline int irq_set_mq_dev_affinit_hint(int q, int numa_node,
+					      cpumask_t *affinity_mask)
+{
+	return -EINVAL;
+}
+
 #endif /* CONFIG_SMP */
 
 /*
diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
index 481a13c..8d98e6e 100644
--- a/kernel/irq/manage.c
+++ b/kernel/irq/manage.c
@@ -221,6 +221,64 @@ int irq_set_affinity_hint(unsigned int irq, const struct cpumask *m)
 }
 EXPORT_SYMBOL_GPL(irq_set_affinity_hint);
 
+/**
+ * irq_set_mq_dev_affinit_hint - set affinity hint of a queue in multi queue
+ * device
+ * @q: queue index number
+ * @numa_node: prefered numa_node
+ * @affinity_mask: the relevant cpu bit is set according to the policy
+ *
+ * This function sets the affinity_mask according to a numa aware policy.
+ * affinity_mask could be used as an affinity hint for the IRQ related to this
+ * queue.
+ * The policy is to spread queues across cores - local cores first.
+ *
+ * Returns 0 on success, or a negative error code.
+ */
+int irq_set_mq_dev_affinit_hint(int q, int numa_node,
+				cpumask_t *affinity_mask)
+{
+	cpumask_var_t mask;
+	int affinity_cpu;
+	int ret = 0;
+
+	if (!zalloc_cpumask_var(&mask, GFP_KERNEL))
+		return -ENOMEM;
+
+	q %= num_online_cpus();
+
+	if (!cpumask_of_node(numa_node)) {
+		cpumask_copy(mask, cpu_online_mask);
+	} else {
+		int n;
+
+		cpumask_and(mask,
+			    cpumask_of_node(numa_node), cpu_online_mask);
+
+		n = cpumask_weight(mask);
+		if (q >= n) {
+			q -= n;
+			cpumask_andnot(mask, cpu_online_mask, mask);
+		}
+	}
+
+	for_each_cpu(affinity_cpu, mask) {
+		if (--q < 0)
+			goto out;
+	}
+
+	ret = -EINVAL;
+
+out:
+	free_cpumask_var(mask);
+
+	if (!ret)
+		cpumask_set_cpu(affinity_cpu, affinity_mask);
+
+	return ret;
+}
+EXPORT_SYMBOL(irq_set_mq_dev_affinit_hint);
+
 static void irq_affinity_notify(struct work_struct *work)
 {
 	struct irq_affinity_notify *notify =
-- 
1.8.3.4
