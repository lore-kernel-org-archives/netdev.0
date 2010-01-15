From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: What protects rcu_dereference() in __in6_dev_get()?
Date: Fri, 15 Jan 2010 06:50:15 +0100
Message-ID: <4B500217.6070908@gmail.com>
References: <20100114183215.GA16866@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org, mingo@elte.hu,
	akpm@linux-foundation.org, peterz@infradead.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47421 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750872Ab0AOFuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 00:50:52 -0500
In-Reply-To: <20100114183215.GA16866@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 14/01/2010 19:32, Paul E. McKenney a =E9crit :
> Hello, Yoshi,
>=20
> Could you please tell me what protects the rcu_dereference() in
> __in6_dev_get()?  I am adding lockdep-based checking to RCU, and
> "git blame" said I should ask you about this one.
>=20
> The current code, rcu_dereference(), assumes that this is protected o=
nly
> by RCU.  My problem might be any of the following:
>=20
> o	Some other flavor of RCU protects this, e.g., RCU-bh, which
> 	would require rcu_dereference_bh().
>=20
> o	This is called from updates as well as from readers, and
> 	some lock protects the updates.
>=20
> o	This is called during initialization, when this pointer is
> 	inaccessible to readers.
> =09
> Please note that I can add a check to cover multiple possibilities.
> For a real example in include/linux/fdtable.h:
>=20
> 	file =3D rcu_dereference_check(fdt->fd[fd],
> 				     rcu_read_lock_held() ||
> 				     lockdep_is_held(&files->file_lock) ||
> 				     atomic_read(&files->count) =3D=3D 1);
>=20
> The first argument is the pointer, and the second argument says that
> this may be protected by either RCU (as opposed to RCU-bh, RCU-sched,
> or SRCU), the files->file_lock as recorded by lockdep, or by being in
> a single-threaded process as noted by the value of files->count.
> (Please see http://lwn.net/Articles/368683/ for a recent patch, anoth=
er
> will go out soon.)
>=20
> So, could you please tell me what protects the rcu_dereference()
> in __in6_dev_get() so that I can craft the appropriate form of
> rcu_dereference()?
>=20
> 							Thanx, Paul

Hi Paul

__in6_dev_get() is called either with rcu_read_lock()/rcu_read_unlock()=
 protection,
or with the RTNL mutex held.

Well, thats the theory, we could have some bugs of course :)

Thanks
