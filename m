From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 4/5] net: tcp: more detailed ACK events, and events for CE marked packets
Date: Mon, 12 May 2014 22:59:43 +0200
Message-ID: <1399928384-24143-5-git-send-email-fw@strlen.de>
References: <1399928384-24143-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Glenn Judd <glenn.judd@morganstanley.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:56535 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753658AbaELVfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 17:35:51 -0400
In-Reply-To: <1399928384-24143-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DataCenter TCP (DCTCP) determines cwnd growth based on ECN information
and ACK properties, e.g. ACK that updates window is treated differently
than DUPACK.

Also DCTCP needs information whether ACK was delayed ACK. Furthermore,
DCTCP also implements a CE state machine that keeps track of CE markings
of incoming packets.

Therefore, extend the congestion control framework to provide these
event types, so that DCTCP can be properly implemented as a normal
congestion algorithm module outside the core stack.

Joint work with Daniel Borkmann and Glenn Judd.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Glenn Judd <glenn.judd@morganstanley.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/tcp.h     |  9 ++++++++-
 net/ipv4/tcp_input.c  | 22 ++++++++++++++++++----
 net/ipv4/tcp_output.c |  4 ++++
 3 files changed, 30 insertions(+), 5 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 0d767d2..56bf383 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -754,10 +754,17 @@ enum tcp_ca_event {
 	CA_EVENT_CWND_RESTART,	/* congestion window restart */
 	CA_EVENT_COMPLETE_CWR,	/* end of congestion recovery */
 	CA_EVENT_LOSS,		/* loss timeout */
+	CA_EVENT_ECN_NO_CE,	/* ECT set, but not CE marked */
+	CA_EVENT_ECN_IS_CE,	/* received CE marked IP packet */
+	CA_EVENT_DELAYED_ACK,	/* Delayed ack is sent */
+	CA_EVENT_NON_DELAYED_ACK,
 };
 
+/* information about inbound ACK, passed to cong_ops->in_ack_event() */
 enum tcp_ca_ack_event_flags {
-	CA_ACK_SLOWPATH = (1 << 0),
+	CA_ACK_SLOWPATH		= (1 << 0),	/* in slow path processing */
+	CA_ACK_WIN_UPDATE	= (1 << 1),	/* ACK updated window */
+	CA_ACK_ECE		= (1 << 2),	/* ECE bit is set on ack */
 };
 
 /*
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 7fab1da..bf0f734 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -232,14 +232,21 @@ static inline void TCP_ECN_check_ce(struct tcp_sock *tp, const struct sk_buff *s
 			tcp_enter_quickack_mode((struct sock *)tp);
 		break;
 	case INET_ECN_CE:
+		if (tcp_ca_needs_ecn((struct sock *)tp))
+			tcp_ca_event((struct sock *)tp, CA_EVENT_ECN_IS_CE);
+
 		if (!(tp->ecn_flags & TCP_ECN_DEMAND_CWR)) {
 			/* Better not delay acks, sender can have a very low cwnd */
 			tcp_enter_quickack_mode((struct sock *)tp);
 			tp->ecn_flags |= TCP_ECN_DEMAND_CWR;
 		}
-		/* fallinto */
+		tp->ecn_flags |= TCP_ECN_SEEN;
+		break;
 	default:
+		if (tcp_ca_needs_ecn((struct sock *)tp))
+			tcp_ca_event((struct sock *)tp, CA_EVENT_ECN_NO_CE);
 		tp->ecn_flags |= TCP_ECN_SEEN;
+		break;
 	}
 }
 
@@ -3421,10 +3428,12 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 		tp->snd_una = ack;
 		flag |= FLAG_WIN_UPDATE;
 
-		tcp_in_ack_event(sk, 0);
+		tcp_in_ack_event(sk, CA_ACK_WIN_UPDATE);
 
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPHPACKS);
 	} else {
+		u32 ack_ev_flags = CA_ACK_SLOWPATH;
+
 		if (ack_seq != TCP_SKB_CB(skb)->end_seq)
 			flag |= FLAG_DATA;
 		else
@@ -3436,10 +3445,15 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 			flag |= tcp_sacktag_write_queue(sk, skb, prior_snd_una,
 							&sack_rtt_us);
 
-		if (TCP_ECN_rcv_ecn_echo(tp, tcp_hdr(skb)))
+		if (TCP_ECN_rcv_ecn_echo(tp, tcp_hdr(skb))) {
 			flag |= FLAG_ECE;
+			ack_ev_flags |= CA_ACK_ECE;
+		}
+
+		if (flag & FLAG_WIN_UPDATE)
+			ack_ev_flags |= CA_ACK_WIN_UPDATE;
 
-		tcp_in_ack_event(sk, CA_ACK_SLOWPATH);
+		tcp_in_ack_event(sk, ack_ev_flags);
 	}
 
 	/* We passed data and got it acked, remove any soft error
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 1f983dd..1f5e04a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3119,6 +3119,8 @@ void tcp_send_delayed_ack(struct sock *sk)
 	int ato = icsk->icsk_ack.ato;
 	unsigned long timeout;
 
+	tcp_ca_event(sk, CA_EVENT_DELAYED_ACK);
+
 	if (ato > TCP_DELACK_MIN) {
 		const struct tcp_sock *tp = tcp_sk(sk);
 		int max_ato = HZ / 2;
@@ -3175,6 +3177,8 @@ void tcp_send_ack(struct sock *sk)
 	if (sk->sk_state == TCP_CLOSE)
 		return;
 
+	tcp_ca_event(sk, CA_EVENT_NON_DELAYED_ACK);
+
 	/* We are not putting this on the write queue, so
 	 * tcp_transmit_skb() will set the ownership to this
 	 * sock.
-- 
1.8.1.5
