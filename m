From: sunil.kovvuri@gmail.com
Subject: [PATCH v2 1/2] net: thunderx: Set recevie buffer page usage count in bulk
Date: Mon, 14 Mar 2016 16:36:14 +0530
Message-ID: <1457953578-7054-2-git-send-email-sunil.kovvuri@gmail.com>
References: <1457953578-7054-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	davem@davemloft.net, sgoutham@cavium.com,
	robert.richter@caviumnetworks.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457953578-7054-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

Instead of calling get_page() for every receive buffer carved out
of page, set page's usage count at the end, to reduce no of atomic
calls.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic.h          |    1 +
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c |   31 ++++++++++++++-----
 2 files changed, 24 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic.h b/drivers/net/ethernet/cavium/thunder/nic.h
index 092f097..872b22d 100644
--- a/drivers/net/ethernet/cavium/thunder/nic.h
+++ b/drivers/net/ethernet/cavium/thunder/nic.h
@@ -294,6 +294,7 @@ struct nicvf {
 	u32			speed;
 	struct page		*rb_page;
 	u32			rb_page_offset;
+	u16			rb_pageref;
 	bool			rb_alloc_fail;
 	bool			rb_work_scheduled;
 	struct delayed_work	rbdr_work;
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index 0dd1abf..fa05e34 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -18,6 +18,15 @@
 #include "q_struct.h"
 #include "nicvf_queues.h"
 
+static void nicvf_get_page(struct nicvf *nic)
+{
+	if (!nic->rb_pageref || !nic->rb_page)
+		return;
+
+	atomic_add(nic->rb_pageref, &nic->rb_page->_count);
+	nic->rb_pageref = 0;
+}
+
 /* Poll a register for a specific value */
 static int nicvf_poll_reg(struct nicvf *nic, int qidx,
 			  u64 reg, int bit_pos, int bits, int val)
@@ -81,16 +90,15 @@ static inline int nicvf_alloc_rcv_buffer(struct nicvf *nic, gfp_t gfp,
 	int order = (PAGE_SIZE <= 4096) ?  PAGE_ALLOC_COSTLY_ORDER : 0;
 
 	/* Check if request can be accomodated in previous allocated page */
-	if (nic->rb_page) {
-		if ((nic->rb_page_offset + buf_len + buf_len) >
-		    (PAGE_SIZE << order)) {
-			nic->rb_page = NULL;
-		} else {
-			nic->rb_page_offset += buf_len;
-			get_page(nic->rb_page);
-		}
+	if (nic->rb_page &&
+	    ((nic->rb_page_offset + buf_len) < (PAGE_SIZE << order))) {
+		nic->rb_pageref++;
+		goto ret;
 	}
 
+	nicvf_get_page(nic);
+	nic->rb_page = NULL;
+
 	/* Allocate a new page */
 	if (!nic->rb_page) {
 		nic->rb_page = alloc_pages(gfp | __GFP_COMP | __GFP_NOWARN,
@@ -102,7 +110,9 @@ static inline int nicvf_alloc_rcv_buffer(struct nicvf *nic, gfp_t gfp,
 		nic->rb_page_offset = 0;
 	}
 
+ret:
 	*rbuf = (u64 *)((u64)page_address(nic->rb_page) + nic->rb_page_offset);
+	nic->rb_page_offset += buf_len;
 
 	return 0;
 }
@@ -158,6 +168,9 @@ static int  nicvf_init_rbdr(struct nicvf *nic, struct rbdr *rbdr,
 		desc = GET_RBDR_DESC(rbdr, idx);
 		desc->buf_addr = virt_to_phys(rbuf) >> NICVF_RCV_BUF_ALIGN;
 	}
+
+	nicvf_get_page(nic);
+
 	return 0;
 }
 
@@ -241,6 +254,8 @@ refill:
 		new_rb++;
 	}
 
+	nicvf_get_page(nic);
+
 	/* make sure all memory stores are done before ringing doorbell */
 	smp_wmb();
 
-- 
1.7.1
