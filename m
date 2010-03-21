From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: RCU problems in fib_table_insert
Date: Sun, 21 Mar 2010 14:38:03 -0700
Message-ID: <20100321213803.GE2517@linux.vnet.ibm.com>
References: <20100321202525.GA966@basil.fritz.box>
 <1269206752.3004.9.camel@edumazet-laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>, robert.olsson@its.uu.se,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:41868 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752475Ab0CUViG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Mar 2010 17:38:06 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e3.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o2LLQYQ2024727
	for <netdev@vger.kernel.org>; Sun, 21 Mar 2010 17:26:34 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2LLc5g11839296
	for <netdev@vger.kernel.org>; Sun, 21 Mar 2010 17:38:05 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2LLc4rO016938
	for <netdev@vger.kernel.org>; Sun, 21 Mar 2010 17:38:05 -0400
Content-Disposition: inline
In-Reply-To: <1269206752.3004.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 21, 2010 at 10:25:52PM +0100, Eric Dumazet wrote:
> Le dimanche 21 mars 2010 =E0 21:25 +0100, Andi Kleen a =E9crit :
> > Hi,
> >=20
> > I got the following warning at boot with a 2.6.34-rc2ish git kernel
> > with RCU debugging and preemption enabled.
> >=20
> > It seems the problem is that not all callers of fib_find_node
> > call it with rcu_read_lock() to stabilize access to the fib.=20
> >=20
> > I tried to fix it, but especially for fib_table_insert() that's rat=
her=20
> > tricky: it does a lot of memory allocations and also route flushing=
 and=20
> > other blocking operations while assuming the original fa is RCU sta=
ble.
> >=20
> > I first tried to move some allocations to the beginning and keep
> > preemption disabled in the rest, but it's difficult with all of the=
m.
> > No patch because of that.
> >=20
> > Does the fa need an additional reference count for this problem?
> > Or perhaps some optimistic locking?
> >=20
> > -Andi
>=20
> No real changes needed, only a lockdep warning...
>=20
> Probably a rcu_dereference() should be changed to
> rcu_dereference_check() like we did for __in6_dev_get()
>=20
> We hold RTNL or rcu_read_lock
>=20
> [PATCH] net: fib_find_node() rcu check
>=20
> We hold rcu read lock or RTNL when fib_find_node() is called.
> Shutup lockdep complain.

You beat me to it, Eric.  ;-)

So:

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> Reported-by: Andi Kleen <andi@firstfloor.org>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> index af5d897..471fe07 100644
> --- a/net/ipv4/fib_trie.c
> +++ b/net/ipv4/fib_trie.c
> @@ -961,7 +961,8 @@ fib_find_node(struct trie *t, u32 key)
>  	struct node *n;
>=20
>  	pos =3D 0;
> -	n =3D rcu_dereference(t->trie);
> +	n =3D rcu_dereference_check(t->trie,
> +				  rcu_read_lock_held() || lockdep_rtnl_is_held());
>=20
>  	while (n !=3D NULL &&  NODE_TYPE(n) =3D=3D T_TNODE) {
>  		tn =3D (struct tnode *) n;
>=20
>=20
