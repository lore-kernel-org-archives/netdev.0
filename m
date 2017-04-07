From: <ilant@mellanox.com>
Subject: [PATCH net-next] gso: Support frag_list splitting with head_frag
Date: Sat, 8 Apr 2017 02:07:08 +0300
Message-ID: <20170407230708.18967-1-ilant@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Ilan Tayari <ilant@mellanox.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0040.outbound.protection.outlook.com ([104.47.2.40]:34368
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751981AbdDGXHa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 19:07:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilan Tayari <ilant@mellanox.com>

A driver may use build_skb() for received packets.
These SKBs then have a head_frag.

Since commit d7e8883cfcf4 ("net: make GRO aware of
skb->head_frag"), GRO may build frag_list SKBs out of
head_frag received SKBs.
In such a case, the chained SKBs end up with a head_frag.

Commit 07b26c9454a2 ("gso: Support partial splitting at
the frag_list pointer") adds partial segmentation of frag_list
SKB chains into individual SKBs.
However, this is not done if the chained SKBs have any
linear part, because the device may not be able to DMA
the private linear buffer.

A chained frag_list SKB with head_frag is wrongfully
detected in this case as having a private linear part
and thus falls back to software GSO, while in fact the
linear part is backed by a DMA page just like any other frag.

This causes low performance when forwarding those packets
that were built with build_skb()

Allow partial segmentation at the frag_list pointer for
chained SKBs with head_frag.

Note that such SKBs can only be created by GRO, when applied
to received packets with head_frag.
Also note that this change only affects the data path that
performs the partial segmentation at frag_list pointer, and
not any of the other more common data paths.

Signed-off-by: Ilan Tayari <ilant@mellanox.com>
---
 net/core/skbuff.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 9f781092fda9..5d9a11eafbf5 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3093,7 +3093,7 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 			 * containing the same amount of data.
 			 */
 			skb_walk_frags(head_skb, iter) {
-				if (skb_headlen(iter))
+				if (skb_headlen(iter) && !iter->head_frag)
 					goto normal;
 
 				len -= iter->len;
-- 
2.11.0
