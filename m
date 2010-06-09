From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-2.6 v2] pkt_sched: gen_estimator: add a new lock
Date: Wed, 09 Jun 2010 13:55:41 +0200
Message-ID: <1276084541.2442.111.camel@edumazet-laptop>
References: <1275921171.2545.102.camel@edumazet-laptop>
	 <AANLkTimgmYjA7Xp19gycRHDXmwP1w1twn92cfT08tCv2@mail.gmail.com>
	 <1275924638.2545.121.camel@edumazet-laptop>
	 <1275926151.2545.126.camel@edumazet-laptop>
	 <1275929761.2545.159.camel@edumazet-laptop>
	 <1275931108.2545.168.camel@edumazet-laptop>
	 <1276076350.2442.90.camel@edumazet-laptop>
	 <20100609113329.GC7308@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:54823 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752474Ab0FILzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 07:55:45 -0400
Received: by wwb31 with SMTP id 31so164221wwb.19
        for <netdev@vger.kernel.org>; Wed, 09 Jun 2010 04:55:43 -0700 (PDT)
In-Reply-To: <20100609113329.GC7308@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 09 juin 2010 =C3=A0 11:33 +0000, Jarek Poplawski a =C3=A9cr=
it :
> On Wed, Jun 09, 2010 at 11:39:10AM +0200, Eric Dumazet wrote:
> ...
> > Here is v2 of patch, adding protection in gen_estimator_active() as
> > well.
> >=20
> > [PATCH net-2.6 v2] pkt_sched: gen_estimator: add a new lock
> >=20
> > gen_kill_estimator() / gen_new_estimator() is not always called wit=
h
> > RTNL held.
> >=20
> > net/netfilter/xt_RATEEST.c is one user of these API that do not hol=
d
> > RTNL, so random corruptions can occur between "tc" and "iptables".
> >=20
> > Add a new fine grained lock instead of trying to use RTNL in netfil=
ter.
>=20
> Btw, maybe it's a different case, but RTNL happens in netfilter alrea=
dy
> (nf_conntrack_helper.c, nf_conntrack_proto.c).
>=20
> It would be nice to mention Changli's argument that
> gen_replace_estimator isn't atomic operation after this change.
>=20

See my next comment. This function is still used in qdisc domain only.
We could add ASSERT_RTNL() here, but its not a bug fix...

> > @@ -312,8 +315,14 @@ EXPORT_SYMBOL(gen_replace_estimator);
> >  bool gen_estimator_active(const struct gnet_stats_basic_packed *bs=
tats,
> >  			  const struct gnet_stats_rate_est *rate_est)
> >  {
> > +	bool res;
> > +
> >  	ASSERT_RTNL();
>=20
> This line should go away as well.
>=20

Nope. This is really needed for safety. Of course, its a debugging knob
and you can remove it if you trust all callers to be good.

Caller should still use RTNL here, or else, as soon as we exit from
gen_estimator_active() with a 'true' result, some other qdisc user coul=
d
destroy the estimator.

=46ortunatly up to 2.6.35, xt_RATEEST cannot reuse/delete an estimator
created by a qdisc user, and it doesnt use gen_estimator_active().

In a future patch, we should add RCU safety here instead of ASSERT_RTNL=
=2E
Thats to make sure caller of gen_estimator_active() is inside a
rcu_read_lock() section, and estimator cannot disappear under it, even
if another cpu/thread calls gen_kill_estimator() on same estimator.



