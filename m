From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: speedup udp receive path
Date: Wed, 28 Apr 2010 16:06:45 +0200
Message-ID: <1272463605.2267.70.camel@edumazet-laptop>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <1272018366.7895.7930.camel@edumazet-laptop>
	 <20100427.150817.84390202.davem@davemloft.net>
	 <1272406693.2343.26.camel@edumazet-laptop>  <1272454432.14068.4.camel@bigi>
	 <1272458001.2267.0.camel@edumazet-laptop>  <1272458174.14068.16.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, xiaosuo@gmail.com,
	therbert@google.com, shemminger@vyatta.com, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>,
	Brian Bloniarz <bmb@athenacr.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:35049 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945Ab0D1OGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 10:06:53 -0400
Received: by bwz19 with SMTP id 19so2788bwz.21
        for <netdev@vger.kernel.org>; Wed, 28 Apr 2010 07:06:50 -0700 (PDT)
In-Reply-To: <1272458174.14068.16.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 28 avril 2010 =C3=A0 08:36 -0400, jamal a =C3=A9crit :
> On Wed, 2010-04-28 at 14:33 +0200, Eric Dumazet wrote:
>=20
> > If you wait a bit, I have another patch to speedup udp receive path=
 ;)
>=20
> Shoot whenever you are ready ;-> I will test with and without your
> patch..
>=20

Here it is ;)

Thanks

[PATCH net-next-2.6] net: speedup udp receive path

Since commit 95766fff ([UDP]: Add memory accounting.),=20
each received packet needs one extra sock_lock()/sock_release() pair.

This added latency because of possible backlog handling. Then later,
ticket spinlocks added yet another latency source in case of DDOS.

This patch introduces lock_sock_bh() and unlock_sock_bh()
synchronization primitives, avoiding one atomic operation and backlog
processing.

skb_free_datagram_locked() uses them instead of full blown
lock_sock()/release_sock(). skb is orphaned inside locked section for
proper socket memory reclaim, and finally freed outside of it.

UDP receive path now take the socket spinlock only once.

Signed-off-by: Eric DUmazet <eric.dumazet@gmail.com>
---
 include/net/sock.h  |   10 ++++++++++
 net/core/datagram.c |   10 +++++++---
 net/ipv4/udp.c      |   12 ++++++------
 net/ipv6/udp.c      |    4 ++--
 4 files changed, 25 insertions(+), 11 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index cf12b1e..d361c77 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1021,6 +1021,16 @@ extern void release_sock(struct sock *sk);
 				SINGLE_DEPTH_NESTING)
 #define bh_unlock_sock(__sk)	spin_unlock(&((__sk)->sk_lock.slock))
=20
+static inline void lock_sock_bh(struct sock *sk)
+{
+	spin_lock_bh(&sk->sk_lock.slock);
+}
+
+static inline void unlock_sock_bh(struct sock *sk)
+{
+	spin_unlock_bh(&sk->sk_lock.slock);
+}
+
 extern struct sock		*sk_alloc(struct net *net, int family,
 					  gfp_t priority,
 					  struct proto *prot);
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 5574a5d..95b851f 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -229,9 +229,13 @@ EXPORT_SYMBOL(skb_free_datagram);
=20
 void skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb)
 {
-	lock_sock(sk);
-	skb_free_datagram(sk, skb);
-	release_sock(sk);
+	lock_sock_bh(sk);
+	skb_orphan(skb);
+	sk_mem_reclaim_partial(sk);
+	unlock_sock_bh(sk);
+
+	/* skb is now orphaned, might be freed outside of locked section */
+	consume_skb(skb);
 }
 EXPORT_SYMBOL(skb_free_datagram_locked);
=20
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 63eb56b..1f86965 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1062,10 +1062,10 @@ static unsigned int first_packet_length(struct =
sock *sk)
 	spin_unlock_bh(&rcvq->lock);
=20
 	if (!skb_queue_empty(&list_kill)) {
-		lock_sock(sk);
+		lock_sock_bh(sk);
 		__skb_queue_purge(&list_kill);
 		sk_mem_reclaim_partial(sk);
-		release_sock(sk);
+		unlock_sock_bh(sk);
 	}
 	return res;
 }
@@ -1196,10 +1196,10 @@ out:
 	return err;
=20
 csum_copy_err:
-	lock_sock(sk);
+	lock_sock_bh(sk);
 	if (!skb_kill_datagram(sk, skb, flags))
 		UDP_INC_STATS_USER(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
-	release_sock(sk);
+	unlock_sock_bh(sk);
=20
 	if (noblock)
 		return -EAGAIN;
@@ -1624,9 +1624,9 @@ int udp_rcv(struct sk_buff *skb)
=20
 void udp_destroy_sock(struct sock *sk)
 {
-	lock_sock(sk);
+	lock_sock_bh(sk);
 	udp_flush_pending_frames(sk);
-	release_sock(sk);
+	unlock_sock_bh(sk);
 }
=20
 /*
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 3ead20a..91c60f0 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -424,7 +424,7 @@ out:
 	return err;
=20
 csum_copy_err:
-	lock_sock(sk);
+	lock_sock_bh(sk);
 	if (!skb_kill_datagram(sk, skb, flags)) {
 		if (is_udp4)
 			UDP_INC_STATS_USER(sock_net(sk),
@@ -433,7 +433,7 @@ csum_copy_err:
 			UDP6_INC_STATS_USER(sock_net(sk),
 					UDP_MIB_INERRORS, is_udplite);
 	}
-	release_sock(sk);
+	unlock_sock_bh(sk);
=20
 	if (flags & MSG_DONTWAIT)
 		return -EAGAIN;


