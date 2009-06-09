From: David Miller <davem@davemloft.net>
Subject: [PATCH 14/15]: xfrm: Use frag list abstraction interfaces.
Date: Tue, 09 Jun 2009 05:02:30 -0700 (PDT)
Message-ID: <20090609.050230.264288634.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58263
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760102AbZFIMC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 08:02:29 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 0AA49C8C0F4
	for <netdev@vger.kernel.org>; Tue,  9 Jun 2009 05:02:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_algo.c |   41 +++++++++++++++++++----------------------
 1 files changed, 19 insertions(+), 22 deletions(-)

diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index 96036cf..d31ccb4 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -696,8 +696,9 @@ int skb_icv_walk(const struct sk_buff *skb, struct hash_desc *desc,
 {
 	int start = skb_headlen(skb);
 	int i, copy = start - offset;
-	int err;
+	struct sk_buff *frag_iter;
 	struct scatterlist sg;
+	int err;
 
 	/* Checksum header. */
 	if (copy > 0) {
@@ -742,28 +743,24 @@ int skb_icv_walk(const struct sk_buff *skb, struct hash_desc *desc,
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
-				err = skb_icv_walk(list, desc, offset-start,
-						   copy, icv_update);
-				if (unlikely(err))
-					return err;
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
+			err = skb_icv_walk(frag_iter, desc, offset-start,
+					   copy, icv_update);
+			if (unlikely(err))
+				return err;
+			if ((len -= copy) == 0)
+				return 0;
+			offset += copy;
 		}
+		start = end;
 	}
 	BUG_ON(len);
 	return 0;
-- 
1.6.3.2

