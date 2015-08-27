From: <chenweilong@huawei.com>
Subject: [PATCH net-next] net: Check frag_lists first to prevent data out of order
Date: Thu, 27 Aug 2015 08:56:05 +0800
Message-ID: <1440636965-11552-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <edumazet@google.com>,
	<alexander.h.duyck@redhat.com>, <willemb@google.com>,
	<hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:20926 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982AbbH0A42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 20:56:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

When try to merge several skbs to prior one, if the frag_list is
used and the the last one is a small packet, once the condition
"len <= skb_tailroom(to)" is satisfied, we will get a wrong
packet!
This patch just check frag_lists before the condtion to prevent
this from happening.

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/core/skbuff.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 8a725cc..d08edcb 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4133,6 +4133,9 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
 	if (skb_cloned(to))
 		return false;
 
+	if (skb_has_frag_list(to) || skb_has_frag_list(from))
+		return false;
+
 	if (len <= skb_tailroom(to)) {
 		if (len)
 			BUG_ON(skb_copy_bits(from, 0, skb_put(to, len), len));
@@ -4140,9 +4143,6 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
 		return true;
 	}
 
-	if (skb_has_frag_list(to) || skb_has_frag_list(from))
-		return false;
-
 	if (skb_headlen(from) != 0) {
 		struct page *page;
 		unsigned int offset;
-- 
1.7.12
