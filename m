From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: ECN blackhole should not force quickack mode
Date: Fri, 23 Sep 2011 08:02:19 +0200
Message-ID: <1316757739.2560.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Jerry Chu <hkchu@google.com>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Jim Gettys <jg@freedesktop.org>,
	Dave Taht <dave.taht@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33233 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751959Ab1IWGCb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2011 02:02:31 -0400
Received: by wyg34 with SMTP id 34so3635036wyg.19
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2011 23:02:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While playing with a new ADSL box at home, I discovered that ECN
blackhole can trigger suboptimal quickack mode on linux : We send one
ACK for each incoming data frame, without any delay and eventual
piggyback.

This is because TCP_ECN_check_ce() considers that if no ECT is seen on =
a
segment, this is because this segment was a retransmit.

Refine this heuristic and apply it only if we seen ECT in a previous
segment, to detect ECN blackhole at IP level.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Jamal Hadi Salim <jhs@mojatatu.com>
CC: Jerry Chu <hkchu@google.com>
CC: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
CC: Jim Gettys <jg@freedesktop.org>
CC: Dave Taht <dave.taht@gmail.com>
---
Another possibility is to remove this (not in RFC 3168) heuristic, what
do you think ?

 include/net/tcp.h    |    1 +
 net/ipv4/tcp_input.c |   23 ++++++++++++++++-------
 2 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index f357bef..702aefc 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -356,6 +356,7 @@ static inline void tcp_dec_quickack_mode(struct soc=
k *sk,
 #define	TCP_ECN_OK		1
 #define	TCP_ECN_QUEUE_CWR	2
 #define	TCP_ECN_DEMAND_CWR	4
+#define	TCP_ECN_SEEN		8
=20
 static __inline__ void
 TCP_ECN_create_request(struct request_sock *req, struct tcphdr *th)
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a5d01b1..5a4408c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -217,16 +217,25 @@ static inline void TCP_ECN_withdraw_cwr(struct tc=
p_sock *tp)
 	tp->ecn_flags &=3D ~TCP_ECN_DEMAND_CWR;
 }
=20
-static inline void TCP_ECN_check_ce(struct tcp_sock *tp, struct sk_buf=
f *skb)
+static inline void TCP_ECN_check_ce(struct tcp_sock *tp, const struct =
sk_buff *skb)
 {
-	if (tp->ecn_flags & TCP_ECN_OK) {
-		if (INET_ECN_is_ce(TCP_SKB_CB(skb)->flags))
-			tp->ecn_flags |=3D TCP_ECN_DEMAND_CWR;
+	if (!(tp->ecn_flags & TCP_ECN_OK))
+		return;
+
+	switch (TCP_SKB_CB(skb)->flags & INET_ECN_MASK) {
+	case INET_ECN_NOT_ECT:
 		/* Funny extension: if ECT is not set on a segment,
-		 * it is surely retransmit. It is not in ECN RFC,
-		 * but Linux follows this rule. */
-		else if (INET_ECN_is_not_ect((TCP_SKB_CB(skb)->flags)))
+		 * and we already seen ECT on a previous segment,
+		 * it is probably a retransmit.
+		 */
+		if (tp->ecn_flags & TCP_ECN_SEEN)
 			tcp_enter_quickack_mode((struct sock *)tp);
+		break;
+	case INET_ECN_CE:
+		tp->ecn_flags |=3D TCP_ECN_DEMAND_CWR;
+		/* fallinto */
+	default:
+		tp->ecn_flags |=3D TCP_ECN_SEEN;
 	}
 }
=20
