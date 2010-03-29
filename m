From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] NETLABEL: Fix an RCU warning
Date: Mon, 29 Mar 2010 08:24:53 -0700
Message-ID: <20100329152453.GC2569@linux.vnet.ibm.com>
References: <20100325110621.5348.32020.stgit@warthog.procyon.org.uk>
 <1269516484.3626.21.camel@edumazet-laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Howells <dhowells@redhat.com>, paul.moore@hp.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:43051 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751300Ab0C2PY4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Mar 2010 11:24:56 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e9.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o2TFDfor017257
	for <netdev@vger.kernel.org>; Mon, 29 Mar 2010 11:13:41 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2TFOsb31814608
	for <netdev@vger.kernel.org>; Mon, 29 Mar 2010 11:24:54 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2TFOsVJ016935
	for <netdev@vger.kernel.org>; Mon, 29 Mar 2010 11:24:54 -0400
Content-Disposition: inline
In-Reply-To: <1269516484.3626.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 25, 2010 at 12:28:04PM +0100, Eric Dumazet wrote:
> Le jeudi 25 mars 2010 =E0 11:06 +0000, David Howells a =E9crit :
> > Fix an RCU warning in the netlabel code due to missing rcu read loc=
king around
> > an rcu_dereference() in netlbl_unlhsh_hash() when called from
> > netlbl_unlhsh_netdev_handler():
> >=20
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
> > [ INFO: suspicious rcu_dereference_check() usage. ]
> > ---------------------------------------------------
> > net/netlabel/netlabel_unlabeled.c:246 invoked rcu_dereference_check=
() without protection!
> >=20
> > other info that might help us debug this:
> >=20
> >=20
> > rcu_scheduler_active =3D 1, debug_locks =3D 0
> > 2 locks held by ip/5108:
> >  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff812c4a36>] rtnl_lock+0x12=
/0x14
> >  #1:  (netlbl_unlhsh_lock){+.+...}, at: [<ffffffff8134daa4>] netlbl=
_unlhsh_netdev_handler+0x1e/0x86
> >=20
> > stack backtrace:
> > Pid: 5108, comm: ip Not tainted 2.6.34-rc2-cachefs #114
> > Call Trace:
> >  [<ffffffff8105121f>] lockdep_rcu_dereference+0xaa/0xb2
> >  [<ffffffff8134d781>] netlbl_unlhsh_hash+0x3e/0x50
> >  [<ffffffff8134d7a1>] netlbl_unlhsh_search_iface+0xe/0x84
> >  [<ffffffff8134daaf>] netlbl_unlhsh_netdev_handler+0x29/0x86
> >  [<ffffffff81048362>] notifier_call_chain+0x32/0x5e
> >  [<ffffffff810483fe>] raw_notifier_call_chain+0xf/0x11
> >  [<ffffffff812ba924>] call_netdevice_notifiers+0x16/0x18
> >  [<ffffffff812bac22>] __dev_notify_flags+0x37/0x5b
> >  [<ffffffff812bac8c>] dev_change_flags+0x46/0x52
> >  [<ffffffff812c41af>] do_setlink+0x250/0x3cd
> >  [<ffffffff812c4ee8>] rtnl_newlink+0x2b6/0x49d
> >  [<ffffffff812c4cdd>] ? rtnl_newlink+0xab/0x49d
> >  [<ffffffff812c4c17>] rtnetlink_rcv_msg+0x1b7/0x1d2
> >  [<ffffffff812c4a60>] ? rtnetlink_rcv_msg+0x0/0x1d2
> >  [<ffffffff812cc1dc>] netlink_rcv_skb+0x3e/0x8f
> >  [<ffffffff812c4a59>] rtnetlink_rcv+0x21/0x28
> >  [<ffffffff812cbefe>] netlink_unicast+0x218/0x28f
> >  [<ffffffff812cc76e>] netlink_sendmsg+0x26b/0x27a
> >  [<ffffffff812a9f1d>] sock_sendmsg+0xd4/0xf5
> >  [<ffffffff81096dca>] ? might_fault+0x4e/0x9e
> >  [<ffffffff81096dca>] ? might_fault+0x4e/0x9e
> >  [<ffffffff81096e13>] ? might_fault+0x97/0x9e
> >  [<ffffffff81096dca>] ? might_fault+0x4e/0x9e
> >  [<ffffffff812b4122>] ? verify_iovec+0x59/0x97
> >  [<ffffffff812aa1d9>] sys_sendmsg+0x209/0x273
> >  [<ffffffff810976dc>] ? __do_fault+0x395/0x3cd
> >  [<ffffffff8109928f>] ? handle_mm_fault+0x324/0x69d
> >  [<ffffffff81051e4e>] ? trace_hardirqs_on_caller+0x10c/0x130
> >  [<ffffffff81074972>] ? audit_syscall_entry+0x17d/0x1b0
> >  [<ffffffff81364154>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> >  [<ffffffff81001eeb>] system_call_fastpath+0x16/0x1b
> >=20
> > Signed-off-by: David Howells <dhowells@redhat.com>
> > ---
> >=20
> >  net/netlabel/netlabel_unlabeled.c |    2 ++
> >  1 files changed, 2 insertions(+), 0 deletions(-)
> >=20
> > diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netla=
bel_unlabeled.c
> > index 852d9d7..7ea64e4 100644
> > --- a/net/netlabel/netlabel_unlabeled.c
> > +++ b/net/netlabel/netlabel_unlabeled.c
> > @@ -799,6 +799,7 @@ static int netlbl_unlhsh_netdev_handler(struct =
notifier_block *this,
> > =20
> >  	/* XXX - should this be a check for NETDEV_DOWN or _UNREGISTER? *=
/
> >  	if (event =3D=3D NETDEV_DOWN) {
> > +		rcu_read_lock();
> >  		spin_lock(&netlbl_unlhsh_lock);
> >  		iface =3D netlbl_unlhsh_search_iface(dev->ifindex);
> >  		if (iface !=3D NULL && iface->valid) {
> > @@ -807,6 +808,7 @@ static int netlbl_unlhsh_netdev_handler(struct =
notifier_block *this,
> >  		} else
> >  			iface =3D NULL;
> >  		spin_unlock(&netlbl_unlhsh_lock);
> > +		rcu_read_unlock();
> >  	}
> > =20
> >  	if (iface !=3D NULL)
> >=20
> > --
>=20
> Sorry this is not the right fix.
>=20
> Fix is to change the dereference check to take into account the lock
> owned here.

So we need the rcu_dereference() in netlbl_unlhsh_search_iface()
to become someething like the following?

	bkt_list =3D &rcu_dereference_check(netlbl_unlhsh,
					  rcu_read_lock_held() ||
					  lockdep_is_held(&netlbl_unlhsh_lock))->tbl[bkt];

Or is this the wrong lock?

							Thanx, Paul
