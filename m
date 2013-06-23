From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH 45/45] tile: Use get/put_online_cpus_atomic() to prevent CPU
 offline
Date: Sun, 23 Jun 2013 19:18:11 +0530
Message-ID: <20130623134807.19094.82081.stgit@srivatsabhat.in.ibm.com>
References: <20130623133642.19094.16038.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, sbw@mit.edu, fweisbec@gmail.com,
	zhong@linux.vnet.ibm.com, nikunj@linux.vnet.ibm.com,
	srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Chris Metcalf <cmetcalf@tilera.com>
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	walken@google.com, vincent.guittot@linaro.org, laijs@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp05.au.ibm.com ([202.81.31.147]:57756 "EHLO
	e23smtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753124Ab3FWNvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jun 2013 09:51:36 -0400
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Sun, 23 Jun 2013 23:45:29 +1000
In-Reply-To: <20130623133642.19094.16038.stgit@srivatsabhat.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Once stop_machine() is gone from the CPU offline path, we won't be able
to depend on disabling preemption to prevent CPUs from going offline
from under us.

Use the get/put_online_cpus_atomic() APIs to prevent CPUs from going
offline, while invoking from atomic context.

Cc: Chris Metcalf <cmetcalf@tilera.com>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 arch/tile/kernel/module.c |    3 +++
 arch/tile/kernel/tlb.c    |   15 +++++++++++++++
 arch/tile/mm/homecache.c  |    3 +++
 3 files changed, 21 insertions(+)

diff --git a/arch/tile/kernel/module.c b/arch/tile/kernel/module.c
index 4918d91..db7d858 100644
--- a/arch/tile/kernel/module.c
+++ b/arch/tile/kernel/module.c
@@ -20,6 +20,7 @@
 #include <linux/fs.h>
 #include <linux/string.h>
 #include <linux/kernel.h>
+#include <linux/cpu.h>
 #include <asm/pgtable.h>
 #include <asm/homecache.h>
 #include <arch/opcode.h>
@@ -79,8 +80,10 @@ void module_free(struct module *mod, void *module_region)
 	vfree(module_region);
 
 	/* Globally flush the L1 icache. */
+	get_online_cpus_atomic();
 	flush_remote(0, HV_FLUSH_EVICT_L1I, cpu_online_mask,
 		     0, 0, 0, NULL, NULL, 0);
+	put_online_cpus_atomic();
 
 	/*
 	 * FIXME: If module_region == mod->module_init, trim exception
diff --git a/arch/tile/kernel/tlb.c b/arch/tile/kernel/tlb.c
index 3fd54d5..a32b9dd 100644
--- a/arch/tile/kernel/tlb.c
+++ b/arch/tile/kernel/tlb.c
@@ -14,6 +14,7 @@
  */
 
 #include <linux/cpumask.h>
+#include <linux/cpu.h>
 #include <linux/module.h>
 #include <linux/hugetlb.h>
 #include <asm/tlbflush.h>
@@ -35,6 +36,8 @@ void flush_tlb_mm(struct mm_struct *mm)
 {
 	HV_Remote_ASID asids[NR_CPUS];
 	int i = 0, cpu;
+
+	get_online_cpus_atomic();
 	for_each_cpu(cpu, mm_cpumask(mm)) {
 		HV_Remote_ASID *asid = &asids[i++];
 		asid->y = cpu / smp_topology.width;
@@ -43,6 +46,7 @@ void flush_tlb_mm(struct mm_struct *mm)
 	}
 	flush_remote(0, HV_FLUSH_EVICT_L1I, mm_cpumask(mm),
 		     0, 0, 0, NULL, asids, i);
+	put_online_cpus_atomic();
 }
 
 void flush_tlb_current_task(void)
@@ -55,8 +59,11 @@ void flush_tlb_page_mm(struct vm_area_struct *vma, struct mm_struct *mm,
 {
 	unsigned long size = vma_kernel_pagesize(vma);
 	int cache = (vma->vm_flags & VM_EXEC) ? HV_FLUSH_EVICT_L1I : 0;
+
+	get_online_cpus_atomic();
 	flush_remote(0, cache, mm_cpumask(mm),
 		     va, size, size, mm_cpumask(mm), NULL, 0);
+	put_online_cpus_atomic();
 }
 
 void flush_tlb_page(struct vm_area_struct *vma, unsigned long va)
@@ -71,13 +78,18 @@ void flush_tlb_range(struct vm_area_struct *vma,
 	unsigned long size = vma_kernel_pagesize(vma);
 	struct mm_struct *mm = vma->vm_mm;
 	int cache = (vma->vm_flags & VM_EXEC) ? HV_FLUSH_EVICT_L1I : 0;
+
+	get_online_cpus_atomic();
 	flush_remote(0, cache, mm_cpumask(mm), start, end - start, size,
 		     mm_cpumask(mm), NULL, 0);
+	put_online_cpus_atomic();
 }
 
 void flush_tlb_all(void)
 {
 	int i;
+
+	get_online_cpus_atomic();
 	for (i = 0; ; ++i) {
 		HV_VirtAddrRange r = hv_inquire_virtual(i);
 		if (r.size == 0)
@@ -89,10 +101,13 @@ void flush_tlb_all(void)
 			     r.start, r.size, HPAGE_SIZE, cpu_online_mask,
 			     NULL, 0);
 	}
+	put_online_cpus_atomic();
 }
 
 void flush_tlb_kernel_range(unsigned long start, unsigned long end)
 {
+	get_online_cpus_atomic();
 	flush_remote(0, HV_FLUSH_EVICT_L1I, cpu_online_mask,
 		     start, end - start, PAGE_SIZE, cpu_online_mask, NULL, 0);
+	put_online_cpus_atomic();
 }
diff --git a/arch/tile/mm/homecache.c b/arch/tile/mm/homecache.c
index 1ae9119..7ff5bf0 100644
--- a/arch/tile/mm/homecache.c
+++ b/arch/tile/mm/homecache.c
@@ -397,9 +397,12 @@ void homecache_change_page_home(struct page *page, int order, int home)
 	BUG_ON(page_count(page) > 1);
 	BUG_ON(page_mapcount(page) != 0);
 	kva = (unsigned long) page_address(page);
+
+	get_online_cpus_atomic();
 	flush_remote(0, HV_FLUSH_EVICT_L2, &cpu_cacheable_map,
 		     kva, pages * PAGE_SIZE, PAGE_SIZE, cpu_online_mask,
 		     NULL, 0);
+	put_online_cpus_atomic();
 
 	for (i = 0; i < pages; ++i, kva += PAGE_SIZE) {
 		pte_t *ptep = virt_to_pte(NULL, kva);
