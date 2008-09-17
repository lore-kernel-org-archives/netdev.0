From: Hannes Hering <hannes.hering@linux.vnet.ibm.com>
Subject: [PATCH] [2.6.27] ehea: Fix memory hotplug support
Date: Wed, 17 Sep 2008 16:19:46 +0200
Message-ID: <200809171619.46741.hannes.hering@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, ossrosch@linux.vnet.ibm.com,
	ossthema@de.ibm.com, raisch@de.ibm.com, themann@de.ibm.com,
	osstklei@de.ibm.com
To: jeff@garzik.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754820AbYIQOUm@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch implements the memory notifier to update the busmap instantly
instead of rebuilding the whole map. This is necessary because
walk_memory_resource provides different information than required during memory
hotplug.

Signed-off-by: Hannes Hering <hering2@de.ibm.com>
---
This patch is based on upstream-fixes in the netdev-2.6.git.

diff -Nurp -X dontdiff linux-netdev-2.6/drivers/net/ehea/ehea.h patched_kernel/drivers/net/ehea/ehea.h
--- linux-netdev-2.6/drivers/net/ehea/ehea.h	2008-09-17 16:09:25.729017931 +0200
+++ patched_kernel/drivers/net/ehea/ehea.h	2008-09-17 16:11:26.481026217 +0200
@@ -40,13 +40,13 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0092"
+#define DRV_VERSION	"EHEA_0094"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
 #define DLPAR_MEM_ADD      2
 #define DLPAR_MEM_REM      4
-#define EHEA_CAPABILITIES  (DLPAR_PORT_ADD_REM | DLPAR_MEM_ADD)
+#define EHEA_CAPABILITIES  (DLPAR_PORT_ADD_REM | DLPAR_MEM_ADD | DLPAR_MEM_REM)
 
 #define EHEA_MSG_DEFAULT (NETIF_MSG_LINK | NETIF_MSG_TIMER \
 	| NETIF_MSG_RX_ERR | NETIF_MSG_TX_ERR)
