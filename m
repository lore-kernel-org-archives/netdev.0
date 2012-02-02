From: Roopa Prabhu <roprabhu@cisco.com>
Subject: Re: [net-next-2.6 PATCH 0/6 v4] macvlan: MAC Address filtering
 support for passthru mode
Date: Thu, 02 Feb 2012 10:07:57 -0800
Message-ID: <CB5010FD.433F4%roprabhu@cisco.com>
References: <4F2A4D81.6070002@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>,
	<chrisw@redhat.com>, <sri@us.ibm.com>, <dragos.tatulea@gmail.com>,
	<kvm@vger.kernel.org>, <arnd@arndb.de>, <gregory.v.rose@intel.com>,
	<mchan@broadcom.com>, <dwang2@cisco.com>, <shemminger@vyatta.com>,
	<eric.dumazet@gmail.com>, <kaber@trash.net>, <benve@cisco.com>
To: John Fastabend <john.r.fastabend@intel.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-4.cisco.com ([173.36.130.15]:2135 "EHLO
	mtv-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933174Ab2BBSIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 13:08:10 -0500
In-Reply-To: <4F2A4D81.6070002@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




On 2/2/12 12:46 AM, "John Fastabend" <john.r.fastabend@intel.com> wrote:

> On 2/1/2012 11:24 PM, Michael S. Tsirkin wrote:
>> On Sun, Nov 20, 2011 at 08:30:24AM -0800, Roopa Prabhu wrote:
>>> 
>>> 
>>> 
>>> On 11/17/11 4:15 PM, "Ben Hutchings" <bhutchings@solarflare.com> wrote:
>>> 
>>>> Sorry to come to this rather late.
>>>> 
>>>> On Tue, 2011-11-08 at 23:55 -0800, Roopa Prabhu wrote:
>>>> [...]
>>>>> v2 -> v3
>>>>> - Moved set and get filter ops from rtnl_link_ops to netdev_ops
>>>>> - Support for SRIOV VFs.
>>>>>         [Note: The get filters msg (in the way current get rtnetlink
>>>>> handles
>>>>>         it) might get too big for SRIOV vfs. This patch follows existing
>>>>> sriov 
>>>>>         vf get code and tries to accomodate filters for all VF's in a PF.
>>>>>         And for the SRIOV case I have only tested the fact that the VF
>>>>>         arguments are getting delivered to rtnetlink correctly. The code
>>>>>         follows existing sriov vf handling code so rest of it should work
>>>>> fine]
>>>> [...]
>>>> 
>>>> This is already broken for large numbers of VFs, and increasing the
>>>> amount of information per VF is going to make the situation worse.  I am
>>>> no netlink expert but I think that the current approach of bundling all
>>>> information about an interface in a single message may not be
>>>> sustainable.
>>> 
>>> Yes agreed. I have the same concern.
>> 
>> So it seems that we need to extend the existing interface to allow
>> tweaking filters per VF. Does it need to block this
>> patchset though? After all, we'll need to support the existing
> 
> hmm not sure I follow what patchset is this blocking?
> 
>> interface indefinitely, too.
>> 
> 
> OK finally got to read through this. And its not clear to me why we need
> these per VF/PF filter netdevice ops and netlink extensions if we can
> get the stacking correct. (Adding filters to the macvlan seems reasonable
> to me)
> 
> In the cases I saw listed above I see a few enumerations:
> 
> PF <--> MACVLAN  <---> Guest <--- [...]
> 
> VF <--> MACVLAN  <---> Guest <--- [...]
> 
>                     VF|Guest <--- [...]       direct assigned VF
> 
>                     PF|Guest <--- [...]       direct assigned PF
> 
> 
> I used '[...]' to represent whatever additional stacking is done in the
> guest unknown to the host. In the direct assign VF case (Greg Rose
> correct me if I am wrong) the normal uc and mc addr lists should suffice
> along with the netdev op ndo_set_rx_mode(). Here the guest adds MAC
> addresses and/or VLANS as normal and then the VF<->PF back channel
> should handle this if needed. This should work for Linux guests and other
> OS's should do something similar.
> 
> In the direct assign PF case the hardware is owned by the guest so
> no problems here.
> 
> This leaves the two MACVLAN cases which can be handled the same. If
> the MACVLAN driver and netlink interface is extended to add filters
> to the MACVLAN then the addresses can be pushed to the lower device
> using the normal dev_uc_{add|del}() and dev_mc_{add|del}() routines.

My patches were trying to do just this (unless I am missing something).

> 
> I think this has some real advantages to the above scheme. First
> we get rid of _all_ the drivers having to add a bunch of new
> net_device ops and do it once in the layer above. This is nice
> for driver implementers but also because your feature becomes usable
> immediately and we don't have to wait for driver developers to implement
> it.

Yes my patches were targeting towards this too. I had macvlan implement the
netlink ops and macvlan internally was using the dev_uc_add and del routines
to pass the addr lists to lower device.

> 
> Also it prunes down the number of netlink extensions being added
> here. 
> 
> Additionally the existing semantics seem a bit strange to me on the
> netlink message side. Taking a quick look at the macvlan implementation
> it looks like every set has to have a complete list of address. But
> the dev_uc_add and dev_uc_del seem to be using a refcnt scheme so
> if I want to add a second address and then latter a third address
> how does that work?

Every set has a complete list of addresses because, for macvlan non-passthru
modes, in future we might want to have macvlan driver do the filtering (This
is for the case when we have a single lower device and multiple macvlans)

> 
> Is the expected flow from user space 'read uc_list -> write uc_list'?
> This seems risky because with two adders in user space you might
> lose addresses unless they are somehow kept in sync. IMHO it is likely
> easier to implement an ADD and DEL attribute rather than a table
> approach.

The ADD and DEL will work for macvlan passthru mode because it maps 1-1 with
the lowerdev uc and mc list. The table was for non passthru modes when
macvlan driver might need to do filtering. So my patchset started with
macvlan filter table for all macvlan modes (hopefully) with passthru mode as
a specific case of offloading everything to the lowerdevice.

 Also the table was mimicking existing tap device filter table for macvtap.

> Took a quick stab at something like this below but there
> might be a better way to do this and allow direct modification of the
> uc and mc lists I think means you could remove a uc address added
> by some stacked device maybe a VLAN. (just guessing.)
> 
> Sorry if I missed something in the above thread I read most of it. And
> maybe I missed something or oversimplified the problem.

I might be overcomplicating things :). I have had no time to look at this
again. I had started with looking at using current interfaces and I hadn't
found anything straight forward. But was planning to look at it again.

