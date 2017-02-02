From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: Fix uld_send() for ctrl pkts
Date: Thu,  2 Feb 2017 12:43:29 +0530
Message-ID: <1486019609-11702-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, Arjun V <arjun@chelsio.com>,
        Casey Leedom <leedom@chelsio.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:16215 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750953AbdBBHO3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 02:14:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arjun V <arjun@chelsio.com>

Without any uld being loaded, uld_txq_info[] will be NULL. uld_send()
is also used for sending control work requests(for eg: setting filter)
that dont require any ulds to be loaded. Hence move uld_txq_info[]
assignment after ctrl_xmit().

Also added a NULL check for uld_txq_info[].

Fixes: 94cdb8bb993a (cxgb4: Add support for dynamic allocation
       of resources for ULD).
Signed-off-by: Arjun V <arjun@chelsio.com>
Signed-off-by: Casey Leedom <leedom@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 0fe04b4..09653ae 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -1774,15 +1774,20 @@ static inline int uld_send(struct adapter *adap, struct sk_buff *skb,
 	struct sge_uld_txq *txq;
 	unsigned int idx = skb_txq(skb);
 
-	txq_info = adap->sge.uld_txq_info[tx_uld_type];
-	txq = &txq_info->uldtxq[idx];
-
 	if (unlikely(is_ctrl_pkt(skb))) {
 		/* Single ctrl queue is a requirement for LE workaround path */
 		if (adap->tids.nsftids)
 			idx = 0;
 		return ctrl_xmit(&adap->sge.ctrlq[idx], skb);
 	}
+
+	txq_info = adap->sge.uld_txq_info[tx_uld_type];
+	if (unlikely(!txq_info)) {
+		WARN_ON(true);
+		return NET_XMIT_DROP;
+	}
+
+	txq = &txq_info->uldtxq[idx];
 	return ofld_xmit(txq, skb);
 }
 
-- 
2.1.0
