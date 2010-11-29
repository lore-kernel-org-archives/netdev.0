From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 2/4] mm: NUMA aware alloc_thread_info_node()
Date: Mon, 29 Nov 2010 16:14:20 +0100
Message-ID: <1291043660.3435.976.camel@edumazet-laptop>
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
	Fenghua Yu <fenghua.yu@intel.com>, linux-arch@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1291023532.3435.29.camel@edumazet-laptop>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a node parameter to alloc_thread_info(), and change its name to
alloc_thread_info_node()

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
 arch/cris/include/asm/thread_info.h     |    2 -
 arch/frv/include/asm/thread_info.h      |   13 +++--------
 arch/ia64/include/asm/thread_info.h     |    5 ++--
 arch/m32r/include/asm/thread_info.h     |   13 +++--------
 arch/mips/include/asm/thread_info.h     |    6 +++--
 arch/mn10300/include/asm/thread_info.h  |    6 +++--
 arch/powerpc/include/asm/thread_info.h  |    2 -
 arch/powerpc/kernel/process.c           |    4 +--
 arch/score/include/asm/thread_info.h    |    2 -
 arch/sh/include/asm/thread_info.h       |    2 -
 arch/sh/kernel/process.c                |   16 ++++++++------
 arch/sparc/include/asm/thread_info_32.h |    6 ++---
 arch/sparc/include/asm/thread_info_64.h |   24 +++++++++++-----------
 arch/sparc/mm/srmmu.c                   |    4 +--
 arch/sparc/mm/sun4c.c                   |    4 +--
 arch/tile/include/asm/thread_info.h     |    2 -
 arch/tile/kernel/process.c              |    4 +--
 arch/x86/include/asm/thread_info.h      |   10 +++++++--
 kernel/fork.c                           |    9 +++++---
 19 files changed, 70 insertions(+), 64 deletions(-)

