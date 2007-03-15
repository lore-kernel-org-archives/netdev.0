From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [patch 1/4] network dev read_mostly
Date: Wed, 14 Mar 2007 22:18:40 -0400
Message-ID: <20070315021840.GG1246@kvack.org>
References: <20070312210817.485320783@linux-foundation.org> <20070312210907.509184287@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:49333 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933388AbXCOCSx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Mar 2007 22:18:53 -0400
Content-Disposition: inline
In-Reply-To: <20070312210907.509184287@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 12, 2007 at 02:08:18PM -0700, Stephen Hemminger wrote:
> For Eric, mark packet type and network device watermarks
> as read mostly.

The following x86-64 bits might be intersting, as they allow you to 
completely eliminate the memory access for run time defined constants.  
Note that read_always writes are non-atomic, so some other form of 
protection is necessary for readers (and rcu won't cut it).  That can be 
fixed somewhat by specifying the alignment for the mov instruction to 
ensure writes are atomic, but for many uses that is overkill.  This kind 
of change can make the biggest difference for high-latency cases, like L1 
cache misses on the Prescott P4.  I've not benched it on a P4 of late, 
though.

		-ben


diff --git a/arch/x86_64/kernel/head64.c b/arch/x86_64/kernel/head64.c
index 5f197b0..022ee38 100644
--- a/arch/x86_64/kernel/head64.c
+++ b/arch/x86_64/kernel/head64.c
@@ -70,6 +70,8 @@ void __init x86_64_start_kernel(char * real_mode_data)
 	memcpy(init_level4_pgt, boot_level4_pgt, PTRS_PER_PGD*sizeof(pgd_t));
 	asm volatile("movq %0,%%cr3" :: "r" (__pa_symbol(&init_level4_pgt)));
 
+	init_read_always();
+
  	for (i = 0; i < NR_CPUS; i++)
  		cpu_pda(i) = &boot_cpu_pda[i];
 
diff --git a/arch/x86_64/kernel/vmlinux.lds.S b/arch/x86_64/kernel/vmlinux.lds.S
index b73212c..19852dc 100644
--- a/arch/x86_64/kernel/vmlinux.lds.S
+++ b/arch/x86_64/kernel/vmlinux.lds.S
@@ -50,6 +50,10 @@ SECTIONS
   __ex_table : AT(ADDR(__ex_table) - LOAD_OFFSET) { *(__ex_table) }
   __stop___ex_table = .;
 
+  start__read_always = .;
+  __read_always : AT(ADDR(__read_always) - LOAD_OFFSET) { *(__read_always) }
+  stop__read_always = .;
+
   RODATA
 
   BUG_TABLE
diff --git a/arch/x86_64/mm/fault.c b/arch/x86_64/mm/fault.c
index 6ada723..d48415e 100644
--- a/arch/x86_64/mm/fault.c
+++ b/arch/x86_64/mm/fault.c
@@ -31,6 +31,7 @@
 #include <asm/tlbflush.h>
 #include <asm/proto.h>
 #include <asm/kdebug.h>
+#include <asm/read_always.h>
 #include <asm-generic/sections.h>
 
 /* Page fault error code bits */
@@ -41,11 +42,67 @@
 #define PF_INSTR	(1<<4)
 
 static ATOMIC_NOTIFIER_HEAD(notify_page_fault_chain);
+static DEFINE_READ_ALWAYS(char, notify_page_fault_active);
+static DEFINE_READ_ALWAYS(char, page_fault_trace);
+
+void init_read_always(void)
+{
+	extern unsigned int start__read_always[], stop__read_always[];
+	unsigned int *fixup;
+
+	fixup = start__read_always;
+	while (fixup < stop__read_always) {
+		void *where = (void *)(fixup[0] - 0x100000000L);
+		void *which = (void *)(fixup[1] - 0x100000000L);
+		long size = fixup[2];
+		fixup += 3;
+
+		switch (size) {
+		case 1:		*(u8 *)where = *(u8 *)which;	break;
+		case 2:		*(u16 *)where = *(u16 *)which;	break;
+		case 4:		*(u32 *)where = *(u32 *)which;	break;
+		case 8:		*(u64 *)where = *(u64 *)which;	break;
+		}
+	}
+}
+
+void set_read_always_size(void *ptr, long val, int size)
+{
+	extern unsigned int start__read_always[], stop__read_always[];
+	unsigned int *fixup;
+
+	switch(size) {
+	case 1:	*(u8 *)ptr = val;	break;
+	case 2:	*(u16 *)ptr = val;	break;
+	case 4:	*(u32 *)ptr = val;	break;
+	case 8:	*(u64 *)ptr = val;	break;
+	}
+
+	fixup = start__read_always;
+	while (fixup < stop__read_always) {
+		void *where = (void *)(fixup[0] - 0x100000000L);
+		void *which = (void *)(fixup[1] - 0x100000000L);
+		long actual_size = fixup[2];
+		fixup += 3;
+
+		if (which != ptr)
+			continue;
+
+		BUG_ON(size != actual_size);
+		switch(size) {
+		case 1:	*(u8 *)where = val;	break;
+		case 2:	*(u16 *)where = val;	break;
+		case 4:	*(u32 *)where = val;	break;
+		case 8:	*(u64 *)where = val;	break;
+		}
+	}
+}
 
 /* Hook to register for page fault notifications */
 int register_page_fault_notifier(struct notifier_block *nb)
 {
 	vmalloc_sync_all();
+	set_read_always(notify_page_fault_active, 1);
 	return atomic_notifier_chain_register(&notify_page_fault_chain, nb);
 }
 EXPORT_SYMBOL_GPL(register_page_fault_notifier);
@@ -56,7 +113,7 @@ int unregister_page_fault_notifier(struct notifier_block *nb)
 }
 EXPORT_SYMBOL_GPL(unregister_page_fault_notifier);
 
