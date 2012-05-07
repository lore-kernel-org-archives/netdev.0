From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH RFC 6/6] skbuff: set zerocopy flag on frag destructor
Date: Mon, 7 May 2012 16:54:58 +0300
Message-ID: <7e4fb863d3936baa87d318d97103689304a3923c.1336397823.git.mst@redhat.com>
References: <cover.1336397823.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20043 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756194Ab2EGNyz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2012 09:54:55 -0400
Content-Disposition: inline
In-Reply-To: <cover.1336397823.git.mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

set tx flags when adding a frag destructor to
force frags to be orphaned as appropriate.
copy when copying frags between skbs.
Note: rare false positives (where flag is set with no
destructors) are harmless.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 include/linux/skbuff.h |   19 ++++++++++++++++++-
 net/core/skbuff.c      |    3 +++
 2 files changed, 21 insertions(+), 1 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 28d842e..2876e4d 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -258,6 +258,13 @@ enum {
 	SKBTX_WIFI_STATUS = 1 << 5,
 };
 
+static inline void skb_copy_frag_destructor(struct sk_buff *to,
+					    struct sk_buff *from)
+{
+	skb_shinfo(to)->tx_flags |= skb_shinfo(from)->tx_flags &
+		SKBTX_DEV_ZEROCOPY;
+}
+
 /*
  * The callback notifies userspace to release buffers when skb DMA is done in
  * lower device, the skb last reference should be 0 when calling this.
@@ -1260,6 +1267,8 @@ static inline void skb_frag_set_destructor(struct sk_buff *skb, int i,
 {
 	skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 	frag->page.destructor = destroy;
+	if (destroy)
+		skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
 }
 
 /**
@@ -1726,7 +1735,15 @@ static inline int skb_orphan_frags(struct sk_buff *skb, gfp_t gfp_mask)
 	return skb_copy_ubufs(skb, gfp_mask);
 }
 
-
+/**
+ *	skb_copy_frag_destructor - update skb after destructor copy
+ *	@to: target skb to which frags were copied
+ *	@from: source skb from which frags where copied
+ *
+ *	Called after some frags move between skbs.
+ *	If any frags in @from have a destructor, a flag in tx_flags is set.
+ *	Set flag for @to so that it gets checked for destructors.
+ */
 static inline void skb_copy_frag_destructor(struct sk_buff *to,
 					    struct sk_buff *from)
 {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index bdf5b09..83b04d9 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -902,6 +902,7 @@ struct sk_buff *__pskb_copy(struct sk_buff *skb, int headroom, gfp_t gfp_mask)
 	n->truesize += skb->data_len;
 	n->data_len  = skb->data_len;
 	n->len	     = skb->len;
+	skb_copy_frag_destructor(n, skb);
 
 	if (skb_shinfo(skb)->nr_frags) {
 		int i;
@@ -2302,6 +2303,7 @@ static inline void skb_split_no_header(struct sk_buff *skb,
 void skb_split(struct sk_buff *skb, struct sk_buff *skb1, const u32 len)
 {
 	int pos = skb_headlen(skb);
+	skb_copy_frag_destructor(skb1, skb);
 
 	if (len < pos)	/* Split line is inside header. */
 		skb_split_inside_header(skb, skb1, len, pos);
@@ -2781,6 +2783,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 			if (unlikely(!nskb))
 				goto err;
 
+			skb_copy_frag_destructor(nskb, skb);
 			skb_reserve(nskb, headroom);
 			__skb_put(nskb, doffset);
 		}
-- 
MST
