From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] tcp_send_skb code pruning
Date: Tue, 27 Apr 2004 16:04:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040427160428.0196fcf3@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The function tcp_send_skb is only called from tcp_fin, and is always called
with force_queue=1.  Therefore, it no longer needs to be global and the code
to send right now can be removed.  Because it always queues, change the
name as well, and fix up the comment.

diff -Nru a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h	Tue Apr 27 14:37:03 2004
+++ b/include/net/tcp.h	Tue Apr 27 14:37:03 2004
@@ -948,7 +948,6 @@
 extern void tcp_send_active_reset(struct sock *sk, int priority);
 extern int  tcp_send_synack(struct sock *);
 extern int  tcp_transmit_skb(struct sock *, struct sk_buff *);
-extern void tcp_send_skb(struct sock *, struct sk_buff *, int force_queue, unsigned mss_now);
 extern void tcp_push_one(struct sock *, unsigned mss_now);
 extern void tcp_send_ack(struct sock *sk);
 extern void tcp_send_delayed_ack(struct sock *sk);
diff -Nru a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c	Tue Apr 27 14:37:03 2004
+++ b/net/ipv4/tcp_output.c	Tue Apr 27 14:37:03 2004
@@ -314,13 +314,12 @@
 }
 
 
-/* This is the main buffer sending routine. We queue the buffer
- * and decide whether to queue or transmit now.
+/* This routine just queue's the buffer 
  *
  * NOTE: probe0 timer is not checked, do not forget tcp_push_pending_frames,
  * otherwise socket can stall.
  */
-void tcp_send_skb(struct sock *sk, struct sk_buff *skb, int force_queue, unsigned cur_mss)
+static void tcp_queue_skb(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_opt *tp = tcp_sk(sk);
 
@@ -329,17 +328,6 @@
 	__skb_queue_tail(&sk->sk_write_queue, skb);
 	tcp_charge_skb(sk, skb);
 
-	if (!force_queue && tp->send_head == NULL && tcp_snd_test(tp, skb, cur_mss, tp->nonagle)) {
-		/* Send it out now. */
-		TCP_SKB_CB(skb)->when = tcp_time_stamp;
-		if (!tcp_transmit_skb(sk, skb_clone(skb, sk->sk_allocation))) {
-			tp->snd_nxt = TCP_SKB_CB(skb)->end_seq;
-			tcp_minshall_update(tp, cur_mss, skb);
-			if (tp->packets_out++ == 0)
-				tcp_reset_xmit_timer(sk, TCP_TIME_RETRANS, tp->rto);
-			return;
-		}
-	}
 	/* Queue it, remembering where we must start sending. */
 	if (tp->send_head == NULL)
 		tp->send_head = skb;
@@ -1120,10 +1108,10 @@
 		TCP_SKB_CB(skb)->flags = (TCPCB_FLAG_ACK | TCPCB_FLAG_FIN);
 		TCP_SKB_CB(skb)->sacked = 0;
 
-		/* FIN eats a sequence byte, write_seq advanced by tcp_send_skb(). */
+		/* FIN eats a sequence byte, write_seq advanced by tcp_queue_skb(). */
 		TCP_SKB_CB(skb)->seq = tp->write_seq;
 		TCP_SKB_CB(skb)->end_seq = TCP_SKB_CB(skb)->seq + 1;
-		tcp_send_skb(sk, skb, 1, mss_now);
+		tcp_queue_skb(sk, skb);
 	}
 	__tcp_push_pending_frames(sk, tp, mss_now, TCP_NAGLE_OFF);
 }
