From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH 51/51] ARM: 7805/1: mm: change max*pfn to
 include the physical offset of memory
Date: Fri, 20 Sep 2013 00:44:07 +0100
Message-ID: <E1VMntH-0002EF-7Z@rmk-PC.arm.linux.org.uk>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Nicolas Pitre <nicolas.pitre@linaro.org>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>
To: alsa-devel@alsa-project.org, b43-dev@lists.infradead.org,
 devel@driverdev.osuosl.org, devicetree@vger.kernel.org,
 dri-devel@lists.freedesktop.org, e1000-devel@lists.sourceforge.net,
 linux-arm-kernel@lists.infradead.org, linux-crypto@vger.kernel.org,
 linux-doc@vger.kernel.org, linux-fbdev@vger.kernel.org,
 linux-ide@vger.kernel.org, linux-media@vger.kernel.org,
 linux-mmc@vger.kernel.org, linux-nvme@lists.infradead.org,
 linux-omap@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org,
 linux-tegra@vger.kernel.org, linux-usb@vger.kernel.org,
 linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
 Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
 uclinux-dist-devel@blackfin.uclinux.org
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <20130919212235.GD12758@n2100.arm.linux.org.uk>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/options/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel/>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Errors-To: alsa-devel-bounces@alsa-project.org
Sender: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

From: Santosh Shilimkar <santosh.shilimkar@ti.com>

Most of the kernel code assumes that max*pfn is maximum pfns because
the physical start of memory is expected to be PFN0. Since this
assumption is not true on ARM architectures, the meaning of max*pfn
is number of memory pages. This is done to keep drivers happy which
are making use of of these variable to calculate the dma bounce limit
using dma_mask.

Now since we have a architecture override possibility for DMAable
maximum pfns, lets make meaning of max*pfns as maximum pnfs on ARM
as well.

Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 arch/arm/include/asm/dma-mapping.h |    8 ++++++++
 arch/arm/mm/init.c                 |   10 ++++------
 2 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
index 5b579b9..863cd84 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -64,6 +64,7 @@ static inline dma_addr_t virt_to_dma(struct device *dev, void *addr)
 {
 	return (dma_addr_t)__virt_to_bus((unsigned long)(addr));
 }
+
 #else
 static inline dma_addr_t pfn_to_dma(struct device *dev, unsigned long pfn)
 {
@@ -86,6 +87,13 @@ static inline dma_addr_t virt_to_dma(struct device *dev, void *addr)
 }
 #endif
 
+/* The ARM override for dma_max_pfn() */
+static inline unsigned long dma_max_pfn(struct device *dev)
+{
+	return PHYS_PFN_OFFSET + dma_to_pfn(dev, *dev->dma_mask);
+}
+#define dma_max_pfn(dev) dma_max_pfn(dev)
+
 /*
  * DMA errors are defined by all-bits-set in the DMA address.
  */
diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 8aab24f..d50533c 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -426,12 +426,10 @@ void __init bootmem_init(void)
 	 * This doesn't seem to be used by the Linux memory manager any
 	 * more, but is used by ll_rw_block.  If we can get rid of it, we
 	 * also get rid of some of the stuff above as well.
-	 *
-	 * Note: max_low_pfn and max_pfn reflect the number of _pages_ in
-	 * the system, not the maximum PFN.
 	 */
-	max_low_pfn = max_low - PHYS_PFN_OFFSET;
-	max_pfn = max_high - PHYS_PFN_OFFSET;
+	min_low_pfn = min;
+	max_low_pfn = max_low;
+	max_pfn = max_high;
 }
 
 /*
@@ -537,7 +535,7 @@ static inline void free_area_high(unsigned long pfn, unsigned long end)
 static void __init free_highpages(void)
 {
 #ifdef CONFIG_HIGHMEM
-	unsigned long max_low = max_low_pfn + PHYS_PFN_OFFSET;
+	unsigned long max_low = max_low_pfn;
 	struct memblock_region *mem, *res;
 
 	/* set highmem page free */
-- 
1.7.4.4
