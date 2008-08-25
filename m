From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 1/9] bnx2x: Rx work check
Date: Mon, 25 Aug 2008 17:24:25 +0300
Message-ID: <1219674265.19456.27.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3159 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754219AbYHYOZh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Aug 2008 10:25:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rx work check
The has Rx work check was wrong: when the FW was at the end of the page,
the driver was already at the beginning of the next page. Since the
check only validated that both driver and FW are pointing to the same
place, it concluded that there is still work to be done. This caused
some serious issues including long latency results on ping-pong test and
lockups while unloading the driver in that condition.

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    2 +-
 drivers/net/bnx2x_main.c |    7 +++++++
 2 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index b468f90..a14dba1
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -271,7 +271,7 @@ struct bnx2x_fastpath {
 			 (fp->tx_pkt_prod != fp->tx_pkt_cons))
 
 #define BNX2X_HAS_RX_WORK(fp) \
-			(fp->rx_comp_cons != le16_to_cpu(*fp->rx_cons_sb))
+			(fp->rx_comp_cons != rx_cons_sb)
 
 #define BNX2X_HAS_WORK(fp)	(BNX2X_HAS_RX_WORK(fp) || BNX2X_HAS_TX_WORK(fp))
 
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 971576b..272f5d1
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -9250,6 +9250,7 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
 						 napi);
 	struct bnx2x *bp = fp->bp;
 	int work_done = 0;
+	u16 rx_cons_sb;
 
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
@@ -9265,10 +9266,16 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
 	if (BNX2X_HAS_TX_WORK(fp))
 		bnx2x_tx_int(fp, budget);
 
+	rx_cons_sb = le16_to_cpu(*fp->rx_cons_sb);
+	if ((rx_cons_sb & MAX_RCQ_DESC_CNT) == MAX_RCQ_DESC_CNT)
+		rx_cons_sb++;
 	if (BNX2X_HAS_RX_WORK(fp))
 		work_done = bnx2x_rx_int(fp, budget);
 
 	rmb(); /* BNX2X_HAS_WORK() reads the status block */
+	rx_cons_sb = le16_to_cpu(*fp->rx_cons_sb);
+	if ((rx_cons_sb & MAX_RCQ_DESC_CNT) == MAX_RCQ_DESC_CNT)
+		rx_cons_sb++;
 
 	/* must not complete if we consumed full budget */
 	if ((work_done < budget) && !BNX2X_HAS_WORK(fp)) {
-- 
1.5.3.2




