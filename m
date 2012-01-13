From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Race condition in ipv6 code
Date: Fri, 13 Jan 2012 07:02:29 +0100
Message-ID: <1326434549.2617.14.camel@edumazet-laptop>
References: <CA+HUmGhJ-YvFMRnKzb8RqH6COZ=erp1SajVcb1rq1vi2k9OBGw@mail.gmail.com>
	 <1326349911.2741.1.camel@edumazet-laptop>
	 <m1pqeov4u1.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francesco Ruggeri <fruggeri@aristanetworks.com>,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49025 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794Ab2AMGCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 01:02:34 -0500
Received: by wgbds12 with SMTP id ds12so2682657wgb.1
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 22:02:32 -0800 (PST)
In-Reply-To: <m1pqeov4u1.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 12 janvier 2012 =C3=A0 16:11 -0800, Eric W. Biederman a =C3=A9=
crit :

> Because the rtnl_lock is broad and we have ABBA deadlocks if we don't=
 in
> particular we hold the rtnl_lock over sysctl registration and removal=
=2E
> sysctl removal blocks until all of the callers into the sysctl method=
s
> namely addrconf_sysctl_forward in this case finish executing.
>=20
> CPU 0                                         CPU 1
>=20
> rtnl_lock()                                   use_count++
> unregister_netdevice()                           addrconf_ctl_foward
>   unregister_sysctl_table()                        rtnl_lock()
>      wait for use_count of addrconf_ctl_forward
>        to =3D=3D 0
>     =20
>=20
> I smacked lockdep around so it would warn about the sysfs ones.
> The proc and sysctl ones I never did manage to get lockdep warnings
> but a ABBA deadlock is most definitely possible.
>=20
> Any solutions better than simply restarting the system call are welco=
me.
>=20
> Perhaps for these heavy weigh methods we should create a work struct
> and go schedule work to perform the change instead of trying to do th=
e
> work synchronously in the sysctl handler.
>=20

This idea was discussed in netconf 2011 (I focused on the ability to
dismantle netdevices at high rates), and I admit I had not implemented
yet.

The problem with rtnl_trylock() is that we make very litle progress if
many tasks are competing for rtnl, and we have no fairness.

The task holding RTNL might be descheduled and all cpus running other
threads spinning in rtnl_trylock()/restart_syscall(). Almost a deadlock=
=2E

Maybe waiting RTNL for at least a couple of ms would help, instead of
instantly failing rtnl_trylock() and looping.
