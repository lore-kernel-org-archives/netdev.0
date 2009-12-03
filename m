From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] tcp: connect() race with timewait reuse
Date: Thu, 03 Dec 2009 09:31:19 +0100
Message-ID: <4B177757.3010407@gmail.com>
References: <99d458640911301802i4bde20f4wa314668d543e3170@mail.gmail.com> <4B152F97.1090409@gmail.com> <20091202.005937.177088443.davem@davemloft.net> <4B163226.50801@gmail.com> <4B164293.7070804@gmail.com> <4B16830B.4010801@gmail.com> <20091202221552.GA17579@ioremap.net> <4B175E65.3070905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kdakhane@gmail.com, netdev@vger.kernel.org,
	netfilter@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54156 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753276AbZLCIbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 03:31:17 -0500
In-Reply-To: <4B175E65.3070905@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
>
>=20
> You are probably right, we could defer the inet_twsk_put(tw) out of l=
ocked
> section, you or I will submit another patch to correct this.
>=20

Here is an updated patch, tested on my dev machine.

I found another problem about tw refcnt I am going to address ASAP.

Thanks !

[PATCH net-next-2.6] tcp: connect() race with timewait reuse

Its currently possible that several threads issuing a connect() find th=
e same
timewait socket and try to reuse it, leading to list corruptions.

Condition for bug is that these threads bound their socket on same addr=
ess/port
of to-be-find timewait socket, and connected to same target. (SO_REUSEA=
DDR needed)

To fix this problem, we could unhash timewait socket while holding ehas=
h lock,
to make sure lookups/changes will be serialized. Only first thread find=
s the timewait
socket, other ones find the established socket and return an EADDRNOTAV=
AIL error.

This second version takes into account Evgeniy's review and makes sure
inet_twsk_put() is called outside of locked sections.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/inet_timewait_sock.h |    2 +
 net/ipv4/inet_hashtables.c       |   10 +++++--
 net/ipv4/inet_timewait_sock.c    |   38 +++++++++++++++++++++--------
 net/ipv6/inet6_hashtables.c      |   15 +++++++----
 4 files changed, 47 insertions(+), 18 deletions(-)

diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewa=
it_sock.h
index 773b10f..cb7d93b 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -199,6 +199,8 @@ static inline __be32 inet_rcv_saddr(const struct so=
ck *sk)
=20
 extern void inet_twsk_put(struct inet_timewait_sock *tw);
=20
+extern int inet_twsk_unhash(struct inet_timewait_sock *tw);
+
 extern struct inet_timewait_sock *inet_twsk_alloc(const struct sock *s=
k,
 						  const int state);
=20
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 94ef51a..30e73c5 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -286,6 +286,7 @@ static int __inet_check_established(struct inet_tim=
ewait_death_row *death_row,
 	struct sock *sk2;
 	const struct hlist_nulls_node *node;
 	struct inet_timewait_sock *tw;
+	int twrefcnt =3D 0;
=20
 	spin_lock(lock);
=20
@@ -318,20 +319,23 @@ unique:
 	sk->sk_hash =3D hash;
 	WARN_ON(!sk_unhashed(sk));
 	__sk_nulls_add_node_rcu(sk, &head->chain);
+	if (tw) {
+		twrefcnt =3D inet_twsk_unhash(tw);
+		NET_INC_STATS_BH(net, LINUX_MIB_TIMEWAITRECYCLED);
+	}
 	spin_unlock(lock);
+	if (twrefcnt)
+		inet_twsk_put(tw);
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
index 1f5d508..11380e6 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -14,22 +14,33 @@
 #include <net/inet_timewait_sock.h>
 #include <net/ip.h>
=20
+
+/*
+ * unhash a timewait socket from established hash
+ * lock must be hold by caller
+ */
+int inet_twsk_unhash(struct inet_timewait_sock *tw)
+{
+	if (hlist_nulls_unhashed(&tw->tw_node))
+		return 0;
+
+	hlist_nulls_del_rcu(&tw->tw_node);
+	sk_nulls_node_init(&tw->tw_node);
+	return 1;
+}
+
 /* Must be called with locally disabled BHs. */
 static void __inet_twsk_kill(struct inet_timewait_sock *tw,
 			     struct inet_hashinfo *hashinfo)
 {
 	struct inet_bind_hashbucket *bhead;
 	struct inet_bind_bucket *tb;
+	int refcnt;
 	/* Unlink from established hashes. */
 	spinlock_t *lock =3D inet_ehash_lockp(hashinfo, tw->tw_hash);
=20
 	spin_lock(lock);
-	if (hlist_nulls_unhashed(&tw->tw_node)) {
-		spin_unlock(lock);
-		return;
-	}
-	hlist_nulls_del_rcu(&tw->tw_node);
-	sk_nulls_node_init(&tw->tw_node);
+	refcnt =3D inet_twsk_unhash(tw);
 	spin_unlock(lock);
=20
 	/* Disassociate with bind bucket. */
@@ -37,9 +48,12 @@ static void __inet_twsk_kill(struct inet_timewait_so=
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
+		refcnt++;
+	}
 	spin_unlock(&bhead->lock);
 #ifdef SOCK_REFCNT_DEBUG
 	if (atomic_read(&tw->tw_refcnt) !=3D 1) {
@@ -47,7 +61,10 @@ static void __inet_twsk_kill(struct inet_timewait_so=
ck *tw,
 		       tw->tw_prot->name, tw, atomic_read(&tw->tw_refcnt));
 	}
 #endif
-	inet_twsk_put(tw);
+	while (refcnt) {
+		inet_twsk_put(tw);
+		refcnt--;
+	}
 }
=20
 static noinline void inet_twsk_free(struct inet_timewait_sock *tw)
@@ -92,6 +109,7 @@ void __inet_twsk_hashdance(struct inet_timewait_sock=
 *tw, struct sock *sk,
 	tw->tw_tb =3D icsk->icsk_bind_hash;
 	WARN_ON(!icsk->icsk_bind_hash);
 	inet_twsk_add_bind_node(tw, &tw->tw_tb->owners);
+	atomic_inc(&tw->tw_refcnt);
 	spin_unlock(&bhead->lock);
=20
 	spin_lock(lock);
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 00c6a3e..7207801 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -223,6 +223,7 @@ static int __inet6_check_established(struct inet_ti=
mewait_death_row *death_row,
 	struct sock *sk2;
 	const struct hlist_nulls_node *node;
 	struct inet_timewait_sock *tw;
+	int twrefcnt =3D 0;
=20
 	spin_lock(lock);
=20
@@ -250,19 +251,23 @@ unique:
 	 * in hash table socket with a funny identity. */
 	inet->inet_num =3D lport;
 	inet->inet_sport =3D htons(lport);
+	sk->sk_hash =3D hash;
 	WARN_ON(!sk_unhashed(sk));
 	__sk_nulls_add_node_rcu(sk, &head->chain);
-	sk->sk_hash =3D hash;
+	if (tw) {
+		twrefcnt =3D inet_twsk_unhash(tw);
+		NET_INC_STATS_BH(net, LINUX_MIB_TIMEWAITRECYCLED);
+	}
 	spin_unlock(lock);
+	if (twrefcnt)
+		inet_twsk_put(tw);
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
