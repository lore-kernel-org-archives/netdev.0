From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net] tg3: Avoid panic from reserved statblk field access
Date: Tue, 24 Apr 2012 16:37:01 -0700
Message-ID: <1335310621-7795-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2206 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758098Ab2DXXhq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2012 19:37:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When RSS is enabled, interrupt vector 0 does not receive any rx traffic.
The rx producer index fields for vector 0's status block should be
considered reserved in this case.  This patch changes the code to
respect these reserved fields, which avoids a kernel panic when these
fields take on non-zero values.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   18 ++++++++++++++++--
 1 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 062ac33..ceeab8e 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -879,8 +879,13 @@ static inline unsigned int tg3_has_work(struct tg3_napi *tnapi)
 		if (sblk->status & SD_STATUS_LINK_CHG)
 			work_exists = 1;
 	}
-	/* check for RX/TX work to do */
-	if (sblk->idx[0].tx_consumer != tnapi->tx_cons ||
+
+	/* check for TX work to do */
+	if (sblk->idx[0].tx_consumer != tnapi->tx_cons)
+		work_exists = 1;
+
+	/* check for RX work to do */
+	if (tnapi->rx_rcb_prod_idx &&
 	    *(tnapi->rx_rcb_prod_idx) != tnapi->rx_rcb_ptr)
 		work_exists = 1;
 
@@ -6124,6 +6129,9 @@ static int tg3_poll_work(struct tg3_napi *tnapi, int work_done, int budget)
 			return work_done;
 	}
 
+	if (!tnapi->rx_rcb_prod_idx)
+		return work_done;
+
 	/* run RX thread, within the bounds set by NAPI.
 	 * All RX "locking" is done by ensuring outside
 	 * code synchronizes with tg3->napi.poll()
@@ -7567,6 +7575,12 @@ static int tg3_alloc_consistent(struct tg3 *tp)
 		 */
 		switch (i) {
 		default:
+			if (tg3_flag(tp, ENABLE_RSS)) {
+				tnapi->rx_rcb_prod_idx = NULL;
+				break;
+			}
+			/* Fall through */
+		case 1:
 			tnapi->rx_rcb_prod_idx = &sblk->idx[0].rx_producer;
 			break;
 		case 2:
-- 
1.7.3.4
