From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 1/4] mm: NUMA aware alloc_task_struct_node()
Date: Mon, 29 Nov 2010 16:13:38 +0100
Message-ID: <1291043618.3435.975.camel@edumazet-laptop>
References: <1290972833.29196.90.camel@edumazet-laptop>
	 <20101128224024.GA12300@basil.fritz.box>
	 <1290984712.29196.100.camel@edumazet-laptop>
	 <20101128230146.GB12300@basil.fritz.box>
	 <1290987424.29196.128.camel@edumazet-laptop>
	 <20101129090510.GA15763@basil.fritz.box>
	 <1291023532.3435.29.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Tony Luck <tony.luck@intel.com>,
	Fenghua Yu <fenghua.yu@intel.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291023532.3435.29.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a node parameter to alloc_task_struct(), and change its name to
alloc_task_struct_node()

This change is needed to allow NUMA aware kthread_create_on_cpu()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David Miller <davem@davemloft.net>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Tejun Heo <tj@kernel.org>
Cc: linux-arch@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
---
 arch/frv/include/asm/processor.h        |    2 +-
 arch/frv/kernel/process.c               |    5 +++--
 arch/ia64/include/asm/thread_info.h     |    9 ++++++++-
 arch/um/include/asm/processor-generic.h |    2 +-
 kernel/fork.c                           |   10 ++++++----
 5 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/arch/frv/include/asm/processor.h b/arch/frv/include/asm/processor.h
index 3744f2e..4b789ab 100644
--- a/arch/frv/include/asm/processor.h
+++ b/arch/frv/include/asm/processor.h
@@ -137,7 +137,7 @@ unsigned long get_wchan(struct task_struct *p);
 #define	KSTK_ESP(tsk)	((tsk)->thread.frame0->sp)
 
 /* Allocation and freeing of basic task resources. */
-extern struct task_struct *alloc_task_struct(void);
+extern struct task_struct *alloc_task_struct_node(int node);
 extern void free_task_struct(struct task_struct *p);
 
 #define cpu_relax()    barrier()
diff --git a/arch/frv/kernel/process.c b/arch/frv/kernel/process.c
index efad120..9d35975 100644
--- a/arch/frv/kernel/process.c
+++ b/arch/frv/kernel/process.c
@@ -44,9 +44,10 @@ asmlinkage void ret_from_fork(void);
 void (*pm_power_off)(void);
 EXPORT_SYMBOL(pm_power_off);
 
-struct task_struct *alloc_task_struct(void)
+struct task_struct *alloc_task_struct_node(int node)
 {
-	struct task_struct *p = kmalloc(THREAD_SIZE, GFP_KERNEL);
+	struct task_struct *p = kmalloc_node(THREAD_SIZE, GFP_KERNEL, node);
+
 	if (p)
 		atomic_set((atomic_t *)(p+1), 1);
 	return p;
diff --git a/arch/ia64/include/asm/thread_info.h b/arch/ia64/include/asm/thread_info.h
index b6a5ba2..342004b 100644
--- a/arch/ia64/include/asm/thread_info.h
+++ b/arch/ia64/include/asm/thread_info.h
@@ -84,7 +84,14 @@ struct thread_info {
 #define end_of_stack(p) (unsigned long *)((void *)(p) + IA64_RBS_OFFSET)
 
 #define __HAVE_ARCH_TASK_STRUCT_ALLOCATOR
-#define alloc_task_struct()	((struct task_struct *)__get_free_pages(GFP_KERNEL | __GFP_COMP, KERNEL_STACK_SIZE_ORDER))
+#define alloc_task_struct_node(node)						\
+({										\
+	struct page *page = alloc_pages_node(node, GFP_KERNEL | __GFP_COMP,	\
+					     KERNEL_STACK_SIZE_ORDER);		\
+	struct task_struct *ret = page ? page_address(page) : NULL;		\
+										\
+	ret;
+})
 #define free_task_struct(tsk)	free_pages((unsigned long) (tsk), KERNEL_STACK_SIZE_ORDER)
 
 #endif /* !__ASSEMBLY */
diff --git a/arch/um/include/asm/processor-generic.h b/arch/um/include/asm/processor-generic.h
index bed6688..d1d1b0d 100644
--- a/arch/um/include/asm/processor-generic.h
+++ b/arch/um/include/asm/processor-generic.h
@@ -66,7 +66,7 @@ struct thread_struct {
 	.request		= { 0 } \
 }
 
-extern struct task_struct *alloc_task_struct(void);
+extern struct task_struct *alloc_task_struct_node(int node);
 
 static inline void release_thread(struct task_struct *task)
 {
diff --git a/kernel/fork.c b/kernel/fork.c
index 3b159c5..9e3c656 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -108,8 +108,10 @@ int nr_processes(void)
 }
 
 #ifndef __HAVE_ARCH_TASK_STRUCT_ALLOCATOR
-# define alloc_task_struct()	kmem_cache_alloc(task_struct_cachep, GFP_KERNEL)
-# define free_task_struct(tsk)	kmem_cache_free(task_struct_cachep, (tsk))
+# define alloc_task_struct_node(node)		\
+		kmem_cache_alloc_node(task_struct_cachep, GFP_KERNEL, node)
+# define free_task_struct(tsk)			\
+		kmem_cache_free(task_struct_cachep, (tsk))
 static struct kmem_cache *task_struct_cachep;
 #endif
 
@@ -246,12 +248,12 @@ static struct task_struct *dup_task_struct(struct task_struct *orig)
 	struct task_struct *tsk;
 	struct thread_info *ti;
 	unsigned long *stackend;
-
+	int node = numa_node_id();
 	int err;
 
 	prepare_to_copy(orig);
 
-	tsk = alloc_task_struct();
+	tsk = alloc_task_struct_node(node);
 	if (!tsk)
 		return NULL;
 
