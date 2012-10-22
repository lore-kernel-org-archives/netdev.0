From: "H.K. Jerry Chu" <hkchu@google.com>
Subject: [PATCH] tcp: Reject invalid ack_seq to Fast Open sockets
Date: Mon, 22 Oct 2012 14:26:36 -0700
Message-ID: <1350941196-31224-1-git-send-email-hkchu@google.com>
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com,
	Jerry Chu <hkchu@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:33704 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755742Ab2JVV2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 17:28:18 -0400
Received: by mail-yh0-f74.google.com with SMTP id 10so398254yhl.1
        for <netdev@vger.kernel.org>; Mon, 22 Oct 2012 14:28:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jerry Chu <hkchu@google.com>

A packet with an invalid ack_seq may cause a TCP Fast Open socket to switch
to the unexpected TCP_CLOSING state, triggering a BUG_ON kernel panic.

When a FIN packet with an invalid ack_seq# arrives at a socket in
the TCP_FIN_WAIT1 state, rather than discarding the packet, the current
code will accept the FIN, causing state transition to TCP_CLOSING.

This may be a small deviation from RFC793, which seems to say that the
packet should be dropped. Unfortunately I did not expect this case for
Fast Open hence it will trigger a BUG_ON panic.

It turns out there is really nothing bad about a TFO socket going into
TCP_CLOSING state so I could just remove the BUG_ON statements. But after
some thought I think it's better to treat this case like TCP_SYN_RECV
and return a RST to the confused peer who caused the unacceptable ack_seq
to be generated in the first place.

Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c |   12 ++++++++++--
 net/ipv4/tcp_timer.c |    2 +-
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 60cf836..ce3e3c7 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5970,7 +5970,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 
 	req = tp->fastopen_rsk;
 	if (req != NULL) {
-		BUG_ON(sk->sk_state != TCP_SYN_RECV &&
+		WARN_ON_ONCE(sk->sk_state != TCP_SYN_RECV &&
 		    sk->sk_state != TCP_FIN_WAIT1);
 
 		if (tcp_check_req(sk, skb, req, NULL, true) == NULL)
@@ -6059,7 +6059,15 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 			 * ACK we have received, this would have acknowledged
 			 * our SYNACK so stop the SYNACK timer.
 			 */
-			if (acceptable && req != NULL) {
+			if (req != NULL) {
+				/* Return RST if ack_seq is invalid.
+				 * Note that RFC793 only says to generate a
+				 * DUPACK for it but for TCP Fast Open it seems
+				 * better to treat this case like TCP_SYN_RECV
+				 * above.
+				 */
+				if (!acceptable)
+					return 1;
 				/* We no longer need the request sock. */
 				reqsk_fastopen_remove(sk, req, false);
 				tcp_rearm_rto(sk);
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index fc04711..a24f4a4 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -347,7 +347,7 @@ void tcp_retransmit_timer(struct sock *sk)
 		return;
 	}
 	if (tp->fastopen_rsk) {
-		BUG_ON(sk->sk_state != TCP_SYN_RECV &&
+		WARN_ON_ONCE(sk->sk_state != TCP_SYN_RECV &&
 		    sk->sk_state != TCP_FIN_WAIT1);
 		tcp_fastopen_synack_timer(sk);
 		/* Before we receive ACK to our SYN-ACK don't retransmit
-- 
1.7.7.3
