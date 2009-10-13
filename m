From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC net-next-2.6] udp: Dont use lock_sock()/release_sock() in rx
 path
Date: Tue, 13 Oct 2009 23:59:52 +0200
Message-ID: <4AD4F858.2040200@gmail.com>
References: <4ACE023D.9030208@gmail.com> <19f34abd0910081454v51455ee0p30ad6715b5ee31c0@mail.gmail.com> <4ACE8CEC.3020905@gmail.com> <4ACE95E1.30301@gmail.com> <alpine.DEB.1.10.0910091539170.32209@gentwo.org> <4ACFA012.6010409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux-foundation.org>,
	Vegard Nossum <vegard.nossum@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:41479 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934428AbZJMWAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 18:00:40 -0400
In-Reply-To: <4ACFA012.6010409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Sure, will do, but first I want to suppress the lock_sock()/release_s=
ock() in
> rx path, that was added for sk_forward_alloc thing. This really hurts=
,
> because of the backlog handling.
>=20
> I have preliminary patch that restore UDP latencies we had in the pas=
t ;)
>=20
> Trick is for UDP, sk_forward_alloc is not updated by tx/rx, only rx.
> So we can use the sk_receive_queue.lock to forbid concurrent updates.
>=20
> As this lock is already hot and only used by rx, we wont have to
> dirty the sk_lock, that will only be used by tx path.
>=20
> Then we can carefuly reorder struct sock to lower number of cache lin=
es
> needed for each path.
>=20

[RFC net-next-2.6] udp: Dont use lock_sock()/release_sock() in rx path

We added two years ago memory accounting for UDP and some people compla=
in
about increased latencies, especially on multicast.

Because sk_forward_alloc is not atomic, we duplicated the protection we=
 used for TCP,
ie use lock_sock()/release_sock() to guard sk_forward_alloc against con=
current updates.

When a frame is received by NIC, sofirq handler has to lock the socket,=
 and eventually
has to queue the frame into backlog instead of receive queue.

Then, user application also has to lock socket to dequeue a frame from =
receive_queue
and eventually process backlog queue, leading to high latencies.

This lock is also used in tx path to guard cork structure against concu=
rrent updates.

This cause false sharing of socket lock between several cpus that could=
 be avoided,
considering UDP touches sk_forward_alloc only on rx. (TCP use it both f=
or rx and tx)

Instead of using socket lock, we can use the sk_receive.lock lock that =
we have to
get anyway to queue frame at softirq time (or dequeue it by user applic=
ation)

This avoids two atomic ops per packet in softirq handler, one in user a=
pp doing recvmsg(),
and we dont touch backlog anymore.

This way, the socket lock is only used in tx path, as in the past, and =
we can improve
things by reordering struct sock fields into separate rx/tx groups, in =
a followup patch.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 core/sock.c |    6 +++++-
 ipv4/udp.c  |   34 ++++++++--------------------------
 ipv6/udp.c  |   36 ++++++++++--------------------------
 3 files changed, 23 insertions(+), 53 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 43ca2c9..d06b1a0 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -292,8 +292,13 @@ int sock_queue_rcv_skb(struct sock *sk, struct sk_=
buff *skb)
 	if (err)
 		goto out;
=20
+	skb_orphan(skb);
+
+	spin_lock_irqsave(&list->lock, flags);
+
 	if (!sk_rmem_schedule(sk, skb->truesize)) {
 		err =3D -ENOBUFS;
+		spin_unlock_irqrestore(&list->lock, flags);
 		goto out;
 	}
=20
@@ -307,7 +312,6 @@ int sock_queue_rcv_skb(struct sock *sk, struct sk_b=
uff *skb)
 	 */
 	skb_len =3D skb->len;
=20
-	spin_lock_irqsave(&list->lock, flags);
 	skb->dropcount =3D atomic_read(&sk->sk_drops);
 	__skb_queue_tail(list, skb);
 	spin_unlock_irqrestore(&list->lock, flags);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index ee61b3f..f62cec3 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -855,29 +855,21 @@ out:
  */
 static unsigned int first_packet_length(struct sock *sk)
 {
-	struct sk_buff_head list_kill, *rcvq =3D &sk->sk_receive_queue;
+	struct sk_buff_head *rcvq =3D &sk->sk_receive_queue;
 	struct sk_buff *skb;
 	unsigned int res;
=20
-	__skb_queue_head_init(&list_kill);
-
 	spin_lock_bh(&rcvq->lock);
 	while ((skb =3D skb_peek(rcvq)) !=3D NULL &&
 		udp_lib_checksum_complete(skb)) {
 		UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS,
 				 IS_UDPLITE(sk));
 		__skb_unlink(skb, rcvq);
-		__skb_queue_tail(&list_kill, skb);
+		skb_kill_datagram(sk, skb, 0);
 	}
 	res =3D skb ? skb->len : 0;
 	spin_unlock_bh(&rcvq->lock);
