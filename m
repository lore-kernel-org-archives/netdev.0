From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv6: tcp: add a missing tcp_v6_restore_cb()
Date: Sun, 05 Feb 2017 20:23:22 -0800
Message-ID: <1486355002.7793.39.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35778 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751009AbdBFEXa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2017 23:23:30 -0500
Received: by mail-it0-f68.google.com with SMTP id 203so7472882ith.2
        for <netdev@vger.kernel.org>; Sun, 05 Feb 2017 20:23:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Dmitry reported use-after-free in ip6_datagram_recv_specific_ctl()

A similar bug was fixed in commit 8ce48623f0cf ("ipv6: tcp: restore
IP6CB for pktoptions skbs"), but I missed another spot.

tcp_v6_syn_recv_sock() can indeed set np->pktoptions from ireq->pktopts

Fixes: 971f10eca186 ("tcp: better TCP_SKB_CB layout to reduce cache line misses")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
---
 net/ipv6/tcp_ipv6.c |   24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index cb8929681dc7597eebcc46026e4b6548f4bedadb..eaad72c3d7462b4af09d632fe88466148964e679 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -991,6 +991,16 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	return 0; /* don't send reset */
 }
 
+static void tcp_v6_restore_cb(struct sk_buff *skb)
+{
+	/* We need to move header back to the beginning if xfrm6_policy_check()
+	 * and tcp_v6_fill_cb() are going to be called again.
+	 * ip6_datagram_recv_specific_ctl() also expects IP6CB to be there.
+	 */
+	memmove(IP6CB(skb), &TCP_SKB_CB(skb)->header.h6,
+		sizeof(struct inet6_skb_parm));
+}
+
 static struct sock *tcp_v6_syn_recv_sock(const struct sock *sk, struct sk_buff *skb,
 					 struct request_sock *req,
 					 struct dst_entry *dst,
@@ -1182,8 +1192,10 @@ static struct sock *tcp_v6_syn_recv_sock(const struct sock *sk, struct sk_buff *
 						      sk_gfp_mask(sk, GFP_ATOMIC));
 			consume_skb(ireq->pktopts);
 			ireq->pktopts = NULL;
-			if (newnp->pktoptions)
+			if (newnp->pktoptions) {
+				tcp_v6_restore_cb(newnp->pktoptions);
 				skb_set_owner_r(newnp->pktoptions, newsk);
+			}
 		}
 	}
 
@@ -1198,16 +1210,6 @@ static struct sock *tcp_v6_syn_recv_sock(const struct sock *sk, struct sk_buff *
 	return NULL;
 }
 
-static void tcp_v6_restore_cb(struct sk_buff *skb)
-{
-	/* We need to move header back to the beginning if xfrm6_policy_check()
-	 * and tcp_v6_fill_cb() are going to be called again.
-	 * ip6_datagram_recv_specific_ctl() also expects IP6CB to be there.
-	 */
-	memmove(IP6CB(skb), &TCP_SKB_CB(skb)->header.h6,
-		sizeof(struct inet6_skb_parm));
-}
-
 /* The socket must have it's spinlock held when we get
  * here, unless it is a TCP_LISTEN socket.
  *
