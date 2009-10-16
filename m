From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 1/3] qlge: Size RX buffers based on MTU (header changes).
Date: Fri, 16 Oct 2009 13:15:34 -0700
Message-ID: <1255724136-27264-2-git-send-email-ron.mercer@qlogic.com>
References: <1255724136-27264-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:55516 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437AbZJPUVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 16:21:31 -0400
In-Reply-To: <1255724136-27264-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change RX large buffer size based on MTU. If pages are larger
than the MTU the page is divided up into multiple chunks and passed to
the hardware.  When pages are smaller than MTU each RX buffer can
contain be comprised of up to 2 pages.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h |   15 +++++++++++++--
 1 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index fd47691..9cdf8ff 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -56,7 +56,8 @@
 		MAX_DB_PAGES_PER_BQ(NUM_LARGE_BUFFERS) * sizeof(u64))
 #define SMALL_BUFFER_SIZE 512
 #define SMALL_BUF_MAP_SIZE (SMALL_BUFFER_SIZE / 2)
-#define LARGE_BUFFER_SIZE	PAGE_SIZE
+#define LARGE_BUFFER_MAX_SIZE 8192
+#define LARGE_BUFFER_MIN_SIZE 2048
 #define MAX_SPLIT_SIZE 1023
 #define QLGE_SB_PAD 32
 
@@ -1201,9 +1202,17 @@ struct tx_ring_desc {
 	struct tx_ring_desc *next;
 };
 
+struct page_chunk {
+	struct page *page;	/* master page */
+	char *va;		/* virt addr for this chunk */
+	u64 map;		/* mapping for master */
+	unsigned int offset;	/* offset for this chunk */
+	unsigned int last_flag; /* flag set for last chunk in page */
+};
+
 struct bq_desc {
 	union {
-		struct page *lbq_page;
+		struct page_chunk pg_chunk;
 		struct sk_buff *skb;
 	} p;
 	__le64 *addr;
@@ -1272,6 +1281,7 @@ struct rx_ring {
 	dma_addr_t lbq_base_dma;
 	void *lbq_base_indirect;
 	dma_addr_t lbq_base_indirect_dma;
+	struct page_chunk pg_chunk; /* current page for chunks */
 	struct bq_desc *lbq;	/* array of control blocks */
 	void __iomem *lbq_prod_idx_db_reg;	/* PCI doorbell mem area + 0x18 */
 	u32 lbq_prod_idx;	/* current sw prod idx */
@@ -1526,6 +1536,7 @@ struct ql_adapter {
 
 	struct rx_ring rx_ring[MAX_RX_RINGS];
 	struct tx_ring tx_ring[MAX_TX_RINGS];
+	unsigned int lbq_buf_order;
 
 	int rx_csum;
 	u32 default_rx_queue;
-- 
1.6.0.2

