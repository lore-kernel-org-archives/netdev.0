From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: No more expensive sock_hold()/sock_put() on each tx
Date: Thu, 04 Jun 2009 11:18:35 +0200
Message-ID: <4A27916B.7030607@gmail.com>
References: <200906041324.59118.rusty@rustcorp.com.au>	<20090603.210054.18839960.davem@davemloft.net>	<4A275380.1050601@gmail.com> <20090603.215621.136203134.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rusty@rustcorp.com.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59632 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751512AbZFDJSp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 05:18:45 -0400
In-Reply-To: <20090603.215621.136203134.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 04 Jun 2009 06:54:24 +0200
>=20
>> We also can avoid the sock_put()/sock_hold() pair for each tx packet=
,
>> to only touch sk_wmem_alloc (with appropriate atomic_sub_return() in=
 sock_wfree()
>> and atomic_dec_test in sk_free
>>
>> We could initialize sk->sk_wmem_alloc to one instead of 0, so that
>> sock_wfree() could just synchronize itself with sk_free()
>=20
> Excellent idea Eric.

Thanks !

>=20
>> Patch will follow after some testing
>=20
> I look forward to it :-)

Here it is, based on net-next-2.6=20

CC list trimmed down...

Next step would be to get rid of sk_callback_lock, I dont remember
if we already discussed about that rwlock, after RCUification of socket=
s...

Thanks

[PATCH] net: No more expensive sock_hold()/sock_put() on each tx

One of the problem with sock memory accounting is it uses
a pair of sock_hold()/sock_put() for each transmitted packet.

This slows down bidirectional flows because the receive path
also needs to take a refcount on socket and might use a different
cpu than transmit path or transmit completion path. So these
two atomic operations also trigger cache line bounces.

We can see this in tx or tx/rx workloads (media gateways for example),
where sock_wfree() can be in top five functions in profiles.

We use this sock_hold()/sock_put() so that sock freeing
is delayed until all tx packets are completed.

As we also update sk_wmem_alloc, we could offset sk_wmem_alloc
by one unit at init time, until sk_free() is called.
Once sk_free() is called, we atomic_dec_and_test(sk_wmem_alloc)
to decrement initial offset and atomicaly check if any packets
are in flight.

skb_set_owner_w() doesnt call sock_hold() anymore

sock_wfree() doesnt call sock_put() anymore, but check if sk_wmem_alloc
reached 0 to perform the final freeing.

Drawback is that a skb->truesize error could lead to unfreeable sockets=
, or
even worse, prematurely calling __sk_free() on a live socket.

Nice speedups on SMP. tbench for example, going from 2691 MB/s to 2711 =
MB/s
on my 8 cpu dev machine, even if tbench was not really hitting sk_refcn=
t
contention point. 5 % speedup on a UDP transmit workload (depends
on number of flows), lowering TX completion cpu usage.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/sock.h    |    6 +++++-
 net/core/sock.c       |   29 +++++++++++++++++++++++++----
 net/ipv4/ip_output.c  |    1 -
 net/ipv6/ip6_output.c |    1 -
 4 files changed, 30 insertions(+), 7 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 4bb1ff9..010e14a 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1217,9 +1217,13 @@ static inline int skb_copy_to_page(struct sock *=
sk, char __user *from,
=20
 static inline void skb_set_owner_w(struct sk_buff *skb, struct sock *s=
k)
 {
-	sock_hold(sk);
 	skb->sk =3D sk;
 	skb->destructor =3D sock_wfree;
+	/*
+	 * We used to take a refcount on sk, but following operation
+	 * is enough to guarantee sk_free() wont free this sock until
+	 * all in-flight packets are completed
+	 */
 	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
 }
=20
diff --git a/net/core/sock.c b/net/core/sock.c
index 58dec9d..ce0159a 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1005,7 +1005,7 @@ struct sock *sk_alloc(struct net *net, int family=
, gfp_t priority,
 }
 EXPORT_SYMBOL(sk_alloc);
=20
-void sk_free(struct sock *sk)
+static void __sk_free(struct sock *sk)
 {
 	struct sk_filter *filter;
=20
@@ -1028,6 +1028,17 @@ void sk_free(struct sock *sk)
 	put_net(sock_net(sk));
 	sk_prot_free(sk->sk_prot_creator, sk);
 }
+
+void sk_free(struct sock *sk)
+{
+	/*
+	 * We substract one from sk_wmem_alloc and can know if
+	 * some packets are still in some tx queue.
+	 * If not null, sock_wfree() will call __sk_free(sk) later
+	 */
+	if (atomic_dec_and_test(&sk->sk_wmem_alloc))
+		__sk_free(sk);
+}
 EXPORT_SYMBOL(sk_free);
=20
 /*
@@ -1068,7 +1079,10 @@ struct sock *sk_clone(const struct sock *sk, con=
st gfp_t priority)
 		newsk->sk_backlog.head	=3D newsk->sk_backlog.tail =3D NULL;
=20
 		atomic_set(&newsk->sk_rmem_alloc, 0);
-		atomic_set(&newsk->sk_wmem_alloc, 0);
+		/*
+		 * sk_wmem_alloc set to one (see sk_free() and sock_wfree())
+		 */
+		atomic_set(&newsk->sk_wmem_alloc, 1);
 		atomic_set(&newsk->sk_omem_alloc, 0);
 		skb_queue_head_init(&newsk->sk_receive_queue);
 		skb_queue_head_init(&newsk->sk_write_queue);
@@ -1172,12 +1186,18 @@ void __init sk_init(void)
 void sock_wfree(struct sk_buff *skb)
 {
 	struct sock *sk =3D skb->sk;
+	int res;
=20
 	/* In case it might be waiting for more memory. */
-	atomic_sub(skb->truesize, &sk->sk_wmem_alloc);
+	res =3D atomic_sub_return(skb->truesize, &sk->sk_wmem_alloc);
 	if (!sock_flag(sk, SOCK_USE_WRITE_QUEUE))
 		sk->sk_write_space(sk);
-	sock_put(sk);
+	/*
+	 * if sk_wmem_alloc reached 0, we are last user and should
+	 * free this sock, as sk_free() call could not do it.
+	 */
+	if (res =3D=3D 0)
+		__sk_free(sk);
 }
 EXPORT_SYMBOL(sock_wfree);
=20
@@ -1816,6 +1836,7 @@ void sock_init_data(struct socket *sock, struct s=
ock *sk)
 	sk->sk_stamp =3D ktime_set(-1L, 0);
=20
 	atomic_set(&sk->sk_refcnt, 1);
+	atomic_set(&sk->sk_wmem_alloc, 1);
 	atomic_set(&sk->sk_drops, 0);
 }
 EXPORT_SYMBOL(sock_init_data);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 3d6167f..badbfde 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -498,7 +498,6 @@ int ip_fragment(struct sk_buff *skb, int (*output)(=
struct sk_buff *))
=20
 			BUG_ON(frag->sk);
 			if (skb->sk) {
-				sock_hold(skb->sk);
 				frag->sk =3D skb->sk;
 				frag->destructor =3D sock_wfree;
 				truesizes +=3D frag->truesize;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index c8dc8e5..18b9630 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -680,7 +680,6 @@ static int ip6_fragment(struct sk_buff *skb, int (*=
output)(struct sk_buff *))
=20
 			BUG_ON(frag->sk);
 			if (skb->sk) {
-				sock_hold(skb->sk);
 				frag->sk =3D skb->sk;
 				frag->destructor =3D sock_wfree;
 				truesizes +=3D frag->truesize;

