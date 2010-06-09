From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-2.6 v2] pkt_sched: gen_estimator: add a new lock
Date: Wed, 09 Jun 2010 11:39:10 +0200
Message-ID: <1276076350.2442.90.camel@edumazet-laptop>
References: <1275921171.2545.102.camel@edumazet-laptop>
	 <AANLkTimgmYjA7Xp19gycRHDXmwP1w1twn92cfT08tCv2@mail.gmail.com>
	 <1275924638.2545.121.camel@edumazet-laptop>
	 <1275926151.2545.126.camel@edumazet-laptop>
	 <1275929761.2545.159.camel@edumazet-laptop>
	 <1275931108.2545.168.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: Changli Gao <xiaosuo@gmail.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47208 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757175Ab0FIJjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 05:39:16 -0400
Received: by wyf28 with SMTP id 28so761985wyf.19
        for <netdev@vger.kernel.org>; Wed, 09 Jun 2010 02:39:15 -0700 (PDT)
In-Reply-To: <1275931108.2545.168.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 07 juin 2010 =C3=A0 19:18 +0200, Eric Dumazet a =C3=A9crit :


> [PATCH net-2.6] pkt_sched: gen_estimator: add a new lock
>=20
> gen_kill_estimator() / gen_new_estimator() is not always called with
> RTNL held.
>=20
> net/netfilter/xt_RATEEST.c is one user of these API that do not hold
> RTNL, so random corruptions can occur between "tc" and "iptables"
>=20
> Add a new fine grained lock instead of trying to use RTNL in xt_RATEE=
ST


Here is v2 of patch, adding protection in gen_estimator_active() as
well.

[PATCH net-2.6 v2] pkt_sched: gen_estimator: add a new lock

gen_kill_estimator() / gen_new_estimator() is not always called with
RTNL held.

net/netfilter/xt_RATEEST.c is one user of these API that do not hold
RTNL, so random corruptions can occur between "tc" and "iptables".

Add a new fine grained lock instead of trying to use RTNL in netfilter.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/gen_estimator.c |   15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index cf8e703..785e527 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -107,6 +107,7 @@ static DEFINE_RWLOCK(est_lock);
=20
 /* Protects against soft lockup during large deletion */
 static struct rb_root est_root =3D RB_ROOT;
+static DEFINE_SPINLOCK(est_tree_lock);
=20
 static void est_timer(unsigned long arg)
 {
@@ -201,7 +202,6 @@ struct gen_estimator *gen_find_node(const struct gn=
et_stats_basic_packed *bstats
  *
  * Returns 0 on success or a negative error code.
  *
- * NOTE: Called under rtnl_mutex
  */
 int gen_new_estimator(struct gnet_stats_basic_packed *bstats,
 		      struct gnet_stats_rate_est *rate_est,
@@ -232,6 +232,7 @@ int gen_new_estimator(struct gnet_stats_basic_packe=
d *bstats,
 	est->last_packets =3D bstats->packets;
 	est->avpps =3D rate_est->pps<<10;
=20
+	spin_lock(&est_tree_lock);
 	if (!elist[idx].timer.function) {
 		INIT_LIST_HEAD(&elist[idx].list);
 		setup_timer(&elist[idx].timer, est_timer, idx);
@@ -242,6 +243,7 @@ int gen_new_estimator(struct gnet_stats_basic_packe=
d *bstats,
=20
 	list_add_rcu(&est->list, &elist[idx].list);
 	gen_add_node(est);
+	spin_unlock(&est_tree_lock);
=20
 	return 0;
 }
@@ -261,13 +263,13 @@ static void __gen_kill_estimator(struct rcu_head =
*head)
  *
  * Removes the rate estimator specified by &bstats and &rate_est.
  *
- * NOTE: Called under rtnl_mutex
  */
 void gen_kill_estimator(struct gnet_stats_basic_packed *bstats,
 			struct gnet_stats_rate_est *rate_est)
 {
 	struct gen_estimator *e;
=20
+	spin_lock(&est_tree_lock);
 	while ((e =3D gen_find_node(bstats, rate_est))) {
 		rb_erase(&e->node, &est_root);
=20
@@ -278,6 +280,7 @@ void gen_kill_estimator(struct gnet_stats_basic_pac=
ked *bstats,
 		list_del_rcu(&e->list);
 		call_rcu(&e->e_rcu, __gen_kill_estimator);
 	}
+	spin_unlock(&est_tree_lock);
 }
 EXPORT_SYMBOL(gen_kill_estimator);
=20
@@ -312,8 +315,14 @@ EXPORT_SYMBOL(gen_replace_estimator);
 bool gen_estimator_active(const struct gnet_stats_basic_packed *bstats=
,
 			  const struct gnet_stats_rate_est *rate_est)
 {
+	bool res;
+
 	ASSERT_RTNL();
=20
-	return gen_find_node(bstats, rate_est) !=3D NULL;
+	spin_lock(&est_tree_lock);
+	res =3D gen_find_node(bstats, rate_est) !=3D NULL;
+	spin_unlock(&est_tree_lock);
+
+	return res;
 }
 EXPORT_SYMBOL(gen_estimator_active);