diff -Nurp -X dontdiff linux-netdev-2.6/drivers/net/ehea/ehea_main.c patched_kernel/drivers/net/ehea/ehea_main.c
--- linux-netdev-2.6/drivers/net/ehea/ehea_main.c	2008-09-17 16:09:25.729017931 +0200
+++ patched_kernel/drivers/net/ehea/ehea_main.c	2008-09-17 16:11:26.481026217 +0200
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
@@ -3519,9 +3512,20 @@ void ehea_crash_handler(void)
 static int ehea_mem_notifier(struct notifier_block *nb,
                              unsigned long action, void *data)
 {
+	struct memory_notify *arg = data;
 	switch (action) {
-	case MEM_OFFLINE:
-		ehea_info("memory has been removed");
+	case MEM_CANCEL_OFFLINE:
+		ehea_info("memory offlining canceled");
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
diff -Nurp -X dontdiff linux-netdev-2.6/drivers/net/ehea/ehea_qmr.c patched_kernel/drivers/net/ehea/ehea_qmr.c
--- linux-netdev-2.6/drivers/net/ehea/ehea_qmr.c	2008-09-17 16:09:25.729017931 +0200
+++ patched_kernel/drivers/net/ehea/ehea_qmr.c	2008-09-17 16:11:26.481026217 +0200
@@ -587,53 +587,81 @@ static inline int ehea_init_bmap(struct 
 	return ehea_init_top_bmap(ehea_bmap->top[top], dir);
 }
 
-static int ehea_create_busmap_callback(unsigned long pfn,
-				       unsigned long nr_pages, void *arg)
+static DEFINE_MUTEX(ehea_busmap_mutex);
+static unsigned long ehea_mr_len;
+
+#define EHEA_BUSMAP_ADD_SECT 1
+#define EHEA_BUSMAP_REM_SECT 0
+
+static int ehea_update_busmap(unsigned long pfn, unsigned long pgnum, int add)
 {
-	unsigned long i, mr_len, start_section, end_section;
-	start_section = (pfn * PAGE_SIZE) / EHEA_SECTSIZE;
-	end_section = start_section + ((nr_pages * PAGE_SIZE) / EHEA_SECTSIZE);
-	mr_len = *(unsigned long *)arg;
+	unsigned long i, start_section, end_section;
 
 	if (!ehea_bmap)
 		ehea_bmap = kzalloc(sizeof(struct ehea_bmap), GFP_KERNEL);
 	if (!ehea_bmap)
 		return -ENOMEM;
 
+	start_section = (pfn * PAGE_SIZE) / EHEA_SECTSIZE;
+	end_section = start_section + ((pgnum * PAGE_SIZE) / EHEA_SECTSIZE);
+
 	for (i = start_section; i < end_section; i++) {
-		int ret;
-		int top, dir, idx;
 		u64 vaddr;
+		int top = ehea_calc_index(i, EHEA_TOP_INDEX_SHIFT);
+		int dir = ehea_calc_index(i, EHEA_DIR_INDEX_SHIFT);
+		int idx = i & EHEA_INDEX_MASK;
+
+		int ret = ehea_init_bmap(ehea_bmap, top, dir);
+		if (ret) {
+			if(add) {
+				return ret;
+			} else {
+				continue;
+			}
+		}
 
-		top = ehea_calc_index(i, EHEA_TOP_INDEX_SHIFT);
-		dir = ehea_calc_index(i, EHEA_DIR_INDEX_SHIFT);
-
-		ret = ehea_init_bmap(ehea_bmap, top, dir);
-		if(ret)
-			return ret;
-
-		idx = i & EHEA_INDEX_MASK;
-		vaddr = EHEA_BUSMAP_START + mr_len + i * EHEA_SECTSIZE;
-
+		if (add) {
+			vaddr = EHEA_BUSMAP_START + ehea_mr_len;
+			ehea_mr_len += EHEA_SECTSIZE;
+		} else { /* remove */
+			vaddr = 0;
+			ehea_mr_len -= EHEA_SECTSIZE;
+		}
 		ehea_bmap->top[top]->dir[dir]->ent[idx] = vaddr;
 	}
-
-	mr_len += nr_pages * PAGE_SIZE;
-	*(unsigned long *)arg = mr_len;
-
 	return 0;
 }
 
-static unsigned long ehea_mr_len;
+int ehea_add_sect_bmap(unsigned long pfn, unsigned long nr_pages)
+{
+	int ret;
+	mutex_lock(&ehea_busmap_mutex);
+	ret = ehea_update_busmap(pfn, nr_pages, EHEA_BUSMAP_ADD_SECT);
+	mutex_unlock(&ehea_busmap_mutex);
+	return ret;
+}
 
-static DEFINE_MUTEX(ehea_busmap_mutex);
+int ehea_rem_sect_bmap(unsigned long pfn, unsigned long nr_pages)
+{
+	int ret;
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
 	mutex_lock(&ehea_busmap_mutex);
 	ehea_mr_len = 0;
-	ret = walk_memory_resource(0, 1ULL << MAX_PHYSMEM_BITS, &ehea_mr_len,
+	ret = walk_memory_resource(0, 1ULL << MAX_PHYSMEM_BITS, NULL,
 				   ehea_create_busmap_callback);
 	mutex_unlock(&ehea_busmap_mutex);
 	return ret;
diff -Nurp -X dontdiff linux-netdev-2.6/drivers/net/ehea/ehea_qmr.h patched_kernel/drivers/net/ehea/ehea_qmr.h
--- linux-netdev-2.6/drivers/net/ehea/ehea_qmr.h	2008-09-17 16:09:25.729017931 +0200
+++ patched_kernel/drivers/net/ehea/ehea_qmr.h	2008-09-17 16:11:26.481026217 +0200
@@ -378,6 +378,8 @@ int ehea_rem_mr(struct ehea_mr *mr);
 
 void ehea_error_data(struct ehea_adapter *adapter, u64 res_handle);
 
+int ehea_add_sect_bmap(unsigned long pfn, unsigned long nr_pages);
+int ehea_rem_sect_bmap(unsigned long pfn, unsigned long nr_pages);
 int ehea_create_busmap(void);
 void ehea_destroy_busmap(void);
 u64 ehea_map_vaddr(void *caddr);
