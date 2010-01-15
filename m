From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: What protects rcu_dereference() in __in6_dev_get()?
Date: Fri, 15 Jan 2010 07:15:59 -0800
Message-ID: <20100115151559.GD6770@linux.vnet.ibm.com>
References: <20100114183215.GA16866@linux.vnet.ibm.com> <4B500217.6070908@gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org, mingo@elte.hu,
	akpm@linux-foundation.org, peterz@infradead.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:43924 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755421Ab0AOPQL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jan 2010 10:16:11 -0500
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e8.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o0FFA2Jo017297
	for <netdev@vger.kernel.org>; Fri, 15 Jan 2010 10:10:02 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0FFG0Wj1237132
	for <netdev@vger.kernel.org>; Fri, 15 Jan 2010 10:16:00 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0FFFxwJ031127
	for <netdev@vger.kernel.org>; Fri, 15 Jan 2010 10:15:59 -0500
Content-Disposition: inline
In-Reply-To: <4B500217.6070908@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 15, 2010 at 06:50:15AM +0100, Eric Dumazet wrote:
> Le 14/01/2010 19:32, Paul E. McKenney a =E9crit :
> > Hello, Yoshi,
> >=20
> > Could you please tell me what protects the rcu_dereference() in
> > __in6_dev_get()?  I am adding lockdep-based checking to RCU, and
> > "git blame" said I should ask you about this one.
> >=20
> > The current code, rcu_dereference(), assumes that this is protected=
 only
> > by RCU.  My problem might be any of the following:
> >=20
> > o	Some other flavor of RCU protects this, e.g., RCU-bh, which
> > 	would require rcu_dereference_bh().
> >=20
> > o	This is called from updates as well as from readers, and
> > 	some lock protects the updates.
> >=20
> > o	This is called during initialization, when this pointer is
> > 	inaccessible to readers.
> > =09
> > Please note that I can add a check to cover multiple possibilities.
> > For a real example in include/linux/fdtable.h:
> >=20
> > 	file =3D rcu_dereference_check(fdt->fd[fd],
> > 				     rcu_read_lock_held() ||
> > 				     lockdep_is_held(&files->file_lock) ||
> > 				     atomic_read(&files->count) =3D=3D 1);
> >=20
> > The first argument is the pointer, and the second argument says tha=
t
> > this may be protected by either RCU (as opposed to RCU-bh, RCU-sche=
d,
> > or SRCU), the files->file_lock as recorded by lockdep, or by being =
in
> > a single-threaded process as noted by the value of files->count.
> > (Please see http://lwn.net/Articles/368683/ for a recent patch, ano=
ther
> > will go out soon.)
> >=20
> > So, could you please tell me what protects the rcu_dereference()
> > in __in6_dev_get() so that I can craft the appropriate form of
> > rcu_dereference()?
> >=20
> > 							Thanx, Paul
>=20
> Hi Paul
>=20
> __in6_dev_get() is called either with rcu_read_lock()/rcu_read_unlock=
() protection,
> or with the RTNL mutex held.

Very good!  So I make a lockdep_rtnl_is_held() in net/core/rtnetlink.c:

	#ifdef CONFIG_PROVE_LOCKING
	int lockdep_rtnl_is_held(void)
	{
		return lockdep_is_held(&rtnl_mutex);
	}
	EXPORT_SYMBOL(lockdep_rtnl_is_held);
	#endif /* #ifdef CONFIG_PROVE_LOCKING */

Then I make __in6_dev_get() look as follows:

	static inline struct inet6_dev *
	__in6_dev_get(struct net_device *dev)
	{
		return rcu_dereference_check(dev->ip6_ptr,
					     rcu_read_lock_held() ||
					     lockdep_rtnl_is_held());
	}

Seem reasonable?

> Well, thats the theory, we could have some bugs of course :)

I know that feeling!  ;-)

						Thanx, Paul
