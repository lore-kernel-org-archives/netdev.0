From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v3] net: clean up skb headers code
Date: Thu, 30 May 2013 10:06:15 +0800
Message-ID: <1369879575-18701-1-git-send-email-amwang@redhat.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43474 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759848Ab3E3CG3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 May 2013 22:06:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

commit 1a37e412a0225fcba5587 (net: Use 16bits for *_headers
fields of struct skbuff) converts skb->*_header to u16,
some #if NET_SKBUFF_DATA_USES_OFFSET are now useless,
and to be safe, we could just use "X = ~(typeof(X))0;"
as suggested by David and Ben.

Cc: Ben Hutchings <bhutchings@solarflare.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Simon Horman <horms@verge.net.au>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
v2: use typeof
v3: use ~(typeof(X))0

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 5f93119..f3c18a0 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1593,7 +1593,7 @@ static inline void skb_set_inner_mac_header(struct sk_buff *skb,
 }
 static inline bool skb_transport_header_was_set(const struct sk_buff *skb)
 {
-	return skb->transport_header != ~0U;
+	return skb->transport_header != ~(typeof(skb->transport_header))0;
 }
 
 static inline unsigned char *skb_transport_header(const struct sk_buff *skb)
@@ -1636,7 +1636,7 @@ static inline unsigned char *skb_mac_header(const struct sk_buff *skb)
 
 static inline int skb_mac_header_was_set(const struct sk_buff *skb)
 {
-	return skb->mac_header != ~0U;
+	return skb->mac_header != ~(typeof(skb->mac_header))0;
 }
 
 static inline void skb_reset_mac_header(struct sk_buff *skb)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f45de07..e121c4b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -199,9 +199,7 @@ struct sk_buff *__alloc_skb_head(gfp_t gfp_mask, int node)
 	skb->truesize = sizeof(struct sk_buff);
 	atomic_set(&skb->users, 1);
 
-#ifdef NET_SKBUFF_DATA_USES_OFFSET
-	skb->mac_header = (__u16) ~0U;
-#endif
+	skb->mac_header = ~(typeof(skb->mac_header))0;
 out:
 	return skb;
 }
@@ -275,10 +273,8 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	skb->data = data;
 	skb_reset_tail_pointer(skb);
 	skb->end = skb->tail + size;
-#ifdef NET_SKBUFF_DATA_USES_OFFSET
-	skb->mac_header = (__u16) ~0U;
-	skb->transport_header = (__u16) ~0U;
-#endif
+	skb->mac_header = ~(typeof(skb->mac_header))0;
+	skb->transport_header = ~(typeof(skb->transport_header))0;
 
 	/* make sure we initialize shinfo sequentially */
 	shinfo = skb_shinfo(skb);
@@ -344,10 +340,8 @@ struct sk_buff *build_skb(void *data, unsigned int frag_size)
 	skb->data = data;
 	skb_reset_tail_pointer(skb);
 	skb->end = skb->tail + size;
-#ifdef NET_SKBUFF_DATA_USES_OFFSET
-	skb->mac_header = (__u16) ~0U;
-	skb->transport_header = (__u16) ~0U;
-#endif
+	skb->mac_header = ~(typeof(skb->mac_header))0;
+	skb->transport_header = ~(typeof(skb->transport_header))0;
 
 	/* make sure we initialize shinfo sequentially */
 	shinfo = skb_shinfo(skb);
