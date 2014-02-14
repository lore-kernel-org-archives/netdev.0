From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH V2 net-next 0/5] xen-net{back,front}: Multiple transmit
 and receive queues
Date: Fri, 14 Feb 2014 15:25:39 +0000
Message-ID: <20140214152539.GD18398@zion.uk.xensource.com>
References: <1392378624-6123-1-git-send-email-andrew.bennieston@citrix.com>
 <20140214140635.GA18398@zion.uk.xensource.com>
 <52FE2DFC.8050702@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<ian.campbell@citrix.com>, <paul.durrant@citrix.com>,
	<netdev@vger.kernel.org>
To: Andrew Bennieston <andrew.bennieston@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:31270 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751825AbaBNP0R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 10:26:17 -0500
Content-Disposition: inline
In-Reply-To: <52FE2DFC.8050702@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 14, 2014 at 02:53:48PM +0000, Andrew Bennieston wrote:
> On 14/02/14 14:06, Wei Liu wrote:
> >On Fri, Feb 14, 2014 at 11:50:19AM +0000, Andrew J. Bennieston wrote:
> >>
> >>This patch series implements multiple transmit and receive queues (i.e.
> >>multiple shared rings) for the xen virtual network interfaces.
> >>
> >>The series is split up as follows:
> >>  - Patches 1 and 3 factor out the queue-specific data for netback and
> >>     netfront respectively, and modify the rest of the code to use these
> >>     as appropriate.
> >>  - Patches 2 and 4 introduce new XenStore keys to negotiate and use
> >>    multiple shared rings and event channels, and code to connect these
> >>    as appropriate.
> >>  - Patch 5 documents the XenStore keys required for the new feature
> >>    in include/xen/interface/io/netif.h
> >>
> >>All other transmit and receive processing remains unchanged, i.e. there
> >>is a kthread per queue and a NAPI context per queue.
> >>
> >>The performance of these patches has been analysed in detail, with
> >>results available at:
> >>
> >>http://wiki.xenproject.org/wiki/Xen-netback_and_xen-netfront_multi-queue_performance_testing
> >>
> >>To summarise:
> >>   * Using multiple queues allows a VM to transmit at line rate on a 10
> >>     Gbit/s NIC, compared with a maximum aggregate throughput of 6 Gbit/s
> >>     with a single queue.
> >>   * For intra-host VM--VM traffic, eight queues provide 171% of the
> >>     throughput of a single queue; almost 12 Gbit/s instead of 6 Gbit/s.
> >>   * There is a corresponding increase in total CPU usage, i.e. this is a
> >>     scaling out over available resources, not an efficiency improvement.
> >>   * Results depend on the availability of sufficient CPUs, as well as the
> >>     distribution of interrupts and the distribution of TCP streams across
> >>     the queues.
> >>
> >>Queue selection is currently achieved via an L4 hash on the packet (i.e.
> >>TCP src/dst port, IP src/dst address) and is not negotiated between the
> >>frontend and backend, since only one option exists. Future patches to
> >>support other frontends (particularly Windows) will need to add some
> >>capability to negotiate not only the hash algorithm selection, but also
> >>allow the frontend to specify some parameters to this.
> >>
> >
> >This has an impact on the protocol. If the key to select hash algorithm
> >is missing then we're assuming L4 is in use.
> >
> >This either needs to be documented (which is missing in your patch to
> >netif.h) or you need to write that key explicitly in XenStore.
> >

a)

> >I also have a question what would happen if one end advertises one hash
> >algorithm then use a different one. This can happen when the
> >driver is rogue or buggy. Will it cause the "good guy" to stall? We
> >certainly don't want to stall backend, at the very least.
> 

b)

> I'm not sure I understand. There is no negotiable selection of hash
> algorithm here. This paragraph refers to a possible future in which
> we may have to support multiple such. These issues will absolutely
> have to be addressed then, but it is completely irrelevant for now.
> 

There's actaully two questions.

I suspect your above reply was for a). My starting point of a) is, if
I'm to write a driver, either backend or frontend, for any random OS,
will I be able to have some basic idea what the correct behavior is by
looking at netif.h only? The current answer for multiqueue hash
algorithm selection is "no" given that 1) the document is not clear L4
is the default algorithm if no key is specified, 2) the key to select
algorithm is not mandatory the the current protocol.

I was not very clear in previous reply, especially the "write that key
explicitly in XenStore", sorry. The thing you need to do would be:
1) document L4 will be selected if algorithm selection is missing, or
2) document algorithm key is mandatory and implement negotiation.

For question b). Say, if I'm writing a malicious frontend driver, I
advertise I want L4 but actually I always select a particular queue, or
deliberately select random queue, will that cause problem to the
backend? If we are to use a more complex algorithm, will a rogue
frontend cause problem to backend?

Wei.

> Andrew.
> >
> >I don't see relevant code in this series to handle "rogue other end". I
> >presume for a simple hash algorithm like L4 is not very important (say,
> >even a packet ends up in the wrong queue we can still safely process
> >it), or core driver can deal with this all by itself (dropping)?
> >
> >Wei.
> >
