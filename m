From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: [Bug 14470] New: freez in TCP stack
Date: Thu, 29 Oct 2009 15:08:30 +0100
Message-ID: <4AE9A1DE.6000808@gmail.com>
References: <20091026084132.57bc3d07@nehalam> <20091028151313.ba4a4d23.akpm@linux-foundation.org> <4AE9298C.1000204@gmail.com> <alpine.DEB.2.00.0910291316340.19761@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Netdev <netdev@vger.kernel.org>, kolo@albatani.cz,
	bugzilla-daemon@bugzilla.kernel.org
To: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:49214 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752891AbZJ2OIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 10:08:39 -0400
In-Reply-To: <alpine.DEB.2.00.0910291316340.19761@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> ...I don't understand how a stale reference would yield to a consistent 
> NULL ptr crash there rather than hard to track corruption for most of the 
> times and random crashes then here and there. Or perhaps we were just very 
> lucky to immediately get only those reports which point out to the right 
> track :-).
> 


When a skb is freed, and re-allocated, we clear most of its fields
in __alloc_skb()

memset(skb, 0, offsetof(struct sk_buff, tail));

Then if this skb is freed again, not queued anywhere, its skb->next stays NULL

So if we have a stale reference to a freed skb, we can :

- Get a NULL pointer, or a poisonned value (if SLUB_DEBUG)


Here is a debug patch to check we dont have stale pointers, maybe this will help ?sync


[PATCH] tcp: check stale pointers in tcp_unlink_write_queue()

In order to track some obscure bug, we check in tcp_unlink_write_queue() if
we dont have stale references to unlinked skb

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/tcp.h     |    4 ++++
 net/ipv4/tcp.c        |    2 +-
 net/ipv4/tcp_input.c  |    4 ++--
 net/ipv4/tcp_output.c |    8 ++++----
 4 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 740d09b..09da342 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1357,6 +1357,10 @@ static inline void tcp_insert_write_queue_before(struct sk_buff *new,
 
 static inline void tcp_unlink_write_queue(struct sk_buff *skb, struct sock *sk)
 {
+	WARN_ON(skb == tcp_sk(sk)->retransmit_skb_hint);
+	WARN_ON(skb == tcp_sk(sk)->lost_skb_hint);
+	WARN_ON(skb == tcp_sk(sk)->scoreboard_skb_hint);
+	WARN_ON(skb == sk->sk_send_head);
 	__skb_unlink(skb, &sk->sk_write_queue);
 }
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index e0cfa63..328bdb1 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1102,11 +1102,11 @@ out:
 
 do_fault:
 	if (!skb->len) {
-		tcp_unlink_write_queue(skb, sk);
 		/* It is the one place in all of TCP, except connection
 		 * reset, where we can be unlinking the send_head.
 		 */
 		tcp_check_send_head(sk, skb);
+		tcp_unlink_write_queue(skb, sk);
 		sk_wmem_free_skb(sk, skb);
 	}
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index ba0eab6..fccc6e9 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3251,13 +3251,13 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 		if (!fully_acked)
 			break;
 
-		tcp_unlink_write_queue(skb, sk);
-		sk_wmem_free_skb(sk, skb);
 		tp->scoreboard_skb_hint = NULL;
 		if (skb == tp->retransmit_skb_hint)
 			tp->retransmit_skb_hint = NULL;
 		if (skb == tp->lost_skb_hint)
 			tp->lost_skb_hint = NULL;
+		tcp_unlink_write_queue(skb, sk);
+		sk_wmem_free_skb(sk, skb);
 	}
 
 	if (likely(between(tp->snd_up, prior_snd_una, tp->snd_una)))
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 616c686..196171d 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1791,6 +1791,10 @@ static void tcp_collapse_retrans(struct sock *sk, struct sk_buff *skb)
 
 	tcp_highest_sack_combine(sk, next_skb, skb);
 
+	/* changed transmit queue under us so clear hints */
+	tcp_clear_retrans_hints_partial(tp);
+	if (next_skb == tp->retransmit_skb_hint)
+		tp->retransmit_skb_hint = skb;
 	tcp_unlink_write_queue(next_skb, sk);
 
 	skb_copy_from_linear_data(next_skb, skb_put(skb, next_skb_size),
@@ -1813,10 +1817,6 @@ static void tcp_collapse_retrans(struct sock *sk, struct sk_buff *skb)
 	 */
 	TCP_SKB_CB(skb)->sacked |= TCP_SKB_CB(next_skb)->sacked & TCPCB_EVER_RETRANS;
 
-	/* changed transmit queue under us so clear hints */
-	tcp_clear_retrans_hints_partial(tp);
-	if (next_skb == tp->retransmit_skb_hint)
-		tp->retransmit_skb_hint = skb;
 
 	tcp_adjust_pcount(sk, next_skb, tcp_skb_pcount(next_skb));
 
