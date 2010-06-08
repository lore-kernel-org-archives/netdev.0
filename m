From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-2.6] pkt_sched: gen_estimator: add a new lock
Date: Tue, 08 Jun 2010 06:30:57 +0200
Message-ID: <1275971457.2775.40.camel@edumazet-laptop>
References: <1275921171.2545.102.camel@edumazet-laptop>
	 <AANLkTimgmYjA7Xp19gycRHDXmwP1w1twn92cfT08tCv2@mail.gmail.com>
	 <1275924638.2545.121.camel@edumazet-laptop>
	 <1275926151.2545.126.camel@edumazet-laptop>
	 <1275929761.2545.159.camel@edumazet-laptop>
	 <1275931108.2545.168.camel@edumazet-laptop>
	 <AANLkTik7k__McJk8VCu0WP1RYEDHUfBJA4dyGYQTUmBV@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:34445 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752570Ab0FHEbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 00:31:04 -0400
Received: by wwb28 with SMTP id 28so188395wwb.19
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 21:31:01 -0700 (PDT)
In-Reply-To: <AANLkTik7k__McJk8VCu0WP1RYEDHUfBJA4dyGYQTUmBV@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 08 juin 2010 =C3=A0 09:00 +0800, Changli Gao a =C3=A9crit :
> On Tue, Jun 8, 2010 at 1:18 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> >
> >
> > [PATCH net-2.6] pkt_sched: gen_estimator: add a new lock
> >
> > gen_kill_estimator() / gen_new_estimator() is not always called wit=
h
> > RTNL held.
> >
> > net/netfilter/xt_RATEEST.c is one user of these API that do not hol=
d
> > RTNL, so random corruptions can occur between "tc" and "iptables"
> >
> > Add a new fine grained lock instead of trying to use RTNL in xt_RAT=
EEST
> >
>=20
> Why not use RTNL in xt_RATEEST? It seems xt_RATEEST misuse the APIs.
>=20
> and I think gen_replace_estimator is expected to be an atomic operati=
on.
>=20
> And gen_estimator_active() is also assumed to be called with RTNL loc=
ked.
>=20

Thank you for asking this question.

Because I want to kill RTNL when possible, I dont even want to try
adding RTNL to xt_RATEEST and solve all lock dependencies it might
raise.

RTNL =3D Big and Horrible Network LOCK

You never got blocked because of this RTNL thing, dont you ?

I did. And it sucks, because when you hit this, you are in a hurry and
locating the bottleneck takes lot of time.

RTNL is the thing we must hold during device register / unregister.
Its locked for long delays because of all synchronize_rcu() that must b=
e
done, and that is already a big problem on some setups.

Every time someone adds a RTNL requirement, you can be sure another guy
will zap it during following ten years.

Let's do this right now, not later.

=46or an example of horrible rtnl behavior, take a look at following
construct :

if (!rtnl_trylock())
	return restart_syscall();

I saw hundred of udev looping, trying to get rtnl to dump some
information. (Patrick added a rtnl requirement to all dump operations,
and it sucks)



