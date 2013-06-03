From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH] net: fix sk_buff head without data area
Date: Mon,  3 Jun 2013 21:28:43 +0200
Message-ID: <1370287723-30168-1-git-send-email-pablo@netfilter.org>
Cc: eric.dumazet@gmail.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43478 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754816Ab3FCT3E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jun 2013 15:29:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet spotted that we have to check skb->head instead
of skb->data as skb->head points to the beginning of the
data area of the skbuff. Similarly, we have to initialize the
skb->head pointer, not skb->data in __alloc_skb_head.

After this fix, netlink crashes in the release path of the
sk_buff, so let's fix that as well.

This bug was introduced in (0ebd0ac net: add function to
allocate sk_buff head without data area).

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/core/skbuff.c        |    4 ++--
 net/netlink/af_netlink.c |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d629891..98ed66a 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -195,7 +195,7 @@ struct sk_buff *__alloc_skb_head(gfp_t gfp_mask, int node)
 	 * the tail pointer in struct sk_buff!
 	 */
 	memset(skb, 0, offsetof(struct sk_buff, tail));
-	skb->data = NULL;
+	skb->head = NULL;
 	skb->truesize = sizeof(struct sk_buff);
 	atomic_set(&skb->users, 1);
 
@@ -611,7 +611,7 @@ static void skb_release_head_state(struct sk_buff *skb)
 static void skb_release_all(struct sk_buff *skb)
 {
 	skb_release_head_state(skb);
-	if (likely(skb->data))
+	if (likely(skb->head))
 		skb_release_data(skb);
 }
 
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 12ac6b4..d0b3dd6 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -747,7 +747,7 @@ static void netlink_skb_destructor(struct sk_buff *skb)
 		atomic_dec(&ring->pending);
 		sock_put(sk);
 
-		skb->data = NULL;
+		skb->head = NULL;
 	}
 #endif
 	if (skb->sk != NULL)
-- 
1.7.10.4
