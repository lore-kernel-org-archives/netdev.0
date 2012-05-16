From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv2-RFC 2/6] skbuff: convert to skb_orphan_frags
Date: Thu, 17 May 2012 00:16:00 +0300
Message-ID: <486ecc2076c801d57fdd7ea6845b6616c28ff951.1337202879.git.mst@redhat.com>
References: <cover.1337202879.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com, davem@davemloft.net
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64413 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759249Ab2EPWIo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2012 18:08:44 -0400
Content-Disposition: inline
In-Reply-To: <cover.1337202879.git.mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reduce code duplication a bit using the new helper.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 net/core/skbuff.c |   22 ++++++++--------------
 1 files changed, 8 insertions(+), 14 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2a18719..596e392 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -761,10 +761,8 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 {
 	struct sk_buff *n;
 
-	if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
-		if (skb_copy_ubufs(skb, gfp_mask))
-			return NULL;
-	}
+	if (skb_orphan_frags(skb, gfp_mask))
+		return NULL;
 
 	n = skb + 1;
 	if (skb->fclone == SKB_FCLONE_ORIG &&
@@ -884,12 +882,10 @@ struct sk_buff *__pskb_copy(struct sk_buff *skb, int headroom, gfp_t gfp_mask)
 	if (skb_shinfo(skb)->nr_frags) {
 		int i;
 
-		if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
-			if (skb_copy_ubufs(skb, gfp_mask)) {
-				kfree_skb(n);
-				n = NULL;
-				goto out;
-			}
+		if (skb_orphan_frags(skb, gfp_mask)) {
+			kfree_skb(n);
+			n = NULL;
+			goto out;
 		}
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 			skb_shinfo(n)->frags[i] = skb_shinfo(skb)->frags[i];
@@ -962,10 +958,8 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 	 */
 	if (skb_cloned(skb)) {
 		/* copy this zero copy skb frags */
-		if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
-			if (skb_copy_ubufs(skb, gfp_mask))
-				goto nofrags;
-		}
+		if (skb_orphan_frags(skb, gfp_mask))
+			goto nofrags;
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
 			skb_frag_ref(skb, i);
 
-- 
MST
