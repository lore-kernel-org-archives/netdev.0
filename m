From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: only run neigh_forced_gc() from one cpu
Date: Wed, 19 Sep 2012 11:27:07 +0200
Message-ID: <1348046827.26523.571.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Tom Herbert <therbert@google.com>,
	Lorenzo Colitti <lorenzo@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:63985 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753636Ab2ISJ1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 05:27:13 -0400
Received: by bkwj10 with SMTP id j10so377657bkw.19
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2012 02:27:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

With multiqueue NIC or RPS, we can have situation where all cpus are
spending huge amount of cycles in neigh_forced_gc(), and machine can
crash.

Since we are under probable attack, its better to let only one cpu
do the scan, and other cpus immediately return from neigh_forced_gc()

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Lorenzo Colitti <lorenzo@google.com>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
Cc: Tom Herbert <therbert@google.com>
---
Google-Bug-Id: 7121897

 include/net/neighbour.h |    1 +
 net/core/neighbour.c    |    9 +++++++--
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 0dab173..ba21e93 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -178,6 +178,7 @@ struct neigh_table {
 	struct neigh_statistics	__percpu *stats;
 	struct neigh_hash_table __rcu *nht;
 	struct pneigh_entry	**phash_buckets;
+	spinlock_t		forced_gc_lock;
 };
=20
 #define NEIGH_PRIV_ALIGN	sizeof(long long)
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index c160adb..1f7d8fa 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -134,9 +134,12 @@ static int neigh_forced_gc(struct neigh_table *tbl=
)
 	int i;
 	struct neigh_hash_table *nht;
=20
+	if (!spin_trylock_bh(&tbl->forced_gc_lock))
+		return 0;
+
 	NEIGH_CACHE_STAT_INC(tbl, forced_gc_runs);
=20
-	write_lock_bh(&tbl->lock);
+	write_lock(&tbl->lock);
 	nht =3D rcu_dereference_protected(tbl->nht,
 					lockdep_is_held(&tbl->lock));
 	for (i =3D 0; i < (1 << nht->hash_shift); i++) {
@@ -169,7 +172,8 @@ static int neigh_forced_gc(struct neigh_table *tbl)
=20
 	tbl->last_flush =3D jiffies;
=20
-	write_unlock_bh(&tbl->lock);
+	write_unlock(&tbl->lock);
+	spin_unlock_bh(&tbl->forced_gc_lock);
=20
 	return shrunk;
 }
@@ -1545,6 +1549,7 @@ static void neigh_table_init_no_netlink(struct ne=
igh_table *tbl)
 		panic("cannot allocate neighbour cache hashes");
=20
 	rwlock_init(&tbl->lock);
+	spin_lock_init(&tbl->forced_gc_lock);
 	INIT_DELAYED_WORK_DEFERRABLE(&tbl->gc_work, neigh_periodic_work);
 	schedule_delayed_work(&tbl->gc_work, tbl->parms.reachable_time);
 	setup_timer(&tbl->proxy_timer, neigh_proxy_process, (unsigned long)tb=
l);
