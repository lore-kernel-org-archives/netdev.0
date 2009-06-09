From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/15]: datagram: Use frag list abstraction interfaces.
Date: Tue, 09 Jun 2009 05:01:58 -0700 (PDT)
Message-ID: <20090609.050158.242130351.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58245
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757638AbZFIMB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 08:01:56 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 2152EC8C0F4
	for <netdev@vger.kernel.org>; Tue,  9 Jun 2009 05:01:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/datagram.c |  178 ++++++++++++++++++++++++---------------------------
 1 files changed, 83 insertions(+), 95 deletions(-)

diff --git a/net/core/datagram.c b/net/core/datagram.c
index 774bcd9..58abee1 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -282,6 +282,7 @@ int skb_copy_datagram_iovec(const struct sk_buff *skb, int offset,
 {
 	int start = skb_headlen(skb);
 	int i, copy = start - offset;
+	struct sk_buff *frag_iter;
 
 	/* Copy header. */
 	if (copy > 0) {
@@ -322,28 +323,24 @@ int skb_copy_datagram_iovec(const struct sk_buff *skb, int offset,
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
-			if ((copy = end - offset) > 0) {
-				if (copy > len)
-					copy = len;
-				if (skb_copy_datagram_iovec(list,
-							    offset - start,
-							    to, copy))
-					goto fault;
-				if ((len -= copy) == 0)
-					return 0;
-				offset += copy;
-			}
-			start = end;
+	skb_walk_frags(skb, frag_iter) {
+		int end;
+
+		WARN_ON(start > offset + len);
+
+		end = start + frag_iter->len;
+		if ((copy = end - offset) > 0) {
+			if (copy > len)
+				copy = len;
+			if (skb_copy_datagram_iovec(frag_iter,
+						    offset - start,
+						    to, copy))
+				goto fault;
+			if ((len -= copy) == 0)
+				return 0;
+			offset += copy;
 		}
+		start = end;
 	}
 	if (!len)
 		return 0;
@@ -369,6 +366,7 @@ int skb_copy_datagram_const_iovec(const struct sk_buff *skb, int offset,
 {
 	int start = skb_headlen(skb);
 	int i, copy = start - offset;
+	struct sk_buff *frag_iter;
 
 	/* Copy header. */
 	if (copy > 0) {
@@ -411,30 +409,26 @@ int skb_copy_datagram_const_iovec(const struct sk_buff *skb, int offset,
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
-			if ((copy = end - offset) > 0) {
-				if (copy > len)
-					copy = len;
-				if (skb_copy_datagram_const_iovec(list,
-							    offset - start,
-							    to, to_offset,
-							    copy))
-					goto fault;
-				if ((len -= copy) == 0)
-					return 0;
-				offset += copy;
-				to_offset += copy;
-			}
-			start = end;
+	skb_walk_frags(skb, frag_iter) {
+		int end;
+
+		WARN_ON(start > offset + len);
+
+		end = start + frag_iter->len;
+		if ((copy = end - offset) > 0) {
+			if (copy > len)
+				copy = len;
+			if (skb_copy_datagram_const_iovec(frag_iter,
+							  offset - start,
+							  to, to_offset,
+							  copy))
+				goto fault;
+			if ((len -= copy) == 0)
+				return 0;
+			offset += copy;
+			to_offset += copy;
 		}
+		start = end;
 	}
 	if (!len)
 		return 0;
@@ -461,6 +455,7 @@ int skb_copy_datagram_from_iovec(struct sk_buff *skb, int offset,
 {
 	int start = skb_headlen(skb);
 	int i, copy = start - offset;
+	struct sk_buff *frag_iter;
 
 	/* Copy header. */
 	if (copy > 0) {
@@ -506,31 +501,27 @@ int skb_copy_datagram_from_iovec(struct sk_buff *skb, int offset,
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
-			if ((copy = end - offset) > 0) {
-				if (copy > len)
-					copy = len;
-				if (skb_copy_datagram_from_iovec(list,
-								 offset - start,
-								 from,
-								 from_offset,
-								 copy))
-					goto fault;
-				if ((len -= copy) == 0)
-					return 0;
-				offset += copy;
-				from_offset += copy;
-			}
-			start = end;
+	skb_walk_frags(skb, frag_iter) {
+		int end;
+
+		WARN_ON(start > offset + len);
+
+		end = start + frag_iter->len;
+		if ((copy = end - offset) > 0) {
+			if (copy > len)
+				copy = len;
+			if (skb_copy_datagram_from_iovec(frag_iter,
+							 offset - start,
+							 from,
+							 from_offset,
+							 copy))
+				goto fault;
+			if ((len -= copy) == 0)
+				return 0;
+			offset += copy;
+			from_offset += copy;
 		}
+		start = end;
 	}
 	if (!len)
 		return 0;
@@ -545,8 +536,9 @@ static int skb_copy_and_csum_datagram(const struct sk_buff *skb, int offset,
 				      __wsum *csump)
 {
 	int start = skb_headlen(skb);
-	int pos = 0;
 	int i, copy = start - offset;
+	struct sk_buff *frag_iter;
+	int pos = 0;
 
 	/* Copy header. */
 	if (copy > 0) {
@@ -597,33 +589,29 @@ static int skb_copy_and_csum_datagram(const struct sk_buff *skb, int offset,
 		start = end;
 	}
 
-	if (skb_shinfo(skb)->frag_list) {
-		struct sk_buff *list = skb_shinfo(skb)->frag_list;
-
-		for (; list; list=list->next) {
-			int end;
-
-			WARN_ON(start > offset + len);
-
-			end = start + list->len;
-			if ((copy = end - offset) > 0) {
-				__wsum csum2 = 0;
-				if (copy > len)
-					copy = len;
-				if (skb_copy_and_csum_datagram(list,
-							       offset - start,
-							       to, copy,
-							       &csum2))
-					goto fault;
-				*csump = csum_block_add(*csump, csum2, pos);
-				if ((len -= copy) == 0)
-					return 0;
-				offset += copy;
-				to += copy;
-				pos += copy;
-			}
-			start = end;
+	skb_walk_frags(skb, frag_iter) {
+		int end;
+
+		WARN_ON(start > offset + len);
+
+		end = start + frag_iter->len;
+		if ((copy = end - offset) > 0) {
+			__wsum csum2 = 0;
+			if (copy > len)
+				copy = len;
+			if (skb_copy_and_csum_datagram(frag_iter,
+						       offset - start,
+						       to, copy,
+						       &csum2))
+				goto fault;
+			*csump = csum_block_add(*csump, csum2, pos);
+			if ((len -= copy) == 0)
+				return 0;
+			offset += copy;
+			to += copy;
+			pos += copy;
 		}
+		start = end;
 	}
 	if (!len)
 		return 0;
-- 
1.6.3.2

