From: Bill Fink <billfink@mindspring.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Fri, 14 Aug 2009 16:44:12 -0400
Message-ID: <20090814164412.be5daa74.billfink@mindspring.com>
References: <20090807170600.9a2eff2e.billfink@mindspring.com>
	<20090807221211.GA16874@localhost.localdomain>
	<20090807205442.32918186.billfink@mindspring.com>
	<20090808015612.GA17710@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Network Developers <netdev@vger.kernel.org>, brice@myri.com,
	gallatin@myri.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-mealy.atl.sa.earthlink.net ([209.86.89.69]:60828 "EHLO
	elasmtp-mealy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751516AbZHNUoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 16:44:14 -0400
In-Reply-To: <20090808015612.GA17710@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 7 Aug 2009, Neil Horman wrote:

> On Fri, Aug 07, 2009 at 08:54:42PM -0400, Bill Fink wrote:
> > On Fri, 7 Aug 2009, Neil Horman wrote:
> > 
> > > You're timing is impeccable!  I just posted a patch for an ftrace module to help
> > > detect just these kind of conditions:
> > > http://marc.info/?l=linux-netdev&m=124967650218846&w=2
> > > 
> > > Hope that helps you out
> > > Neil
> > 
> > Thanks!  It could be helpful.  Do you have a pointer to documentation
> > on how to use it?  And does it require the latest GIT kernel or could
> > it possibly be used with a 2.6.29.6 kernel?
> > 
> > 						-Bill
> 
> It should apply to 2.6.29.6 no problem (might take a little massaging, but not
> much).

It doesn't look like I can apply your patches to my 2.6.29.6 kernel.

For starters, there's no include/trace/events directory, so there's
no include/trace/events/skb.h.  There is an include/trace/skb.h file,
but there's no TRACE_EVENT defined anywhere in the kernel.

I don't suppose it's as simple as defining (from include/linux/tracepoint.h
from Linus's GIT tree):

#define PARAMS(args...) args

#define TRACE_EVENT(name, proto, args, struct, assign, print)   \
	DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))

So do you still think it's reasonable to try applying your patches
to my 2.6.29.6 kernel, or should I get a newer kernel like 2.6.30.4
or 2.6.31-rc6?

						-Thanks

						-Bill



> No docs I'm afraid (sorry, I'm horrible about that)
> 
> Using it is easy though:
> 
> 1) Patch, build and boot the kernel (make sure to have
> CONFIG_SKB_SOURCES_TRACER, along with the other FTRACE requisite options)
> 
> 2) mount -t debugfs nodev /sys/kernel/debug
> 
> 3) cd /sys/kernel/debug/tracing
> 
> 4) echo skb_sources > ./current_tracer
> 
> 5) echo 1 > trace
> 
> 6) cat ./trace
> 
> Step 5 clears the trace buffer.  Step 6 provides you a list list this
> 
> 
> PID	ANID	CNID	RXQ	CCPU	LEN
> 
> 
> Where:
> PID - The process receiving an skb
> ANID - The node which the skb being received was allocated on
> CNID - The node which the process is running when it read this skb
> RQQ - The NIC receive queue that received this skb
> CCPU - The cpu the process was running on when it read the skb in question
> LEN - The length of the skb being received
> 
> Each entry in the list denotes a unique skb (obviously), and with a clever awk
> script you can identify which nodes each process in your system is receiving
> frames from, so that you can use numactl or taskset to bias that process to run
> on the same nodes cpus.
> 
> Note that step (6) wil show a larger list each time you cat that file (as trace
> records aren't removed during a read.  Step 5 is what actually clears the trace
> buffer and resets the list length to zero.
> 
> Hope that helps. Please feel free to email me if you have any questions.
