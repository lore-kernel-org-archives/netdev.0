From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [1/2] [NET] Add skb_header_release and use it in net/ipv4/tcp
Date: Sat, 29 Jan 2005 14:17:40 +1100
Message-ID: <20050129031740.GA6130@gondor.apana.org.au>
References: <20050121204024.6f94fc26.davem@davemloft.net> <20050122054346.GA1635@gondor.apana.org.au> <20050122170533.GB11499@yakov.inr.ac.ru> <20050123071027.GA20296@gondor.apana.org.au> <20050126110043.GA29950@yakov.inr.ac.ru> <20050126222522.GA21670@gondor.apana.org.au> <20050127110946.GA20494@gondor.apana.org.au> <20050127111201.GB20494@gondor.apana.org.au> <20050128202542.GA23670@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="VbJkn9YxBvnuCH5J"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20050128202542.GA23670@yakov.inr.ac.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--VbJkn9YxBvnuCH5J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Jan 28, 2005 at 11:25:42PM +0300, Alexey Kuznetsov wrote:
> 
> Actually, I would prefer to unbind this from tcp, it can be used
> for something else, sctp or anything else who sends clones of skbs
> and wants to protect only data part.

Good point.  Let's generalise it into a counter as well.

This patch adds skb_header_release which can be called when the owner
of an skb no longer needs to access the header at all.  What constitutes
the header is left up to the users of the skb to define.

For instance, for outbound TCP packets we define the header to be
anything in front of the TCP payload.  Therefore we add skb_header_release
calls to all the paths where outound TCP packets are produced.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--VbJkn9YxBvnuCH5J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=tso-mangle-1

===== include/linux/skbuff.h 1.59 vs edited =====
--- 1.59/include/linux/skbuff.h	2005-01-11 07:23:55 +11:00
+++ edited/include/linux/skbuff.h	2005-01-29 13:58:24 +11:00
@@ -146,6 +146,20 @@
 	skb_frag_t	frags[MAX_SKB_FRAGS];
 };
 
+/* We divide dataref into two halves.  The higher 16 bits hold references
+ * to the payload part of skb->data.  The lower 16 bits hold references to
+ * the entire skb->data.  It is up to the users of the skb to agree on
+ * where the payload starts.
+ *
+ * All users must obey the rule that the skb->data reference count must be
+ * greater than or equal to the payload reference count.
+ *
+ * Holding a reference to the payload part means that the user does not
+ * care about modifications to the header part of skb->data.
+ */
+#define SKB_DATAREF_SHIFT 16
+#define SKB_DATAREF_MASK ((1 << SKB_DATAREF_SHIFT) - 1)
+
 /** 
  *	struct sk_buff - socket buffer
  *	@next: Next buffer in list
@@ -167,6 +181,7 @@
  *	@csum: Checksum
  *	@__unused: Dead field, may be reused
  *	@cloned: Head may be cloned (check refcnt to be sure)
+ *	@nohdr: Payload reference only, must not modify header
  *	@pkt_type: Packet class
  *	@ip_summed: Driver fed us an IP checksum
  *	@priority: Packet queueing priority
@@ -238,7 +253,8 @@
 				mac_len,
 				csum;
 	unsigned char		local_df,
-				cloned,
+				cloned:1,
+				nohdr:1,
 				pkt_type,
 				ip_summed;
 	__u32			priority;
@@ -374,7 +390,23 @@
  */
 static inline int skb_cloned(const struct sk_buff *skb)
 {
-	return skb->cloned && atomic_read(&skb_shinfo(skb)->dataref) != 1;
+	return skb->cloned &&
+	       (atomic_read(&skb_shinfo(skb)->dataref) & SKB_DATAREF_MASK) != 1;
+}
+
+/**
+ *	skb_header_release - release reference to header
+ *	@skb: buffer to operate on
+ *
+ *	Drop a reference to the header part of the buffer.  This is done
+ *	by acquiring a payload reference.  You must not read from the header
+ *	part of skb->data after this.
+ */
+static inline void skb_header_release(struct sk_buff *skb)
+{
+	BUG_ON(skb->nohdr);
+	skb->nohdr = 1;
+	atomic_add(1 << SKB_DATAREF_SHIFT, &skb_shinfo(skb)->dataref);
 }
 
 /**
===== net/core/skbuff.c 1.41 vs edited =====
--- 1.41/net/core/skbuff.c	2004-12-02 16:49:52 +11:00
+++ edited/net/core/skbuff.c	2005-01-29 13:49:41 +11:00
@@ -241,7 +241,8 @@
 void skb_release_data(struct sk_buff *skb)
 {
 	if (!skb->cloned ||
-	    atomic_dec_and_test(&(skb_shinfo(skb)->dataref))) {
+	    !atomic_sub_return(skb->nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : 1,
+			       &skb_shinfo(skb)->dataref)) {
 		if (skb_shinfo(skb)->nr_frags) {
 			int i;
 			for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
@@ -353,6 +354,7 @@
 	C(csum);
 	C(local_df);
 	n->cloned = 1;
+	n->nohdr = 0;
 	C(pkt_type);
 	C(ip_summed);
 	C(priority);
@@ -604,6 +606,7 @@
 	skb->h.raw   += off;
 	skb->nh.raw  += off;
 	skb->cloned   = 0;
+	skb->nohdr    = 0;
 	atomic_set(&skb_shinfo(skb)->dataref, 1);
 	return 0;
 
===== net/ipv4/tcp.c 1.91 vs edited =====
--- 1.91/net/ipv4/tcp.c	2005-01-18 09:09:33 +11:00
+++ edited/net/ipv4/tcp.c	2005-01-29 13:52:38 +11:00
@@ -598,6 +598,7 @@
 	TCP_SKB_CB(skb)->end_seq = tp->write_seq;
 	TCP_SKB_CB(skb)->flags = TCPCB_FLAG_ACK;
 	TCP_SKB_CB(skb)->sacked = 0;
+	skb_header_release(skb);
 	__skb_queue_tail(&sk->sk_write_queue, skb);
 	sk_charge_skb(sk, skb);
 	if (!sk->sk_send_head)
===== net/ipv4/tcp_output.c 1.77 vs edited =====
--- 1.77/net/ipv4/tcp_output.c	2005-01-19 07:23:36 +11:00
+++ edited/net/ipv4/tcp_output.c	2005-01-29 13:55:08 +11:00
@@ -400,6 +400,7 @@
 
 	/* Advance write_seq and place onto the write_queue. */
 	tp->write_seq = TCP_SKB_CB(skb)->end_seq;
+	skb_header_release(skb);
 	__skb_queue_tail(&sk->sk_write_queue, skb);
 	sk_charge_skb(sk, skb);
 
@@ -1327,6 +1328,7 @@
 			if (nskb == NULL)
 				return -ENOMEM;
 			__skb_unlink(skb, &sk->sk_write_queue);
+			skb_header_release(nskb);
 			__skb_queue_head(&sk->sk_write_queue, nskb);
 			sk_stream_free_skb(sk, skb);
 			sk_charge_skb(sk, nskb);
@@ -1493,6 +1495,7 @@
 	/* Send it off. */
 	TCP_SKB_CB(buff)->when = tcp_time_stamp;
 	tp->retrans_stamp = TCP_SKB_CB(buff)->when;
+	skb_header_release(buff);
 	__skb_queue_tail(&sk->sk_write_queue, buff);
 	sk_charge_skb(sk, buff);
 	tp->packets_out += tcp_skb_pcount(buff);

--VbJkn9YxBvnuCH5J--
