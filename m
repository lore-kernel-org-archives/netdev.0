From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net] tcp: fix false undo corner cases
Date: Wed,  2 Jul 2014 12:07:16 -0700
Message-ID: <1404328036-2477-1-git-send-email-ycheng@google.com>
Cc: ncardwell@google.com, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f201.google.com ([209.85.216.201]:56423 "EHLO
	mail-qc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932209AbaGBTHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 15:07:20 -0400
Received: by mail-qc0-f201.google.com with SMTP id c9so1326292qcz.0
        for <netdev@vger.kernel.org>; Wed, 02 Jul 2014 12:07:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The undo code assumes that, upon entering loss recovery, TCP
1) always retransmit something
2) the retransmission never fails locally (e.g., qdisc drop)

so undo_marker is set in tcp_enter_recovery() and undo_retrans is
incremented only when tcp_retransmit_skb() is successful.

When the assumption is broken because TCP's cwnd is too small to
retransmit or the retransmit fails locally. The next (DUP)ACK
would incorrectly revert the cwnd and the congestion state in
tcp_try_undo_dsack() or tcp_may_undo(). Subsequent (DUP)ACKs
may enter the recovery state. The sender repeatedly enter and
(incorrectly) exit recovery states if the retransmits continue to
fail locally while receiving (DUP)ACKs.

The fix is to initialize undo_retrans to -1 and start counting on
the first retransmission. Always increment undo_retrans even if the
retransmissions fail locally because they couldn't cause DSACKs to
undo the cwnd reduction.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_input.c  | 8 ++++----
 net/ipv4/tcp_output.c | 6 ++++--
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index b5c2375..40639c2 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1106,7 +1106,7 @@ static bool tcp_check_dsack(struct sock *sk, const struct sk_buff *ack_skb,
 	}
 
 	/* D-SACK for already forgotten data... Do dumb counting. */
-	if (dup_sack && tp->undo_marker && tp->undo_retrans &&
+	if (dup_sack && tp->undo_marker && tp->undo_retrans > 0 &&
 	    !after(end_seq_0, prior_snd_una) &&
 	    after(end_seq_0, tp->undo_marker))
 		tp->undo_retrans--;
@@ -1187,7 +1187,7 @@ static u8 tcp_sacktag_one(struct sock *sk,
 
 	/* Account D-SACK for retransmitted packet. */
 	if (dup_sack && (sacked & TCPCB_RETRANS)) {
-		if (tp->undo_marker && tp->undo_retrans &&
+		if (tp->undo_marker && tp->undo_retrans > 0 &&
 		    after(end_seq, tp->undo_marker))
 			tp->undo_retrans--;
 		if (sacked & TCPCB_SACKED_ACKED)
@@ -1893,7 +1893,7 @@ static void tcp_clear_retrans_partial(struct tcp_sock *tp)
 	tp->lost_out = 0;
 
 	tp->undo_marker = 0;
-	tp->undo_retrans = 0;
+	tp->undo_retrans = -1;
 }
 
 void tcp_clear_retrans(struct tcp_sock *tp)
@@ -2665,7 +2665,7 @@ static void tcp_enter_recovery(struct sock *sk, bool ece_ack)
 
 	tp->prior_ssthresh = 0;
 	tp->undo_marker = tp->snd_una;
-	tp->undo_retrans = tp->retrans_out;
+	tp->undo_retrans = tp->retrans_out ? : -1;
 
 	if (inet_csk(sk)->icsk_ca_state < TCP_CA_CWR) {
 		if (!ece_ack)
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index d92bce0..179b51e 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2525,8 +2525,6 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 		if (!tp->retrans_stamp)
 			tp->retrans_stamp = TCP_SKB_CB(skb)->when;
 
-		tp->undo_retrans += tcp_skb_pcount(skb);
-
 		/* snd_nxt is stored to detect loss of retransmitted segment,
 		 * see tcp_input.c tcp_sacktag_write_queue().
 		 */
@@ -2534,6 +2532,10 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	} else if (err != -EBUSY) {
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPRETRANSFAIL);
 	}
+
+	if (tp->undo_retrans < 0)
+		tp->undo_retrans = 0;
+	tp->undo_retrans += tcp_skb_pcount(skb);
 	return err;
 }
 
-- 
2.0.0.526.g5318336
