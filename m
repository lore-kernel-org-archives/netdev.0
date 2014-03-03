From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCHv2 net-next 01/31] cxgb4: Fix some small bugs in t4_sge_init_soft() when our Page Size is 64KB
Date: Mon,  3 Mar 2014 12:10:45 +0530
Message-ID: <1393828875-13452-2-git-send-email-hariprasad@chelsio.com>
References: <1393828875-13452-1-git-send-email-hariprasad@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1393828875-13452-1-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Kumar Sanghvi <kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>

We'd come in with SGE_FL_BUFFER_SIZE[0] and [1] both equal to 64KB and the
extant logic would flag that as an error.

Based on original work by Casey Leedom <leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>

Signed-off-by: Kumar Sanghvi <kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index af76b25..3a2ecd8 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -2596,11 +2596,19 @@ static int t4_sge_init_soft(struct adapter *adap)
 	fl_small_mtu = READ_FL_BUF(RX_SMALL_MTU_BUF);
 	fl_large_mtu = READ_FL_BUF(RX_LARGE_MTU_BUF);
 
+	/* We only bother using the Large Page logic if the Large Page Buffer
+	 * is larger than our Page Size Buffer.
+	 */
+	if (fl_large_pg <= fl_small_pg)
+		fl_large_pg = 0;
+
 	#undef READ_FL_BUF
 
+	/* The Page Size Buffer must be exactly equal to our Page Size and the
+	 * Large Page Size Buffer should be 0 (per above) or a power of 2.
+	 */
 	if (fl_small_pg != PAGE_SIZE ||
-	    (fl_large_pg != 0 && (fl_large_pg < fl_small_pg ||
-				  (fl_large_pg & (fl_large_pg-1)) != 0))) {
+	    (fl_large_pg & (fl_large_pg-1)) != 0) {
 		dev_err(adap->pdev_dev, "bad SGE FL page buffer sizes [%d, %d]\n",
 			fl_small_pg, fl_large_pg);
 		return -EINVAL;
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
