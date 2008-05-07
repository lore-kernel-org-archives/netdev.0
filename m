From: Hannes Hering <hannes.hering@linux.vnet.ibm.com>
Subject: [PATCH 3/3] [2.6.26] ehea: Add DLPAR memory remove support
Date: Wed, 7 May 2008 14:43:36 +0200
Message-ID: <200805071443.36660.hannes.hering@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, ossrosch@linux.vnet.ibm.com,
	ossthema@de.ibm.com, raisch@de.ibm.com, themann@de.ibm.com,
	tklein@de.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([195.212.29.135]:32499 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756599AbYEGMoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 08:44:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The eHEA driver uses the recently modified walk_memory_resource for powerpc
functionality to detect the memory layout. It further uses the memory hotplug
notifiers to catch memory hotplug events.

Signed-off-by: Hannes Hering <hering2@de.ibm.com>
---

diff -Nurp -X dontdiff linux-2.6.26-rc1/drivers/net/ehea/ehea.h patched_kernel/drivers/net/ehea/ehea.h
--- linux-2.6.26-rc1/drivers/net/ehea/ehea.h	2008-05-03 20:59:44.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea.h	2008-05-07 14:09:50.000000000 +0200
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0090"
+#define DRV_VERSION	"EHEA_0091"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
@@ -118,6 +118,13 @@
 #define EHEA_MR_ACC_CTRL       0x00800000
 
 #define EHEA_BUSMAP_START      0x8000000000000000ULL
+#define EHEA_INVAL_ADDR        0xFFFFFFFFFFFFFFFFULL
+#define EHEA_DIR_INDEX_SHIFT 13                   /* 8k Entries in 64k block */
+#define EHEA_TOP_INDEX_SHIFT (EHEA_DIR_INDEX_SHIFT * 2)
+#define EHEA_MAP_ENTRIES (1 << EHEA_DIR_INDEX_SHIFT)
+#define EHEA_MAP_SIZE (0x10000)                   /* currently fixed map size */
+#define EHEA_INDEX_MASK (EHEA_MAP_ENTRIES - 1)
+
 
 #define EHEA_WATCH_DOG_TIMEOUT 10*HZ
 
@@ -192,10 +199,20 @@ struct h_epas {
 				   set to 0 if unused */
 };
 
-struct ehea_busmap {
-	unsigned int entries;		/* total number of entries */
-	unsigned int valid_sections;	/* number of valid sections */
-	u64 *vaddr;
+/*
+ * Memory map data structures
+ */
+struct ehea_dir_bmap
+{
+	u64 ent[EHEA_MAP_ENTRIES];
+};
+struct ehea_top_bmap
+{
+	struct ehea_dir_bmap *dir[EHEA_MAP_ENTRIES];
+};
+struct ehea_bmap
+{
+	struct ehea_top_bmap *top[EHEA_MAP_ENTRIES];
 };
 
 struct ehea_qp;
diff -Nurp -X dontdiff linux-2.6.26-rc1/drivers/net/ehea/ehea_main.c patched_kernel/drivers/net/ehea/ehea_main.c
--- linux-2.6.26-rc1/drivers/net/ehea/ehea_main.c	2008-05-03 20:59:44.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea_main.c	2008-05-07 14:09:50.000000000 +0200
@@ -35,6 +35,7 @@
 #include <linux/if_ether.h>
 #include <linux/notifier.h>
 #include <linux/reboot.h>
+#include <linux/memory.h>
 #include <asm/kexec.h>
 #include <linux/mutex.h>
 
@@ -3503,6 +3504,24 @@ void ehea_crash_handler(void)
 					      0, H_DEREG_BCMC);
 }
 
