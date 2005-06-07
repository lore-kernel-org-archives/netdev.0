From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 2/9]: TCP: The Road to Super TSO
Date: Mon, 06 Jun 2005 21:17:08 -0700 (PDT)
Message-ID: <20050606.211708.63132555.davem@davemloft.net>
References: <20050606.210846.07641049.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jheffner@psc.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050606.210846.07641049.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


[TCP]: Fix quick-ack decrementing with TSO.

On each packet output, we call tcp_dec_quickack_mode()
if the ACK flag is set.  It drops tp->ack.quick until
it hits zero, at which time we deflate the ATO value.

When doing TSO, we are emitting multiple packets with
ACK set, so we should decrement tp->ack.quick that many
segments.

Note that, unlike this case, tcp_enter_cwr() should not
take the tcp_skb_pcount(skb) into consideration.  That
function, one time, readjusts tp->snd_cwnd and moves
into TCP_CA_CWR state.

Signed-off-by: David S. Miller <davem@davemloft.net>

00cb08b2ec091f4b461210026392edeaccf31d9c (from 28f78ef8dcc90a2a26499dab76678bd6813d7793)
diff --git a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -817,11 +817,16 @@ static inline int tcp_ack_scheduled(stru
 	return tp->ack.pending&TCP_ACK_SCHED;
 }
 
-static __inline__ void tcp_dec_quickack_mode(struct tcp_sock *tp)
+static __inline__ void tcp_dec_quickack_mode(struct tcp_sock *tp, unsigned int pkts)
 {
-	if (tp->ack.quick && --tp->ack.quick == 0) {
-		/* Leaving quickack mode we deflate ATO. */
-		tp->ack.ato = TCP_ATO_MIN;
+	if (tp->ack.quick) {
+		if (pkts >= tp->ack.quick) {
+			tp->ack.quick = 0;
+
+			/* Leaving quickack mode we deflate ATO. */
+			tp->ack.ato = TCP_ATO_MIN;
+		} else
+			tp->ack.quick -= pkts;
 	}
 }
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -141,11 +141,11 @@ static inline void tcp_event_data_sent(s
 		tp->ack.pingpong = 1;
 }
 
-static __inline__ void tcp_event_ack_sent(struct sock *sk)
+static __inline__ void tcp_event_ack_sent(struct sock *sk, unsigned int pkts)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	tcp_dec_quickack_mode(tp);
+	tcp_dec_quickack_mode(tp, pkts);
 	tcp_clear_xmit_timer(sk, TCP_TIME_DACK);
 }
 
@@ -361,7 +361,7 @@ static int tcp_transmit_skb(struct sock 
 		tp->af_specific->send_check(sk, th, skb->len, skb);
 
 		if (tcb->flags & TCPCB_FLAG_ACK)
-			tcp_event_ack_sent(sk);
+			tcp_event_ack_sent(sk, tcp_skb_pcount(skb));
 
 		if (skb->len != tcp_header_size)
 			tcp_event_data_sent(tp, skb, sk);
