From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH RFC 3/6] skbuff: convert to skb_orphan_frags
Date: Mon, 7 May 2012 16:54:42 +0300
Message-ID: <4e5974462cb385ad30b4aa6f1dfc003e5ee39878.1336397823.git.mst@redhat.com>
References: <cover.1336397823.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22207 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756171Ab2EGNyj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2012 09:54:39 -0400
Content-Disposition: inline
In-Reply-To: <cover.1336397823.git.mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reduce dode duplication a bit using the new helper.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 net/core/skbuff.c |   22 ++++++++--------------
 1 files changed, 8 insertions(+), 14 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index bd28e80..bdf5b09 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -785,10 +785,8 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
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
@@ -908,12 +906,10 @@ struct sk_buff *__pskb_copy(struct sk_buff *skb, int headroom, gfp_t gfp_mask)
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
@@ -1005,10 +1001,8 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 		skb_free_head(skb);
 	} else {
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