> 
> Thanks,
> John
> 
> 
> 
> +/* MACVLAN ADDRLIST management section
> + *
> + * Contains attributes to expose multicast and unicast hardware
> + * RX address filters to user space.
> + *
> + * FIELDS:
> + * - IFLA_ADDRLIST_{UC|MC}
> + *
> + *   Read only attributes, returns currently set mc or uc addr list.
> + *
> + * - IFLA_ADDRLIST_{UC|MC}_ADD
> + *
> + *   Write only attributes, adds listed addresses to dev uc or mc
> + *   RX filter address lists.
> + *
> + * - IFLA_ADDRLIST_{UC|MC}_DEL
> + *
> + *   Write only attributes, deletes listed addresses in dev uc or
> + *   mc RX filter address lists.
> + *
> + * PRECEDENCE:
> + *
> + * Add operations are parsed before delete operations. Passing a
> + * single netlink message with a single address in both the add
> + * and del lists will result in an addresses being added and then
> + * removed.
> + *
> + * USAGE:
> + *
> + *     [IFLA_ADDRLISTS]
> + *             [IFLA_ADDRLIST_UC]
> + *                     [IFLA_ADDRLIST_ADDR], ...
> + *             [IFLA_ADDRLIST_UC_ADD]
> + *                     [IFLA_ADDRLIST_ADDR], ...
> + *             [IFLA_ADDRLIST_UC_DEL]
> + *                     [IFLA_ADDRLIST_ADDR}, ...
> + *             [IFLA_ADDRLIST_MC]
> + *                     [IFLA_ADDRLIST_ADDR], ...
> + *             [IFLA_ADDRLIST_MC_ADD]
> + *                     [IFLA_ADDRLIST_ADDR], ...
> + *             [IFLA_ADDRLIST_MC_DEL]
> + *                     [IFLA_ADDRLIST_ADDR}, ...
> + *
> + * NOTES:
> + *
> + * This interface exposes the uc and mc addresses. Addresses
> + * are handled with reference counting so adding the same address
> + * repeatedly will increment the reference count. No effort is
> + * made to determine if the address being deleted was not added
> + * by a stacked object earlier e.g. VLAN. This could for instance
> + * result in ingress VLAN traffic being dropped.
> + */

In general since we don't have a netlink mechanism to add del mc/uc addr
list from userspace (which I was looking for in the first place initially)
such mechanism will be good to have too. I will also think about this some
more.

Thanks,
Roopa
