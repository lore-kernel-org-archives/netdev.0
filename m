From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH RFC 1/6] skbuff: support per-page destructors in copy_ubufs
Date: Mon, 7 May 2012 16:54:31 +0300
Message-ID: <8a3235fbceef37758ef23169c4c152e8d1251d3b.1336397823.git.mst@redhat.com>
References: <cover.1336397823.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21464 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756147Ab2EGNy2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2012 09:54:28 -0400
Content-Disposition: inline
In-Reply-To: <cover.1336397823.git.mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sunrpc wants to use zero copy with tcp which means
some fragments are zero copy while others are not.
This in turn means there's no per skb destructor_arg,
instead some fragments have destructors. Teach
skb_copy_ubufs and skb_release_data to handle such skbs.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 net/core/skbuff.c |   18 ++++++++++++++----
 1 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index c81240c..bd28e80 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -423,7 +423,7 @@ static void skb_release_data(struct sk_buff *skb)
 			struct ubuf_info *uarg;
 
 			uarg = skb_shinfo(skb)->destructor_arg;
-			if (uarg->callback)
+			if (uarg && uarg->callback)
 				uarg->callback(uarg);
 		}
 
@@ -721,6 +721,8 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 	for (i = 0; i < num_frags; i++) {
 		u8 *vaddr;
 		skb_frag_t *f = &skb_shinfo(skb)->frags[i];
+		if (unlikely((!uarg && !f->page.destructor)))
+			continue;
 
 		page = alloc_page(GFP_ATOMIC);
 		if (!page) {
@@ -740,13 +742,21 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 	}
 
 	/* skb frags release userspace buffers */
-	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
-		skb_frag_unref(skb, i);
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		skb_frag_t *f = &skb_shinfo(skb)->frags[i];
+		if (unlikely((!uarg && !f->page.destructor)))
+			continue;
+		__skb_frag_unref(f);
+	}
 
-	uarg->callback(uarg);
+	if (uarg)
+		uarg->callback(uarg);
 
 	/* skb frags point to kernel buffers */
 	for (i = skb_shinfo(skb)->nr_frags; i > 0; i--) {
+		skb_frag_t *f = &skb_shinfo(skb)->frags[i];
+		if (unlikely((!uarg && !f->page.destructor)))
+			continue;
 		__skb_fill_page_desc(skb, i-1, head, 0,
 				     skb_shinfo(skb)->frags[i - 1].size);
 		head = (struct page *)head->private;
-- 
MST
