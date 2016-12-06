From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH] net/udp: do not touch skb->peeked unless really needed
Date: Tue, 06 Dec 2016 18:08:18 +0100
Message-ID: <1481044098.7129.7.camel@redhat.com>
References: <1480905784.18162.509.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480944138.4694.37.camel@redhat.com>
         <1480948133.18162.527.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480960639.18162.556.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481020451.6225.38.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38860 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752633AbcLFRI1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Dec 2016 12:08:27 -0500
In-Reply-To: <1481020451.6225.38.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-12-06 at 11:34 +0100, Paolo Abeni wrote:
> On Mon, 2016-12-05 at 09:57 -0800, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > In UDP recvmsg() path we currently access 3 cache lines from an skb
> > while holding receive queue lock, plus another one if packet is
> > dequeued, since we need to change skb->next->prev
> > 
> > 1st cache line (contains ->next/prev pointers, offsets 0x00 and 0x08)
> > 2nd cache line (skb->len & skb->peeked, offsets 0x80 and 0x8e)
> > 3rd cache line (skb->truesize/users, offsets 0xe0 and 0xe4)
> > 
> > skb->peeked is only needed to make sure 0-length packets are properly
> > handled while MSG_PEEK is operated.
> > 
> > I had first the intent to remove skb->peeked but the "MSG_PEEK at
> > non-zero offset" support added by Sam Kumar makes this not possible.
> > 
> > This patch avoids one cache line miss during the locked section, when
> > skb->len and skb->peeked do not have to be read.
> > 
> > It also avoids the skb_set_peeked() cost for non empty UDP datagrams.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Thank you for all the good work.
> 
> After all your improvement, I see the cacheline miss in inet_recvmsg()
> as a major perf offender for the user space process in the udp flood
> scenario due to skc_rxhash sharing the same sk_drops cacheline.
> 
> Using an udp-specific drop counter (and an sk_drops accessor to wrap
> sk_drops access where needed), we could avoid such cache miss. With that
> - patch for udp.h only below - I get 3% improvement on top of all the
> pending udp patches, and the gain should be more relevant after the 2
> queues rework. What do you think ?

Here follow what I'm experimenting. 

The 'pcflag' changes is not strictly needed, but it shrinks the udp_sock
struct a bit, so that the newly added cacheline does not create
additional holes - with my kconfig, at least. I can use a separate patch
for that chunk.
---
diff --git a/include/linux/udp.h b/include/linux/udp.h
index d1fd8cd..a21baaf 100644
--- a/include/linux/udp.h
+++ b/include/linux/udp.h
@@ -49,7 +49,11 @@ struct udp_sock {
 	unsigned int	 corkflag;	/* Cork is required */
 	__u8		 encap_type;	/* Is this an Encapsulation socket? */
 	unsigned char	 no_check6_tx:1,/* Send zero UDP6 checksums on TX? */
-			 no_check6_rx:1;/* Allow zero UDP6 checksums on RX? */
+			 no_check6_rx:1,/* Allow zero UDP6 checksums on RX? */
+			 pcflag:6;	/* UDP-Lite specific, moved here to */
+					/* fill an hole, marks socket as */
+					/* UDP-Lite if > 0    */
+
 	/*
 	 * Following member retains the information to create a UDP header
 	 * when the socket is uncorked.
@@ -64,8 +68,7 @@ struct udp_sock {
 #define UDPLITE_BIT      0x1  		/* set by udplite proto init function */
 #define UDPLITE_SEND_CC  0x2  		/* set via udplite setsockopt         */
 #define UDPLITE_RECV_CC  0x4		/* set via udplite setsocktopt        */
-	__u8		 pcflag;        /* marks socket as UDP-Lite if > 0    */
-	__u8		 unused[3];
+
 	/*
 	 * For encapsulation sockets.
 	 */
@@ -79,6 +82,9 @@ struct udp_sock {
 	int			(*gro_complete)(struct sock *sk,
 						struct sk_buff *skb,
 						int nhoff);
+
+	/* since we are prone to drops, avoid dirtying any sk cacheline */
+	atomic_t		drops ____cacheline_aligned_in_smp;
 };
 
 static inline struct udp_sock *udp_sk(const struct sock *sk)
@@ -106,6 +112,17 @@ static inline bool udp_get_no_check6_rx(struct sock *sk)
 	return udp_sk(sk)->no_check6_rx;
 }
 
+static inline int udp_drops_read(const struct sock *sk)
+{
      * +	return atomic_read(&udp_sk(sk)->drops);
+}
+
+static inline void
+udp_skb_set_dropcount(const struct sock *sk, struct sk_buff *skb)
+{
+	SOCK_SKB_CB(skb)->dropcount = udp_drops_read(sk);
+}
+
 #define udp_portaddr_for_each_entry(__sk, list) \
 	hlist_for_each_entry(__sk, list, __sk_common.skc_portaddr_node)
 
diff --git a/include/net/sock.h b/include/net/sock.h
index ed75dec..113e495 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2138,6 +2138,8 @@ struct sock_skb_cb {
 	SOCK_SKB_CB(skb)->dropcount = atomic_read(&sk->sk_drops);
 }
 
