From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: skb_share_check() should use consume_skb()
Date: Sat, 04 Aug 2012 08:54:15 +0200
Message-ID: <1344063255.9299.1457.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:35448 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752090Ab2HDGyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Aug 2012 02:54:19 -0400
Received: by wgbfm10 with SMTP id fm10so173332wgb.1
        for <netdev@vger.kernel.org>; Fri, 03 Aug 2012 23:54:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In order to avoid false drop_monitor indications, we should
call consume_skb() if skb_clone() was successful.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/skbuff.h |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 7632c87..b33a3a1 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -846,13 +846,16 @@ static inline int skb_shared(const struct sk_buff *skb)
  *
  *	NULL is returned on a memory allocation failure.
  */
-static inline struct sk_buff *skb_share_check(struct sk_buff *skb,
-					      gfp_t pri)
+static inline struct sk_buff *skb_share_check(struct sk_buff *skb, gfp_t pri)
 {
 	might_sleep_if(pri & __GFP_WAIT);
 	if (skb_shared(skb)) {
 		struct sk_buff *nskb = skb_clone(skb, pri);
-		kfree_skb(skb);
+
+		if (likely(nskb))
+			consume_skb(skb);
+		else
+			kfree_skb(skb);
 		skb = nskb;
 	}
 	return skb;
