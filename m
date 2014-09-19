From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next] net: keep original skb which only needs header checking during software GSO
Date: Fri, 19 Sep 2014 14:38:06 +0800
Message-ID: <1411108686-20602-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit ce93718fb7cdbc064c3000ff59e4d3200bdfa744 ("net: Don't keep
around original SKB when we software segment GSO frames") frees the
original skb after software GSO even for dodgy gso skbs. This breaks
the stream throughput from untrusted sources, since only header
checking was done during software GSO instead of a true
segmentation. This patch fixes this by freeing the original gso skb
only when it was really segmented by software.

Fixes ce93718fb7cdbc064c3000ff59e4d3200bdfa744 ("net: Don't keep
around original SKB when we software segment GSO frames.")

CC: David S. Miller <davem@davemloft.net>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 net/core/dev.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index e916ba8..b7a0e1d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2694,10 +2694,12 @@ struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device *dev)
 		struct sk_buff *segs;
 
 		segs = skb_gso_segment(skb, features);
-		kfree_skb(skb);
 		if (IS_ERR(segs))
 			segs = NULL;
-		skb = segs;
+		else if (segs) {
+			kfree_skb(skb);
+			skb = segs;
+		}
 	} else {
 		if (skb_needs_linearize(skb, features) &&
 		    __skb_linearize(skb))
-- 
1.9.1
