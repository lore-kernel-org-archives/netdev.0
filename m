From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: Performance regression on kernels 3.10 and newer
Date: Thu, 14 Aug 2014 16:16:36 -0700
Message-ID: <53ED4354.9090904@intel.com>
References: <53ECFDAB.5010701@intel.com> <1408041962.6804.31.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:59019 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932180AbaHNXRC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2014 19:17:02 -0400
In-Reply-To: <1408041962.6804.31.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/14/2014 11:46 AM, Eric Dumazet wrote:
> In real life, applications do not use prequeue, because nobody wants one
> thread per flow.

I still say this is just an argument to remove it.  It looks like you
submitted a patch to allow stripping it from the build about 7 years go.
 I assume it was rejected.

> Each socket has its own dst now route cache was removed, but if your
> netperf migrates cpu (and NUMA node), we do not detect the dst should be
> re-created onto a different NUMA node.

Are you sure about each socket having it's own DST?  Everything I see
seems to indicate it is somehow associated with IP.  For example I can
actually work around the issue by setting up a second subnet on the same
port and then running the tests with each subnet affinitized to a
specific node.

>From what I can tell the issue is that the patch made it so tcp_prequeue
forces the skb to take a reference on the dst via an atomic increment.
It is later freed with an atomic decrement when the skb is freed.  I
believe these two transactions are the source of my cacheline bouncing,
though I am still not sure where the ipv4_dst_check is coming into play
in all this since it shows up as the top item in perf but should be in a
separate cacheline entirely.  Perhaps it is the result of some sort of
false sharing.

Since my test was back to back with only one IP on each end it used the
same DST for all of the queues/CPUs (or at least that is what I am
ass-u-me-ing).  So as a result 1 NUMA node looks okay as things only get
evicted out to LLC for the locked transaction, when you go to 2 sockets
it completely evicts it from LLC and things get very ugly.

I don't believe that his will scale on SMP setups.  If I am missing
something obvious please let me know, but being over 10x worse in terms
of throughput based on CPU utilization is enough to make me just want to
scrap it.  I'm open to any suggestions on where having this enabled
might give us gains.  I have tried testing with a single thread setup
and it still was hurting performance to have things going through
prequeue.  I figure if I cannot find a benefit for it maybe I should
just submit a patch to strip it and the tcp_low_latency sysctl out.

Thanks,

Alex
