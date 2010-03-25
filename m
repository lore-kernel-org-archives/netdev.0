From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] NETLABEL: Fix an RCU warning
Date: Thu, 25 Mar 2010 14:32:20 +0100
Message-ID: <1269523940.3626.37.camel@edumazet-laptop>
References: <1269516484.3626.21.camel@edumazet-laptop>
	 <20100325110621.5348.32020.stgit@warthog.procyon.org.uk>
	 <6522.1269517044@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paul.moore@hp.com, netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:53979 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753128Ab0CYNcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 09:32:25 -0400
Received: by bwz1 with SMTP id 1so844070bwz.21
        for <netdev@vger.kernel.org>; Thu, 25 Mar 2010 06:32:23 -0700 (PDT)
In-Reply-To: <6522.1269517044@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 25 mars 2010 =C3=A0 11:37 +0000, David Howells a =C3=A9crit :
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > Sorry this is not the right fix.
> >=20
> > Fix is to change the dereference check to take into account the loc=
k
> > owned here.
>=20
> Then the comments on netlbl_unlhsh_hash(), netlbl_unlhsh_search_iface=
(),
> netlbl_unlhsh_search_iface_def() and netlbl_unlhsh_add_iface() are al=
l wrong,
> for all of them say:
>=20
> 	* The caller is responsible for calling the rcu_read_[un]lock()
> 	* functions.
>=20
> Furthermore, netlabel_unlhsh_add() and netlabel_unlhsh_remove() _do_ =
wrap the
> calls to those functions in rcu_read_lock'd sections.

Current code is probably fine.
Comments are not up to date (as many other comments BTW)

Only the dereference check is bad, as it assumes the rcu_read lock is
held.

Its not the case, we own a spinlock.

You suggest adding a surrounding rcu lock, but this surrounding lock
adds overhead on normal kernels, to correct checker warnings only.

If a mutex was protecting existing code, instead of a spinlock, then
adding rcu_read_lock() would be no correct anyway (existing code would
not be allowed to call a might_sleep function)

Please take a look at rcu_dereference_check() in :

__sk_free() (file net/core/sock.c)=20
__in6_dev_get() (file include/net/addrconf.h)
rcu_dereference_check_fdtable (file include/linux/fdtable.h)
task_subsys_state() (file include/linux/cgroup.h)
rcu_dereference_check_sched_domain (file kernel/sched.c)
=2E..

for examples of proper checks.

Yes, its more difficult, but its the right thing.


