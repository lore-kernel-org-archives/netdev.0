From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH v3 net-next 1/4] net: skbuff: add skb_append_pagefrags and use it
Date: Thu, 21 May 2015 16:59:58 +0200
Message-ID: <cb8fe767b5785002cb7c64775fc96467b8600b74.1432220158.git.hannes@stressinduktion.org>
References: <cover.1432220158.git.hannes@stressinduktion.org>
Cc: edumazet@google.com, cwang@twopensource.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:42598 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755641AbbEUPAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 11:00:08 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 2AE82206F6
	for <netdev@vger.kernel.org>; Thu, 21 May 2015 11:00:08 -0400 (EDT)
In-Reply-To: <cover.1432220158.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1432220158.git.hannes@stressinduktion.org>
References: <cover.1432220158.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Acked-by: Eric Dumazet <edumazet@google.com>
---
v2:
* remove now unused variable i in ip_append_page (thanks, Cong!)
* switched to EXPORT_SYMBOL_GPL for skb_append_pagefrags

v3:
* unchanged

 include/linux/skbuff.h |  3 +++
 net/core/skbuff.c      | 18 ++++++++++++++++++
 net/ipv4/ip_output.c   | 15 ++++-----------
 3 files changed, 25 insertions(+), 11 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 40960fe..b9d267b 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -860,6 +860,9 @@ int skb_append_datato_frags(struct sock *sk, struct sk_buff *skb,
 					int len, int odd, struct sk_buff *skb),
 			    void *from, int length);
 
+int skb_append_pagefrags(struct sk_buff *skb, struct page *page,
+			 int offset, size_t size);
+
 struct skb_seq_state {
 	__u32		lower_offset;
 	__u32		upper_offset;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f3fe9bd..4f2babe 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2915,6 +2915,24 @@ int skb_append_datato_frags(struct sock *sk, struct sk_buff *skb,
 }
 EXPORT_SYMBOL(skb_append_datato_frags);
 
+int skb_append_pagefrags(struct sk_buff *skb, struct page *page,
+			 int offset, size_t size)
+{
+	int i = skb_shinfo(skb)->nr_frags;
+
+	if (skb_can_coalesce(skb, i, page, offset)) {
+		skb_frag_size_add(&skb_shinfo(skb)->frags[i - 1], size);
+	} else if (i < MAX_SKB_FRAGS) {
+		get_page(page);
+		skb_fill_page_desc(skb, i, page, offset, size);
+	} else {
+		return -EMSGSIZE;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(skb_append_pagefrags);
+
 /**
  *	skb_pull_rcsum - pull skb and update receive checksum
  *	@skb: buffer to update
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 8d91b92..451b009 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1233,11 +1233,9 @@ ssize_t	ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
 	}
 
 	while (size > 0) {
-		int i;
-
-		if (skb_is_gso(skb))
+		if (skb_is_gso(skb)) {
 			len = size;
-		else {
+		} else {
 
 			/* Check if the remaining data fits into current packet. */
 			len = mtu - skb->len;
@@ -1289,15 +1287,10 @@ ssize_t	ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
 			continue;
 		}
 
-		i = skb_shinfo(skb)->nr_frags;
 		if (len > size)
 			len = size;
-		if (skb_can_coalesce(skb, i, page, offset)) {
-			skb_frag_size_add(&skb_shinfo(skb)->frags[i-1], len);
-		} else if (i < MAX_SKB_FRAGS) {
-			get_page(page);
-			skb_fill_page_desc(skb, i, page, offset, len);
-		} else {
+
+		if (skb_append_pagefrags(skb, page, offset, len)) {
 			err = -EMSGSIZE;
 			goto error;
 		}
-- 
2.1.0
