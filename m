From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 4/9] skb: add skb_shinfo_init and use for both alloc_skb, build_skb and skb_recycle
Date: Thu, 3 May 2012 15:56:06 +0100
Message-ID: <1336056971-7839-4-git-send-email-ian.campbell@citrix.com>
References: <1336056915.20716.96.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:37758 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757102Ab2ECO7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 10:59:22 -0400
In-Reply-To: <1336056915.20716.96.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is only one semantic change here which is that skb_recycle now does:
	kmemcheck_annotate_variable(shinfo->destructor_arg)
I don't think it was erroneously missing before (since in the skb_recycle case
it will have happened previously) but I beleive it is harmless to do it again
and this saves having a different copy of the same code for the recycle case.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
---
 net/core/skbuff.c |   30 +++++++++++++-----------------
 1 files changed, 13 insertions(+), 17 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index c60b603..e96f68b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -145,6 +145,16 @@ static void skb_under_panic(struct sk_buff *skb, int sz, void *here)
 	BUG();
 }
 
+static void skb_shinfo_init(struct sk_buff *skb)
+{
+	struct skb_shared_info *shinfo = skb_shinfo(skb);
+
+	/* make sure we initialize shinfo sequentially */
+	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
+	atomic_set(&shinfo->dataref, 1);
+	kmemcheck_annotate_variable(shinfo->destructor_arg);
+}
+
 /* 	Allocate a new skbuff. We do this ourselves so we can fill in a few
  *	'private' fields and also do memory statistics to find all the
  *	[BEEP] leaks.
@@ -170,7 +180,6 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 			    int fclone, int node)
 {
 	struct kmem_cache *cache;
-	struct skb_shared_info *shinfo;
 	struct sk_buff *skb;
 	u8 *data;
 
@@ -210,11 +219,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	skb->mac_header = ~0U;
 #endif
 
-	/* make sure we initialize shinfo sequentially */
-	shinfo = skb_shinfo(skb);
-	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
-	atomic_set(&shinfo->dataref, 1);
-	kmemcheck_annotate_variable(shinfo->destructor_arg);
+	skb_shinfo_init(skb);
 
 	if (fclone) {
 		struct sk_buff *child = skb + 1;
@@ -255,7 +260,6 @@ EXPORT_SYMBOL(__alloc_skb);
  */
 struct sk_buff *build_skb(void *data, unsigned int frag_size)
 {
-	struct skb_shared_info *shinfo;
 	struct sk_buff *skb;
 	unsigned int size = frag_size ? : ksize(data);
 
@@ -277,11 +281,7 @@ struct sk_buff *build_skb(void *data, unsigned int frag_size)
 	skb->mac_header = ~0U;
 #endif
 
-	/* make sure we initialize shinfo sequentially */
-	shinfo = skb_shinfo(skb);
-	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
-	atomic_set(&shinfo->dataref, 1);
-	kmemcheck_annotate_variable(shinfo->destructor_arg);
+	skb_shinfo_init(skb);
 
 	return skb;
 }
@@ -546,13 +546,9 @@ EXPORT_SYMBOL(consume_skb);
  */
 void skb_recycle(struct sk_buff *skb)
 {
-	struct skb_shared_info *shinfo;
-
 	skb_release_head_state(skb);
 
-	shinfo = skb_shinfo(skb);
-	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
-	atomic_set(&shinfo->dataref, 1);
+	skb_shinfo_init(skb);
 
 	memset(skb, 0, offsetof(struct sk_buff, tail));
 	skb->data = skb->head + NET_SKB_PAD;
-- 
1.7.2.5
