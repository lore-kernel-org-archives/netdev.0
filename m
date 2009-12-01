From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: Fix a connect() race with timewait sockets
Date: Tue, 01 Dec 2009 16:00:39 +0100
Message-ID: <4B152F97.1090409@gmail.com>
References: <99d458640911301802i4bde20f4wa314668d543e3170@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Evgeniy Polyakov <zbr@ioremap.net>
To: kapil dakhane <kdakhane@gmail.com>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <99d458640911301802i4bde20f4wa314668d543e3170@mail.gmail.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

kapil dakhane a =E9crit :
> Hello,
>=20
> I am trying to analyze the capacity of linux network stack on x6270
> which has 16 Hyper threads on two 8-core Intel(r) Xeon(r) CPU. I see
> that at around 150000 simultaneous connections, after around 1.6 gbps=
,
> a cpu get stuck in an infinite loop in inet_csk_bind_conflict, then
> other cpus get locked up doing spin_lock. Before the lockup cpu usage
> was around 25%. It appears to be a bug, unless I am hitting some kind
> of resource limit. It would be good if someone familiar with network
> code would confirm this, or point me in the right direction.
>=20
> Important details are:
>=20
> I am using kernel version 2.6.31.4 recompiled with TPROXY related
> options: NF_CONNTRACK, NETFILTER_TPROXY, NETFILTER_XT_MATCH_SOCKET,
> NETFILTER_XT_TARGET_TPROXY.
>=20
>=20
> I have enabled transparent capture and transparent forward using
> iptables and ip rules.  I have 10 instances of a single threaded user
> space bits-forwarding-proxy (fast), each bound to different
> hyper-threads (CPUs). Rest 6 CPUs are dedicated to interrupt
> processing, each handling interrupts from six different network cards=
=2E
> TCP flow from a 4-tuple always get handled by the same proxy process,
> interrupt thread, and network card. In this way, network traffic is
> segregated as much as possible to achieve high degree of parallelism.
>=20
> First /var/log/message entry shows CPU#7 is stuck in inet_csk_bind_co=
nflict
>=20
> Nov 17 23:02:04 cap-x6270-01 kernel: BUG: soft lockup - CPU#7 stuck
> for 61s! [fast:20701]

After some more audit and coffee, I finally found one subtle bug in our
connect() code, that periodically triggers but never got tracked.

Here is a patch cooked on top of current linux-2.6 git tree, it should =
probably
apply on 2.6.31.6 as well...

Thanks

[PATCH] tcp: Fix a connect() race with timewait sockets

When we find a timewait connection in __inet_hash_connect() and reuse
it for a new connection request, we have a race window, releasing bind
list lock and reacquiring it in __inet_twsk_kill() to remove timewait
socket from list.

Another thread might find the timewait socket we already chose, leading=
 to
list corruption and crashes.

=46ix is to remove timewait socket from bind list before releasing the =
lock.

Reported-by: kapil dakhane <kdakhane@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/inet_timewait_sock.h |    4 +++
 net/ipv4/inet_hashtables.c       |    4 +++
 net/ipv4/inet_timewait_sock.c    |   37 ++++++++++++++++++++---------
 3 files changed, 34 insertions(+), 11 deletions(-)

diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewa=
it_sock.h
index f93ad90..e18e5df 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -206,6 +206,10 @@ extern void __inet_twsk_hashdance(struct inet_time=
wait_sock *tw,
 				  struct sock *sk,
 				  struct inet_hashinfo *hashinfo);
=20
+extern void inet_twsk_unhash(struct inet_timewait_sock *tw,
+			     struct inet_hashinfo *hashinfo,
+			     bool mustlock);
+
 extern void inet_twsk_schedule(struct inet_timewait_sock *tw,
 			       struct inet_timewait_death_row *twdr,
 			       const int timeo, const int timewait_len);
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 625cc5f..76d81e4 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -488,6 +488,10 @@ ok:
 			inet_sk(sk)->sport =3D htons(port);
 			hash(sk);
 		}
+
+		if (tw)
+			inet_twsk_unhash(tw, hinfo, false);
+
 		spin_unlock(&head->lock);
=20
 		if (tw) {
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_soc=
k.c
index 13f0781..2d6d543 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -14,12 +14,34 @@
 #include <net/inet_timewait_sock.h>
 #include <net/ip.h>
=20
+
+void inet_twsk_unhash(struct inet_timewait_sock *tw,
+		      struct inet_hashinfo *hashinfo,
+		      bool mustlock)
+{
+	struct inet_bind_hashbucket *bhead;
+	struct inet_bind_bucket *tb =3D tw->tw_tb;
+
+	if (!tb)
+		return;
+
+	/* Disassociate with bind bucket. */
+	bhead =3D &hashinfo->bhash[inet_bhashfn(twsk_net(tw),
+					      tw->tw_num,
+					      hashinfo->bhash_size)];
+	if (mustlock)
+		spin_lock(&bhead->lock);
+	__hlist_del(&tw->tw_bind_node);
+	tw->tw_tb =3D NULL;
+	inet_bind_bucket_destroy(hashinfo->bind_bucket_cachep, tb);
+	if (mustlock)
+		spin_unlock(&bhead->lock);
+}
+
 /* Must be called with locally disabled BHs. */
 static void __inet_twsk_kill(struct inet_timewait_sock *tw,
 			     struct inet_hashinfo *hashinfo)
 {
-	struct inet_bind_hashbucket *bhead;
-	struct inet_bind_bucket *tb;
 	/* Unlink from established hashes. */
 	spinlock_t *lock =3D inet_ehash_lockp(hashinfo, tw->tw_hash);
=20
@@ -32,15 +54,8 @@ static void __inet_twsk_kill(struct inet_timewait_so=
ck *tw,
 	sk_nulls_node_init(&tw->tw_node);
 	spin_unlock(lock);
=20
-	/* Disassociate with bind bucket. */
-	bhead =3D &hashinfo->bhash[inet_bhashfn(twsk_net(tw), tw->tw_num,
-			hashinfo->bhash_size)];
-	spin_lock(&bhead->lock);
-	tb =3D tw->tw_tb;
-	__hlist_del(&tw->tw_bind_node);
-	tw->tw_tb =3D NULL;
-	inet_bind_bucket_destroy(hashinfo->bind_bucket_cachep, tb);
-	spin_unlock(&bhead->lock);
+	inet_twsk_unhash(tw, hashinfo, true);
+
 #ifdef SOCK_REFCNT_DEBUG
 	if (atomic_read(&tw->tw_refcnt) !=3D 1) {
 		printk(KERN_DEBUG "%s timewait_sock %p refcnt=3D%d\n",
