From: "Arnaldo Carvalho de Melo" <acme@redhat.com>
Subject: [PATCH 1/2] [LIB]: Introduce struct pcounter
Date: Wed, 7 Nov 2007 14:16:15 -0200
Message-ID: <20071107161615.GL27345@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45281 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753554AbXKGQQr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 11:16:47 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This just generalises what was introduced by Eric Dumazet for the struct proto
inuse field in 286ab3d46058840d68e5d7d52e316c1f7e98c59f:

    [NET]: Define infrastructure to keep 'inuse' changes in an efficent SMP/NUMA way.

Please look at the comment in there to see the rationale.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 include/linux/pcounter.h |  102 ++++++++++++++++++++++++++++++++++++++++++++++
 lib/Makefile             |    1 +
 lib/pcounter.c           |   26 ++++++++++++
 3 files changed, 129 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/pcounter.h
 create mode 100644 lib/pcounter.c

diff --git a/include/linux/pcounter.h b/include/linux/pcounter.h
new file mode 100644
index 0000000..3d3891b
--- /dev/null
+++ b/include/linux/pcounter.h
@@ -0,0 +1,102 @@
+#ifndef __LINUX_PCOUNTER_H
+#define __LINUX_PCOUNTER_H
+
+struct pcounter {
+#ifdef CONFIG_SMP
+	void		(*add)(struct pcounter *self, int inc);
+	int		(*getval)(const struct pcounter *self);
+	int		*per_cpu_values;
+#else
+	int		val;
+#endif
+};
+
+/*
+ * Special macros to let pcounters use a fast version of {getvalue|add}
+ * using a static percpu variable per pcounter instead of an allocated one,
+ * saving one dereference.
+ * This might be changed if/when dynamic percpu vars become fast.
+ */
+#ifdef CONFIG_SMP
+#include <linux/cpumask.h>
+#include <linux/percpu.h>
+
+#define DEFINE_PCOUNTER(NAME)					\
+static DEFINE_PER_CPU(int, NAME##_pcounter_values);		\
+static void NAME##_pcounter_add(struct pcounter *self, int inc)	\
+{								\
+       __get_cpu_var(NAME##_pcounter_values) += inc;		\
+}								\
+								\
+static int NAME##_pcounter_getval(const struct pcounter *self)	\
+{								\
+       int res = 0, cpu;					\
+								\
+       for_each_possible_cpu(cpu)				\
+               res += per_cpu(NAME##_pcounter_values, cpu);	\
+       return res;						\
+}
+								
+#define PCOUNTER_MEMBER_INITIALIZER(NAME, MEMBER)		\
+	MEMBER = {						\
+		.add	= NAME##_pcounter_add,			\
+		.getval = NAME##_pcounter_getval,		\
+	}
+
+extern void pcounter_def_add(struct pcounter *self, int inc);
+extern int pcounter_def_getval(const struct pcounter *self);
+
+static inline int pcounter_alloc(struct pcounter *self)
+{
+	int rc = 0;
+	if (self->add == NULL) {
+		self->per_cpu_values = alloc_percpu(int);
+		if (self->per_cpu_values != NULL) {
+			self->add    = pcounter_def_add;
+			self->getval = pcounter_def_getval;
+		} else
+			rc = 1;
+	}
+	return rc;
+}
+
+static inline void pcounter_free(struct pcounter *self)
+{
+	if (self->per_cpu_values != NULL) {
+		free_percpu(self->per_cpu_values);
+		self->per_cpu_values = NULL;
+		self->getval = NULL;
+		self->add = NULL;
+	}
+}
+
+static inline void pcounter_add(struct pcounter *self, int inc)
+{
+	self->add(self, inc);
+}
+
+static inline int pcounter_getval(const struct pcounter *self)
+{
+	return self->getval(self);
+}
+
+#else /* CONFIG_SMP */
+
+static inline void pcounter_add(struct pcounter *self, int inc)
+{
+	self->value += inc;
+}
+
+static inline int pcounter_getval(const struct pcounter *self)
+{
+	return self->val;
+}
+
+#define DEFINE_PCOUNTER(NAME)
+#define PCOUNTER_MEMBER_INITIALIZER(NAME, MEMBER)
+#define pcounter_alloc(self) 0
+#define pcounter_free(self)
+
+#endif /* CONFIG_SMP */
+
+#endif /* __LINUX_PCOUNTER_H */
diff --git a/lib/Makefile b/lib/Makefile
index 3a0983b..0fe94ec 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -61,6 +61,7 @@ obj-$(CONFIG_TEXTSEARCH_KMP) += ts_kmp.o
 obj-$(CONFIG_TEXTSEARCH_BM) += ts_bm.o
 obj-$(CONFIG_TEXTSEARCH_FSM) += ts_fsm.o
 obj-$(CONFIG_SMP) += percpu_counter.o
+obj-$(CONFIG_SMP) += pcounter.o
 obj-$(CONFIG_AUDIT_GENERIC) += audit.o
 
 obj-$(CONFIG_SWIOTLB) += swiotlb.o
diff --git a/lib/pcounter.c b/lib/pcounter.c
new file mode 100644
index 0000000..e89880e
--- /dev/null
+++ b/lib/pcounter.c
@@ -0,0 +1,26 @@
+/*
+ * Define default pcounter functions 
+ * Note that often used pcounters use dedicated functions to get a speed increase.
+ * (see DEFINE_PCOUNTER/REF_PCOUNTER_MEMBER)
+ */
+
+#include <linux/module.h>
+#include <linux/pcounter.h>
+#include <linux/smp.h>
+
+void pcounter_def_add(struct pcounter *self, int inc)
+{
+	per_cpu_ptr(self->per_cpu_values, smp_processor_id())[0] += inc;
+}
+
+EXPORT_SYMBOL_GPL(pcounter_def_add);
+
+int pcounter_def_getval(const struct pcounter *self)
+{
+	int res = 0, cpu;
+	for_each_possible_cpu(cpu)
+		res += per_cpu_ptr(self->per_cpu_values, cpu)[0];
+	return res;
+}
+
+EXPORT_SYMBOL_GPL(pcounter_def_getval);
-- 
1.5.3.4

