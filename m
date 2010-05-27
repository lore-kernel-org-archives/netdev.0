From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fix lock_sock_bh/unlock_sock_bh
Date: Thu, 27 May 2010 07:20:18 +0200
Message-ID: <1274937618.2542.46.camel@edumazet-laptop>
References: <1274868776.2672.96.camel@edumazet-laptop>
	 <20100527035617.GB28295@kryten> <1274933926.2542.26.camel@edumazet-laptop>
	 <20100526.212105.212688828.davem@davemloft.net>
	 <1274936763.2542.42.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: anton@samba.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38409 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469Ab0E0FU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 01:20:27 -0400
Received: by wyb29 with SMTP id 29so3841596wyb.19
        for <netdev@vger.kernel.org>; Wed, 26 May 2010 22:20:25 -0700 (PDT)
In-Reply-To: <1274936763.2542.42.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 27 mai 2010 =C3=A0 07:06 +0200, Eric Dumazet a =C3=A9crit :
> Le mercredi 26 mai 2010 =C3=A0 21:21 -0700, David Miller a =C3=A9crit=
 :
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Thu, 27 May 2010 06:18:46 +0200
> >=20
> > > Process context :
> > >=20
> > > lock only (sk_lock.slock =3D locked, sk_lock.owned =3D ???)
> > >=20
> > > So I should add a test on owned. If set (by another thread), we s=
hould take the slow path.
> >=20
> > Indeed, what you're doing now is broken.
> >=20
> > If owned is non-zero when you take the spinlock you have to queue y=
our
> > work, just like how we toss packets into the socket backlog, which =
is
> > processed by release_sock(), when this happens.
>=20
> Here is the patch I am going to test today.
>=20
> Anton, could you please test it too, just for sure ?
>=20
> Thanks !
>=20
>=20
> [PATCH] net: fix lock_sock_bh/unlock_sock_bh
>=20
> This new sock lock primitive was introduced to speedup some user cont=
ext
> socket manipulation. But it is unsafe to protect two threads, one usi=
ng
> regular lock_sock/release_sock, one using lock_sock_bh/unlock_sock_bh
>=20
> This patch changes lock_sock_bh to be careful against 'owned' state.
> If owned is found to be set, we must take the slow path.
> lock_sock_bh() now returns a boolean to say if the slow path was take=
n,
> and this boolean is used at unlock_sock_bh time to call the appropria=
te
> unlock function.
>=20
> After this change, BH are either disabled or enabled during the
> lock_sock_bh/unlock_sock_bh protected section. This might be misleadi=
ng,
> so we rename these functions to lock_sock_fast()/unlock_sock_fast().
>=20
> Reported-by: Anton Blanchard <anton@samba.org>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  include/net/sock.h  |   20 ++++++++++++++------
>  net/core/datagram.c |    6 ++++--
>  net/core/sock.c     |   32 ++++++++++++++++++++++++++++++++
>  net/ipv4/udp.c      |   14 ++++++++------
>  net/ipv6/udp.c      |    5 +++--
>  5 files changed, 61 insertions(+), 16 deletions(-)
>=20
> diff --git a/include/net/sock.h b/include/net/sock.h
> index d2a71b0..ca241ea 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1026,15 +1026,23 @@ extern void release_sock(struct sock *sk);
>  				SINGLE_DEPTH_NESTING)
>  #define bh_unlock_sock(__sk)	spin_unlock(&((__sk)->sk_lock.slock))
> =20
> -static inline void lock_sock_bh(struct sock *sk)
> +extern bool lock_sock_fast(struct sock *sk);
> +/**
> + * unlock_sock_fast - complement of lock_sock_fast
> + * @sk: socket
> + * @slow: slow mode
> + *
> + * fast unlock socket for user context.
> + * If slow mode is on, we call regular release_sock()
> + */
> +static inline void unlock_sock_fast(struct sock *sk, bool slow)
>  {
> -	spin_lock_bh(&sk->sk_lock.slock);
> +	if (slow)
> +		release_sock(sk);
> +	else
> +		spin_unlock_bh(&sk->sk_lock.slock);
>  }
> =20
> -static inline void unlock_sock_bh(struct sock *sk)
> -{
> -	spin_unlock_bh(&sk->sk_lock.slock);
> -}
> =20
>  extern struct sock		*sk_alloc(struct net *net, int family,
>  					  gfp_t priority,
> diff --git a/net/core/datagram.c b/net/core/datagram.c
> index e009753..f5b6f43 100644
> --- a/net/core/datagram.c
> +++ b/net/core/datagram.c
> @@ -229,15 +229,17 @@ EXPORT_SYMBOL(skb_free_datagram);
> =20
>  void skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb)
>  {
> +	bool slow;
> +
>  	if (likely(atomic_read(&skb->users) =3D=3D 1))
>  		smp_rmb();
>  	else if (likely(!atomic_dec_and_test(&skb->users)))
>  		return;
> =20
> -	lock_sock_bh(sk);
> +	slow =3D lock_sock_fast(sk);
>  	skb_orphan(skb);
>  	sk_mem_reclaim_partial(sk);
> -	unlock_sock_bh(sk);
> +	unlock_sock_fast(sk, slow);
> =20
>  	/* skb is now orphaned, can be freed outside of locked section */
>  	__kfree_skb(skb);
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 37fe9b6..7ab6398 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -2007,6 +2007,38 @@ void release_sock(struct sock *sk)
>  }
>  EXPORT_SYMBOL(release_sock);
> =20
> +/**
> + * lock_sock_fast - fast version of lock_sock
> + * @sk: socket
> + *
> + * This version should be used for very small section, where process=
 wont block
> + * return false if fast path is taken
> + *   sk_lock.slock locked, owned =3D 0, BH disabled
> + * return true if slow path is taken
> + *   sk_lock.slock unlocked, owned =3D 1, BH enabled
> + */
> +bool lock_sock_fast(struct sock *sk)
> +{
> +	might_sleep();
> +	spin_lock_bh(&sk->sk_lock.slock);
> +
> +	if (!sk->sk_lock.owned)
> +		/*
> +		 * Note : We must disable BH or risk a deadlock
> +		 */
> +		return false;
> +
> +	__lock_sock(sk);
> +	sk->sk_lock.owned =3D 1;
> +	spin_unlock(&sk->sk_lock.slock);
> +	/*
> +	 * The sk_lock has mutex_lock() semantics here:
> +	 */
> +	mutex_acquire(&sk->sk_lock.dep_map, 0, 0, _RET_IP_);

Oops, I missed a local_bh_enable(); here

> +	return true;
> +}
> +EXPORT_SYMBOL(lock_sock_fast);
> +
>  int sock_get_timestamp(struct sock *sk, struct timeval __user *users=
tamp)
>  {
>  	struct timeval tv;

Here is v2 of patch with local_bh_enable(); added in lock_sock_fast()

[PATCH v2] net: fix lock_sock_bh/unlock_sock_bh

This new sock lock primitive was introduced to speedup some user contex=
t
socket manipulation. But it is unsafe to protect two threads, one using
regular lock_sock/release_sock, one using lock_sock_bh/unlock_sock_bh

This patch changes lock_sock_bh to be careful against 'owned' state.
If owned is found to be set, we must take the slow path.
lock_sock_bh() now returns a boolean to say if the slow path was taken,
and this boolean is used at unlock_sock_bh time to call the appropriate
unlock function.

After this change, BH are either disabled or enabled during the
lock_sock_bh/unlock_sock_bh protected section. This might be misleading=
,
so we rename these functions to lock_sock_fast()/unlock_sock_fast().

Reported-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/sock.h  |   20 ++++++++++++++------
 net/core/datagram.c |    6 ++++--
 net/core/sock.c     |   33 +++++++++++++++++++++++++++++++++
 net/ipv4/udp.c      |   14 ++++++++------
 net/ipv6/udp.c      |    5 +++--
 5 files changed, 62 insertions(+), 16 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index d2a71b0..ca241ea 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1026,15 +1026,23 @@ extern void release_sock(struct sock *sk);
 				SINGLE_DEPTH_NESTING)
 #define bh_unlock_sock(__sk)	spin_unlock(&((__sk)->sk_lock.slock))
