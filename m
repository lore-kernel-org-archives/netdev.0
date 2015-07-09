From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next 3/3] tcp: update congestion state first before raising cwnd
Date: Thu,  9 Jul 2015 13:16:31 -0700
Message-ID: <1436472991-16056-4-git-send-email-ycheng@google.com>
References: <1436472991-16056-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Van Jacobson <vanj@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:33264 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752262AbbGIUR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 16:17:29 -0400
Received: by ietj16 with SMTP id j16so10915879iet.0
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 13:17:29 -0700 (PDT)
In-Reply-To: <1436472991-16056-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The congestion state and cwnd can be updated in the wrong order.
For example, upon receiving a dubious ACK, we incorrectly raise
the cwnd first (tcp_may_raise_cwnd()/tcp_cong_avoid()) because
the state is still Open, then enter recovery state to reduce cwnd.

For another example, if the ACK indicates spurious timeout or
retransmits, we first revert the cwnd reduction and congestion
state back to Open state.  But we don't raise the cwnd even though
the ACK does not indicate any congestion.

To fix this problem we should first call tcp_fastretrans_alert() to
process the dubious ACK and update the congestion state, then call
tcp_may_raise_cwnd() that raises cwnd based on the current state.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Nandita Dukkipati <nanditad@google.com>
---
 net/ipv4/tcp_input.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index ad1482d..a6bbe0f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3566,10 +3566,6 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 				    &sack_state);
 	acked -= tp->packets_out;
 
-	/* Advance cwnd if state allows */
-	if (tcp_may_raise_cwnd(sk, flag))
-		tcp_cong_avoid(sk, ack, acked);
-
 	if (tcp_ack_is_dubious(sk, flag)) {
 		is_dupack = !(flag & (FLAG_SND_UNA_ADVANCED | FLAG_NOT_DUP));
 		tcp_fastretrans_alert(sk, acked, prior_unsacked,
@@ -3578,6 +3574,10 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	if (tp->tlp_high_seq)
 		tcp_process_tlp_ack(sk, ack, flag);
 
+	/* Advance cwnd if state allows */
+	if (tcp_may_raise_cwnd(sk, flag))
+		tcp_cong_avoid(sk, ack, acked);
+
 	if ((flag & FLAG_FORWARD_PROGRESS) || !(flag & FLAG_NOT_DUP)) {
 		struct dst_entry *dst = __sk_dst_get(sk);
 		if (dst)
-- 
2.4.3.573.g4eafbef
