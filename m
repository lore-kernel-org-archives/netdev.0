From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/3] inetpeer: Support ipv6 addresses.
Date: Tue, 30 Nov 2010 07:11:19 +0100
Message-ID: <1291097479.2725.13.camel@edumazet-laptop>
References: <AANLkTin11AYaFWMArC6fNQnvej2+=WUfOtTVrtX8WLEZ@mail.gmail.com>
	 <20101129.212222.115953137.davem@davemloft.net>
	 <1291095736.2725.5.camel@edumazet-laptop>
	 <20101129.215303.48488457.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64331 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751730Ab0K3GLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 01:11:31 -0500
Received: by wyb28 with SMTP id 28so5306630wyb.19
        for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 22:11:30 -0800 (PST)
In-Reply-To: <20101129.215303.48488457.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 29 novembre 2010 =C3=A0 21:53 -0800, David Miller a =C3=A9crit=
 :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 30 Nov 2010 06:42:16 +0100
>=20
> > Its a bit early in the morning here, I must confess I dont yet
> > understand your patch David :)
> >=20
> > As we use a tree, why not using two different trees for ipv4 / ipv6=
 ?
>=20
> The "key" just creates a natural ordering in the tree, it's
> almost arbitrary except that it must distribute well amongst
> the entries.

Hmm. AVL search must take a decision, take the left or the right path.

if current key is equal, which path do you take ?


@@ -165,9 +208,9 @@ static void unlink_from_unused(struct inet_peer *p)
>  	for (u =3D rcu_dereference_protected(peers.root,		\
>  			lockdep_is_held(&peers.lock));		\
>  	     u !=3D peer_avl_empty; ) {				\
> -		if (_daddr =3D=3D u->v4daddr)			\
> +		if (inet_peer_addr_equal(_daddr, &u->daddr))	\
>  			break;					\
> -		if ((__force __u32)_daddr < (__force __u32)u->v4daddr)	\
> +		if (key < inet_peer_key(&u->daddr))		\
>  			v =3D &u->avl_left;			\
>  		else						\
>  			v =3D &u->avl_right;			\


Apparently you take the right one, you may miss the target if its on th=
e
left path ?

>=20
> I currently don't see any reason to make two trees right now.
>=20

Cost of a tree is one pointer, and ipv4 search would be faster if we us=
e
different search functions.

> > I dont understand how computing a 32bit key (sort of hash key) is g=
oing
> > to help when hash collision happens, with an avl tree.
> > Either version of tree (AVL/rbtree) will be expensive to use if dep=
th is
> > big (With 2 millions entries, depth is going to be very big). I
> > understand you want to get rid of route cache ?
>=20
> Do we plan to talk to 2 million unique destinations and have active
> non-default metrics for each one of them very often?
>=20
> inet_peer entries will only get created when we need to make
> non-default metric settings for a specific destination address.
>=20
> See that's the thing, it's scope is so much smaller than the existing
> routing cache.  It's only going to be used in limited if not
> controlled cases.
>=20

OK good :)

I have no idea how many addresses have non default metric settings.

Do you know how to make an estimation on a server ?



