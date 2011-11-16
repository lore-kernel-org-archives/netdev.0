From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH 4/5] tcp: allow undo from reordered DSACKs
Date: Wed, 16 Nov 2011 13:58:04 -0500
Message-ID: <1321469885-10885-4-git-send-email-ncardwell@google.com>
References: <1321469885-10885-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f74.google.com ([74.125.82.74]:55050 "EHLO
	mail-ww0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085Ab1KPTE7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 14:04:59 -0500
Received: by wwe5 with SMTP id 5so19592wwe.1
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2011 11:04:58 -0800 (PST)
In-Reply-To: <1321469885-10885-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously, SACK-enabled connections hung around in TCP_CA_Disorder
state while snd_una==high_seq, just waiting to accumulate DSACKs and
hopefully undo a cwnd reduction. This could and did lead to the
following unfortunate scenario: if some incoming ACKs advance snd_una
beyond high_seq then we were setting undo_marker to 0 and moving to
TCP_CA_Open, so if (due to reordering in the ACK return path) we
shortly thereafter received a DSACK then we were no longer able to
undo the cwnd reduction.

The change: Simplify the congestion avoidance state machine by
removing the behavior where SACK-enabled connections hung around in
the TCP_CA_Disorder state just waiting for DSACKs. Instead, when
snd_una advances to high_seq or beyond we typically move to
TCP_CA_Open immediately and allow an undo in either TCP_CA_Open or
TCP_CA_Disorder if we later receive enough DSACKs.

Other patches in this series will provide other changes that are
necessary to fully fix this problem.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_input.c |   15 ++-------------
 1 files changed, 2 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 751d390..a4efdd7 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2858,7 +2858,7 @@ static void tcp_try_keep_open(struct sock *sk)
 	struct tcp_sock *tp = tcp_sk(sk);
 	int state = TCP_CA_Open;
 
-	if (tcp_left_out(tp) || tcp_any_retrans_done(sk) || tp->undo_marker)
+	if (tcp_left_out(tp) || tcp_any_retrans_done(sk))
 		state = TCP_CA_Disorder;
 
 	if (inet_csk(sk)->icsk_ca_state != state) {
@@ -3066,17 +3066,6 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
 			}
 			break;
 
-		case TCP_CA_Disorder:
-			tcp_try_undo_dsack(sk);
-			if (!tp->undo_marker ||
-			    /* For SACK case do not Open to allow to undo
-			     * catching for all duplicate ACKs. */
-			    tcp_is_reno(tp) || tp->snd_una != tp->high_seq) {
-				tp->undo_marker = 0;
-				tcp_set_ca_state(sk, TCP_CA_Open);
-			}
-			break;
-
 		case TCP_CA_Recovery:
 			if (tcp_is_reno(tp))
 				tcp_reset_reno_sack(tp);
@@ -3117,7 +3106,7 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
 				tcp_add_reno_sack(sk);
 		}
 
-		if (icsk->icsk_ca_state == TCP_CA_Disorder)
+		if (icsk->icsk_ca_state <= TCP_CA_Disorder)
 			tcp_try_undo_dsack(sk);
 
 		if (!tcp_time_to_recover(sk)) {
-- 
1.7.3.1
