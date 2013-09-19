From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [stable] [PATCH] sfc: Fix efx_rx_buf_offset() for recycled pages
Date: Thu, 19 Sep 2013 15:54:24 +0100
Message-ID: <1379602464.1514.8.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Oe5WGYPagEWwQyuzwPP0"
Cc: stable <stable@kernel.org>, netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:14206 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751984Ab3ISOyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Sep 2013 10:54:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-Oe5WGYPagEWwQyuzwPP0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

This bug fix is only for stable branches older than 3.10.  The bug was
fixed upstream by commit 2768935a4660 ('sfc: reuse pages to avoid DMA
mapping/unmapping costs'), but that change is totally unsuitable for
stable.

Commit b590ace09d51 ('sfc: Fix efx_rx_buf_offset() in the presence of
swiotlb') added an explicit page_offset member to struct
efx_rx_buffer, which must be set consistently with the u.page and
dma_addr fields.  However, it failed to add the necessary assignment
in efx_resurrect_rx_buffer().  It also did not correct the calculation
of efx_rx_buffer::dma_addr in efx_resurrect_rx_buffer(), which assumes
that DMA-mapping a page will result in a page-aligned DMA address
(exactly what swiotlb violates).

Add the assignment of efx_rx_buffer::page_offset and change the
calculation of dma_addr to make use of it.

I'm attaching the patches for 3.0.y, 3.2.y and 3.4.y (the last of which
should also be applicable to the later unofficial stable branches).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--=-Oe5WGYPagEWwQyuzwPP0
Content-Disposition: attachment;
	filename="sfc-Fix-efx_rx_buf_offset-for-recycled-pages-3.0.patch"
Content-Type: text/x-patch;
	name="sfc-Fix-efx_rx_buf_offset-for-recycled-pages-3.0.patch";
	charset="UTF-8"
Content-Transfer-Encoding: 7bit

>From d4e70d42eff6938c12d7d0b12f657b10d06a156d Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 6 Sep 2013 22:39:20 +0100
Subject: sfc: Fix efx_rx_buf_offset() for recycled pages

This bug fix is only for stable branches older than 3.10.  The bug was
fixed upstream by commit 2768935a4660 ('sfc: reuse pages to avoid DMA
mapping/unmapping costs'), but that change is totally unsuitable for
stable.

Commit b590ace09d51 ('sfc: Fix efx_rx_buf_offset() in the presence of
swiotlb') added an explicit page_offset member to struct
efx_rx_buffer, which must be set consistently with the u.page and
dma_addr fields.  However, it failed to add the necessary assignment
in efx_resurrect_rx_buffer().  It also did not correct the calculation
of efx_rx_buffer::dma_addr in efx_resurrect_rx_buffer(), which assumes
that DMA-mapping a page will result in a page-aligned DMA address
(exactly what swiotlb violates).

Add the assignment of efx_rx_buffer::page_offset and change the
calculation of dma_addr to make use of it.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/rx.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index d429f0a..26e4cca 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -311,8 +311,9 @@ static void efx_resurrect_rx_buffer(struct efx_rx_queue *rx_queue,
 
 	index = rx_queue->added_count & rx_queue->ptr_mask;
 	new_buf = efx_rx_buffer(rx_queue, index);
-	new_buf->dma_addr = rx_buf->dma_addr ^ (PAGE_SIZE >> 1);
 	new_buf->u.page = rx_buf->u.page;
+	new_buf->page_offset = rx_buf->page_offset ^ (PAGE_SIZE >> 1);
+	new_buf->dma_addr = state->dma_addr + new_buf->page_offset;
 	new_buf->len = rx_buf->len;
 	new_buf->is_page = true;
 	++rx_queue->added_count;
-- 
1.8.1.4


--=-Oe5WGYPagEWwQyuzwPP0
Content-Disposition: attachment;
	filename="sfc-Fix-efx_rx_buf_offset-for-recycled-pages-3.2.patch"
Content-Type: text/x-patch;
	name="sfc-Fix-efx_rx_buf_offset-for-recycled-pages-3.2.patch";
	charset="UTF-8"
Content-Transfer-Encoding: 7bit

>From 43587737635de32882d9f69df36562e0d5b0e0bd Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 6 Sep 2013 22:39:20 +0100
Subject: sfc: Fix efx_rx_buf_offset() for recycled pages

This bug fix is only for stable branches older than 3.10.  The bug was
fixed upstream by commit 2768935a4660 ('sfc: reuse pages to avoid DMA
mapping/unmapping costs'), but that change is totally unsuitable for
stable.

Commit b590ace09d51 ('sfc: Fix efx_rx_buf_offset() in the presence of
swiotlb') added an explicit page_offset member to struct
efx_rx_buffer, which must be set consistently with the u.page and
dma_addr fields.  However, it failed to add the necessary assignment
in efx_resurrect_rx_buffer().  It also did not correct the calculation
of efx_rx_buffer::dma_addr in efx_resurrect_rx_buffer(), which assumes
that DMA-mapping a page will result in a page-aligned DMA address
(exactly what swiotlb violates).

Add the assignment of efx_rx_buffer::page_offset and change the
calculation of dma_addr to make use of it.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/rx.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 9ce8665..c231b3f 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -312,8 +312,9 @@ static void efx_resurrect_rx_buffer(struct efx_rx_queue *rx_queue,
 
 	index = rx_queue->added_count & rx_queue->ptr_mask;
 	new_buf = efx_rx_buffer(rx_queue, index);
-	new_buf->dma_addr = rx_buf->dma_addr ^ (PAGE_SIZE >> 1);
 	new_buf->u.page = rx_buf->u.page;
+	new_buf->page_offset = rx_buf->page_offset ^ (PAGE_SIZE >> 1);
+	new_buf->dma_addr = state->dma_addr + new_buf->page_offset;
 	new_buf->len = rx_buf->len;
 	new_buf->is_page = true;
 	++rx_queue->added_count;
-- 
1.8.1.4


--=-Oe5WGYPagEWwQyuzwPP0
Content-Disposition: attachment;
	filename="sfc-Fix-efx_rx_buf_offset-for-recycled-pages-3.4.patch"
Content-Type: text/x-patch;
	name="sfc-Fix-efx_rx_buf_offset-for-recycled-pages-3.4.patch";
	charset="UTF-8"
Content-Transfer-Encoding: 7bit

>From 55961f9a914e637f143da275da42154a49c9743a Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 6 Sep 2013 22:39:20 +0100
Subject: sfc: Fix efx_rx_buf_offset() for recycled pages

This bug fix is only for stable branches older than 3.10.  The bug was
fixed upstream by commit 2768935a4660 ('sfc: reuse pages to avoid DMA
mapping/unmapping costs'), but that change is totally unsuitable for
stable.

Commit b590ace09d51 ('sfc: Fix efx_rx_buf_offset() in the presence of
swiotlb') added an explicit page_offset member to struct
efx_rx_buffer, which must be set consistently with the u.page and
dma_addr fields.  However, it failed to add the necessary assignment
in efx_resurrect_rx_buffer().  It also did not correct the calculation
of efx_rx_buffer::dma_addr in efx_resurrect_rx_buffer(), which assumes
that DMA-mapping a page will result in a page-aligned DMA address
(exactly what swiotlb violates).

Add the assignment of efx_rx_buffer::page_offset and change the
calculation of dma_addr to make use of it.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/rx.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 7b3c068..62311ad3 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -311,8 +311,9 @@ static void efx_resurrect_rx_buffer(struct efx_rx_queue *rx_queue,
 
 	index = rx_queue->added_count & rx_queue->ptr_mask;
 	new_buf = efx_rx_buffer(rx_queue, index);
-	new_buf->dma_addr = rx_buf->dma_addr ^ (PAGE_SIZE >> 1);
 	new_buf->u.page = rx_buf->u.page;
+	new_buf->page_offset = rx_buf->page_offset ^ (PAGE_SIZE >> 1);
+	new_buf->dma_addr = state->dma_addr + new_buf->page_offset;
 	new_buf->len = rx_buf->len;
 	new_buf->flags = EFX_RX_BUF_PAGE;
 	++rx_queue->added_count;
-- 
1.8.1.4


--=-Oe5WGYPagEWwQyuzwPP0--
