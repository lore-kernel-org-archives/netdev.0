From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net] tcp: fix bogus RTT on special retransmission
Date: Fri, 28 Feb 2014 16:42:26 -0800
Message-ID: <1393634546-18802-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com,
	nanditad@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f201.google.com ([209.85.214.201]:41608 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751838AbaCAAmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 19:42:44 -0500
Received: by mail-ob0-f201.google.com with SMTP id gq1so935030obb.4
        for <netdev@vger.kernel.org>; Fri, 28 Feb 2014 16:42:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RTT may be bogus with tall loss probe (TLP) when a packet
is retransmitted and latter (s)acked without TCPCB_SACKED_RETRANS flag.

For example, TLP calls __tcp_retransmit_skb() instead of
tcp_retransmit_skb(). The skb timestamps are updated but the sacked
flag is not marked with TCPCB_SACKED_RETRANS. As a result we'll
get bogus RTT in tcp_clean_rtx_queue() or in tcp_sacktag_one() on
spurious retransmission.

The fix is to apply the sticky flag TCP_EVER_RETRANS to enforce Karn's
check on RTT sampling. However this will disable F-RTO if timeout occurs
after TLP, by resetting undo_marker in tcp_enter_loss(). We relax this
check to only if any pending retransmists are still in-flight.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c  |  3 ++-
 net/ipv4/tcp_output.c | 11 ++++++++---
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 227cba7..eeaac39 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1945,8 +1945,9 @@ void tcp_enter_loss(struct sock *sk, int how)
 		if (skb == tcp_send_head(sk))
 			break;
 
-		if (TCP_SKB_CB(skb)->sacked & TCPCB_RETRANS)
+		if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS)
 			tp->undo_marker = 0;
+
 		TCP_SKB_CB(skb)->sacked &= (~TCPCB_TAGBITS)|TCPCB_SACKED_ACKED;
 		if (!(TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_ACKED) || how) {
 			TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_ACKED;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index d718482..f0eb4e3 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2337,6 +2337,7 @@ int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	unsigned int cur_mss;
+	int err;
 
 	/* Inconslusive MTU probe */
 	if (icsk->icsk_mtup.probe_size) {
@@ -2400,11 +2401,15 @@ int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 		     skb_headroom(skb) >= 0xFFFF)) {
 		struct sk_buff *nskb = __pskb_copy(skb, MAX_TCP_HEADER,
 						   GFP_ATOMIC);
-		return nskb ? tcp_transmit_skb(sk, nskb, 0, GFP_ATOMIC) :
-			      -ENOBUFS;
+		err = nskb ? tcp_transmit_skb(sk, nskb, 0, GFP_ATOMIC) :
+			     -ENOBUFS;
 	} else {
-		return tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
+		err = tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
 	}
+
+	if (likely(!err))
+		TCP_SKB_CB(skb)->sacked |= TCPCB_EVER_RETRANS;
+	return err;
 }
 
 int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
-- 
1.9.0.279.gdc9e3eb
