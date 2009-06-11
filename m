From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 2/3] qlge: Allow RX buf rings to be > than 4096 bytes.
Date: Wed, 10 Jun 2009 18:49:34 -0700
Message-ID: <1244684975-10211-2-git-send-email-ron.mercer@qlogic.com>
References: <1244684975-10211-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:39442 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758946AbZFKB5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 21:57:06 -0400
In-Reply-To: <1244684975-10211-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RX buffer rings can be comprised of non-contiguous fixed
size chunks of memory. The ring is given to the hardware
as a pointer to a location that stores the location of
the queue.  If the queue is greater than 4096 bytes then
the hardware gets a list of said pointers.
This patch addes the necessary logic to generate the list if
the queue size exceeds 4096.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |   13 +++++++++++--
 drivers/net/qlge/qlge_main.c |   28 ++++++++++++++++++++++------
 2 files changed, 33 insertions(+), 8 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index b1ddfd1..156e02e 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -41,7 +41,18 @@
 
 #define NUM_SMALL_BUFFERS   512
 #define NUM_LARGE_BUFFERS   512
+#define DB_PAGE_SIZE 4096
+
+/* Calculate the number of (4k) pages required to
+ * contain a buffer queue of the given length.
+ */
+#define MAX_DB_PAGES_PER_BQ(x) \
+		(((x * sizeof(u64)) / DB_PAGE_SIZE) + \
+		(((x * sizeof(u64)) % DB_PAGE_SIZE) ? 1 : 0))
 
+#define RX_RING_SHADOW_SPACE	(sizeof(u64) + \
+		MAX_DB_PAGES_PER_BQ(NUM_SMALL_BUFFERS) * sizeof(u64) + \
+		MAX_DB_PAGES_PER_BQ(NUM_LARGE_BUFFERS) * sizeof(u64))
 #define SMALL_BUFFER_SIZE 256
 #define LARGE_BUFFER_SIZE	PAGE_SIZE
 #define MAX_SPLIT_SIZE 1023
@@ -65,8 +76,6 @@
 #define TX_DESC_PER_OAL 0
 #endif
 
-#define DB_PAGE_SIZE 4096
-
 /* MPI test register definitions. This register
  * is used for determining alternate NIC function's
  * PCI->func number.
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 17d512c..b9a5f59 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2552,14 +2552,16 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 {
 	struct cqicb *cqicb = &rx_ring->cqicb;
 	void *shadow_reg = qdev->rx_ring_shadow_reg_area +
-	    (rx_ring->cq_id * sizeof(u64) * 4);
+		(rx_ring->cq_id * RX_RING_SHADOW_SPACE);
 	u64 shadow_reg_dma = qdev->rx_ring_shadow_reg_dma +
-	    (rx_ring->cq_id * sizeof(u64) * 4);
+		(rx_ring->cq_id * RX_RING_SHADOW_SPACE);
 	void __iomem *doorbell_area =
 	    qdev->doorbell_area + (DB_PAGE_SIZE * (128 + rx_ring->cq_id));
 	int err = 0;
 	u16 bq_len;
 	u64 tmp;
+	__le64 *base_indirect_ptr;
+	int page_entries;
 
 	/* Set up the shadow registers for this ring. */
 	rx_ring->prod_idx_sh_reg = shadow_reg;
@@ -2568,8 +2570,8 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 	shadow_reg_dma += sizeof(u64);
 	rx_ring->lbq_base_indirect = shadow_reg;
 	rx_ring->lbq_base_indirect_dma = shadow_reg_dma;
-	shadow_reg += sizeof(u64);
-	shadow_reg_dma += sizeof(u64);
+	shadow_reg += (sizeof(u64) * MAX_DB_PAGES_PER_BQ(rx_ring->lbq_len));
+	shadow_reg_dma += (sizeof(u64) * MAX_DB_PAGES_PER_BQ(rx_ring->lbq_len));
 	rx_ring->sbq_base_indirect = shadow_reg;
 	rx_ring->sbq_base_indirect_dma = shadow_reg_dma;
 
@@ -2606,7 +2608,14 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 	if (rx_ring->lbq_len) {
 		cqicb->flags |= FLAGS_LL;	/* Load lbq values */
 		tmp = (u64)rx_ring->lbq_base_dma;;
-		*((__le64 *) rx_ring->lbq_base_indirect) = cpu_to_le64(tmp);
+		base_indirect_ptr = (__le64 *) rx_ring->lbq_base_indirect;
+		page_entries = 0;
+		do {
+			*base_indirect_ptr = cpu_to_le64(tmp);
+			tmp += DB_PAGE_SIZE;
+			base_indirect_ptr++;
+			page_entries++;
+		} while (page_entries < MAX_DB_PAGES_PER_BQ(rx_ring->lbq_len));
 		cqicb->lbq_addr =
 		    cpu_to_le64(rx_ring->lbq_base_indirect_dma);
 		bq_len = (rx_ring->lbq_buf_size == 65536) ? 0 :
@@ -2623,7 +2632,14 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 	if (rx_ring->sbq_len) {
 		cqicb->flags |= FLAGS_LS;	/* Load sbq values */
 		tmp = (u64)rx_ring->sbq_base_dma;;
-		*((__le64 *) rx_ring->sbq_base_indirect) = cpu_to_le64(tmp);
+		base_indirect_ptr = (__le64 *) rx_ring->sbq_base_indirect;
+		page_entries = 0;
+		do {
+			*base_indirect_ptr = cpu_to_le64(tmp);
+			tmp += DB_PAGE_SIZE;
+			base_indirect_ptr++;
+			page_entries++;
+		} while (page_entries < MAX_DB_PAGES_PER_BQ(rx_ring->sbq_len));
 		cqicb->sbq_addr =
 		    cpu_to_le64(rx_ring->sbq_base_indirect_dma);
 		cqicb->sbq_buf_size =
-- 
1.6.0.2

