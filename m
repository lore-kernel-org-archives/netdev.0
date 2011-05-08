From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Scalability of interface creation and deletion
Date: Sun, 8 May 2011 06:44:25 -0700
Message-ID: <20110508134425.GL2641@linux.vnet.ibm.com>
References: <0F4A638C2A523577CDBC295E@Ximines.local>
 <1304785589.3207.5.camel@edumazet-laptop>
 <178E8895FB84C07251538EF7@Ximines.local>
 <1304793174.3207.22.camel@edumazet-laptop>
 <1304793749.3207.26.camel@edumazet-laptop>
 <1304838742.3207.45.camel@edumazet-laptop>
 <F57561A93EFF5E88729A8D53@nimrod.local>
 <7B76F9D75FD26D716624004B@nimrod.local>
 <20110508125028.GK2641@linux.vnet.ibm.com>
 <B2891EFD056565BBD4DBCE16@nimrod.local>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Alex Bligh <alex@alex.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:37300 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751026Ab1EHNo3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 May 2011 09:44:29 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p48DXS4J030085
	for <netdev@vger.kernel.org>; Sun, 8 May 2011 09:33:28 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p48DiShI108284
	for <netdev@vger.kernel.org>; Sun, 8 May 2011 09:44:28 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p48DiRlQ002057
	for <netdev@vger.kernel.org>; Sun, 8 May 2011 09:44:27 -0400
Content-Disposition: inline
In-Reply-To: <B2891EFD056565BBD4DBCE16@nimrod.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 08, 2011 at 02:13:30PM +0100, Alex Bligh wrote:
> 
> >>The fact that increasing HZ masks the problem seems to imply that
> >>sychronize_sched() is waiting when it shouldn't be, as it suggests
> >>it's waiting for a context switch. But surely it shouldn't be
> >>waiting for context switch if all other cpu cores are idle?
> >>It knows that it (the caller) doesn't hold an rcu_read_lock,
> >>and presumably can see the other cpus are in the idle state,
> >>in which case surely it should return immediately? Distribution
> >>of latency in synchronize_sched() looks like this:
> >>
> >>20-49 us 110 instances (27.500%)
> >>50-99 us 45 instances (11.250%)
> >
> >Really?  I am having a hard time believing this above two.  Is this really
> >2000-4999 us and 5000-9999 us?  That would be much more believable,
> >and expected on a busy system with lots of context switching.  Or on a
> >system with CONFIG_NO_HZ=n.
> 
> Yes, really 20-49us and 50-99us, not ms. Raw data attached :-)
> 
> I'm guessing there are circumstances where there is an early exit.

Well, if you were onlining and offlining CPUs, then if there was only
one CPU online, this could happen.  And there really is only one CPU
online during boot, so if your measurements included early boot time,
this could easily explain these very short timings.

> $ fgrep HZ .config
> CONFIG_RCU_FAST_NO_HZ=y
> CONFIG_NO_HZ=y
> CONFIG_HZ_100=y
> # CONFIG_HZ_250 is not set
> # CONFIG_HZ_300 is not set
> # CONFIG_HZ_1000 is not set
> CONFIG_HZ=100
> # CONFIG_MACHZ_WDT is not set
> 
> >
> >>5000-9999 us 5 instances (1.250%)
> >
> >This makes sense for a mostly-idle system with frequent short bursts
> >of work.
> >
> >>10000-19999 us 33 instances (8.250%)
> >
> >This makes sense for a CONFIG_NO_HZ system that is idle, where there
> >is some amount of background work that is also using RCU grace periods.
> >
> >>20000-49999 us 4 instances (1.000%)
> >>50000-99999 us 191 instances (47.750%)
> >>100000-199999 us 12 instances (3.000%)
> >
> >These last involve additional delays.  Possibilities include long-running
> >irq handlers, SMIs, or NMIs.
> 
> There is nothing much going on these systems (idle, no other users,
> just normal system daemons).

And normal system daemons might cause this, right?

