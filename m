From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 4/9]: TCP: The Road to Super TSO
Date: Mon, 06 Jun 2005 21:18:52 -0700 (PDT)
Message-ID: <20050606.211852.55512928.davem@davemloft.net>
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


[TCP]: Move __tcp_data_snd_check into tcp_output.c

It reimplements portions of tcp_snd_check(), so it
we move it to tcp_output.c we can consolidate it's
logic much easier in a later change.

Signed-off-by: David S. Miller <davem@davemloft.net>

bdbf09522de5be3ada129dceaa3ad9da9be078bc (from cba5d690f46699d37df7dc087247d1f7c7155692)
diff --git a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -945,6 +945,7 @@ extern __u32 cookie_v4_init_sequence(str
 /* tcp_output.c */
 
 extern int tcp_write_xmit(struct sock *, int nonagle);
+extern void __tcp_data_snd_check(struct sock *sk, struct sk_buff *skb);
 extern void __tcp_push_pending_frames(struct sock *sk, struct tcp_sock *tp,
 				      unsigned cur_mss, int nonagle);
 extern int tcp_may_send_now(struct sock *sk, struct tcp_sock *tp);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3975,16 +3975,6 @@ static inline void tcp_check_space(struc
 	}
 }
 
-static void __tcp_data_snd_check(struct sock *sk, struct sk_buff *skb)
-{
-	struct tcp_sock *tp = tcp_sk(sk);
-
-	if (after(TCP_SKB_CB(skb)->end_seq, tp->snd_una + tp->snd_wnd) ||
-	    tcp_packets_in_flight(tp) >= tp->snd_cwnd ||
-	    tcp_write_xmit(sk, tp->nonagle))
-		tcp_check_probe_timer(sk, tp);
-}
-
 static __inline__ void tcp_data_snd_check(struct sock *sk)
 {
 	struct sk_buff *skb = sk->sk_send_head;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -536,6 +536,16 @@ void __tcp_push_pending_frames(struct so
 	tcp_cwnd_validate(sk, tp);
 }
 
+void __tcp_data_snd_check(struct sock *sk, struct sk_buff *skb)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	if (after(TCP_SKB_CB(skb)->end_seq, tp->snd_una + tp->snd_wnd) ||
+	    tcp_packets_in_flight(tp) >= tp->snd_cwnd ||
+	    tcp_write_xmit(sk, tp->nonagle))
+		tcp_check_probe_timer(sk, tp);
+}
+
 int tcp_may_send_now(struct sock *sk, struct tcp_sock *tp)
 {
 	struct sk_buff *skb = sk->sk_send_head;
