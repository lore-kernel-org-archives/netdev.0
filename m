From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net 1/2] tcp: only undo on partial ACKs in CA_Loss
Date: Mon, 18 May 2015 12:31:44 -0700
Message-ID: <1431977505-15014-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:34868 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932083AbbERTcg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 15:32:36 -0400
Received: by igbyr2 with SMTP id yr2so57623846igb.0
        for <netdev@vger.kernel.org>; Mon, 18 May 2015 12:32:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Undo based on TCP timestamps should only happen on ACKs that advance
SND_UNA, according to the Eifel algorithm in RFC 3522:

Section 3.2:

  (4) If the value of the Timestamp Echo Reply field of the
      acceptable ACK's Timestamps option is smaller than the
      value of RetransmitTS, then proceed to step (5),

Section Terminology:
   We use the term 'acceptable ACK' as defined in [RFC793].  That is an
   ACK that acknowledges previously unacknowledged data.

This is because upon receiving an out-of-order packet, the receiver
returns the last timestamp that advances RCV_NXT, not the current
timestamp of the packet in the DUPACK. Without checking the flag,
the DUPACK will cause tcp_packet_delayed() to return true and
tcp_try_undo_loss() will revert cwnd reduction.

Note that we check the condition in CA_Recovery already by only
calling tcp_try_undo_partial() if FLAG_SND_UNA_ADVANCED is set or
tcp_try_undo_recovery() if snd_una crosses high_seq.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_input.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index bc790ea..9faf775 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2698,11 +2698,16 @@ static void tcp_process_loss(struct sock *sk, int flag, bool is_dupack)
 	struct tcp_sock *tp = tcp_sk(sk);
 	bool recovered = !before(tp->snd_una, tp->high_seq);
 
+	if ((flag & FLAG_SND_UNA_ADVANCED) &&
+	    tcp_try_undo_loss(sk, false))
+		return;
+
 	if (tp->frto) { /* F-RTO RFC5682 sec 3.1 (sack enhanced version). */
 		/* Step 3.b. A timeout is spurious if not all data are
 		 * lost, i.e., never-retransmitted data are (s)acked.
 		 */
-		if (tcp_try_undo_loss(sk, flag & FLAG_ORIG_SACK_ACKED))
+		if ((flag & FLAG_ORIG_SACK_ACKED) &&
+		    tcp_try_undo_loss(sk, true))
 			return;
 
 		if (after(tp->snd_nxt, tp->high_seq) &&
@@ -2732,8 +2737,6 @@ static void tcp_process_loss(struct sock *sk, int flag, bool is_dupack)
 		else if (flag & FLAG_SND_UNA_ADVANCED)
 			tcp_reset_reno_sack(tp);
 	}
-	if (tcp_try_undo_loss(sk, false))
-		return;
 	tcp_xmit_retransmit_queue(sk);
 }
 
-- 
2.2.0.rc0.207.ga3a616c
