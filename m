From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: use synchronize_rcu_expedited()
Date: Tue, 24 May 2011 17:52:44 +0200
Message-ID: <1306252364.3026.63.camel@edumazet-laptop>
References: <1306228052.3026.16.camel@edumazet-laptop>
	 <20110524154445.GC2266@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35442 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932363Ab1EXPws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 11:52:48 -0400
Received: by wya21 with SMTP id 21so5095484wya.19
        for <netdev@vger.kernel.org>; Tue, 24 May 2011 08:52:47 -0700 (PDT)
In-Reply-To: <20110524154445.GC2266@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 24 mai 2011 =C3=A0 08:44 -0700, Paul E. McKenney a =C3=A9crit =
:
> On Tue, May 24, 2011 at 11:07:32AM +0200, Eric Dumazet wrote:
> > synchronize_rcu() is very slow in various situations (HZ=3D100,
> > CONFIG_NO_HZ=3Dy, CONFIG_PREEMPT=3Dn)
> >=20
> > Extract from my (mostly idle) 8 core machine :
> >=20
> >  synchronize_rcu() in 99985 us
> >  synchronize_rcu() in 79982 us
> >  synchronize_rcu() in 87612 us
> >  synchronize_rcu() in 79827 us
> >  synchronize_rcu() in 109860 us
> >  synchronize_rcu() in 98039 us
> >  synchronize_rcu() in 89841 us
> >  synchronize_rcu() in 79842 us
> >  synchronize_rcu() in 80151 us
> >  synchronize_rcu() in 119833 us
> >  synchronize_rcu() in 99858 us
> >  synchronize_rcu() in 73999 us
> >  synchronize_rcu() in 79855 us
> >  synchronize_rcu() in 79853 us
> >=20
> >=20
> > When we hold RTNL mutex, we would like to spend some cpu cycles but=
 not
> > block too long other processes waiting for this mutex.
> >=20
> > We also want to setup/dismantle network features as fast as possibl=
e at
> > boot/shutdown time.
> >=20
> > This patch makes synchronize_net() call the expedited version if RT=
NL is
> > locked.
> >=20
> > synchronize_rcu_expedited() typical delay is about 20 us on my mach=
ine.
> >=20
> >  synchronize_rcu_expedited() in 18 us
> >  synchronize_rcu_expedited() in 18 us
> >  synchronize_rcu_expedited() in 18 us
> >  synchronize_rcu_expedited() in 18 us
> >  synchronize_rcu_expedited() in 20 us
> >  synchronize_rcu_expedited() in 16 us
> >  synchronize_rcu_expedited() in 20 us
> >  synchronize_rcu_expedited() in 18 us
> >  synchronize_rcu_expedited() in 18 us
>=20
> Cool!!!
>=20
> Just out of curiosity, how many CPUs does your system have?

16 (2x4x2)  [ processor.max_cstate=3D1 ]

I am now trying to optimize rcu_barrier(), if you have an idea to get a=
n
expedited version as well ?

We can see in following trace 3 groups, spaced by one jiffie (HZ=3D100)

Maybe we can avoid sending a call_rcu() to a cpu that has no pending rc=
u
work ?

[  835.189996] cpu0 synchronize_rcu_expedited() in 30 us=20
   -> begin rcu_barrier() immediately
[  835.259702] cpu15 rcu_barrier_callback()
[  835.259705] cpu14 rcu_barrier_callback()
[  835.259708] cpu7 rcu_barrier_callback()
[  835.259711] cpu12 rcu_barrier_callback()
[  835.259714] cpu8 rcu_barrier_callback()
[  835.259716] cpu1 rcu_barrier_callback()
[  835.259719] cpu0 rcu_barrier_callback()

[  835.269691] cpu13 rcu_barrier_callback()
[  835.269695] cpu11 rcu_barrier_callback()
[  835.269698] cpu5 rcu_barrier_callback()
[  835.269700] cpu6 rcu_barrier_callback()
[  835.269702] cpu10 rcu_barrier_callback()
[  835.269705] cpu3 rcu_barrier_callback()
[  835.269707] cpu2 rcu_barrier_callback()

[  835.279687] cpu4 rcu_barrier_callback()
[  835.279689] cpu9 rcu_barrier_callback()
[  835.279744] cpu0 rcu_barrier() in 89499 us

Thanks


