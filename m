From: Prashant Sreedharan <prashant@broadcom.com>
Subject: [PATCH net]tg3: Modify tg3_tso_bug() to handle multiple TX rings
Date: Tue, 5 Aug 2014 16:02:02 -0700
Message-ID: <1407279722-1485-1-git-send-email-prashant@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:24171 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753577AbaHEXJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 19:09:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tg3_tso_bug() was originally designed to handle only HW TX ring 0, Commit
d3f6f3a1d818410c17445bce4f4caab52eb102f1 ("tg3: Prevent page allocation failure
during TSO workaround") changed the driver logic to use tg3_tso_bug() for all
HW TX rings that are enabled. This patch fixes the regression by modifying
tg3_tso_bug() to handle multiple HW TX rings.

Signed-off-by: Prashant Sreedharan <prashant@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   22 ++++++++++++----------
 1 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 8afa579..a3dd5dc 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -7830,17 +7830,18 @@ static int tigon3_dma_hwbug_workaround(struct tg3_napi *tnapi,
 
 static netdev_tx_t tg3_start_xmit(struct sk_buff *, struct net_device *);
 
-/* Use GSO to workaround a rare TSO bug that may be triggered when the
- * TSO header is greater than 80 bytes.
+/* Use GSO to workaround all TSO packets that meet HW bug conditions
+ * indicated in tg3_tx_frag_set()
  */
-static int tg3_tso_bug(struct tg3 *tp, struct sk_buff *skb)
+static int tg3_tso_bug(struct tg3 *tp, struct tg3_napi *tnapi,
+		       struct netdev_queue *txq, struct sk_buff *skb)
 {
 	struct sk_buff *segs, *nskb;
 	u32 frag_cnt_est = skb_shinfo(skb)->gso_segs * 3;
 
 	/* Estimate the number of fragments in the worst case */
-	if (unlikely(tg3_tx_avail(&tp->napi[0]) <= frag_cnt_est)) {
-		netif_stop_queue(tp->dev);
+	if (unlikely(tg3_tx_avail(tnapi) <= frag_cnt_est)) {
+		netif_tx_stop_queue(txq);
 
 		/* netif_tx_stop_queue() must be done before checking
 		 * checking tx index in tg3_tx_avail() below, because in
@@ -7848,13 +7849,14 @@ static int tg3_tso_bug(struct tg3 *tp, struct sk_buff *skb)
 		 * netif_tx_queue_stopped().
 		 */
 		smp_mb();
-		if (tg3_tx_avail(&tp->napi[0]) <= frag_cnt_est)
+		if (tg3_tx_avail(tnapi) <= frag_cnt_est)
 			return NETDEV_TX_BUSY;
 
-		netif_wake_queue(tp->dev);
+		netif_tx_wake_queue(txq);
 	}
 
-	segs = skb_gso_segment(skb, tp->dev->features & ~(NETIF_F_TSO | NETIF_F_TSO6));
+	segs = skb_gso_segment(skb, tp->dev->features &
+				    ~(NETIF_F_TSO | NETIF_F_TSO6));
 	if (IS_ERR(segs) || !segs)
 		goto tg3_tso_bug_end;
 
@@ -7930,7 +7932,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (!skb_is_gso_v6(skb)) {
 			if (unlikely((ETH_HLEN + hdr_len) > 80) &&
 			    tg3_flag(tp, TSO_BUG))
-				return tg3_tso_bug(tp, skb);
+				return tg3_tso_bug(tp, tnapi, txq, skb);
 
 			ip_csum = iph->check;
 			ip_tot_len = iph->tot_len;
@@ -8061,7 +8063,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 				iph->tot_len = ip_tot_len;
 			}
 			tcph->check = tcp_csum;
-			return tg3_tso_bug(tp, skb);
+			return tg3_tso_bug(tp, tnapi, txq, skb);
 		}
 
 		/* If the workaround fails due to memory/mapping
-- 
1.7.1