=20
-static inline void lock_sock_bh(struct sock *sk)
+extern bool lock_sock_fast(struct sock *sk);
+/**
+ * unlock_sock_fast - complement of lock_sock_fast
+ * @sk: socket
+ * @slow: slow mode
+ *
+ * fast unlock socket for user context.
+ * If slow mode is on, we call regular release_sock()
+ */
+static inline void unlock_sock_fast(struct sock *sk, bool slow)
 {
-	spin_lock_bh(&sk->sk_lock.slock);
+	if (slow)
+		release_sock(sk);
+	else
+		spin_unlock_bh(&sk->sk_lock.slock);
 }
=20
-static inline void unlock_sock_bh(struct sock *sk)
-{
-	spin_unlock_bh(&sk->sk_lock.slock);
-}
=20
 extern struct sock		*sk_alloc(struct net *net, int family,
 					  gfp_t priority,
diff --git a/net/core/datagram.c b/net/core/datagram.c
index e009753..f5b6f43 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -229,15 +229,17 @@ EXPORT_SYMBOL(skb_free_datagram);
=20
 void skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb)
 {
+	bool slow;
+
 	if (likely(atomic_read(&skb->users) =3D=3D 1))
 		smp_rmb();
 	else if (likely(!atomic_dec_and_test(&skb->users)))
 		return;
=20
-	lock_sock_bh(sk);
+	slow =3D lock_sock_fast(sk);
 	skb_orphan(skb);
 	sk_mem_reclaim_partial(sk);
-	unlock_sock_bh(sk);
+	unlock_sock_fast(sk, slow);
=20
 	/* skb is now orphaned, can be freed outside of locked section */
 	__kfree_skb(skb);
diff --git a/net/core/sock.c b/net/core/sock.c
index 37fe9b6..2cf7f9f 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2007,6 +2007,39 @@ void release_sock(struct sock *sk)
 }
 EXPORT_SYMBOL(release_sock);
