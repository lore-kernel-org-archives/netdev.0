From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] udp: drop head states only when all skb references are gone
Date: Wed,  6 Sep 2017 14:44:36 +0200
Message-ID: <1d0596e2a1926e7c0e8c7f691ef42c713daa3396.1504701206.git.pabeni@redhat.com>
References: <1504631927.15310.47.camel@edumazet-glaptop3.roam.corp.google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54227 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753828AbdIFMpA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 08:45:00 -0400
In-Reply-To: <1504631927.15310.47.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit 0ddf3fb2c43d ("udp: preserve skb->dst if required
for IP options processing") we clear the skb head state as soon
as the skb carrying them is first processed.

Since the same skb can be processed several times when MSG_PEEK
is used, we can end up lacking the required head states, and
eventually oopsing.

Fix this clearing the skb head state only when processing the
last skb reference.

Reported-by: Eric Dumazet <edumazet@google.com>
Fixes: 0ddf3fb2c43d ("udp: preserve skb->dst if required for IP options processing")
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/linux/skbuff.h | 2 +-
 net/core/skbuff.c      | 9 +++------
 net/ipv4/udp.c         | 5 ++++-
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d67a8182e5eb..63df75ae70ee 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -885,7 +885,7 @@ void kfree_skb(struct sk_buff *skb);
 void kfree_skb_list(struct sk_buff *segs);
 void skb_tx_error(struct sk_buff *skb);
 void consume_skb(struct sk_buff *skb);
-void consume_stateless_skb(struct sk_buff *skb);
+void __consume_stateless_skb(struct sk_buff *skb);
 void  __kfree_skb(struct sk_buff *skb);
 extern struct kmem_cache *skbuff_head_cache;
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e07556606284..72eb23d2426f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -753,14 +753,11 @@ EXPORT_SYMBOL(consume_skb);
  *	consume_stateless_skb - free an skbuff, assuming it is stateless
  *	@skb: buffer to free
  *
- *	Works like consume_skb(), but this variant assumes that all the head
- *	states have been already dropped.
+ *	Alike consume_skb(), but this variant assumes that this is the last
+ *	skb reference and all the head states have been already dropped
  */
-void consume_stateless_skb(struct sk_buff *skb)
+void __consume_stateless_skb(struct sk_buff *skb)
 {
-	if (!skb_unref(skb))
-		return;
-
 	trace_consume_skb(skb);
 	if (likely(skb->head))
 		skb_release_data(skb);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 62344804baae..979e4d8526ba 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1386,12 +1386,15 @@ void skb_consume_udp(struct sock *sk, struct sk_buff *skb, int len)
 		unlock_sock_fast(sk, slow);
 	}
 
+	if (!skb_unref(skb))
+		return;
+
 	/* In the more common cases we cleared the head states previously,
 	 * see __udp_queue_rcv_skb().
 	 */
 	if (unlikely(udp_skb_has_head_state(skb)))
 		skb_release_head_state(skb);
-	consume_stateless_skb(skb);
+	__consume_stateless_skb(skb);
 }
 EXPORT_SYMBOL_GPL(skb_consume_udp);
 
-- 
2.13.5
