From: Igor Mammedov <imammedo@redhat.com>
Subject: Re: [PATCH] vhost: support upto 509 memory regions
Date: Tue, 17 Feb 2015 16:02:40 +0100
Message-ID: <20150217160240.1085e2f7@nial.brq.redhat.com>
References: <1423842599-5174-1-git-send-email-imammedo@redhat.com>
	<20150217090242.GA20254@redhat.com>
	<54E31F24.1060705@redhat.com>
	<20150217123212.GA6362@redhat.com>
	<54E33E09.5090603@redhat.com>
	<20150217132931.GB6362@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Paolo Bonzini <pbonzini@redhat.com>, linux-kernel@vger.kernel.org,
	kvm@vger.kernel.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150217132931.GB6362@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 17 Feb 2015 14:29:31 +0100
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> On Tue, Feb 17, 2015 at 02:11:37PM +0100, Paolo Bonzini wrote:
> > 
> > 
> > On 17/02/2015 13:32, Michael S. Tsirkin wrote:
> > > On Tue, Feb 17, 2015 at 11:59:48AM +0100, Paolo Bonzini wrote:
> > >>
> > >>
> > >> On 17/02/2015 10:02, Michael S. Tsirkin wrote:
> > >>>> Increasing VHOST_MEMORY_MAX_NREGIONS from 65 to 509
> > >>>> to match KVM_USER_MEM_SLOTS fixes issue for vhost-net.
> > >>>>
> > >>>> Signed-off-by: Igor Mammedov <imammedo@redhat.com>
> > >>>
> > >>> This scares me a bit: each region is 32byte, we are talking
> > >>> a 16K allocation that userspace can trigger.
> > >>
> > >> What's bad with a 16K allocation?
> > > 
> > > It fails when memory is fragmented.
> > 
> > If memory is _that_ fragmented I think you have much bigger problems
> > than vhost.
> > 
> > > I'm guessing kvm doesn't do memory scans on data path, vhost does.
> > 
> > It does for MMIO memory-to-memory writes, but that's not a particularly
> > fast path.
> > 
> > KVM doesn't access the memory map on fast paths, but QEMU does, so I
> > don't think it's beyond the expectations of the kernel.
> 
> QEMU has an elaborate data structure to deal with that.
> 
> >  For example you
> > can use a radix tree (not lib/radix-tree.c unfortunately), and cache
> > GVA->HPA translations if it turns out that lookup has become a hot path.
> 
> All vhost lookups are hot path.
> 
> > The addressing space of x86 is in practice 44 bits or fewer, and each
> > slot will typically be at least 1 GiB, so you only have 14 bits to
> > dispatch on.   It's probably possible to only have two or three levels
> > in the radix tree in the common case, and beat the linear scan real quick.
> 
> Not if there are about 6 regions, I think.
When memslots where increased to 509 and look up of them was replaced on
binary search results were on par with linear search for a default 13 memslots VM.

Adding LRU cache helped to shave ~40% of cycles for sequential lookup workloads.

> 
> > The radix tree can be tuned to use order-0 allocations, and then your
> > worries about fragmentation go away too.
> > 
> > Paolo
> 
> Increasing the number might be reasonable for workloads such as nested
> virt. But depending on this in userspace when you don't have to is not a
> good idea IMHO.
> 
> 
