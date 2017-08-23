From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net 3/3] nfp: avoid buffer leak when representor is missing
Date: Tue, 22 Aug 2017 23:22:44 -0700
Message-ID: <20170823062244.26580-4-jakub.kicinski@netronome.com>
References: <20170823062244.26580-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35914 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753290AbdHWGWx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 02:22:53 -0400
Received: by mail-pf0-f172.google.com with SMTP id c28so3475688pfe.3
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 23:22:53 -0700 (PDT)
In-Reply-To: <20170823062244.26580-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When driver receives a muxed frame, but it can't find the representor
netdev it is destined to it will try to "drop" that frame, i.e. reuse
the buffer.  The issue is that the replacement buffer has already been
allocated at this point, and reusing the buffer from received frame
will leak it.  Change the code to put the new buffer on the ring
earlier and not reuse the old buffer (make the buffer parameter
to nfp_net_rx_drop() a NULL).

Fixes: 91bf82ca9eed ("nfp: add support for tx/rx with metadata portid")
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 9f77ce038a4a..1ff0c577819e 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1751,6 +1751,10 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 			continue;
 		}
 
+		nfp_net_dma_unmap_rx(dp, rxbuf->dma_addr);
+
+		nfp_net_rx_give_one(dp, rx_ring, new_frag, new_dma_addr);
+
 		if (likely(!meta.portid)) {
 			netdev = dp->netdev;
 		} else {
@@ -1759,16 +1763,12 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 			nn = netdev_priv(dp->netdev);
 			netdev = nfp_app_repr_get(nn->app, meta.portid);
 			if (unlikely(!netdev)) {
-				nfp_net_rx_drop(dp, r_vec, rx_ring, rxbuf, skb);
+				nfp_net_rx_drop(dp, r_vec, rx_ring, NULL, skb);
 				continue;
 			}
 			nfp_repr_inc_rx_stats(netdev, pkt_len);
 		}
 
-		nfp_net_dma_unmap_rx(dp, rxbuf->dma_addr);
-
-		nfp_net_rx_give_one(dp, rx_ring, new_frag, new_dma_addr);
-
 		skb_reserve(skb, pkt_off);
 		skb_put(skb, pkt_len);
 
-- 
2.11.0
