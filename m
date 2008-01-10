From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: e1000 performance issue in 4 simultaneous links
Date: Thu, 10 Jan 2008 12:52:15 -0800
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F5204275B04@orsmsx418.amr.corp.intel.com>
References: <1199981839.8931.35.camel@cafe>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: "Breno Leitao" <leitao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:51497 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752558AbYAJVM1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 16:12:27 -0500
Content-class: urn:content-classes:message
In-Reply-To: <1199981839.8931.35.camel@cafe>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Breno Leitao wrote:
> When I run netperf in just one interface, I get 940.95 * 10^6 bits/sec
> of transfer rate. If I run 4 netperf against 4 different interfaces, I
> get around 720 * 10^6 bits/sec.

This is actually a known issue that we have worked with your company
before on.  It comes down to your system's default behavior of round
robining interrupts (see cat /proc/interrupts while running the test)
combined with e1000's way of exiting / rescheduling NAPI.

The default round robin behavior of the interrupts on your system is the
root cause of this issue, and here is what happens:

4 interfaces start generating interrupts, if you're lucky the round
robin balancer has them all on different cpus.
As the e1000 driver goes into and out of polling mode, the round robin
balancer keeps moving the interrupt to the next cpu.
Eventually 2 or more driver instances end up on the same CPU, which
causes both driver instances to stay in NAPI polling mode, due to the
amount of work being done, and that there are always more than
"netdev->weight" packets to do for each instance.  This keeps *hardware*
interrupts for each interface *disabled*.
Staying in NAPI polling mode causes higher cpu utilization on that one
processor, which guarantees that when the hardware round robin balancer
moves any other network interrupt onto that CPU, it too will join the
NAPI polling mode chain.
So no matter how many processors you have, with this round robin style
of hardware interrupts, it guarantees you that if there is a lot of work
to do (more than weight) at each softirq, then, all network interfaces
will end up on the same cpu eventually (the busiest one)
Your performance becomes the same as if you had booted with maxcpus=1

I hope this explanation makes sense, but what it comes down to is that
combining hardware round robin balancing with NAPI is a BAD IDEA.  In
general the behavior of hardware round robin balancing is bad and I'm
sure it is causing all sorts of other performance issues that you may
not even be aware of.

I'm sure your problem will go away if you run e1000 in interrupt mode.
(use make CFLAGS_EXTRA=-DE1000_NO_NAPI)
 
> If I run the same test against 2 interfaces I get a 940 * 10^6
> bits/sec transfer rate also, and if I run it against 3 interfaces I
> get around 850 * 10^6 bits/sec performance.
> 
> I got this results using the upstream netdev-2.6 branch kernel plus
> David Miller's 7 NAPI patches set[1]. In the kernel 2.6.23.12 the
> result is a bit worse, and the the transfer rate was around 600 * 10^6
> bits/sec.

Thank you for testing the latest kernel.org kernel.

Hope this helps.
