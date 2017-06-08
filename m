From: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Subject: [PATCH 03/44] dmaengine: ioat: don't use DMA_ERROR_CODE
Date: Thu,  8 Jun 2017 15:25:28 +0200
Message-ID: <20170608132609.32662-4-hch@lst.de>
References: <20170608132609.32662-1-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org,
	linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, openrisc-cunTk1MwBs9a3B2Vnqf2dGD2FQJk+8+b@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, dmaengine-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org,
	linux-samsung-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20170608132609.32662-1-hch-jcswGhMUV9g@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

DMA_ERROR_CODE is not a public API and will go away.  Instead properly
unwind based on the loop counter.

Signed-off-by: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
---
 drivers/dma/ioat/init.c | 24 +++++++-----------------
 1 file changed, 7 insertions(+), 17 deletions(-)

diff --git a/drivers/dma/ioat/init.c b/drivers/dma/ioat/init.c
index 6ad4384b3fa8..ed8ed1192775 100644
--- a/drivers/dma/ioat/init.c
+++ b/drivers/dma/ioat/init.c
@@ -839,8 +839,6 @@ static int ioat_xor_val_self_test(struct ioatdma_device *ioat_dma)
 		goto free_resources;
 	}
 
-	for (i = 0; i < IOAT_NUM_SRC_TEST; i++)
-		dma_srcs[i] = DMA_ERROR_CODE;
 	for (i = 0; i < IOAT_NUM_SRC_TEST; i++) {
 		dma_srcs[i] = dma_map_page(dev, xor_srcs[i], 0, PAGE_SIZE,
 					   DMA_TO_DEVICE);
@@ -910,8 +908,6 @@ static int ioat_xor_val_self_test(struct ioatdma_device *ioat_dma)
 
 	xor_val_result = 1;
 
-	for (i = 0; i < IOAT_NUM_SRC_TEST + 1; i++)
-		dma_srcs[i] = DMA_ERROR_CODE;
 	for (i = 0; i < IOAT_NUM_SRC_TEST + 1; i++) {
 		dma_srcs[i] = dma_map_page(dev, xor_val_srcs[i], 0, PAGE_SIZE,
 					   DMA_TO_DEVICE);
@@ -965,8 +961,6 @@ static int ioat_xor_val_self_test(struct ioatdma_device *ioat_dma)
 	op = IOAT_OP_XOR_VAL;
 
 	xor_val_result = 0;
-	for (i = 0; i < IOAT_NUM_SRC_TEST + 1; i++)
-		dma_srcs[i] = DMA_ERROR_CODE;
 	for (i = 0; i < IOAT_NUM_SRC_TEST + 1; i++) {
 		dma_srcs[i] = dma_map_page(dev, xor_val_srcs[i], 0, PAGE_SIZE,
 					   DMA_TO_DEVICE);
@@ -1017,18 +1011,14 @@ static int ioat_xor_val_self_test(struct ioatdma_device *ioat_dma)
 	goto free_resources;
 dma_unmap:
 	if (op == IOAT_OP_XOR) {
-		if (dest_dma != DMA_ERROR_CODE)
-			dma_unmap_page(dev, dest_dma, PAGE_SIZE,
-				       DMA_FROM_DEVICE);
-		for (i = 0; i < IOAT_NUM_SRC_TEST; i++)
-			if (dma_srcs[i] != DMA_ERROR_CODE)
-				dma_unmap_page(dev, dma_srcs[i], PAGE_SIZE,
-					       DMA_TO_DEVICE);
+		while (--i >= 0)
+			dma_unmap_page(dev, dma_srcs[i], PAGE_SIZE,
+				       DMA_TO_DEVICE);
+		dma_unmap_page(dev, dest_dma, PAGE_SIZE, DMA_FROM_DEVICE);
 	} else if (op == IOAT_OP_XOR_VAL) {
-		for (i = 0; i < IOAT_NUM_SRC_TEST + 1; i++)
-			if (dma_srcs[i] != DMA_ERROR_CODE)
-				dma_unmap_page(dev, dma_srcs[i], PAGE_SIZE,
-					       DMA_TO_DEVICE);
+		while (--i >= 0)
+			dma_unmap_page(dev, dma_srcs[i], PAGE_SIZE,
+				       DMA_TO_DEVICE);
 	}
 free_resources:
 	dma->device_free_chan_resources(dma_chan);
-- 
2.11.0
