From: sunil.kovvuri@gmail.com
Subject: [PATCH 4/9] net: thunderx: Cleanup receive buffer allocation
Date: Tue,  2 May 2017 18:36:53 +0530
Message-ID: <1493730418-24606-5-git-send-email-sunil.kovvuri@gmail.com>
References: <1493730418-24606-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1493730418-24606-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

Get rid of unnecessary double pointer references and type casting
in receive buffer allocation code.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index 90c5bc7d..e4a02a9 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -145,7 +145,7 @@ static struct pgcache *nicvf_alloc_page(struct nicvf *nic,
 
 /* Allocate buffer for packet reception */
 static inline int nicvf_alloc_rcv_buffer(struct nicvf *nic, struct rbdr *rbdr,
-					 gfp_t gfp, u32 buf_len, u64 **rbuf)
+					 gfp_t gfp, u32 buf_len, u64 *rbuf)
 {
 	struct pgcache *pgcache = NULL;
 
@@ -172,10 +172,10 @@ static inline int nicvf_alloc_rcv_buffer(struct nicvf *nic, struct rbdr *rbdr,
 		nic->rb_page = pgcache->page;
 ret:
 	/* HW will ensure data coherency, CPU sync not required */
-	*rbuf = (u64 *)((u64)dma_map_page_attrs(&nic->pdev->dev, nic->rb_page,
-						nic->rb_page_offset, buf_len,
-						DMA_FROM_DEVICE,
-						DMA_ATTR_SKIP_CPU_SYNC));
+	*rbuf = (u64)dma_map_page_attrs(&nic->pdev->dev, nic->rb_page,
+					nic->rb_page_offset, buf_len,
+					DMA_FROM_DEVICE,
+					DMA_ATTR_SKIP_CPU_SYNC);
 	if (dma_mapping_error(&nic->pdev->dev, (dma_addr_t)*rbuf)) {
 		if (!nic->rb_page_offset)
 			__free_pages(nic->rb_page, 0);
@@ -212,7 +212,7 @@ static int  nicvf_init_rbdr(struct nicvf *nic, struct rbdr *rbdr,
 			    int ring_len, int buf_size)
 {
 	int idx;
-	u64 *rbuf;
+	u64 rbuf;
 	struct rbdr_entry_t *desc;
 	int err;
 
@@ -257,7 +257,7 @@ static int  nicvf_init_rbdr(struct nicvf *nic, struct rbdr *rbdr,
 		}
 
 		desc = GET_RBDR_DESC(rbdr, idx);
-		desc->buf_addr = (u64)rbuf & ~(NICVF_RCV_BUF_ALIGN_BYTES - 1);
+		desc->buf_addr = rbuf & ~(NICVF_RCV_BUF_ALIGN_BYTES - 1);
 	}
 
 	nicvf_get_page(nic);
@@ -330,7 +330,7 @@ static void nicvf_refill_rbdr(struct nicvf *nic, gfp_t gfp)
 	int refill_rb_cnt;
 	struct rbdr *rbdr;
 	struct rbdr_entry_t *desc;
-	u64 *rbuf;
+	u64 rbuf;
 	int new_rb = 0;
 
 refill:
@@ -364,7 +364,7 @@ static void nicvf_refill_rbdr(struct nicvf *nic, gfp_t gfp)
 			break;
 
 		desc = GET_RBDR_DESC(rbdr, tail);
-		desc->buf_addr = (u64)rbuf & ~(NICVF_RCV_BUF_ALIGN_BYTES - 1);
+		desc->buf_addr = rbuf & ~(NICVF_RCV_BUF_ALIGN_BYTES - 1);
 		refill_rb_cnt--;
 		new_rb++;
 	}
-- 
2.7.4
