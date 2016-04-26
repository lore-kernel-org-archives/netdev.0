From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 3/8] cxgb4: Avoids race and deadlock while freeing tx descriptor
Date: Tue, 26 Apr 2016 20:10:24 +0530
Message-ID: <1461681629-28275-4-git-send-email-hariprasad@chelsio.com>
References: <1461681629-28275-1-git-send-email-hariprasad@chelsio.com>
Cc: netdev@vger.kernel.org, leedom@chelsio.com,
	swise@opengridcomputing.com, nirranjan@chelsio.com,
	santosh@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:16592 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751998AbcDZOg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 10:36:28 -0400
In-Reply-To: <1461681629-28275-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There could be race between t4_eth_xmit() and t4_free_sge_resources() while
freeing tx descriptors, take txq lock in t4_free_sge_resources(). We need
to stop the xmit frame path which runs in bottom half context while
unloading the driver using _bh variant of the lock. This is to prevent
the deadlock between xmit and driver unload.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 6278e5a74b74..bad253beb8c8 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -3006,7 +3006,9 @@ void t4_free_sge_resources(struct adapter *adap)
 		if (etq->q.desc) {
 			t4_eth_eq_free(adap, adap->mbox, adap->pf, 0,
 				       etq->q.cntxt_id);
+			__netif_tx_lock_bh(etq->txq);
 			free_tx_desc(adap, &etq->q, etq->q.in_use, true);
+			__netif_tx_unlock_bh(etq->txq);
 			kfree(etq->q.sdesc);
 			free_txq(adap, &etq->q);
 		}
-- 
2.3.4
