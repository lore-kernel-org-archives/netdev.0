From: Joerg Roedel <joerg.roedel@amd.com>
Subject: [PATCH 08/16] dma-debug: add core checking functions
Date: Fri, 9 Jan 2009 17:19:22 +0100
Message-ID: <1231517970-20288-9-git-send-email-joerg.roedel@amd.com>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: mingo@redhat.com, dwmw2@infradead.org,
	fujita.tomonori@lab.ntt.co.jp, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org,
	Joerg Roedel <joerg.roedel@amd.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-va3.frontbridge.com ([216.32.180.16]:37182 "EHLO
	VA3EHSOBE004.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752597AbZAIQTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 11:19:54 -0500
In-Reply-To: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: add functions to check on dma unmap and sync

Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>
---
 lib/dma-debug.c |  133 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 133 insertions(+), 0 deletions(-)

diff --git a/lib/dma-debug.c b/lib/dma-debug.c
index ca0ccb1..9f730a4 100644
--- a/lib/dma-debug.c
+++ b/lib/dma-debug.c
@@ -17,9 +17,11 @@
  * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
  */
 
+#include <linux/dma-mapping.h>
 #include <linux/dma-debug.h>
 #include <linux/spinlock.h>
 #include <linux/debugfs.h>
+#include <linux/device.h>
 #include <linux/types.h>
 #include <linux/list.h>
 #include <linux/slab.h>
@@ -82,6 +84,22 @@ static struct dentry *show_num_errors_dent;
 static struct dentry *num_free_entries_dent;
 static struct dentry *min_free_entries_dent;
 
+static char *type2name[3] = { "single", "scather-gather", "coherent" };
+
+static char *dir2name[4] = { "DMA_BIDIRECTIONAL", "DMA_TO_DEVICE",
+			     "DMA_FROM_DEVICE", "DMA_NONE" };
+
+#define err_printk(dev, format, arg...) do {			\
+		error_count += 1;				\
+		if (show_all_errors || show_num_errors > 0) {	\
+			WARN(1, "%s %s: " format,		\
+			     dev_driver_string(dev),		\
+			     dev_name(dev) , ## arg);		\
+		}						\
+		if (!show_all_errors && show_num_errors > 0)	\
+			show_num_errors -= 1;			\
+	} while (0);
+
 /*
  * Hash related functions
  *
@@ -377,3 +395,118 @@ static __init int dma_debug_entries_cmdline(char *str)
 __setup("dma_debug=", dma_debug_cmdline);
 __setup("dma_debug_entries=", dma_debug_entries_cmdline);
 
+static void check_unmap(struct dma_debug_entry *ref)
+{
+	struct dma_debug_entry *entry;
+	struct hash_bucket *bucket;
+	unsigned long flags;
+
+	if (dma_mapping_error(ref->dev, ref->dev_addr))
+		return;
+
+	bucket = get_hash_bucket(ref, &flags);
+	entry = hash_bucket_find(bucket, ref);
+
+	if (!entry) {
+		err_printk(ref->dev, "DMA-API: device driver tries "
+			   "to free DMA memory it has not allocated "
+			   "[device address=0x%016llx] [size=%llu bytes]\n",
+			   ref->dev_addr, ref->size);
+		goto out;
+	}
+
+	if (ref->size != entry->size) {
+		err_printk(ref->dev, "DMA-API: device driver frees "
+			   "DMA memory with different size "
+			   "[device address=0x%016llx] [map size=%llu bytes] "
+			   "[unmap size=%llu bytes]\n",
+			   ref->dev_addr, entry->size, ref->size);
+	}
+
+	if (ref->type != entry->type) {
+		err_printk(ref->dev, "DMA-API: device driver frees "
+			   "DMA memory different that it was allocated "
+			   "[device address=0x%016llx] [size=%llu bytes] "
+			   "[mapped as %s] [unmapped as %s]\n",
+			   ref->dev_addr, ref->size,
+			   type2name[entry->type], type2name[ref->type]);
+	} else if ((entry->type == dma_debug_coherent) &&
+		   (ref->cpu_addr != entry->cpu_addr)) {
+		err_printk(ref->dev, "DMA-API: device driver frees "
+			   "DMA memory with different CPU address "
+			   "[device address=0x%016llx] [size=%llu bytes] "
+			   "[cpu alloc address=%p] [cpu free address=%p]",
+			   ref->dev_addr, ref->size,
+			   entry->cpu_addr, ref->cpu_addr);
+	}
+
+	/*
+	 *          * This may be no bug in reality - but most implementations of the
+	 *                   * DMA API don't handle this properly, so check for it here
+	 *                            */
+	if (ref->direction != entry->direction) {
+		err_printk(ref->dev, "DMA-API: device driver frees "
+			   "DMA memory with different direction "
+			   "[device address=0x%016llx] [size=%llu bytes] "
+			   "[mapped with %s] [unmapped with %s]\n",
+			   ref->dev_addr, ref->size,
+			   dir2name[entry->direction],
+			   dir2name[ref->direction]);
+	}
+
+	hash_bucket_del(entry);
+	dma_entry_free(entry);
+
+out:
+	put_hash_bucket(bucket, &flags);
+}
+
+static void check_sync(struct device *dev, dma_addr_t addr,
+		       u64 size, u64 offset, int direction, bool to_cpu)
+{
+	struct dma_debug_entry ref = {
+		.dev            = dev,
+		.dev_addr       = addr,
+		.size           = size,
+		.direction      = direction,
+	};
+	struct dma_debug_entry *entry;
+	struct hash_bucket *bucket;
+	unsigned long flags;
+
+	bucket = get_hash_bucket(&ref, &flags);
+
+	entry = hash_bucket_find(bucket, &ref);
+
+	if (!entry) {
+		err_printk(dev, "DMA-API: device driver tries "
+				"to sync DMA memory it has not allocated "
+				"[device address=0x%016llx] [size=%llu bytes]\n",
+				addr, size);
+		goto out;
+	}
+
+	if ((offset + size) > entry->size) {
+		err_printk(dev, "DMA-API: device driver syncs"
+				" DMA memory outside allocated range "
+				"[device address=0x%016llx] "
+				"[allocation size=%llu bytes] [sync offset=%llu] "
+				"[sync size=%llu]\n", entry->dev_addr, entry->size,
+				offset, size);
+	}
+
+	if (direction != entry->direction) {
+		err_printk(dev, "DMA-API: device driver syncs "
+				"DMA memory with different direction "
+				"[device address=0x%016llx] [size=%llu bytes] "
+				"[mapped with %s] [synced with %s]\n",
+				addr, entry->size,
+				dir2name[entry->direction],
+				dir2name[direction]);
+	}
+
+out:
+	put_hash_bucket(bucket, &flags);
+
+}
+
-- 
1.5.6.4


