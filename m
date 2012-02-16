From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 03/19] sfc: Replace some literal constants with
 EFX_PAGE_SIZE/EFX_BUF_SIZE
Date: Thu, 16 Feb 2012 00:45:11 +0000
Message-ID: <1329353111.2565.29.camel@bwh-desktop>
References: <1329352938.2565.26.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:27533 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753356Ab2BPApO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 19:45:14 -0500
In-Reply-To: <1329352938.2565.26.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 'page size' for PCIe DMA, i.e. the alignment of boundaries at
which DMA must be broken, is 4KB.  Name this value as EFX_PAGE_SIZE
and use it in efx_max_tx_len().  Redefine EFX_BUF_SIZE as
EFX_PAGE_SIZE since its value is also a result of that requirement,
and use it in efx_init_special_buffer().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/nic.c |    5 +----
 drivers/net/ethernet/sfc/nic.h |    5 +++++
 drivers/net/ethernet/sfc/tx.c  |    2 +-
 3 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index a43d1ca..dd50c4f 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -54,9 +54,6 @@
 #define EFX_FLUSH_INTERVAL 10
 #define EFX_FLUSH_POLL_COUNT 100
 
-/* Size and alignment of special buffers (4KB) */
-#define EFX_BUF_SIZE 4096
-
 /* Depth of RX flush request fifo */
 #define EFX_RX_FLUSH_COUNT 4
 
@@ -196,7 +193,7 @@ efx_init_special_buffer(struct efx_nic *efx, struct efx_special_buffer *buffer)
 	/* Write buffer descriptors to NIC */
 	for (i = 0; i < buffer->entries; i++) {
 		index = buffer->index + i;
-		dma_addr = buffer->dma_addr + (i * 4096);
+		dma_addr = buffer->dma_addr + (i * EFX_BUF_SIZE);
 		netif_dbg(efx, probe, efx->net_dev,
 			  "mapping special buffer %d at %llx\n",
 			  index, (unsigned long long)dma_addr);
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 905a187..4f9d18a 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -65,6 +65,11 @@ enum {
 #define FALCON_GMAC_LOOPBACKS			\
 	(1 << LOOPBACK_GMAC)
 
+/* Alignment of PCIe DMA boundaries (4KB) */
+#define EFX_PAGE_SIZE	4096
+/* Size and alignment of buffer table entries (same) */
+#define EFX_BUF_SIZE	EFX_PAGE_SIZE
+
 /**
  * struct falcon_board_type - board operations and type information
  * @id: Board type id, as found in NVRAM
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 5cb81fa..a096e28 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -110,7 +110,7 @@ efx_max_tx_len(struct efx_nic *efx, dma_addr_t dma_addr)
 	 * little benefit from using descriptors that cross those
 	 * boundaries and we keep things simple by not doing so.
 	 */
-	unsigned len = (~dma_addr & 0xfff) + 1;
+	unsigned len = (~dma_addr & (EFX_PAGE_SIZE - 1)) + 1;
 
 	/* Work around hardware bug for unaligned buffers. */
 	if (EFX_WORKAROUND_5391(efx) && (dma_addr & 0xf))
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
