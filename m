From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 06/14] nfp: add buffer drop/recycle helper for RX
Date: Mon, 31 Oct 2016 20:43:14 +0000
Message-ID: <1477946602-19644-7-git-send-email-jakub.kicinski@netronome.com>
References: <1477946602-19644-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:35305 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034043AbcJaUoE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 16:44:04 -0400
Received: by mail-wm0-f54.google.com with SMTP id a197so43035392wmd.0
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 13:44:03 -0700 (PDT)
In-Reply-To: <1477946602-19644-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nfp_net_rx() is quite long already and about to get longer.
Move buffer drop/recycle to a helper.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 27 ++++++++++++++--------
 1 file changed, 17 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 77c645abb827..abd4f17e89c7 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1330,6 +1330,20 @@ static void nfp_net_set_hash(struct net_device *netdev, struct sk_buff *skb,
 	return data;
 }
 
+static void
+nfp_net_rx_drop(struct nfp_net_r_vector *r_vec, struct nfp_net_rx_ring *rx_ring,
+		struct nfp_net_rx_buf *rxbuf, struct sk_buff *skb)
+{
+	u64_stats_update_begin(&r_vec->rx_sync);
+	r_vec->rx_drops++;
+	u64_stats_update_end(&r_vec->rx_sync);
+
+	if (rxbuf)
+		nfp_net_rx_give_one(rx_ring, rxbuf->skb, rxbuf->dma_addr);
+	if (skb)
+		dev_kfree_skb_any(skb);
+}
+
 /**
  * nfp_net_rx() - receive up to @budget packets on @rx_ring
  * @rx_ring:   RX ring to receive from
@@ -1372,11 +1386,8 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		new_skb = nfp_net_rx_alloc_one(rx_ring, &new_dma_addr,
 					       nn->fl_bufsz);
 		if (!new_skb) {
-			nfp_net_rx_give_one(rx_ring, rx_ring->rxbufs[idx].skb,
-					    rx_ring->rxbufs[idx].dma_addr);
-			u64_stats_update_begin(&r_vec->rx_sync);
-			r_vec->rx_drops++;
-			u64_stats_update_end(&r_vec->rx_sync);
+			nfp_net_rx_drop(r_vec, rx_ring, &rx_ring->rxbufs[idx],
+					NULL);
 			continue;
 		}
 
@@ -1420,12 +1431,8 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 
 			end = nfp_net_parse_meta(nn->netdev, skb, meta_len);
 			if (unlikely(end != skb->data)) {
-				u64_stats_update_begin(&r_vec->rx_sync);
-				r_vec->rx_drops++;
-				u64_stats_update_end(&r_vec->rx_sync);
-
-				dev_kfree_skb_any(skb);
 				nn_warn_ratelimit(nn, "invalid RX packet metadata\n");
+				nfp_net_rx_drop(r_vec, rx_ring, NULL, skb);
 				continue;
 			}
 		}
-- 
1.9.1
