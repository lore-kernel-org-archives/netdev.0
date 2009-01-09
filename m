From: Joerg Roedel <joerg.roedel@amd.com>
Subject: [PATCH 05/16] dma-debug: add initialization code
Date: Fri, 9 Jan 2009 17:19:19 +0100
Message-ID: <1231517970-20288-6-git-send-email-joerg.roedel@amd.com>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: mingo@redhat.com, dwmw2@infradead.org,
	fujita.tomonori@lab.ntt.co.jp, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org,
	Joerg Roedel <joerg.roedel@amd.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-wa4.frontbridge.com ([216.32.181.16]:32100 "EHLO
	WA4EHSOBE004.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752189AbZAIQTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 11:19:43 -0500
In-Reply-To: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: add code to initialize dma-debug core data structures

Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>
---
 include/linux/dma-debug.h |   14 +++++++++
 lib/dma-debug.c           |   66 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 80 insertions(+), 0 deletions(-)

diff --git a/include/linux/dma-debug.h b/include/linux/dma-debug.h
index ce4ace7..345d538 100644
--- a/include/linux/dma-debug.h
+++ b/include/linux/dma-debug.h
@@ -20,6 +20,20 @@
 #ifndef __DMA_DEBUG_H
 #define __DMA_DEBUG_H
 
+#include <linux/types.h>
+
 struct device;
 
+#ifdef CONFIG_DMA_API_DEBUG
+
+extern void dma_debug_init(u32 num_entries);
+
+#else /* CONFIG_DMA_API_DEBUG */
+
+static inline void dma_debug_init(u32 num_entries)
+{
+}
+
+#endif /* CONFIG_DMA_API_DEBUG */
+
 #endif /* __DMA_DEBUG_H */
diff --git a/lib/dma-debug.c b/lib/dma-debug.c
index c5444d4..b932f15 100644
--- a/lib/dma-debug.c
+++ b/lib/dma-debug.c
@@ -21,6 +21,7 @@
 #include <linux/spinlock.h>
 #include <linux/types.h>
 #include <linux/list.h>
+#include <linux/slab.h>
 
 #define HASH_SIZE       256
 #define HASH_FN_SHIFT   20
@@ -195,3 +196,68 @@ static void dma_entry_free(struct dma_debug_entry *entry)
 	spin_unlock_irqrestore(&free_entries_lock, flags);
 }
 
+/*
+ * DMA-API debugging init code
+ *
+ * The init code does two things:
+ *   1. Initialize core data structures
+ *   2. Preallocate a given number of dma_debug_entry structs
+ */
+
+static int prealloc_memory(u32 num_entries)
+{
+	struct dma_debug_entry *entry, *next_entry;
+	int i;
+
+	for (i = 0; i < num_entries; ++i) {
+		entry = kmalloc(sizeof(*entry), GFP_KERNEL | __GFP_ZERO);
+		if (!entry)
+			goto out_err;
+
+		list_add_tail(&entry->list, &free_entries);
+	}
+
+	num_free_entries = num_entries;
+	min_free_entries = num_entries;
+
+	printk(KERN_INFO "DMA-API: preallocated %d debug entries\n",
+			num_entries);
+
+	return 0;
+
+out_err:
+
+	list_for_each_entry_safe(entry, next_entry, &free_entries, list) {
+		list_del(&entry->list);
+		kfree(entry);
+	}
+
+	return -ENOMEM;
+}
+
+/*
+ * Let the architectures decide how many entries should be preallocated.
+ */
+void dma_debug_init(u32 num_entries)
+{
+	int i;
+
+	if (global_disable)
+		return;
+
+	for (i = 0; i < HASH_SIZE; ++i) {
+		INIT_LIST_HEAD(&dma_entry_hash[i].list);
+		dma_entry_hash[i].lock = SPIN_LOCK_UNLOCKED;
+	}
+
+	if (prealloc_memory(num_entries) != 0) {
+		printk(KERN_ERR "DMA-API: debugging out of memory error "
+				"- disabled\n");
+		global_disable = true;
+
+		return;
+	}
+
+	printk(KERN_INFO "DMA-API: debugging enabled by kernel config\n");
+}
+
-- 
1.5.6.4


