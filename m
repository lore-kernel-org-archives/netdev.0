From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 3/8] tg3: Fix 4k skb error recovery path
Date: Fri, 4 Nov 2011 12:15:00 -0700
Message-ID: <1320434105-12898-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3460 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755640Ab1KDTN4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 15:13:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On the error recovery resource unwind path, it is possible for the
driver to attempt to unmap a fragment that hadn't been mapped.  This
patch fixes the problem by correcting the "last" parameter supplied.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 507b73b..3a75179 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6507,7 +6507,7 @@ static void tg3_tx_skb_unmap(struct tg3_napi *tnapi, u32 entry, int last)
 		txb = &tnapi->tx_buffers[entry];
 	}
 
-	for (i = 0; i < last; i++) {
+	for (i = 0; i <= last; i++) {
 		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 		entry = NEXT_TX(entry);
@@ -6568,7 +6568,7 @@ static int tigon3_dma_hwbug_workaround(struct tg3_napi *tnapi,
 			if (tg3_tx_frag_set(tnapi, entry, budget, new_addr,
 					    new_skb->len, base_flags,
 					    mss, vlan)) {
-				tg3_tx_skb_unmap(tnapi, save_entry, 0);
+				tg3_tx_skb_unmap(tnapi, save_entry, -1);
 				dev_kfree_skb(new_skb);
 				ret = -1;
 			}
@@ -6758,11 +6758,10 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (tg3_tx_frag_set(tnapi, &entry, &budget, mapping, len, base_flags |
 			  ((skb_shinfo(skb)->nr_frags == 0) ? TXD_FLAG_END : 0),
-			    mss, vlan))
+			    mss, vlan)) {
 		would_hit_hwbug = 1;
-
 	/* Now loop through additional data fragments, and queue them. */
-	if (skb_shinfo(skb)->nr_frags > 0) {
+	} else if (skb_shinfo(skb)->nr_frags > 0) {
 		u32 tmp_mss = mss;
 
 		if (!tg3_flag(tp, HW_TSO_1) &&
@@ -6831,7 +6830,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 
 dma_error:
-	tg3_tx_skb_unmap(tnapi, tnapi->tx_prod, i);
+	tg3_tx_skb_unmap(tnapi, tnapi->tx_prod, --i);
 	tnapi->tx_buffers[tnapi->tx_prod].skb = NULL;
 drop:
 	dev_kfree_skb(skb);
@@ -7284,7 +7283,8 @@ static void tg3_free_rings(struct tg3 *tp)
 			if (!skb)
 				continue;
 
-			tg3_tx_skb_unmap(tnapi, i, skb_shinfo(skb)->nr_frags);
+			tg3_tx_skb_unmap(tnapi, i,
+					 skb_shinfo(skb)->nr_frags - 1);
 
 			dev_kfree_skb_any(skb);
 		}
@@ -11523,7 +11523,7 @@ static int tg3_run_loopback(struct tg3 *tp, u32 pktsz, bool tso_loopback)
 			break;
 	}
 
-	tg3_tx_skb_unmap(tnapi, tnapi->tx_prod - 1, 0);
+	tg3_tx_skb_unmap(tnapi, tnapi->tx_prod - 1, -1);
 	dev_kfree_skb(skb);
 
 	if (tx_idx != tnapi->tx_prod)
-- 
1.7.3.4
