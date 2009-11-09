From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] tcp: provide more information on the tcp receive_queue
 bugs
Date: Mon, 9 Nov 2009 11:19:18 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0911091053200.13479@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696230645-1491473374-1257757214=:13479"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Arjan van de Ven <arjan@infradead.org>,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46816 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754681AbZKIJTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 04:19:13 -0500
Content-ID: <alpine.DEB.2.00.0911091117460.14118@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696230645-1491473374-1257757214=:13479
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.0911091113251.13914@melkinpaasi.cs.helsinki.fi>

The addition of rcv_nxt allows to discern whether the skb
was out of place or tp->copied. Also catch fancy combination
of flags if necessary (sadly we might miss the actual causer
flags as it might have already returned).

Btw, we perhaps would want to forward copied_seq in
somewhere or otherwise we might have some nice loop with
WARN stuff within but where to do that safely I don't
know at this stage until more is known (but it is not
made significantly worse by this patch).

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp.c |   19 ++++++++++++-------
 1 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 98440ad..f1813bc 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1183,7 +1183,9 @@ void tcp_cleanup_rbuf(struct sock *sk, int copied)
 #if TCP_DEBUG
 	struct sk_buff *skb = skb_peek(&sk->sk_receive_queue);
 
-	WARN_ON(skb && !before(tp->copied_seq, TCP_SKB_CB(skb)->end_seq));
+	WARN(skb && !before(tp->copied_seq, TCP_SKB_CB(skb)->end_seq),
+	     KERN_INFO "cleanup rbuf bug: copied %X seq %X rcvnxt %X\n",
+	     tp->copied_seq, TCP_SKB_CB(skb)->end_seq, tp->rcv_nxt);
 #endif
 
 	if (inet_csk_ack_scheduled(sk)) {
@@ -1430,11 +1432,13 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			/* Now that we have two receive queues this
 			 * shouldn't happen.
 			 */
-			if (before(*seq, TCP_SKB_CB(skb)->seq)) {
-				printk(KERN_INFO "recvmsg bug: copied %X "
-				       "seq %X\n", *seq, TCP_SKB_CB(skb)->seq);
+			if (WARN(before(*seq, TCP_SKB_CB(skb)->seq),
+			     KERN_INFO "recvmsg bug: copied %X "
+				       "seq %X rcvnxt %X fl %X\n", *seq,
+				       TCP_SKB_CB(skb)->seq, tp->rcv_nxt,
+				       flags))
 				break;
-			}
+
 			offset = *seq - TCP_SKB_CB(skb)->seq;
 			if (tcp_hdr(skb)->syn)
 				offset--;
@@ -1443,8 +1447,9 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			if (tcp_hdr(skb)->fin)
 				goto found_fin_ok;
 			WARN(!(flags & MSG_PEEK), KERN_INFO "recvmsg bug 2: "
-					"copied %X seq %X\n", *seq,
-					TCP_SKB_CB(skb)->seq);
+					"copied %X seq %X rcvnxt %X fl %X\n",
+					*seq, TCP_SKB_CB(skb)->seq,
+					tp->rcv_nxt, flags);
 		}
 
 		/* Well, if we have backlog, try to process it now yet. */
-- 
1.5.6.5
---696230645-1491473374-1257757214=:13479--
