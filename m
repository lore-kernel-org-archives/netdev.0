From: Joerg Roedel <joerg.roedel@amd.com>
Subject: [PATCH 03/16] dma-debug: add hash functions for dma_debug_entries
Date: Fri, 9 Jan 2009 17:19:17 +0100
Message-ID: <1231517970-20288-4-git-send-email-joerg.roedel@amd.com>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: mingo@redhat.com, dwmw2@infradead.org,
	fujita.tomonori@lab.ntt.co.jp, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org,
	Joerg Roedel <joerg.roedel@amd.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-wa4.frontbridge.com ([216.32.181.16]:32121 "EHLO
	WA4EHSOBE006.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752218AbZAIQTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 11:19:43 -0500
In-Reply-To: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: implement necessary functions for the core hash

Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>
---
 lib/dma-debug.c |  101 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 101 insertions(+), 0 deletions(-)

diff --git a/lib/dma-debug.c b/lib/dma-debug.c
index d04f8b6..74a0f36 100644
--- a/lib/dma-debug.c
+++ b/lib/dma-debug.c
@@ -18,9 +18,14 @@
  */
 
 #include <linux/dma-debug.h>
+#include <linux/spinlock.h>
 #include <linux/types.h>
 #include <linux/list.h>
 
+#define HASH_SIZE       256
+#define HASH_FN_SHIFT   20
+#define HASH_FN_MASK    0xffULL
+
 enum {
 	dma_debug_single,
 	dma_debug_sg,
@@ -37,3 +42,99 @@ struct dma_debug_entry {
 	int              direction;
 };
 
+struct hash_bucket {
+	struct list_head list;
+	spinlock_t lock;
+} ____cacheline_aligned;
+
+/* Hash list to save the allocated dma addresses */
+static struct hash_bucket dma_entry_hash[HASH_SIZE];
+
+/*
+ * Hash related functions
+ *
+ * Every DMA-API request is saved into a struct dma_debug_entry. To
+ * have quick access to these structs they are stored into a hash.
+ */
+static int hash_fn(struct dma_debug_entry *entry)
+{
+	/*
+	 * Hash function is based on the dma address.
+	 * We use bits 20-27 here as the index into the hash
+	 */
+	return (entry->dev_addr >> HASH_FN_SHIFT) & HASH_FN_MASK;
+}
+
+/*
+ * Request exclusive access to a hash bucket for a given dma_debug_entry.
+ */
+static struct hash_bucket *get_hash_bucket(struct dma_debug_entry *entry,
+					   unsigned long *flags)
+{
+	int idx = hash_fn(entry);
+	unsigned long __flags;
+
+	spin_lock_irqsave(&dma_entry_hash[idx].lock, __flags);
+	*flags = __flags;
+	return &dma_entry_hash[idx];
+}
+
+/*
+ * Give up exclusive access to the hash bucket
+ */
+static void put_hash_bucket(struct hash_bucket *bucket,
+			    unsigned long *flags)
+{
+	unsigned long __flags = *flags;
+
+	spin_unlock_irqrestore(&bucket->lock, __flags);
+}
+
+/*
+ * Search a given entry in the hash bucket list
+ */
+static struct dma_debug_entry *hash_bucket_find(struct hash_bucket *bucket,
+						struct dma_debug_entry *ref)
+{
+	struct dma_debug_entry *entry;
+
+	list_for_each_entry(entry, &bucket->list, list) {
+		if ((entry->dev_addr == ref->dev_addr) &&
+		    (entry->dev == ref->dev))
+			return entry;
+	}
+
+	return NULL;
+}
+
+/*
+ * Add an entry to a hash bucket
+ */
+static void hash_bucket_add(struct hash_bucket *bucket,
+			    struct dma_debug_entry *entry)
+{
+	list_add_tail(&entry->list, &bucket->list);
+}
+
+/*
+ * Remove entry from a hash bucket list
+ */
+static void hash_bucket_del(struct dma_debug_entry *entry)
+{
+	list_del(&entry->list);
+}
+
+/*
+ * Wrapper function for adding an entry to the hash.
+ * This function takes care of locking itself.
+ */
+static void add_dma_entry(struct dma_debug_entry *entry)
+{
+	struct hash_bucket *bucket;
+	unsigned long flags;
+
+	bucket = get_hash_bucket(entry, &flags);
+	hash_bucket_add(bucket, entry);
+	put_hash_bucket(bucket, &flags);
+}
+
-- 
1.5.6.4


