From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: RFC: ixgbe+build_skb+extra performance experiments
Date: Fri, 03 Oct 2014 10:49:46 -0700
Message-ID: <542EE1BA.3060300@intel.com>
References: <1412229642-10555-1-git-send-email-ast@plumgrid.com>	<20141002093636.6f482281@redhat.com>	<542EB55B.3000102@gmail.com> <CAMEtUuzoWyvFgDjtVUOCvG-i0zyWU_QELbXA9shT2Y3VKoS1pQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Eric Dumazet <edumazet@google.com>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>,
	Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:12824 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750987AbaJCRts (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 13:49:48 -0400
In-Reply-To: <CAMEtUuzoWyvFgDjtVUOCvG-i0zyWU_QELbXA9shT2Y3VKoS1pQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/03/2014 09:54 AM, Alexei Starovoitov wrote:
> On Fri, Oct 3, 2014 at 7:40 AM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> On 10/02/2014 12:36 AM, Jesper Dangaard Brouer wrote:
>>> On Wed,  1 Oct 2014 23:00:42 -0700 Alexei Starovoitov <ast@plumgrid.com> wrote:
>>>
>>>> I'm trying to speed up single core packet per second.
>>> Great, welcome to the club ;-)
>>
>> Yes, but please keep in mind that multi-core is the more common use case
>> for many systems.
> 
> well, I care about 'single core performance' and not 'single core systems'.
> My primary test machines are 4-core i7 haswell and
> 12-core xeon servers. It's much easier to benchmark, understand,
> speedup performance on a single cpu before turning on packet
> spraying and stressing the whole box.

The point is that there are single core optimization that don't actually
don't scale well when you spread them out to multiple cores due to
design issues resulting in cache-thrash and such.  I was just suggesting
you keep that in mind when making any changes.

>> To that end we may want to look to something like GRO to do the
>> buffering on the Rx side so that we could make use of GRO/GSO to send
>> blocks of buffers instead of one at a time.
> 
> Optimizing gro would be next step. When I turn gro now, it only
> slows things down and muddies perf profile.

I am aware of that.  Optimizing GRO now though might make more sense
since it would allow for a clean optimization.  The problem with using
build_skb on ixgbe is that ixgbe does page-reuse.  If you were to do a
clean setup of build_skb you would likely lose more performance as the
design of page-reuse provided significant gains on ixgbe, especially on
platforms with IOMMU enabled.

>> From my past experience this is very platform dependant.  For example
>> with DDIO or DCA features enabled on a system the memcpy is very cheap
>> since it is already in the cache.  It is one of the reasons for choosing
>> that as a means of working around the fact that we cannot use build_skb
>> and page reuse in the same driver.
> 
> my systems are already intel alphabet soup, including DCA
> and I have CONFIG_IXGBE_DCA=y
> yet, memcpy() is #1 as you can see in profile.

Yes, but that is the kernel option, not the hardware feature.  On Xeon
systems both IOAT and DDIO are available and function.  On i7 those
features are not enabled as I recall.

>> One thought I had at one point was to try and add a flag to the DMA api
>> to indicate if the DMA api is trivial resulting in just a call to
>> virt_to_phys.  It might be worthwhile to look into something like that,
>> then we could split the receive processing into one of two paths, one
>> for non-trivial DMA mapping APIs, and one for trivial DMA mapping APIs
>> such as swiotlb on a device that supports all the memory in the system.
> 
> I have similar hack to optimize swiotlb case, but it's not helpful
> right now. The first step is to use build_skb()

If you really want to use build_skb() you should remove most of the page
reuse code and simply map a page and use sub-sections of it.  The ixgbe
receive path didn't work with build_skb() because of the page reuse, and
before you can push anything that would make use of build_skb() you
would first need to remove all of that code.

>> The problem is build_skb usage comes at a certain cost.  Specifically in
>> the case of small packets it can result in a larger memory footprint
>> since you cannot just reuse the same region in the buffer.  I suspect we
>> may need to look into some sort of compromise between build_skb and a
>> copybreak scheme for best cache performance on Xeon for example.
> 
> we're talking 10Gbps ixgbe use case here.
> For e1000 on small system with precious memory the copybreak
> approach might makes sense, but large server in datacenter
> I would rather configure for build_skb() only.
> In your patch you made a cutoff based on 1500 mtu.
> I would prefer 1550 or 1600 cutoff, so that encapsulated
> packets can get into hypervisor as quickly as possible and
> forwarded to appropriate VMs or containers.

I am talking about cache foot rather than memory.  At 1500 byte packets
the expense for doing a 1 or 2 cache line copy to get the header is
pretty low.  Also if you are talking about virtualization I assume you
must not be talking about co-existing with direct assignment or running
on PowerPC since most drivers that use build_skb will not perform as
well as the page reuse when an IOMMU is enabled on the host.

Also the upper limit would largely be controlled based on the size of
the skb_shared_info.  The actual value for maximum supported buffer
would probably be the shared info size plus the size for any padding
needed at the start of the frame subtracted from 2K.

>> For the burst size logic you might want to explore handling the
>> descriptors in 4 descriptor aligned chunks that should give you the best
>> possible performance since that would mean processing the descriptor
>> ring one cache-line at a time.
> 
> makes sense. I was thinking to pipeline it more in the future.
> Including splitting build_skb() into phases of allocation and initialization,
> so that prefetch from previous stage will have time to populate caches.
> 
> I was hoping my performance measurements were convincing
> enough for you to dust off ixgbe+build_skb patch, fix page reuse
> somehow and submit it for everyone to cheer :)

The problem is market segment focus.  Your are running ixgbe on
enthusiast grade hardware.  When you get it up onto the big Xeon or even
PowerPC systems the performance layout is quite different due to the
introduction of other features, and the focus is on these units as this
is what you find in most big data centers.

The i7 focused approach can be very narrow.  When I rewrote most of the
receive path for ixgbe I had to take into account multiple use cases
included multiple architectures and system setups including multiple
NUMA nodes, IOMMU, PowerPC, Atom, Xeon, and other factors.  The current
driver is a compromise in order to get the best performance across all
platforms without sacrificing too much on any one of them.

If anything I think you might need to start first with looking at the
DMA APIs out there and seeing if there is a way to sort out trivial and
non-trivial DMA APIs.  So for the cases that are using a simple
virt_to_phys such as x86 we might be able to get away with just using
build_skb and could probably set a flag indicating as such so that we
ran that path.  For the other DMA APIs out there however we would
probably need to just use standard page reuse in order to avoid
overwriting the page data on a shared page.

Thanks,

Alex
