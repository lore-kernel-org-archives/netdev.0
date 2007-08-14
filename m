From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: [PATCH] IOAT: Fix ioatdma descriptor cache miss
Date: Tue, 14 Aug 2007 14:20:02 -0700
Message-ID: <BAE9DCEF64577A439B3A37F36F9B691C02DBB8B7@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <jgarzik@pobox.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:32608 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751693AbXHNVUE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2007 17:20:04 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
(copying from linux-kernel to net-dev)

The layout for struct ioat_desc_sw is non-optimal and causes an extra
cache hit for every descriptor processed.  By tightening up the struct
layout and removing one item, we pull in the fields that get used in
the speedpath and get a little better performance.


Before:
-------
struct ioat_desc_sw {
	struct ioat_dma_descriptor * hw;                 /*     0     8
*/
	struct list_head           node;                 /*     8    16
*/
	int                        tx_cnt;               /*    24     4
*/

	/* XXX 4 bytes hole, try to pack */

	dma_addr_t                 src;                  /*    32     8
*/
	__u32                      src_len;              /*    40     4
*/

	/* XXX 4 bytes hole, try to pack */

	dma_addr_t                 dst;                  /*    48     8
*/
	__u32                      dst_len;              /*    56     4
*/

	/* XXX 4 bytes hole, try to pack */

	/* --- cacheline 1 boundary (64 bytes) --- */
	struct dma_async_tx_descriptor async_tx;         /*    64   144
*/
	/* --- cacheline 3 boundary (192 bytes) was 16 bytes ago --- */

	/* size: 208, cachelines: 4 */
	/* sum members: 196, holes: 3, sum holes: 12 */
	/* last cacheline: 16 bytes */
};	/* definitions: 1 */


After:
------

struct ioat_desc_sw {
	struct ioat_dma_descriptor * hw;                 /*     0     8
*/
	struct list_head           node;                 /*     8    16
*/
	int                        tx_cnt;               /*    24     4
*/
	__u32                      len;                  /*    28     4
*/
	dma_addr_t                 src;                  /*    32     8
*/
	dma_addr_t                 dst;                  /*    40     8
*/
	struct dma_async_tx_descriptor async_tx;         /*    48   144
*/
	/* --- cacheline 3 boundary (192 bytes) --- */

	/* size: 192, cachelines: 3 */
};	/* definitions: 1 */


Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
---

 drivers/dma/ioatdma.c |    7 +++----
 drivers/dma/ioatdma.h |    3 +--
 2 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/dma/ioatdma.c b/drivers/dma/ioatdma.c
index 5fbe56b..2d1f178 100644
--- a/drivers/dma/ioatdma.c
+++ b/drivers/dma/ioatdma.c
@@ -347,8 +347,7 @@ ioat_dma_prep_memcpy(struct dma_chan *chan, size_t
len, int int_en)
 	new->async_tx.ack = 0; /* client is in control of this ack */
 	new->async_tx.cookie = -EBUSY;
 
-	pci_unmap_len_set(new, src_len, orig_len);
-	pci_unmap_len_set(new, dst_len, orig_len);
+	pci_unmap_len_set(new, len, orig_len);
 	spin_unlock_bh(&ioat_chan->desc_lock);
 
 	return new ? &new->async_tx : NULL;
@@ -423,11 +422,11 @@ static void ioat_dma_memcpy_cleanup(struct
ioat_dma_chan *chan)
 			*/
 			pci_unmap_page(chan->device->pdev,
 					pci_unmap_addr(desc, dst),
-					pci_unmap_len(desc, dst_len),
+					pci_unmap_len(desc, len),
 					PCI_DMA_FROMDEVICE);
 			pci_unmap_page(chan->device->pdev,
 					pci_unmap_addr(desc, src),
-					pci_unmap_len(desc, src_len),
+					pci_unmap_len(desc, len),
 					PCI_DMA_TODEVICE);
 		}
 
diff --git a/drivers/dma/ioatdma.h b/drivers/dma/ioatdma.h
index d372647..bf4dad7 100644
--- a/drivers/dma/ioatdma.h
+++ b/drivers/dma/ioatdma.h
@@ -111,10 +111,9 @@ struct ioat_desc_sw {
 	struct ioat_dma_descriptor *hw;
 	struct list_head node;
 	int tx_cnt;
+	DECLARE_PCI_UNMAP_LEN(len)
 	DECLARE_PCI_UNMAP_ADDR(src)
-	DECLARE_PCI_UNMAP_LEN(src_len)
 	DECLARE_PCI_UNMAP_ADDR(dst)
-	DECLARE_PCI_UNMAP_LEN(dst_len)
 	struct dma_async_tx_descriptor async_tx;
 };
 