> Note this is with CONFIG_HZ=100 (which is the Ubuntu default). I wonder
> if that means you need to scale your expactations by a factor if 10 (i.e.
> you'd expect 50000-99999 for "a mostly-idle system with frequent
> short bursts of work."

Indeed, I was thinking in terms of HZ=1000.

							Thanx, Paul

> Interestingly there are quite a few of these on boot up. If this
> is a CONFIG_HZ thing, then setting it to 1000 would probably take
> half a second off bootup time.
> 
> 
> -- 
> Alex Bligh
> 
> 
> May  8 09:47:31 nattytest kernel: [  177.030197] synchronize_sched()
> in 66921 us
> May  8 09:47:31 nattytest kernel: [  177.120085] synchronize_sched()
> in 89080 us
> May  8 09:47:31 nattytest kernel: [  177.190910] synchronize_sched()
> in 46 us
> May  8 09:47:31 nattytest kernel: [  177.210087] synchronize_sched()
> in 18686 us
> May  8 09:47:32 nattytest kernel: [  177.400080] synchronize_sched()
> in 110609 us
> May  8 09:47:32 nattytest kernel: [  177.480071] synchronize_sched()
> in 78550 us
> May  8 09:47:32 nattytest kernel: [  177.550119] synchronize_sched()
> in 19087 us
> May  8 09:47:32 nattytest kernel: [  177.551761] synchronize_sched()
> in 79 us
> May  8 09:47:32 nattytest kernel: [  177.670085] synchronize_sched()
> in 60616 us
> May  8 09:47:32 nattytest kernel: [  177.760075] synchronize_sched()
> in 88465 us
> May  8 09:47:32 nattytest kernel: [  177.820999] synchronize_sched()
> in 45 us
> May  8 09:47:32 nattytest kernel: [  177.840086] synchronize_sched()
> in 17579 us
> May  8 09:47:32 nattytest kernel: [  177.970084] synchronize_sched()
> in 70925 us
> May  8 09:47:32 nattytest kernel: [  178.050092] synchronize_sched()
> in 78477 us
> May  8 09:47:32 nattytest kernel: [  178.101046] synchronize_sched()
> in 39 us
> May  8 09:47:32 nattytest kernel: [  178.102574] synchronize_sched()
> in 48 us
> May  8 09:47:33 nattytest kernel: [  178.230082] synchronize_sched()
> in 70966 us
> May  8 09:47:33 nattytest kernel: [  178.310071] synchronize_sched()
> in 78503 us
> May  8 09:47:33 nattytest kernel: [  178.371056] synchronize_sched()
> in 43 us
> May  8 09:47:33 nattytest kernel: [  178.390094] synchronize_sched()
> in 17553 us
> May  8 09:47:33 nattytest kernel: [  178.540084] synchronize_sched()
> in 70533 us
> May  8 09:47:33 nattytest kernel: [  178.620074] synchronize_sched()
> in 79172 us
> May  8 09:47:33 nattytest kernel: [  178.671124] synchronize_sched()
> in 57 us
> May  8 09:47:33 nattytest kernel: [  178.672645] synchronize_sched()
> in 49 us
> May  8 09:47:33 nattytest kernel: [  178.830106] synchronize_sched()
> in 100955 us
> May  8 09:47:33 nattytest kernel: [  178.910084] synchronize_sched()
> in 78408 us
> May  8 09:47:33 nattytest kernel: [  178.961090] synchronize_sched()
> in 43 us
> May  8 09:47:33 nattytest kernel: [  178.962642] synchronize_sched()
> in 50 us
> May  8 09:47:33 nattytest kernel: [  179.090088] synchronize_sched()
> in 71354 us
> May  8 09:47:33 nattytest kernel: [  179.220071] synchronize_sched()
> in 128463 us
> May  8 09:47:34 nattytest kernel: [  179.300867] synchronize_sched()
> in 52 us
> May  8 09:47:34 nattytest kernel: [  179.302079] synchronize_sched()
> in 48 us
> May  8 09:47:34 nattytest kernel: [  179.420085] synchronize_sched()
> in 61562 us
> May  8 09:47:34 nattytest kernel: [  179.500093] synchronize_sched()
> in 78506 us
> May  8 09:47:34 nattytest kernel: [  179.551048] synchronize_sched()
> in 42 us
> May  8 09:47:34 nattytest kernel: [  179.552637] synchronize_sched()
> in 51 us
> May  8 09:47:34 nattytest kernel: [  179.670088] synchronize_sched()
> in 61469 us
> May  8 09:47:34 nattytest kernel: [  179.760078] synchronize_sched()
> in 88430 us
> May  8 09:47:34 nattytest kernel: [  179.830918] synchronize_sched()
> in 44 us
> May  8 09:47:34 nattytest kernel: [  179.850173] synchronize_sched()
> in 17783 us
> May  8 09:47:34 nattytest kernel: [  180.080085] synchronize_sched()
> in 150585 us
> May  8 09:47:34 nattytest kernel: [  180.160082] synchronize_sched()
> in 78381 us
> May  8 09:47:34 nattytest kernel: [  180.211027] synchronize_sched()
> in 39 us
> May  8 09:47:34 nattytest kernel: [  180.212186] synchronize_sched()
> in 52 us
> May  8 09:47:35 nattytest kernel: [  180.320091] synchronize_sched()
> in 50520 us
> May  8 09:47:35 nattytest kernel: [  180.400074] synchronize_sched()
> in 78525 us
> May  8 09:47:35 nattytest kernel: [  180.451028] synchronize_sched()
> in 50 us
> May  8 09:47:35 nattytest kernel: [  180.452100] synchronize_sched()
> in 30 us
> May  8 09:47:35 nattytest kernel: [  180.570086] synchronize_sched()
> in 61211 us
> May  8 09:47:35 nattytest kernel: [  180.650073] synchronize_sched()
> in 79145 us
> May  8 09:47:35 nattytest kernel: [  180.701376] synchronize_sched()
> in 38 us
> May  8 09:47:35 nattytest kernel: [  180.703490] synchronize_sched()
> in 57 us
> May  8 09:47:35 nattytest kernel: [  180.820087] synchronize_sched()
> in 61483 us
> May  8 09:47:35 nattytest kernel: [  180.910081] synchronize_sched()
> in 88485 us
> May  8 09:47:35 nattytest kernel: [  180.965970] synchronize_sched()
> in 49 us
> May  8 09:47:35 nattytest kernel: [  180.990091] synchronize_sched()
> in 22425 us
> May  8 09:47:35 nattytest kernel: [  181.150084] synchronize_sched()
> in 71317 us
> May  8 09:47:36 nattytest kernel: [  181.230074] synchronize_sched()
> in 78470 us
> May  8 09:47:36 nattytest kernel: [  181.300099] synchronize_sched()
> in 18988 us
> May  8 09:47:36 nattytest kernel: [  181.301637] synchronize_sched()
> in 46 us
> May  8 09:47:36 nattytest kernel: [  181.420086] synchronize_sched()
> in 61240 us
> May  8 09:47:36 nattytest kernel: [  181.500072] synchronize_sched()
> in 77682 us
> May  8 09:47:36 nattytest kernel: [  181.551059] synchronize_sched()
> in 45 us
> May  8 09:47:36 nattytest kernel: [  181.552546] synchronize_sched()
> in 29 us
> May  8 09:47:36 nattytest kernel: [  181.670084] synchronize_sched()
> in 61612 us
> May  8 09:47:36 nattytest kernel: [  181.750076] synchronize_sched()
> in 78513 us
> May  8 09:47:36 nattytest kernel: [  181.801195] synchronize_sched()
> in 52 us
> May  8 09:47:36 nattytest kernel: [  181.802805] synchronize_sched()
> in 69 us
> May  8 09:47:36 nattytest kernel: [  181.920088] synchronize_sched()
> in 61998 us
> May  8 09:47:36 nattytest kernel: [  182.000091] synchronize_sched()
> in 78539 us
> May  8 09:47:36 nattytest kernel: [  182.051053] synchronize_sched()
> in 42 us
> May  8 09:47:36 nattytest kernel: [  182.052595] synchronize_sched()
> in 29 us
> May  8 09:47:36 nattytest kernel: [  182.170103] synchronize_sched()
> in 61607 us
> May  8 09:47:37 nattytest kernel: [  182.260072] synchronize_sched()
> in 88460 us
> May  8 09:47:37 nattytest kernel: [  182.331028] synchronize_sched()
> in 44 us
> May  8 09:47:37 nattytest kernel: [  182.350096] synchronize_sched()
> in 17563 us
> May  8 09:47:37 nattytest kernel: [  182.500085] synchronize_sched()
> in 71793 us
> May  8 09:47:37 nattytest kernel: [  182.620085] synchronize_sched()
> in 118343 us
> May  8 09:47:37 nattytest kernel: [  182.671024] synchronize_sched()
> in 39 us
> May  8 09:47:37 nattytest kernel: [  182.672511] synchronize_sched()
> in 29 us
> May  8 09:47:37 nattytest kernel: [  182.830096] synchronize_sched()
> in 101470 us
> May  8 09:47:37 nattytest kernel: [  182.910081] synchronize_sched()
> in 78413 us
> May  8 09:47:37 nattytest kernel: [  182.971056] synchronize_sched()
> in 43 us
> May  8 09:47:37 nattytest kernel: [  182.972568] synchronize_sched()
> in 44 us
> May  8 09:47:37 nattytest kernel: [  183.100084] synchronize_sched()
> in 60854 us
> May  8 09:47:37 nattytest kernel: [  183.170097] synchronize_sched()
> in 68450 us
> May  8 09:47:37 nattytest kernel: [  183.221081] synchronize_sched()
> in 40 us
> May  8 09:47:37 nattytest kernel: [  183.222580] synchronize_sched()
> in 29 us
> May  8 09:47:38 nattytest kernel: [  183.340082] synchronize_sched()
> in 61422 us
> May  8 09:47:38 nattytest kernel: [  183.420078] synchronize_sched()
> in 79154 us
> May  8 09:47:38 nattytest kernel: [  183.471003] synchronize_sched()
> in 41 us
> May  8 09:47:38 nattytest kernel: [  183.472469] synchronize_sched()
> in 29 us
> May  8 09:47:38 nattytest kernel: [  183.590095] synchronize_sched()
> in 61591 us
> May  8 09:47:38 nattytest kernel: [  183.670069] synchronize_sched()
> in 78533 us
> May  8 09:47:38 nattytest kernel: [  183.721106] synchronize_sched()
> in 43 us
> May  8 09:47:38 nattytest kernel: [  183.722663] synchronize_sched()
> in 49 us
> May  8 09:47:38 nattytest kernel: [  183.850094] synchronize_sched()
> in 71060 us
> May  8 09:47:38 nattytest kernel: [  183.930080] synchronize_sched()
> in 78522 us
> May  8 09:47:38 nattytest kernel: [  183.981040] synchronize_sched()
> in 44 us
> May  8 09:47:38 nattytest kernel: [  183.990375] synchronize_sched()
> in 7913 us
> May  8 09:47:38 nattytest kernel: [  184.150080] synchronize_sched()
> in 81568 us
> May  8 09:47:38 nattytest kernel: [  184.220088] synchronize_sched()
> in 68481 us
> May  8 09:47:39 nattytest kernel: [  184.281161] synchronize_sched()
> in 65 us
> May  8 09:47:39 nattytest kernel: [  184.282733] synchronize_sched()
> in 60 us
> May  8 09:47:39 nattytest kernel: [  184.400079] synchronize_sched()
> in 61791 us
> May  8 09:47:39 nattytest kernel: [  184.480104] synchronize_sched()
> in 79181 us
> May  8 09:47:39 nattytest kernel: [  184.550103] synchronize_sched()
> in 19063 us
> May  8 09:47:39 nattytest kernel: [  184.551621] synchronize_sched()
> in 30 us
> May  8 09:47:39 nattytest kernel: [  184.680083] synchronize_sched()
> in 71800 us
> May  8 09:47:39 nattytest kernel: [  184.750084] synchronize_sched()
> in 69162 us
> May  8 09:47:39 nattytest kernel: [  184.801153] synchronize_sched()
> in 51 us
> May  8 09:47:39 nattytest kernel: [  184.802802] synchronize_sched()
> in 53 us
> May  8 09:47:39 nattytest kernel: [  184.920091] synchronize_sched()
> in 61217 us
> May  8 09:47:39 nattytest kernel: [  185.000074] synchronize_sched()
> in 79141 us
> May  8 09:47:39 nattytest kernel: [  185.050985] synchronize_sched()
> in 40 us
> May  8 09:47:39 nattytest kernel: [  185.052727] synchronize_sched()
> in 47 us
> May  8 09:47:39 nattytest kernel: [  185.170087] synchronize_sched()
> in 62802 us
> May  8 09:47:40 nattytest kernel: [  185.250074] synchronize_sched()
> in 78418 us
> May  8 09:47:40 nattytest kernel: [  185.311022] synchronize_sched()
> in 40 us
> May  8 09:47:40 nattytest kernel: [  185.312542] synchronize_sched()
> in 63 us
> May  8 09:47:40 nattytest kernel: [  185.430111] synchronize_sched()
> in 61894 us
> May  8 09:47:40 nattytest kernel: [  185.510073] synchronize_sched()
> in 78410 us
> May  8 09:47:40 nattytest kernel: [  185.561055] synchronize_sched()
> in 58 us
> May  8 09:47:40 nattytest kernel: [  185.562589] synchronize_sched()
> in 45 us
> May  8 09:47:40 nattytest kernel: [  185.680091] synchronize_sched()
> in 62023 us
> May  8 09:47:40 nattytest kernel: [  185.760076] synchronize_sched()
> in 78438 us
> May  8 09:47:40 nattytest kernel: [  185.811063] synchronize_sched()
> in 45 us
> May  8 09:47:40 nattytest kernel: [  185.812580] synchronize_sched()
> in 52 us
> May  8 09:47:40 nattytest kernel: [  185.930089] synchronize_sched()
> in 61864 us
> May  8 09:47:40 nattytest kernel: [  186.010072] synchronize_sched()
> in 78465 us
> May  8 09:47:40 nattytest kernel: [  186.061141] synchronize_sched()
> in 44 us
> May  8 09:47:40 nattytest kernel: [  186.062631] synchronize_sched()
> in 29 us
> May  8 09:47:40 nattytest kernel: [  186.180078] synchronize_sched()
> in 61806 us
> May  8 09:47:41 nattytest kernel: [  186.260074] synchronize_sched()
> in 78415 us
> May  8 09:47:41 nattytest kernel: [  186.311073] synchronize_sched()
> in 43 us
> May  8 09:47:41 nattytest kernel: [  186.312573] synchronize_sched()
> in 29 us
> May  8 09:47:41 nattytest kernel: [  186.440083] synchronize_sched()
> in 72358 us
> May  8 09:47:41 nattytest kernel: [  186.520071] synchronize_sched()
> in 78395 us
> May  8 09:47:41 nattytest kernel: [  186.573068] synchronize_sched()
> in 66 us
> May  8 09:47:41 nattytest kernel: [  186.590105] synchronize_sched()
> in 15551 us
> May  8 09:47:41 nattytest kernel: [  186.740092] synchronize_sched()
> in 71884 us
> May  8 09:47:41 nattytest kernel: [  186.830069] synchronize_sched()
> in 89123 us
> May  8 09:47:41 nattytest kernel: [  186.890967] synchronize_sched()
> in 41 us
> May  8 09:47:41 nattytest kernel: [  186.910091] synchronize_sched()
> in 18639 us
> May  8 09:47:41 nattytest kernel: [  187.070078] synchronize_sched()
> in 82847 us
> May  8 09:47:41 nattytest kernel: [  187.140090] synchronize_sched()
> in 68499 us
> May  8 09:47:41 nattytest kernel: [  187.191148] synchronize_sched()
> in 57 us
> May  8 09:47:41 nattytest kernel: [  187.192743] synchronize_sched()
> in 69 us
> May  8 09:47:42 nattytest kernel: [  187.310087] synchronize_sched()
> in 63069 us
> May  8 09:47:42 nattytest kernel: [  187.400076] synchronize_sched()
> in 88432 us
> May  8 09:47:42 nattytest kernel: [  187.461521] synchronize_sched()
> in 57 us
> May  8 09:47:42 nattytest kernel: [  187.480099] synchronize_sched()
> in 16493 us
> May  8 09:47:42 nattytest kernel: [  187.640081] synchronize_sched()
> in 82269 us
> May  8 09:47:42 nattytest kernel: [  187.710079] synchronize_sched()
> in 68389 us
> May  8 09:47:42 nattytest kernel: [  187.761071] synchronize_sched()
> in 38 us
> May  8 09:47:42 nattytest kernel: [  187.762623] synchronize_sched()
> in 67 us
> May  8 09:47:42 nattytest kernel: [  187.880077] synchronize_sched()
> in 61847 us
> May  8 09:47:42 nattytest kernel: [  187.960096] synchronize_sched()
> in 78450 us
> May  8 09:47:42 nattytest kernel: [  188.011147] synchronize_sched()
> in 62 us
> May  8 09:47:42 nattytest kernel: [  188.012617] synchronize_sched()
> in 29 us
> May  8 09:47:42 nattytest kernel: [  188.130083] synchronize_sched()
> in 62431 us
> May  8 09:47:42 nattytest kernel: [  188.210090] synchronize_sched()
> in 78447 us
> May  8 09:47:43 nattytest kernel: [  188.261015] synchronize_sched()
> in 38 us
> May  8 09:47:43 nattytest kernel: [  188.262491] synchronize_sched()
> in 29 us
> May  8 09:47:43 nattytest kernel: [  188.380097] synchronize_sched()
> in 61923 us
> May  8 09:47:43 nattytest kernel: [  188.470131] synchronize_sched()
> in 88521 us
> May  8 09:47:43 nattytest kernel: [  188.531024] synchronize_sched()
> in 46 us
> May  8 09:47:43 nattytest kernel: [  188.550087] synchronize_sched()
> in 17676 us
> May  8 09:47:43 nattytest kernel: [  188.690085] synchronize_sched()
> in 71911 us
> May  8 09:47:43 nattytest kernel: [  188.820071] synchronize_sched()
> in 128473 us
> May  8 09:47:43 nattytest kernel: [  188.881032] synchronize_sched()
> in 42 us
> May  8 09:47:43 nattytest kernel: [  188.900085] synchronize_sched()
> in 17588 us
> May  8 09:47:43 nattytest kernel: [  189.080084] synchronize_sched()
> in 111945 us
> May  8 09:47:43 nattytest kernel: [  189.170068] synchronize_sched()
> in 88449 us
> May  8 09:47:43 nattytest kernel: [  189.221066] synchronize_sched()
> in 41 us
> May  8 09:47:44 nattytest kernel: [  189.230257] synchronize_sched()
> in 7463 us
> May  8 09:47:44 nattytest kernel: [  189.380093] synchronize_sched()
> in 71896 us
> May  8 09:47:44 nattytest kernel: [  189.470093] synchronize_sched()
> in 88481 us
> May  8 09:47:44 nattytest kernel: [  189.550883] synchronize_sched()
> in 43 us
> May  8 09:47:44 nattytest kernel: [  189.552391] synchronize_sched()
> in 29 us
> May  8 09:47:44 nattytest kernel: [  189.670085] synchronize_sched()
> in 61850 us
> May  8 09:47:44 nattytest kernel: [  189.760080] synchronize_sched()
> in 88549 us
> May  8 09:47:44 nattytest kernel: [  189.821014] synchronize_sched()
> in 44 us
> May  8 09:47:44 nattytest kernel: [  189.850080] synchronize_sched()
> in 27628 us
> May  8 09:47:44 nattytest kernel: [  189.990087] synchronize_sched()
> in 72251 us
> May  8 09:47:44 nattytest kernel: [  190.080074] synchronize_sched()
> in 88486 us
> May  8 09:47:44 nattytest kernel: [  190.150968] synchronize_sched()
> in 71 us
> May  8 09:47:44 nattytest kernel: [  190.170092] synchronize_sched()
> in 17672 us
> May  8 09:47:45 nattytest kernel: [  190.320088] synchronize_sched()
> in 71937 us
> May  8 09:47:45 nattytest kernel: [  190.410068] synchronize_sched()
> in 89155 us
> May  8 09:47:45 nattytest kernel: [  190.490882] synchronize_sched()
> in 40 us
> May  8 09:47:45 nattytest kernel: [  190.492405] synchronize_sched()
> in 29 us
> May  8 09:47:45 nattytest kernel: [  190.620103] synchronize_sched()
> in 62808 us
> May  8 09:47:45 nattytest kernel: [  190.700108] synchronize_sched()
> in 78486 us
> May  8 09:47:45 nattytest kernel: [  190.820119] synchronize_sched()
> in 69075 us
> May  8 09:47:45 nattytest kernel: [  190.870096] synchronize_sched()
> in 48447 us
> May  8 09:47:45 nattytest kernel: [  191.000082] synchronize_sched()
> in 62795 us
> May  8 09:47:45 nattytest kernel: [  191.080082] synchronize_sched()
> in 78489 us
> May  8 09:47:45 nattytest kernel: [  191.141021] synchronize_sched()
> in 61 us
> May  8 09:47:45 nattytest kernel: [  191.160086] synchronize_sched()
> in 17596 us
> May  8 09:47:46 nattytest kernel: [  191.310097] synchronize_sched()
> in 82089 us
> May  8 09:47:46 nattytest kernel: [  191.390076] synchronize_sched()
> in 78427 us
> May  8 09:47:46 nattytest kernel: [  191.451045] synchronize_sched()
> in 49 us
> May  8 09:47:46 nattytest kernel: [  191.470088] synchronize_sched()
> in 17643 us
> May  8 09:47:46 nattytest kernel: [  191.620095] synchronize_sched()
> in 72871 us
> May  8 09:47:46 nattytest kernel: [  191.700072] synchronize_sched()
> in 79137 us
> May  8 09:47:46 nattytest kernel: [  191.751087] synchronize_sched()
> in 40 us
> May  8 09:47:46 nattytest kernel: [  191.752600] synchronize_sched()
> in 48 us
> May  8 09:47:46 nattytest kernel: [  191.880092] synchronize_sched()
> in 72297 us
> May  8 09:47:46 nattytest kernel: [  191.950076] synchronize_sched()
> in 69142 us
> May  8 09:47:46 nattytest kernel: [  192.005349] synchronize_sched()
> in 54 us
> May  8 09:47:46 nattytest kernel: [  192.006834] synchronize_sched()
> in 30 us
> May  8 09:47:46 nattytest kernel: [  192.130091] synchronize_sched()
> in 72839 us
> May  8 09:47:46 nattytest kernel: [  192.210069] synchronize_sched()
> in 78535 us
> May  8 09:47:47 nattytest kernel: [  192.270973] synchronize_sched()
> in 43 us
> May  8 09:47:47 nattytest kernel: [  192.300094] synchronize_sched()
> in 27592 us
> May  8 09:47:47 nattytest kernel: [  192.450079] synchronize_sched()
> in 83072 us
> May  8 09:47:47 nattytest kernel: [  192.520073] synchronize_sched()
> in 68499 us
> May  8 09:47:47 nattytest kernel: [  192.571106] synchronize_sched()
> in 44 us
> May  8 09:47:47 nattytest kernel: [  192.572585] synchronize_sched()
> in 29 us
> May  8 09:47:47 nattytest kernel: [  192.700080] synchronize_sched()
> in 62670 us
> May  8 09:47:47 nattytest kernel: [  192.820084] synchronize_sched()
> in 118509 us
> May  8 09:47:47 nattytest kernel: [  192.871107] synchronize_sched()
> in 69 us
> May  8 09:47:47 nattytest kernel: [  192.872611] synchronize_sched()
> in 29 us
> May  8 09:47:47 nattytest kernel: [  192.990110] synchronize_sched()
> in 62742 us
> May  8 09:47:47 nattytest kernel: [  193.080070] synchronize_sched()
> in 89147 us
> May  8 09:47:47 nattytest kernel: [  193.150962] synchronize_sched()
> in 65 us
> May  8 09:47:47 nattytest kernel: [  193.160285] synchronize_sched()
> in 8879 us
> May  8 09:47:48 nattytest kernel: [  193.300097] synchronize_sched()
> in 72753 us
> May  8 09:47:48 nattytest kernel: [  193.380075] synchronize_sched()
> in 78472 us
> May  8 09:47:48 nattytest kernel: [  193.431029] synchronize_sched()
> in 41 us
> May  8 09:47:48 nattytest kernel: [  193.432518] synchronize_sched()
> in 30 us
> May  8 09:47:48 nattytest kernel: [  193.560081] synchronize_sched()
> in 72448 us
> May  8 09:47:48 nattytest kernel: [  193.670073] synchronize_sched()
> in 108452 us
> May  8 09:47:48 nattytest kernel: [  193.721098] synchronize_sched()
> in 49 us
> May  8 09:47:48 nattytest kernel: [  193.722821] synchronize_sched()
> in 30 us
> May  8 09:47:48 nattytest kernel: [  193.840075] synchronize_sched()
> in 62317 us
> May  8 09:47:48 nattytest kernel: [  193.920070] synchronize_sched()
> in 78472 us
> May  8 09:47:48 nattytest kernel: [  193.971073] synchronize_sched()
> in 43 us
> May  8 09:47:48 nattytest kernel: [  193.972550] synchronize_sched()
> in 29 us
> May  8 09:47:48 nattytest kernel: [  194.100088] synchronize_sched()
> in 72391 us
> May  8 09:47:48 nattytest kernel: [  194.170082] synchronize_sched()
> in 69202 us
> May  8 09:47:48 nattytest kernel: [  194.221053] synchronize_sched()
> in 40 us
> May  8 09:47:48 nattytest kernel: [  194.222543] synchronize_sched()
> in 29 us
> May  8 09:47:49 nattytest kernel: [  194.350082] synchronize_sched()
> in 72874 us
> May  8 09:47:49 nattytest kernel: [  194.430068] synchronize_sched()
> in 78536 us
> May  8 09:47:49 nattytest kernel: [  194.481167] synchronize_sched()
> in 70 us
> May  8 09:47:49 nattytest kernel: [  194.500091] synchronize_sched()
> in 17486 us
> May  8 09:47:49 nattytest kernel: [  194.640088] synchronize_sched()
> in 73012 us
> May  8 09:47:49 nattytest kernel: [  194.730069] synchronize_sched()
> in 88519 us
> May  8 09:47:49 nattytest kernel: [  194.781117] synchronize_sched()
> in 46 us
> May  8 09:47:49 nattytest kernel: [  194.792950] synchronize_sched()
> in 10384 us
> May  8 09:47:49 nattytest kernel: [  194.910126] synchronize_sched()
> in 63131 us
> May  8 09:47:49 nattytest kernel: [  195.000088] synchronize_sched()
> in 88453 us
> May  8 09:47:49 nattytest kernel: [  195.160080] synchronize_sched()
> in 79582 us
> May  8 09:47:50 nattytest kernel: [  195.240073] synchronize_sched()
> in 79132 us
> May  8 09:47:50 nattytest kernel: [  195.360124] synchronize_sched()
> in 62368 us
> May  8 09:47:50 nattytest kernel: [  195.440096] synchronize_sched()
> in 79148 us
> May  8 09:47:50 nattytest kernel: [  195.491063] synchronize_sched()
> in 53 us
> May  8 09:47:50 nattytest kernel: [  195.492182] synchronize_sched()
> in 29 us
> May  8 09:47:50 nattytest kernel: [  195.610085] synchronize_sched()
> in 62444 us
> May  8 09:47:50 nattytest kernel: [  195.700078] synchronize_sched()
> in 89170 us
> May  8 09:47:50 nattytest kernel: [  195.761011] synchronize_sched()
> in 57 us
> May  8 09:47:50 nattytest kernel: [  195.780137] synchronize_sched()
> in 18587 us
> May  8 09:47:50 nattytest kernel: [  195.920080] synchronize_sched()
> in 73194 us
> May  8 09:47:50 nattytest kernel: [  196.000073] synchronize_sched()
> in 78456 us
> May  8 09:47:50 nattytest kernel: [  196.051067] synchronize_sched()
> in 42 us
> May  8 09:47:50 nattytest kernel: [  196.052613] synchronize_sched()
> in 44 us
> May  8 09:47:50 nattytest kernel: [  196.170080] synchronize_sched()
> in 63040 us
> May  8 09:47:51 nattytest kernel: [  196.250075] synchronize_sched()
> in 78420 us
> May  8 09:47:51 nattytest kernel: [  196.301051] synchronize_sched()
> in 46 us
> May  8 09:47:51 nattytest kernel: [  196.302527] synchronize_sched()
> in 29 us
> May  8 09:47:51 nattytest kernel: [  196.420095] synchronize_sched()
> in 62701 us
> May  8 09:47:51 nattytest kernel: [  196.500064] synchronize_sched()
> in 78448 us
> May  8 09:47:51 nattytest kernel: [  196.551104] synchronize_sched()
> in 48 us
> May  8 09:47:51 nattytest kernel: [  196.552631] synchronize_sched()
> in 49 us
> May  8 09:47:51 nattytest kernel: [  196.670084] synchronize_sched()
> in 63111 us
> May  8 09:47:51 nattytest kernel: [  196.750095] synchronize_sched()
> in 78464 us
> May  8 09:47:51 nattytest kernel: [  196.801082] synchronize_sched()
> in 60 us
> May  8 09:47:51 nattytest kernel: [  196.802616] synchronize_sched()
> in 43 us
> May  8 09:47:51 nattytest kernel: [  196.930124] synchronize_sched()
> in 73010 us
> May  8 09:47:51 nattytest kernel: [  197.010084] synchronize_sched()
> in 78359 us
> May  8 09:47:51 nattytest kernel: [  197.071137] synchronize_sched()
> in 79 us
> May  8 09:47:51 nattytest kernel: [  197.080320] synchronize_sched()
> in 7773 us
> May  8 09:47:52 nattytest kernel: [  197.230086] synchronize_sched()
> in 83245 us
> May  8 09:47:52 nattytest kernel: [  197.310075] synchronize_sched()
> in 78509 us
> May  8 09:47:52 nattytest kernel: [  197.361050] synchronize_sched()
> in 44 us
> May  8 09:47:52 nattytest kernel: [  197.380084] synchronize_sched()
> in 17591 us
> May  8 09:47:52 nattytest kernel: [  197.530084] synchronize_sched()
> in 82999 us
> May  8 09:47:52 nattytest kernel: [  197.610080] synchronize_sched()
> in 79162 us
> May  8 09:47:52 nattytest kernel: [  197.680937] synchronize_sched()
> in 65 us
> May  8 09:47:52 nattytest kernel: [  197.700096] synchronize_sched()
> in 18620 us
> May  8 09:47:52 nattytest kernel: [  197.850141] synchronize_sched()
> in 73601 us
> May  8 09:47:52 nattytest kernel: [  197.930091] synchronize_sched()
> in 78393 us
> May  8 09:47:52 nattytest kernel: [  197.981050] synchronize_sched()
> in 39 us
> May  8 09:47:52 nattytest kernel: [  197.982788] synchronize_sched()
> in 29 us
> May  8 09:47:52 nattytest kernel: [  198.110084] synchronize_sched()
> in 72893 us
> May  8 09:47:52 nattytest kernel: [  198.180072] synchronize_sched()
> in 69151 us
> May  8 09:47:53 nattytest kernel: [  198.231098] synchronize_sched()
> in 50 us
> May  8 09:47:53 nattytest kernel: [  198.232679] synchronize_sched()
> in 46 us
> May  8 09:47:53 nattytest kernel: [  198.370084] synchronize_sched()
> in 72935 us
> May  8 09:47:53 nattytest kernel: [  198.450068] synchronize_sched()
> in 78461 us
> May  8 09:47:53 nattytest kernel: [  198.511077] synchronize_sched()
> in 77 us
> May  8 09:47:53 nattytest kernel: [  198.530094] synchronize_sched()
> in 17512 us
> May  8 09:47:53 nattytest kernel: [  198.670095] synchronize_sched()
> in 83122 us
> May  8 09:47:53 nattytest kernel: [  198.740079] synchronize_sched()
> in 68453 us
> May  8 09:47:53 nattytest kernel: [  198.801121] synchronize_sched()
> in 48 us
> May  8 09:47:53 nattytest kernel: [  198.802600] synchronize_sched()
> in 29 us
> May  8 09:47:53 nattytest kernel: [  198.920100] synchronize_sched()
> in 63392 us
> May  8 09:47:53 nattytest kernel: [  199.000088] synchronize_sched()
> in 78482 us
> May  8 09:47:53 nattytest kernel: [  199.070099] synchronize_sched()
> in 19013 us
> May  8 09:47:53 nattytest kernel: [  199.071626] synchronize_sched()
> in 48 us
> May  8 09:47:53 nattytest kernel: [  199.190083] synchronize_sched()
> in 63245 us
> May  8 09:47:54 nattytest kernel: [  199.270075] synchronize_sched()
> in 78491 us
> May  8 09:47:54 nattytest kernel: [  199.321088] synchronize_sched()
> in 42 us
> May  8 09:47:54 nattytest kernel: [  199.322589] synchronize_sched()
> in 29 us
> May  8 09:47:54 nattytest kernel: [  199.440101] synchronize_sched()
> in 63063 us
> May  8 09:47:54 nattytest kernel: [  199.520073] synchronize_sched()
> in 78463 us
> May  8 09:47:54 nattytest kernel: [  199.571056] synchronize_sched()
> in 49 us
> May  8 09:47:54 nattytest kernel: [  199.572488] synchronize_sched()
> in 29 us
> May  8 09:47:54 nattytest kernel: [  199.700083] synchronize_sched()
> in 73220 us
> May  8 09:47:54 nattytest kernel: [  199.770096] synchronize_sched()
> in 68508 us
> May  8 09:47:54 nattytest kernel: [  199.821090] synchronize_sched()
> in 50 us
> May  8 09:47:54 nattytest kernel: [  199.822540] synchronize_sched()
> in 29 us
> May  8 09:47:54 nattytest kernel: [  199.940084] synchronize_sched()
> in 63681 us
> May  8 09:47:54 nattytest kernel: [  200.020067] synchronize_sched()
> in 78451 us
> May  8 09:47:54 nattytest kernel: [  200.071095] synchronize_sched()
> in 41 us
> May  8 09:47:54 nattytest kernel: [  200.072566] synchronize_sched()
> in 29 us
> May  8 09:47:54 nattytest kernel: [  200.190089] synchronize_sched()
> in 63584 us
> May  8 09:47:55 nattytest kernel: [  200.280076] synchronize_sched()
> in 89123 us
> May  8 09:47:55 nattytest kernel: [  200.341011] synchronize_sched()
> in 61 us
> May  8 09:47:55 nattytest kernel: [  200.360094] synchronize_sched()
> in 18527 us
> May  8 09:47:55 nattytest kernel: [  200.520085] synchronize_sched()
> in 94129 us
> May  8 09:47:55 nattytest kernel: [  200.670072] synchronize_sched()
> in 148512 us
> May  8 09:47:55 nattytest kernel: [  200.730983] synchronize_sched()
> in 41 us
> May  8 09:47:55 nattytest kernel: [  200.750355] synchronize_sched()
> in 17917 us
> May  8 09:47:55 nattytest kernel: [  200.890082] synchronize_sched()
> in 83406 us
> May  8 09:47:55 nattytest kernel: [  200.970072] synchronize_sched()
> in 78439 us
> May  8 09:47:55 nattytest kernel: [  201.031034] synchronize_sched()
> in 45 us
> May  8 09:47:55 nattytest kernel: [  201.050090] synchronize_sched()
> in 17555 us
> May  8 09:47:55 nattytest kernel: [  201.200090] synchronize_sched()
> in 83318 us
> May  8 09:47:56 nattytest kernel: [  201.270075] synchronize_sched()
> in 68468 us
> May  8 09:47:56 nattytest kernel: [  201.330983] synchronize_sched()
> in 41 us
> May  8 09:47:56 nattytest kernel: [  201.332487] synchronize_sched()
> in 62 us
> May  8 09:47:56 nattytest kernel: [  201.450088] synchronize_sched()
> in 53772 us
> May  8 09:47:56 nattytest kernel: [  201.530075] synchronize_sched()
> in 78437 us
> May  8 09:47:56 nattytest kernel: [  201.590986] synchronize_sched()
> in 46 us
> May  8 09:47:56 nattytest kernel: [  201.592134] synchronize_sched()
> in 29 us
> May  8 09:47:56 nattytest kernel: [  201.710085] synchronize_sched()
> in 63551 us
> May  8 09:47:56 nattytest kernel: [  201.830146] synchronize_sched()
> in 118553 us
> May  8 09:47:56 nattytest kernel: [  201.891143] synchronize_sched()
> in 50 us
> May  8 09:47:56 nattytest kernel: [  201.892712] synchronize_sched()
> in 55 us
> May  8 09:47:56 nattytest kernel: [  202.010092] synchronize_sched()
> in 63446 us
> May  8 09:47:56 nattytest kernel: [  202.090126] synchronize_sched()
> in 78477 us
> May  8 09:47:56 nattytest kernel: [  202.141120] synchronize_sched()
> in 45 us
> May  8 09:47:56 nattytest kernel: [  202.142867] synchronize_sched()
> in 30 us
> May  8 09:47:57 nattytest kernel: [  202.260092] synchronize_sched()
> in 63271 us
> May  8 09:47:57 nattytest kernel: [  202.340071] synchronize_sched()
> in 78474 us
> May  8 09:47:57 nattytest kernel: [  202.391094] synchronize_sched()
> in 44 us
> May  8 09:47:57 nattytest kernel: [  202.392581] synchronize_sched()
> in 29 us
> May  8 09:47:57 nattytest kernel: [  202.510110] synchronize_sched()
> in 63718 us
> May  8 09:47:57 nattytest kernel: [  202.600092] synchronize_sched()
> in 88434 us
> May  8 09:47:57 nattytest kernel: [  202.661075] synchronize_sched()
> in 46 us
> May  8 09:47:57 nattytest kernel: [  202.680091] synchronize_sched()
> in 17516 us
> May  8 09:47:57 nattytest kernel: [  202.820083] synchronize_sched()
> in 83733 us
> May  8 09:47:57 nattytest kernel: [  202.900067] synchronize_sched()
> in 78478 us
> May  8 09:47:57 nattytest kernel: [  202.951062] synchronize_sched()
> in 43 us
> May  8 09:47:57 nattytest kernel: [  202.960445] synchronize_sched()
> in 7921 us
> May  8 09:47:57 nattytest kernel: [  203.100080] synchronize_sched()
> in 83496 us
> May  8 09:47:57 nattytest kernel: [  203.170084] synchronize_sched()
> in 68474 us
> May  8 09:47:57 nattytest kernel: [  203.221083] synchronize_sched()
> in 41 us
> May  8 09:47:57 nattytest kernel: [  203.222692] synchronize_sched()
> in 68 us
> May  8 09:47:58 nattytest kernel: [  203.350083] synchronize_sched()
> in 74062 us
> May  8 09:47:58 nattytest kernel: [  203.430100] synchronize_sched()
> in 78468 us
> May  8 09:47:58 nattytest kernel: [  203.491028] synchronize_sched()
> in 52 us
> May  8 09:47:58 nattytest kernel: [  203.510086] synchronize_sched()
> in 17607 us
> May  8 09:47:58 nattytest kernel: [  203.670080] synchronize_sched()
> in 83798 us
> May  8 09:47:58 nattytest kernel: [  203.750080] synchronize_sched()
> in 78382 us
> May  8 09:47:58 nattytest kernel: [  203.821032] synchronize_sched()
> in 48 us
> May  8 09:47:58 nattytest kernel: [  203.840093] synchronize_sched()
> in 17608 us
> May  8 09:47:58 nattytest kernel: [  203.990084] synchronize_sched()
> in 73664 us
> May  8 09:47:58 nattytest kernel: [  204.080078] synchronize_sched()
> in 88391 us
> May  8 09:47:58 nattytest kernel: [  204.141021] synchronize_sched()
> in 44 us
> May  8 09:47:58 nattytest kernel: [  204.160083] synchronize_sched()
> in 17671 us
> May  8 09:47:59 nattytest kernel: [  204.310086] synchronize_sched()
> in 83288 us
> May  8 09:47:59 nattytest kernel: [  204.380074] synchronize_sched()
> in 69168 us
> May  8 09:47:59 nattytest kernel: [  204.431059] synchronize_sched()
> in 67 us
> May  8 09:47:59 nattytest kernel: [  204.432205] synchronize_sched()
> in 30 us
> May  8 09:47:59 nattytest kernel: [  204.550147] synchronize_sched()
> in 54218 us
> May  8 09:47:59 nattytest kernel: [  204.640079] synchronize_sched()
> in 88401 us
> May  8 09:47:59 nattytest kernel: [  204.701062] synchronize_sched()
> in 48 us
> May  8 09:47:59 nattytest kernel: [  204.720093] synchronize_sched()
> in 17508 us
> May  8 09:47:59 nattytest kernel: [  204.850108] synchronize_sched()
> in 73968 us
> May  8 09:47:59 nattytest kernel: [  204.940074] synchronize_sched()
> in 88489 us
> May  8 09:47:59 nattytest kernel: [  205.011002] synchronize_sched()
> in 44 us
> May  8 09:47:59 nattytest kernel: [  205.030104] synchronize_sched()
> in 17658 us
> May  8 09:47:59 nattytest kernel: [  205.190091] synchronize_sched()
> in 83651 us
> May  8 09:48:00 nattytest kernel: [  205.270094] synchronize_sched()
> in 78501 us
> May  8 09:48:00 nattytest kernel: [  205.341000] synchronize_sched()
> in 65 us
> May  8 09:48:00 nattytest kernel: [  205.360081] synchronize_sched()
> in 17640 us
> 
> 
> 
> 
