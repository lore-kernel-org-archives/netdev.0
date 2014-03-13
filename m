From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 1/5] cxgb4: Fix some small bugs in t4_sge_init_soft() when our Page Size is 64KB
Date: Thu, 13 Mar 2014 20:50:46 +0530
Message-ID: <1394724050-9291-2-git-send-email-hariprasad@chelsio.com>
References: <1394724050-9291-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, dm@chelsio.com, swise@opengridcomputing.com,
	leedom@chelsio.com, santosh@chelsio.com, kumaras@chelsio.com,
	nirranjan@chelsio.com, hariprasad@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:5818 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753730AbaCMP3P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 11:29:15 -0400
In-Reply-To: <1394724050-9291-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumaras@chelsio.com>

We'd come in with SGE_FL_BUFFER_SIZE[0] and [1] both equal to 64KB and the
extant logic would flag that as an error.

Based on original work by Casey Leedom <leedom@chelsio.com>

Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

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
1.8.4
