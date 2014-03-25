From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 16/54] cxgb4: Call dev_kfree/consume_skb_any instead of [dev_]kfree_skb.
Date: Mon, 24 Mar 2014 23:05:02 -0700
Message-ID: <1395727540-12148-16-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:59063 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751074AbaCYGLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:11:31 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace kfree_skb with dev_consume_skb_any in free_tx_desc that can be
called in hard irq and other contexts. dev_consume_skb_any is used
as this function consumes successfully transmitted skbs.

Replace dev_kfree_skb with dev_kfree_skb_any in t4_eth_xmit that can
be called in hard irq and other contexts, on paths that drop the skb.

Replace dev_kfree_skb with dev_consume_skb_any in t4_eth_xmit that can
be called in hard irq and other contexts, on paths that successfully
transmit the skb.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index d4db382ff8c7..ca95cf2954eb 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -383,7 +383,7 @@ static void free_tx_desc(struct adapter *adap, struct sge_txq *q,
 		if (d->skb) {                       /* an SGL is present */
 			if (unmap)
 				unmap_sgl(dev, d->skb, d->sgl, q);
-			kfree_skb(d->skb);
+			dev_consume_skb_any(d->skb);
 			d->skb = NULL;
 		}
 		++d;
@@ -1009,7 +1009,7 @@ netdev_tx_t t4_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * anything shorter than an Ethernet header.
 	 */
 	if (unlikely(skb->len < ETH_HLEN)) {
-out_free:	dev_kfree_skb(skb);
+out_free:	dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
 
@@ -1104,7 +1104,7 @@ out_free:	dev_kfree_skb(skb);
 
 	if (immediate) {
 		inline_tx_skb(skb, &q->q, cpl + 1);
-		dev_kfree_skb(skb);
+		dev_consume_skb_any(skb);
 	} else {
 		int last_desc;
 
-- 
1.7.10.4
