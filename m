From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: RFC: ixgbe+build_skb+extra performance experiments
Date: Fri, 3 Oct 2014 09:54:41 -0700
Message-ID: <CAMEtUuzoWyvFgDjtVUOCvG-i0zyWU_QELbXA9shT2Y3VKoS1pQ@mail.gmail.com>
References: <1412229642-10555-1-git-send-email-ast@plumgrid.com>
	<20141002093636.6f482281@redhat.com>
	<542EB55B.3000102@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Eric Dumazet <edumazet@google.com>,
	Network Development <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:52510 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753828AbaJCQym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 12:54:42 -0400
Received: by mail-wi0-f175.google.com with SMTP id d1so7807147wiv.14
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 09:54:41 -0700 (PDT)
In-Reply-To: <542EB55B.3000102@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 3, 2014 at 7:40 AM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On 10/02/2014 12:36 AM, Jesper Dangaard Brouer wrote:
>> On Wed,  1 Oct 2014 23:00:42 -0700 Alexei Starovoitov <ast@plumgrid.com> wrote:
>>
>>> I'm trying to speed up single core packet per second.
>> Great, welcome to the club ;-)
>
> Yes, but please keep in mind that multi-core is the more common use case
> for many systems.

well, I care about 'single core performance' and not 'single core systems'.
My primary test machines are 4-core i7 haswell and
12-core xeon servers. It's much easier to benchmark, understand,
speedup performance on a single cpu before turning on packet
spraying and stressing the whole box.

> To that end we may want to look to something like GRO to do the
> buffering on the Rx side so that we could make use of GRO/GSO to send
> blocks of buffers instead of one at a time.

Optimizing gro would be next step. When I turn gro now, it only
slows things down and muddies perf profile.

> From my past experience this is very platform dependant.  For example
> with DDIO or DCA features enabled on a system the memcpy is very cheap
> since it is already in the cache.  It is one of the reasons for choosing
> that as a means of working around the fact that we cannot use build_skb
> and page reuse in the same driver.

my systems are already intel alphabet soup, including DCA
and I have CONFIG_IXGBE_DCA=y
yet, memcpy() is #1 as you can see in profile.

> One thought I had at one point was to try and add a flag to the DMA api
> to indicate if the DMA api is trivial resulting in just a call to
> virt_to_phys.  It might be worthwhile to look into something like that,
> then we could split the receive processing into one of two paths, one
> for non-trivial DMA mapping APIs, and one for trivial DMA mapping APIs
> such as swiotlb on a device that supports all the memory in the system.

I have similar hack to optimize swiotlb case, but it's not helpful
right now. The first step is to use build_skb()

> The problem is build_skb usage comes at a certain cost.  Specifically in
> the case of small packets it can result in a larger memory footprint
> since you cannot just reuse the same region in the buffer.  I suspect we
> may need to look into some sort of compromise between build_skb and a
> copybreak scheme for best cache performance on Xeon for example.

we're talking 10Gbps ixgbe use case here.
For e1000 on small system with precious memory the copybreak
approach might makes sense, but large server in datacenter
I would rather configure for build_skb() only.
In your patch you made a cutoff based on 1500 mtu.
I would prefer 1550 or 1600 cutoff, so that encapsulated
packets can get into hypervisor as quickly as possible and
forwarded to appropriate VMs or containers.

> For the burst size logic you might want to explore handling the
> descriptors in 4 descriptor aligned chunks that should give you the best
> possible performance since that would mean processing the descriptor
> ring one cache-line at a time.

makes sense. I was thinking to pipeline it more in the future.
Including splitting build_skb() into phases of allocation and initialization,
so that prefetch from previous stage will have time to populate caches.

I was hoping my performance measurements were convincing
enough for you to dust off ixgbe+build_skb patch, fix page reuse
somehow and submit it for everyone to cheer :)
