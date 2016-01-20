From: skallam <siva.kallam@broadcom.com>
Subject: [PATCH net-next 2/2] tg3: Fix for tg3 transmit queue 0 timed out when too many gso_segs.
Date: Wed, 20 Jan 2016 17:16:58 +0530
Message-ID: <1453290418-15331-3-git-send-email-siva.kallam@broadcom.com>
References: <1453290418-15331-1-git-send-email-siva.kallam@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <mchan@broadcom.com>,
	<prashant@broadcom.com>,
	Siva Reddy Kallam <siva.kallam@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:12924 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933145AbcATLrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 06:47:08 -0500
In-Reply-To: <1453290418-15331-1-git-send-email-siva.kallam@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Siva Reddy Kallam <siva.kallam@broadcom.com>

There is an issue on the GSO path inside tg3_tso_bug() when we don't
have sufficient descriptors available, we stop the queue. This queue
may never get started again as there are no Tx completions pending.

For example if the tcp segment size is as low as 88 bytes and TSO packet
from the stack is quite big(<64 K), gso_segs exceeds the limit of
descriptors available.

tg3_tso_bug_gso_check() is implemented to verify if the total no. of
descriptors available for gso are sufficient or not. If not sufficient
we simply linearize the the skb and transmit it once again or drop the
skb.

Signed-off-by: Siva Reddy Kallam <siva.kallam@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Acked-by: Prashant Sreedharan <prashant@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 25 +++++++++++++++++++------
 1 file changed, 19 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 9293675..eb3d347 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -7831,6 +7831,14 @@ static int tigon3_dma_hwbug_workaround(struct tg3_napi *tnapi,
 	return ret;
 }
 
+static bool tg3_tso_bug_gso_check(struct tg3_napi *tnapi, struct sk_buff *skb)
+{
+	/* Check if we will never have enough descriptors,
+	 * as gso_segs can be more than current ring size
+	 */
+	return skb_shinfo(skb)->gso_segs < tnapi->tx_pending / 3;
+}
+
 static netdev_tx_t tg3_start_xmit(struct sk_buff *, struct net_device *);
 
 /* Use GSO to workaround all TSO packets that meet HW bug conditions
@@ -7934,14 +7942,19 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		 * vlan encapsulated.
 		 */
 		if (skb->protocol == htons(ETH_P_8021Q) ||
-		    skb->protocol == htons(ETH_P_8021AD))
-			return tg3_tso_bug(tp, tnapi, txq, skb);
+		    skb->protocol == htons(ETH_P_8021AD)) {
+			if (tg3_tso_bug_gso_check(tnapi, skb))
+				return tg3_tso_bug(tp, tnapi, txq, skb);
+			goto drop;
+		}
 
 		if (!skb_is_gso_v6(skb)) {
 			if (unlikely((ETH_HLEN + hdr_len) > 80) &&
-			    tg3_flag(tp, TSO_BUG))
-				return tg3_tso_bug(tp, tnapi, txq, skb);
-
+			    tg3_flag(tp, TSO_BUG)) {
+				if (tg3_tso_bug_gso_check(tnapi, skb))
+					return tg3_tso_bug(tp, tnapi, txq, skb);
+				goto drop;
+			}
 			ip_csum = iph->check;
 			ip_tot_len = iph->tot_len;
 			iph->check = 0;
@@ -8073,7 +8086,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (would_hit_hwbug) {
 		tg3_tx_skb_unmap(tnapi, tnapi->tx_prod, i);
 
-		if (mss) {
+		if (mss && tg3_tso_bug_gso_check(tnapi, skb)) {
 			/* If it's a TSO packet, do GSO instead of
 			 * allocating and copying to a large linear SKB
 			 */
-- 
1.9.1
