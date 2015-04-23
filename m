From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: avoid looping in tcp_send_fin()
Date: Thu, 23 Apr 2015 10:42:39 -0700
Message-ID: <1429810959.22254.74.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150423.115447.2163146250304402014.davem@davemloft.net>
	 <1429805815.22254.57.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1429807692.22254.59.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150423.131234.2270841808622853554.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: johunt@akamai.com, netdev@vger.kernel.org, edumazet@google.com,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:34119 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966513AbbDWRml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 13:42:41 -0400
Received: by iget9 with SMTP id t9so14467598ige.1
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2015 10:42:40 -0700 (PDT)
In-Reply-To: <20150423.131234.2270841808622853554.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Presence of an unbound loop in tcp_send_fin() had always been hard
to explain when analyzing crash dumps involving gigantic dying processes
with millions of sockets.

Lets try a different strategy :

In case of memory pressure, try to add the FIN flag to last packet
in write queue, even if packet was already sent. TCP stack will
be able to deliver this FIN after a timeout event. Note that this
FIN being delivered by a retransmit, it also carries a Push flag
given our current implementation.

By checking sk_under_memory_pressure(), we anticipate that cooking
many FIN packets might deplete tcp memory.

In the case we could not allocate a packet, even with __GFP_WAIT
allocation, then not sending a FIN seems quite reasonable if it allows
to get rid of this socket, free memory, and not block the process from
eventually doing other useful work.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_output.c |   50 +++++++++++++++++++++++-----------------
 1 file changed, 29 insertions(+), 21 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 2ade67b7cdb0..a369e8a70b2c 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2814,7 +2814,8 @@ begin_fwd:
 
 /* We allow to exceed memory limits for FIN packets to expedite
  * connection tear down and (memory) recovery.
- * Otherwise tcp_send_fin() could loop forever.
+ * Otherwise tcp_send_fin() could be tempted to either delay FIN
+ * or even be forced to close flow without any FIN.
  */
 static void sk_forced_wmem_schedule(struct sock *sk, int size)
 {
@@ -2827,33 +2828,40 @@ static void sk_forced_wmem_schedule(struct sock *sk, int size)
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
+	 * as TCP stack thinks it has already been transmitted.
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
+			/* This means tskb was already sent.
+			 * Pretend we included the FIN on previous transmit.
+			 * We need to set tp->snd_nxt to the value it would have
+			 * if FIN had been sent. This is because retransmit path
+			 * does not change tp->snd_nxt.
+			 */
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
@@ -2862,7 +2870,7 @@ void tcp_send_fin(struct sock *sk)
 				     TCPHDR_ACK | TCPHDR_FIN);
 		tcp_queue_skb(sk, skb);
 	}
-	__tcp_push_pending_frames(sk, mss_now, TCP_NAGLE_OFF);
+	__tcp_push_pending_frames(sk, tcp_current_mss(sk), TCP_NAGLE_OFF);
 }
 
 /* We get here when a process closes a file descriptor (either due to
