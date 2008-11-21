From: Joerg Roedel <joerg.roedel@amd.com>
Subject: [PATCH 04/10] x86: add helper functions for consistency checks
Date: Fri, 21 Nov 2008 17:26:04 +0100
Message-ID: <1227284770-19215-5-git-send-email-joerg.roedel@amd.com>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org,
	Joerg Roedel <joerg.roedel@amd.com>
To: Ingo Molnar <mingo@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-sin.frontbridge.com ([207.46.51.80]:8497 "EHLO
	SG2EHSOBE004.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757289AbYKUQ1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 11:27:46 -0500
In-Reply-To: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: adds helper functions to be used later

Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>
---
 arch/x86/kernel/pci-dma-debug.c |  125 +++++++++++++++++++++++++++++++++++++++
 1 files changed, 125 insertions(+), 0 deletions(-)

diff --git a/arch/x86/kernel/pci-dma-debug.c b/arch/x86/kernel/pci-dma-debug.c
index c2d3408..fc95631 100644
--- a/arch/x86/kernel/pci-dma-debug.c
+++ b/arch/x86/kernel/pci-dma-debug.c
@@ -42,6 +42,11 @@ static struct kmem_cache *dma_entry_cache;
 /* lock to protect the data structures */
 static DEFINE_SPINLOCK(dma_lock);
 
+static char *type2name[3] = { "single", "scather-gather", "coherent" };
+
+static char *dir2name[4] = { "DMA_BIDIRECTIONAL", "DMA_TO_DEVICE",
+			     "DMA_FROM_DEVICE", "DMA_NONE" };
+
 static int hash_fn(struct dma_debug_entry *entry)
 {
 	/*
@@ -95,6 +100,126 @@ static void remove_dma_entry(struct dma_debug_entry *entry)
 	list_del(&entry->list);
 }
 
+static bool check_unmap(struct dma_debug_entry *ref,
+		struct dma_debug_entry *entry)
+{
+	bool errors = false;
+
+	if (!entry) {
+		dev_printk(KERN_ERR, ref->dev, "PCI-DMA: device driver tries "
+			   "to free DMA memory it has not allocated "
+			   "[device address=0x%016llx] [size=%llu bytes]\n",
+			   ref->dev_addr, ref->size);
+		dump_stack();
+
+		return false;
+	}
+
+	if (ref->size != entry->size) {
+		dev_printk(KERN_ERR, ref->dev, "PCI-DMA: device driver frees "
+			   "DMA memory with different size "
+			   "[device address=0x%016llx] [map size=%llu bytes] "
+			   "[unmap size=%llu bytes]\n",
+			   ref->dev_addr, entry->size, ref->size);
+		errors = true;
+	}
+
+	if (ref->type != entry->type) {
+		dev_printk(KERN_ERR, ref->dev, "PCI-DMA: device driver frees "
+			   "DMA memory different that it was allocated "
+			   "[device address=0x%016llx] [size=%llu bytes] "
+			   "[mapped as %s] [unmapped as %s]\n",
+			   ref->dev_addr, ref->size,
+			   type2name[entry->type], type2name[ref->type]);
+		errors = true;
+	} else if ((entry->type == DMA_DEBUG_COHERENT) &&
+		   (ref->cpu_addr != entry->cpu_addr)) {
+		dev_printk(KERN_ERR, ref->dev, "PCI-DMA: device driver frees "
+			   "DMA memory with different CPU address "
+			   "[device address=0x%016llx] [size=%llu bytes] "
+			   "[cpu alloc address=%p] [cpu free address=%p]",
+			   ref->dev_addr, ref->size,
+			   entry->cpu_addr, ref->cpu_addr);
+		errors = true;
+
+	}
+
+	/*
+	 * This may be no bug in reality - but most implementations of the
+	 * DMA API don't handle this properly, so check for it here
+	 */
+	if (ref->direction != entry->direction) {
+		dev_printk(KERN_ERR, ref->dev, "PCI-DMA: device driver frees "
+			   "DMA memory with different direction "
+			   "[device address=0x%016llx] [size=%llu bytes] "
+			   "[mapped with %s] [unmapped with %s]\n",
+			   ref->dev_addr, ref->size,
+			   dir2name[entry->direction],
+			   dir2name[ref->direction]);
+		errors = true;
+	}
+
+	if (errors)
+		dump_stack();
+
+	return true;
+}
+
+static void check_sync(struct device *dev, dma_addr_t addr,
+		u64 size, u64 offset, int direction, bool to_cpu)
+{
+	bool error = false;
+	unsigned long flags;
+	struct dma_debug_entry ref = {
+		.dev = dev,
+		.dev_addr = addr,
+		.size = size,
+		.direction = direction,
+	};
+	struct dma_debug_entry *entry;
+
+	spin_lock_irqsave(&dma_lock, flags);
+
+	entry = find_dma_entry(&ref);
+
+	if (!entry) {
+		dev_printk(KERN_ERR, dev, "PCI-DMA: device driver tries "
+			   "to sync DMA memory it has not allocated "
+			   "[device address=0x%016llx] [size=%llu bytes]\n",
+			   addr, size);
+		error = true;
+		goto out;
+	}
+
+	if ((offset + size) > entry->size) {
+		dev_printk(KERN_ERR, dev, "PCI-DMA: device driver syncs"
+			   " DMA memory outside allocated range "
+			   "[device address=0x%016llx] "
+			   "[allocation size=%llu bytes] [sync offset=%llu] "
+			   "[sync size=%llu]\n", entry->dev_addr, entry->size,
+			   offset, size);
+		error = true;
+	}
+
+	if (direction != entry->direction) {
+		dev_printk(KERN_ERR, dev, "PCI-DMA: device driver syncs "
+			   "DMA memory with different direction "
+			   "[device address=0x%016llx] [size=%llu bytes] "
+			   "[mapped with %s] [synced with %s]\n",
+			   addr, entry->size,
+			   dir2name[entry->direction],
+			   dir2name[direction]);
+		error = true;
+	}
+
+out:
+	spin_unlock_irqrestore(&dma_lock, flags);
+
+	if (error)
+		dump_stack();
+}
+
+
 void dma_debug_init(void)
 {
 	int i;
-- 
1.5.6.4