-static inline int notify_page_fault(struct pt_regs *regs, long err)
+static int notify_page_fault(struct pt_regs *regs, long err)
 {
 	struct die_args args = {
 		.regs = regs,
@@ -301,7 +358,6 @@ static int vmalloc_fault(unsigned long address)
 	return 0;
 }
 
-int page_fault_trace = 0;
 int exception_trace = 1;
 
 /*
@@ -355,7 +411,8 @@ asmlinkage void __kprobes do_page_fault(struct pt_regs *regs,
 			if (vmalloc_fault(address) >= 0)
 				return;
 		}
-		if (notify_page_fault(regs, error_code) == NOTIFY_STOP)
+		if (read_always(notify_page_fault_active) &&
+		    notify_page_fault(regs, error_code) == NOTIFY_STOP)
 			return;
 		/*
 		 * Don't take the mm semaphore here. If we fixup a prefetch
@@ -364,13 +421,14 @@ asmlinkage void __kprobes do_page_fault(struct pt_regs *regs,
 		goto bad_area_nosemaphore;
 	}
 
-	if (notify_page_fault(regs, error_code) == NOTIFY_STOP)
+	if (read_always(notify_page_fault_active) &&
+	    notify_page_fault(regs, error_code) == NOTIFY_STOP)
 		return;
 
 	if (likely(regs->eflags & X86_EFLAGS_IF))
 		local_irq_enable();
 
-	if (unlikely(page_fault_trace))
+	if (unlikely(read_always(page_fault_trace)))
 		printk("pagefault rip:%lx rsp:%lx cs:%lu ss:%lu address %lx error %lx\n",
 		       regs->rip,regs->rsp,regs->cs,regs->ss,address,error_code); 
 
@@ -628,7 +686,7 @@ void vmalloc_sync_all(void)
 
 static int __init enable_pagefaulttrace(char *str)
 {
-	page_fault_trace = 1;
+	set_read_always(page_fault_trace, 1);
 	return 1;
 }
 __setup("pagefaulttrace", enable_pagefaulttrace);
diff --git a/fs/exec.c b/fs/exec.c
index 7e36c6f..018ac4a 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -65,7 +65,7 @@ int suid_dumpable = 0;
 EXPORT_SYMBOL(suid_dumpable);
 /* The maximal length of core_pattern is also specified in sysctl.c */
 
-static struct linux_binfmt *formats;
+static DEFINE_READ_ALWAYS(struct linux_binfmt *, formats);
 static DEFINE_RWLOCK(binfmt_lock);
 
 int register_binfmt(struct linux_binfmt * fmt)
@@ -85,7 +85,7 @@ int register_binfmt(struct linux_binfmt * fmt)
 		tmp = &(*tmp)->next;
 	}
 	fmt->next = formats;
