From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [LIB] pcounter : unline too big functions
Date: Thu, 3 Jan 2008 16:52:27 +0100
Message-ID: <20080103165227.02fc0da4.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "acme@redhat.com" <acme@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:48113 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751724AbYACPwm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jan 2008 10:52:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before pushing pcounter to Linus tree, I would like to make some adjustments.

Goal is to reduce kernel text size, by unlining too big functions.

When a pcounter is bound to a statically defined per_cpu variable,
we define two small helpers functions. (No more folding function
using the fat for_each_possible_cpu(cpu) ... )

static DEFINE_PER_CPU(int, NAME##_pcounter_values);            
static void NAME##_pcounter_add(struct pcounter *self, int val)
{                                                             
       __get_cpu_var(NAME##_pcounter_values) += val;          
}                                                             
static int NAME##_pcounter_getval(const struct pcounter *self, int cpu)
{                                                                
       return per_cpu(NAME##_pcounter_values, cpu);
}

Fast path is therefore unchanged, while folding/alloc/free is now unlined.

This saves 228 bytes on i386

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

 include/linux/pcounter.h |   80 ++++++++++++-------------------------
 lib/pcounter.c           |   42 +++++++++++++++++--
 2 files changed, 63 insertions(+), 59 deletions(-)


diff --git a/include/linux/pcounter.h b/include/linux/pcounter.h
index 9c4760a..a82d9f2 100644
--- a/include/linux/pcounter.h
+++ b/include/linux/pcounter.h
@@ -1,41 +1,39 @@
 #ifndef __LINUX_PCOUNTER_H
 #define __LINUX_PCOUNTER_H
-
+/*
+ * Using a dynamic percpu 'int' variable has a cost :
+ * 1) Extra dereference
+ * Current per_cpu_ptr() implementation uses an array per 'percpu variable'.
+ * 2) memory cost of NR_CPUS*(32+sizeof(void *)) instead of num_possible_cpus()*4
+ *
+ * This pcounter implementation is an abstraction to be able to use
+ * either a static or a dynamic per cpu variable.
+ * One dynamic per cpu variable gets a fast & cheap implementation, we can
+ * change pcounter implementation too.
+ */
 struct pcounter {
 #ifdef CONFIG_SMP
 	void		(*add)(struct pcounter *self, int inc);
-	int		(*getval)(const struct pcounter *self);
+	int		(*getval)(const struct pcounter *self, int cpu);
 	int		*per_cpu_values;
 #else
 	int		val;
 #endif
 };
 
-/*
- * Special macros to let pcounters use a fast version of {getvalue|add}
- * using a static percpu variable per pcounter instead of an allocated one,
- * saving one dereference.
- * This might be changed if/when dynamic percpu vars become fast.
- */
 #ifdef CONFIG_SMP
-#include <linux/cpumask.h>
 #include <linux/percpu.h>
 
-#define DEFINE_PCOUNTER(NAME)					\
-static DEFINE_PER_CPU(int, NAME##_pcounter_values);		\
-static void NAME##_pcounter_add(struct pcounter *self, int inc)	\
-{								\
-       __get_cpu_var(NAME##_pcounter_values) += inc;		\
-}								\
-								\
-static int NAME##_pcounter_getval(const struct pcounter *self)	\
-{								\
-       int res = 0, cpu;					\
-								\
-       for_each_possible_cpu(cpu)				\
-               res += per_cpu(NAME##_pcounter_values, cpu);	\
-       return res;						\
-}
+#define DEFINE_PCOUNTER(NAME)						\
+static DEFINE_PER_CPU(int, NAME##_pcounter_values);			\
+static void NAME##_pcounter_add(struct pcounter *self, int val)		\
+{									\
+       __get_cpu_var(NAME##_pcounter_values) += val;			\
+}									\
+static int NAME##_pcounter_getval(const struct pcounter *self, int cpu)	\
+{									\
+	return per_cpu(NAME##_pcounter_values, cpu);			\
+}									\
 
 #define PCOUNTER_MEMBER_INITIALIZER(NAME, MEMBER)		\
 	MEMBER = {						\
@@ -43,42 +41,16 @@ static int NAME##_pcounter_getval(const struct pcounter *self)	\
 		.getval = NAME##_pcounter_getval,		\
 	}
 
-extern void pcounter_def_add(struct pcounter *self, int inc);
-extern int pcounter_def_getval(const struct pcounter *self);
-
-static inline int pcounter_alloc(struct pcounter *self)
-{
-	int rc = 0;
-	if (self->add == NULL) {
-		self->per_cpu_values = alloc_percpu(int);
-		if (self->per_cpu_values != NULL) {
-			self->add    = pcounter_def_add;
-			self->getval = pcounter_def_getval;
-		} else
-			rc = 1;
-	}
-	return rc;
-}
-
-static inline void pcounter_free(struct pcounter *self)
-{
-	if (self->per_cpu_values != NULL) {
-		free_percpu(self->per_cpu_values);
-		self->per_cpu_values = NULL;
-		self->getval = NULL;
-		self->add = NULL;
-	}
-}
 
 static inline void pcounter_add(struct pcounter *self, int inc)
 {
 	self->add(self, inc);
 }
 
-static inline int pcounter_getval(const struct pcounter *self)
-{
-	return self->getval(self);
-}
+extern int pcounter_getval(const struct pcounter *self);
+extern int pcounter_alloc(struct pcounter *self);
+extern void pcounter_free(struct pcounter *self);
+
 
 #else /* CONFIG_SMP */
 
diff --git a/lib/pcounter.c b/lib/pcounter.c
index 93feea5..9b56807 100644
--- a/lib/pcounter.c
+++ b/lib/pcounter.c
@@ -7,20 +7,52 @@
 #include <linux/module.h>
 #include <linux/pcounter.h>
 #include <linux/smp.h>
+#include <linux/cpumask.h>
 
-void pcounter_def_add(struct pcounter *self, int inc)
+static void pcounter_dyn_add(struct pcounter *self, int inc)
 {
 	per_cpu_ptr(self->per_cpu_values, smp_processor_id())[0] += inc;
 }
 
-EXPORT_SYMBOL_GPL(pcounter_def_add);
+static int pcounter_dyn_getval(const struct pcounter *self, int cpu)
+{
+	return per_cpu_ptr(self->per_cpu_values, cpu)[0];
+}
 
-int pcounter_def_getval(const struct pcounter *self)
+int pcounter_getval(const struct pcounter *self)
 {
 	int res = 0, cpu;
+
 	for_each_possible_cpu(cpu)
-		res += per_cpu_ptr(self->per_cpu_values, cpu)[0];
+		res += self->getval(self, cpu);
+
 	return res;
 }
+EXPORT_SYMBOL_GPL(pcounter_getval);
+
+int pcounter_alloc(struct pcounter *self)
+{
+	int rc = 0;
+	if (self->add == NULL) {
+		self->per_cpu_values = alloc_percpu(int);
+		if (self->per_cpu_values != NULL) {
+			self->add    = pcounter_dyn_add;
+			self->getval = pcounter_dyn_getval;
+		} else
+			rc = 1;
+	}
+	return rc;
+}
+EXPORT_SYMBOL_GPL(pcounter_alloc);
+
+void pcounter_free(struct pcounter *self)
+{
+	if (self->per_cpu_values != NULL) {
+		free_percpu(self->per_cpu_values);
+		self->per_cpu_values = NULL;
+		self->getval = NULL;
+		self->add = NULL;
+	}
+}
+EXPORT_SYMBOL_GPL(pcounter_free);
 
-EXPORT_SYMBOL_GPL(pcounter_def_getval);
