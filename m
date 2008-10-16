From: Hannes Hering <hannes.hering@linux.vnet.ibm.com>
Subject: [PATCH] ehea: Fix memory hotplug support
Date: Thu, 16 Oct 2008 11:36:42 +0200
Message-ID: <200810161136.42822.hannes.hering@linux.vnet.ibm.com>
References: <200809171619.46741.hannes.hering@linux.vnet.ibm.com> <200810151318.59151.hannes.hering@linux.vnet.ibm.com> <48F7056F.7050602@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, ossrosch@linux.vnet.ibm.com,
	ossthema@de.ibm.com, raisch@de.ibm.com, themann@de.ibm.com,
	osstklei@de.ibm.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.17.161]:48226 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753142AbYJPJgv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 05:36:51 -0400
In-Reply-To: <48F7056F.7050602@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements the memory notifier to update the busmap instantly
instead of rebuilding the whole map. This is necessary because
walk_memory_resource provides different information than required during memory
hotplug.

Signed-off-by: Hannes Hering <hering2@de.ibm.com>
---
Jeff, as requested, this patch is now based on davem's net-2.6.git.

diff -Nurp -X dontdiff linux-2.6.27/drivers/net/ehea/ehea.h patched_kernel/drivers/net/ehea/ehea.h
--- linux-2.6.27/drivers/net/ehea/ehea.h	2008-10-16 11:22:15.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea.h	2008-10-16 11:23:00.646563117 +0200
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0093"
+#define DRV_VERSION	"EHEA_0094"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
diff -Nurp -X dontdiff linux-2.6.27/drivers/net/ehea/ehea_main.c patched_kernel/drivers/net/ehea/ehea_main.c
--- linux-2.6.27/drivers/net/ehea/ehea_main.c	2008-10-16 11:22:15.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea_main.c	2008-10-16 11:23:00.646563117 +0200
@@ -2863,7 +2863,7 @@ static void ehea_rereg_mrs(struct work_s
 	struct ehea_adapter *adapter;
 
 	mutex_lock(&dlpar_mem_lock);
-	ehea_info("LPAR memory enlarged - re-initializing driver");
+	ehea_info("LPAR memory changed - re-initializing driver");
 
 	list_for_each_entry(adapter, &adapter_list, list)
 		if (adapter->active_ports) {
@@ -2900,13 +2900,6 @@ static void ehea_rereg_mrs(struct work_s
 			}
 		}
 
-	ehea_destroy_busmap();
-	ret = ehea_create_busmap();
-	if (ret) {
-		ehea_error("creating ehea busmap failed");
-		goto out;
-	}
-
 	clear_bit(__EHEA_STOP_XFER, &ehea_driver_flags);
 
 	list_for_each_entry(adapter, &adapter_list, list)
@@ -3519,9 +3512,21 @@ void ehea_crash_handler(void)
 static int ehea_mem_notifier(struct notifier_block *nb,
                              unsigned long action, void *data)
 {
+	struct memory_notify *arg = data;
 	switch (action) {
-	case MEM_OFFLINE:
-		ehea_info("memory has been removed");
+	case MEM_CANCEL_OFFLINE:
+		ehea_info("memory offlining canceled");
+		/* Readd canceled memory block */
+	case MEM_ONLINE:
+		ehea_info("memory is going online");
+		if (ehea_add_sect_bmap(arg->start_pfn, arg->nr_pages))
+			return NOTIFY_BAD;
+		ehea_rereg_mrs(NULL);
+		break;
+	case MEM_GOING_OFFLINE:
+		ehea_info("memory is going offline");
+		if (ehea_rem_sect_bmap(arg->start_pfn, arg->nr_pages))
+			return NOTIFY_BAD;
 		ehea_rereg_mrs(NULL);
 		break;
 	default:
diff -Nurp -X dontdiff linux-2.6.27/drivers/net/ehea/ehea_qmr.c patched_kernel/drivers/net/ehea/ehea_qmr.c
--- linux-2.6.27/drivers/net/ehea/ehea_qmr.c	2008-10-16 11:22:15.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea_qmr.c	2008-10-16 11:23:00.646563117 +0200
@@ -567,7 +567,7 @@ static inline int ehea_calc_index(unsign
 static inline int ehea_init_top_bmap(struct ehea_top_bmap *ehea_top_bmap,
 				     int dir)
 {
-	if(!ehea_top_bmap->dir[dir]) {
+	if (!ehea_top_bmap->dir[dir]) {
 		ehea_top_bmap->dir[dir] =
 			kzalloc(sizeof(struct ehea_dir_bmap), GFP_KERNEL);
 		if (!ehea_top_bmap->dir[dir])
@@ -578,7 +578,7 @@ static inline int ehea_init_top_bmap(str
 
 static inline int ehea_init_bmap(struct ehea_bmap *ehea_bmap, int top, int dir)
 {
-	if(!ehea_bmap->top[top]) {
+	if (!ehea_bmap->top[top]) {
 		ehea_bmap->top[top] =
 			kzalloc(sizeof(struct ehea_top_bmap), GFP_KERNEL);
 		if (!ehea_bmap->top[top])
@@ -587,53 +587,124 @@ static inline int ehea_init_bmap(struct 
 	return ehea_init_top_bmap(ehea_bmap->top[top], dir);
 }
 
-static int ehea_create_busmap_callback(unsigned long pfn,
-				       unsigned long nr_pages, void *arg)
-{
-	unsigned long i, mr_len, start_section, end_section;
-	start_section = (pfn * PAGE_SIZE) / EHEA_SECTSIZE;
-	end_section = start_section + ((nr_pages * PAGE_SIZE) / EHEA_SECTSIZE);
-	mr_len = *(unsigned long *)arg;
+static DEFINE_MUTEX(ehea_busmap_mutex);
+static unsigned long ehea_mr_len;
 
-	if (!ehea_bmap)
-		ehea_bmap = kzalloc(sizeof(struct ehea_bmap), GFP_KERNEL);
-	if (!ehea_bmap)
-		return -ENOMEM;
+#define EHEA_BUSMAP_ADD_SECT 1
+#define EHEA_BUSMAP_REM_SECT 0
 
-	for (i = start_section; i < end_section; i++) {
-		int ret;
-		int top, dir, idx;
-		u64 vaddr;
+static void ehea_rebuild_busmap(void)
+{
+	u64 vaddr = EHEA_BUSMAP_START;
+	int top, dir, idx;
+
+	for (top = 0; top < EHEA_MAP_ENTRIES; top++) {
+		struct ehea_top_bmap *ehea_top;
+		int valid_dir_entries = 0;
 
-		top = ehea_calc_index(i, EHEA_TOP_INDEX_SHIFT);
-		dir = ehea_calc_index(i, EHEA_DIR_INDEX_SHIFT);
+		if (!ehea_bmap->top[top])
+			continue;
+		ehea_top = ehea_bmap->top[top];
+		for (dir = 0; dir < EHEA_MAP_ENTRIES; dir++) {
+			struct ehea_dir_bmap *ehea_dir;
+			int valid_entries = 0;
 
-		ret = ehea_init_bmap(ehea_bmap, top, dir);
-		if(ret)
-			return ret;
+			if (!ehea_top->dir[dir])
+				continue;
+			valid_dir_entries++;
+			ehea_dir = ehea_top->dir[dir];
+			for (idx = 0; idx < EHEA_MAP_ENTRIES; idx++) {
+				if (!ehea_dir->ent[idx])
+					continue;
+				valid_entries++;
+				ehea_dir->ent[idx] = vaddr;
+				vaddr += EHEA_SECTSIZE;
+			}
+			if (!valid_entries) {
+				ehea_top->dir[dir] = NULL;
+				kfree(ehea_dir);
+			}
+		}
+		if (!valid_dir_entries) {
+			ehea_bmap->top[top] = NULL;
+			kfree(ehea_top);
+		}
+	}
+}
 
-		idx = i & EHEA_INDEX_MASK;
-		vaddr = EHEA_BUSMAP_START + mr_len + i * EHEA_SECTSIZE;
+static int ehea_update_busmap(unsigned long pfn, unsigned long pgnum, int add)
+{
+	unsigned long i, start_section, end_section;
 
-		ehea_bmap->top[top]->dir[dir]->ent[idx] = vaddr;
+	if (!ehea_bmap) {
+		ehea_bmap = kzalloc(sizeof(struct ehea_bmap), GFP_KERNEL);
+		if (!ehea_bmap)
+			return -ENOMEM;
 	}
 
-	mr_len += nr_pages * PAGE_SIZE;
-	*(unsigned long *)arg = mr_len;
+	start_section = (pfn * PAGE_SIZE) / EHEA_SECTSIZE;
+	end_section = start_section + ((pgnum * PAGE_SIZE) / EHEA_SECTSIZE);
+	/* Mark entries as valid or invalid only; address is assigned later */
+	for (i = start_section; i < end_section; i++) {
+		u64 flag;
+		int top = ehea_calc_index(i, EHEA_TOP_INDEX_SHIFT);
+		int dir = ehea_calc_index(i, EHEA_DIR_INDEX_SHIFT);
+		int idx = i & EHEA_INDEX_MASK;
+		
+		if (add) {
+			int ret = ehea_init_bmap(ehea_bmap, top, dir);
+			if (ret)
+				return ret;
+			flag = 1; /* valid */
+			ehea_mr_len += EHEA_SECTSIZE;
+		} else {
+			if (!ehea_bmap->top[top])
+				continue;
+			if (!ehea_bmap->top[top]->dir[dir])
+				continue;
+			flag = 0; /* invalid */
+			ehea_mr_len -= EHEA_SECTSIZE;
+		}
 
+		ehea_bmap->top[top]->dir[dir]->ent[idx] = flag;
+	}
+	ehea_rebuild_busmap(); /* Assign contiguous addresses for mr */
 	return 0;
 }
 
-static unsigned long ehea_mr_len;
+int ehea_add_sect_bmap(unsigned long pfn, unsigned long nr_pages)
+{
+	int ret;
 
-static DEFINE_MUTEX(ehea_busmap_mutex);
+	mutex_lock(&ehea_busmap_mutex);
+	ret = ehea_update_busmap(pfn, nr_pages, EHEA_BUSMAP_ADD_SECT);
+	mutex_unlock(&ehea_busmap_mutex);
+	return ret;
+}
+
+int ehea_rem_sect_bmap(unsigned long pfn, unsigned long nr_pages)
+{
+	int ret;
+
+	mutex_lock(&ehea_busmap_mutex);
+	ret = ehea_update_busmap(pfn, nr_pages, EHEA_BUSMAP_REM_SECT);
+	mutex_unlock(&ehea_busmap_mutex);
+	return ret;
+}
+
+static int ehea_create_busmap_callback(unsigned long pfn,
+				       unsigned long nr_pages, void *arg)
+{
+	return ehea_update_busmap(pfn, nr_pages, EHEA_BUSMAP_ADD_SECT);
+}
 
 int ehea_create_busmap(void)
 {
 	int ret;
+
 	mutex_lock(&ehea_busmap_mutex);
 	ehea_mr_len = 0;
-	ret = walk_memory_resource(0, 1ULL << MAX_PHYSMEM_BITS, &ehea_mr_len,
+	ret = walk_memory_resource(0, 1ULL << MAX_PHYSMEM_BITS, NULL,
 				   ehea_create_busmap_callback);
 	mutex_unlock(&ehea_busmap_mutex);
 	return ret;
diff -Nurp -X dontdiff linux-2.6.27/drivers/net/ehea/ehea_qmr.h patched_kernel/drivers/net/ehea/ehea_qmr.h
--- linux-2.6.27/drivers/net/ehea/ehea_qmr.h	2008-10-16 11:22:15.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea_qmr.h	2008-10-16 11:23:00.646563117 +0200
@@ -378,6 +378,8 @@ int ehea_rem_mr(struct ehea_mr *mr);
 
 void ehea_error_data(struct ehea_adapter *adapter, u64 res_handle);
 
+int ehea_add_sect_bmap(unsigned long pfn, unsigned long nr_pages);
+int ehea_rem_sect_bmap(unsigned long pfn, unsigned long nr_pages);
 int ehea_create_busmap(void);
 void ehea_destroy_busmap(void);
 u64 ehea_map_vaddr(void *caddr);
