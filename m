From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: fix a timewait refcnt race
Date: Thu, 03 Dec 2009 11:49:01 +0100
Message-ID: <4B17979D.4040301@gmail.com>
References: <99d458640911301802i4bde20f4wa314668d543e3170@mail.gmail.com>	 <4B152F97.1090409@gmail.com>	 <20091202.005937.177088443.davem@davemloft.net>	 <4B163226.50801@gmail.com> <4B164293.7070804@gmail.com>	 <20091202113213.GA18453@ioremap.net>	 <99d458640912021118y42a6fe4bm7b742a2046ad7a3b@mail.gmail.com> <99d458640912021843y21ad07a4j724003328da07e9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter@vger.kernel.org, Evgeniy Polyakov <zbr@ioremap.net>
To: kapil dakhane <kdakhane@gmail.com>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <99d458640912021843y21ad07a4j724003328da07e9@mail.gmail.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

kapil dakhane a =E9crit :

> Either there are more places for race condition, or the fix didn't
> address the issue effectively.

Thanks a lot for all these details ! It definitly is very usefull to
localize problems.

I believe I found another timewait problem, I am not sure
it is what makes your test fail, but we make progress :)

I cooked a patch against last net-next-2.6 + my previous patch.

(2nd take of [PATCH net-next-2.6] tcp: connect() race with timewait reu=
se)

[PATCH net-next-2.6] tcp: fix a timewait refcnt race

After TCP RCU conversion, tw->tw_refcnt should not be set to 1 in
inet_twsk_alloc(). It allows a RCU reader to get this timewait
socket, while we not yet stabilized it.

Only choice we have is to set tw_refcnt to 0 in inet_twsk_alloc(),
then atomic_add() it later, once everything is done.

Location of this atomic_add() is tricky, because we dont want another
writer to find this timewait in ehash, while tw_refcnt is still zero !

Thanks to Kapil Dakhane tests and reports.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/inet_timewait_sock.c |   19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)


diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_soc=
k.c
index 11380e6..91680ec 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -109,7 +109,6 @@ void __inet_twsk_hashdance(struct inet_timewait_soc=
k *tw, struct sock *sk,
 	tw->tw_tb =3D icsk->icsk_bind_hash;
 	WARN_ON(!icsk->icsk_bind_hash);
 	inet_twsk_add_bind_node(tw, &tw->tw_tb->owners);
-	atomic_inc(&tw->tw_refcnt);
 	spin_unlock(&bhead->lock);
=20
 	spin_lock(lock);
@@ -119,13 +118,22 @@ void __inet_twsk_hashdance(struct inet_timewait_s=
ock *tw, struct sock *sk,
 	 * Should be done before removing sk from established chain
 	 * because readers are lockless and search established first.
 	 */
-	atomic_inc(&tw->tw_refcnt);
 	inet_twsk_add_node_rcu(tw, &ehead->twchain);
=20
 	/* Step 3: Remove SK from established hash. */
 	if (__sk_nulls_del_node_init_rcu(sk))
 		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
=20
+	/*
+	 * Notes :
+ 	 * - We initially set tw_refcnt to 0 in inet_twsk_alloc()
+	 * - We add one reference for the bhash link
+	 * - We add one reference for the ehash link
+	 * - We want this refcnt update done before allowing other
+	 *   threads to find this tw in ehash chain.
+	 */
+	atomic_add(1 + 1 + 1, &tw->tw_refcnt);
+
 	spin_unlock(lock);
 }
=20
@@ -157,7 +165,12 @@ struct inet_timewait_sock *inet_twsk_alloc(const s=
truct sock *sk, const int stat
 		tw->tw_transparent  =3D inet->transparent;
 		tw->tw_prot	    =3D sk->sk_prot_creator;
 		twsk_net_set(tw, hold_net(sock_net(sk)));
-		atomic_set(&tw->tw_refcnt, 1);
+		/*
+		 * Because we use RCU lookups, we should not set tw_refcnt
+		 * to a non null value before everything is setup for this
+		 * timewait socket.
+		 */
+		atomic_set(&tw->tw_refcnt, 0);
 		inet_twsk_dead_node_init(tw);
 		__module_get(tw->tw_prot->owner);
 	}