-	formats = fmt;
+	set_read_always(formats, fmt);
 	write_unlock(&binfmt_lock);
 	return 0;	
 }
@@ -100,6 +100,8 @@ int unregister_binfmt(struct linux_binfmt * fmt)
 	while (*tmp) {
 		if (fmt == *tmp) {
 			*tmp = fmt->next;
+			if (tmp == &formats)
+				set_read_always(formats, fmt->next);
 			write_unlock(&binfmt_lock);
 			return 0;
 		}
@@ -150,7 +152,7 @@ asmlinkage long sys_uselib(const char __user * library)
 		struct linux_binfmt * fmt;
 
 		read_lock(&binfmt_lock);
-		for (fmt = formats ; fmt ; fmt = fmt->next) {
+		for (fmt = read_always(formats); fmt ; fmt = fmt->next) {
 			if (!fmt->load_shlib)
 				continue;
 			if (!try_module_get(fmt->module))
@@ -1068,7 +1070,7 @@ int search_binary_handler(struct linux_binprm *bprm,struct pt_regs *regs)
 	retval = -ENOENT;
 	for (try=0; try<2; try++) {
 		read_lock(&binfmt_lock);
-		for (fmt = formats ; fmt ; fmt = fmt->next) {
+		for (fmt = read_always(formats) ; fmt ; fmt = fmt->next) {
 			int (*fn)(struct linux_binprm *, struct pt_regs *) = fmt->load_binary;
 			if (!fn)
 				continue;
diff --git a/include/asm-x86_64/read_always.h b/include/asm-x86_64/read_always.h
index 166b2a2..389e6e6 100644
--- a/include/asm-x86_64/read_always.h
+++ b/include/asm-x86_64/read_always.h
@@ -1 +1,60 @@
-#include <asm-generic/read_always.h>
+#ifndef __ASM__READ_ALWAYS_H
+#define __ASM__READ_ALWAYS_H
+
+#ifdef MODULE
+/* FIXME: making modules implement this optimization requires more work. */
+#define DEFINE_READ_ALWAYS(type, var)	type var
+#define read_always(var)		(var)
+
+#else
+
+#define DEFINE_READ_ALWAYS(type, var)					\
+	type var;							\
+	extern inline type read_always_##var(void)			\
+	{								\
+		extern void __size_is_unsupported(void) __attribute__((noreturn));		\
+		type ret;						\
+		switch (sizeof(ret)) {					\
+		case 1:							\
+			__asm__ __volatile__(				\
+				"movb $0x12,%0\n1:\n"			\
+				".section __read_always,\"a\"\n"	\
+				"	.long	1b-1+0x100000000\n"	\
+				"	.long	" #var "+0x100000000\n"	\
+				"	.long	1\n"			\
+				".previous\n"				\
+				: "=r" (ret));				\
+			break;						\
+		case 4:							\
+			__asm__ __volatile__(				\
+				"movl $0x12345678,%0\n1:\n"		\
+				".section __read_always,\"a\"\n"	\
+				"	.long	1b-4+0x100000000\n"	\
+				"	.long	" #var "+0x100000000\n"	\
+				"	.long	1\n"			\
+				".previous\n"				\
+				: "=r" (ret));				\
+			break;						\
+		case 8:							\
+			__asm__ __volatile__(				\
+				"movq $0x123456789abcdef0,%0\n1:\n"	\
+				".section __read_always,\"a\"\n"	\
+				"	.long	1b-8+0x100000000\n"	\
+				"	.long	" #var "+0x100000000\n"	\
+				"	.long	8\n"			\
+				".previous\n"				\
+				: "=r" (ret));				\
+			break;						\
+		default:						\
+			__size_is_unsupported();			\
+		}							\
+		return ret;						\
+	}
+
+#define read_always(var)	read_always_##var()
+#endif
+
+#define set_read_always(var, val) set_read_always_size(&var, (long)(val), sizeof var)
+extern void set_read_always_size(void *var, long val, int size);
+
+#endif
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 60e0e4a..f0c3908 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -114,7 +114,9 @@ struct vm_area_struct {
 #endif
 };
 
-extern struct kmem_cache *vm_area_cachep;
+#include <asm/read_always.h>
+extern DEFINE_READ_ALWAYS(struct kmem_cache *, __vm_area_cachep);
+#define vm_area_cachep	read_always(__vm_area_cachep)
 
 /*
  * This struct defines the per-mm list of VMAs for uClinux. If CONFIG_MMU is
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index ee9e314..629ce04 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -407,8 +407,10 @@ struct node_active_region {
 #endif /* CONFIG_ARCH_POPULATES_NODE_MAP */
 
 #ifndef CONFIG_DISCONTIGMEM
+#include <asm/read_always.h>
 /* The array of struct pages - for discontigmem use pgdat->lmem_map */
-extern struct page *mem_map;
+extern DEFINE_READ_ALWAYS(struct page *, __mem_map);
+#define mem_map		read_always(__mem_map)
 #endif
 
 /*
diff --git a/kernel/fork.c b/kernel/fork.c
index d154cc7..c7d8b7f 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -81,13 +81,13 @@ int nr_processes(void)
 }
 
 #ifndef __HAVE_ARCH_TASK_STRUCT_ALLOCATOR
-# define alloc_task_struct()	kmem_cache_alloc(task_struct_cachep, GFP_KERNEL)
-# define free_task_struct(tsk)	kmem_cache_free(task_struct_cachep, (tsk))
-static struct kmem_cache *task_struct_cachep;
+# define alloc_task_struct()	kmem_cache_alloc(read_always(task_struct_cachep), GFP_KERNEL)
+# define free_task_struct(tsk)	kmem_cache_free(read_always(task_struct_cachep), (tsk))
+static DEFINE_READ_ALWAYS(struct kmem_cache *, task_struct_cachep);
 #endif
 
 /* SLAB cache for signal_struct structures (tsk->signal) */
-static struct kmem_cache *signal_cachep;
+static DEFINE_READ_ALWAYS(struct kmem_cache *, signal_cachep);
 
 /* SLAB cache for sighand_struct structures (tsk->sighand) */
 struct kmem_cache *sighand_cachep;
@@ -99,10 +99,10 @@ struct kmem_cache *files_cachep;
 struct kmem_cache *fs_cachep;
 
 /* SLAB cache for vm_area_struct structures */
-struct kmem_cache *vm_area_cachep;
+struct kmem_cache *__vm_area_cachep;
 
 /* SLAB cache for mm_struct structures (tsk->mm) */
-static struct kmem_cache *mm_cachep;
+static DEFINE_READ_ALWAYS(struct kmem_cache *, mm_cachep);
 
 void free_task(struct task_struct *tsk)
 {
@@ -134,9 +134,9 @@ void __init fork_init(unsigned long mempages)
 #define ARCH_MIN_TASKALIGN	L1_CACHE_BYTES
 #endif
 	/* create a slab on which task_structs can be allocated */
-	task_struct_cachep =
+	set_read_always(task_struct_cachep,
 		kmem_cache_create("task_struct", sizeof(struct task_struct),
-			ARCH_MIN_TASKALIGN, SLAB_PANIC, NULL, NULL);
+			ARCH_MIN_TASKALIGN, SLAB_PANIC, NULL, NULL));
 #endif
 
 	/*
@@ -320,8 +320,8 @@ static inline void mm_free_pgd(struct mm_struct * mm)
 
  __cacheline_aligned_in_smp DEFINE_SPINLOCK(mmlist_lock);
 
-#define allocate_mm()	(kmem_cache_alloc(mm_cachep, GFP_KERNEL))
-#define free_mm(mm)	(kmem_cache_free(mm_cachep, (mm)))
+#define allocate_mm()	(kmem_cache_alloc(read_always(mm_cachep), GFP_KERNEL))
+#define free_mm(mm)	(kmem_cache_free(read_always(mm_cachep), (mm)))
 
 #include <linux/init_task.h>
 
@@ -836,14 +836,14 @@ static inline int copy_signal(unsigned long clone_flags, struct task_struct * ts
 		atomic_inc(&current->signal->live);
 		return 0;
 	}
-	sig = kmem_cache_alloc(signal_cachep, GFP_KERNEL);
+	sig = kmem_cache_alloc(read_always(signal_cachep), GFP_KERNEL);
 	tsk->signal = sig;
 	if (!sig)
 		return -ENOMEM;
 
 	ret = copy_thread_group_keys(tsk);
 	if (ret < 0) {
-		kmem_cache_free(signal_cachep, sig);
+		kmem_cache_free(read_always(signal_cachep), sig);
 		return ret;
 	}
 
@@ -900,7 +900,7 @@ static inline int copy_signal(unsigned long clone_flags, struct task_struct * ts
 void __cleanup_signal(struct signal_struct *sig)
 {
 	exit_thread_group_keys(sig);
-	kmem_cache_free(signal_cachep, sig);
+	kmem_cache_free(read_always(signal_cachep), sig);
 }
 
 static inline void cleanup_signal(struct task_struct *tsk)
@@ -1434,21 +1434,21 @@ void __init proc_caches_init(void)
 			sizeof(struct sighand_struct), 0,
 			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_DESTROY_BY_RCU,
 			sighand_ctor, NULL);
-	signal_cachep = kmem_cache_create("signal_cache",
+	set_read_always(signal_cachep, kmem_cache_create("signal_cache",
 			sizeof(struct signal_struct), 0,
-			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL);
+			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL));
 	files_cachep = kmem_cache_create("files_cache", 
 			sizeof(struct files_struct), 0,
 			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL);
 	fs_cachep = kmem_cache_create("fs_cache", 
 			sizeof(struct fs_struct), 0,
 			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL);
-	vm_area_cachep = kmem_cache_create("vm_area_struct",
+	set_read_always(__vm_area_cachep, kmem_cache_create("vm_area_struct",
 			sizeof(struct vm_area_struct), 0,
-			SLAB_PANIC, NULL, NULL);
-	mm_cachep = kmem_cache_create("mm_struct",
+			SLAB_PANIC, NULL, NULL));
+	set_read_always(mm_cachep, kmem_cache_create("mm_struct",
 			sizeof(struct mm_struct), ARCH_MIN_MMSTRUCT_ALIGN,
-			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL);
+			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL));
 }
 
 
diff --git a/mm/memory.c b/mm/memory.c
index e7066e7..36c062e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -61,12 +61,13 @@
 #include <linux/elf.h>
 
 #ifndef CONFIG_NEED_MULTIPLE_NODES
+#include <asm/read_always.h>
 /* use the per-pgdat data instead for discontigmem - mbligh */
 unsigned long max_mapnr;
-struct page *mem_map;
+struct page *__mem_map;
 
 EXPORT_SYMBOL(max_mapnr);
-EXPORT_SYMBOL(mem_map);
+EXPORT_SYMBOL(__mem_map);
 #endif
 
 unsigned long num_physpages;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 353ce90..b312e5c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2718,11 +2718,16 @@ static void __init alloc_node_mem_map(struct pglist_data *pgdat)
 	 * With no DISCONTIG, the global mem_map is just set as node 0's
 	 */
 	if (pgdat == NODE_DATA(0)) {
-		mem_map = NODE_DATA(0)->node_mem_map;
+		struct page *map = NODE_DATA(0)->node_mem_map;
 #ifdef CONFIG_ARCH_POPULATES_NODE_MAP
-		if (page_to_pfn(mem_map) != pgdat->node_start_pfn)
-			mem_map -= pgdat->node_start_pfn;
+		if (page_to_pfn(map) != pgdat->node_start_pfn)
+			map -= pgdat->node_start_pfn;
 #endif /* CONFIG_ARCH_POPULATES_NODE_MAP */
+#ifdef mem_map
+		set_read_always(__mem_map, map);
+#else
+		mem_map = map;
+#endif
 	}
 #endif
 #endif /* CONFIG_FLAT_NODE_MEM_MAP */
diff --git a/net/core/dev.c b/net/core/dev.c
index cf71614..e3975cf 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -229,7 +229,7 @@ extern void netdev_unregister_sysfs(struct net_device *);
  *	For efficiency
  */
 
-static int netdev_nit;
+static DEFINE_READ_ALWAYS(int, netdev_nit);
 
 /*
  *	Add a protocol ID to the list. Now that the input handler is
@@ -266,7 +266,7 @@ void dev_add_pack(struct packet_type *pt)
 
 	spin_lock_bh(&ptype_lock);
 	if (pt->type == htons(ETH_P_ALL)) {
-		netdev_nit++;
+		set_read_always(netdev_nit, netdev_nit + 1);
 		list_add_rcu(&pt->list, &ptype_all);
 	} else {
 		hash = ntohs(pt->type) & 15;
@@ -296,7 +296,7 @@ void __dev_remove_pack(struct packet_type *pt)
 	spin_lock_bh(&ptype_lock);
 
 	if (pt->type == htons(ETH_P_ALL)) {
-		netdev_nit--;
+		set_read_always(netdev_nit, netdev_nit - 1);
 		head = &ptype_all;
 	} else
 		head = &ptype_base[ntohs(pt->type) & 15];
@@ -1343,7 +1343,7 @@ static int dev_gso_segment(struct sk_buff *skb)
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	if (likely(!skb->next)) {
-		if (netdev_nit)
+		if (read_always(netdev_nit))
 			dev_queue_xmit_nit(skb, dev);
 
 		if (netif_needs_gso(dev, skb)) {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 820761f..2595a97 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -64,11 +64,14 @@
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
+#include <asm/read_always.h>
 
 #include "kmap_skb.h"
 
-static struct kmem_cache *skbuff_head_cache __read_mostly;
-static struct kmem_cache *skbuff_fclone_cache __read_mostly;
+static DEFINE_READ_ALWAYS(struct kmem_cache *, __skbuff_head_cache);
+#define skbuff_head_cache	read_always(__skbuff_head_cache)
+static DEFINE_READ_ALWAYS(struct kmem_cache *, __skbuff_fclone_cache);
+#define skbuff_fclone_cache	read_always(__skbuff_fclone_cache)
 
 /*
  *	Keep out-of-line to prevent kernel bloat.
@@ -2046,17 +2049,19 @@ EXPORT_SYMBOL_GPL(skb_segment);
 
 void __init skb_init(void)
 {
-	skbuff_head_cache = kmem_cache_create("skbuff_head_cache",
+	set_read_always(__skbuff_head_cache, kmem_cache_create(
+					      "skbuff_head_cache",
 					      sizeof(struct sk_buff),
 					      0,
 					      SLAB_HWCACHE_ALIGN|SLAB_PANIC,
-					      NULL, NULL);
-	skbuff_fclone_cache = kmem_cache_create("skbuff_fclone_cache",
+					      NULL, NULL));
+	set_read_always(__skbuff_fclone_cache, kmem_cache_create(
+						"skbuff_fclone_cache",
 						(2*sizeof(struct sk_buff)) +
 						sizeof(atomic_t),
 						0,
 						SLAB_HWCACHE_ALIGN|SLAB_PANIC,
-						NULL, NULL);
+						NULL, NULL));
 }
 
 EXPORT_SYMBOL(___pskb_trim);
