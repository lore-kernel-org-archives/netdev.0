From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into hardware
Date: Wed, 29 Feb 2012 10:19:48 -0800
Message-ID: <4F4E6C44.9070502@intel.com>
References: <20120209032206.32468.92296.stgit@jf-dev1-dcblab> <20120208203627.035c6b0e@nehalam.linuxnetplumber.net> <4F34042F.6090806@intel.com> <20120209094047.3ea7aa56@nehalam.linuxnetplumber.net> <4F3407F7.9000202@intel.com> <1328821894.2089.3.camel@mojatatu> <4F347D96.2020806@intel.com> <4F3499BC.8020609@intel.com> <1328887111.2075.43.camel@mojatatu> <4F39287F.6030204@intel.com> <1329225526.2806.34.camel@mojatatu> <4F3AAE80.4040609@intel.com> <1329315057.4158.15.camel@mojatatu> <4F3C5B44.7000608@intel.com> <1329488932.2272.19.camel@mojatatu> <4F3E8A01.5000205@intel.com> <1329568900.3027.0.camel@mojatatu> <4F4DAC26.4050108@intel.com> <1330523779.18226.17.camel@mojatatu> <4F4E5FA4.4040506@intel.com> <20120229095204.48885405@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, bhutchings@solarflare.com,
	roprabhu@cisco.com, netdev@vger.kernel.org, mst@redhat.com,
	chrisw@redhat.com, davem@davemloft.net, gregory.v.rose@intel.com,
	kvm@vger.kernel.org, sri@us.ibm.com, kernel@wantstofly.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:64026 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965490Ab2B2STt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Feb 2012 13:19:49 -0500
In-Reply-To: <20120229095204.48885405@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/29/2012 9:52 AM, Stephen Hemminger wrote:
> On Wed, 29 Feb 2012 09:25:56 -0800
> John Fastabend <john.r.fastabend@intel.com> wrote:
> 
>> On 2/29/2012 5:56 AM, Jamal Hadi Salim wrote:
>>> On Tue, 2012-02-28 at 20:40 -0800, John Fastabend wrote:
>>>
>>>> OK back to this. The last piece is where to put these messages...
>>>> we could take PF_ROUTE:RTM_*NEIGH
>>>>
>>>>      PF_ROUTE:RTM_NEWNEIGH - Add a new FDB entry to an offloaded
>>>>                              switch.
>>>>      PF_ROUTE:RTM_DELNEIGH - Delete a FDB entry from an offlaoded
>>>>                              switch.
>>>>      PF_ROUTE:RTM_GETNEIGH - Dumps the embedded FDB table
>>>>
>>>
>>> Why RTM_*NEIGH? RTM tends to map to Route/L3 and NEIGH tends to map
>>> to ndisc or ARP both tied to IP address resolution. While both ARP/Ndisc
>>> may play a role in the user space app populating the FDB, i dont think
>>> they are necessary players.
>>> Learning could be via a table entry miss and packet redirect to user
>>> space.
>>> So my suggestion is to use FDB_*ENTRY for names
>>>  
>>
>> Well I think NETLINK_ROUTE is the most correct type to use in this
>> case. Per netlink.h its for routing and device hooks.
>>
>> #define NETLINK_ROUTE           0       /* Routing/device hook                          */
>>
>> And NETLINK_ROUTE msg_types use the RTM_* prefix. The _*NEIGH postfix
>> were merely a copy from the SW BRIDGE code paths. How about,
>>
>> PF_BRIDGE:RTM_FDB_NEWENTRY
>> PF_BRIDGE:RTM_FDB_DELENTRY
>> PF_BRIDGE:RTM_FDB_GETENTRY
>>
>> And a new group RTNLGRP_FDB. Also using NETLINK_ROUTE gives the correct
>> rtnl locking semantics for free.
>>
>>>> The neighbor code is using the PF_UNSPEC protocol type so we won't
>>>> collide with these unless someone was using PF_ROUTE and relying on
>>>> falling back to PF_UNSPEC however I couldn't find any programs that
>>>> did this iproute2 certainly doesn't. And the bridge pieces are using
>>>> PF_BRIDGE so no collision there.
>>>
>>> They have to be different calls from the calls that talk to the s/ware
>>> bridge. In my opinion, as controversial as this may sound, you need to
>>> be flexible enough that some vendor can replace these calls with
>>> proprietary calls which are more efficient for their hardware. So a
>>> "plugin" to replace these calls in the user space code would be a 
>>> good idea. Alternatively, you could make that something they do at
>>> the driver level i.e from user space to kernel it is "hardware, please
>>> addthistotheFDBtable()" call and the implementation of that could be
>>> proprietary to the specific hardware.
>>>
>>
>> Agreed. I think adding some ndo_ops for bridging offloads here would
>> work. For example the DSA infrastructure and/or macvlan devices might
>> need this. Along the lines of extending this RFC,
>>
>> [RFC] hardware bridging support for DSA switches
>> http://patchwork.ozlabs.org/patch/16578/
> 
> I want to see a unified API so that user space control applications (RSTP, TRILL?)
> can use one set of netlink calls for both software bridge and hardware offloaded
> bridges.  Does this proposal meet that requirement?
> 

With the patches I sent out last night the same netlink calls are used
for both SW and HW with a flag set in ndm_flags to indicate it is a hardware
entry. The flag is needed when a port has offload support and is also
a slave of a SW bridge. Another option would be to apply the command to both
hardware and software tables. This might be good enough and user space would
not have to make distinctions between HW and SW bridges. Also helps with my
original use case where I want the SW and HW bridge FDBs to be in sync.

In response to Jamal's comment I proposed changing the type to RTM_FDB_XXXENTRY
but the message contents are the same in both cases.

Jamal, so why do "They have to be different calls"? I'm not so sure anymore...
moving to RTM_FDB_XXXENTRY saved some refactoring in the bridge module but that
is just cosmetic.

Thanks,
John
