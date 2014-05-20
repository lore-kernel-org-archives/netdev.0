From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next] genirq: Eliminate explicit dependency between IRQ affinity notifiers and CONFIG_SMP
Date: Tue, 20 May 2014 17:57:00 +0300
Message-ID: <1400597820-30685-1-git-send-email-amirv@mellanox.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eyal Perry <eyalpe@mellanox.com>

Instead of requiring each consumer of the IRQ affinity notifier to have
themselves be explicitly dependent on CONFIG_SMP, make the definition of
struct irq_affinity_notify to exist independently of that config option
and introduce a stub for irq_set_affinity_notifier() under non SMP
configuration.

Fixes: 2eacc23 ("net/mlx4_core: Enforce irq affinity changes
immediatly")

Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 include/linux/interrupt.h | 46 ++++++++++++++++++++++++++--------------------
 1 file changed, 26 insertions(+), 20 deletions(-)

diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
index 97ac926..3f74c059 100644
--- a/include/linux/interrupt.h
+++ b/include/linux/interrupt.h
@@ -199,6 +199,26 @@ extern int check_wakeup_irqs(void);
 static inline int check_wakeup_irqs(void) { return 0; }
 #endif
 
+/**
+ * struct irq_affinity_notify - context for notification of IRQ affinity changes
+ * @irq:		Interrupt to which notification applies
+ * @kref:		Reference count, for internal use
+ * @work:		Work item, for internal use
+ * @notify:		Function to be called on change.  This will be
+ *			called in process context.
+ * @release:		Function to be called on release.  This will be
+ *			called in process context.  Once registered, the
+ *			structure must only be freed when this function is
+ *			called or later.
+ */
+struct irq_affinity_notify {
+	unsigned int irq;
+	struct kref kref;
+	struct work_struct work;
+	void (*notify)(struct irq_affinity_notify *, const cpumask_t *mask);
+	void (*release)(struct kref *ref);
+};
+
 #if defined(CONFIG_SMP)
 
 extern cpumask_var_t irq_default_affinity;
@@ -242,26 +262,6 @@ extern int irq_select_affinity(unsigned int irq);
 
 extern int irq_set_affinity_hint(unsigned int irq, const struct cpumask *m);
 
-/**
- * struct irq_affinity_notify - context for notification of IRQ affinity changes
- * @irq:		Interrupt to which notification applies
- * @kref:		Reference count, for internal use
- * @work:		Work item, for internal use
- * @notify:		Function to be called on change.  This will be
- *			called in process context.
- * @release:		Function to be called on release.  This will be
- *			called in process context.  Once registered, the
- *			structure must only be freed when this function is
- *			called or later.
- */
-struct irq_affinity_notify {
-	unsigned int irq;
-	struct kref kref;
-	struct work_struct work;
-	void (*notify)(struct irq_affinity_notify *, const cpumask_t *mask);
-	void (*release)(struct kref *ref);
-};
-
 extern int
 irq_set_affinity_notifier(unsigned int irq, struct irq_affinity_notify *notify);
 
@@ -284,6 +284,12 @@ static inline int irq_set_affinity_hint(unsigned int irq,
 {
 	return -EINVAL;
 }
+
+static inline int
+irq_set_affinity_notifier(unsigned int irq, struct irq_affinity_notify *notify)
+{
+	return 0;
+}
 #endif /* CONFIG_SMP */
 
 /*
-- 
1.8.3.4
