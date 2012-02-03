From: Roopa Prabhu <roprabhu@cisco.com>
Subject: Re: [net-next-2.6 PATCH 0/6 v4] macvlan: MAC Address filtering
 support for passthru mode
Date: Fri, 03 Feb 2012 07:32:00 -0800
Message-ID: <CB513DF0.435BE%roprabhu@cisco.com>
References: <4F2ADCD4.4080205@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>,
	<chrisw@redhat.com>, <sri@us.ibm.com>, <dragos.tatulea@gmail.com>,
	<kvm@vger.kernel.org>, <arnd@arndb.de>, <gregory.v.rose@intel.com>,
	<mchan@broadcom.com>, <dwang2@cisco.com>, <shemminger@vyatta.com>,
	<eric.dumazet@gmail.com>, <kaber@trash.net>, <benve@cisco.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-2.cisco.com ([173.36.130.13]:43937 "EHLO
	mtv-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752217Ab2BCPcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 10:32:03 -0500
In-Reply-To: <4F2ADCD4.4080205@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




On 2/2/12 10:58 AM, "John Fastabend" <john.r.fastabend@intel.com> wrote:

> On 2/2/2012 10:07 AM, Roopa Prabhu wrote:

<snip>..
>> 
>> My patches were trying to do just this (unless I am missing something).
>> 
> 
> Right I was trying enumerate the cases. Your patches 5,6 seem to use
> dev_{uc|mc}_{add|del} like this.
> 
Ok

>>> 
>>> I think this has some real advantages to the above scheme. First
>>> we get rid of _all_ the drivers having to add a bunch of new
>>> net_device ops and do it once in the layer above. This is nice
>>> for driver implementers but also because your feature becomes usable
>>> immediately and we don't have to wait for driver developers to implement
>>> it.
>> 
>> Yes my patches were targeting towards this too. I had macvlan implement the
>> netlink ops and macvlan internally was using the dev_uc_add and del routines
>> to pass the addr lists to lower device.
> 
> Yes. But I am missing why the VF ops and netlink extensions are useful. Or
> even the op/netlink extension into the PF for that matter.
> 

This was to support something that intel wanted. I think Ben described that
in another email. This was done by v3 version of the patch. This is not
needed for the macvlan problem that this patch is trying to solve. We were
trying to make the new netlink interface fit other use cases if possible.

I believe at this point we are convinced that the hybrid acceleration with
PF/VF that ben described can be solved in possibly other ways.

>> 
>>> 
>>> Also it prunes down the number of netlink extensions being added
>>> here. 
>>> 
>>> Additionally the existing semantics seem a bit strange to me on the
>>> netlink message side. Taking a quick look at the macvlan implementation
>>> it looks like every set has to have a complete list of address. But
>>> the dev_uc_add and dev_uc_del seem to be using a refcnt scheme so
>>> if I want to add a second address and then latter a third address
>>> how does that work?
>> 
>> Every set has a complete list of addresses because, for macvlan non-passthru
>> modes, in future we might want to have macvlan driver do the filtering (This
>> is for the case when we have a single lower device and multiple macvlans)
>> 
> 
> hmm but lists seem problematic when hooked up to the netdev uc and mc addr
> lists. Consider this case
> 
> read uc_list  <--- thread1: dumps unicast table
> add vlan      <--- thread2: adds a vlan maybe inserting a uc addr
> write uc_list <--- thread1: writes the table back + 1 addr
> 
> Does the uc addr of the vlan get deleted? And this case

It should.

> 
> read uc_list   <--- dump table
> write uc_list  <--- add a new filter A to the uc list
> read uc_list   <--- dump table
> write uc_list  <--- add a second filter B to the uc list
> 
> Now based on your patch 4,5 it looks like the refcnt on the address A is
> two so to remove it I have to call set filters twice without the A addr.

I think this depends on the implementation of the handler. The macvtap
handler will remove A and add B if A is not part of the second filter.


> 
> read  uc_list   <--- dump table
> write uc_list   <--- list without A
> write uc_list   <--- list without A
> 
> This seems really easy to get screwed up and it doesn't look like user
> space can learn the refcnt (at least in this series).
> 
> 


the sequences you are describing above are possible but they depend on how
you implement the filter handler I think.
For macvlan, this filter op could just populate the internal filter.
Except that for passthru mode it tries to program the lower dev hw filter
using uc/mc lists. And in passthru mode it assumes that it owns the lower
device, and tries to make sure that it adds or deletes only addresses it
knows about. I think if you have another thread also adding/deleting address
to the lowerdev when it is assigned to macvtap in passthru mode, the other
thread might see inconsistent results.

The netlink filter interface which the patch was trying to add was not a
replacement for existing uc/mc lists. It was really targeted to virtual
devices that want to do filtering on their own.
I believe uc/mc lists are used to set/unset hw filters and they are not used
in fwding lookups in the kernel (pls correct me if I am wrong). The filter
that this netlink msg was trying to set was for devices that want to do
filtering/fwding lookups like the hw.

>>> 
>>> Is the expected flow from user space 'read uc_list -> write uc_list'?
>>> This seems risky because with two adders in user space you might
>>> lose addresses unless they are somehow kept in sync. IMHO it is likely
>>> easier to implement an ADD and DEL attribute rather than a table
>>> approach.
>> 
>> The ADD and DEL will work for macvlan passthru mode because it maps 1-1 with
>> the lowerdev uc and mc list. The table was for non passthru modes when
>> macvlan driver might need to do filtering. So my patchset started with
>> macvlan filter table for all macvlan modes (hopefully) with passthru mode as
>> a specific case of offloading everything to the lowerdevice.
>> 
> 
> Still this doesn't require a table right. Repeated ADD/DEL should work
> correct?
> 
Yes that's correct. You could still have an ADD/DEL interface to populate
the table.

>>  Also the table was mimicking existing tap device filter table for macvtap.
>> 
> 
> But the tap filter isn't directly manipulating the uc/mc betdev tables. I
> think
> this is a key difference.
> 
Yes. The uc/mc list came into picture only for macvlan passthru mode because
there is a 1-1 mapping between hw  dev and macvtap and its simpler to just
pass the addr filters to the lowerdev to program the hw via mc/uc.

>>> Took a quick stab at something like this below but there
>>> might be a better way to do this and allow direct modification of the
>>> uc and mc lists I think means you could remove a uc address added
>>> by some stacked device maybe a VLAN. (just guessing.)
>>> 
>>> Sorry if I missed something in the above thread I read most of it. And
>>> maybe I missed something or oversimplified the problem.
>> 
>> I might be overcomplicating things :). I have had no time to look at this
>> again. I had started with looking at using current interfaces and I hadn't
>> found anything straight forward. But was planning to look at it again.
>> 
> 
> I'm wondering if this is really just a macvlan specific thing after all. I
> think your first v1 series was more closely done like this.
> 
Yes that's correct. I still think v1 might be cleaner. But there we had to
extend the tun filter interface to handle vlans too. And michael had a point
when he said that we should probably add newer netlink interfaces instead of
extending the existing ioctl interfaces.


>> 
>> In general since we don't have a netlink mechanism to add del mc/uc addr
>> list from userspace (which I was looking for in the first place initially)
>> such mechanism will be good to have too. I will also think about this some
>> more.
>> 
> 
> Are you sure they will be good to have? I'm  not so sure you want to be
> able to manipulate the uc and mc tables from user space. MACVLAN seems to
> be one type of device where it is useful but doing this to a PF or VF seems
> hard to use for any real use case. Fun to test the embedded bridge though.
> 

I wont say I am sure. Would be nice have to have netlink interfaces to
ADD/DEL additional uc, mc addrs, filter flags and vlans. I have looked at
the existing interfaces and nothing seemed straightforward then. But I
forget and need to take a look again.
I think vlans and filter flags is somehow possible today. And maybe mc too.
But if I am right we don't have a way to add additional unicast addresses
from userspace. 

I will dig my notes and try and list down the problems with using the
existing netlink interfaces for this.

Thanks,
Roopa
