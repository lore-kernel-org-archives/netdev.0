From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: [PATCH] ARM: dmabounce: fix partial sync in dma_sync_single_* API
Date: Tue, 13 Apr 2010 14:27:04 +0900
Message-ID: <20100413142607V.fujita.tomonori@lab.ntt.co.jp>
References: <20100405123847C.fujita.tomonori@lab.ntt.co.jp>
	<20100412193536.GO3048@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: fujita.tomonori@lab.ntt.co.jp, netdev@vger.kernel.org, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: linux@arm.linux.org.uk
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20100412193536.GO3048@n2100.arm.linux.org.uk>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Mon, 12 Apr 2010 20:35:36 +0100
Russell King - ARM Linux <linux@arm.linux.org.uk> wrote:

> On Mon, Apr 05, 2010 at 12:39:32PM +0900, FUJITA Tomonori wrote:
> > I don't have arm hardware that uses dmabounce so I can't confirm the
> > problem but seems that dmabounce doesn't work for some drivers...
> 
> Patch reviews fine, except for one niggle.  I too don't have hardware
> I can test (well, I do except the kernel stopped supporting the UDA1341
> audio codec on the SA1110 Neponset.)

Thanks for reviewing.

> > @@ -171,10 +172,17 @@ find_safe_buffer(struct dmabounce_device_info *device_info, dma_addr_t safe_dma_
> >  	read_lock_irqsave(&device_info->lock, flags);
> >  
> >  	list_for_each_entry(b, &device_info->safe_buffers, node)
> > -		if (b->safe_dma_addr == safe_dma_addr) {
> > -			rb = b;
> > -			break;
> > -		}
> > +		if (for_sync) {
> > +			if (b->safe_dma_addr <= safe_dma_addr &&
> > +			    safe_dma_addr < b->safe_dma_addr + b->size) {
> > +				rb = b;
> > +				break;
> > +			}
> > +		} else
> > +			if (b->safe_dma_addr == safe_dma_addr) {
> > +				rb = b;
> > +				break;
> > +			}
> 
> This is the niggle; I don't like this indentation style.  If you want to
> indent this if () statement, then please format like this:
> 
> 		} else {
> 			if (b->safe...) {
> 				...
> 			}
> 		}
> 
> or format it as:
> 
> 		} else if (b->safe...) {
> 			...
> 		}

ok, here's the fixed patch.

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
 arch/arm/common/dmabounce.c |   30 +++++++++++++++++++++---------
 1 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/arch/arm/common/dmabounce.c b/arch/arm/common/dmabounce.c
index cc0a932..2e6deec 100644
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
@@ -171,9 +172,17 @@ find_safe_buffer(struct dmabounce_device_info *device_info, dma_addr_t safe_dma_
 	read_lock_irqsave(&device_info->lock, flags);
 
 	list_for_each_entry(b, &device_info->safe_buffers, node)
-		if (b->safe_dma_addr == safe_dma_addr) {
-			rb = b;
-			break;
+		if (for_sync) {
+			if (b->safe_dma_addr <= safe_dma_addr &&
+			    safe_dma_addr < b->safe_dma_addr + b->size) {
+				rb = b;
+				break;
+			}
+		} else {
+			if (b->safe_dma_addr == safe_dma_addr) {
+				rb = b;
+				break;
+			}
 		}
 
 	read_unlock_irqrestore(&device_info->lock, flags);
@@ -205,7 +214,8 @@ free_safe_buffer(struct dmabounce_device_info *device_info, struct safe_buffer *
 /* ************************************************** */
 
 static struct safe_buffer *find_safe_buffer_dev(struct device *dev,
-		dma_addr_t dma_addr, const char *where)
+						dma_addr_t dma_addr, const char *where,
+						int for_sync)
 {
 	if (!dev || !dev->archdata.dmabounce)
 		return NULL;
@@ -216,7 +226,7 @@ static struct safe_buffer *find_safe_buffer_dev(struct device *dev,
 			pr_err("unknown device: Trying to %s invalid mapping\n", where);
 		return NULL;
 	}
-	return find_safe_buffer(dev->archdata.dmabounce, dma_addr);
+	return find_safe_buffer(dev->archdata.dmabounce, dma_addr, for_sync);
 }
 
 static inline dma_addr_t map_single(struct device *dev, void *ptr, size_t size,
@@ -286,7 +296,7 @@ static inline dma_addr_t map_single(struct device *dev, void *ptr, size_t size,
 static inline void unmap_single(struct device *dev, dma_addr_t dma_addr,
 		size_t size, enum dma_data_direction dir)
 {
-	struct safe_buffer *buf = find_safe_buffer_dev(dev, dma_addr, "unmap");
+	struct safe_buffer *buf = find_safe_buffer_dev(dev, dma_addr, "unmap", 0);
 
 	if (buf) {
 		BUG_ON(buf->size != size);
@@ -398,7 +408,7 @@ int dmabounce_sync_for_cpu(struct device *dev, dma_addr_t addr,
 	dev_dbg(dev, "%s(dma=%#x,off=%#lx,sz=%zx,dir=%x)\n",
 		__func__, addr, off, sz, dir);
 
-	buf = find_safe_buffer_dev(dev, addr, __func__);
+	buf = find_safe_buffer_dev(dev, addr, __func__, 1);
 	if (!buf)
 		return 1;
 
@@ -411,6 +421,8 @@ int dmabounce_sync_for_cpu(struct device *dev, dma_addr_t addr,
 	DO_STATS(dev->archdata.dmabounce->bounce_count++);
 
 	if (dir == DMA_FROM_DEVICE || dir == DMA_BIDIRECTIONAL) {
+		if (addr != buf->safe_dma_addr)
+			off = addr - buf->safe_dma_addr;
 		dev_dbg(dev, "%s: copy back safe %p to unsafe %p size %d\n",
 			__func__, buf->safe + off, buf->ptr + off, sz);
 		memcpy(buf->ptr + off, buf->safe + off, sz);
@@ -427,7 +439,7 @@ int dmabounce_sync_for_device(struct device *dev, dma_addr_t addr,
 	dev_dbg(dev, "%s(dma=%#x,off=%#lx,sz=%zx,dir=%x)\n",
 		__func__, addr, off, sz, dir);
 
-	buf = find_safe_buffer_dev(dev, addr, __func__);
+	buf = find_safe_buffer_dev(dev, addr, __func__, 1);
 	if (!buf)
 		return 1;
 
-- 
1.6.5
