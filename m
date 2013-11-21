From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 09/13] bna: Add NULL Check Before Dereferencing TCB
Date: Wed, 20 Nov 2013 21:54:13 -0800
Message-ID: <1385013257-32745-10-git-send-email-rmody@brocade.com>
References: <1385013257-32745-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	<adapter_linux_open_src_team@Brocade.COM>,
	Rasesh Mody <rmody@Brocade.COM>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:40603 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752498Ab3KUGVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 01:21:08 -0500
In-Reply-To: <1385013257-32745-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we already check to see whether the BNAD_TXQ_TX_STARTED cleared.
But if the tcb structure which contains this flag is also already freed by that
time, we would dereference the NULL pointer. This patch is to check tcb for NULL
pointer, before dereferencing it.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index cfdcfb6..41689ae 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -2947,21 +2947,21 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	}
 
 	tcb = bnad->tx_info[0].tcb[txq_id];
-	q_depth = tcb->q_depth;
-	prod = tcb->producer_index;
-
-	unmap_q = tcb->unmap_q;
 
 	/*
 	 * Takes care of the Tx that is scheduled between clearing the flag
 	 * and the netif_tx_stop_all_queues() call.
 	 */
-	if (unlikely(!test_bit(BNAD_TXQ_TX_STARTED, &tcb->flags))) {
+	if (unlikely(!tcb || !test_bit(BNAD_TXQ_TX_STARTED, &tcb->flags))) {
 		dev_kfree_skb(skb);
 		BNAD_UPDATE_CTR(bnad, tx_skb_stopping);
 		return NETDEV_TX_OK;
 	}
 
+	q_depth = tcb->q_depth;
+	prod = tcb->producer_index;
+	unmap_q = tcb->unmap_q;
+
 	vectors = 1 + skb_shinfo(skb)->nr_frags;
 	wis = BNA_TXQ_WI_NEEDED(vectors);	/* 4 vectors per work item */
 
-- 
1.8.2.3
