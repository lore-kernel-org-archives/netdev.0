From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: neigh_periodic_timer expires too often
Date: Thu, 30 Jul 2009 15:15:07 +0200
Message-ID: <4A719CDB.3060004@gmail.com>
References: <4A717985.7060909@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, tero.kristo@nokia.com
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50679 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921AbZG3NPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 09:15:10 -0400
In-Reply-To: <4A717985.7060909@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Luciano Coelho a =E9crit :
> Hi,
>=20
> We were making some measurements and trying to figure out which timer=
s
> in the kernel can be made deferrable so that our device doesn't have =
to
> wake up too often.
>=20
> During this investigation, we found out that the neigh_periodic_timer=
 is
> expiring approximately every 8 seconds, even when we don't have a
> network connection established.  After the connection is established,
> the timer starts expiring every 2 seconds and continues to expire at
> this interval after the connection is closed.
>=20
> We have been converting many of the kernel times to deferrable timers=
=2E=20
> Checking the netdev mailing list archives, I found out that this issu=
e
> has been discussed in December 2007 [1], but the thread seems to have
> died out and the proposed patch has never been applied AFAICS.
>=20
> Another proposed solution, which has never been applied either, was t=
o
> convert this timer from softirq-based to workqueue-based [2].  Would
> that be any better?
>=20
> So, my question is, does it make sense to make this timer deferrable =
or
> use the workqueue instead? Or is there any other better solution to
> avoid unnecessarily frequent wakeups caused by neigh_periodic_timer?
>=20
> We are using a kernel based on 2.6.28.
>=20
> [1] http://article.gmane.org/gmane.linux.network/81361
> [2] http://article.gmane.org/gmane.linux.network/81140
>=20
Hi Luciano

Thank you for reminding us this stuff !

You are mixing two different problems here.

=46irst patch you link (from Stephen Hemminger) was using deferrable ti=
mer for
individual entry (function neigh_timer_handler()). Probably not your
current concern.

Second patch you link (from me) was using a workqueue (instead of a tim=
er)
for garbage collection of whole table.

I bet you are more intested about the garbage collection problem
(function neigh_periodic_timer()) so I could try to resurrect
my patch. I guess at that time Parag didnt replied to my mail...

If nobody cared, patch was not considered for inclusion. Thats all.

So please test it and tell me/us you like it :)

Thanks

[PATCH net-next-2.6] neigh: Convert garbage collection from softirq to =
workqueue

Current neigh_periodic_timer() function is fired by timer IRQ, and
scans one hash bucket each round (very litle work in fact)

As we are supposed to scan whole hash table in 15 seconds, this means
neigh_periodic_timer() can be fired very often. (depending on the numbe=
r
of concurrent hash entries we stored in this table)

Converting this to a workqueue permits scanning whole table, minimizing
icache pollution, and firing this work every 15 seconds, independantly
of hash table size.

This 15 seconds delay is not a hard number, as work is a deferrable one=
=2E

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/neighbour.h |    4 -
 net/core/neighbour.c    |   89 ++++++++++++++++++--------------------
 2 files changed, 45 insertions(+), 48 deletions(-)


diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index d8d790e..18b69b6 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -24,6 +24,7 @@
=20
 #include <linux/err.h>
 #include <linux/sysctl.h>
+#include <linux/workqueue.h>
 #include <net/rtnetlink.h>
=20
 /*
@@ -167,7 +168,7 @@ struct neigh_table
 	int			gc_thresh2;
 	int			gc_thresh3;
 	unsigned long		last_flush;
-	struct timer_list 	gc_timer;
+	struct delayed_work	gc_work;
 	struct timer_list 	proxy_timer;
 	struct sk_buff_head	proxy_queue;
 	atomic_t		entries;
@@ -178,7 +179,6 @@ struct neigh_table
 	struct neighbour	**hash_buckets;
 	unsigned int		hash_mask;
 	__u32			hash_rnd;
-	unsigned int		hash_chain_gc;
 	struct pneigh_entry	**phash_buckets;
 };
=20
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index c6f9ad8..e587e68 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -692,75 +692,74 @@ static void neigh_connect(struct neighbour *neigh=
)
 		hh->hh_output =3D neigh->ops->hh_output;
 }
=20
-static void neigh_periodic_timer(unsigned long arg)
+static void neigh_periodic_work(struct work_struct *work)
 {
-	struct neigh_table *tbl =3D (struct neigh_table *)arg;
+	struct neigh_table *tbl =3D container_of(work, struct neigh_table, gc=
_work.work);
 	struct neighbour *n, **np;
-	unsigned long expire, now =3D jiffies;
+	unsigned int i;
=20
 	NEIGH_CACHE_STAT_INC(tbl, periodic_gc_runs);
=20
-	write_lock(&tbl->lock);
+	write_lock_bh(&tbl->lock);
=20
 	/*
 	 *	periodically recompute ReachableTime from random function
 	 */
