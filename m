From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: What protects rcu_dereference() in __sk_free()?
Date: Fri, 15 Jan 2010 11:51:53 -0800
Message-ID: <20100115195153.GA6188@linux.vnet.ibm.com>
References: <20100114184107.GA17245@linux.vnet.ibm.com> <4B50043D.9090205@gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dim@openvz.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:53553 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758178Ab0AOUIt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jan 2010 15:08:49 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e2.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o0FJxUMw015592
	for <netdev@vger.kernel.org>; Fri, 15 Jan 2010 14:59:30 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0FK8mKG117236
	for <netdev@vger.kernel.org>; Fri, 15 Jan 2010 15:08:48 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0FK8mPI012265
	for <netdev@vger.kernel.org>; Fri, 15 Jan 2010 15:08:48 -0500
Content-Disposition: inline
In-Reply-To: <4B50043D.9090205@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 15, 2010 at 06:59:25AM +0100, Eric Dumazet wrote:
> Le 14/01/2010 19:41, Paul E. McKenney a =E9crit :
> > Hello, Dmitry,
> >=20
> > Could you please tell me what protects the rcu_dereference() in
> > __sk_free()?  I am adding lockdep-based checking to RCU, and
> > "git blame" said I should ask you about this one.
> >=20
> > The current code, rcu_dereference(), assumes that this is protected=
 only
> > by RCU-bh.  My problem might be any of the following:
> >=20
> > o	Some other flavor of RCU protects this, e.g., RCU-sched, which
> > 	would require rcu_dereference_sched() in place of my current
> > 	rcu_dereference_bh() for RCU-bh.
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
> > So, could you please tell me what protects the rcu_dereference() in
> > __sk_free() so that I can craft the appropriate form of rcu_derefer=
ence()?
> >=20
>=20
> Hi Paul
>=20
> filter =3D rcu_dereference(sk->sk_filter);
>=20
> is probably not really needed, current thread being the one doing soc=
ket destruction,
> and has a writer role.
>=20
> void sk_free(struct sock *sk)
> {
> 	if (atomic_dec_and_test(&sk->sk_wmem_alloc))
> 		__sk_free(sk);
> }
>=20
> So the protection comes from the atomic_dec_and_test() that acts as a=
 lock.

Thank you for the info, Eric!

One option would be to remove the rcu_dereference() from __sk_free().
Given that it was there, my thought would be to make it read as follows=
:

	filter =3D rcu_dereference_check(sk->sk_filter,
				       atomic_read(&sk->sk_wmem_alloc) =3D=3D 0);

This approach would have the benefit of potentially catching some race
conditions if built with CONFIG_PROVE_RCU.  Does this seem reasonable t=
o
you?

						Thanx, Paul
