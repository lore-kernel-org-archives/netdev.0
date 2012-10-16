From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH] bnx2x: fix handling mf storage modes
Date: Tue, 16 Oct 2012 13:28:27 +0200
Message-ID: <1350386907-25737-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Ariel Elior" <ariele@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2853 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754069Ab2JPL2L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2012 07:28:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit a3348722 AFEX FCoE function is continuously reset.
The patch prevents the resetting and removes debug print
to stop garbaging syslog.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |   10 +++++++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c  |    2 +-
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 2422099..5164f19 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2957,9 +2957,13 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			skb_shinfo(skb)->nr_frags +
 			BDS_PER_TX_PKT +
 			NEXT_CNT_PER_TX_PKT(MAX_BDS_PER_TX_PKT))) {
-		bnx2x_fp_qstats(bp, txdata->parent_fp)->driver_xoff++;
-		netif_tx_stop_queue(txq);
-		BNX2X_ERR("BUG! Tx ring full when queue awake!\n");
+		/* Handle special storage cases separately */
+		if (txdata->tx_ring_size != 0) {
+			BNX2X_ERR("BUG! Tx ring full when queue awake!\n");
+			bnx2x_fp_qstats(bp, txdata->parent_fp)->driver_xoff++;
+			netif_tx_stop_queue(txq);
+		}
+
 		return NETDEV_TX_BUSY;
 	}
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index 71971a1..614981c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -126,7 +126,7 @@ static inline int bnx2x_exe_queue_add(struct bnx2x *bp,
 		/* Check if this request is ok */
 		rc = o->validate(bp, o->owner, elem);
 		if (rc) {
-			BNX2X_ERR("Preamble failed: %d\n", rc);
+			DP(BNX2X_MSG_SP, "Preamble failed: %d\n", rc);
 			goto free_and_exit;
 		}
 	}
-- 
1.7.7.2
