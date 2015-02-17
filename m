From: Paolo Bonzini <pbonzini@redhat.com>
Subject: Re: [PATCH] vhost: support upto 509 memory regions
Date: Tue, 17 Feb 2015 14:11:37 +0100
Message-ID: <54E33E09.5090603@redhat.com>
References: <1423842599-5174-1-git-send-email-imammedo@redhat.com> <20150217090242.GA20254@redhat.com> <54E31F24.1060705@redhat.com> <20150217123212.GA6362@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: Igor Mammedov <imammedo@redhat.com>, linux-kernel@vger.kernel.org,
	kvm@vger.kernel.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150217123212.GA6362@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 17/02/2015 13:32, Michael S. Tsirkin wrote:
> On Tue, Feb 17, 2015 at 11:59:48AM +0100, Paolo Bonzini wrote:
>>
>>
>> On 17/02/2015 10:02, Michael S. Tsirkin wrote:
>>>> Increasing VHOST_MEMORY_MAX_NREGIONS from 65 to 509
>>>> to match KVM_USER_MEM_SLOTS fixes issue for vhost-net.
>>>>
>>>> Signed-off-by: Igor Mammedov <imammedo@redhat.com>
>>>
>>> This scares me a bit: each region is 32byte, we are talking
>>> a 16K allocation that userspace can trigger.
>>
>> What's bad with a 16K allocation?
> 
> It fails when memory is fragmented.

If memory is _that_ fragmented I think you have much bigger problems
than vhost.

> I'm guessing kvm doesn't do memory scans on data path, vhost does.

It does for MMIO memory-to-memory writes, but that's not a particularly
fast path.

KVM doesn't access the memory map on fast paths, but QEMU does, so I
don't think it's beyond the expectations of the kernel.  For example you
can use a radix tree (not lib/radix-tree.c unfortunately), and cache
GVA->HPA translations if it turns out that lookup has become a hot path.

The addressing space of x86 is in practice 44 bits or fewer, and each
slot will typically be at least 1 GiB, so you only have 14 bits to
dispatch on.   It's probably possible to only have two or three levels
in the radix tree in the common case, and beat the linear scan real quick.

The radix tree can be tuned to use order-0 allocations, and then your
worries about fragmentation go away too.

Paolo
