From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/15]: skbuff: Add frag list abstraction interfaces.
Date: Tue, 09 Jun 2009 05:01:51 -0700 (PDT)
Message-ID: <20090609.050151.41544906.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58239
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755232AbZFIMBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 08:01:49 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 73F77C8C0F4
	for <netdev@vger.kernel.org>; Tue,  9 Jun 2009 05:01:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


With the hope that these can be used to eliminate direct
references to the frag list implementation.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/skbuff.h |   21 ++++++++++++++++++++-
 1 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index aad484c..f1c93b8 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1077,7 +1077,7 @@ extern void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page,
 			    int off, int size);
 
 #define SKB_PAGE_ASSERT(skb) 	BUG_ON(skb_shinfo(skb)->nr_frags)
-#define SKB_FRAG_ASSERT(skb) 	BUG_ON(skb_shinfo(skb)->frag_list)
+#define SKB_FRAG_ASSERT(skb) 	BUG_ON(skb_has_frags(skb))
 #define SKB_LINEAR_ASSERT(skb)  BUG_ON(skb_is_nonlinear(skb))
 
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
@@ -1716,6 +1716,25 @@ static inline int pskb_trim_rcsum(struct sk_buff *skb, unsigned int len)
 		     skb = skb->prev)
 
 
+static inline bool skb_has_frags(const struct sk_buff *skb)
+{
+	return skb_shinfo(skb)->frag_list != NULL;
+}
+
+static inline void skb_frag_list_init(struct sk_buff *skb)
+{
+	skb_shinfo(skb)->frag_list = NULL;
+}
+
+static inline void skb_frag_add_head(struct sk_buff *skb, struct sk_buff *frag)
+{
+	frag->next = skb_shinfo(skb)->frag_list;
+	skb_shinfo(skb)->frag_list = frag;
+}
+
+#define skb_walk_frags(skb, iter)	\
+	for (iter = skb_shinfo(skb)->frag_list; iter; iter = iter->next)
+
 extern struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned flags,
 					   int *peeked, int *err);
 extern struct sk_buff *skb_recv_datagram(struct sock *sk, unsigned flags,
-- 
1.6.3.2

