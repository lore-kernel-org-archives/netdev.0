From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Flush per-ns routing cache more sanely.
Date: Sun, 19 Dec 2010 21:14:53 -0800 (PST)
Message-ID: <20101219.211453.226783693.davem@davemloft.net>
References: <m1sjzs3hbw.fsf@fess.ebiederm.org>
	<20101026.122022.241452738.davem@davemloft.net>
	<1288121422.2652.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ebiederm@xmission.com, netdev@vger.kernel.org,
	daniel.lezcano@free.fr
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42798
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751633Ab0LTFOY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Dec 2010 00:14:24 -0500
In-Reply-To: <1288121422.2652.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 26 Oct 2010 21:30:22 +0200

> Le mardi 26 octobre 2010 =E0 12:20 -0700, David Miller a =E9crit :
>> From: ebiederm@xmission.com (Eric W. Biederman)
>> Date: Tue, 26 Oct 2010 12:05:39 -0700
>>=20
>> >> @@ -999,7 +999,7 @@ static int fib_netdev_event(struct notifier_b=
lock *this, unsigned long event, vo
>> >>  		rt_cache_flush(dev_net(dev), 0);
>> >>  		break;
>> >>  	case NETDEV_UNREGISTER_BATCH:
>> >> -		rt_cache_flush_batch();
>> >> +		rt_cache_flush_batch(dev_net(dev));
>> >=20
>> > It still has this incorrect conversion in it.
>>=20
>> Sorry I missed that, what's the exact problem with it?
>=20
> Because the way _BATCH operation is performed, we call it once...
>=20
> rollback_registered_many() calls it for the first dev queued in the
> list.
>=20
> So it should be net independant.

Thanks Eric.  I finally got back to fixing this issue and respinning
the patch.

Please review, in particular how I handled the RCU bits.

--------------------
ipv4: Flush per-ns routing cache more sanely.

=46lush the routing cache only of entries that match the
network namespace in which the purge event occurred.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h     |    2 +-
 net/ipv4/fib_frontend.c |    6 +++-
 net/ipv4/route.c        |   68 ++++++++++++++++++---------------------=
--------
 3 files changed, 32 insertions(+), 44 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 2700236..93e10c4 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -114,7 +114,7 @@ extern int		ip_rt_init(void);
 extern void		ip_rt_redirect(__be32 old_gw, __be32 dst, __be32 new_gw,
 				       __be32 src, struct net_device *dev);
 extern void		rt_cache_flush(struct net *net, int how);
-extern void		rt_cache_flush_batch(void);
+extern void		rt_cache_flush_batch(struct net *net);
 extern int		__ip_route_output_key(struct net *, struct rtable **, cons=
t struct flowi *flp);
 extern int		ip_route_output_key(struct net *, struct rtable **, struct=
 flowi *flp);
 extern int		ip_route_output_flow(struct net *, struct rtable **rp, str=
uct flowi *flp, struct sock *sk, int flags);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index d3a1112..9f8bb68 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -987,7 +987,11 @@ static int fib_netdev_event(struct notifier_block =
*this, unsigned long event, vo
 		rt_cache_flush(dev_net(dev), 0);
 		break;
 	case NETDEV_UNREGISTER_BATCH:
-		rt_cache_flush_batch();
+		/* The batch unregister is only called on the first
+		 * device in the list of devices being unregistered.
+		 * Therefore we should not pass dev_net(dev) in here.
+		 */
+		rt_cache_flush_batch(NULL);
 		break;
 	}
 	return NOTIFY_DONE;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index ae52096..7c87d8e 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -717,13 +717,15 @@ static inline int rt_is_expired(struct rtable *rt=
h)
  * Can be called by a softirq or a process.
  * In the later case, we want to be reschedule if necessary
  */
-static void rt_do_flush(int process_context)
+static void rt_do_flush(struct net *net, int process_context)
 {
 	unsigned int i;
 	struct rtable *rth, *next;
-	struct rtable * tail;
=20
 	for (i =3D 0; i <=3D rt_hash_mask; i++) {
+		struct rtable __rcu **pprev;
+		struct rtable *list;
+
 		if (process_context && need_resched())
 			cond_resched();
 		rth =3D rcu_dereference_raw(rt_hash_table[i].chain);
@@ -731,52 +733,34 @@ static void rt_do_flush(int process_context)
 			continue;
=20
 		spin_lock_bh(rt_hash_lock_addr(i));
-#ifdef CONFIG_NET_NS
-		{
-		struct rtable __rcu **prev;
-		struct rtable *p;
=20
-		rth =3D rcu_dereference_protected(rt_hash_table[i].chain,
+		list =3D NULL;
+		pprev =3D &rt_hash_table[i].chain;
+		rth =3D rcu_dereference_protected(*pprev,
 			lockdep_is_held(rt_hash_lock_addr(i)));
=20
-		/* defer releasing the head of the list after spin_unlock */
-		for (tail =3D rth; tail;
-		     tail =3D rcu_dereference_protected(tail->dst.rt_next,
-				lockdep_is_held(rt_hash_lock_addr(i))))
-			if (!rt_is_expired(tail))
-				break;
-		if (rth !=3D tail)
-			rt_hash_table[i].chain =3D tail;
-
-		/* call rt_free on entries after the tail requiring flush */
-		prev =3D &rt_hash_table[i].chain;
-		for (p =3D rcu_dereference_protected(*prev,
-				lockdep_is_held(rt_hash_lock_addr(i)));
-		     p !=3D NULL;
-		     p =3D next) {
-			next =3D rcu_dereference_protected(p->dst.rt_next,
+		while (rth) {
+			next =3D rcu_dereference_protected(rth->dst.rt_next,
 				lockdep_is_held(rt_hash_lock_addr(i)));
-			if (!rt_is_expired(p)) {
-				prev =3D &p->dst.rt_next;
+
+			if (!net ||
+			    net_eq(dev_net(rth->dst.dev), net)) {
+				rcu_assign_pointer(*pprev, next);
+				rcu_assign_pointer(rth->dst.rt_next, list);
+				list =3D rth;
 			} else {
-				*prev =3D next;
-				rt_free(p);
+				pprev =3D &rth->dst.rt_next;
 			}
+			rth =3D next;
 		}
-		}
-#else
-		rth =3D rcu_dereference_protected(rt_hash_table[i].chain,
-			lockdep_is_held(rt_hash_lock_addr(i)));
-		rcu_assign_pointer(rt_hash_table[i].chain, NULL);
-		tail =3D NULL;
-#endif
+
 		spin_unlock_bh(rt_hash_lock_addr(i));
=20
-		for (; rth !=3D tail; rth =3D next) {
-			next =3D rcu_dereference_protected(rth->dst.rt_next, 1);
-			rt_free(rth);
-		}
-	}
+		for (; list; list =3D next) {
+			next =3D rcu_dereference_protected(list->dst.rt_next, 1);
+			rt_free(list);
+ 		}
+	}=09
 }
=20
 /*
@@ -922,13 +906,13 @@ void rt_cache_flush(struct net *net, int delay)
 {
 	rt_cache_invalidate(net);
 	if (delay >=3D 0)
-		rt_do_flush(!in_softirq());
+		rt_do_flush(net, !in_softirq());
 }
=20
 /* Flush previous cache invalidated entries from the cache */
-void rt_cache_flush_batch(void)
+void rt_cache_flush_batch(struct net *net)
 {
-	rt_do_flush(!in_softirq());
+	rt_do_flush(net, !in_softirq());
 }
=20
 static void rt_emergency_hash_rebuild(struct net *net)
--=20
1.7.3.4

