From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: the TSO packet mangling issue
Date: Thu, 27 Jan 2005 22:09:46 +1100
Message-ID: <20050127110946.GA20494@gondor.apana.org.au>
References: <20050121204024.6f94fc26.davem@davemloft.net> <20050122054346.GA1635@gondor.apana.org.au> <20050122170533.GB11499@yakov.inr.ac.ru> <20050123071027.GA20296@gondor.apana.org.au> <20050126110043.GA29950@yakov.inr.ac.ru> <20050126222522.GA21670@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="GvXjxJ+pjyke8COw"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20050126222522.GA21670@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--GvXjxJ+pjyke8COw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

OK, here are the patches to COW TSO packets before the TCP/TCP header
gets written over.

This one defines a new bit of dataref.  It's set just before a packet
joins the TCP write queue.  It's cleared after the packet is taken
off the queue and just before it's freed.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--GvXjxJ+pjyke8COw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=tso-mangle-1

===== include/linux/skbuff.h 1.59 vs edited =====
--- 1.59/include/linux/skbuff.h	2005-01-11 07:23:55 +11:00
+++ edited/include/linux/skbuff.h	2005-01-27 21:18:04 +11:00
@@ -134,6 +134,9 @@
 	__u16 size;
 };
 
+#define SKB_DATAREF_TCP 0x40000000
+#define SKB_DATAREF_MASK 0x3fffffff
+
 /* This data is invariant across clones and lives at
  * the end of the header data, ie. at skb->end.
  */
@@ -374,7 +377,8 @@
  */
 static inline int skb_cloned(const struct sk_buff *skb)
 {
-	return skb->cloned && atomic_read(&skb_shinfo(skb)->dataref) != 1;
+	return skb->cloned &&
+	       (atomic_read(&skb_shinfo(skb)->dataref) & SKB_DATAREF_MASK) != 1;
 }
 
 /**
===== include/net/tcp.h 1.103 vs edited =====
--- 1.103/include/net/tcp.h	2005-01-18 09:09:33 +11:00
+++ edited/include/net/tcp.h	2005-01-27 21:37:57 +11:00
@@ -1222,6 +1222,27 @@
 	return (tp->packets_out - tp->left_out + tp->retrans_out);
 }
 
+/* This marks the skb as owned by the TCP stack.  The TCP stack
+ * isn't fussy about others modifying the skb's content as long
+ * as they do so within the TCP/IP headers and leave the TCP
+ * payload alone.
+ */
+static inline void tcp_skb_hold(struct sk_buff *skb)
+{
+	atomic_add(SKB_DATAREF_TCP, &skb_shinfo(skb)->dataref);
+}
+
+static inline void tcp_skb_release(struct sk_buff *skb)
+{
+	atomic_sub(SKB_DATAREF_TCP, &skb_shinfo(skb)->dataref);
+}
+
+static inline void tcp_sk_stream_free_skb(struct sock *sk, struct sk_buff *skb)
+{
+	tcp_skb_release(skb);
+	sk_stream_free_skb(sk, skb);
+}
+
 /*
  * Which congestion algorithim is in use on the connection.
  */
===== net/ipv4/tcp.c 1.91 vs edited =====
--- 1.91/net/ipv4/tcp.c	2005-01-18 09:09:33 +11:00
+++ edited/net/ipv4/tcp.c	2005-01-27 21:28:57 +11:00
@@ -598,6 +598,7 @@
 	TCP_SKB_CB(skb)->end_seq = tp->write_seq;
 	TCP_SKB_CB(skb)->flags = TCPCB_FLAG_ACK;
 	TCP_SKB_CB(skb)->sacked = 0;
+	tcp_skb_hold(skb);
 	__skb_queue_tail(&sk->sk_write_queue, skb);
 	sk_charge_skb(sk, skb);
 	if (!sk->sk_send_head)
@@ -990,7 +991,7 @@
 		if (sk->sk_send_head == skb)
 			sk->sk_send_head = NULL;
 		__skb_unlink(skb, skb->list);
-		sk_stream_free_skb(sk, skb);
+		tcp_sk_stream_free_skb(sk, skb);
 	}
 
 do_error:
===== net/ipv4/tcp_input.c 1.89 vs edited =====
--- 1.89/net/ipv4/tcp_input.c	2005-01-18 09:09:33 +11:00
+++ edited/net/ipv4/tcp_input.c	2005-01-27 21:29:37 +11:00
@@ -2470,7 +2470,7 @@
 		tcp_dec_pcount_approx(&tp->fackets_out, skb);
 		tcp_packets_out_dec(tp, skb);
 		__skb_unlink(skb, skb->list);
-		sk_stream_free_skb(sk, skb);
+		tcp_sk_stream_free_skb(sk, skb);
 	}
 
 	if (acked&FLAG_ACKED) {
===== net/ipv4/tcp_output.c 1.77 vs edited =====
--- 1.77/net/ipv4/tcp_output.c	2005-01-19 07:23:36 +11:00
+++ edited/net/ipv4/tcp_output.c	2005-01-27 21:29:18 +11:00
@@ -400,6 +400,7 @@
 
 	/* Advance write_seq and place onto the write_queue. */
 	tp->write_seq = TCP_SKB_CB(skb)->end_seq;
+	tcp_skb_hold(skb);
 	__skb_queue_tail(&sk->sk_write_queue, skb);
 	sk_charge_skb(sk, skb);
 
@@ -960,7 +961,7 @@
 		 */
 		tcp_dec_pcount_approx(&tp->fackets_out, next_skb);
 		tcp_packets_out_dec(tp, next_skb);
-		sk_stream_free_skb(sk, next_skb);
+		tcp_sk_stream_free_skb(sk, next_skb);
 	}
 }
 
@@ -1327,8 +1328,9 @@
 			if (nskb == NULL)
 				return -ENOMEM;
 			__skb_unlink(skb, &sk->sk_write_queue);
+			tcp_skb_hold(nskb);
 			__skb_queue_head(&sk->sk_write_queue, nskb);
-			sk_stream_free_skb(sk, skb);
+			tcp_sk_stream_free_skb(sk, skb);
 			sk_charge_skb(sk, nskb);
 			skb = nskb;
 		}
@@ -1493,6 +1495,7 @@
 	/* Send it off. */
 	TCP_SKB_CB(buff)->when = tcp_time_stamp;
 	tp->retrans_stamp = TCP_SKB_CB(buff)->when;
+	tcp_skb_hold(buff);
 	__skb_queue_tail(&sk->sk_write_queue, buff);
 	sk_charge_skb(sk, buff);
 	tp->packets_out += tcp_skb_pcount(buff);

--GvXjxJ+pjyke8COw--
