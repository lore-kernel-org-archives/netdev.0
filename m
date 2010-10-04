From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next V3] net: dynamic ingress_queue allocation
Date: Mon, 4 Oct 2010 14:06:27 +0200
Message-ID: <20101004120626.GA2022@del.dom.local>
References: <1285689517.3154.76.camel@edumazet-laptop>
 <20100928180447.GA1880@del.dom.local>
 <1285757817.3561.2.camel@bigi>
 <1285887509.2705.33.camel@edumazet-laptop>
 <1285933506.3553.176.camel@bigi>
 <1285941388.2641.175.camel@edumazet-laptop>
 <20101002093255.GA2049@del.dom.local>
 <1286035915.2582.2472.camel@edumazet-laptop>
 <20101003094221.GA2028@del.dom.local>
 <1286181729.18293.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46215 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753882Ab0JDMGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 08:06:32 -0400
Received: by wyb28 with SMTP id 28so4809502wyb.19
        for <netdev@vger.kernel.org>; Mon, 04 Oct 2010 05:06:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1286181729.18293.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 04, 2010 at 10:42:09AM +0200, Eric Dumazet wrote:
> Le dimanche 03 octobre 2010 ?? 11:42 +0200, Jarek Poplawski a =E9crit=
 :
>=20
> > I'd consider rcu_dereference_rtnl(). Btw, technically qdisc_lookup(=
)
> > doesn't require rtnl, and there was time it was used without it
> > (on xmit path).
>=20
>=20
> Hmm, for me, rcu_dereference_rtnl() is a bit lazy.
>=20
> Either we are a reader and should use rcu_dereference(), or a writer =
and
> RTNL should be held.
>=20
> Mixing two conditions in a "super macro" is a workaround that we used=
 to
> promptly shutup some lockdep splats. Real fix would be to use strict
> lockdep conditions, because this better documents the code and the
> locking invariants.
>=20
> BTW, rtnl_dereference() should be changed to use
> rcu_dereference_protected() instead of rcu_dereference_check() :
> If RTBL is held, there is no need to force a barrier.

Actually, I'm one of those (convinced by Patrick btw), who consider
rcu_dereference() on the clear update side as misleading, so I'm not
rtnl_dereference() fan with or without changes.

>=20
>=20
> > I think you should also add a comment here why this rcu is used, an=
d
> > that it changes only once in dev's liftime.
> >=20
>=20
> This comment was needed in the previous version of the patch, with th=
e
> smb_wmb() barrier. Now I switched to regular rcu use, nothing prevent=
s
> us to change dev->ingress_queue in flight. Of course there is no curr=
ent
> interest doing so.

Right, but then at least in qdisc_lookup():

if (dev_ingress_queue(dev))
	q =3D qdisc_match_from_root(dev_ingress_queue(dev), handle);

you should use a variable instead of the second dereference (rtnl isn't
mandatory here).

Jarek P.
