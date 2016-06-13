From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 3/3] infiniband: rxe: fix 32-bit build warnings
Date: Mon, 13 Jun 2016 14:54:55 +0200
Message-ID: <1465822509-4167617-3-git-send-email-arnd@arndb.de>
References: <1465822509-4167617-1-git-send-email-arnd@arndb.de>
Cc: netdev@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
	Moni Shoua <monis@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	Kamal Heib <kamalh@mellanox.com>,
	Haggai Eran <haggaie@mellanox.com>, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.74]:65161 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422747AbcFMMyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 08:54:33 -0400
In-Reply-To: <1465822509-4167617-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new rxe infinband driver passes around pointers that have been
converted to 64-bit integers. This is valid, but causes compile-time
warnings on all 32-bit architectures:

infiniband/hw/rxe/rxe_dma.c: In function 'rxe_dma_map_single':
infiniband/hw/rxe/rxe_dma.c:49:9: error: cast from pointer to integer of different size [-Werror=pointer-to-int-cast]
  return (u64)cpu_addr;
         ^
infiniband/hw/rxe/rxe_dma.c: In function 'rxe_dma_map_page':
infiniband/hw/rxe/rxe_dma.c:73:9: error: cast from pointer to integer of different size [-Werror=pointer-to-int-cast]
infiniband/hw/rxe/rxe_dma.c: In function 'rxe_map_sg':
infiniband/hw/rxe/rxe_dma.c:99:10: error: cast from pointer to integer of different size [-Werror=pointer-to-int-cast]
infiniband/hw/rxe/rxe_dma.c: In function 'rxe_dma_alloc_coherent':
infiniband/hw/rxe/rxe_dma.c:143:17: error: cast from pointer to integer of different size [-Werror=pointer-to-int-cast]

This changes the cast to use 'uintptr_t', which can always be
cast to and from pointer, and can be assigned to and from 64-bit
integers.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/infiniband/hw/rxe/rxe_dma.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/hw/rxe/rxe_dma.c b/drivers/infiniband/hw/rxe/rxe_dma.c
index f080bc5bda43..7634c1a81b2b 100644
--- a/drivers/infiniband/hw/rxe/rxe_dma.c
+++ b/drivers/infiniband/hw/rxe/rxe_dma.c
@@ -46,7 +46,7 @@ static u64 rxe_dma_map_single(struct ib_device *dev,
 			      enum dma_data_direction direction)
 {
 	WARN_ON(!valid_dma_direction(direction));
-	return (u64)cpu_addr;
+	return (uintptr_t)cpu_addr;
 }
 
 static void rxe_dma_unmap_single(struct ib_device *dev,
@@ -70,7 +70,7 @@ static u64 rxe_dma_map_page(struct ib_device *dev,
 		goto done;
 	}
 
-	addr = (u64)page_address(page);
+	addr = (uintptr_t)page_address(page);
 	if (addr)
 		addr += offset;
 
@@ -96,7 +96,7 @@ static int rxe_map_sg(struct ib_device *dev, struct scatterlist *sgl,
 	WARN_ON(!valid_dma_direction(direction));
 
 	for_each_sg(sgl, sg, nents, i) {
-		addr = (u64)page_address(sg_page(sg));
+		addr = (uintptr_t)page_address(sg_page(sg));
 		if (!addr) {
 			ret = 0;
 			break;
@@ -140,7 +140,7 @@ static void *rxe_dma_alloc_coherent(struct ib_device *dev, size_t size,
 		addr = page_address(p);
 
 	if (dma_handle)
-		*dma_handle = (u64)addr;
+		*dma_handle = (uintptr_t)addr;
 
 	return addr;
 }
-- 
2.7.0
