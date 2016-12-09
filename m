From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: skb_condense() can also deal with empty skbs
Date: Fri, 09 Dec 2016 08:02:05 -0800
Message-ID: <1481299325.4930.183.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33749 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932461AbcLIQDH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 11:03:07 -0500
Received: by mail-pg0-f68.google.com with SMTP id 3so2695878pgd.0
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2016 08:03:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

It seems attackers can also send UDP packets with no payload at all.

skb_condense() can still be a win in this case.

It will be possible to replace the custom code in tcp_add_backlog()
to get full benefit from skb_condense()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/skbuff.c |   22 +++++++++++++---------
 1 file changed, 13 insertions(+), 9 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 84151cf40aebb973bad5bee3ee4be0758084d83c..b1451e66d570269252ce628b2dc1714b860e1ca4 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4946,16 +4946,20 @@ EXPORT_SYMBOL(pskb_extract);
  */
 void skb_condense(struct sk_buff *skb)
 {
-	if (!skb->data_len ||
-	    skb->data_len > skb->end - skb->tail ||
-	    skb_cloned(skb))
-		return;
-
-	/* Nice, we can free page frag(s) right now */
-	__pskb_pull_tail(skb, skb->data_len);
+	if (skb->data_len) {
+		if (skb->data_len > skb->end - skb->tail ||
+		    skb_cloned(skb))
+			return;
 
-	/* Now adjust skb->truesize, since __pskb_pull_tail() does
-	 * not do this.
+		/* Nice, we can free page frag(s) right now */
+		__pskb_pull_tail(skb, skb->data_len);
+	}
+	/* At this point, skb->truesize might be over estimated,
+	 * because skb had a fragment, and fragments do not tell
+	 * their truesize.
+	 * When we pulled its content into skb->head, fragment
+	 * was freed, but __pskb_pull_tail() could not possibly
+	 * adjust skb->truesize, not knowing the frag truesize.
 	 */
 	skb->truesize = SKB_TRUESIZE(skb_end_offset(skb));
 }
