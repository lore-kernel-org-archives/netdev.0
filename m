From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 5/6] nfp: remove buggy RX buffer length validation
Date: Sat, 16 Apr 2016 11:25:53 +0100
Message-ID: <1460802354-14248-6-git-send-email-jakub.kicinski@netronome.com>
References: <1460802354-14248-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:35756 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246AbcDPK0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2016 06:26:25 -0400
Received: by mail-wm0-f48.google.com with SMTP id a140so60657756wma.0
        for <netdev@vger.kernel.org>; Sat, 16 Apr 2016 03:26:24 -0700 (PDT)
In-Reply-To: <1460802354-14248-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Meaning of data_len and meta_len RX WB descriptor fields is
slightly confusing.  Add a comment with a diagram clarifying
the layout.  Also remove the buffer length validation:
(a) it's imprecise for static rx-offsets; (b) if firmware
is buggy enough to DMA past the end of the buffer
WARN_ON_ONCE() doesn't seem like a strong enough response.
skb_put() will do the checking for us anyway.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 26 ++++++++++++----------
 1 file changed, 14 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 0bdff390c958..5235e86eb684 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1298,23 +1298,25 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 
 		nfp_net_rx_give_one(rx_ring, new_skb, new_dma_addr);
 
+		/*         < meta_len >
+		 *  <-- [rx_offset] -->
+		 *  ---------------------------------------------------------
+		 * | [XX] |  metadata  |             packet           | XXXX |
+		 *  ---------------------------------------------------------
+		 *         <---------------- data_len --------------->
+		 *
+		 * The rx_offset is fixed for all packets, the meta_len can vary
+		 * on a packet by packet basis. If rx_offset is set to zero
+		 * (_RX_OFFSET_DYNAMIC) metadata starts at the beginning of the
+		 * buffer and is immediately followed by the packet (no [XX]).
+		 */
 		meta_len = rxd->rxd.meta_len_dd & PCIE_DESC_RX_META_LEN_MASK;
 		data_len = le16_to_cpu(rxd->rxd.data_len);
 
-		if (WARN_ON_ONCE(data_len > nn->fl_bufsz)) {
-			dev_kfree_skb_any(skb);
-			continue;
-		}
-
-		if (nn->rx_offset == NFP_NET_CFG_RX_OFFSET_DYNAMIC) {
-			/* The packet data starts after the metadata */
+		if (nn->rx_offset == NFP_NET_CFG_RX_OFFSET_DYNAMIC)
 			skb_reserve(skb, meta_len);
-		} else {
-			/* The packet data starts at a fixed offset */
+		else
 			skb_reserve(skb, nn->rx_offset);
-		}
-
-		/* Adjust the SKB for the dynamic meta data pre-pended */
 		skb_put(skb, data_len - meta_len);
 
 		nfp_net_set_hash(nn->netdev, skb, rxd);
-- 
1.9.1
