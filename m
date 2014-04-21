From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: avoid retransmits of TCP packets hanging in
 host queues
Date: Sun, 20 Apr 2014 17:58:17 -0700
Message-ID: <1398041897.19600.26.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1397865790.19600.10.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:54477 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751098AbaDUA6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2014 20:58:19 -0400
Received: by mail-pa0-f45.google.com with SMTP id kl14so3177576pab.4
        for <netdev@vger.kernel.org>; Sun, 20 Apr 2014 17:58:18 -0700 (PDT)
In-Reply-To: <1397865790.19600.10.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In commit 0e280af026a5 ("tcp: introduce TCPSpuriousRtxHostQueues SNMP
counter") we added a logic to detect when a packet was retransmitted
while the prior clone was still in a qdisc or driver queue.

We are now confident we can do better, and catch the problem before
we fragment a TSO packet before retransmit, or in TLP path.

This patch fully exploits the logic by simply canceling the spurious
retransmit.
Original packet is in a queue and will eventually leave the host.

This helps to avoid network collapses when some events make the RTO
estimations very wrong, particularly when dealing with huge number of
sockets with synchronized blast.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
Google-Bug-Id: 8584703

 net/ipv4/tcp_output.c |   34 ++++++++++++++++++++++++++--------
 1 file changed, 26 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 025e25093984..21ad5fd193c9 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -878,15 +878,8 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	BUG_ON(!skb || !tcp_skb_pcount(skb));
 
 	if (clone_it) {
-		const struct sk_buff *fclone = skb + 1;
-
 		skb_mstamp_get(&skb->skb_mstamp);
 
-		if (unlikely(skb->fclone == SKB_FCLONE_ORIG &&
-			     fclone->fclone == SKB_FCLONE_CLONE))
-			NET_INC_STATS(sock_net(sk),
-				      LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES);
-
 		if (unlikely(skb_cloned(skb)))
 			skb = pskb_copy(skb, gfp_mask);
 		else
@@ -2039,6 +2032,25 @@ bool tcp_schedule_loss_probe(struct sock *sk)
 	return true;
 }
 
+/* Thanks to skb fast clones, we can detect if a prior transmit of
+ * a packet is still in a qdisc or driver queue.
+ * In this case, there is very little point doing a retransmit !
+ * Note: This is called from BH context only.
+ */
+static bool skb_still_in_host_queue(const struct sock *sk,
+				    const struct sk_buff *skb)
+{
+	const struct sk_buff *fclone = skb + 1;
+
+	if (unlikely(skb->fclone == SKB_FCLONE_ORIG &&
+		     fclone->fclone == SKB_FCLONE_CLONE)) {
+		NET_INC_STATS_BH(sock_net(sk),
+				 LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES);
+		return true;
+	}
+	return false;
+}
+
 /* When probe timeout (PTO) fires, send a new segment if one exists, else
  * retransmit the last segment.
  */
@@ -2064,6 +2076,9 @@ void tcp_send_loss_probe(struct sock *sk)
 	if (WARN_ON(!skb))
 		goto rearm_timer;
 
+	if (skb_still_in_host_queue(sk, skb))
+		goto rearm_timer;
+
 	pcount = tcp_skb_pcount(skb);
 	if (WARN_ON(!pcount))
 		goto rearm_timer;
@@ -2385,6 +2400,9 @@ int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	    min(sk->sk_wmem_queued + (sk->sk_wmem_queued >> 2), sk->sk_sndbuf))
 		return -EAGAIN;
 
+	if (skb_still_in_host_queue(sk, skb))
+		return -EBUSY;
+
 	if (before(TCP_SKB_CB(skb)->seq, tp->snd_una)) {
 		if (before(TCP_SKB_CB(skb)->end_seq, tp->snd_una))
 			BUG();
@@ -2478,7 +2496,7 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 		 * see tcp_input.c tcp_sacktag_write_queue().
 		 */
 		TCP_SKB_CB(skb)->ack_seq = tp->snd_nxt;
-	} else {
+	} else if (err != -EBUSY) {
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPRETRANSFAIL);
 	}
 	return err;
