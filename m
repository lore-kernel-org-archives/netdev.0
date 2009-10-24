From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: allow netdev_wait_allrefs() to run faster
Date: Sat, 24 Oct 2009 06:52:14 -0700
Message-ID: <20091024135214.GB6638@linux.vnet.ibm.com>
References: <20091017221857.GG1925@kvack.org> <4ADB55BC.5020107@gmail.com> <20091018182144.GC23395@kvack.org> <200910211539.01824.opurdila@ixiacom.com> <4ADF2B57.4030708@gmail.com> <20091023211338.GA6145@linux.vnet.ibm.com> <4AE28429.6040608@gmail.com> <20091024054943.GA6638@linux.vnet.ibm.com> <4AE2BFB3.3060407@gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>, netdev@vger.kernel.org,
	Cosmin Ratiu <cratiu@ixiacom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:60974 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753506AbZJXNwL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Oct 2009 09:52:11 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e4.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n9ODiQEX032429
	for <netdev@vger.kernel.org>; Sat, 24 Oct 2009 09:44:26 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9ODqFJD1048774
	for <netdev@vger.kernel.org>; Sat, 24 Oct 2009 09:52:15 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9ODqEXA006617
	for <netdev@vger.kernel.org>; Sat, 24 Oct 2009 09:52:15 -0400
Content-Disposition: inline
In-Reply-To: <4AE2BFB3.3060407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 24, 2009 at 10:49:55AM +0200, Eric Dumazet wrote:
> Paul E. McKenney a =E9crit :
> > On Sat, Oct 24, 2009 at 06:35:53AM +0200, Eric Dumazet wrote:
> >=20
> >> Maybe we could call it once only, if we had to call 1 times
> >> the jiffie delay ?
> >=20
> > This could be a very useful approach!
> >=20
> > However, please keep in mind that although synchronize_rcu_expedite=
d()
> > forces a grace period, it does nothing to speed the invocation of o=
ther
> > RCU callbacks.  In short, synchronize_rcu_expedited() is a faster v=
ersion
> > of synchronize_rcu(), but doesn't necessarily help other synchroniz=
e_rcu()
> > or call_rcu() invocations.
> >=20
> > The reason I point this out is that it looks to me that the code be=
low is
> > waiting for some other task which is in turn waiting on a grace per=
iod.
> > But I don't know this code, so could easily be confused.
> >=20
>=20
> Normally, we need a synchronize_rcu() calls, but I feel its bit more =
than really
> needed here.
>=20
> On my dev machine, a synchronize_rcu() lasts between 2 an 12 ms

That sounds like the right range, depending on what else is happening
on the machine at the time.

The synchronize_rcu_expedited() primitive would run in the 10s-100s
of microseconds.  It involves a pair of wakeups and a pair of context
switches on each CPU.

							Thanx, Paul

> messages:Oct 21 19:13:14 svivoipvnx001-00 kernel: [ 2515.580259] sync=
hronize_net() 4045596 ns
> messages:Oct 21 19:13:14 svivoipvnx001-00 kernel: [ 2515.588262] sync=
hronize_net() 7769327 ns
> messages:Oct 21 19:13:14 svivoipvnx001-00 kernel: [ 2515.625014] sync=
hronize_net() 4772052 ns
> messages:Oct 21 19:13:14 svivoipvnx001-00 kernel: [ 2515.633008] sync=
hronize_net() 7773896 ns
> messages:Oct 21 19:13:14 svivoipvnx001-00 kernel: [ 2515.669260] sync=
hronize_net() 3958141 ns
> messages:Oct 21 19:13:14 svivoipvnx001-00 kernel: [ 2515.677259] sync=
hronize_net() 7755817 ns
> messages:Oct 21 19:13:14 svivoipvnx001-00 kernel: [ 2515.712011] sync=
hronize_net() 2502544 ns
> messages:Oct 21 19:13:14 svivoipvnx001-00 kernel: [ 2515.720011] sync=
hronize_net() 7767748 ns
> messages:Oct 21 19:13:14 svivoipvnx001-00 kernel: [ 2515.754259] sync=
hronize_net() 2087946 ns
> messages:Oct 21 19:13:14 svivoipvnx001-00 kernel: [ 2515.762258] sync=
hronize_net() 7738054 ns
> messages:Oct 21 19:13:14 svivoipvnx001-00 kernel: [ 2515.796011] sync=
hronize_net() 3392760 ns
> messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2515.808025] sync=
hronize_net() 11814619 ns
> messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2515.848010] sync=
hronize_net() 8970220 ns
> messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2515.856015] sync=
hronize_net() 7800782 ns
> messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2515.893008] sync=
hronize_net() 6650174 ns
> messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2515.897012] sync=
hronize_net() 3744808 ns
> messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2515.940202] sync=
hronize_net() 8354366 ns
> messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2515.952137] sync=
hronize_net() 11693215 ns
> messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2515.985010] sync=
hronize_net() 2355970 ns
> messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2515.989009] sync=
hronize_net() 3771419 ns
> messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2516.028137] sync=
hronize_net() 7661195 ns
> messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2516.036152] sync=
hronize_net() 7800056 ns
> messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2516.083135] sync=
hronize_net() 6774026 ns
> messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2516.089145] sync=
hronize_net() 5727189 ns
> messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2516.130385] sync=
hronize_net() 10133932 ns
> messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2516.134399] sync=
hronize_net() 3773058 ns
> messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2516.170136] sync=
hronize_net() 4479194 ns
> messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2516.178138] sync=
hronize_net() 7710466 ns
> messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2516.217198] sync=
hronize_net() 4323437 ns
> messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2516.226206] sync=
hronize_net() 8723108 ns
> messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2516.268013] sync=
hronize_net() 6221155 ns
> messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2516.280007] sync=
hronize_net() 11719297 ns
> messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2516.324008] sync=
hronize_net() 11654511 ns
> messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2516.332009] sync=
hronize_net() 7744182 ns
>=20
