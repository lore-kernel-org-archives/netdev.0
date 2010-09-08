From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] lockdep warning in gen_kill_estimator
Date: Wed, 8 Sep 2010 12:16:28 -0700
Message-ID: <20100908121628.0eee5294@nehalam>
References: <20100908112719.3f4b4644@nehalam>
	<1283971234.2428.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40187 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752549Ab0IHTQb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 15:16:31 -0400
In-Reply-To: <1283971234.2428.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 08 Sep 2010 20:40:34 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le mercredi 08 septembre 2010 =E0 11:27 -0700, Stephen Hemminger a =E9=
crit :
> > Saw big lockdep SOFTIRQ-unsafe lock warning in gen_kill_estimator w=
hen doing.
> >=20
> >   tc qdisc del dev dummy0 root
> >=20
>=20
> >=20
> > --- a/net/core/gen_estimator.c	2010-09-08 11:16:10.184368926 -0700
> > +++ b/net/core/gen_estimator.c	2010-09-08 11:16:24.694194050 -0700
> > @@ -270,18 +270,18 @@ void gen_kill_estimator(struct gnet_stat
> >  {
> >  	struct gen_estimator *e;
> > =20
> > -	spin_lock(&est_tree_lock);
> > +	spin_lock_bh(&est_tree_lock);
> >  	while ((e =3D gen_find_node(bstats, rate_est))) {
> >  		rb_erase(&e->node, &est_root);
> > =20
> > -		write_lock_bh(&est_lock);
> > +		write_lock(&est_lock);
> >  		e->bstats =3D NULL;
> > -		write_unlock_bh(&est_lock);
> > +		write_unlock(&est_lock);
> > =20
> >  		list_del_rcu(&e->list);
> >  		call_rcu(&e->e_rcu, __gen_kill_estimator);
> >  	}
> > -	spin_unlock(&est_tree_lock);
> > +	spin_unlock_bh(&est_tree_lock);
> >  }
> >  EXPORT_SYMBOL(gen_kill_estimator);
> > =20
>=20
> Hmm... I think commit 0b5d404e349c0236
> already takes care of this ?
>=20
> Already in Linus tree=20
>=20
>=20
Ok.

But that commit adds unnecessary bh_disable
-------
Subject: [PATCH] pkt_sched: remov unnecessary bh_disable

Now that est_tree_lock is acquired with BH protection, the other
call is unnecessary.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/core/gen_estimator.c	2010-09-08 12:13:55.182851300 -0700
+++ b/net/core/gen_estimator.c	2010-09-08 12:14:07.401063663 -0700
@@ -274,9 +274,9 @@ void gen_kill_estimator(struct gnet_stat
 	while ((e =3D gen_find_node(bstats, rate_est))) {
 		rb_erase(&e->node, &est_root);
=20
-		write_lock_bh(&est_lock);
+		write_lock(&est_lock);
 		e->bstats =3D NULL;
-		write_unlock_bh(&est_lock);
+		write_unlock(&est_lock);
=20
 		list_del_rcu(&e->list);
 		call_rcu(&e->e_rcu, __gen_kill_estimator);



--=20
