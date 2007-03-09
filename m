From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Fix RB-tree comparisons
Date: Thu, 08 Mar 2007 21:20:13 -0800 (PST)
Message-ID: <20070308.212013.59468505.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60420
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750939AbXCIFUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 00:20:14 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 87C7DAE40D1
	for <netdev@vger.kernel.org>; Thu,  8 Mar 2007 21:20:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


While reviewing Ilpo's lost marking code I noticed that the
RB-tree code was doing raw comparisons on sequence numbers
which is always wrong.

I checked the following into net-2.6.22 to cure that:

[TCP]: Fix sequence number comparisons in RB-tree code.

Need to use after(), before(), etc. to handle wrapping
correctly.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/tcp.h b/include/net/tcp.h
index b94debb..813fa8b 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1233,9 +1233,9 @@ static inline struct sk_buff *tcp_write_queue_find(struct sock *sk, __u32 seq)
 
 	while (rb_node) {
 		struct sk_buff *tmp = rb_entry(rb_node,struct sk_buff,rb);
-		if (TCP_SKB_CB(tmp)->end_seq > seq) {
+		if (after(TCP_SKB_CB(tmp)->end_seq, seq)) {
 			skb = tmp;
-			if (TCP_SKB_CB(tmp)->seq <= seq)
+			if (!after(TCP_SKB_CB(tmp)->seq, seq))
 				break;
 			rb_node = rb_node->rb_left;
 		} else
@@ -1257,8 +1257,8 @@ static inline void tcp_rb_insert(struct sk_buff *skb, struct rb_root *root)
 
 		rb_parent = *rb_link;
 		tmp = rb_entry(rb_parent,struct sk_buff,rb);
-		if (TCP_SKB_CB(tmp)->end_seq > seq) {
-			BUG_ON(TCP_SKB_CB(tmp)->seq <= seq);
+		if (after(TCP_SKB_CB(tmp)->end_seq, seq)) {
+			BUG_ON(!after(TCP_SKB_CB(tmp)->seq, seq));
 			rb_link = &rb_parent->rb_left;
 		} else {
 			rb_link = &rb_parent->rb_right;
