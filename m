From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net] tg3: Fix RSS ring refill race condition
Date: Wed, 21 Mar 2012 17:38:33 -0800
Message-ID: <1332380314-14198-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4155 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754967Ab2CVBaV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2012 21:30:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The RSS feature in tg3 hardware has only one rx producer ring for all
RSS rings.  NAPI vector 1 is special and handles the refilling of the
rx producer ring on behalf of all RSS rings.  There is a race condition
between these RSS NAPIs and the NAPI[1].  If NAPI[1] finishes checking
for refill and then another RSS ring empties the rx producer ring
before NAPI[1] exits NAPI, the chip will be completely out of SKBs in
the rx producer ring.

We fix this by adding a flag tp->rx_refill and rely on napi_schedule()/
napi_complete() to help synchronize it to close the race condition.

Update driver version to 3.123.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   25 ++++++++++++++++++++++---
 drivers/net/ethernet/broadcom/tg3.h |    1 +
 2 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index b065746..7b71387 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -89,10 +89,10 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
 
 #define DRV_MODULE_NAME		"tg3"
 #define TG3_MAJ_NUM			3
-#define TG3_MIN_NUM			122
+#define TG3_MIN_NUM			123
 #define DRV_MODULE_VERSION	\
 	__stringify(TG3_MAJ_NUM) "." __stringify(TG3_MIN_NUM)
-#define DRV_MODULE_RELDATE	"December 7, 2011"
+#define DRV_MODULE_RELDATE	"March 21, 2012"
 
 #define RESET_KIND_SHUTDOWN	0
 #define RESET_KIND_INIT		1
@@ -5953,8 +5953,10 @@ next_pkt_nopost:
 		tpr->rx_std_prod_idx = std_prod_idx & tp->rx_std_ring_mask;
 		tpr->rx_jmb_prod_idx = jmb_prod_idx & tp->rx_jmb_ring_mask;
 
-		if (tnapi != &tp->napi[1])
+		if (tnapi != &tp->napi[1]) {
+			tp->rx_refill = true;
 			napi_schedule(&tp->napi[1].napi);
+		}
 	}
 
 	return received;
@@ -6134,6 +6136,7 @@ static int tg3_poll_work(struct tg3_napi *tnapi, int work_done, int budget)
 		u32 std_prod_idx = dpr->rx_std_prod_idx;
 		u32 jmb_prod_idx = dpr->rx_jmb_prod_idx;
 
+		tp->rx_refill = false;
 		for (i = 1; i < tp->irq_cnt; i++)
 			err |= tg3_rx_prodring_xfer(tp, dpr,
 						    &tp->napi[i].prodring);
@@ -6197,9 +6200,25 @@ static int tg3_poll_msix(struct napi_struct *napi, int budget)
 		/* check for RX/TX work to do */
 		if (likely(sblk->idx[0].tx_consumer == tnapi->tx_cons &&
 			   *(tnapi->rx_rcb_prod_idx) == tnapi->rx_rcb_ptr)) {
+
+			/* This test here is not race free, but will reduce
+			 * the number of interrupts by looping again.
+			 */
+			if (tnapi == &tp->napi[1] && tp->rx_refill)
+				continue;
+
 			napi_complete(napi);
 			/* Reenable interrupts. */
 			tw32_mailbox(tnapi->int_mbox, tnapi->last_tag << 24);
+
+			/* This test here is synchronized by napi_schedule()
+			 * and napi_complete() to close the race condition.
+			 */
+			if (unlikely(tnapi == &tp->napi[1] && tp->rx_refill)) {
+				tw32(HOSTCC_MODE, tp->coalesce_mode |
+						  HOSTCC_MODE_ENABLE |
+						  tnapi->coal_now);
+			}
 			mmiowb();
 			break;
 		}
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 66bcfca..93865f8 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -3007,6 +3007,7 @@ struct tg3 {
 	u32				rx_std_max_post;
 	u32				rx_offset;
 	u32				rx_pkt_map_sz;
+	bool				rx_refill;
 
 
 	/* begin "everything else" cacheline(s) section */
-- 
1.7.1
