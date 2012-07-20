From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv3 2/6] skbuff: convert to skb_orphan_frags
Date: Fri, 20 Jul 2012 22:23:10 +0300
Message-ID: <a1f1fceab0fc4347ba577f5fb3aca8acf61de064.1342812067.git.mst@redhat.com>
References: <cover.1342812067.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com, davem@davemloft.net
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1342812067.git.mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reduce code duplication a bit using the new helper.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 net/core/skbuff.c | 22 ++++++++--------------
 1 file changed, 8 insertions(+), 14 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index ccfcb7d..438bbc5 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -804,10 +804,8 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
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
@@ -927,12 +925,10 @@ struct sk_buff *__pskb_copy(struct sk_buff *skb, int headroom, gfp_t gfp_mask)
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
