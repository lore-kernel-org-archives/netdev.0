From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] tcp: connect() race with timewait reuse
Date: Wed, 02 Dec 2009 16:08:59 +0100
Message-ID: <4B16830B.4010801@gmail.com>
References: <99d458640911301802i4bde20f4wa314668d543e3170@mail.gmail.com>	<4B152F97.1090409@gmail.com> <20091202.005937.177088443.davem@davemloft.net> <4B163226.50801@gmail.com> <4B164293.7070804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kdakhane@gmail.com, netdev@vger.kernel.org,
	netfilter@vger.kernel.org, zbr@ioremap.net,
	Evgeniy Polyakov <zbr@ioremap.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57181 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753640AbZLBPJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 10:09:03 -0500
In-Reply-To: <4B164293.7070804@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Eric Dumazet a =E9crit :
>> But even if sysctl_tw_reuse is cleared, we might trigger the bug if
>> local port is bound to a value.
>=20
> Oh well, that's more subtle than that.
>=20
> __inet_check_established() is called not only with bh disabled,
> but also with a lock on bind list if twp !=3D NULL.
>=20
> However, if twp is NULL, lock is not held by caller.
>=20
> [ Thats the final
>   ret =3D check_established(death_row, sk, snum, NULL);
>   in __inet_hash_connect()]
>=20
> So triggering this bug with tw_reuse clear is tricky :
>=20
> You need several threads, using sockets with REUSEADDR set,
> and bind() to same address/port before connect() to same target.
>=20
> We need another patch to correct this.
>=20

Here is a separate patch for this issue, cooked on top of net-next-2.6
for testing purposes, and public discussion.

Thanks

[PATCH net-next-2.6] tcp: connect() race with timewait reuse

Its currently possible that several threads issuing a connect() find th=
e same
timewait socket and try to reuse it, leading to list corruptions.

Condition for bug is that these threads bound their socket on same addr=
ess/port
of to be found timewait socket, and connected to same target. (SO_REUSE=
ADDR needed)

To fix this problem, we could unhash timewait socket while holding ehas=
h lock,
to make sure lookups/changes will be serialized. Only first one find th=
e timewait
socket, other ones find the established socket and return an EADDRNOTAV=
AIL error.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/inet_timewait_sock.h |    2 +
 net/ipv4/inet_hashtables.c       |    7 +++--
 net/ipv4/inet_timewait_sock.c    |   36 ++++++++++++++++++++---------
 net/ipv6/inet6_hashtables.c      |   12 +++++----
 4 files changed, 39 insertions(+), 18 deletions(-)

diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewa=
it_sock.h
index 773b10f..59c80a0 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -199,6 +199,8 @@ static inline __be32 inet_rcv_saddr(const struct so=
ck *sk)
=20
 extern void inet_twsk_put(struct inet_timewait_sock *tw);
=20
+extern void inet_twsk_unhash(struct inet_timewait_sock *tw);
+
 extern struct inet_timewait_sock *inet_twsk_alloc(const struct sock *s=
k,
 						  const int state);
=20
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 94ef51a..143ddb4 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -318,20 +318,21 @@ unique:
 	sk->sk_hash =3D hash;
 	WARN_ON(!sk_unhashed(sk));
 	__sk_nulls_add_node_rcu(sk, &head->chain);
+	if (tw) {
+		inet_twsk_unhash(tw);
+		NET_INC_STATS_BH(net, LINUX_MIB_TIMEWAITRECYCLED);
+	}
 	spin_unlock(lock);
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
=20
 	if (twp) {
 		*twp =3D tw;
-		NET_INC_STATS_BH(net, LINUX_MIB_TIMEWAITRECYCLED);
 	} else if (tw) {
 		/* Silly. Should hash-dance instead... */
 		inet_twsk_deschedule(tw, death_row);
-		NET_INC_STATS_BH(net, LINUX_MIB_TIMEWAITRECYCLED);
=20
 		inet_twsk_put(tw);
 	}
-
 	return 0;
=20
 not_unique:
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_soc=
k.c
index 1f5d508..680d09b 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -14,6 +14,21 @@
 #include <net/inet_timewait_sock.h>
 #include <net/ip.h>
