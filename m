From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: introduce __skb_header_release()
Date: Mon, 22 Sep 2014 16:29:32 -0700
Message-ID: <1411428572.26859.165.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:64022 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751088AbaIVX3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 19:29:34 -0400
Received: by mail-pa0-f52.google.com with SMTP id hz1so5427301pad.11
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 16:29:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

While profiling TCP stack, I noticed one useless atomic operation
in tcp_sendmsg(), caused by skb_header_release().

It turns out all current skb_header_release() users have a fresh skb,
that no other user can see, so we can avoid one atomic operation.

Introduce __skb_header_release() to clearly document this.

This gave me a 1.5 % improvement on TCP_RR workload.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/skbuff.h |   15 +++++++++++++++
 net/core/skbuff.c      |    4 ++--
 net/ipv4/tcp.c         |    4 ++--
 net/ipv4/tcp_output.c  |   10 +++++-----
 4 files changed, 24 insertions(+), 9 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f1bfa3781c75..8eaa62400fca 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1083,6 +1083,7 @@ static inline int skb_header_cloned(const struct sk_buff *skb)
  *	Drop a reference to the header part of the buffer.  This is done
  *	by acquiring a payload reference.  You must not read from the header
  *	part of skb->data after this.
+ *	Note : Check if you can use __skb_header_release() instead.
  */
 static inline void skb_header_release(struct sk_buff *skb)
 {
@@ -1092,6 +1093,20 @@ static inline void skb_header_release(struct sk_buff *skb)
 }
 
 /**
+ *	__skb_header_release - release reference to header
+ *	@skb: buffer to operate on
+ *
+ *	Variant of skb_header_release() assuming skb is private to caller.
+ *	We can avoid one atomic operation.
+ */
+static inline void __skb_header_release(struct sk_buff *skb)
+{
+	skb->nohdr = 1;
+	atomic_set(&skb_shinfo(skb)->dataref, 1 + (1 << SKB_DATAREF_SHIFT));
+}
+
+
+/**
  *	skb_shared - is the buffer shared
  *	@skb: buffer to check
  *
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 06a8feb10099..512dc7dcbc32 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3179,7 +3179,7 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 	skb_shinfo(nskb)->frag_list = p;
 	skb_shinfo(nskb)->gso_size = pinfo->gso_size;
 	pinfo->gso_size = 0;
-	skb_header_release(p);
+	__skb_header_release(p);
 	NAPI_GRO_CB(nskb)->last = p;
 
 	nskb->data_len += p->len;
@@ -3211,7 +3211,7 @@ merge:
 	else
 		NAPI_GRO_CB(p)->last->next = skb;
 	NAPI_GRO_CB(p)->last = skb;
-	skb_header_release(skb);
+	__skb_header_release(skb);
 	lp = p;
 
 done:
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 070aeff1b131..553b01f52f71 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -609,7 +609,7 @@ static inline bool forced_push(const struct tcp_sock *tp)
 	return after(tp->write_seq, tp->pushed_seq + (tp->max_window >> 1));
 }
 
-static inline void skb_entail(struct sock *sk, struct sk_buff *skb)
+static void skb_entail(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_skb_cb *tcb = TCP_SKB_CB(skb);
@@ -618,7 +618,7 @@ static inline void skb_entail(struct sock *sk, struct sk_buff *skb)
 	tcb->seq     = tcb->end_seq = tp->write_seq;
 	tcb->tcp_flags = TCPHDR_ACK;
 	tcb->sacked  = 0;
-	skb_header_release(skb);
+	__skb_header_release(skb);
 	tcp_add_write_queue_tail(sk, skb);
 	sk->sk_wmem_queued += skb->truesize;
 	sk_mem_charge(sk, skb->truesize);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 8c61a7c0c889..f173b1c4f815 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -995,7 +995,7 @@ static void tcp_queue_skb(struct sock *sk, struct sk_buff *skb)
 
 	/* Advance write_seq and place onto the write_queue. */
 	tp->write_seq = TCP_SKB_CB(skb)->end_seq;
-	skb_header_release(skb);
+	__skb_header_release(skb);
 	tcp_add_write_queue_tail(sk, skb);
 	sk->sk_wmem_queued += skb->truesize;
 	sk_mem_charge(sk, skb->truesize);
@@ -1167,7 +1167,7 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len,
 	}
 
 	/* Link BUFF into the send queue. */
-	skb_header_release(buff);
+	__skb_header_release(buff);
 	tcp_insert_write_queue_after(skb, buff, sk);
 
 	return 0;
@@ -1671,7 +1671,7 @@ static int tso_fragment(struct sock *sk, struct sk_buff *skb, unsigned int len,
 	tcp_set_skb_tso_segs(sk, buff, mss_now);
 
 	/* Link BUFF into the send queue. */
-	skb_header_release(buff);
+	__skb_header_release(buff);
 	tcp_insert_write_queue_after(skb, buff, sk);
 
 	return 0;
@@ -2772,7 +2772,7 @@ int tcp_send_synack(struct sock *sk)
 			if (nskb == NULL)
 				return -ENOMEM;
 			tcp_unlink_write_queue(skb, sk);
-			skb_header_release(nskb);
+			__skb_header_release(nskb);
 			__tcp_add_write_queue_head(sk, nskb);
 			sk_wmem_free_skb(sk, skb);
 			sk->sk_wmem_queued += nskb->truesize;
@@ -2947,7 +2947,7 @@ static void tcp_connect_queue_skb(struct sock *sk, struct sk_buff *skb)
 	struct tcp_skb_cb *tcb = TCP_SKB_CB(skb);
 
 	tcb->end_seq += skb->len;
-	skb_header_release(skb);
+	__skb_header_release(skb);
 	__tcp_add_write_queue_tail(sk, skb);
 	sk->sk_wmem_queued += skb->truesize;
 	sk_mem_charge(sk, skb->truesize);
