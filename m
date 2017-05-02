From: sunil.kovvuri@gmail.com
Subject: [PATCH 2/9] net: thunderx: Optimize RBDR descriptor handling
Date: Tue,  2 May 2017 18:36:51 +0530
Message-ID: <1493730418-24606-3-git-send-email-sunil.kovvuri@gmail.com>
References: <1493730418-24606-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sunil Goutham <sgoutham@cavium.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1493730418-24606-1-git-send-email-sunil.kovvuri@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

Receive buffer's physical address or iova will anyway not
go beyond 49bits, since it is the max supported HW address.
As per perf, updating bitfields i.e buf_addr:42 in RBDR
descriptor entry consumes lots of cpu cycles, hence changed
it to a 64bit field with alignment requirements taken care of.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c |  8 ++++----
 drivers/net/ethernet/cavium/thunder/q_struct.h     | 10 +---------
 2 files changed, 5 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index 12f9709..dfc85a1 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -257,7 +257,7 @@ static int  nicvf_init_rbdr(struct nicvf *nic, struct rbdr *rbdr,
 		}
 
 		desc = GET_RBDR_DESC(rbdr, idx);
-		desc->buf_addr = (u64)rbuf >> NICVF_RCV_BUF_ALIGN;
+		desc->buf_addr = (u64)rbuf & ~(NICVF_RCV_BUF_ALIGN_BYTES - 1);
 	}
 
 	nicvf_get_page(nic);
@@ -286,7 +286,7 @@ static void nicvf_free_rbdr(struct nicvf *nic, struct rbdr *rbdr)
 	/* Release page references */
 	while (head != tail) {
 		desc = GET_RBDR_DESC(rbdr, head);
-		buf_addr = ((u64)desc->buf_addr) << NICVF_RCV_BUF_ALIGN;
+		buf_addr = desc->buf_addr;
 		phys_addr = nicvf_iova_to_phys(nic, buf_addr);
 		dma_unmap_page_attrs(&nic->pdev->dev, buf_addr, RCV_FRAG_LEN,
 				     DMA_FROM_DEVICE, DMA_ATTR_SKIP_CPU_SYNC);
@@ -297,7 +297,7 @@ static void nicvf_free_rbdr(struct nicvf *nic, struct rbdr *rbdr)
 	}
 	/* Release buffer of tail desc */
 	desc = GET_RBDR_DESC(rbdr, tail);
-	buf_addr = ((u64)desc->buf_addr) << NICVF_RCV_BUF_ALIGN;
+	buf_addr = desc->buf_addr;
 	phys_addr = nicvf_iova_to_phys(nic, buf_addr);
 	dma_unmap_page_attrs(&nic->pdev->dev, buf_addr, RCV_FRAG_LEN,
 			     DMA_FROM_DEVICE, DMA_ATTR_SKIP_CPU_SYNC);
@@ -364,7 +364,7 @@ static void nicvf_refill_rbdr(struct nicvf *nic, gfp_t gfp)
 			break;
 
 		desc = GET_RBDR_DESC(rbdr, tail);
-		desc->buf_addr = (u64)rbuf >> NICVF_RCV_BUF_ALIGN;
+		desc->buf_addr = (u64)rbuf & ~(NICVF_RCV_BUF_ALIGN_BYTES - 1);
 		refill_rb_cnt--;
 		new_rb++;
 	}
diff --git a/drivers/net/ethernet/cavium/thunder/q_struct.h b/drivers/net/ethernet/cavium/thunder/q_struct.h
index f363472..e47205a 100644
--- a/drivers/net/ethernet/cavium/thunder/q_struct.h
+++ b/drivers/net/ethernet/cavium/thunder/q_struct.h
@@ -359,15 +359,7 @@ union cq_desc_t {
 };
 
 struct rbdr_entry_t {
-#if defined(__BIG_ENDIAN_BITFIELD)
-	u64   rsvd0:15;
-	u64   buf_addr:42;
-	u64   cache_align:7;
-#elif defined(__LITTLE_ENDIAN_BITFIELD)
-	u64   cache_align:7;
-	u64   buf_addr:42;
-	u64   rsvd0:15;
-#endif
+	u64   buf_addr;
 };
 
 /* TCP reassembly context */
-- 
2.7.4
