From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 17/54] cxfb4vf: Call dev_kfree/consume_skb_any instead of [dev_]kfree_skb.
Date: Mon, 24 Mar 2014 23:05:03 -0700
Message-ID: <1395727540-12148-17-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:59120 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752420AbaCYGLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:11:40 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace kfree_skb with dev_consume_skb_any in free_tx_desc that can be
called in hard irq and other contexts. dev_consume_skb_any is used
as this function consumes successfully transmitted skbs.

Replace dev_kfree_skb with dev_kfree_skb_any in t4vf_eth_xmit that can
be called in hard irq and other contexts, on paths that drop the skb.

Replace dev_kfree_skb with dev_consume_skb_any in t4vf_eth_xmit that can
be called in hard irq and other contexts, on paths that successfully
transmit the skb.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index 0a89963c48ce..9cfa4b4bb089 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -401,7 +401,7 @@ static void free_tx_desc(struct adapter *adapter, struct sge_txq *tq,
 		if (sdesc->skb) {
 			if (need_unmap)
 				unmap_sgl(dev, sdesc->skb, sdesc->sgl, tq);
-			kfree_skb(sdesc->skb);
+			dev_consume_skb_any(sdesc->skb);
 			sdesc->skb = NULL;
 		}
 
@@ -1275,7 +1275,7 @@ int t4vf_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 		 * need it any longer.
 		 */
 		inline_tx_skb(skb, &txq->q, cpl + 1);
-		dev_kfree_skb(skb);
+		dev_consume_skb_any(skb);
 	} else {
 		/*
 		 * Write the skb's Scatter/Gather list into the TX Packet CPL
@@ -1354,7 +1354,7 @@ out_free:
 	 * An error of some sort happened.  Free the TX skb and tell the
 	 * OS that we've "dealt" with the packet ...
 	 */
-	dev_kfree_skb(skb);
+	dev_kfree_skb_any(skb);
 	return NETDEV_TX_OK;
 }
 
-- 
1.7.10.4
