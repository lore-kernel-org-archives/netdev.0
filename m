From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH 46/51] ARM: DMA-API: better handing of DMA
 masks for coherent allocations
Date: Fri, 20 Sep 2013 00:39:06 +0100
Message-ID: <E1VMnoQ-0000QN-2l@rmk-PC.arm.linux.org.uk>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
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

We need to start treating DMA masks as something which is specific to
the bus that the device resides on, otherwise we're going to hit all
sorts of nasty issues with LPAE and 32-bit DMA controllers in >32-bit
systems, where memory is offset from PFN 0.

In order to start doing this, we convert the DMA mask to a PFN using
the device specific dma_to_pfn() macro.  This is the reverse of the
pfn_to_dma() macro which is used to get the DMA address for the device.

This gives us a PFN mask, which we can then check against the PFN
limit of the DMA zone.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 arch/arm/mm/dma-mapping.c |   49 ++++++++++++++++++++++++++++++++++++++++----
 arch/arm/mm/init.c        |    2 +
 arch/arm/mm/mm.h          |    2 +
 3 files changed, 48 insertions(+), 5 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index f5e1a84..13d55e1 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -173,10 +173,30 @@ static u64 get_coherent_dma_mask(struct device *dev)
 			return 0;
 		}
 
-		if ((~mask) & (u64)arm_dma_limit) {
-			dev_warn(dev, "coherent DMA mask %#llx is smaller "
-				 "than system GFP_DMA mask %#llx\n",
-				 mask, (u64)arm_dma_limit);
+		/*
+		 * If the mask allows for more memory than we can address,
+		 * and we actually have that much memory, then fail the
+		 * allocation.
+		 */
+		if (sizeof(mask) != sizeof(dma_addr_t) &&
+		    mask > (dma_addr_t)~0 &&
+		    dma_to_pfn(dev, ~0) > arm_dma_pfn_limit) {
+			dev_warn(dev, "Coherent DMA mask %#llx is larger than dma_addr_t allows\n",
+				 mask);
+			dev_warn(dev, "Driver did not use or check the return value from dma_set_coherent_mask()?\n");
+			return 0;
+		}
+
+		/*
+		 * Now check that the mask, when translated to a PFN,
+		 * fits within the allowable addresses which we can
+		 * allocate.
+		 */
+		if (dma_to_pfn(dev, mask) < arm_dma_pfn_limit) {
+			dev_warn(dev, "Coherent DMA mask %#llx (pfn %#lx-%#lx) covers a smaller range of system memory than the DMA zone pfn 0x0-%#lx\n",
+				 mask,
+				 dma_to_pfn(dev, 0), dma_to_pfn(dev, mask) + 1,
+				 arm_dma_pfn_limit + 1);
 			return 0;
 		}
 	}
@@ -1007,8 +1027,27 @@ void arm_dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
  */
 int dma_supported(struct device *dev, u64 mask)
 {
-	if (mask < (u64)arm_dma_limit)
+	unsigned long limit;
+
+	/*
+	 * If the mask allows for more memory than we can address,
+	 * and we actually have that much memory, then we must
+	 * indicate that DMA to this device is not supported.
+	 */
+	if (sizeof(mask) != sizeof(dma_addr_t) &&
+	    mask > (dma_addr_t)~0 &&
+	    dma_to_pfn(dev, ~0) > arm_dma_pfn_limit)
+		return 0;
+
+	/*
+	 * Translate the device's DMA mask to a PFN limit.  This
+	 * PFN number includes the page which we can DMA to.
+	 */
+	limit = dma_to_pfn(dev, mask);
+
+	if (limit < arm_dma_pfn_limit)
 		return 0;
+
 	return 1;
 }
 EXPORT_SYMBOL(dma_supported);
diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index febaee7..8aab24f 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -218,6 +218,7 @@ EXPORT_SYMBOL(arm_dma_zone_size);
  * so a successful GFP_DMA allocation will always satisfy this.
  */
 phys_addr_t arm_dma_limit;
+unsigned long arm_dma_pfn_limit;
 
 static void __init arm_adjust_dma_zone(unsigned long *size, unsigned long *hole,
 	unsigned long dma_size)
@@ -240,6 +241,7 @@ void __init setup_dma_zone(const struct machine_desc *mdesc)
 		arm_dma_limit = PHYS_OFFSET + arm_dma_zone_size - 1;
 	} else
 		arm_dma_limit = 0xffffffff;
+	arm_dma_pfn_limit = arm_dma_limit >> PAGE_SHIFT;
 #endif
 }
 
diff --git a/arch/arm/mm/mm.h b/arch/arm/mm/mm.h
index d5a4e9a..d5a982d 100644
--- a/arch/arm/mm/mm.h
+++ b/arch/arm/mm/mm.h
@@ -81,8 +81,10 @@ extern __init void add_static_vm_early(struct static_vm *svm);
 
 #ifdef CONFIG_ZONE_DMA
 extern phys_addr_t arm_dma_limit;
+extern unsigned long arm_dma_pfn_limit;
 #else
 #define arm_dma_limit ((phys_addr_t)~0)
+#define arm_dma_pfn_limit (~0ul >> PAGE_SHIFT)
 #endif
 
 extern phys_addr_t arm_lowmem_limit;
-- 
1.7.4.4
