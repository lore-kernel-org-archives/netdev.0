From: David Miller <davem@davemloft.net>
Subject: [PATCH 8/15]: net/core/user_dma.c: Use frag list abstraction
 interfaces.
Date: Tue, 09 Jun 2009 05:02:14 -0700 (PDT)
Message-ID: <20090609.050214.35805797.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58251
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760006AbZFIMCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 08:02:12 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 6A55DC8C1B5
	for <netdev@vger.kernel.org>; Tue,  9 Jun 2009 05:02:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/user_dma.c |   46 ++++++++++++++++++++++------------------------
 1 files changed, 22 insertions(+), 24 deletions(-)

diff --git a/net/core/user_dma.c b/net/core/user_dma.c
index 164b090..25d717e 100644
--- a/net/core/user_dma.c
+++ b/net/core/user_dma.c
@@ -51,6 +51,7 @@ int dma_skb_copy_datagram_iovec(struct dma_chan *chan,
 {
 	int start = skb_headlen(skb);
 	int i, copy = start - offset;
+	struct sk_buff *frag_iter;
 	dma_cookie_t cookie = 0;
 
 	/* Copy header. */
@@ -94,31 +95,28 @@ int dma_skb_copy_datagram_iovec(struct dma_chan *chan,
 		start = end;
 	}
 
-	if (skb_shinfo(skb)->frag_list) {
-		struct sk_buff *list = skb_shinfo(skb)->frag_list;
-
-		for (; list; list = list->next) {
-			int end;
-
-			WARN_ON(start > offset + len);
-
-			end = start + list->len;
-			copy = end - offset;
-			if (copy > 0) {
-				if (copy > len)
-					copy = len;
-				cookie = dma_skb_copy_datagram_iovec(chan, list,
-						offset - start, to, copy,
-						pinned_list);
-				if (cookie < 0)
-					goto fault;
-				len -= copy;
-				if (len == 0)
-					goto end;
-				offset += copy;
-			}
-			start = end;
+	skb_walk_frags(skb, frag_iter) {
+		int end;
+
+		WARN_ON(start > offset + len);
+
+		end = start + frag_iter->len;
+		copy = end - offset;
+		if (copy > 0) {
+			if (copy > len)
+				copy = len;
+			cookie = dma_skb_copy_datagram_iovec(chan, frag_iter,
+							     offset - start,
+							     to, copy,
+							     pinned_list);
+			if (cookie < 0)
+				goto fault;
+			len -= copy;
+			if (len == 0)
+				goto end;
+			offset += copy;
 		}
+		start = end;
 	}
 
 end:
-- 
1.6.3.2

