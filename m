From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC/T] [NET] give truesize warning when truesize differs
Date: Sun, 04 May 2008 20:12:08 +0200
Message-ID: <1209924728.3655.7.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:33921 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753201AbYEDSMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 14:12:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the truesize warning be printed when the truesize
actually changed, not just when the header was increased and the
additional size actually used.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---
It'll trigger with mac80211, should hold it until I fixed that.

 include/linux/skbuff.h |    8 ++++++--
 net/core/skbuff.c      |   10 ++++++++--
 2 files changed, 14 insertions(+), 4 deletions(-)

--- everything.orig/include/linux/skbuff.h	2008-05-03 15:47:00.000000000 +0200
+++ everything/include/linux/skbuff.h	2008-05-04 00:30:34.000000000 +0200
@@ -387,9 +387,13 @@ extern void	      skb_truesize_bug(struc
 
 static inline void skb_truesize_check(struct sk_buff *skb)
 {
-	int len = sizeof(struct sk_buff) + skb->len;
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+	int len = sizeof(struct sk_buff) + skb->end;
+#else
+	int len = sizeof(struct sk_buff) + (skb->end - skb->head);
+#endif
 
-	if (unlikely((int)skb->truesize < len))
+	if (unlikely((int)skb->truesize != len))
 		skb_truesize_bug(skb);
 }
 
--- everything.orig/net/core/skbuff.c	2008-05-03 16:29:23.000000000 +0200
+++ everything/net/core/skbuff.c	2008-05-04 00:31:32.000000000 +0200
@@ -151,9 +151,15 @@ void skb_under_panic(struct sk_buff *skb
 
 void skb_truesize_bug(struct sk_buff *skb)
 {
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+	int len = sizeof(struct sk_buff) + skb->end;
+#else
+	int len = sizeof(struct sk_buff) + (skb->end - skb->head);
+#endif
+
 	printk(KERN_ERR "SKB BUG: Invalid truesize (%u) "
-	       "len=%u, sizeof(sk_buff)=%Zd\n",
-	       skb->truesize, skb->len, sizeof(struct sk_buff));
+	       "size=%u, sizeof(sk_buff)=%Zd\n",
+	       skb->truesize, len, sizeof(struct sk_buff));
 }
 EXPORT_SYMBOL(skb_truesize_bug);
 