=20
-	if (!skb_queue_empty(&list_kill)) {
-		lock_sock(sk);
-		__skb_queue_purge(&list_kill);
-		sk_mem_reclaim_partial(sk);
-		release_sock(sk);
-	}
 	return res;
 }
=20
@@ -1003,17 +995,17 @@ try_again:
 		err =3D ulen;
=20
 out_free:
-	lock_sock(sk);
+	spin_lock_bh(&sk->sk_receive_queue.lock);
 	skb_free_datagram(sk, skb);
-	release_sock(sk);
+	spin_unlock_bh(&sk->sk_receive_queue.lock);
 out:
 	return err;
=20
 csum_copy_err:
-	lock_sock(sk);
+	spin_lock_bh(&sk->sk_receive_queue.lock);
 	if (!skb_kill_datagram(sk, skb, flags))
-		UDP_INC_STATS_USER(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
-	release_sock(sk);
+		UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
+	spin_unlock_bh(&sk->sk_receive_queue.lock);
=20
 	if (noblock)
 		return -EAGAIN;
@@ -1095,7 +1087,6 @@ drop:
 int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	struct udp_sock *up =3D udp_sk(sk);
-	int rc;
 	int is_udplite =3D IS_UDPLITE(sk);
=20
 	/*
@@ -1175,16 +1166,7 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk=
_buff *skb)
 			goto drop;
 	}
=20
-	rc =3D 0;
-
-	bh_lock_sock(sk);
-	if (!sock_owned_by_user(sk))
-		rc =3D __udp_queue_rcv_skb(sk, skb);
-	else
-		sk_add_backlog(sk, skb);
-	bh_unlock_sock(sk);
-
-	return rc;
+	return __udp_queue_rcv_skb(sk, skb);
=20
 drop:
 	UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 1f8e2af..07468aa 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -288,23 +288,23 @@ try_again:
 		err =3D ulen;
=20
 out_free:
-	lock_sock(sk);
+	spin_lock_bh(&sk->sk_receive_queue.lock);
 	skb_free_datagram(sk, skb);
-	release_sock(sk);
+	spin_unlock_bh(&sk->sk_receive_queue.lock);
 out:
 	return err;
=20
 csum_copy_err:
-	lock_sock(sk);
+	spin_lock_bh(&sk->sk_receive_queue.lock);
 	if (!skb_kill_datagram(sk, skb, flags)) {
 		if (is_udp4)
-			UDP_INC_STATS_USER(sock_net(sk),
+			UDP_INC_STATS_BH(sock_net(sk),
 					UDP_MIB_INERRORS, is_udplite);
 		else
-			UDP6_INC_STATS_USER(sock_net(sk),
+			UDP6_INC_STATS_BH(sock_net(sk),
 					UDP_MIB_INERRORS, is_udplite);
 	}
-	release_sock(sk);
+	spin_unlock_bh(&sk->sk_receive_queue.lock);
=20
 	if (flags & MSG_DONTWAIT)
 		return -EAGAIN;
@@ -468,21 +468,10 @@ static int __udp6_lib_mcast_deliver(struct net *n=
et, struct sk_buff *skb,
 	while ((sk2 =3D udp_v6_mcast_next(net, sk_nulls_next(sk2), uh->dest, =
daddr,
 					uh->source, saddr, dif))) {
 		struct sk_buff *buff =3D skb_clone(skb, GFP_ATOMIC);
-		if (buff) {
-			bh_lock_sock(sk2);
-			if (!sock_owned_by_user(sk2))
-				udpv6_queue_rcv_skb(sk2, buff);
-			else
-				sk_add_backlog(sk2, buff);
-			bh_unlock_sock(sk2);
-		}
+		if (buff)
+			udpv6_queue_rcv_skb(sk2, buff);
 	}
-	bh_lock_sock(sk);
-	if (!sock_owned_by_user(sk))
-		udpv6_queue_rcv_skb(sk, skb);
-	else
-		sk_add_backlog(sk, skb);
-	bh_unlock_sock(sk);
+	udpv6_queue_rcv_skb(sk, skb);
 out:
 	spin_unlock(&hslot->lock);
 	return 0;
@@ -597,12 +586,7 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp=
_table *udptable,
=20
 	/* deliver */
=20
-	bh_lock_sock(sk);
-	if (!sock_owned_by_user(sk))
-		udpv6_queue_rcv_skb(sk, skb);
-	else
-		sk_add_backlog(sk, skb);
-	bh_unlock_sock(sk);
+	udpv6_queue_rcv_skb(sk, skb);
 	sock_put(sk);
 	return 0;
=20