=20
-	if (time_after(now, tbl->last_rand + 300 * HZ)) {
+	if (time_after(jiffies, tbl->last_rand + 300 * HZ)) {
 		struct neigh_parms *p;
-		tbl->last_rand =3D now;
+		tbl->last_rand =3D jiffies;
 		for (p =3D &tbl->parms; p; p =3D p->next)
 			p->reachable_time =3D
 				neigh_rand_reach_time(p->base_reachable_time);
 	}
=20
-	np =3D &tbl->hash_buckets[tbl->hash_chain_gc];
-	tbl->hash_chain_gc =3D ((tbl->hash_chain_gc + 1) & tbl->hash_mask);
+	for (i =3D 0 ; i <=3D tbl->hash_mask; i++) {
+		np =3D &tbl->hash_buckets[i];
=20
-	while ((n =3D *np) !=3D NULL) {
-		unsigned int state;
+		while ((n =3D *np) !=3D NULL) {
+			unsigned int state;
=20
-		write_lock(&n->lock);
+			write_lock(&n->lock);
=20
-		state =3D n->nud_state;
-		if (state & (NUD_PERMANENT | NUD_IN_TIMER)) {
-			write_unlock(&n->lock);
-			goto next_elt;
-		}
+			state =3D n->nud_state;
+			if (state & (NUD_PERMANENT | NUD_IN_TIMER)) {
+				write_unlock(&n->lock);
+				goto next_elt;
+			}
=20
-		if (time_before(n->used, n->confirmed))
-			n->used =3D n->confirmed;
+			if (time_before(n->used, n->confirmed))
+				n->used =3D n->confirmed;
=20
-		if (atomic_read(&n->refcnt) =3D=3D 1 &&
-		    (state =3D=3D NUD_FAILED ||
-		     time_after(now, n->used + n->parms->gc_staletime))) {
-			*np =3D n->next;
-			n->dead =3D 1;
+			if (atomic_read(&n->refcnt) =3D=3D 1 &&
+			    (state =3D=3D NUD_FAILED ||
+			     time_after(jiffies, n->used + n->parms->gc_staletime))) {
+				*np =3D n->next;
+				n->dead =3D 1;
+				write_unlock(&n->lock);
+				neigh_cleanup_and_release(n);
+				continue;
+			}
 			write_unlock(&n->lock);
-			neigh_cleanup_and_release(n);
-			continue;
-		}
-		write_unlock(&n->lock);
=20
 next_elt:
-		np =3D &n->next;
+			np =3D &n->next;
+		}
+		/*
+		 * It's fine to release lock here, even if hash table
+		 * grows while we are preempted.
+		 */
+		write_unlock_bh(&tbl->lock);
+		cond_resched();
+		write_lock_bh(&tbl->lock);
 	}
-
 	/* Cycle through all hash buckets every base_reachable_time/2 ticks.
 	 * ARP entry timeouts range from 1/2 base_reachable_time to 3/2
 	 * base_reachable_time.
 	 */
-	expire =3D tbl->parms.base_reachable_time >> 1;
-	expire /=3D (tbl->hash_mask + 1);
-	if (!expire)
-		expire =3D 1;
-
-	if (expire>HZ)
-		mod_timer(&tbl->gc_timer, round_jiffies(now + expire));
-	else
-		mod_timer(&tbl->gc_timer, now + expire);
-
-	write_unlock(&tbl->lock);
+	schedule_delayed_work(&tbl->gc_work,
+			      tbl->parms.base_reachable_time >> 1);
+	write_unlock_bh(&tbl->lock);
 }
=20
 static __inline__ int neigh_max_probes(struct neighbour *n)
@@ -1442,10 +1441,8 @@ void neigh_table_init_no_netlink(struct neigh_ta=
ble *tbl)
 	get_random_bytes(&tbl->hash_rnd, sizeof(tbl->hash_rnd));
=20
 	rwlock_init(&tbl->lock);
-	setup_timer(&tbl->gc_timer, neigh_periodic_timer, (unsigned long)tbl)=
;
-	tbl->gc_timer.expires  =3D now + 1;
-	add_timer(&tbl->gc_timer);
-
+	INIT_DELAYED_WORK_DEFERRABLE(&tbl->gc_work, neigh_periodic_work);
+	schedule_delayed_work(&tbl->gc_work, tbl->parms.reachable_time);
 	setup_timer(&tbl->proxy_timer, neigh_proxy_process, (unsigned long)tb=
l);
 	skb_queue_head_init_class(&tbl->proxy_queue,
 			&neigh_table_proxy_queue_class);
@@ -1482,7 +1479,8 @@ int neigh_table_clear(struct neigh_table *tbl)
 	struct neigh_table **tp;
=20
 	/* It is not clean... Fix it to unload IPv6 module safely */
-	del_timer_sync(&tbl->gc_timer);
+	cancel_delayed_work(&tbl->gc_work);
+	flush_scheduled_work();
 	del_timer_sync(&tbl->proxy_timer);
 	pneigh_queue_purge(&tbl->proxy_queue);
 	neigh_ifdown(tbl, NULL);
@@ -1752,7 +1750,6 @@ static int neightbl_fill_info(struct sk_buff *skb=
, struct neigh_table *tbl,
 			.ndtc_last_rand		=3D jiffies_to_msecs(rand_delta),
 			.ndtc_hash_rnd		=3D tbl->hash_rnd,
 			.ndtc_hash_mask		=3D tbl->hash_mask,
-			.ndtc_hash_chain_gc	=3D tbl->hash_chain_gc,
 			.ndtc_proxy_qlen	=3D tbl->proxy_queue.qlen,
 		};
=20
