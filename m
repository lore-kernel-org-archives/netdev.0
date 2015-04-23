From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] fix tcp fin memory accounting
Date: Thu, 23 Apr 2015 07:02:47 -0700
Message-ID: <1429797767.22254.41.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1426807170-19258-1-git-send-email-johunt@akamai.com>
	 <20150320.132029.103306583158863864.davem@davemloft.net>
	 <550C5A98.5040305@akamai.com>
	 <20150324.021050.384709317309031128.davem@davemloft.net>
	 <55110009.4020706@akamai.com>
	 <1429661349.18561.23.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5538F821.6070503@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	edumazet@google.com
To: Josh Hunt <johunt@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:38132 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751628AbbDWOCu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 10:02:50 -0400
Received: by igbhj9 with SMTP id hj9so24390140igb.1
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2015 07:02:50 -0700 (PDT)
In-Reply-To: <5538F821.6070503@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-23 at 08:48 -0500, Josh Hunt wrote:
> On 04/21/2015 07:09 PM, Eric Dumazet wrote:
> >
> > Note that this patch adds a deadlock possibility in some stress
> > situations.
> >
> > If a process owning some tcp socket dies, and tcp_mem[2] is already hit,
> > all sk_stream_alloc_skb() can return NULL and we loop in tcp_send_fin(),
> > making no progress because we can not free any tcp memory.
> 
> Ugh. Thanks for fixing this Eric!

No problem ;)

For the record, I've tested this followup patch that I'll formally
submit when net-next reopens :

If there is one already sent skb in write queue
(we look at the tail of course), and :
- We are under TCP memory pressure, 
- or allocation of a fresh skb using GFP_KERNEL failed,

-> we add the FIN flag that will eventually be sent later after a
timeout.

 net/ipv4/tcp_output.c |   41 ++++++++++++++++++++--------------------
 1 file changed, 21 insertions(+), 20 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 2ade67b7cdb0..fe6558eb64f3 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2827,33 +2827,34 @@ static void sk_forced_wmem_schedule(struct sock *sk, int size)
 	sk_memory_allocated_add(sk, amt, &status);
 }
 
-/* Send a fin.  The caller locks the socket for us.  This cannot be
- * allowed to fail queueing a FIN frame under any circumstances.
+/* Send a FIN. The caller locks the socket for us.
+ * We should try to send a FIN packet really hard, but eventually give up.
  */
 void tcp_send_fin(struct sock *sk)
 {
+	struct sk_buff *skb, *tskb = tcp_write_queue_tail(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct sk_buff *skb = tcp_write_queue_tail(sk);
-	int mss_now;
 
-	/* Optimization, tack on the FIN if we have a queue of
-	 * unsent frames.  But be careful about outgoing SACKS
-	 * and IP options.
+	/* Optimization, tack on the FIN if we have one skb in write queue and
+	 * this skb was not yet sent, or we are under memory pressure.
+	 * Note: in the latter case, FIN packet will be sent after a timeout,
+	 * as TCP stack thinks it has been transmitted once.
 	 */
-	mss_now = tcp_current_mss(sk);
-
-	if (tcp_send_head(sk)) {
-		TCP_SKB_CB(skb)->tcp_flags |= TCPHDR_FIN;
-		TCP_SKB_CB(skb)->end_seq++;
+	if (tskb && (tcp_send_head(sk) || sk_under_memory_pressure(sk))) {
+coalesce:
+		TCP_SKB_CB(tskb)->tcp_flags |= TCPHDR_FIN;
+		TCP_SKB_CB(tskb)->end_seq++;
 		tp->write_seq++;
+		if (!tcp_send_head(sk)) {
+			tp->snd_nxt++;
+			return;
+		}
 	} else {
-		/* Socket is locked, keep trying until memory is available. */
-		for (;;) {
-			skb = alloc_skb_fclone(MAX_TCP_HEADER,
-					       sk->sk_allocation);
-			if (skb)
-				break;
-			yield();
+		skb = alloc_skb_fclone(MAX_TCP_HEADER, sk->sk_allocation);
+		if (unlikely(!skb)) {
+			if (tskb)
+				goto coalesce;
+			return;
 		}
 		skb_reserve(skb, MAX_TCP_HEADER);
 		sk_forced_wmem_schedule(sk, skb->truesize);
@@ -2862,7 +2863,7 @@ void tcp_send_fin(struct sock *sk)
 				     TCPHDR_ACK | TCPHDR_FIN);
 		tcp_queue_skb(sk, skb);
 	}
-	__tcp_push_pending_frames(sk, mss_now, TCP_NAGLE_OFF);
+	__tcp_push_pending_frames(sk, tcp_current_mss(sk), TCP_NAGLE_OFF);
 }
 
 /* We get here when a process closes a file descriptor (either due to
