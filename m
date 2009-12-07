From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: documents timewait refcnt tricks
Date: Mon, 07 Dec 2009 10:59:41 +0100
Message-ID: <4B1CD20D.8030407@gmail.com>
References: <99d458640911301802i4bde20f4wa314668d543e3170@mail.gmail.com> <4B152F97.1090409@gmail.com> <4B1912CE.5040304@gmail.com> <20091205212148.GA26270@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kapil dakhane <kdakhane@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <20091205212148.GA26270@ioremap.net>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov a =E9crit :
> Hi Eric.
>=20
> On Fri, Dec 04, 2009 at 02:46:54PM +0100, Eric Dumazet (eric.dumazet@=
gmail.com) wrote:
>> First patch changes __inet_hash_nolisten() and __inet6_hash()
>> to get a timewait parameter to be able to unhash it from ehash
>> at same time the new socket is inserted in hash.
>>
>> This makes sure timewait socket wont be found by a concurrent
>> writer in __inet_check_established()
>=20
> Both patches look good, although trick with returning reference count=
er
> may look like a hack especially when only viewing into ip code and no=
t
> hashtable itself. Can you please cook up a documentation update for h=
ash
> function that it is supposed to return refcnt when socket was in hash
> table.
>=20

Sure, here it is :

Thanks !

[PATCH] tcp: documents timewait refcnt tricks=20

Adds kerneldoc for inet_twsk_unhash() & inet_twsk_bind_unhash().

Suggested-by: Evgeniy Polyakov <zbr@ioremap.net>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_soc=
k.c
index 1958cf5..cf719c2 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -15,9 +15,13 @@
 #include <net/ip.h>
=20
=20
-/*
- * unhash a timewait socket from established hash
- * lock must be hold by caller
+/**
+ *	inet_twsk_unhash - unhash a timewait socket from established hash
+ *	@tw: timewait socket
+ *
+ *	unhash a timewait socket from established hash, if hashed.
+ *	ehash lock must be hold by caller.
+ *	Returns 1 if caller should call inet_twsk_put() after lock release.
  */
 int inet_twsk_unhash(struct inet_timewait_sock *tw)
 {
@@ -26,12 +30,21 @@ int inet_twsk_unhash(struct inet_timewait_sock *tw)
=20
 	hlist_nulls_del_rcu(&tw->tw_node);
 	sk_nulls_node_init(&tw->tw_node);
+	/*
+	 * We cannot call inet_twsk_put() ourself under lock,
+	 * caller must call it for us.
+	 */
 	return 1;
 }
=20
-/*
- * unhash a timewait socket from bind hash
- * lock must be hold by caller
+/**
+ *	inet_twsk_bind_unhash - unhash a timewait socket from bind hash
+ *	@tw: timewait socket
+ *	@hashinfo: hashinfo pointer
+ *
+ *	unhash a timewait socket from bind hash, if hashed.
+ *	bind hash lock must be hold by caller.
+ *	Returns 1 if caller should call inet_twsk_put() after lock release.
  */
 int inet_twsk_bind_unhash(struct inet_timewait_sock *tw,
 			  struct inet_hashinfo *hashinfo)
@@ -44,6 +57,10 @@ int inet_twsk_bind_unhash(struct inet_timewait_sock =
*tw,
 	__hlist_del(&tw->tw_bind_node);
 	tw->tw_tb =3D NULL;
 	inet_bind_bucket_destroy(hashinfo->bind_bucket_cachep, tb);
+	/*
+	 * We cannot call inet_twsk_put() ourself under lock,
+	 * caller must call it for us.
+	 */
 	return 1;
 }
=20
@@ -140,7 +157,7 @@ void __inet_twsk_hashdance(struct inet_timewait_soc=
k *tw, struct sock *sk,
=20
 	/*
 	 * Notes :
- 	 * - We initially set tw_refcnt to 0 in inet_twsk_alloc()
+	 * - We initially set tw_refcnt to 0 in inet_twsk_alloc()
 	 * - We add one reference for the bhash link
 	 * - We add one reference for the ehash link
 	 * - We want this refcnt update done before allowing other
@@ -150,7 +167,6 @@ void __inet_twsk_hashdance(struct inet_timewait_soc=
k *tw, struct sock *sk,
=20
 	spin_unlock(lock);
 }
-
 EXPORT_SYMBOL_GPL(__inet_twsk_hashdance);
=20
 struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk, cons=
t int state)
@@ -191,7 +207,6 @@ struct inet_timewait_sock *inet_twsk_alloc(const st=
ruct sock *sk, const int stat
=20
 	return tw;
 }
-
 EXPORT_SYMBOL_GPL(inet_twsk_alloc);
=20
 /* Returns non-zero if quota exceeded.  */
@@ -270,7 +285,6 @@ void inet_twdr_hangman(unsigned long data)
 out:
 	spin_unlock(&twdr->death_lock);
 }
-
 EXPORT_SYMBOL_GPL(inet_twdr_hangman);
=20
 void inet_twdr_twkill_work(struct work_struct *work)
@@ -301,7 +315,6 @@ void inet_twdr_twkill_work(struct work_struct *work=
)
 		spin_unlock_bh(&twdr->death_lock);
 	}
 }
-
 EXPORT_SYMBOL_GPL(inet_twdr_twkill_work);
=20
 /* These are always called from BH context.  See callers in
@@ -321,7 +334,6 @@ void inet_twsk_deschedule(struct inet_timewait_sock=
 *tw,
 	spin_unlock(&twdr->death_lock);
 	__inet_twsk_kill(tw, twdr->hashinfo);
 }
-
 EXPORT_SYMBOL(inet_twsk_deschedule);
=20
 void inet_twsk_schedule(struct inet_timewait_sock *tw,
@@ -402,7 +414,6 @@ void inet_twsk_schedule(struct inet_timewait_sock *=
tw,
 		mod_timer(&twdr->tw_timer, jiffies + twdr->period);
 	spin_unlock(&twdr->death_lock);
 }
-
 EXPORT_SYMBOL_GPL(inet_twsk_schedule);
=20
 void inet_twdr_twcal_tick(unsigned long data)
@@ -463,7 +474,6 @@ out:
 #endif
 	spin_unlock(&twdr->death_lock);
 }
-
 EXPORT_SYMBOL_GPL(inet_twdr_twcal_tick);
=20
 void inet_twsk_purge(struct inet_hashinfo *hashinfo,
