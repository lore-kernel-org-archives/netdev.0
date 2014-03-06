From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] l2tp: keep original skb ownership
Date: Wed, 05 Mar 2014 18:19:34 -0800
Message-ID: <1394072374.27473.23.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	James Chapman <jchapman@katalix.com>,
	Tom Parkin <tparkin@katalix.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:40078 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755512AbaCFCTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 21:19:42 -0500
Received: by mail-pb0-f53.google.com with SMTP id rp16so1908807pbb.40
        for <netdev@vger.kernel.org>; Wed, 05 Mar 2014 18:19:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

There is no reason to orphan skb in l2tp.

This breaks things like per socket memory limits, TCP Small queues...

Fix this before more people copy/paste it.

This is very similar to commit 8f646c922d550
("vxlan: keep original skb ownership")

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_core.c |   23 ++---------------------
 1 file changed, 2 insertions(+), 21 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 735d0f60c83a..a523eb2191bd 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1108,6 +1108,7 @@ static int l2tp_xmit_core(struct l2tp_session *session, struct sk_buff *skb,
 			  struct flowi *fl, size_t data_len)
 {
 	struct l2tp_tunnel *tunnel = session->tunnel;
+	struct sock *sk = tunnel->sock;
 	unsigned int len = skb->len;
 	int error;
 
@@ -1131,7 +1132,7 @@ static int l2tp_xmit_core(struct l2tp_session *session, struct sk_buff *skb,
 	/* Queue the packet to IP for output */
 	skb->local_df = 1;
 #if IS_ENABLED(CONFIG_IPV6)
-	if (skb->sk->sk_family == PF_INET6 && !tunnel->v4mapped)
+	if (sk->sk_family == PF_INET6 && !tunnel->v4mapped)
 		error = inet6_csk_xmit(skb, NULL);
 	else
 #endif
@@ -1151,23 +1152,6 @@ static int l2tp_xmit_core(struct l2tp_session *session, struct sk_buff *skb,
 	return 0;
 }
 
-/* Automatically called when the skb is freed.
- */
-static void l2tp_sock_wfree(struct sk_buff *skb)
-{
-	sock_put(skb->sk);
-}
-
-/* For data skbs that we transmit, we associate with the tunnel socket
- * but don't do accounting.
- */
-static inline void l2tp_skb_set_owner_w(struct sk_buff *skb, struct sock *sk)
-{
-	sock_hold(sk);
-	skb->sk = sk;
-	skb->destructor = l2tp_sock_wfree;
-}
-
 #if IS_ENABLED(CONFIG_IPV6)
 static void l2tp_xmit_ipv6_csum(struct sock *sk, struct sk_buff *skb,
 				int udp_len)
@@ -1221,7 +1205,6 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
 		return NET_XMIT_DROP;
 	}
 
-	skb_orphan(skb);
 	/* Setup L2TP header */
 	session->build_header(session, __skb_push(skb, hdr_len));
 
@@ -1287,8 +1270,6 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
 		break;
 	}
 
-	l2tp_skb_set_owner_w(skb, sk);
-
 	l2tp_xmit_core(session, skb, fl, data_len);
 out_unlock:
 	bh_unlock_sock(sk);