+int sk_drops_read(const struct sock *sk);
+
 static inline void sk_drops_add(struct sock *sk, const struct sk_buff *skb)
 {
 	int segs = max_t(u16, 1, skb_shinfo(skb)->gso_segs);
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index 6b10573..dc41727 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -9,6 +9,7 @@
 #include <net/sock.h>
 #include <linux/kernel.h>
 #include <linux/tcp.h>
+#include <linux/udp.h>
 #include <linux/workqueue.h>
 
 #include <linux/inet_diag.h>
@@ -19,6 +20,14 @@
 static DEFINE_MUTEX(sock_diag_table_mutex);
 static struct workqueue_struct *broadcast_wq;
 
+int sk_drops_read(const struct sock *sk)
+{
+	if (sk->sk_protocol == IPPROTO_UDP)
+		return udp_drops_read(sk);
+	else
+		return atomic_read(&sk->sk_drops);
+}
+
 static u64 sock_gen_cookie(struct sock *sk)
 {
 	while (1) {
@@ -67,7 +76,7 @@ int sock_diag_put_meminfo(struct sock *sk, struct sk_buff *skb, int attrtype)
 	mem[SK_MEMINFO_WMEM_QUEUED] = sk->sk_wmem_queued;
 	mem[SK_MEMINFO_OPTMEM] = atomic_read(&sk->sk_omem_alloc);
 	mem[SK_MEMINFO_BACKLOG] = sk->sk_backlog.len;
-	mem[SK_MEMINFO_DROPS] = atomic_read(&sk->sk_drops);
+	mem[SK_MEMINFO_DROPS] = sk_drops_read(sk);
 
 	return nla_put(skb, attrtype, sizeof(mem), &mem);
 }
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index fbd6b69..d7c4980 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1174,6 +1174,11 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
 	return ret;
 }
 
+static void udp_drops_inc(struct sock *sk)
+{
+	atomic_inc(&udp_sk(sk)->drops);
+}
+
 /* fully reclaim rmem/fwd memory allocated for skb */
 static void udp_rmem_release(struct sock *sk, int size, int partial)
 {
@@ -1244,7 +1249,7 @@ int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb)
 	/* no need to setup a destructor, we will explicitly release the
 	 * forward allocated memory on dequeue
 	 */
-	sock_skb_set_dropcount(sk, skb);
+	udp_skb_set_dropcount(sk, skb);
 
 	__skb_queue_tail(list, skb);
 	spin_unlock(&list->lock);
@@ -1258,7 +1263,7 @@ int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb)
 	atomic_sub(skb->truesize, &sk->sk_rmem_alloc);
 
 drop:
-	atomic_inc(&sk->sk_drops);
+	udp_drops_inc(sk);
 	return err;
 }
 EXPORT_SYMBOL_GPL(__udp_enqueue_schedule_skb);
@@ -1319,7 +1324,7 @@ static int first_packet_length(struct sock *sk)
 				IS_UDPLITE(sk));
 		__UDP_INC_STATS(sock_net(sk), UDP_MIB_INERRORS,
 				IS_UDPLITE(sk));
-		atomic_inc(&sk->sk_drops);
+		udp_drops_inc(sk);
 		__skb_unlink(skb, rcvq);
 		total += skb->truesize;
 		kfree_skb(skb);
@@ -1417,7 +1422,7 @@ int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 
 	if (unlikely(err)) {
 		if (!peeked) {
-			atomic_inc(&sk->sk_drops);
+			udp_drops_inc(sk);
 			UDP_INC_STATS(sock_net(sk),
 				      UDP_MIB_INERRORS, is_udplite);
 		}
@@ -1714,7 +1719,7 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	__UDP_INC_STATS(sock_net(sk), UDP_MIB_CSUMERRORS, is_udplite);
 drop:
 	__UDP_INC_STATS(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
-	atomic_inc(&sk->sk_drops);
+	udp_drops_inc(sk);
 	kfree_skb(skb);
 	return -1;
 }
@@ -1772,7 +1777,7 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 		nskb = skb_clone(skb, GFP_ATOMIC);
 
 		if (unlikely(!nskb)) {
-			atomic_inc(&sk->sk_drops);
+			udp_drops_inc(sk);
 			__UDP_INC_STATS(net, UDP_MIB_RCVBUFERRORS,
 					IS_UDPLITE(sk));
 			__UDP_INC_STATS(net, UDP_MIB_INERRORS,
@@ -2491,7 +2496,7 @@ static void udp4_format_sock(struct sock *sp, struct seq_file *f,
 		from_kuid_munged(seq_user_ns(f), sock_i_uid(sp)),
 		0, sock_i_ino(sp),
 		atomic_read(&sp->sk_refcnt), sp,
-		atomic_read(&sp->sk_drops));
+		udp_drops_read(sp));
 }
 
 int udp4_seq_show(struct seq_file *seq, void *v)
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index c5d76d2..9f46dff 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -1038,5 +1038,5 @@ void ip6_dgram_sock_seq_show(struct seq_file *seq, struct sock *sp,
 		   0,
 		   sock_i_ino(sp),
 		   atomic_read(&sp->sk_refcnt), sp,
-		   atomic_read(&sp->sk_drops));
+		   sk_drops_read(sp));
 }