=20
+/**
+ * lock_sock_fast - fast version of lock_sock
+ * @sk: socket
+ *
+ * This version should be used for very small section, where process w=
ont block
+ * return false if fast path is taken
+ *   sk_lock.slock locked, owned =3D 0, BH disabled
+ * return true if slow path is taken
+ *   sk_lock.slock unlocked, owned =3D 1, BH enabled
+ */
+bool lock_sock_fast(struct sock *sk)
+{
+	might_sleep();
+	spin_lock_bh(&sk->sk_lock.slock);
+
+	if (!sk->sk_lock.owned)
+		/*
+		 * Note : We must disable BH
+		 */
+		return false;
+
+	__lock_sock(sk);
+	sk->sk_lock.owned =3D 1;
+	spin_unlock(&sk->sk_lock.slock);
+	/*
+	 * The sk_lock has mutex_lock() semantics here:
+	 */
+	mutex_acquire(&sk->sk_lock.dep_map, 0, 0, _RET_IP_);
+	local_bh_enable();
+	return true;
+}
+EXPORT_SYMBOL(lock_sock_fast);
+
 int sock_get_timestamp(struct sock *sk, struct timeval __user *usersta=
mp)
 {
 	struct timeval tv;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 9de6a69..b9d0d40 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1063,10 +1063,11 @@ static unsigned int first_packet_length(struct =
sock *sk)
 	spin_unlock_bh(&rcvq->lock);
=20
 	if (!skb_queue_empty(&list_kill)) {
-		lock_sock_bh(sk);
+		bool slow =3D lock_sock_fast(sk);
+
 		__skb_queue_purge(&list_kill);
 		sk_mem_reclaim_partial(sk);
-		unlock_sock_bh(sk);
+		unlock_sock_fast(sk, slow);
 	}
 	return res;
 }
@@ -1123,6 +1124,7 @@ int udp_recvmsg(struct kiocb *iocb, struct sock *=
sk, struct msghdr *msg,
 	int peeked;
 	int err;
 	int is_udplite =3D IS_UDPLITE(sk);
+	bool slow;
=20
 	/*
 	 *	Check any passed addresses
@@ -1197,10 +1199,10 @@ out:
 	return err;
=20
 csum_copy_err:
-	lock_sock_bh(sk);
+	slow =3D lock_sock_fast(sk);
 	if (!skb_kill_datagram(sk, skb, flags))
 		UDP_INC_STATS_USER(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
-	unlock_sock_bh(sk);
+	unlock_sock_fast(sk, slow);
=20
 	if (noblock)
 		return -EAGAIN;
@@ -1625,9 +1627,9 @@ int udp_rcv(struct sk_buff *skb)
=20
 void udp_destroy_sock(struct sock *sk)
 {
-	lock_sock_bh(sk);
+	bool slow =3D lock_sock_fast(sk);
 	udp_flush_pending_frames(sk);
-	unlock_sock_bh(sk);
+	unlock_sock_fast(sk, slow);
 }
=20
 /*
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 3d7a2c0..87be586 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -328,6 +328,7 @@ int udpv6_recvmsg(struct kiocb *iocb, struct sock *=
sk,
 	int err;
 	int is_udplite =3D IS_UDPLITE(sk);
 	int is_udp4;
+	bool slow;
=20
 	if (addr_len)
 		*addr_len=3Dsizeof(struct sockaddr_in6);
@@ -424,7 +425,7 @@ out:
 	return err;
=20
 csum_copy_err:
-	lock_sock_bh(sk);
+	slow =3D lock_sock_fast(sk);
 	if (!skb_kill_datagram(sk, skb, flags)) {
 		if (is_udp4)
 			UDP_INC_STATS_USER(sock_net(sk),
@@ -433,7 +434,7 @@ csum_copy_err:
 			UDP6_INC_STATS_USER(sock_net(sk),
 					UDP_MIB_INERRORS, is_udplite);
 	}
-	unlock_sock_bh(sk);
+	unlock_sock_fast(sk, slow);
=20
 	if (flags & MSG_DONTWAIT)
 		return -EAGAIN;


