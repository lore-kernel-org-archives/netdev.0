From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH 0/16] DMA-API debugging facility v2
Date: Thu, 05 Feb 2009 22:52:32 +0000
Message-ID: <1233874352.8135.12.camel@macbook.infradead.org>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com,
	fujita.tomonori@lab.ntt.co.jp, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org
To: Joerg Roedel <joerg.roedel@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:45725 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755983AbZBEWwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2009 17:52:36 -0500
In-Reply-To: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a function to dump the DMA mappings that the debugging code is
aware of -- either for a single device, or for _all_ devices.

This can be useful for debugging -- sticking a call to it in the DMA
page fault handler, for example, to see if the faulting address _should_
be mapped or not, and hence work out whether it's IOMMU bugs we're
seeing, or driver bugs.

I'd also like to make it answer the question 'should address X be mapped
for device Y', but I'll get to that next.

Do we have a %pX format for printing dma_addr_t yet? 

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

diff --git a/include/linux/dma-debug.h b/include/linux/dma-debug.h
index 8a8aae4..5f4fc9f 100644
--- a/include/linux/dma-debug.h
+++ b/include/linux/dma-debug.h
@@ -75,6 +75,8 @@ extern void debug_dma_sync_sg_for_device(struct device *dev,
 					 struct scatterlist *sg,
 					 int nelems, int direction);
 
+extern void debug_dma_dump_mappings(struct device *dev);
+
 #else /* CONFIG_DMA_API_DEBUG */
 
 static inline void dma_debug_init(u32 num_entries)
@@ -155,6 +157,10 @@ static inline void debug_dma_sync_sg_for_device(struct device *dev,
 {
 }
 
+static inline void debug_dma_dump_mappings(struct device *dev)
+{
+}
+
 #endif /* CONFIG_DMA_API_DEBUG */
 
 #endif /* __DMA_DEBUG_H */
diff --git a/lib/dma-debug.c b/lib/dma-debug.c
index 469e5b9..127d108 100644
--- a/lib/dma-debug.c
+++ b/lib/dma-debug.c
@@ -191,6 +191,36 @@ static void hash_bucket_del(struct dma_debug_entry *entry)
 }
 
 /*
+ * Dump mapping entries for debugging purposes
+ */
+void debug_dma_dump_mappings(struct device *dev)
+{
+	int idx;
+
+	for (idx = 0; idx < HASH_SIZE; idx++) {
+		struct hash_bucket *bucket = &dma_entry_hash[idx];
+		struct dma_debug_entry *entry;
+		unsigned long flags;
+
+		spin_lock_irqsave(&bucket->lock, flags);
+
+		list_for_each_entry(entry, &bucket->list, list) {
+			if (!dev || dev == entry->dev) {
+				dev_info(entry->dev,
+					 "%s idx %d P=%Lx D=%Lx L=%Lx %s\n",
+					 type2name[entry->type], idx,
+					 (unsigned long long)entry->paddr,
+					 entry->dev_addr, entry->size,
+					 dir2name[entry->direction]);
+			}
+		}
+
+			spin_unlock_irqrestore(&bucket->lock, flags);
+	}
+}
+EXPORT_SYMBOL(debug_dma_dump_mappings);
+
+/*
  * Wrapper function for adding an entry to the hash.
  * This function takes care of locking itself.
  */


-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

