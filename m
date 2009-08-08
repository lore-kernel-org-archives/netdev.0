From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Fri, 7 Aug 2009 21:56:12 -0400
Message-ID: <20090808015612.GA17710@localhost.localdomain>
References: <20090807170600.9a2eff2e.billfink@mindspring.com> <20090807221211.GA16874@localhost.localdomain> <20090807205442.32918186.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Network Developers <netdev@vger.kernel.org>, brice@myri.com,
	gallatin@myri.com
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59661 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754694AbZHHB4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 21:56:16 -0400
Content-Disposition: inline
In-Reply-To: <20090807205442.32918186.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 07, 2009 at 08:54:42PM -0400, Bill Fink wrote:
> On Fri, 7 Aug 2009, Neil Horman wrote:
> 
> > You're timing is impeccable!  I just posted a patch for an ftrace module to help
> > detect just these kind of conditions:
> > http://marc.info/?l=linux-netdev&m=124967650218846&w=2
> > 
> > Hope that helps you out
> > Neil
> 
> Thanks!  It could be helpful.  Do you have a pointer to documentation
> on how to use it?  And does it require the latest GIT kernel or could
> it possibly be used with a 2.6.29.6 kernel?
> 
> 						-Bill
> 

It should apply to 2.6.29.6 no problem (might take a little massaging, but not
much).

No docs I'm afraid (sorry, I'm horrible about that)

Using it is easy though:

1) Patch, build and boot the kernel (make sure to have
CONFIG_SKB_SOURCES_TRACER, along with the other FTRACE requisite options)

2) mount -t debugfs nodev /sys/kernel/debug

3) cd /sys/kernel/debug/tracing

4) echo skb_sources > ./current_tracer

5) echo 1 > trace

6) cat ./trace

Step 5 clears the trace buffer.  Step 6 provides you a list list this


PID	ANID	CNID	RXQ	CCPU	LEN


Where:
PID - The process receiving an skb
ANID - The node which the skb being received was allocated on
CNID - The node which the process is running when it read this skb
RQQ - The NIC receive queue that received this skb
CCPU - The cpu the process was running on when it read the skb in question
LEN - The length of the skb being received

Each entry in the list denotes a unique skb (obviously), and with a clever awk
script you can identify which nodes each process in your system is receiving
frames from, so that you can use numactl or taskset to bias that process to run
on the same nodes cpus.

Note that step (6) wil show a larger list each time you cat that file (as trace
records aren't removed during a read.  Step 5 is what actually clears the trace
buffer and resets the list length to zero.

Hope that helps. Please feel free to email me if you have any questions.

Regards
Neil

