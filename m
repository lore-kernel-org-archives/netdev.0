From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: reduce memory needs of out of order queue
Date: Fri, 14 Oct 2011 18:11:54 +0200
Message-ID: <1318608714.2223.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1318576791.2533.99.camel@edumazet-laptop>
	 <20111014.034224.1197576516015404466.davem@davemloft.net>
	 <4E985A3F.5080103@hp.com>
	 <1318608052.2223.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61478 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754730Ab1JNQLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 12:11:39 -0400
Received: by wwf22 with SMTP id 22so3688984wwf.1
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 09:11:38 -0700 (PDT)
In-Reply-To: <1318608052.2223.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 14 octobre 2011 =C3=A0 18:00 +0200, Eric Dumazet a =C3=A9cr=
it :

> Now we also could do the copybreak for frames queued into regular
>  receive_queue, if current wmem_alloc is above 25% of rcvbuf space...

I mean rmem_alloc of course...


diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c1653fe..0fe0828 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4426,6 +4426,25 @@ static inline int tcp_try_rmem_schedule(struct s=
ock *sk, unsigned int size)
 	return 0;
 }
=20
+/*
+ * Caller want to reduce memory needs before queueing skb
+ * The (expensive) copy should not be be done in fast path.
+ */
+static struct sk_buff *skb_reduce_truesize(struct sk_buff *skb)
+{
+	if (skb->truesize > 2 * SKB_TRUESIZE(skb->len)) {
+		struct sk_buff *nskb;
+
+		nskb =3D skb_copy_expand(skb, skb_headroom(skb), 0,
+				       GFP_ATOMIC | __GFP_NOWARN);
+		if (nskb) {
+			__kfree_skb(skb);
+			skb =3D nskb;
+		}
+	}
+	return skb;
+}
+
 static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcphdr *th =3D tcp_hdr(skb);
@@ -4475,6 +4494,10 @@ queue_and_out:
 			    tcp_try_rmem_schedule(sk, skb->truesize))
 				goto drop;
=20
+			if (atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf >> 2) {
+				skb =3D skb_reduce_truesize(skb);
+				th =3D tcp_hdr(skb);
+			}
 			skb_set_owner_r(skb, sk);
 			__skb_queue_tail(&sk->sk_receive_queue, skb);
 		}
@@ -4553,6 +4576,11 @@ drop:
 	SOCK_DEBUG(sk, "out of order segment: rcv_next %X seq %X - %X\n",
 		   tp->rcv_nxt, TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq);
=20
+	/* Since this skb might stay on ofo a long time, try to reduce
+	 * its truesize (if its too big) to avoid future pruning.
+	 * Many drivers allocate large buffers even to hold tiny frames.
+	 */
+	skb =3D skb_reduce_truesize(skb);
 	skb_set_owner_r(skb, sk);
=20
 	if (!skb_peek(&tp->out_of_order_queue)) {
