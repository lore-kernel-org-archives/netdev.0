From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] irda: vlsi_ir: fix check for dma mapping errors
Date: Sat, 25 Mar 2017 01:48:08 +0300
Message-ID: <1490395688-3666-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

vlsi_alloc_ring() checks for dma mapping errors by comparison
returned address with zero, while pci_dma_mapping_error() should be used.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/irda/vlsi_ir.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
index ffedad2a360a..15b920086251 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -418,8 +418,9 @@ static struct vlsi_ring *vlsi_alloc_ring(struct pci_dev *pdev, struct ring_descr
 		memset(rd, 0, sizeof(*rd));
 		rd->hw = hwmap + i;
 		rd->buf = kmalloc(len, GFP_KERNEL|GFP_DMA);
-		if (rd->buf == NULL ||
-		    !(busaddr = pci_map_single(pdev, rd->buf, len, dir))) {
+		if (rd->buf)
+			busaddr = pci_map_single(pdev, rd->buf, len, dir);
+		if (rd->buf == NULL || pci_dma_mapping_error(pdev, busaddr)) {
 			if (rd->buf) {
 				net_err_ratelimited("%s: failed to create PCI-MAP for %p\n",
 						    __func__, rd->buf);
@@ -430,8 +431,7 @@ static struct vlsi_ring *vlsi_alloc_ring(struct pci_dev *pdev, struct ring_descr
 				rd = r->rd + j;
 				busaddr = rd_get_addr(rd);
 				rd_set_addr_status(rd, 0, 0);
-				if (busaddr)
-					pci_unmap_single(pdev, busaddr, len, dir);
+				pci_unmap_single(pdev, busaddr, len, dir);
 				kfree(rd->buf);
 				rd->buf = NULL;
 			}
-- 
2.7.4
