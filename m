From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH] ARM: dmabounce: fix partial sync in dma_sync_single_* API
Date: Mon, 5 Apr 2010 12:39:32 +0900
Message-ID: <20100405123847C.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org
To: linux@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:36110 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753889Ab0DEDjx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Apr 2010 23:39:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I don't have arm hardware that uses dmabounce so I can't confirm the
problem but seems that dmabounce doesn't work for some drivers...

=
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH] ARM: dmabounce: fix partial sync in dma_sync_single_* API

Some network drivers do a partial sync with
dma_sync_single_for_{device|cpu}. The dma_addr argument might not be
the same as one as passed into the mapping API.

This adds some tricks to find_safe_buffer() for
dma_sync_single_for_{device|cpu}.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 arch/arm/common/dmabounce.c |   31 +++++++++++++++++++++----------
 1 files changed, 21 insertions(+), 10 deletions(-)

diff --git a/arch/arm/common/dmabounce.c b/arch/arm/common/dmabounce.c
index cc0a932..87eb160 100644
--- a/arch/arm/common/dmabounce.c
+++ b/arch/arm/common/dmabounce.c
@@ -163,7 +163,8 @@ alloc_safe_buffer(struct dmabounce_device_info *device_info, void *ptr,
 
 /* determine if a buffer is from our "safe" pool */
 static inline struct safe_buffer *
-find_safe_buffer(struct dmabounce_device_info *device_info, dma_addr_t safe_dma_addr)
+find_safe_buffer(struct dmabounce_device_info *device_info, dma_addr_t safe_dma_addr,
+		 int for_sync)
 {
 	struct safe_buffer *b, *rb = NULL;
 	unsigned long flags;
@@ -171,10 +172,17 @@ find_safe_buffer(struct dmabounce_device_info *device_info, dma_addr_t safe_dma_
 	read_lock_irqsave(&device_info->lock, flags);
 
 	list_for_each_entry(b, &device_info->safe_buffers, node)
-		if (b->safe_dma_addr == safe_dma_addr) {
-			rb = b;
-			break;
-		}
+		if (for_sync) {
+			if (b->safe_dma_addr <= safe_dma_addr &&
+			    safe_dma_addr < b->safe_dma_addr + b->size) {
+				rb = b;
+				break;
+			}
+		} else
+			if (b->safe_dma_addr == safe_dma_addr) {
+				rb = b;
+				break;
+			}
 
 	read_unlock_irqrestore(&device_info->lock, flags);
 	return rb;
@@ -205,7 +213,8 @@ free_safe_buffer(struct dmabounce_device_info *device_info, struct safe_buffer *
 /* ************************************************** */
 
 static struct safe_buffer *find_safe_buffer_dev(struct device *dev,
-		dma_addr_t dma_addr, const char *where)
+						dma_addr_t dma_addr, const char *where,
+						int for_sync)
 {
 	if (!dev || !dev->archdata.dmabounce)
 		return NULL;
@@ -216,7 +225,7 @@ static struct safe_buffer *find_safe_buffer_dev(struct device *dev,
 			pr_err("unknown device: Trying to %s invalid mapping\n", where);
 		return NULL;
 	}
-	return find_safe_buffer(dev->archdata.dmabounce, dma_addr);
+	return find_safe_buffer(dev->archdata.dmabounce, dma_addr, for_sync);
 }
 
 static inline dma_addr_t map_single(struct device *dev, void *ptr, size_t size,
@@ -286,7 +295,7 @@ static inline dma_addr_t map_single(struct device *dev, void *ptr, size_t size,
 static inline void unmap_single(struct device *dev, dma_addr_t dma_addr,
 		size_t size, enum dma_data_direction dir)
 {
-	struct safe_buffer *buf = find_safe_buffer_dev(dev, dma_addr, "unmap");
+	struct safe_buffer *buf = find_safe_buffer_dev(dev, dma_addr, "unmap", 0);
 
 	if (buf) {
 		BUG_ON(buf->size != size);
@@ -398,7 +407,7 @@ int dmabounce_sync_for_cpu(struct device *dev, dma_addr_t addr,
 	dev_dbg(dev, "%s(dma=%#x,off=%#lx,sz=%zx,dir=%x)\n",
 		__func__, addr, off, sz, dir);
 
-	buf = find_safe_buffer_dev(dev, addr, __func__);
+	buf = find_safe_buffer_dev(dev, addr, __func__, 1);
 	if (!buf)
 		return 1;
 
@@ -411,6 +420,8 @@ int dmabounce_sync_for_cpu(struct device *dev, dma_addr_t addr,
 	DO_STATS(dev->archdata.dmabounce->bounce_count++);
 
 	if (dir == DMA_FROM_DEVICE || dir == DMA_BIDIRECTIONAL) {
+		if (addr != buf->safe_dma_addr)
+			off = addr - buf->safe_dma_addr;
 		dev_dbg(dev, "%s: copy back safe %p to unsafe %p size %d\n",
 			__func__, buf->safe + off, buf->ptr + off, sz);
 		memcpy(buf->ptr + off, buf->safe + off, sz);
@@ -427,7 +438,7 @@ int dmabounce_sync_for_device(struct device *dev, dma_addr_t addr,
 	dev_dbg(dev, "%s(dma=%#x,off=%#lx,sz=%zx,dir=%x)\n",
 		__func__, addr, off, sz, dir);
 
-	buf = find_safe_buffer_dev(dev, addr, __func__);
+	buf = find_safe_buffer_dev(dev, addr, __func__, 1);
 	if (!buf)
 		return 1;
 
-- 
1.7.0

