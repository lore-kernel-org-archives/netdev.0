From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: avoid the unnecessary kmalloc
Date: Tue, 30 Nov 2010 00:16:32 +0800
Message-ID: <1291047392-3057-1-git-send-email-xiaosuo@gmail.com>
Cc: netdev@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:38816 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752926Ab0K2QQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 11:16:59 -0500
Received: by gxk1 with SMTP id 1so118223gxk.19
        for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 08:16:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the old memory allocated by kmalloc() is larger than the new requested,
pskb_expand_head() doesn't need to allocate a new one, unless the skb is
cloned.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/core/skbuff.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 104f844..3908329 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -778,6 +778,17 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 
 	size = SKB_DATA_ALIGN(size);
 
+	if (!skb->cloned &&
+	    size + sizeof(struct skb_shared_info) <= ksize(skb->head)) {
+		memmove(skb->head + size, skb_shinfo(skb),
+			offsetof(struct skb_shared_info,
+				 frags[skb_shinfo(skb)->nr_frags]));
+		memmove(skb->head + nhead, skb->head,
+			skb_tail_pointer(skb) - skb->head);
+		off = nhead;
+		goto adjust_others;
+	}
+
 	data = kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
 	if (!data)
 		goto nodata;
@@ -816,6 +827,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 	off = (data + nhead) - skb->head;
 
 	skb->head     = data;
+adjust_others:
 	skb->data    += off;
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
 	skb->end      = size;
