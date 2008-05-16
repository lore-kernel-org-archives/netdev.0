From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 10/16] sfc: Use DMA_BIT_MASK() instead of our own DMA mask macros
Date: Fri, 16 May 2008 21:18:48 +0100
Message-ID: <20080516201848.GC28241@solarflare.com>
References: <20080516201005.GS28241@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:53554 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757085AbYEPUTY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 16:19:24 -0400
Content-Disposition: inline
In-Reply-To: <20080516201005.GS28241@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also change type of efx_nic_type::max_dma_mask to u64, matching
pci_dma_supported() parameter type.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/bitfield.h   |    3 ---
 drivers/net/sfc/falcon.c     |   13 ++-----------
 drivers/net/sfc/net_driver.h |    2 +-
 3 files changed, 3 insertions(+), 15 deletions(-)

diff --git a/drivers/net/sfc/bitfield.h b/drivers/net/sfc/bitfield.h
index c98a591..2c79d27 100644
--- a/drivers/net/sfc/bitfield.h
+++ b/drivers/net/sfc/bitfield.h
@@ -501,8 +501,5 @@ typedef union efx_oword {
 #define DMA_ADDR_T_WIDTH	(8 * sizeof(dma_addr_t))
 #define EFX_DMA_TYPE_WIDTH(width) \
 	(((width) < DMA_ADDR_T_WIDTH) ? (width) : DMA_ADDR_T_WIDTH)
-#define EFX_DMA_MAX_MASK ((DMA_ADDR_T_WIDTH == 64) ? \
-			  ~((u64) 0) : ~((u32) 0))
-#define EFX_DMA_MASK(mask) ((mask) & EFX_DMA_MAX_MASK)
 
 #endif /* EFX_BITFIELD_H */
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index e02f1d1..475b596 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -116,17 +116,8 @@ MODULE_PARM_DESC(rx_xon_thresh_bytes, "RX fifo XON threshold");
  **************************************************************************
  */
 
-/* DMA address mask (up to 46-bit, avoiding compiler warnings)
- *
- * Note that it is possible to have a platform with 64-bit longs and
- * 32-bit DMA addresses, or vice versa.  EFX_DMA_MASK takes care of the
- * platform DMA mask.
- */
-#if BITS_PER_LONG == 64
-#define FALCON_DMA_MASK EFX_DMA_MASK(0x00003fffffffffffUL)
-#else
-#define FALCON_DMA_MASK EFX_DMA_MASK(0x00003fffffffffffULL)
-#endif
+/* DMA address mask */
+#define FALCON_DMA_MASK DMA_BIT_MASK(46)
 
 /* TX DMA length mask (13-bit) */
 #define FALCON_TX_DMA_MASK (4096 - 1)
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index a84f975..77418ae 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -800,7 +800,7 @@ struct efx_nic_type {
 	unsigned int txd_ring_mask;
 	unsigned int rxd_ring_mask;
 	unsigned int evq_size;
-	dma_addr_t max_dma_mask;
+	u64 max_dma_mask;
 	unsigned int tx_dma_mask;
 	unsigned bug5391_mask;
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
