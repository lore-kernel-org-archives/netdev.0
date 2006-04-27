From: "Chris Leech" <christopher.leech@intel.com>
Subject: Re: [PATCH 0/10] [IOAT] I/OAT patches repost
Date: Thu, 27 Apr 2006 16:45:14 -0700
Message-ID: <41b516cb0604271645l6209a381wf0f40a63bbce1915@mail.gmail.com>
References: <20060420213305.GK26746@pb15.lixom.net>
	 <20060420.172742.132879746.davem@davemloft.net>
	 <20060421030426.GM26746@pb15.lixom.net>
	 <20060420.204200.103377406.davem@davemloft.net>
Reply-To: chris.leech@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: olof@lixom.net, andrew.grover@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pproxy.gmail.com ([64.233.166.181]:14472 "EHLO pproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751750AbWD0XpP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Apr 2006 19:45:15 -0400
Received: by pproxy.gmail.com with SMTP id i49so2236005pye
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 16:45:14 -0700 (PDT)
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060420.204200.103377406.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/20/06, David S. Miller <davem@davemloft.net> wrote:
> Yes, and it means that the memory bandwidth costs are equivalent
> between I/O AT and cpu copy.

The following is a response from the I/OAT architects.  I only point
out that this is not coming directly from me because I have not seen
the data to verify the claims regarding the speed of a copy vs a load
and the cost of the rep mov instruction.  I'll encourage more direct
participation in this discussion from the architects moving forward.

    - Chris

Let's talk about the caching benefits that is seemingly lost when
using the DMA engine. The intent of the DMA engine is to save CPU
cycles spent in copying data (rep mov). In cases where the destination
is already warm in cache (due to destination buffer re-use) and the
source is in memory, the cycles spent in a host copy is not just due
to the cache misses it encounters in the process of bringing in the
source but also due to the execution of rep move itself within the
host core. If you contrast this to simply touching (loading) the data
residing in memory, the cost of this load is primarily the cost of the
cache misses and not so much CPU execution time. Given this, some of
the following points are noteworthy:

1. While the DMA engine forces the destination to be in memory and
touching it may cause the same number of observable cache misses as a
host copy assuming a cache warmed destination, the cost of the host
copy (in terms of CPU cycles) is much more than the cost of the touch.

2. CPU hardware prefetchers do a pretty good job of staying ahead of
the fetch stream to minimize cache misses. So for loads of medium to
large buffers, cache misses form a much smaller component of the data
fetch time=85most of it is dominated by front side bus (FSB) or Memory
bandwidth. For small buffers, we do not use the DMA engine but if we
had to, we would insert SW prefetches that do reasonably well.

3. If the destination wasn't already warm in cache i.e., it was in
memory or some CPU other cache, host copy will have to snoop and bring
the destination in and will encounter additional misses on the
destination buffer as well. These misses are the same as those
encountered in #1 above when using the DMA engine and touching the
data afterwards. So in effect it becomes a wash when compared to the
DMA engine's behavior. The case where the destination is already warm
in cache is common in benchmarks such as iperf, ttcp etc. where the
same buffer is reused over and over again. Real applications typically
will not exhibit this aggressive buffer re-use behavior.

4. It may take a large number of packets (and several interrupts) to
satisfy a large posted buffer (say 64KB). Even if you use host copy to
warm the cache with the destination, there is no guarantee that some
or all of the destination will stay in the cache before the
application has a chance to read the data.

5. The source data payload (skb ->data) is typically needed only once
for the copy and has no use later. The host copy brings it into the
cache and may end up polluting the cache, and consuming FSB bandwidth
whereas the DMA engine avoids this altogether.

The IxChariot data posted earlier that touches the data and yet shows
I/OAT benefit is due to some of the reasons above. Bottom line is that
I agree with the cache benefit argument of host copy for small buffers
(64B to 512B) but for larger buffers and certain application scenarios
(destination in memory), the DMA engine will show better performance
regardless of where the destination buffer resided to begin with and
where it is accessed from.