=20
+
+/*
+ * unhash a timewait socket from established hash
+ * lock must be hold by caller
+ */
+void inet_twsk_unhash(struct inet_timewait_sock *tw)
+{
+	if (hlist_nulls_unhashed(&tw->tw_node))
+		return;
+
+	hlist_nulls_del_rcu(&tw->tw_node);
+	sk_nulls_node_init(&tw->tw_node);
+	inet_twsk_put(tw);
+}
+
 /* Must be called with locally disabled BHs. */
 static void __inet_twsk_kill(struct inet_timewait_sock *tw,
 			     struct inet_hashinfo *hashinfo)
@@ -24,12 +39,9 @@ static void __inet_twsk_kill(struct inet_timewait_so=
ck *tw,
 	spinlock_t *lock =3D inet_ehash_lockp(hashinfo, tw->tw_hash);
=20
 	spin_lock(lock);
-	if (hlist_nulls_unhashed(&tw->tw_node)) {
-		spin_unlock(lock);
-		return;
-	}
-	hlist_nulls_del_rcu(&tw->tw_node);
-	sk_nulls_node_init(&tw->tw_node);
+
+	inet_twsk_unhash(tw);
+
 	spin_unlock(lock);
=20
 	/* Disassociate with bind bucket. */
@@ -37,9 +49,11 @@ static void __inet_twsk_kill(struct inet_timewait_so=
ck *tw,
 			hashinfo->bhash_size)];
 	spin_lock(&bhead->lock);
 	tb =3D tw->tw_tb;
-	__hlist_del(&tw->tw_bind_node);
-	tw->tw_tb =3D NULL;
-	inet_bind_bucket_destroy(hashinfo->bind_bucket_cachep, tb);
+	if (tb) {
+		__hlist_del(&tw->tw_bind_node);
+		tw->tw_tb =3D NULL;
+		inet_bind_bucket_destroy(hashinfo->bind_bucket_cachep, tb);
+	}
 	spin_unlock(&bhead->lock);
 #ifdef SOCK_REFCNT_DEBUG
 	if (atomic_read(&tw->tw_refcnt) !=3D 1) {
@@ -47,7 +61,8 @@ static void __inet_twsk_kill(struct inet_timewait_soc=
k *tw,
 		       tw->tw_prot->name, tw, atomic_read(&tw->tw_refcnt));
 	}
 #endif
-	inet_twsk_put(tw);
+	if (tb)
+		inet_twsk_put(tw);
 }
=20
 static noinline void inet_twsk_free(struct inet_timewait_sock *tw)
@@ -92,6 +107,7 @@ void __inet_twsk_hashdance(struct inet_timewait_sock=
 *tw, struct sock *sk,
 	tw->tw_tb =3D icsk->icsk_bind_hash;
 	WARN_ON(!icsk->icsk_bind_hash);
 	inet_twsk_add_bind_node(tw, &tw->tw_tb->owners);
+	atomic_inc(&tw->tw_refcnt);
 	spin_unlock(&bhead->lock);
=20
 	spin_lock(lock);
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 00c6a3e..3681c00 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -250,19 +250,21 @@ unique:
 	 * in hash table socket with a funny identity. */
 	inet->inet_num =3D lport;
 	inet->inet_sport =3D htons(lport);
+	sk->sk_hash =3D hash;
 	WARN_ON(!sk_unhashed(sk));
 	__sk_nulls_add_node_rcu(sk, &head->chain);
-	sk->sk_hash =3D hash;
+	if (tw) {
+		inet_twsk_unhash(tw);
+		NET_INC_STATS_BH(net, LINUX_MIB_TIMEWAITRECYCLED);
+	}
 	spin_unlock(lock);
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
=20
-	if (twp !=3D NULL) {
+	if (twp) {
 		*twp =3D tw;
-		NET_INC_STATS_BH(net, LINUX_MIB_TIMEWAITRECYCLED);
-	} else if (tw !=3D NULL) {
+	} else if (tw) {
 		/* Silly. Should hash-dance instead... */
 		inet_twsk_deschedule(tw, death_row);
-		NET_INC_STATS_BH(net, LINUX_MIB_TIMEWAITRECYCLED);
=20
 		inet_twsk_put(tw);
 	}
