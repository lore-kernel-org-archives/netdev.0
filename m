From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/15]: appletalk: Use frag list abstraction interfaces.
Date: Tue, 09 Jun 2009 05:01:56 -0700 (PDT)
Message-ID: <20090609.050156.153369270.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58243
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757072AbZFIMBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 08:01:54 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 1720DC8C0F4
	for <netdev@vger.kernel.org>; Tue,  9 Jun 2009 05:01:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/appletalk/ddp.c |   31 ++++++++++++++-----------------
 1 files changed, 14 insertions(+), 17 deletions(-)

diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index d6a9243..b603cba 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -939,6 +939,7 @@ static unsigned long atalk_sum_skb(const struct sk_buff *skb, int offset,
 				   int len, unsigned long sum)
 {
 	int start = skb_headlen(skb);
+	struct sk_buff *frag_iter;
 	int i, copy;
 
 	/* checksum stuff in header space */
@@ -977,26 +978,22 @@ static unsigned long atalk_sum_skb(const struct sk_buff *skb, int offset,
 		start = end;
 	}
 
-	if (skb_shinfo(skb)->frag_list) {
-		struct sk_buff *list = skb_shinfo(skb)->frag_list;
-
-		for (; list; list = list->next) {
-			int end;
+	skb_walk_frags(skb, frag_iter) {
+		int end;
 
-			WARN_ON(start > offset + len);
+		WARN_ON(start > offset + len);
 
-			end = start + list->len;
-			if ((copy = end - offset) > 0) {
-				if (copy > len)
-					copy = len;
-				sum = atalk_sum_skb(list, offset - start,
-						    copy, sum);
-				if ((len -= copy) == 0)
-					return sum;
-				offset += copy;
-			}
-			start = end;
+		end = start + frag_iter->len;
+		if ((copy = end - offset) > 0) {
+			if (copy > len)
+				copy = len;
+			sum = atalk_sum_skb(frag_iter, offset - start,
+					    copy, sum);
+			if ((len -= copy) == 0)
+				return sum;
+			offset += copy;
 		}
+		start = end;
 	}
 
 	BUG_ON(len > 0);
-- 
1.6.3.2

