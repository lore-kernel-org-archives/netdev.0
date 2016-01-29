From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v2 2/7] net: davinci_cpdma: use dma_addr_t for DMA address
Date: Fri, 29 Jan 2016 12:39:10 +0100
Message-ID: <1454067557-3546883-3-git-send-email-arnd@arndb.de>
References: <1454067557-3546883-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1454067557-3546883-1-git-send-email-arnd@arndb.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

The davinci_cpdma mixes up physical addresses as seen from the CPU
and DMA addresses as seen from a DMA master, since it can operate
on both normal memory or an on-chip buffer. If dma_addr_t is
different from phys_addr_t, this means we get a compile-time warning
about the type mismatch:

ethernet/ti/davinci_cpdma.c: In function 'cpdma_desc_pool_create':
ethernet/ti/davinci_cpdma.c:182:48: error: passing argument 3 of 'dma_alloc_coherent' from incompatible pointer type [-Werror=incompatible-pointer-types]
   pool->cpumap = dma_alloc_coherent(dev, size, &pool->phys,
In file included from ethernet/ti/davinci_cpdma.c:21:0:
dma-mapping.h:398:21: note: expected 'dma_addr_t * {aka long long unsigned int *}' but argument is of type 'phys_addr_t * {aka unsigned int *}'
 static inline void *dma_alloc_coherent(struct device *dev, size_t size,

This slightly restructures the code so the address we use for
mapping RAM into a DMA address is always a dma_addr_t, avoiding
the warning. The code is correct even if both types are 32-bit
because the DMA master in this device only supports 32-bit addressing
anyway, independent of the types that are used.

We still assign this value to pool->phys, and that is wrong if
the driver is ever used with an IOMMU, but that value appears to
be never used, so there is no problem really. I've added a couple
of comments about where we do things that are slightly violating
the API.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/ti/davinci_cpdma.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 657b65bf5cac..18bf3a8fdc50 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -82,7 +82,7 @@ struct cpdma_desc {
 
 struct cpdma_desc_pool {
 	phys_addr_t		phys;
-	u32			hw_addr;
+	dma_addr_t		hw_addr;
 	void __iomem		*iomap;		/* ioremap map */
 	void			*cpumap;	/* dma_alloc map */
 	int			desc_size, mem_size;
@@ -152,7 +152,7 @@ struct cpdma_chan {
  * abstract out these details
  */
 static struct cpdma_desc_pool *
-cpdma_desc_pool_create(struct device *dev, u32 phys, u32 hw_addr,
+cpdma_desc_pool_create(struct device *dev, u32 phys, dma_addr_t hw_addr,
 				int size, int align)
 {
 	int bitmap_size;
@@ -176,13 +176,13 @@ cpdma_desc_pool_create(struct device *dev, u32 phys, u32 hw_addr,
 
 	if (phys) {
 		pool->phys  = phys;
-		pool->iomap = ioremap(phys, size);
+		pool->iomap = ioremap(phys, size); /* should be memremap? */
 		pool->hw_addr = hw_addr;
 	} else {
-		pool->cpumap = dma_alloc_coherent(dev, size, &pool->phys,
+		pool->cpumap = dma_alloc_coherent(dev, size, &pool->hw_addr,
 						  GFP_KERNEL);
-		pool->iomap = pool->cpumap;
-		pool->hw_addr = pool->phys;
+		pool->iomap = (void __iomem __force *)pool->cpumap;
+		pool->phys = pool->hw_addr; /* assumes no IOMMU, don't use this value */
 	}
 
 	if (pool->iomap)
-- 
2.7.0
