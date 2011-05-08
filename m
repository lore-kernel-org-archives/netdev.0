From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Scalability of interface creation and deletion
Date: Sun, 8 May 2011 08:48:54 -0700
Message-ID: <20110508154854.GT2641@linux.vnet.ibm.com>
References: <1304793749.3207.26.camel@edumazet-laptop>
 <1304838742.3207.45.camel@edumazet-laptop>
 <F57561A93EFF5E88729A8D53@nimrod.local>
 <7B76F9D75FD26D716624004B@nimrod.local>
 <20110508125028.GK2641@linux.vnet.ibm.com>
 <B2891EFD056565BBD4DBCE16@nimrod.local>
 <20110508134425.GL2641@linux.vnet.ibm.com>
 <C449131127D58077CB25C9D8@Ximines.local>
 <20110508144749.GR2641@linux.vnet.ibm.com>
 <AB9DE9E04289CF29CA79CC67@Ximines.local>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Alex Bligh <alex@alex.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:35531 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752790Ab1EHPs5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 May 2011 11:48:57 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p48FRJCg032425
	for <netdev@vger.kernel.org>; Sun, 8 May 2011 11:27:19 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p48Fmu7A099342
	for <netdev@vger.kernel.org>; Sun, 8 May 2011 11:48:56 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p48FmtdQ032338
	for <netdev@vger.kernel.org>; Sun, 8 May 2011 11:48:56 -0400
Content-Disposition: inline
In-Reply-To: <AB9DE9E04289CF29CA79CC67@Ximines.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 08, 2011 at 04:17:42PM +0100, Alex Bligh wrote:
> Paul,
> 
> >>No, I waited a few minutes after boot for the system to stabilize, and
> >>all CPUs were definitely online.
> >>
> >>The patch to the kernel I am running is below.
> >
> >OK, interesting...
> >
> >My guess is that you need to be using ktime_get_ts().  Isn't ktime_get()
> >subject to various sorts of adjustment?
> 
> It's Eric's code, not mine, but:
> 
> kernel/time/timekeeping.c suggests they do the same thing
> (adjust xtime by wall_to_monotonic), just one returns a
> struct timespec and the other returns a ktime_t.
> 
> >>>> There is nothing much going on these systems (idle, no other users,
> >>>> just normal system daemons).
> >>>
> >>> And normal system daemons might cause this, right?
> >>
> >>Yes. Everything is normal, except I did
> >>service udev stop
> >>unshare -n bash
> >>which together stop the system running interface scripts when
> >>interfaces are created (as upstart and upstart-udev-bridge are
> >>now integrated, you can't kill upstart, so you have to rely on
> >>unshare -n to stop the events being propagated). That's just
> >>to avoid measuring the time it takes to execute the scripts.
> >
> >OK, so you really could be seeing grace periods started by these system
> >daemons.
> 
> In 50% of 200 calls? That seems pretty unlikely. I think it's more
> likely to be the 6 jiffies per call to ensure cpus are idle,
> plus the 3 calls per interface destroy.
> 
> If 6 jiffies per call to ensure cpus are idle is a fact of life,
> then the question goes back to why interface removal is waiting
> for rcu readers to be released synchronously, as opposed to
> doing the update bits synchronously, then doing the reclaim
> element (freeing the memory) afterwards using call_rcu.

This would speed things up considerably, assuming that there is no
other reason to block for an RCU grace period.

							Thanx, Paul
