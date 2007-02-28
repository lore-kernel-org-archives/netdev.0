From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/4]: Maintain cached fack counts in retransmit queue.
Date: Wed, 28 Feb 2007 11:49:30 -0800 (PST)
Message-ID: <20070228.114930.11959853.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48288
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751860AbXB1Ttb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Feb 2007 14:49:31 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id B655CAE426D
	for <netdev@vger.kernel.org>; Wed, 28 Feb 2007 11:49:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


commit 5fc24957defcc34df8fab6bf62bc1918e54607f8
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Tue Feb 27 17:23:52 2007 -0800

    [TCP]: Maintain cached fack counts in retransmit queue.
    
    The fack count of any skb in the retransmit queue at any
    given point in time is:
    
    	(skb->fack_count - head_skb->fack_count)
    
    And we'll use this in the SACK processing loops.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/tcp.h b/include/net/tcp.h
index cce6b0e..80a572b 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -532,6 +532,7 @@ struct tcp_skb_cb {
 	__u32		seq;		/* Starting sequence number	*/
 	__u32		end_seq;	/* SEQ + FIN + SYN + datalen	*/
 	__u32		when;		/* used to compute rtt's	*/
+	unsigned int	fack_count;	/* speed up SACK processing	*/
 	__u8		flags;		/* TCP header flags.		*/
 
 	/* NOTE: These must match up to the flags byte in a
@@ -1272,6 +1273,12 @@ static inline void tcp_rb_unlink(struct sk_buff *skb, struct rb_root *root)
 
 static inline void __tcp_add_write_queue_tail(struct sock *sk, struct sk_buff *skb)
 {
+	struct sk_buff *tail = tcp_write_queue_tail(sk);
+	unsigned int fc = 0;
+
+	if (tail)
+		fc = TCP_SKB_CB(tail)->fack_count + tcp_skb_pcount(skb);
+	TCP_SKB_CB(skb)->fack_count = fc;
 	__skb_queue_tail(&sk->sk_write_queue, skb);
 	tcp_rb_insert(skb, &tcp_sk(sk)->write_queue_rb);
 }
@@ -1285,18 +1292,44 @@ static inline void tcp_add_write_queue_tail(struct sock *sk, struct sk_buff *skb
 		sk->sk_send_head = skb;
 }
 
+/* This is only used for tcp_send_synack(), so the write queue should
+ * be empty.  If that stops being true, the fack_count assignment
+ * will need to be more elaborate.
+ */
 static inline void __tcp_add_write_queue_head(struct sock *sk, struct sk_buff *skb)
 {
+	BUG_ON(!skb_queue_empty(&sk->sk_write_queue));
 	__skb_queue_head(&sk->sk_write_queue, skb);
+	TCP_SKB_CB(skb)->fack_count = 0;
 	tcp_rb_insert(skb, &tcp_sk(sk)->write_queue_rb);
 }
 
+/* An insert into the middle of the write queue causes the fack
+ * counts in subsequent packets to become invalid, fix them up.
+ */
+static inline void tcp_reset_fack_counts(struct sock *sk, struct sk_buff *first)
+{
+	struct sk_buff *prev = first->prev;
+	unsigned int fc = 0;
+
+	if (prev != (struct sk_buff *) &sk->sk_write_queue)
+		fc = TCP_SKB_CB(prev)->fack_count + tcp_skb_pcount(prev);
+
+	while (first != (struct sk_buff *)&sk->sk_write_queue) {
+		TCP_SKB_CB(first)->fack_count = fc;
+
+		fc += tcp_skb_pcount(first);
+		first = first->next;
+	}
+}
+
 /* Insert buff after skb on the write queue of sk.  */
 static inline void tcp_insert_write_queue_after(struct sk_buff *skb,
 						struct sk_buff *buff,
 						struct sock *sk)
 {
 	__skb_append(skb, buff, &sk->sk_write_queue);
+	tcp_reset_fack_counts(sk, buff);
 	tcp_rb_insert(skb, &tcp_sk(sk)->write_queue_rb);
 }
 
@@ -1306,6 +1339,7 @@ static inline void tcp_insert_write_queue_before(struct sk_buff *new,
 						  struct sock *sk)
 {
 	__skb_insert(new, skb->prev, skb, &sk->sk_write_queue);
+	tcp_reset_fack_counts(sk, new);
 	tcp_rb_insert(skb, &tcp_sk(sk)->write_queue_rb);
 }
 
