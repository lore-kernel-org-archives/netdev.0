From: Paolo Bonzini <pbonzini@redhat.com>
Subject: Re: [PATCH] vhost: support upto 509 memory regions
Date: Tue, 17 Feb 2015 15:11:13 +0100
Message-ID: <54E34C01.5060304@redhat.com>
References: <1423842599-5174-1-git-send-email-imammedo@redhat.com> <20150217090242.GA20254@redhat.com> <54E31F24.1060705@redhat.com> <20150217123212.GA6362@redhat.com> <54E33E09.5090603@redhat.com> <20150217132931.GB6362@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: Igor Mammedov <imammedo@redhat.com>, linux-kernel@vger.kernel.org,
	kvm@vger.kernel.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20150217132931.GB6362@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 17/02/2015 14:29, Michael S. Tsirkin wrote:
> On Tue, Feb 17, 2015 at 02:11:37PM +0100, Paolo Bonzini wrote:
>>
>>
>> On 17/02/2015 13:32, Michael S. Tsirkin wrote:
>>> On Tue, Feb 17, 2015 at 11:59:48AM +0100, Paolo Bonzini wrote:
>>>>
>>>>
>>>> On 17/02/2015 10:02, Michael S. Tsirkin wrote:
>>>>>> Increasing VHOST_MEMORY_MAX_NREGIONS from 65 to 509
>>>>>> to match KVM_USER_MEM_SLOTS fixes issue for vhost-net.
>>>>>>
>>>>>> Signed-off-by: Igor Mammedov <imammedo@redhat.com>
>>>>>
>>>>> This scares me a bit: each region is 32byte, we are talking
>>>>> a 16K allocation that userspace can trigger.
>>>>
>>>> What's bad with a 16K allocation?
>>>
>>> It fails when memory is fragmented.
>>
>> If memory is _that_ fragmented I think you have much bigger problems
>> than vhost.
>>
>>> I'm guessing kvm doesn't do memory scans on data path, vhost does.
>>
>> It does for MMIO memory-to-memory writes, but that's not a particularly
>> fast path.
>>
>> KVM doesn't access the memory map on fast paths, but QEMU does, so I
>> don't think it's beyond the expectations of the kernel.
> 
> QEMU has an elaborate data structure to deal with that.

It's not elaborate, it's just a radix tree.  The complicated part is
building the flat view and computing what changed in the memory map, but
none of this would have to be done in vhost.  vhost gets the flat memory
map in VHOST_SET_MEM_TABLE.

A lookup is basically:

#define LOG_TRIE_WIDTH      (PAGE_SHIFT - LOG_BITS_PER_LONG)

unsigned long node_val = (unsigned long) trie_root;
/* log of highest valid address in the memory map */
if (addr & (-1U << vhost_address_space_bits))
	return NULL;

addr <<= 64 - vhost_address_space_bits;
do {
	struct memmap_trie_node *node;
	unsigned i = addr >> (64 - LOG_TRIE_WIDTH);
	addr = addr << LOG_TRIE_WIDTH;
	node = (struct memmap_trie_node *) (node_val - 1);
	node_val = (unsigned long) node[i];
} while (node_val & 1);
return (struct vhost_mem_slot *)node_val;

bit 0: 0 if leaf

if leaf:
	bits 1-63: pointer to mem table entry
if not leaf:
	bits 1-63: pointer to next level

>>  For example you
>> can use a radix tree (not lib/radix-tree.c unfortunately), and cache
>> GVA->HPA translations if it turns out that lookup has become a hot path.
> 
> All vhost lookups are hot path.

What % is lookup vs the networking stuff?  Also, adding a simple MRU
cache might make lookups less prominent in the profile.

>> The addressing space of x86 is in practice 44 bits or fewer, and each
>> slot will typically be at least 1 GiB, so you only have 14 bits to
>> dispatch on.   It's probably possible to only have two or three levels
>> in the radix tree in the common case, and beat the linear scan real quick.
> 
> Not if there are about 6 regions, I think.

It depends on many factors including branch prediction, MRU cache hits, etc.

> Increasing the number might be reasonable for workloads such as nested
> virt.

Why does nested virt matter?

Paolo
