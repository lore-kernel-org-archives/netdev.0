From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 12/54] bnad: Call dev_kfree_skb_any instead of dev_kfree_skb.
Date: Mon, 24 Mar 2014 23:04:58 -0700
Message-ID: <1395727540-12148-12-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:59115 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752410AbaCYGLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:11:40 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace dev_kfree_skb with dev_kfree_skb_any in bnad_start_xmit that
can be called in hard irq and other contexts.

dev_kfree_skb_any is used as bnad_start_xmit only frees skbs when to
drop them, normally transmitted packets are handled elsewhere.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index cb7625366ec2..a881e982a084 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -2946,17 +2946,17 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	/* Sanity checks for the skb */
 
 	if (unlikely(skb->len <= ETH_HLEN)) {
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		BNAD_UPDATE_CTR(bnad, tx_skb_too_short);
 		return NETDEV_TX_OK;
 	}
 	if (unlikely(len > BFI_TX_MAX_DATA_PER_VECTOR)) {
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		BNAD_UPDATE_CTR(bnad, tx_skb_headlen_zero);
 		return NETDEV_TX_OK;
 	}
 	if (unlikely(len == 0)) {
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		BNAD_UPDATE_CTR(bnad, tx_skb_headlen_zero);
 		return NETDEV_TX_OK;
 	}
@@ -2968,7 +2968,7 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	 * and the netif_tx_stop_all_queues() call.
 	 */
 	if (unlikely(!tcb || !test_bit(BNAD_TXQ_TX_STARTED, &tcb->flags))) {
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		BNAD_UPDATE_CTR(bnad, tx_skb_stopping);
 		return NETDEV_TX_OK;
 	}
@@ -2981,7 +2981,7 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	wis = BNA_TXQ_WI_NEEDED(vectors);	/* 4 vectors per work item */
 
 	if (unlikely(vectors > BFI_TX_MAX_VECTORS_PER_PKT)) {
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		BNAD_UPDATE_CTR(bnad, tx_skb_max_vectors);
 		return NETDEV_TX_OK;
 	}
@@ -3021,7 +3021,7 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 	/* Program the opcode, flags, frame_len, num_vectors in WI */
 	if (bnad_txq_wi_prepare(bnad, tcb, skb, txqent)) {
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
 	txqent->hdr.wi.reserved = 0;
@@ -3047,7 +3047,7 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 			/* Undo the changes starting at tcb->producer_index */
 			bnad_tx_buff_unmap(bnad, unmap_q, q_depth,
 				tcb->producer_index);
-			dev_kfree_skb(skb);
+			dev_kfree_skb_any(skb);
 			BNAD_UPDATE_CTR(bnad, tx_skb_frag_zero);
 			return NETDEV_TX_OK;
 		}
@@ -3076,7 +3076,7 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	if (unlikely(len != skb->len)) {
 		/* Undo the changes starting at tcb->producer_index */
 		bnad_tx_buff_unmap(bnad, unmap_q, q_depth, tcb->producer_index);
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		BNAD_UPDATE_CTR(bnad, tx_skb_len_mismatch);
 		return NETDEV_TX_OK;
 	}
-- 
1.7.10.4
