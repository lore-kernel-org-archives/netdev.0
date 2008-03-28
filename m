From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 5/5][LIB]: Drop the pcounter itself.
Date: Fri, 28 Mar 2008 15:39:53 +0300
Message-ID: <47ECE719.5090409@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:57494 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753797AbYC1MkA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 08:40:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The knock-out. The pcounter abstraction is not used any longer
in the kernel.

Not sure whether this should go via netdev tree, but as far as
I remember it was added via this one, and besides Eric thinks
that Andrew shouldn't mind this.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/linux/pcounter.h |   74 ----------------------------------------------
 lib/Makefile             |    1 -
 lib/pcounter.c           |   58 ------------------------------------
 3 files changed, 0 insertions(+), 133 deletions(-)
 delete mode 100644 include/linux/pcounter.h
 delete mode 100644 lib/pcounter.c

diff --git a/include/linux/pcounter.h b/include/linux/pcounter.h
deleted file mode 100644
index a82d9f2..0000000
--- a/include/linux/pcounter.h
+++ /dev/null
@@ -1,74 +0,0 @@
-#ifndef __LINUX_PCOUNTER_H
-#define __LINUX_PCOUNTER_H
-/*
- * Using a dynamic percpu 'int' variable has a cost :
- * 1) Extra dereference
- * Current per_cpu_ptr() implementation uses an array per 'percpu variable'.
- * 2) memory cost of NR_CPUS*(32+sizeof(void *)) instead of num_possible_cpus()*4
- *
- * This pcounter implementation is an abstraction to be able to use
- * either a static or a dynamic per cpu variable.
- * One dynamic per cpu variable gets a fast & cheap implementation, we can
- * change pcounter implementation too.
- */
-struct pcounter {
-#ifdef CONFIG_SMP
-	void		(*add)(struct pcounter *self, int inc);
-	int		(*getval)(const struct pcounter *self, int cpu);
-	int		*per_cpu_values;
-#else
-	int		val;
-#endif
-};
-
-#ifdef CONFIG_SMP
-#include <linux/percpu.h>
-
-#define DEFINE_PCOUNTER(NAME)						\
-static DEFINE_PER_CPU(int, NAME##_pcounter_values);			\
-static void NAME##_pcounter_add(struct pcounter *self, int val)		\
-{									\
-       __get_cpu_var(NAME##_pcounter_values) += val;			\
-}									\
-static int NAME##_pcounter_getval(const struct pcounter *self, int cpu)	\
-{									\
-	return per_cpu(NAME##_pcounter_values, cpu);			\
-}									\
-
-#define PCOUNTER_MEMBER_INITIALIZER(NAME, MEMBER)		\
-	MEMBER = {						\
-		.add	= NAME##_pcounter_add,			\
-		.getval = NAME##_pcounter_getval,		\
-	}
-
-
-static inline void pcounter_add(struct pcounter *self, int inc)
-{
-	self->add(self, inc);
-}
-
-extern int pcounter_getval(const struct pcounter *self);
-extern int pcounter_alloc(struct pcounter *self);
-extern void pcounter_free(struct pcounter *self);
-
-
-#else /* CONFIG_SMP */
-
-static inline void pcounter_add(struct pcounter *self, int inc)
-{
-	self->val += inc;
-}
-
-static inline int pcounter_getval(const struct pcounter *self)
-{
-	return self->val;
-}
-
-#define DEFINE_PCOUNTER(NAME)
-#define PCOUNTER_MEMBER_INITIALIZER(NAME, MEMBER)
-#define pcounter_alloc(self) 0
-#define pcounter_free(self)
-
-#endif /* CONFIG_SMP */
-
-#endif /* __LINUX_PCOUNTER_H */
diff --git a/lib/Makefile b/lib/Makefile
index 23de261..4d059d4 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -61,7 +61,6 @@ obj-$(CONFIG_TEXTSEARCH_KMP) += ts_kmp.o
 obj-$(CONFIG_TEXTSEARCH_BM) += ts_bm.o
 obj-$(CONFIG_TEXTSEARCH_FSM) += ts_fsm.o
 obj-$(CONFIG_SMP) += percpu_counter.o
-obj-$(CONFIG_SMP) += pcounter.o
 obj-$(CONFIG_AUDIT_GENERIC) += audit.o
 
 obj-$(CONFIG_SWIOTLB) += swiotlb.o
diff --git a/lib/pcounter.c b/lib/pcounter.c
deleted file mode 100644
index 9b56807..0000000
--- a/lib/pcounter.c
+++ /dev/null
@@ -1,58 +0,0 @@
-/*
- * Define default pcounter functions
- * Note that often used pcounters use dedicated functions to get a speed increase.
- * (see DEFINE_PCOUNTER/REF_PCOUNTER_MEMBER)
- */
-
-#include <linux/module.h>
-#include <linux/pcounter.h>
-#include <linux/smp.h>
-#include <linux/cpumask.h>
-
-static void pcounter_dyn_add(struct pcounter *self, int inc)
-{
-	per_cpu_ptr(self->per_cpu_values, smp_processor_id())[0] += inc;
-}
-
-static int pcounter_dyn_getval(const struct pcounter *self, int cpu)
-{
-	return per_cpu_ptr(self->per_cpu_values, cpu)[0];
-}
-
-int pcounter_getval(const struct pcounter *self)
-{
-	int res = 0, cpu;
-
-	for_each_possible_cpu(cpu)
-		res += self->getval(self, cpu);
-
-	return res;
-}
-EXPORT_SYMBOL_GPL(pcounter_getval);
-
-int pcounter_alloc(struct pcounter *self)
-{
-	int rc = 0;
-	if (self->add == NULL) {
-		self->per_cpu_values = alloc_percpu(int);
-		if (self->per_cpu_values != NULL) {
-			self->add    = pcounter_dyn_add;
-			self->getval = pcounter_dyn_getval;
-		} else
-			rc = 1;
-	}
-	return rc;
-}
-EXPORT_SYMBOL_GPL(pcounter_alloc);
-
-void pcounter_free(struct pcounter *self)
-{
-	if (self->per_cpu_values != NULL) {
-		free_percpu(self->per_cpu_values);
-		self->per_cpu_values = NULL;
-		self->getval = NULL;
-		self->add = NULL;
-	}
-}
-EXPORT_SYMBOL_GPL(pcounter_free);
-
-- 
1.5.3.4

