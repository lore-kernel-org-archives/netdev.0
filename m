From: <ilant@mellanox.com>
Subject: [PATCH net] gso: Validate assumption of frag_list segementation
Date: Wed, 19 Apr 2017 21:26:07 +0300
Message-ID: <20170419182607.2342-1-ilant@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Ilan Tayari <ilant@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0044.outbound.protection.outlook.com ([104.47.0.44]:23053
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1030686AbdDSS0V (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Apr 2017 14:26:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilan Tayari <ilant@mellanox.com>

Commit 07b26c9454a2 ("gso: Support partial splitting at the frag_list
pointer") assumes that all SKBs in a frag_list (except maybe the last
one) contain the same amount of GSO payload.

This assumption is not always correct, resulting in the following
warning message in the log:
    skb_segment: too many frags

For example, mlx5 driver in Striding RQ mode creates some RX SKBs with
one frag, and some with 2 frags.
After GRO, the frag_list SKBs end up having different amounts of payload.
If this frag_list SKB is then forwarded, the aforementioned assumption
is violated.

Validate the assumption, and fall back to software GSO if it not true.

Change-Id: Ia03983f4a47b6534dd987d7a2aad96d54d46d212
Fixes: 07b26c9454a2 ("gso: Support partial splitting at the frag_list pointer")
Signed-off-by: Ilan Tayari <ilant@mellanox.com>
Signed-off-by: Ilya Lesokhin <ilyal@mellanox.com>
---
 net/core/skbuff.c | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 35c1e2460206..f86bf69cfb8d 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3082,22 +3082,32 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 	if (sg && csum && (mss != GSO_BY_FRAGS))  {
 		if (!(features & NETIF_F_GSO_PARTIAL)) {
 			struct sk_buff *iter;
+			unsigned int frag_len;
 
 			if (!list_skb ||
 			    !net_gso_ok(features, skb_shinfo(head_skb)->gso_type))
 				goto normal;
 
-			/* Split the buffer at the frag_list pointer.
-			 * This is based on the assumption that all
-			 * buffers in the chain excluding the last
-			 * containing the same amount of data.
+			/* If we get here then all the required
+			 * GSO features except frag_list are supported.
+			 * Try to split the SKB to multiple GSO SKBs
+			 * with no frag_list.
+			 * Currently we can do that only when the buffers don't
+			 * have a linear part and all the buffers except
+			 * the last are of the same length.
 			 */
+			frag_len = list_skb->len;
 			skb_walk_frags(head_skb, iter) {
+				if (frag_len != iter->len && iter->next)
+					goto normal;
 				if (skb_headlen(iter))
 					goto normal;
 
 				len -= iter->len;
 			}
+
+			if (len != frag_len)
+				goto normal;
 		}
 
 		/* GSO partial only requires that we trim off any excess that
-- 
2.11.0
