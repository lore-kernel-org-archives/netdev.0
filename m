From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] inet: remove rcu protection on tw_net
Date: Wed, 14 Dec 2011 23:28:10 +0100
Message-ID: <1323901690.2631.15.camel@edumazet-laptop>
References: <1323874713.2334.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <m1d3bqaowg.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:53129 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757877Ab1LNW2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 17:28:15 -0500
Received: by wgbds13 with SMTP id ds13so2152749wgb.1
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2011 14:28:14 -0800 (PST)
In-Reply-To: <m1d3bqaowg.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 14 d=C3=A9cembre 2011 =C3=A0 12:17 -0800, Eric W. Biederman=
 a =C3=A9crit :
> Eric Dumazet <eric.dumazet@gmail.com> writes:
>=20
> > commit b099ce2602d806 (net: Batch inet_twsk_purge) added rcu protec=
tion
> > on tw_net for no obvious reason.
>=20
> From that commit I see:
>=20
>                 sk_nulls_for_each_rcu(sk, node, &head->twchain) {
>                         tw =3D inet_twsk(sk);
> -                       if (!net_eq(twsk_net(tw), net) ||
> -                           tw->tw_family !=3D family)
> +                       if ((tw->tw_family !=3D family) ||
> +                               atomic_read(&twsk_net(tw)->count))
>=20
> That atomic_read is a new dereference of twsk_net in an only rcu
> protected section.  That seems like an obvious reason to me.
>=20

Absolutely not.

As I said twsk_net() cannot change in a tw lifetime.

(If it could, this code would be bogus anyway, you should use :

net =3D twsk_net(tw);
if (tw->tw_family !=3D family || !net || atomic_read(&net->count))
	...

> > struct net are refcounted anyway since timewait sockets escape from=
 rcu
> > protected sections. tw_net stay valid for the whole timwait lifetim=
e.
>=20
> What? twsk_net_set does not bump the struct net ref count.
>=20

The commit I mentioned did not change anything in this respect.

> There is that stupid hold_net/release_net over designed debugging
> thinko that makes it look like we have a refcount.  We should probabl=
y
> just kill that thing.  But a time wait socket unlike a normal socket
> does not keep a network namespace alive.  Which is why we have to pur=
ge
> pending timewait sockets when a network namespace exits.
>=20

Since you do a cleanup _before_ removing "struct net", you have absolut=
e
guarantee tw_net is stable, you dont need rcu_dereference() (and implie=
d
smb_rmb()) at all.

Why pay the price twice, once in the super heavy inet_twsk_purge()
function, once in every twsk_net() calls ?

[ By the way, rcu_dereference_raw() dubious use is another sign we dont
really know what RCU invariant is respected when calling twsk_net(tw) ]

> > This also removes a lot of sparse errors.
>=20
> What is sparse saying that we are doing wrong?
>=20

CONFIG_SPARSE_RCU_POINTER=3Dy

make C=3D2 net/ipv4/inet_timewait_sock.o

  CHECK   net/ipv4/inet_timewait_sock.c
include/net/inet_timewait_sock.h:222:16: error: incompatible types in
comparison expression (different address spaces)

[ repeat NN times ]

comparison expression (different address spaces)
include/net/inet_timewait_sock.h:222:16: error: incompatible types in
comparison expression (different address spaces)
include/net/inet_timewait_sock.h:222:16: error: incompatible types in
comparison expression (different address spaces)
include/net/inet_timewait_sock.h:222:16: error: incompatible types in
comparison expression (different address spaces)
include/net/inet_timewait_sock.h:222:16: error: too many errors



> There may be constraints that are strong enough that we can get away
> this but I am at least a little dubious.
>=20

Thanks for reviewing and comments !
