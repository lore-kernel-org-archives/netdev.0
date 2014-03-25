From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 15/54] cxgb3: Call dev_kfree/consume_skb_any instead of [dev_]kfree_skb.
Date: Mon, 24 Mar 2014 23:05:01 -0700
Message-ID: <1395727540-12148-15-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:59131 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751957AbaCYGLl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:11:41 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace kfree_skb with dev_consume_skb_any in free_tx_desc, and
write_tx_pkt_wr that can be called in hard irq and other contexts.

Replace dev_kfree_skb with dev_kfree_skb_any in t3_eth_xmit that can
be called in hard irq and other contexts.

dev_kfree_skb is replaced with dev_kfree_skb_any in t3_eth_xmit as
that location is a packet drop, while kfree_skb in free_tx_desc,
and in write_tx_pkt_wr are places where packets are consumed
in a healthy manner.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/chelsio/cxgb3/sge.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/sge.c b/drivers/net/ethernet/chelsio/cxgb3/sge.c
index 632b318eb38a..8b069f96e920 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/sge.c
@@ -298,7 +298,7 @@ static void free_tx_desc(struct adapter *adapter, struct sge_txq *q,
 			if (need_unmap)
 				unmap_skb(d->skb, q, cidx, pdev);
 			if (d->eop) {
-				kfree_skb(d->skb);
+				dev_consume_skb_any(d->skb);
 				d->skb = NULL;
 			}
 		}
@@ -1188,7 +1188,7 @@ static void write_tx_pkt_wr(struct adapter *adap, struct sk_buff *skb,
 			cpl->wr.wr_lo = htonl(V_WR_LEN(flits) | V_WR_GEN(gen) |
 					      V_WR_TID(q->token));
 			wr_gen2(d, gen);
-			kfree_skb(skb);
+			dev_consume_skb_any(skb);
 			return;
 		}
 
@@ -1233,7 +1233,7 @@ netdev_tx_t t3_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * anything shorter than an Ethernet header.
 	 */
 	if (unlikely(skb->len < ETH_HLEN)) {
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
 
-- 
1.7.10.4
