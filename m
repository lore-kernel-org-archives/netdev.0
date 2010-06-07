From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-2.6] pkt_sched: gen_estimator: add a new lock
Date: Mon, 07 Jun 2010 19:18:27 +0200
Message-ID: <1275931108.2545.168.camel@edumazet-laptop>
References: <1275921171.2545.102.camel@edumazet-laptop>
	 <AANLkTimgmYjA7Xp19gycRHDXmwP1w1twn92cfT08tCv2@mail.gmail.com>
	 <1275924638.2545.121.camel@edumazet-laptop>
	 <1275926151.2545.126.camel@edumazet-laptop>
	 <1275929761.2545.159.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: Changli Gao <xiaosuo@gmail.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36572 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751146Ab0FGRSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 13:18:32 -0400
Received: by wyi11 with SMTP id 11so2555874wyi.19
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 10:18:31 -0700 (PDT)
In-Reply-To: <1275929761.2545.159.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 07 juin 2010 =C3=A0 18:56 +0200, Eric Dumazet a =C3=A9crit :
> >=20
> > For your information, bug is already there before my patch.
> >=20
> > So this est_lock is a wrong protection, in the sense its so convolu=
ted
> > that nobody but you and me even noticed it was buggy in the first p=
lace.
> >=20
> > (see commit 5d944c640b4 for a first patch)
> >=20
> >=20
>=20
> Here is v2 of the patch.
>=20
> Even if its a bug correction, I cooked it for net-next-2.6 since bug
> probably never occured, and patch is too large to be sent to
> net-2.6/linux-2.6 before testing.
>=20
> Another bug comes from net/netfilter/xt_RATEEST.c : It apparently
> calls gen_kill_estimator() / gen_new_estimator() without holding RTNL=
 ?
>=20
> So we should add another lock to protect things (est_root, elist[], .=
=2E.)
>=20
> David, I can send a net-2.6 patch for this one, since it should be sm=
all
> enough. If yes, I'll respin this patch of course ;)

[PATCH net-2.6] pkt_sched: gen_estimator: add a new lock

gen_kill_estimator() / gen_new_estimator() is not always called with
RTNL held.

net/netfilter/xt_RATEEST.c is one user of these API that do not hold
RTNL, so random corruptions can occur between "tc" and "iptables"

Add a new fine grained lock instead of trying to use RTNL in xt_RATEEST

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/gen_estimator.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index cf8e703..3d11203 100644
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
@@ -222,6 +222,7 @@ int gen_new_estimator(struct gnet_stats_basic_packe=
d *bstats,
 	if (est =3D=3D NULL)
 		return -ENOBUFS;
=20
+	spin_lock(&est_tree_lock);
 	idx =3D parm->interval + 2;
 	est->bstats =3D bstats;
 	est->rate_est =3D rate_est;
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


