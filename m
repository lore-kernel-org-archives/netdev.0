From: Bill Fink <billfink@mindspring.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Thu, 20 Aug 2009 03:50:44 -0400
Message-ID: <20090820035044.9b70fca6.billfink@mindspring.com>
References: <20090807170600.9a2eff2e.billfink@mindspring.com>
	<20090807221211.GA16874@localhost.localdomain>
	<20090807205442.32918186.billfink@mindspring.com>
	<20090808015612.GA17710@localhost.localdomain>
	<20090814164412.be5daa74.billfink@mindspring.com>
	<20090814232543.GA28599@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Network Developers <netdev@vger.kernel.org>, brice@myri.com,
	gallatin@myri.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:58759 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750787AbZHTHuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 03:50:44 -0400
In-Reply-To: <20090814232543.GA28599@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Aug 2009, Neil Horman wrote:

> On Fri, Aug 14, 2009 at 04:44:12PM -0400, Bill Fink wrote:
> > On Fri, 7 Aug 2009, Neil Horman wrote:
> > 
> > > On Fri, Aug 07, 2009 at 08:54:42PM -0400, Bill Fink wrote:
> > > > On Fri, 7 Aug 2009, Neil Horman wrote:
> > > > 
> > > > > You're timing is impeccable!  I just posted a patch for an ftrace module to help
> > > > > detect just these kind of conditions:
> > > > > http://marc.info/?l=linux-netdev&m=124967650218846&w=2
> > > > > 
> > > > > Hope that helps you out
> > > > > Neil
> > > > 
> > > > Thanks!  It could be helpful.  Do you have a pointer to documentation
> > > > on how to use it?  And does it require the latest GIT kernel or could
> > > > it possibly be used with a 2.6.29.6 kernel?
> > > > 
> > > > 						-Bill
> > > 
> > > It should apply to 2.6.29.6 no problem (might take a little massaging, but not
> > > much).
> > 
> > It doesn't look like I can apply your patches to my 2.6.29.6 kernel.
> > 
> > For starters, there's no include/trace/events directory, so there's
> > no include/trace/events/skb.h.  There is an include/trace/skb.h file,
> > but there's no TRACE_EVENT defined anywhere in the kernel.
> > 
> > I don't suppose it's as simple as defining (from include/linux/tracepoint.h
> > from Linus's GIT tree):
> > 
> > #define PARAMS(args...) args
> > 
> > #define TRACE_EVENT(name, proto, args, struct, assign, print)   \
> > 	DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
> > 
> > So do you still think it's reasonable to try applying your patches
> > to my 2.6.29.6 kernel, or should I get a newer kernel like 2.6.30.4
> > or 2.6.31-rc6?
> > 
> > 						-Thanks
> > 
> > 						-Bill
> > 
> > 
> > 
> I thought the trace stuff went it around 2.6.29 but I might be mistaken.
> Easiest thing to do likely would be find where in the tree those were introduced
> and just apply them prior to my patches, or move to the latest kernel if you
> can (at least for the purposes of testing)

I finally got a 2.6.31-rc6 kernel built and had some limited success
with your ftrace patches.  Doing some simple ping tests I was able to
verify that everything was mostly as expected regarding CPU and NUMA
memory affinity, with one weird exception.  eth2 through eth7, which
all connect to the 5520 I/O Hub that connects to NUMA node 1, all
correctly showed their allocations and consumptions on NUMA node 1.
eth8 through eth13 are all connected to the 5520 I/O Hub that connects
to NUMA node 0, and eth9 through eth13 all correctly reflected that
on the ping ftrace tests.  But eth8 showed its allocations being
done on NUMA node 1 instead of the expected NUMA node 0, which just
doesn't make sense since eth8 and eth9 are part of a dual-port 10-GigE
Myricom NIC (and I doublechecked that all the IRQ assignments were
correct).

When I tried an actual nuttcp performance test, even when rate limiting
to just 1 Mbps, I immediately got a kernel oops.  I tried to get a
crashdump via kexec/kdump, but the kexec kernel, instead of just
generating a crashdump, fully booted the new kernel, which was
extremely sluggish until I rebooted it through a BIOS re-init,
and never produced a crashdump.  I tried this several times and
an immediate kernel oops was always the result (with either a TCP
or UDP test).  A ping test of 1000 9000-byte packets with an interval
of 0.001 seconds (which is 72 Mbps for 1 second) on the other hand
worked just fine.

						-Thanks

						-Bill
