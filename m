From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] SELinux: Fix RCU deref check warning in
 sel_netport_insert()
Date: Tue, 04 Oct 2011 06:22:56 +0200
Message-ID: <1317702176.2784.4.camel@edumazet-laptop>
References: <20111003135824.15303.10147.stgit@warthog.procyon.org.uk>
	 <2230709.7n5noARWFd@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Howells <dhowells@redhat.com>, selinux@tycho.nsa.gov,
	netdev@vger.kernel.org
To: Paul Moore <paul@paul-moore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:54058 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069Ab1JDEXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2011 00:23:03 -0400
Received: by wwf22 with SMTP id 22so155778wwf.1
        for <netdev@vger.kernel.org>; Mon, 03 Oct 2011 21:23:01 -0700 (PDT)
In-Reply-To: <2230709.7n5noARWFd@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 03 octobre 2011 =C3=A0 17:30 -0400, Paul Moore a =C3=A9crit :
> On Monday, October 03, 2011 02:58:24 PM David Howells wrote:
> > Fix the following bug in sel_netport_insert() where rcu_dereference=
() should
> > be rcu_dereference_protected() as sel_netport_lock is held.
> >=20
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
> > [ INFO: suspicious rcu_dereference_check() usage. ]
> > ---------------------------------------------------
> > security/selinux/netport.c:127 invoked rcu_dereference_check() with=
out
> > protection!
> >=20
> > other info that might help us debug this:
> >=20
> >=20
> > rcu_scheduler_active =3D 1, debug_locks =3D 0
> > 1 lock held by ossec-rootcheck/3323:
> >  #0:  (sel_netport_lock){+.....}, at: [<ffffffff8117d775>]
> > sel_netport_sid+0xbb/0x226
> >=20
> > stack backtrace:
> > Pid: 3323, comm: ossec-rootcheck Not tainted 3.1.0-rc8-fsdevel+ #10=
95
> > Call Trace:
> >  [<ffffffff8105cfb7>] lockdep_rcu_dereference+0xa7/0xb0
> >  [<ffffffff8117d871>] sel_netport_sid+0x1b7/0x226
> >  [<ffffffff8117d6ba>] ? sel_netport_avc_callback+0xbc/0xbc
> >  [<ffffffff8117556c>] selinux_socket_bind+0x115/0x230
> >  [<ffffffff810a5388>] ? might_fault+0x4e/0x9e
> >  [<ffffffff810a53d1>] ? might_fault+0x97/0x9e
> >  [<ffffffff81171cf4>] security_socket_bind+0x11/0x13
> >  [<ffffffff812ba967>] sys_bind+0x56/0x95
> >  [<ffffffff81380dac>] ? sysret_check+0x27/0x62
> >  [<ffffffff8105b767>] ? trace_hardirqs_on_caller+0x11e/0x155
> >  [<ffffffff81076fcd>] ? audit_syscall_entry+0x17b/0x1ae
> >  [<ffffffff811b5eae>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> >  [<ffffffff81380d7b>] system_call_fastpath+0x16/0x1b
> >=20
> > Signed-off-by: David Howells <dhowells@redhat.com>
> > ---
> >=20
> >  security/selinux/netport.c |    4 +++-
> >  1 files changed, 3 insertions(+), 1 deletions(-)
>=20
> We should probably do the same for the security/selinux/netif.c as it=
 uses the=20
> same logic; David is this something you want to tackle?
>=20
> Acked-by: Paul Moore <paul@paul-moore.com>
>=20
> > diff --git a/security/selinux/netport.c b/security/selinux/netport.=
c
> > index 0b62bd1..39e2138 100644
> > --- a/security/selinux/netport.c
> > +++ b/security/selinux/netport.c
> > @@ -123,7 +123,9 @@ static void sel_netport_insert(struct sel_netpo=
rt *port)
> > if (sel_netport_hash[idx].size =3D=3D SEL_NETPORT_HASH_BKT_LIMIT) {
> >  		struct sel_netport *tail;
> >  		tail =3D list_entry(
> > -			rcu_dereference(sel_netport_hash[idx].list.prev),
> > +			rcu_dereference_protected(
> > +				sel_netport_hash[idx].list.prev,
> > +				spin_is_locked(&sel_netport_lock)),

Usual way is to use :
	rcu_dereference_protected(
		sel_netport_hash[idx].list.prev,
		lockdep_is_held(&sel_netport_lock)),
