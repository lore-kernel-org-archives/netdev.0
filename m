From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next v2 2/2] tcp: TLP retransmits last if failed to send new packet
Date: Wed, 12 Aug 2015 11:18:19 -0700
Message-ID: <1439403499-24774-3-git-send-email-ycheng@google.com>
References: <1439403499-24774-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:33323 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751324AbbHLSUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 14:20:19 -0400
Received: by pdrh1 with SMTP id h1so9966056pdr.0
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 11:20:19 -0700 (PDT)
In-Reply-To: <1439403499-24774-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When TLP fails to send new packet because of receive window
limit, it should fall back to retransmit the last packet instead.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Nandita Dukkipati <nanditad@google.com>
---
v2: condition the fallback retransmit on receiver window limit

 net/ipv4/tcp_output.c | 38 ++++++++++++++++++++++----------------
 1 file changed, 22 insertions(+), 16 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 78fc89c..444ab5b 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2149,7 +2149,7 @@ repair:
 		tcp_cwnd_validate(sk, is_cwnd_limited);
 		return false;
 	}
-	return (push_one == 2) || (!tp->packets_out && tcp_send_head(sk));
+	return !tp->packets_out && tcp_send_head(sk);
 }
 
 bool tcp_schedule_loss_probe(struct sock *sk)
@@ -2226,7 +2226,7 @@ static bool skb_still_in_host_queue(const struct sock *sk,
 	return false;
 }
 
-/* When probe timeout (PTO) fires, send a new segment if one exists, else
+/* When probe timeout (PTO) fires, try send a new segment if possible, else
  * retransmit the last segment.
  */
 void tcp_send_loss_probe(struct sock *sk)
@@ -2235,11 +2235,19 @@ void tcp_send_loss_probe(struct sock *sk)
 	struct sk_buff *skb;
 	int pcount;
 	int mss = tcp_current_mss(sk);
-	int err = -1;
 
-	if (tcp_send_head(sk)) {
-		err = tcp_write_xmit(sk, mss, TCP_NAGLE_OFF, 2, GFP_ATOMIC);
-		goto rearm_timer;
+	skb = tcp_send_head(sk);
+	if (skb) {
+		if (tcp_snd_wnd_test(tp, skb, mss)) {
+			pcount = tp->packets_out;
+			tcp_write_xmit(sk, mss, TCP_NAGLE_OFF, 2, GFP_ATOMIC);
+			if (tp->packets_out > pcount)
+				goto probe_sent;
+			goto rearm_timer;
+		}
+		skb = tcp_write_queue_prev(sk, skb);
+	} else {
+		skb = tcp_write_queue_tail(sk);
 	}
 
 	/* At most one outstanding TLP retransmission. */
@@ -2247,7 +2255,6 @@ void tcp_send_loss_probe(struct sock *sk)
 		goto rearm_timer;
 
 	/* Retransmit last segment. */
-	skb = tcp_write_queue_tail(sk);
 	if (WARN_ON(!skb))
 		goto rearm_timer;
 
@@ -2262,24 +2269,23 @@ void tcp_send_loss_probe(struct sock *sk)
 		if (unlikely(tcp_fragment(sk, skb, (pcount - 1) * mss, mss,
 					  GFP_ATOMIC)))
 			goto rearm_timer;
-		skb = tcp_write_queue_tail(sk);
+		skb = tcp_write_queue_next(sk, skb);
 	}
 
 	if (WARN_ON(!skb || !tcp_skb_pcount(skb)))
 		goto rearm_timer;
 
-	err = __tcp_retransmit_skb(sk, skb);
+	if (__tcp_retransmit_skb(sk, skb))
+		goto rearm_timer;
 
 	/* Record snd_nxt for loss detection. */
-	if (likely(!err))
-		tp->tlp_high_seq = tp->snd_nxt;
+	tp->tlp_high_seq = tp->snd_nxt;
 
+probe_sent:
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPLOSSPROBES);
+	/* Reset s.t. tcp_rearm_rto will restart timer from now */
+	inet_csk(sk)->icsk_pending = 0;
 rearm_timer:
-	if (likely(!err)) {
-		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPLOSSPROBES);
-		/* Reset s.t. tcp_rearm_rto will restart timer from now */
-		inet_csk(sk)->icsk_pending = 0;
-	}
 	tcp_rearm_rto(sk);
 }
 
-- 
2.5.0.276.gf5e568e
