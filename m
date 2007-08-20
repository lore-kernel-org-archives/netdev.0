From: "Felix Marti" <felix@chelsio.com>
Subject: RE: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCPportsfrom the host TCP port space.
Date: Sun, 19 Aug 2007 18:41:40 -0700
Message-ID: <8A71B368A89016469F72CD08050AD334018E20C1@maui.asicdesigners.com>
References: <8A71B368A89016469F72CD08050AD334018E20BC@maui.asicdesigners.com><20070819.174017.77241227.davem@davemloft.net><8A71B368A89016469F72CD08050AD334018E20BE@maui.asicdesigners.com> <20070819.180540.74750322.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <sean.hefty@intel.com>, <netdev@vger.kernel.org>,
	<rdreier@cisco.com>, <general@lists.openfabrics.org>,
	<linux-kernel@vger.kernel.org>, <jeff@garzik.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:31961 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811AbXHTBna convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Aug 2007 21:43:30 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Sunday, August 19, 2007 6:06 PM
> To: Felix Marti
> Cc: sean.hefty@intel.com; netdev@vger.kernel.org; rdreier@cisco.com;
> general@lists.openfabrics.org; linux-kernel@vger.kernel.org;
> jeff@garzik.org
> Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate
> PS_TCPportsfrom the host TCP port space.
> 
> From: "Felix Marti" <felix@chelsio.com>
> Date: Sun, 19 Aug 2007 17:47:59 -0700
> 
> > [Felix Marti]
> 
> Please stop using this to start your replies, thank you.
Better?

> 
> > David and Herbert, so you agree that the user<>kernel
> > space memory copy overhead is a significant overhead and we want to
> > enable zero-copy in both the receive and transmit path? - Yes, copy
> > avoidance is mainly an API issue and unfortunately the so widely
used
> > (synchronous) sockets API doesn't make copy avoidance easy, which is
> one
> > area where protocol offload can help. Yes, some apps can resort to
> > sendfile() but there are many apps which seem to have trouble
> switching
> > to that API... and what about the receive path?
> 
> On the send side none of this is an issue.  You either are sending
> static content, in which using sendfile() is trivial, or you're
> generating data dynamically in which case the data copy is in the
> noise or too small to do zerocopy on and if not you can use a shared
> mmap to generate your data into, and then sendfile out from that file,
> to avoid the copy that way.
> 
> splice() helps a lot too.
> 
> Splice has the capability to do away with the receive side too, and
> there are a few receivefile() implementations that could get cleaned
> up and merged in.
I don't believe it is as simple as that. Many apps synthesize their
payload in user space buffers (i.e. malloced memory) and expect to
receive their data in user space buffers _and_ expect the received data
to have a certain alignment and to be contiguous - something not
addressed by these 'new' APIs. Look, people writing HPC apps tend to
take advantage of whatever they can to squeeze some extra performance
out of their apps and they are resorting to protocol offload technology
for a reason, wouldn't you agree? 

> 
> Also, the I/O bus is still the more limiting factor and main memory
> bandwidth in all of this, it is the smallest data pipe for
> communications out to and from the network.  So the protocol header
> avoidance gains of TSO and LRO are still a very worthwhile savings.
So, i.e. with TSO, your saving about 16 headers (let us say 14 + 20 +
20), 864B, when moving ~64KB of payload - looks like very much in the
noise to me. And again, PCI-E provides more bandwidth than the wire...

> 
> But even if RDMA increases performance 100 fold, it still doesn't
> avoid the issue that it doesn't fit in with the rest of the networking
> stack and feature set.
> 
> Any monkey can change the rules around ("ok I can make it go fast as
> long as you don't need firewalling, packet scheduling, classification,
> and you only need to talk to specific systems that speak this same
> special protocol") to make things go faster.  On the other hand well
> designed solutions can give performance gains within the constraints
> of the full system design and without sactificing functionality.
While I believe that you should give people an option to get 'high
performance' _instead_ of other features and let them chose whatever
they care about, I really do agree with what you're saying and believe
that offload devices _should_ be integrated with the facilities that you
mention (in fact, offload can do a much better job at lots of things
that you mention ;) ... but you're not letting offload devices integrate
and you're slowing down innovation in this field.

