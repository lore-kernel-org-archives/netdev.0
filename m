From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: fix tcp_ack() performance problem
Date: Sat, 11 Oct 2014 15:17:29 -0700
Message-ID: <1413065849.9362.72.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Van Jacobson <vanj@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:39711 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223AbaJKWRb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2014 18:17:31 -0400
Received: by mail-pd0-f169.google.com with SMTP id w10so3579040pde.28
        for <netdev@vger.kernel.org>; Sat, 11 Oct 2014 15:17:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We worked hard to improve tcp_ack() performance, by not accessing
skb_shinfo() in fast path (cd7d8498c9a5 tcp: change tcp_skb_pcount()
location)

We still have one spurious access because of ACK timestamping,
added in commit e1c8a607b281 ("net-timestamp: ACK timestamp for
bytestreams")

By checking if sk_tsflags has SOF_TIMESTAMPING_TX_ACK set,
we can avoid two cache line misses for the common case.

While we are at it, add two prefetchw() :

One in tcp_ack() to bring skb at the head of write queue.

One in tcp_clean_rtx_queue() loop to bring following skb,
as we will delete skb from the write queue and dirty skb->next->prev.

Add a couple of [un]likely() clauses.

After this patch, tcp_ack() is no longer the most consuming
function in tcp stack.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Van Jacobson <vanj@google.com>
---
Google-Bug-Id : 9694859

 net/ipv4/tcp_input.c |   36 +++++++++++++++++++++++++++---------
 1 file changed, 27 insertions(+), 9 deletions(-)
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 00a41499d52c..a12b455928e5 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -68,6 +68,7 @@
 #include <linux/module.h>
 #include <linux/sysctl.h>
 #include <linux/kernel.h>
+#include <linux/prefetch.h>
 #include <net/dst.h>
 #include <net/tcp.h>
 #include <net/inet_common.h>
@@ -3029,6 +3030,21 @@ static u32 tcp_tso_acked(struct sock *sk, struct sk_buff *skb)
 	return packets_acked;
 }
 
+static void tcp_ack_tstamp(struct sock *sk, struct sk_buff *skb,
+			   u32 prior_snd_una)
+{
+	const struct skb_shared_info *shinfo;
+
+	/* Avoid cache line misses to get skb_shinfo() and shinfo->tx_flags */
+	if (likely(!(sk->sk_tsflags & SOF_TIMESTAMPING_TX_ACK)))
+		return;
+
+	shinfo = skb_shinfo(skb);
+	if ((shinfo->tx_flags & SKBTX_ACK_TSTAMP) &&
+	    between(shinfo->tskey, prior_snd_una, tcp_sk(sk)->snd_una - 1))
+		__skb_tstamp_tx(skb, NULL, sk, SCM_TSTAMP_ACK);
+}
+
 /* Remove acknowledged frames from the retransmission queue. If our packet
  * is before the ack sequence we can discard it as it's confirmed to have
  * arrived at the other end.
@@ -3052,14 +3068,11 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 	first_ackt.v64 = 0;
 
 	while ((skb = tcp_write_queue_head(sk)) && skb != tcp_send_head(sk)) {
-		struct skb_shared_info *shinfo = skb_shinfo(skb);
 		struct tcp_skb_cb *scb = TCP_SKB_CB(skb);
 		u8 sacked = scb->sacked;
 		u32 acked_pcount;
 
-		if (unlikely(shinfo->tx_flags & SKBTX_ACK_TSTAMP) &&
-		    between(shinfo->tskey, prior_snd_una, tp->snd_una - 1))
-			__skb_tstamp_tx(skb, NULL, sk, SCM_TSTAMP_ACK);
+		tcp_ack_tstamp(sk, skb, prior_snd_una);
 
 		/* Determine how many packets and what bytes were acked, tso and else */
 		if (after(scb->end_seq, tp->snd_una)) {
@@ -3073,10 +3086,12 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 
 			fully_acked = false;
 		} else {
+			/* Speedup tcp_unlink_write_queue() and next loop */
+			prefetchw(skb->next);
 			acked_pcount = tcp_skb_pcount(skb);
 		}
 
-		if (sacked & TCPCB_RETRANS) {
+		if (unlikely(sacked & TCPCB_RETRANS)) {
 			if (sacked & TCPCB_SACKED_RETRANS)
 				tp->retrans_out -= acked_pcount;
 			flag |= FLAG_RETRANS_DATA_ACKED;
@@ -3107,7 +3122,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 		 * connection startup slow start one packet too
 		 * quickly.  This is severely frowned upon behavior.
 		 */
-		if (!(scb->tcp_flags & TCPHDR_SYN)) {
+		if (likely(!(scb->tcp_flags & TCPHDR_SYN))) {
 			flag |= FLAG_DATA_ACKED;
 		} else {
 			flag |= FLAG_SYN_ACKED;
@@ -3119,9 +3134,9 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 
 		tcp_unlink_write_queue(skb, sk);
 		sk_wmem_free_skb(sk, skb);
-		if (skb == tp->retransmit_skb_hint)
+		if (unlikely(skb == tp->retransmit_skb_hint))
 			tp->retransmit_skb_hint = NULL;
-		if (skb == tp->lost_skb_hint)
+		if (unlikely(skb == tp->lost_skb_hint))
 			tp->lost_skb_hint = NULL;
 	}
 
@@ -3132,7 +3147,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 		flag |= FLAG_SACK_RENEGING;
 
 	skb_mstamp_get(&now);
-	if (first_ackt.v64) {
+	if (likely(first_ackt.v64)) {
 		seq_rtt_us = skb_mstamp_us_delta(&now, &first_ackt);
 		ca_seq_rtt_us = skb_mstamp_us_delta(&now, &last_ackt);
 	}
@@ -3394,6 +3409,9 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	int acked = 0; /* Number of packets newly acked */
 	long sack_rtt_us = -1L;
 
+	/* We very likely will need to access write queue head. */
+	prefetchw(sk->sk_write_queue.next);
+
 	/* If the ack is older than previous acks
 	 * then we can probably ignore it.
 	 */