diff --git a/arch/cris/include/asm/thread_info.h b/arch/cris/include/asm/thread_info.h
index 9177606..29b74a1 100644
--- a/arch/cris/include/asm/thread_info.h
+++ b/arch/cris/include/asm/thread_info.h
@@ -68,7 +68,7 @@ struct thread_info {
 #define init_thread_info	(init_thread_union.thread_info)
 
 /* thread information allocation */
-#define alloc_thread_info(tsk) ((struct thread_info *) __get_free_pages(GFP_KERNEL,1))
+#define alloc_thread_info(tsk, node) ((struct thread_info *) __get_free_pages(GFP_KERNEL,1))
 #define free_thread_info(ti) free_pages((unsigned long) (ti), 1)
 
 #endif /* !__ASSEMBLY__ */
diff --git a/arch/frv/include/asm/thread_info.h b/arch/frv/include/asm/thread_info.h
index 11f33ea..8582e9c 100644
--- a/arch/frv/include/asm/thread_info.h
+++ b/arch/frv/include/asm/thread_info.h
@@ -84,16 +84,11 @@ register struct thread_info *__current_thread_info asm("gr15");
 
 /* thread information allocation */
 #ifdef CONFIG_DEBUG_STACK_USAGE
-#define alloc_thread_info(tsk)					\
-	({							\
-		struct thread_info *ret;			\
-								\
-		ret = kzalloc(THREAD_SIZE, GFP_KERNEL);		\
-								\
-		ret;						\
-	})
+#define alloc_thread_info_node(tsk, node)			\
+		kzalloc_node(THREAD_SIZE, GFP_KERNEL, node)
 #else
-#define alloc_thread_info(tsk)	kmalloc(THREAD_SIZE, GFP_KERNEL)
+#define alloc_thread_info_node(tsk)				\
+		kmalloc_node(THREAD_SIZE, GFP_KERNEL, node)
 #endif
 
 #define free_thread_info(info)	kfree(info)
diff --git a/arch/ia64/include/asm/thread_info.h b/arch/ia64/include/asm/thread_info.h
index 342004b..6392908 100644
--- a/arch/ia64/include/asm/thread_info.h
+++ b/arch/ia64/include/asm/thread_info.h
@@ -59,11 +59,12 @@ struct thread_info {
 #ifndef ASM_OFFSETS_C
 /* how to get the thread information struct from C */
 #define current_thread_info()	((struct thread_info *) ((char *) current + IA64_TASK_SIZE))
-#define alloc_thread_info(tsk)	((struct thread_info *) ((char *) (tsk) + IA64_TASK_SIZE))
+#define alloc_thread_info_node(tsk, node)	\
+		((struct thread_info *) ((char *) (tsk) + IA64_TASK_SIZE))
 #define task_thread_info(tsk)	((struct thread_info *) ((char *) (tsk) + IA64_TASK_SIZE))
 #else
 #define current_thread_info()	((struct thread_info *) 0)
-#define alloc_thread_info(tsk)	((struct thread_info *) 0)
+#define alloc_thread_info_node(tsk, node)	((struct thread_info *) 0)
 #define task_thread_info(tsk)	((struct thread_info *) 0)
 #endif
 #define free_thread_info(ti)	/* nothing */
diff --git a/arch/m32r/include/asm/thread_info.h b/arch/m32r/include/asm/thread_info.h
index 71faff5..0227dba 100644
--- a/arch/m32r/include/asm/thread_info.h
+++ b/arch/m32r/include/asm/thread_info.h
@@ -96,16 +96,11 @@ static inline struct thread_info *current_thread_info(void)
 
 /* thread information allocation */
 #ifdef CONFIG_DEBUG_STACK_USAGE
-#define alloc_thread_info(tsk)					\
-	({							\
-		struct thread_info *ret;			\
-	 							\
-	 	ret = kzalloc(THREAD_SIZE, GFP_KERNEL);		\
-								\
-	 	ret;						\
-	 })
+#define alloc_thread_info_node(tsk, node)			\
+		kzalloc_node(THREAD_SIZE, GFP_KERNEL, node)
 #else
-#define alloc_thread_info(tsk) kmalloc(THREAD_SIZE, GFP_KERNEL)
+#define alloc_thread_info_node(tsk, node)			\
+		kmalloc_node(THREAD_SIZE, GFP_KERNEL, node)
 #endif
 
 #define free_thread_info(info) kfree(info)
diff --git a/arch/mips/include/asm/thread_info.h b/arch/mips/include/asm/thread_info.h
index d309556..d71160d 100644
--- a/arch/mips/include/asm/thread_info.h
+++ b/arch/mips/include/asm/thread_info.h
@@ -88,9 +88,11 @@ register struct thread_info *__current_thread_info __asm__("$28");
 #define __HAVE_ARCH_THREAD_INFO_ALLOCATOR
 
 #ifdef CONFIG_DEBUG_STACK_USAGE
-#define alloc_thread_info(tsk) kzalloc(THREAD_SIZE, GFP_KERNEL)
+#define alloc_thread_info_node(tsk, node) \
+		kzalloc_node(THREAD_SIZE, GFP_KERNEL, node)
 #else
-#define alloc_thread_info(tsk) kmalloc(THREAD_SIZE, GFP_KERNEL)
+#define alloc_thread_info_node(tsk, node) \
+		kmalloc_node(THREAD_SIZE, GFP_KERNEL, node)
 #endif
 
 #define free_thread_info(info) kfree(info)
diff --git a/arch/mn10300/include/asm/thread_info.h b/arch/mn10300/include/asm/thread_info.h
index aa07a4a..8d53f09 100644
--- a/arch/mn10300/include/asm/thread_info.h
+++ b/arch/mn10300/include/asm/thread_info.h
@@ -124,9 +124,11 @@ static inline unsigned long current_stack_pointer(void)
 
 /* thread information allocation */
 #ifdef CONFIG_DEBUG_STACK_USAGE
-#define alloc_thread_info(tsk) kzalloc(THREAD_SIZE, GFP_KERNEL)
+#define alloc_thread_info_node(tsk, node)			\
+		kzalloc_node(THREAD_SIZE, GFP_KERNEL, node)
 #else
-#define alloc_thread_info(tsk) kmalloc(THREAD_SIZE, GFP_KERNEL)
+#define alloc_thread_info_node(tsk, node)			\
+		kmalloc_node(THREAD_SIZE, GFP_KERNEL, node)
 #endif
 
 #define free_thread_info(ti)	kfree((ti))
diff --git a/arch/powerpc/include/asm/thread_info.h b/arch/powerpc/include/asm/thread_info.h
index 65eb859..d8529ef 100644
--- a/arch/powerpc/include/asm/thread_info.h
+++ b/arch/powerpc/include/asm/thread_info.h
@@ -72,7 +72,7 @@ struct thread_info {
 
 #define __HAVE_ARCH_THREAD_INFO_ALLOCATOR
 
-extern struct thread_info *alloc_thread_info(struct task_struct *tsk);
+extern struct thread_info *alloc_thread_info_node(struct task_struct *tsk, int node);
 extern void free_thread_info(struct thread_info *ti);
 
 #endif /* THREAD_SHIFT < PAGE_SHIFT */
diff --git a/arch/powerpc/kernel/process.c b/arch/powerpc/kernel/process.c
index 84906d3..1248460 100644
--- a/arch/powerpc/kernel/process.c
+++ b/arch/powerpc/kernel/process.c
@@ -1216,11 +1216,11 @@ void __ppc64_runlatch_off(void)
 
 static struct kmem_cache *thread_info_cache;
 
-struct thread_info *alloc_thread_info(struct task_struct *tsk)
+struct thread_info *alloc_thread_info_node(struct task_struct *tsk, int node)
 {
 	struct thread_info *ti;
 
-	ti = kmem_cache_alloc(thread_info_cache, GFP_KERNEL);
+	ti = kmem_cache_alloc_node(thread_info_cache, GFP_KERNEL, node);
 	if (unlikely(ti == NULL))
 		return NULL;
 #ifdef CONFIG_DEBUG_STACK_USAGE
diff --git a/arch/score/include/asm/thread_info.h b/arch/score/include/asm/thread_info.h
index 8570d08..2205c62 100644
--- a/arch/score/include/asm/thread_info.h
+++ b/arch/score/include/asm/thread_info.h
@@ -71,7 +71,7 @@ struct thread_info {
 register struct thread_info *__current_thread_info __asm__("r28");
 #define current_thread_info()	__current_thread_info
 
-#define alloc_thread_info(tsk) kmalloc(THREAD_SIZE, GFP_KERNEL)
+#define alloc_thread_info_node(tsk, node) kmalloc_node(THREAD_SIZE, GFP_KERNEL, node)
 #define free_thread_info(info) kfree(info)
 
 #endif /* !__ASSEMBLY__ */
diff --git a/arch/sh/include/asm/thread_info.h b/arch/sh/include/asm/thread_info.h
index c228946..ea2d508 100644
--- a/arch/sh/include/asm/thread_info.h
+++ b/arch/sh/include/asm/thread_info.h
@@ -95,7 +95,7 @@ static inline struct thread_info *current_thread_info(void)
 
 #endif
 
-extern struct thread_info *alloc_thread_info(struct task_struct *tsk);
+extern struct thread_info *alloc_thread_info_node(struct task_struct *tsk, int node);
 extern void free_thread_info(struct thread_info *ti);
 extern void arch_task_cache_init(void);
 #define arch_task_cache_init arch_task_cache_init
diff --git a/arch/sh/kernel/process.c b/arch/sh/kernel/process.c
index dcb126d..f39ad57 100644
--- a/arch/sh/kernel/process.c
+++ b/arch/sh/kernel/process.c
@@ -32,16 +32,16 @@ void free_thread_xstate(struct task_struct *tsk)
 #if THREAD_SHIFT < PAGE_SHIFT
 static struct kmem_cache *thread_info_cache;
 
-struct thread_info *alloc_thread_info(struct task_struct *tsk)
+struct thread_info *alloc_thread_info(struct task_struct *tsk, int node)
 {
 	struct thread_info *ti;
-
-	ti = kmem_cache_alloc(thread_info_cache, GFP_KERNEL);
-	if (unlikely(ti == NULL))
-		return NULL;
 #ifdef CONFIG_DEBUG_STACK_USAGE
-	memset(ti, 0, THREAD_SIZE);
+	gfp_t mask = GFP_KERNEL | __GFP_ZERO;
+#else
+	gfp_t mask = GFP_KERNEL;
 #endif
+
+	ti = kmem_cache_alloc_node(thread_info_cache, mask, node);
 	return ti;
 }
 
@@ -64,7 +64,9 @@ struct thread_info *alloc_thread_info(struct task_struct *tsk)
 #else
 	gfp_t mask = GFP_KERNEL;
 #endif
-	return (struct thread_info *)__get_free_pages(mask, THREAD_SIZE_ORDER);
+	struct page *page = alloc_pages_node(node, mask, THREAD_SIZE_ORDER);
+
+	return page ? page_address(page) : NULL;
 }
 
 void free_thread_info(struct thread_info *ti)
diff --git a/arch/sparc/include/asm/thread_info_32.h b/arch/sparc/include/asm/thread_info_32.h
index 9dd0318..fa57532 100644
--- a/arch/sparc/include/asm/thread_info_32.h
+++ b/arch/sparc/include/asm/thread_info_32.h
@@ -82,8 +82,8 @@ register struct thread_info *current_thread_info_reg asm("g6");
 
 #define __HAVE_ARCH_THREAD_INFO_ALLOCATOR
 
-BTFIXUPDEF_CALL(struct thread_info *, alloc_thread_info, void)
-#define alloc_thread_info(tsk) BTFIXUP_CALL(alloc_thread_info)()
+BTFIXUPDEF_CALL(struct thread_info *, alloc_thread_info_node, int)
+#define alloc_thread_info_node(tsk, node) BTFIXUP_CALL(alloc_thread_info_node)(node)
 
 BTFIXUPDEF_CALL(void, free_thread_info, struct thread_info *)
 #define free_thread_info(ti) BTFIXUP_CALL(free_thread_info)(ti)
@@ -92,7 +92,7 @@ BTFIXUPDEF_CALL(void, free_thread_info, struct thread_info *)
 
 /*
  * Size of kernel stack for each process.
- * Observe the order of get_free_pages() in alloc_thread_info().
+ * Observe the order of get_free_pages() in alloc_thread_info_node().
  * The sun4 has 8K stack too, because it's short on memory, and 16K is a waste.
  */
 #define THREAD_SIZE		8192
diff --git a/arch/sparc/include/asm/thread_info_64.h b/arch/sparc/include/asm/thread_info_64.h
index fb2ea77..60d86be 100644
--- a/arch/sparc/include/asm/thread_info_64.h
+++ b/arch/sparc/include/asm/thread_info_64.h
@@ -146,21 +146,21 @@ register struct thread_info *current_thread_info_reg asm("g6");
 #define __HAVE_ARCH_THREAD_INFO_ALLOCATOR
 
 #ifdef CONFIG_DEBUG_STACK_USAGE
-#define alloc_thread_info(tsk)					\
-({								\
-	struct thread_info *ret;				\
-								\
-	ret = (struct thread_info *)				\
-	  __get_free_pages(GFP_KERNEL, __THREAD_INFO_ORDER);	\
-	if (ret)						\
-		memset(ret, 0, PAGE_SIZE<<__THREAD_INFO_ORDER);	\
-	ret;							\
-})
+#define THREAD_FLAGS (GFP_KERNEL | __GFP_ZERO)
 #else
-#define alloc_thread_info(tsk) \
-	((struct thread_info *)__get_free_pages(GFP_KERNEL, __THREAD_INFO_ORDER))
+#define THREAD_FLAGS (GFP_KERNEL)
 #endif
 
+#define alloc_thread_info_node(tsk, node)				\
+({									\
+	struct page *page = alloc_pages_node(node, THREAD_FLAGS,	\
+					     __THREAD_INFO_ORDER);	\
+	struct thread_info *ret;					\
+									\
+	ret = page ? page_address(page) : NULL;				\
+	ret;								\
+})
+
 #define free_thread_info(ti) \
 	free_pages((unsigned long)(ti),__THREAD_INFO_ORDER)
 
diff --git a/arch/sparc/mm/srmmu.c b/arch/sparc/mm/srmmu.c
index 92319aa..fe09fd8 100644
--- a/arch/sparc/mm/srmmu.c
+++ b/arch/sparc/mm/srmmu.c
@@ -650,7 +650,7 @@ static void srmmu_unmapiorange(unsigned long virt_addr, unsigned int len)
  * mappings on the kernel stack without any special code as we did
  * need on the sun4c.
  */
-static struct thread_info *srmmu_alloc_thread_info(void)
+static struct thread_info *srmmu_alloc_thread_info_node(int node)
 {
 	struct thread_info *ret;
 
@@ -2271,7 +2271,7 @@ void __init ld_mmu_srmmu(void)
 
 	BTFIXUPSET_CALL(mmu_info, srmmu_mmu_info, BTFIXUPCALL_NORM);
 
-	BTFIXUPSET_CALL(alloc_thread_info, srmmu_alloc_thread_info, BTFIXUPCALL_NORM);
+	BTFIXUPSET_CALL(alloc_thread_info_node, srmmu_alloc_thread_info_node, BTFIXUPCALL_NORM);
 	BTFIXUPSET_CALL(free_thread_info, srmmu_free_thread_info, BTFIXUPCALL_NORM);
 
 	BTFIXUPSET_CALL(pte_to_pgoff, srmmu_pte_to_pgoff, BTFIXUPCALL_NORM);
diff --git a/arch/sparc/mm/sun4c.c b/arch/sparc/mm/sun4c.c
index ddd0d86..f6f4c54 100644
--- a/arch/sparc/mm/sun4c.c
+++ b/arch/sparc/mm/sun4c.c
@@ -924,7 +924,7 @@ static inline void garbage_collect(int entry)
 	free_locked_segment(BUCKET_ADDR(entry));
 }
 
-static struct thread_info *sun4c_alloc_thread_info(void)
+static struct thread_info *sun4c_alloc_thread_info_node(int node)
 {
 	unsigned long addr, pages;
 	int entry;
@@ -2157,7 +2157,7 @@ void __init ld_mmu_sun4c(void)
 	BTFIXUPSET_CALL(__swp_offset, sun4c_swp_offset, BTFIXUPCALL_NORM);
 	BTFIXUPSET_CALL(__swp_entry, sun4c_swp_entry, BTFIXUPCALL_NORM);
 
-	BTFIXUPSET_CALL(alloc_thread_info, sun4c_alloc_thread_info, BTFIXUPCALL_NORM);
+	BTFIXUPSET_CALL(alloc_thread_info_node, sun4c_alloc_thread_info_node, BTFIXUPCALL_NORM);
 	BTFIXUPSET_CALL(free_thread_info, sun4c_free_thread_info, BTFIXUPCALL_NORM);
 
 	BTFIXUPSET_CALL(mmu_info, sun4c_mmu_info, BTFIXUPCALL_NORM);
diff --git a/arch/tile/include/asm/thread_info.h b/arch/tile/include/asm/thread_info.h
index 3872f2b..145e578 100644
--- a/arch/tile/include/asm/thread_info.h
+++ b/arch/tile/include/asm/thread_info.h
@@ -83,7 +83,7 @@ register unsigned long stack_pointer __asm__("sp");
   ((struct thread_info *)(stack_pointer & -THREAD_SIZE))
 
 #define __HAVE_ARCH_THREAD_INFO_ALLOCATOR
-extern struct thread_info *alloc_thread_info(struct task_struct *task);
+extern struct thread_info *alloc_thread_info_node(struct task_struct *task, int node);
 extern void free_thread_info(struct thread_info *info);
 
 /* Sit on a nap instruction until interrupted. */
diff --git a/arch/tile/kernel/process.c b/arch/tile/kernel/process.c
index 8430f45..7f7179a 100644
--- a/arch/tile/kernel/process.c
+++ b/arch/tile/kernel/process.c
@@ -109,7 +109,7 @@ void cpu_idle(void)
 	}
 }
 
-struct thread_info *alloc_thread_info(struct task_struct *task)
+struct thread_info *alloc_thread_info_node(struct task_struct *task, int node)
 {
 	struct page *page;
 	gfp_t flags = GFP_KERNEL;
@@ -118,7 +118,7 @@ struct thread_info *alloc_thread_info(struct task_struct *task)
 	flags |= __GFP_ZERO;
 #endif
 
-	page = alloc_pages(flags, THREAD_SIZE_ORDER);
+	page = alloc_pages_node(node, flags, THREAD_SIZE_ORDER);
 	if (!page)
 		return NULL;
 
diff --git a/arch/x86/include/asm/thread_info.h b/arch/x86/include/asm/thread_info.h
index f0b6e5d..1f2e61e 100644
--- a/arch/x86/include/asm/thread_info.h
+++ b/arch/x86/include/asm/thread_info.h
@@ -161,8 +161,14 @@ struct thread_info {
 
 #define __HAVE_ARCH_THREAD_INFO_ALLOCATOR
 
-#define alloc_thread_info(tsk)						\
-	((struct thread_info *)__get_free_pages(THREAD_FLAGS, THREAD_ORDER))
+#define alloc_thread_info_node(tsk, node)				\
+({									\
+	struct page *page = alloc_pages_node(node, THREAD_FLAGS,	\
+					     THREAD_ORDER);		\
+	struct thread_info *ret = page ? page_address(page) : NULL;	\
+									\
+	ret;								\
+})
 
 #ifdef CONFIG_X86_32
 
diff --git a/kernel/fork.c b/kernel/fork.c
index 9e3c656..3ebae16 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -116,14 +116,17 @@ static struct kmem_cache *task_struct_cachep;
 #endif
 
 #ifndef __HAVE_ARCH_THREAD_INFO_ALLOCATOR
-static inline struct thread_info *alloc_thread_info(struct task_struct *tsk)
+static struct thread_info *alloc_thread_info_node(struct task_struct *tsk,
+						  int node)
 {
 #ifdef CONFIG_DEBUG_STACK_USAGE
 	gfp_t mask = GFP_KERNEL | __GFP_ZERO;
 #else
 	gfp_t mask = GFP_KERNEL;
 #endif
-	return (struct thread_info *)__get_free_pages(mask, THREAD_SIZE_ORDER);
+	struct page *page = alloc_pages_node(node, mask, THREAD_SIZE_ORDER);
+
+	return page ? page_address(page) : NULL;
 }
 
 static inline void free_thread_info(struct thread_info *ti)
@@ -257,7 +260,7 @@ static struct task_struct *dup_task_struct(struct task_struct *orig)
 	if (!tsk)
 		return NULL;
 
-	ti = alloc_thread_info(tsk);
+	ti = alloc_thread_info_node(tsk, node);
 	if (!ti) {
 		free_task_struct(tsk);
 		return NULL;
