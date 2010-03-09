From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH 4/4] bnx2x: merge common code when stopping queue
Date: Tue,  9 Mar 2010 17:55:03 +0100
Message-ID: <1268153703-4186-4-git-send-email-sgruszka@redhat.com>
References: <1268153703-4186-1-git-send-email-sgruszka@redhat.com>
 <1268153703-4186-2-git-send-email-sgruszka@redhat.com>
 <1268153703-4186-3-git-send-email-sgruszka@redhat.com>
Cc: Vladislav Zolotarov <vladz@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8307 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755227Ab0CIQ46 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Mar 2010 11:56:58 -0500
In-Reply-To: <1268153703-4186-3-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Main reason for merge code is willingness to use memory barrier to avoid
races with bnx2x_tx_int(). There is no real situation possible to
trigger the races. But if we assume that bug of not stopped and full
queue can happen, we should also stop queue then in the safe way.

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
I have no strong fillings that patch should be applied, if Vladislav
do not want the patch, I'll will not argue.

 drivers/net/bnx2x_main.c |   37 ++++++++++++++++++++-----------------
 1 files changed, 20 insertions(+), 17 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 6c042a7..6751ca2 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -11176,10 +11176,9 @@ static netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct eth_tx_bd *tx_data_bd, *total_pkt_bd = NULL;
 	struct eth_tx_parse_bd *pbd = NULL;
 	u16 pkt_prod, bd_prod;
-	int nbd, fp_index;
+	int i, ret, nbd, fp_index;
 	dma_addr_t mapping;
 	u32 xmit_type = bnx2x_xmit_type(bp, skb);
-	int i;
 	u8 hlen = 0;
 	__le16 pkt_size = 0;
 
@@ -11194,10 +11193,9 @@ static netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	fp = &bp->fp[fp_index];
 
 	if (unlikely(bnx2x_tx_avail(fp) < (skb_shinfo(skb)->nr_frags + 3))) {
-		fp->eth_q_stats.driver_xoff++;
-		netif_tx_stop_queue(txq);
 		BNX2X_ERR("BUG! Tx ring full when queue awake!\n");
-		return NETDEV_TX_BUSY;
+		ret = NETDEV_TX_BUSY;
+		goto stop_queue;
 	}
 
 	DP(NETIF_MSG_TX_QUEUED, "SKB: summed %x  protocol %x  protocol(%x,%x)"
@@ -11425,22 +11423,27 @@ static netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	mmiowb();
 
 	fp->tx_bd_prod += nbd;
+	fp->tx_pkt++;
 
-	if (unlikely(bnx2x_tx_avail(fp) < MAX_SKB_FRAGS + 3)) {
-		netif_tx_stop_queue(txq);
+	ret = NETDEV_TX_OK;
+	if (unlikely(bnx2x_tx_avail(fp) < MAX_SKB_FRAGS + 3))
+		goto stop_queue;
 
-		/* paired memory barrier is in bnx2x_tx_int(), we have to keep
-		 * ordering of set_bit() in netif_tx_stop_queue() and read of
-		 * fp->bd_tx_cons */
-		smp_mb();
+	return ret;
 
-		fp->eth_q_stats.driver_xoff++;
-		if (bnx2x_tx_avail(fp) >= MAX_SKB_FRAGS + 3)
-			netif_tx_wake_queue(txq);
-	}
-	fp->tx_pkt++;
+stop_queue:
+	netif_tx_stop_queue(txq);
+
+	/* paired memory barrier is in bnx2x_tx_int(), we have to keep
+	 * ordering of set_bit() in netif_tx_stop_queue() and read of
+	 * fp->bd_tx_cons */
+	smp_mb();
 
-	return NETDEV_TX_OK;
+	fp->eth_q_stats.driver_xoff++;
+	if (bnx2x_tx_avail(fp) >= MAX_SKB_FRAGS + 3)
+		netif_tx_wake_queue(txq);
+
+	return ret;
 }
 
 /* called with rtnl_lock */
-- 
1.6.2.5

