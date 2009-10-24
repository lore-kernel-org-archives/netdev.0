From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: allow netdev_wait_allrefs() to run faster
Date: Sat, 24 Oct 2009 07:46:10 -0700
Message-ID: <20091024144610.GC6638@linux.vnet.ibm.com>
References: <4ADB55BC.5020107@gmail.com> <20091018182144.GC23395@kvack.org> <200910211539.01824.opurdila@ixiacom.com> <4ADF2B57.4030708@gmail.com> <20091023211338.GA6145@linux.vnet.ibm.com> <4AE28429.6040608@gmail.com> <20091024054943.GA6638@linux.vnet.ibm.com> <4AE2BFB3.3060407@gmail.com> <20091024135214.GB6638@linux.vnet.ibm.com> <4AE30E1B.5080008@gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>, netdev@vger.kernel.org,
	Cosmin Ratiu <cratiu@ixiacom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:45992 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753569AbZJXOqJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Oct 2009 10:46:09 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e7.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n9OEgveF002562
	for <netdev@vger.kernel.org>; Sat, 24 Oct 2009 10:42:57 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9OEkBJL079850
	for <netdev@vger.kernel.org>; Sat, 24 Oct 2009 10:46:13 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9OEkAQb022543
	for <netdev@vger.kernel.org>; Sat, 24 Oct 2009 10:46:11 -0400
Content-Disposition: inline
In-Reply-To: <4AE30E1B.5080008@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 24, 2009 at 04:24:27PM +0200, Eric Dumazet wrote:
> Paul E. McKenney a =E9crit :
> > On Sat, Oct 24, 2009 at 10:49:55AM +0200, Eric Dumazet wrote:
> >>
> >> On my dev machine, a synchronize_rcu() lasts between 2 an 12 ms
> >=20
> > That sounds like the right range, depending on what else is happeni=
ng
> > on the machine at the time.
> >=20
> > The synchronize_rcu_expedited() primitive would run in the 10s-100s
> > of microseconds.  It involves a pair of wakeups and a pair of conte=
xt
> > switches on each CPU.
>=20
> Hmm... I'll make some experiments Monday and post results, but it see=
ms very
> promising.

I should hasten to add that synchronize_rcu_expedited() goes fast for
TREE_RCU but not yet for TREE_PREEMPT_RCU (where it maps safely but
slowly to synchronize_rcu()).

> Do you think the "on_each_cpu(flush_backlog, dev, 1);"
> we perform right before calling netdev_wait_allrefs() could be change=
d
> somehow to speedup rcu callbacks ? Maybe we ould avoid sending IPI tw=
ice to
> cpus ?

This is an interesting possibility, and might fit in with some of the
changes that I am thinking about to reduce OS jitter for the heavy-duty
numerical-computing guys.

In the meantime, you could try doing the following from flush_backlog()=
:

	local_irq_save(flags);
	rcu_check_callbacks(smp_processor_id(), 0);
	local_irq_restore(flags);

This would emulate a much-faster HZ value, but only for RCU.  This work=
s
better in TREE_RCU than it does in TREE_PREEMPT_RCU at the moment (on m=
y
todo list!).  In older kernels, this should also work for CLASSIC_RCU.
Of course, in TINY_RCU, synchronize_rcu() is a no-op anyway.  ;-)

And just to be clear, synchronize_rcu_expedited() currently just does
wakeups, not explicit IPIs.

							Thanx, Paul
