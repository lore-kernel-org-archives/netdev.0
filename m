From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 5/5] cxgb4: Calculate len properly for LSO path
Date: Thu, 13 Mar 2014 20:50:50 +0530
Message-ID: <1394724050-9291-6-git-send-email-hariprasad@chelsio.com>
References: <1394724050-9291-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, dm@chelsio.com, swise@opengridcomputing.com,
	leedom@chelsio.com, santosh@chelsio.com, kumaras@chelsio.com,
	nirranjan@chelsio.com, hariprasad@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:25874 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754344AbaCMP3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 11:29:25 -0400
In-Reply-To: <1394724050-9291-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumaras@chelsio.com>

Commit 0034b29 ("cxgb4: Don't assume LSO only uses SGL path in t4_eth_xmit()")
introduced a regression where-in length was calculated wrongly for LSO path,
causing chip hangs.
So, correct the calculation of len.

Fixes: 0034b29 ("cxgb4: Don't assume LSO only uses SGL path in t4_eth_xmit()")
Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index a7c56b3..46429f9 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -1051,7 +1051,6 @@ out_free:	dev_kfree_skb(skb);
 	end = (u64 *)wr + flits;
 
 	len = immediate ? skb->len : 0;
-	len += sizeof(*cpl);
 	ssi = skb_shinfo(skb);
 	if (ssi->gso_size) {
 		struct cpl_tx_pkt_lso *lso = (void *)wr;
@@ -1079,6 +1078,7 @@ out_free:	dev_kfree_skb(skb);
 		q->tso++;
 		q->tx_cso += ssi->gso_segs;
 	} else {
+		len += sizeof(*cpl);
 		wr->op_immdlen = htonl(FW_WR_OP(FW_ETH_TX_PKT_WR) |
 				       FW_WR_IMMDLEN(len));
 		cpl = (void *)(wr + 1);
-- 
1.8.4
