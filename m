From: Steve Dobbelstein <steved@us.ibm.com>
Subject: Re: Network performance with small packets
Date: Fri, 28 Jan 2011 16:51:59 -0600
Message-ID: <OF410A9B21.0EA0CDB8-ON86257826.007CBE3F-86257826.007D9C47@us.ibm.com>
References: <OFD293DCD2.7F0260F0-ON86257823.0061DC39-86257823.00743BB3@us.ibm.com>	 <20110126151700.GA14113@redhat.com>
	 <1296153874.1640.27.camel@localhost.localdomain>	 <20110127190031.GC5228@redhat.com>
	 <1296155340.1640.34.camel@localhost.localdomain>	 <20110127193131.GD5228@redhat.com>
	 <1296157547.1640.45.camel@localhost.localdomain>	 <20110127200548.GE5228@redhat.com> <1296159305.1640.50.camel@localhost.localdomain> <OF381CCA86.B82857CC-ON86257826.00629F88-86257826.006596F5@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: kvm@vger.kernel.org, kvm-owner@vger.kernel.org,
	mashirle@linux.vnet.ibm.com, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org
To: Steve Dobbelstein <steved@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:47346 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752272Ab1A1WwG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jan 2011 17:52:06 -0500
In-Reply-To: <OF381CCA86.B82857CC-ON86257826.00629F88-86257826.006596F5@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

steved@us.ibm.com wrote on 01/28/2011 12:29:37 PM:

> > On Thu, 2011-01-27 at 22:05 +0200, Michael S. Tsirkin wrote:
> > > One simple theory is that guest net stack became faster
> > > and so the host can't keep up.
> >
> > Yes, that's what I think here. Some qdisc code has been changed
> > recently.
>
> I ran a test with txqueuelen set to 128, instead of the default of 1000,
in
> the guest in an attempt to slow down the guest transmits.  The change had
> no effect on the throughput nor on the CPU usage.
>
> On the other hand, I ran some tests with different CPU pinnings and
> with/without hyperthreading enabled.  Here is a summary of the results.
>
> Pinning configuration 1:  pin the VCPUs and pin the vhost thread to one
of
> the VCPU CPUs
> Pinning configuration 2:  pin the VCPUs and pin the vhost thread to a
> separate CPU on the same socket
> Pinning configuration 3:  pin the VCPUs and pin the vhost thread to a
> separate CPU a different socket
>
> HT   Pinning   Throughput  CPU
> Yes  config 1  - 40%       - 40%
> Yes  config 2  - 37%       - 35%
> Yes  config 3  - 37%       - 36%
> No   none         0%       -  5%
> No   config 1  - 41%       - 43%
> No   config 2  + 32%       -  4%
> No   config 3  + 34%       +  9%
>
> Pinning the vhost thread to the same CPU as a guest VCPU hurts
performance.
> Turning off hyperthreading and pinning the VPUS and vhost thread to
> separate CPUs significantly improves performance, getting it into the
> competitive range with other hypervisors.
>
> Steve D.

Those results for configs 2 and 3 with hyperthreading off are a little
strange.  Digging into the cause I found that my automation script for
pinning the vhost thread failed and pinned it to CPU 1, the same as config
1, giving results similar to config 1.  I reran the tests making sure the
pinning script did the right thing.  The results are more consistent.

HT   Pinning   Throughput  CPU
Yes  config 1  - 40%       - 40%
Yes  config 2  + 33%       -  8%
Yes  config 3  + 34%       +  9%
No   none         0%       -  5%
No   config 1  - 41%       - 43%
No   config 2  + 32%       -  4%
No   config 3  + 34%       +  9%

It appears that we have a scheduling problem.  If the processes are pinned
we can get good performance.

We also se that hyperthreading makes little difference.

Sorry for the initial misleading data.

Steve D.


