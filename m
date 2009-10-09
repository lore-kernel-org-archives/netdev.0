From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Fix struct sock bitfield annotation
Date: Fri, 09 Oct 2009 22:41:54 +0200
Message-ID: <4ACFA012.6010409@gmail.com>
References: <4ACE023D.9030208@gmail.com> <19f34abd0910081454v51455ee0p30ad6715b5ee31c0@mail.gmail.com> <4ACE8CEC.3020905@gmail.com> <4ACE95E1.30301@gmail.com> <alpine.DEB.1.10.0910091539170.32209@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Vegard Nossum <vegard.nossum@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38165 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753894AbZJIUmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 16:42:51 -0400
In-Reply-To: <alpine.DEB.1.10.0910091539170.32209@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> On Fri, 9 Oct 2009, Eric Dumazet wrote:
>=20
>> For networking guys, here is the actual mess with "struct sock" on x=
86_64,
>> related to UDP handling (critical latencies for some people). We bas=
ically touch
>> all cache lines, in every paths, bad effects on SMP...
>=20
> Please keep me posted on this. I am very interested in this work.
>=20
> Some simple shuffling around may do some good here.
>=20

Sure, will do, but first I want to suppress the lock_sock()/release_soc=
k() in
rx path, that was added for sk_forward_alloc thing. This really hurts,
because of the backlog handling.

I have preliminary patch that restore UDP latencies we had in the past =
;)

Trick is for UDP, sk_forward_alloc is not updated by tx/rx, only rx.
So we can use the sk_receive_queue.lock to forbid concurrent updates.

As this lock is already hot and only used by rx, we wont have to
dirty the sk_lock, that will only be used by tx path.

Then we can carefuly reorder struct sock to lower number of cache lines
needed for each path.


Patch against linux-2.6 git tree

 net/core/sock.c |    9 ++++
 net/ipv4/udp.c  |   89 ++++++++++++++++++++++------------------------
 2 files changed, 51 insertions(+), 47 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 7626b6a..45212d4 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -276,6 +276,7 @@ int sock_queue_rcv_skb(struct sock *sk, struct sk_b=
uff *skb)
 {
 	int err =3D 0;
 	int skb_len;
+	unsigned long flags;
=20
 	/* Cast sk->rcvbuf to unsigned... It's pointless, but reduces
 	   number of warnings when compiling with -W --ANK
@@ -290,8 +291,12 @@ int sock_queue_rcv_skb(struct sock *sk, struct sk_=
buff *skb)
 	if (err)
 		goto out;
=20
+	skb_orphan(skb);
+
+	spin_lock_irqsave(&sk->sk_receive_queue.lock, flags);
 	if (!sk_rmem_schedule(sk, skb->truesize)) {
 		err =3D -ENOBUFS;
+		spin_unlock_irqrestore(&sk->sk_receive_queue.lock, flags);
 		goto out;
 	}
=20
@@ -305,7 +310,9 @@ int sock_queue_rcv_skb(struct sock *sk, struct sk_b=
uff *skb)
 	 */
 	skb_len =3D skb->len;
=20
-	skb_queue_tail(&sk->sk_receive_queue, skb);
+	__skb_queue_tail(&sk->sk_receive_queue, skb);
+
+	spin_unlock_irqrestore(&sk->sk_receive_queue.lock, flags);
=20
 	if (!sock_flag(sk, SOCK_DEAD))
 		sk->sk_data_ready(sk, skb_len);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 6ec6a8a..e8a1be4 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -841,6 +841,36 @@ out:
 	return ret;
 }
=20
+
+/**
+ *	first_packet_length	- return length of first packet in receive queu=
e
+ *	@sk: socket
+ *
+ *	Drops all bad checksum frames, until a valid one is found.
+ *	Returns the length of found skb, or 0 if none is found.
+ */
+static unsigned int first_packet_length(struct sock *sk)
+{
+	struct sk_buff_head *rcvq =3D &sk->sk_receive_queue;
+	struct sk_buff *skb;
+	unsigned int res;
+
+	spin_lock_bh(&rcvq->lock);
+
+	while ((skb =3D skb_peek(rcvq)) !=3D NULL &&
+		udp_lib_checksum_complete(skb)) {
+		UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS,
+				 IS_UDPLITE(sk));
+		__skb_unlink(skb, rcvq);
+		skb_kill_datagram(sk, skb, 0);
+	}
+	res =3D skb ? skb->len : 0;
+
+	spin_unlock_bh(&rcvq->lock);
+
+	return res;
+}
+
 /*
  *	IOCTL requests applicable to the UDP protocol
  */
@@ -857,21 +887,16 @@ int udp_ioctl(struct sock *sk, int cmd, unsigned =
long arg)
=20
 	case SIOCINQ:
 	{
-		struct sk_buff *skb;
-		unsigned long amount;
+		unsigned int amount =3D first_packet_length(sk);
=20
-		amount =3D 0;
-		spin_lock_bh(&sk->sk_receive_queue.lock);
-		skb =3D skb_peek(&sk->sk_receive_queue);
-		if (skb !=3D NULL) {
+		if (amount)
 			/*
 			 * We will only return the amount
 			 * of this packet since that is all
 			 * that will be read.
 			 */
-			amount =3D skb->len - sizeof(struct udphdr);
-		}
-		spin_unlock_bh(&sk->sk_receive_queue.lock);
+			amount -=3D sizeof(struct udphdr);
+
 		return put_user(amount, (int __user *)arg);
 	}
=20
@@ -968,17 +993,17 @@ try_again:
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
@@ -1060,7 +1085,6 @@ drop:
 int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	struct udp_sock *up =3D udp_sk(sk);
-	int rc;
 	int is_udplite =3D IS_UDPLITE(sk);
=20
 	/*
@@ -1140,16 +1164,7 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk=
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
@@ -1540,29 +1555,11 @@ unsigned int udp_poll(struct file *file, struct=
 socket *sock, poll_table *wait)
 {
 	unsigned int mask =3D datagram_poll(file, sock, wait);
 	struct sock *sk =3D sock->sk;
-	int 	is_lite =3D IS_UDPLITE(sk);
=20
 	/* Check for false positives due to checksum errors */
-	if ((mask & POLLRDNORM) &&
-	    !(file->f_flags & O_NONBLOCK) &&
-	    !(sk->sk_shutdown & RCV_SHUTDOWN)) {
-		struct sk_buff_head *rcvq =3D &sk->sk_receive_queue;
-		struct sk_buff *skb;
-
-		spin_lock_bh(&rcvq->lock);
-		while ((skb =3D skb_peek(rcvq)) !=3D NULL &&
-		       udp_lib_checksum_complete(skb)) {
-			UDP_INC_STATS_BH(sock_net(sk),
-					UDP_MIB_INERRORS, is_lite);
-			__skb_unlink(skb, rcvq);
-			kfree_skb(skb);
-		}
-		spin_unlock_bh(&rcvq->lock);
-
-		/* nothing to see, move along */
-		if (skb =3D=3D NULL)
-			mask &=3D ~(POLLIN | POLLRDNORM);
-	}
+	if ((mask & POLLRDNORM) && !(file->f_flags & O_NONBLOCK) &&
+	    !(sk->sk_shutdown & RCV_SHUTDOWN) && !first_packet_length(sk))
+		mask &=3D ~(POLLIN | POLLRDNORM);
=20
 	return mask;
=20
