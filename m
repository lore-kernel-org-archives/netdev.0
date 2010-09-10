From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 05/10] sfc: Allocate DMA and event rings using
 GFP_KERNEL
Date: Fri, 10 Sep 2010 17:41:26 +0100
Message-ID: <1284136886.2267.99.camel@achroite.uk.solarflarecom.com>
References: <1284136817.2267.93.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:25621 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755809Ab0IJQl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 12:41:29 -0400
In-Reply-To: <1284136817.2267.93.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we allocate DMA descriptor rings and event rings using
pci_alloc_consistent() which selects non-blocking behaviour from the
page allocator (GFP_ATOMIC). This is unnecessary, and since we
currently allocate a single contiguous block for each ring (up to 32
pages!) these allocations are likely to fail if there is any
significant memory pressure.  Use dma_alloc_coherent() and GFP_KERNEL
instead.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/nic.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index f595d92..8efe1ca 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -263,8 +263,8 @@ static int efx_alloc_special_buffer(struct efx_nic *efx,
 {
 	len = ALIGN(len, EFX_BUF_SIZE);
 
-	buffer->addr = pci_alloc_consistent(efx->pci_dev, len,
-					    &buffer->dma_addr);
+	buffer->addr = dma_alloc_coherent(&efx->pci_dev->dev, len,
+					  &buffer->dma_addr, GFP_KERNEL);
 	if (!buffer->addr)
 		return -ENOMEM;
 	buffer->len = len;
@@ -301,8 +301,8 @@ efx_free_special_buffer(struct efx_nic *efx, struct efx_special_buffer *buffer)
 		  (u64)buffer->dma_addr, buffer->len,
 		  buffer->addr, (u64)virt_to_phys(buffer->addr));
 
-	pci_free_consistent(efx->pci_dev, buffer->len, buffer->addr,
-			    buffer->dma_addr);
+	dma_free_coherent(&efx->pci_dev->dev, buffer->len, buffer->addr,
+			  buffer->dma_addr);
 	buffer->addr = NULL;
 	buffer->entries = 0;
 }
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

