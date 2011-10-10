From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 9/9] net: add opaque struct around skb frag page
Date: Mon, 10 Oct 2011 12:11:41 +0100
Message-ID: <1318245101-16890-9-git-send-email-ian.campbell@citrix.com>
References: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:44685 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753640Ab1JJLLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 07:11:55 -0400
In-Reply-To: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
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
index ac6b05a..f881d75 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -135,7 +135,9 @@ struct sk_buff;
 typedef struct skb_frag_struct skb_frag_t;
 
 struct skb_frag_struct {
-	struct page *page;
+	struct {
+		struct page *p;
+	} page;
 #if (BITS_PER_LONG > 32) || (PAGE_SIZE >= 65536)
 	__u32 page_offset;
 	__u32 size;
@@ -1149,7 +1151,7 @@ static inline void __skb_fill_page_desc(struct sk_buff *skb, int i,
 {
 	skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
-	frag->page		  = page;
+	frag->page.p		  = page;
 	frag->page_offset	  = off;
 	frag->size		  = size;
 }
@@ -1673,7 +1675,7 @@ static inline void netdev_free_page(struct net_device *dev, struct page *page)
  */
 static inline struct page *skb_frag_page(const skb_frag_t *frag)
 {
-	return frag->page;
+	return frag->page.p;
 }
 
 /**
@@ -1759,7 +1761,7 @@ static inline void *skb_frag_address_safe(const skb_frag_t *frag)
  */
 static inline void __skb_frag_set_page(skb_frag_t *frag, struct page *page)
 {
-	frag->page = page;
+	frag->page.p = page;
 	__skb_frag_ref(frag);
 }
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5b2c5f1..6305076 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -657,14 +657,14 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 
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
