From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: Performance regression on kernels 3.10 and newer
Date: Fri, 15 Aug 2014 10:15:15 -0700
Message-ID: <53EE4023.6080902@intel.com>
References: <53ECFDAB.5010701@intel.com>	<1408041962.6804.31.camel@edumazet-glaptop2.roam.corp.google.com>	<53ED4354.9090904@intel.com> <20140814.162024.2218312002979492106.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:45668 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751027AbaHORPc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Aug 2014 13:15:32 -0400
In-Reply-To: <20140814.162024.2218312002979492106.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/14/2014 04:20 PM, David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> Date: Thu, 14 Aug 2014 16:16:36 -0700
> 
>> Are you sure about each socket having it's own DST?  Everything I see
>> seems to indicate it is somehow associated with IP.
> 
> Right it should be, unless you have exception entries created by path
> MTU or redirects.
> 
> WRT prequeue, it does the right thing for dumb apps that block in
> receive.  But because it causes the packet to cross domains as it
> does, we can't do a lot of tricks which we normally can do, and that's
> why the refcounting on the dst is there now.
> 
> Perhaps we can find a clever way to elide that refcount, who knows.

Actually I would consider the refcount issue just the coffin nail in all
of this.  It seems like there are multiple issues that have been there
for some time and they are just getting worse with the refcount change
in 3.10.

With the prequeue disabled what happens is that the frames are making it
up and hitting tcp_rcv_established before being pushed into the backlog
queues and coalesced there.  I believe the lack of coalescing on the
prequeue path is one of the reasons why it is twice as expensive as the
non-prequeue path CPU wise even if you eliminate the refcount issue.

I realize most of my data is anecdotal as I only have the ixgbe/igb
adapters and netperf to work with.  This is one of the reasons why I
keep asking if someone can tell me what the use case is for this where
it performs well.  From what I can tell it might have had some value
back in the day before the introduction of things such as RPS/RFS where
some of the socket processing would be offloaded to other CPUs for a
single queue device, but even that use case is now deprecated since
RPS/RFS are there and function better than this.  What I am basically
looking for is a way to weight the gain versus the penalties to
determine if this code is even viable anymore.

In the meantime I think I will put together a patch to default
tcp_low_latency to 1 for net and stable, and if we cannot find a good
reason for keeping it then I can submit a patch to net-next that will
strip it out since I don't see any benefit to having this code.

Thanks,

Alex
