From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] net: clean up skb headers code
Date: Wed, 29 May 2013 14:09:00 +0800
Message-ID: <1369807740-12324-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37492 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752930Ab3E2GJP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 May 2013 02:09:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 1a37e412a0225fcba5587 (net: Use 16bits for *_headers
fields of struct skbuff) converts skb->*_header to u16,
therefore 1) we could just use 0xFFFFF instead of (__u16) ~0U
2) some #if NET_SKBUFF_DATA_USES_OFFSET is useless now.


Cc: David S. Miller <davem@davemloft.net>
Cc: Simon Horman <horms@verge.net.au>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 8f2b830..3c896b7 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1584,7 +1584,7 @@ static inline void skb_set_inner_mac_header(struct sk_buff *skb,
 }
 static inline bool skb_transport_header_was_set(const struct sk_buff *skb)
 {
-	return skb->transport_header != ~0U;
+	return skb->transport_header != 0xFFFF;
 }
 
 static inline unsigned char *skb_transport_header(const struct sk_buff *skb)
@@ -1627,7 +1627,7 @@ static inline unsigned char *skb_mac_header(const struct sk_buff *skb)
 
 static inline int skb_mac_header_was_set(const struct sk_buff *skb)
 {
-	return skb->mac_header != ~0U;
+	return skb->mac_header != 0xFFFF;
 }
 
 static inline void skb_reset_mac_header(struct sk_buff *skb)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f45de07..0c3742f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -199,9 +199,7 @@ struct sk_buff *__alloc_skb_head(gfp_t gfp_mask, int node)
 	skb->truesize = sizeof(struct sk_buff);
 	atomic_set(&skb->users, 1);
 
-#ifdef NET_SKBUFF_DATA_USES_OFFSET
-	skb->mac_header = (__u16) ~0U;
-#endif
+	skb->mac_header = 0xFFFF;
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
+	skb->mac_header = 0xFFFF;
+	skb->transport_header = 0xFFFF;
 
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
+	skb->mac_header = 0xFFFF;
+	skb->transport_header = 0xFFFF;
 
 	/* make sure we initialize shinfo sequentially */
 	shinfo = skb_shinfo(skb);
