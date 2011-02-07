From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH] tcp: undo_retrans counter fixes
Date: Mon,  7 Feb 2011 14:57:04 -0800
Message-ID: <1297119424-19956-1-git-send-email-ycheng@google.com>
Cc: ilpo.jarvinen@helsinki.fi, Yuchung Cheng <ycheng@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:19973 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755093Ab1BGW5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Feb 2011 17:57:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a bug that undo_retrans is incorrectly decremented when undo_marker is
not set or undo_retrans is already 0. This happens when sender receives
more DSACK ACKs than packets retransmitted during the current
undo phase. This may also happen when sender receives DSACK after
the undo operation is completed or cancelled.

Fix another bug that undo_retrans is incorrectly incremented when
sender retransmits an skb and tcp_skb_pcount(skb) > 1 (TSO). This case
is rare but not impossible.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c  |    5 +++--
 net/ipv4/tcp_output.c |    2 +-
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2f692ce..08ea735 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1222,7 +1222,7 @@ static int tcp_check_dsack(struct sock *sk, struct sk_buff *ack_skb,
 	}
 
 	/* D-SACK for already forgotten data... Do dumb counting. */
-	if (dup_sack &&
+	if (dup_sack && tp->undo_marker && tp->undo_retrans &&
 	    !after(end_seq_0, prior_snd_una) &&
 	    after(end_seq_0, tp->undo_marker))
 		tp->undo_retrans--;
@@ -1299,7 +1299,8 @@ static u8 tcp_sacktag_one(struct sk_buff *skb, struct sock *sk,
 
 	/* Account D-SACK for retransmitted packet. */
 	if (dup_sack && (sacked & TCPCB_RETRANS)) {
-		if (after(TCP_SKB_CB(skb)->end_seq, tp->undo_marker))
+		if (tp->undo_marker && tp->undo_retrans &&
+		    after(TCP_SKB_CB(skb)->end_seq, tp->undo_marker))
 			tp->undo_retrans--;
 		if (sacked & TCPCB_SACKED_ACKED)
 			state->reord = min(fack_count, state->reord);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 406f320..dfa5beb 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2162,7 +2162,7 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 		if (!tp->retrans_stamp)
 			tp->retrans_stamp = TCP_SKB_CB(skb)->when;
 
-		tp->undo_retrans++;
+		tp->undo_retrans += tcp_skb_pcount(skb);
 
 		/* snd_nxt is stored to detect loss of retransmitted segment,
 		 * see tcp_input.c tcp_sacktag_write_queue().
-- 
1.7.3.1