+static int ehea_mem_notifier(struct notifier_block *nb,
+                             unsigned long action, void *data)
+{
+	switch (action) {
+	case MEM_OFFLINE:
+		ehea_info("memory has been removed");
+		ehea_rereg_mrs(NULL);
+		break;
+	default:
+		break;
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block ehea_mem_nb = {
+	.notifier_call = ehea_mem_notifier,
+};
+
 static int ehea_reboot_notifier(struct notifier_block *nb,
 				unsigned long action, void *unused)
 {
@@ -3581,6 +3600,10 @@ int __init ehea_module_init(void)
 	if (ret)
 		ehea_info("failed registering reboot notifier");
 
+	ret = register_memory_notifier(&ehea_mem_nb);
+	if (ret)
+		ehea_info("failed registering memory remove notifier");
+
 	ret = crash_shutdown_register(&ehea_crash_handler);
 	if (ret)
 		ehea_info("failed registering crash handler");
@@ -3604,6 +3627,7 @@ int __init ehea_module_init(void)
 out3:
 	ibmebus_unregister_driver(&ehea_driver);
 out2:
+	unregister_memory_notifier(&ehea_mem_nb);
 	unregister_reboot_notifier(&ehea_reboot_nb);
 	crash_shutdown_unregister(&ehea_crash_handler);
 out:
@@ -3621,6 +3645,7 @@ static void __exit ehea_module_exit(void
 	ret = crash_shutdown_unregister(&ehea_crash_handler);
 	if (ret)
 		ehea_info("failed unregistering crash handler");
+	unregister_memory_notifier(&ehea_mem_nb);
 	kfree(ehea_fw_handles.arr);
 	kfree(ehea_bcmc_regs.arr);
 	ehea_destroy_busmap();
diff -Nurp -X dontdiff linux-2.6.26-rc1/drivers/net/ehea/ehea_qmr.c patched_kernel/drivers/net/ehea/ehea_qmr.c
--- linux-2.6.26-rc1/drivers/net/ehea/ehea_qmr.c	2008-05-03 20:59:44.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea_qmr.c	2008-05-07 14:09:50.000000000 +0200
@@ -31,8 +31,8 @@
 #include "ehea_phyp.h"
 #include "ehea_qmr.h"
 
+struct ehea_bmap *ehea_bmap = NULL;
 
-struct ehea_busmap ehea_bmap = { 0, 0, NULL };
 
 
 static void *hw_qpageit_get_inc(struct hw_queue *queue)
@@ -559,125 +559,253 @@ int ehea_destroy_qp(struct ehea_qp *qp)
 	return 0;
 }
 
-int ehea_create_busmap(void)
+static inline int ehea_calc_index(unsigned long i, unsigned long s)
 {
-	u64 vaddr = EHEA_BUSMAP_START;
-	unsigned long high_section_index = 0;
-	int i;
+	return (i >> s) & EHEA_INDEX_MASK;
+}
 
-	/*
-	 * Sections are not in ascending order -> Loop over all sections and
-	 * find the highest PFN to compute the required map size.
-	*/
-	ehea_bmap.valid_sections = 0;
-
-	for (i = 0; i < NR_MEM_SECTIONS; i++)
-		if (valid_section_nr(i))
-			high_section_index = i;
+static inline int ehea_init_top_bmap(struct ehea_top_bmap *ehea_top_bmap,
+				     int dir)
+{
+	if(!ehea_top_bmap->dir[dir]) {
+		ehea_top_bmap->dir[dir] =
+			kzalloc(sizeof(struct ehea_dir_bmap), GFP_KERNEL);
+		if (!ehea_top_bmap->dir[dir])
+			return -ENOMEM;
+	}
+	return 0;
+}
 
-	ehea_bmap.entries = high_section_index + 1;
-	ehea_bmap.vaddr = vmalloc(ehea_bmap.entries * sizeof(*ehea_bmap.vaddr));
+static inline int ehea_init_bmap(struct ehea_bmap *ehea_bmap, int top, int dir)
+{
+	if(!ehea_bmap->top[top]) {
+		ehea_bmap->top[top] =
+			kzalloc(sizeof(struct ehea_top_bmap), GFP_KERNEL);
+		if (!ehea_bmap->top[top])
+			return -ENOMEM;
+	}
+	return ehea_init_top_bmap(ehea_bmap->top[top], dir);
+}
+
+static int ehea_create_busmap_callback(unsigned long pfn,
+				       unsigned long nr_pages, void *arg)
+{
+	unsigned long i, mr_len, start_section, end_section;
+	start_section = (pfn * PAGE_SIZE) / EHEA_SECTSIZE;
+	end_section = start_section + ((nr_pages * PAGE_SIZE) / EHEA_SECTSIZE);
+	mr_len = *(unsigned long *)arg;
 
-	if (!ehea_bmap.vaddr)
+	ehea_bmap = kzalloc(sizeof(struct ehea_bmap), GFP_KERNEL);
+	if (!ehea_bmap)
 		return -ENOMEM;
 
-	for (i = 0 ; i < ehea_bmap.entries; i++) {
-		unsigned long pfn = section_nr_to_pfn(i);
+	for (i = start_section; i < end_section; i++) {
+		int ret;
+		int top, dir, idx;
+		u64 vaddr;
+
+		top = ehea_calc_index(i, EHEA_TOP_INDEX_SHIFT);
+		dir = ehea_calc_index(i, EHEA_DIR_INDEX_SHIFT);
 
-		if (pfn_valid(pfn)) {
-			ehea_bmap.vaddr[i] = vaddr;
-			vaddr += EHEA_SECTSIZE;
-			ehea_bmap.valid_sections++;
-		} else
-			ehea_bmap.vaddr[i] = 0;
+		ret = ehea_init_bmap(ehea_bmap, top, dir);
+		if(ret)
+			return ret;
+
+		idx = i & EHEA_INDEX_MASK;
+		vaddr = EHEA_BUSMAP_START + mr_len + i * EHEA_SECTSIZE;
+
+		ehea_bmap->top[top]->dir[dir]->ent[idx] = vaddr;
 	}
 
+	mr_len += nr_pages * PAGE_SIZE;
+	*(unsigned long *)arg = mr_len;
+
 	return 0;
 }
 
+static unsigned long ehea_mr_len;
+
+static DEFINE_MUTEX(ehea_busmap_mutex);
+
+int ehea_create_busmap(void)
+{
+	int ret;
+	mutex_lock(&ehea_busmap_mutex);
+	ehea_mr_len = 0;
+	ret = walk_memory_resource(0, 1ULL << MAX_PHYSMEM_BITS, &ehea_mr_len,
+				   ehea_create_busmap_callback);
+	mutex_unlock(&ehea_busmap_mutex);
+	return ret;
+}
+
 void ehea_destroy_busmap(void)
 {
-	vfree(ehea_bmap.vaddr);
+	int top, dir;
+	mutex_lock(&ehea_busmap_mutex);
+	if (!ehea_bmap)
+		goto out_destroy;
+
+	for (top = 0; top < EHEA_MAP_ENTRIES; top++) {
+		if (!ehea_bmap->top[top])
+			continue;
+
+		for (dir = 0; dir < EHEA_MAP_ENTRIES; dir++) {
+			if (!ehea_bmap->top[top]->dir[dir])
+				continue;
+
+			kfree(ehea_bmap->top[top]->dir[dir]);
+		}
+
+		kfree(ehea_bmap->top[top]);
+	}
+
+	kfree(ehea_bmap);
+	ehea_bmap = NULL;
+out_destroy:	
+	mutex_unlock(&ehea_busmap_mutex);
 }
 
 u64 ehea_map_vaddr(void *caddr)
 {
-	u64 mapped_addr;
-	unsigned long index = __pa(caddr) >> SECTION_SIZE_BITS;
+	int top, dir, idx;
+	unsigned long index, offset;
+
+	if (!ehea_bmap)
+		return EHEA_INVAL_ADDR;
+
+	index = virt_to_abs(caddr) >> SECTION_SIZE_BITS;
+	top = (index >> EHEA_TOP_INDEX_SHIFT) & EHEA_INDEX_MASK;
+	if (!ehea_bmap->top[top])
+		return EHEA_INVAL_ADDR;
 
-	if (likely(index < ehea_bmap.entries)) {
-		mapped_addr = ehea_bmap.vaddr[index];
-		if (likely(mapped_addr))
-			mapped_addr |= (((unsigned long)caddr)
-					& (EHEA_SECTSIZE - 1));
-		else
-			mapped_addr = -1;
-	} else
-		mapped_addr = -1;
-
-	if (unlikely(mapped_addr == -1))
-		if (!test_and_set_bit(__EHEA_STOP_XFER, &ehea_driver_flags))
-			schedule_work(&ehea_rereg_mr_task);
+	dir = (index >> EHEA_DIR_INDEX_SHIFT) & EHEA_INDEX_MASK;
+	if (!ehea_bmap->top[top]->dir[dir])
+		return EHEA_INVAL_ADDR;
 
-	return mapped_addr;
+	idx = index & EHEA_INDEX_MASK;
+	if (!ehea_bmap->top[top]->dir[dir]->ent[idx])
+		return EHEA_INVAL_ADDR;
+
+	offset = (unsigned long)caddr & (EHEA_SECTSIZE - 1);
+	return ehea_bmap->top[top]->dir[dir]->ent[idx] | offset;
+}
+
+static inline void *ehea_calc_sectbase(int top, int dir, int idx)
+{
+	unsigned long ret = idx;
+	ret |= dir << EHEA_DIR_INDEX_SHIFT;
+	ret |= top << EHEA_TOP_INDEX_SHIFT;
+	return abs_to_virt(ret << SECTION_SIZE_BITS);
+}
+
+static u64 ehea_reg_mr_section(int top, int dir, int idx, u64 *pt,
+			       struct ehea_adapter *adapter,
+			       struct ehea_mr *mr)
+{
+	void *pg;
+	u64 j, m, hret;
+	unsigned long k = 0;
+	u64 pt_abs = virt_to_abs(pt);
+
+	void *sectbase = ehea_calc_sectbase(top, dir, idx);
+
+	for (j = 0; j < (EHEA_PAGES_PER_SECTION / EHEA_MAX_RPAGE); j++) {
+
+		for (m = 0; m < EHEA_MAX_RPAGE; m++) {
+			pg = sectbase + ((k++) * EHEA_PAGESIZE);
+			pt[m] = virt_to_abs(pg);
+		}
+		hret = ehea_h_register_rpage_mr(adapter->handle, mr->handle, 0,
+						0, pt_abs, EHEA_MAX_RPAGE);
+
+		if ((hret != H_SUCCESS)
+		    && (hret != H_PAGE_REGISTERED)) {
+			ehea_h_free_resource(adapter->handle, mr->handle,
+					     FORCE_FREE);
+			ehea_error("register_rpage_mr failed");
+			return hret;
+		}
+	}
+	return hret;
+}
+
+static u64 ehea_reg_mr_sections(int top, int dir, u64 *pt,
+				struct ehea_adapter *adapter,
+				struct ehea_mr *mr)
+{
+	u64 hret = H_SUCCESS;
+	int idx;
+
+	for (idx = 0; idx < EHEA_MAP_ENTRIES; idx++) {
+		if (!ehea_bmap->top[top]->dir[dir]->ent[idx])
+			continue;
+		
+		hret = ehea_reg_mr_section(top, dir, idx, pt, adapter, mr);
+		if ((hret != H_SUCCESS) && (hret != H_PAGE_REGISTERED))
+			    	return hret;
+	}
+	return hret;
+}
+
+static u64 ehea_reg_mr_dir_sections(int top, u64 *pt,
+				    struct ehea_adapter *adapter,
+				    struct ehea_mr *mr)
+{
+	u64 hret = H_SUCCESS;
+	int dir;
+
+	for (dir = 0; dir < EHEA_MAP_ENTRIES; dir++) {
+		if (!ehea_bmap->top[top]->dir[dir])
+			continue;
+
+		hret = ehea_reg_mr_sections(top, dir, pt, adapter, mr);
+		if ((hret != H_SUCCESS) && (hret != H_PAGE_REGISTERED))
+			    	return hret;
+	}
+	return hret;
 }
 
 int ehea_reg_kernel_mr(struct ehea_adapter *adapter, struct ehea_mr *mr)
 {
 	int ret;
 	u64 *pt;
-	void *pg;
-	u64 hret, pt_abs, i, j, m, mr_len;
+	u64 hret;
 	u32 acc_ctrl = EHEA_MR_ACC_CTRL;
 
-	mr_len = ehea_bmap.valid_sections * EHEA_SECTSIZE;
+	unsigned long top;
 
-	pt =  kzalloc(PAGE_SIZE, GFP_KERNEL);
+	pt = kzalloc(PAGE_SIZE, GFP_KERNEL);
 	if (!pt) {
 		ehea_error("no mem");
 		ret = -ENOMEM;
 		goto out;
 	}
-	pt_abs = virt_to_abs(pt);
 
-	hret = ehea_h_alloc_resource_mr(adapter->handle,
-					EHEA_BUSMAP_START, mr_len,
-					acc_ctrl, adapter->pd,
+	hret = ehea_h_alloc_resource_mr(adapter->handle, EHEA_BUSMAP_START,
+					ehea_mr_len, acc_ctrl, adapter->pd,
 					&mr->handle, &mr->lkey);
+
 	if (hret != H_SUCCESS) {
 		ehea_error("alloc_resource_mr failed");
 		ret = -EIO;
 		goto out;
 	}
 
-	for (i = 0 ; i < ehea_bmap.entries; i++)
-		if (ehea_bmap.vaddr[i]) {
-			void *sectbase = __va(i << SECTION_SIZE_BITS);
-			unsigned long k = 0;
-
-			for (j = 0; j < (EHEA_PAGES_PER_SECTION /
-					 EHEA_MAX_RPAGE); j++) {
-
-				for (m = 0; m < EHEA_MAX_RPAGE; m++) {
-					pg = sectbase + ((k++) * EHEA_PAGESIZE);
-					pt[m] = virt_to_abs(pg);
-				}
-
-				hret = ehea_h_register_rpage_mr(adapter->handle,
-								mr->handle,
-								0, 0, pt_abs,
-								EHEA_MAX_RPAGE);
-				if ((hret != H_SUCCESS)
-				    && (hret != H_PAGE_REGISTERED)) {
-					ehea_h_free_resource(adapter->handle,
-							     mr->handle,
-							     FORCE_FREE);
-					ehea_error("register_rpage_mr failed");
-					ret = -EIO;
-					goto out;
-				}
-			}
-		}
+	if (!ehea_bmap) {
+		ehea_h_free_resource(adapter->handle, mr->handle, FORCE_FREE);
+		ehea_error("no busmap available");
+		ret = -EIO;
+		goto out;
+	}
+
+	for (top = 0; top < EHEA_MAP_ENTRIES; top++) {
+		if (!ehea_bmap->top[top])
+			continue;
+
+		hret = ehea_reg_mr_dir_sections(top, pt, adapter, mr);
+		if((hret != H_PAGE_REGISTERED) && (hret != H_SUCCESS))
+			break;
+	}
 
 	if (hret != H_SUCCESS) {
 		ehea_h_free_resource(adapter->handle, mr->handle, FORCE_FREE);
