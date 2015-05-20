From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 1/4] net: skbuff: add skb_append_pagefrags and use it
Date: Wed, 20 May 2015 17:35:05 +0200
Message-ID: <9b4f1db599452ad72b0f5dcd95d66311af6eaa58.1432135413.git.hannes@stressinduktion.org>
References: <cover.1432135413.git.hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:54520 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754189AbbETPm0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 11:42:26 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id A866520AC1
	for <netdev@vger.kernel.org>; Wed, 20 May 2015 11:35:16 -0400 (EDT)
Received: from stressinduktion.org (unknown [217.192.177.51])
	by mail.messagingengine.com (Postfix) with ESMTPA id 37F1E6801D6
	for <netdev@vger.kernel.org>; Wed, 20 May 2015 11:35:16 -0400 (EDT)
In-Reply-To: <cover.1432135413.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1432135413.git.hannes@stressinduktion.org>
References: <cover.1432135413.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/skbuff.h |  3 +++
 net/core/skbuff.c      | 18 ++++++++++++++++++
 net/ipv4/ip_output.c   |  8 ++------
 3 files changed, 23 insertions(+), 6 deletions(-)

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
index f3fe9bd..1d3f88a 100644
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
+EXPORT_SYMBOL(skb_append_pagefrags);
+
 /**
  *	skb_pull_rcsum - pull skb and update receive checksum
  *	@skb: buffer to update
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 8d91b92..35ff40f 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1292,12 +1292,8 @@ ssize_t	ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
 		i = skb_shinfo(skb)->nr_frags;
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
