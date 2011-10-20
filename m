From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 6/6] net: add opaque struct around skb frag page
Date: Thu, 20 Oct 2011 10:01:49 +0100
Message-ID: <1319101309-28431-6-git-send-email-ian.campbell@citrix.com>
References: <1319101275.3385.129.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:26442 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755979Ab1JTJCA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Oct 2011 05:02:00 -0400
In-Reply-To: <1319101275.3385.129.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've split this bit out of the skb frag destructor patch since it helps enforce
the use of the fragment API.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
---
 include/linux/skbuff.h |   10 ++++++----
 net/core/skbuff.c      |    6 +++---
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 1ebf1ea..aec73c1 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -140,7 +140,9 @@ struct sk_buff;
 typedef struct skb_frag_struct skb_frag_t;
 
 struct skb_frag_struct {
-	struct page *page;
+	struct {
+		struct page *p;
+	} page;
 #if (BITS_PER_LONG > 32) || (PAGE_SIZE >= 65536)
 	__u32 page_offset;
 	__u32 size;
@@ -1175,7 +1177,7 @@ static inline void __skb_fill_page_desc(struct sk_buff *skb, int i,
 {
 	skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
-	frag->page		  = page;
+	frag->page.p		  = page;
 	frag->page_offset	  = off;
 	skb_frag_size_set(frag, size);
 }
@@ -1699,7 +1701,7 @@ static inline void netdev_free_page(struct net_device *dev, struct page *page)
  */
 static inline struct page *skb_frag_page(const skb_frag_t *frag)
 {
-	return frag->page;
+	return frag->page.p;
 }
 
 /**
@@ -1785,7 +1787,7 @@ static inline void *skb_frag_address_safe(const skb_frag_t *frag)
  */
 static inline void __skb_frag_set_page(skb_frag_t *frag, struct page *page)
 {
-	frag->page = page;
+	frag->page.p = page;
 }
 
 /**
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e271040..ca4db40 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -668,14 +668,14 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 
 	/* skb frags release userspace buffers */
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
-		put_page(skb_shinfo(skb)->frags[i].page);
+		skb_frag_unref(skb, i);
 
 	uarg->callback(uarg);
 
 	/* skb frags point to kernel buffers */
 	for (i = skb_shinfo(skb)->nr_frags; i > 0; i--) {
-		skb_shinfo(skb)->frags[i - 1].page_offset = 0;
-		skb_shinfo(skb)->frags[i - 1].page = head;
+		__skb_fill_page_desc(skb, i-1, head, 0,
+				     skb_shinfo(skb)->frags[i - 1].size);
 		head = (struct page *)head->private;
 	}
 
-- 
1.7.2.5
