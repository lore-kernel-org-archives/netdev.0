From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/2]: niu: Add GRO support.
Date: Sun, 29 Mar 2009 03:17:22 -0700 (PDT)
Message-ID: <20090329.031722.13206549.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34503
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753872AbZC2KRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2009 06:17:34 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 6DD73C8C0DD
	for <netdev@vger.kernel.org>; Sun, 29 Mar 2009 03:17:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/niu.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 50c1112..02c37e2 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -3441,7 +3441,8 @@ static int niu_rx_pkt_ignore(struct niu *np, struct rx_ring_info *rp)
 	return num_rcr;
 }
 
-static int niu_process_rx_pkt(struct niu *np, struct rx_ring_info *rp)
+static int niu_process_rx_pkt(struct napi_struct *napi, struct niu *np,
+			      struct rx_ring_info *rp)
 {
 	unsigned int index = rp->rcr_index;
 	struct sk_buff *skb;
@@ -3518,7 +3519,7 @@ static int niu_process_rx_pkt(struct niu *np, struct rx_ring_info *rp)
 
 	skb->protocol = eth_type_trans(skb, np->dev);
 	skb_record_rx_queue(skb, rp->rx_channel);
-	netif_receive_skb(skb);
+	napi_gro_receive(napi, skb);
 
 	return num_rcr;
 }
@@ -3706,7 +3707,8 @@ static inline void niu_sync_rx_discard_stats(struct niu *np,
 	}
 }
 
-static int niu_rx_work(struct niu *np, struct rx_ring_info *rp, int budget)
+static int niu_rx_work(struct napi_struct *napi, struct niu *np,
+		       struct rx_ring_info *rp, int budget)
 {
 	int qlen, rcr_done = 0, work_done = 0;
 	struct rxdma_mailbox *mbox = rp->mbox;
@@ -3728,7 +3730,7 @@ static int niu_rx_work(struct niu *np, struct rx_ring_info *rp, int budget)
 	rcr_done = work_done = 0;
 	qlen = min(qlen, budget);
 	while (work_done < qlen) {
-		rcr_done += niu_process_rx_pkt(np, rp);
+		rcr_done += niu_process_rx_pkt(napi, np, rp);
 		work_done++;
 	}
 
@@ -3776,7 +3778,7 @@ static int niu_poll_core(struct niu *np, struct niu_ldg *lp, int budget)
 		if (rx_vec & (1 << rp->rx_channel)) {
 			int this_work_done;
 
-			this_work_done = niu_rx_work(np, rp,
+			this_work_done = niu_rx_work(&lp->napi, np, rp,
 						     budget);
 
 			budget -= this_work_done;
-- 
1.6.2.1.222.g570cc

