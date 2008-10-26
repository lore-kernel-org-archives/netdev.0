From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Sun, 26 Oct 2008 02:11:53 -0700
Message-ID: <20081026021153.47878580.akpm@linux-foundation.org>
References: <20081024.221653.23695396.davem@davemloft.net>
	<1224914333.3822.18.camel@marge.simson.net>
	<1224917623.4929.15.camel@marge.simson.net>
	<20081025.002420.82739316.davem@davemloft.net>
	<Pine.LNX.4.64.0810260055070.22126@twin.jikos.cz>
	<1225010790.8566.22.camel@marge.simson.net>
	<1225011648.27415.4.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mike Galbraith <efault@gmx.de>, Jiri Kosina <jkosina@suse.cz>,
	David Miller <davem@davemloft.net>, rjw@sisk.pl,
	Ingo Molnar <mingo@elte.hu>, s0mbre@tservice.net.ru,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38166 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750944AbYJZJNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 05:13:08 -0400
In-Reply-To: <1225011648.27415.4.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 26 Oct 2008 10:00:48 +0100 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> On Sun, 2008-10-26 at 09:46 +0100, Mike Galbraith wrote: 
> > On Sun, 2008-10-26 at 01:10 +0200, Jiri Kosina wrote:
> > > On Sat, 25 Oct 2008, David Miller wrote:
> > > 
> > > > But note that tbench performance improved a bit in 2.6.25.
> > > > In my tests I noticed a similar effect, but from 2.6.23 to 2.6.24,
> > > > weird.
> > > > Just for the public record here are the numbers I got in my testing.
> > > 
> > > I have been currently looking at very similarly looking issue. For the 
> > > public record, here are the numbers we have been able to come up with so 
> > > far (measured with dbench, so the absolute values are slightly different, 
> > > but still shows similar pattern)
> > > 
> > > 208.4 MB/sec  -- vanilla 2.6.16.60
> > > 201.6 MB/sec  -- vanilla 2.6.20.1
> > > 172.9 MB/sec  -- vanilla 2.6.22.19
> > > 74.2 MB/sec   -- vanilla 2.6.23
> > >  46.1 MB/sec  -- vanilla 2.6.24.2
> > >  30.6 MB/sec  -- vanilla 2.6.26.1
> > > 
> > > I.e. huge drop for 2.6.23 (this was with default configs for each 
> > > respective kernel).

Was this when we decreased the default value of
/proc/sys/vm/dirty_ratio, perhaps?  dbench is sensitive to that.

> > > 2.6.23-rc1 shows 80.5 MB/s, i.e. a few % better than final 2.6.23, but 
> > > still pretty bad. 
> > > 
> > > I have gone through the commits that went into -rc1 and tried to figure 
> > > out which one could be responsible. Here are the numbers:
> > > 
> > >  85.3 MB/s for 2ba2d00363 (just before on-deman readahead has been merged)
> > >  82.7 MB/s for 45426812d6 (before cond_resched() has been added into page 
> > > 187.7 MB/s for c1e4fe711a4 (just before CFS scheduler has been merged)
> > >                            invalidation code)
> > > 
> > > So the current bigest suspect is CFS, but I don't have enough numbers yet 
> > > to be able to point a finger to it with 100% certainity. Hopefully soon.
> 
> > I reproduced this on my Q6600 box.  However, I also reproduced it with
> > 2.6.22.19.  What I think you're seeing is just dbench creating a
> > massive train wreck. 
> 
> wasn't dbench one of those non-benchmarks that thrives on randomness and
> unfairness?
> 
> Andrew said recently:
>   "dbench is pretty chaotic and it could be that a good change causes
> dbench to get worse.  That's happened plenty of times in the past."
> 
> So I'm not inclined to worry too much about dbench in any way shape or
> form.

Well.  If there is a consistent change in dbench throughput, it is
important that we at least understand the reasons for it.  But we
don't necessarily want to optimise for dbench throughput.

