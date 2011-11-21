From: Greg Rose <gregory.v.rose@intel.com>
Subject: Re: [net-next-2.6 PATCH 0/6 v4] macvlan: MAC Address filtering support
 for passthru mode
Date: Mon, 21 Nov 2011 09:41:36 -0800
Message-ID: <4ECA8D50.9080603@intel.com>
References: <20111109075449.13549.58135.stgit@rhel6.1>  <1321575301.2749.51.camel@bwh-desktop>  <4EC5A785.3060108@intel.com>  <1321577078.2749.58.camel@bwh-desktop>  <4EC68EBB.3080303@intel.com> <1321638038.2883.28.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roprabhu@cisco.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"chrisw@redhat.com" <chrisw@redhat.com>,
	"sri@us.ibm.com" <sri@us.ibm.com>,
	"dragos.tatulea@gmail.com" <dragos.tatulea@gmail.com>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"arnd@arndb.de" <arnd@arndb.de>, "mst@redhat.com" <mst@redhat.com>,
	"mchan@broadcom.com" <mchan@broadcom.com>,
	"dwang2@cisco.com" <dwang2@cisco.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"benve@cisco.com" <benve@cisco.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:1298 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751517Ab1KURlk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Nov 2011 12:41:40 -0500
In-Reply-To: <1321638038.2883.28.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/18/2011 9:40 AM, Ben Hutchings wrote:
> On Fri, 2011-11-18 at 08:58 -0800, Greg Rose wrote:
>> On 11/17/2011 4:44 PM, Ben Hutchings wrote:
>>> On Thu, 2011-11-17 at 16:32 -0800, Greg Rose wrote:
>>>> On 11/17/2011 4:15 PM, Ben Hutchings wrote:
>>>>> Sorry to come to this rather late.
>>>>>
>>>>> On Tue, 2011-11-08 at 23:55 -0800, Roopa Prabhu wrote:
>>>>> [...]
>>>>>> v2 ->    v3
>>>>>> - Moved set and get filter ops from rtnl_link_ops to netdev_ops
>>>>>> - Support for SRIOV VFs.
>>>>>>            [Note: The get filters msg (in the way current get rtnetlink handles
>>>>>>            it) might get too big for SRIOV vfs. This patch follows existing sriov
>>>>>>            vf get code and tries to accomodate filters for all VF's in a PF.
>>>>>>            And for the SRIOV case I have only tested the fact that the VF
>>>>>>            arguments are getting delivered to rtnetlink correctly. The code
>>>>>>            follows existing sriov vf handling code so rest of it should work fine]
>>>>> [...]
>>>>>
>>>>> This is already broken for large numbers of VFs, and increasing the
>>>>> amount of information per VF is going to make the situation worse.  I am
>>>>> no netlink expert but I think that the current approach of bundling all
>>>>> information about an interface in a single message may not be
>>>>> sustainable.
>>>>>
>>>>> Also, I'm unclear on why this interface is to be used to set filtering
>>>>> for the (PF) net device as well as for related VFs.  Doesn't that
>>>>> duplicate the functionality of ndo_set_rx_mode and
>>>>> ndo_vlan_rx_{add,kill}_vid?
>>>>
>>>> Functionally yes but contextually no.  This allows the PF driver to know
>>>> that it is setting these filters in the context of the existence of VFs,
>>>> allowing it to take appropriate action.  The other two functions may be
>>>> called without the presence of SR-IOV enablement and the existence of VFs.
>>>>
>>>> Anyway, that's why I asked Roopa to add that capability.
>>>
>>> I don't follow.  The PF driver already knows whether it has enabled VFs.
>>>
>>> How do filters set this way interact with filters set through the
>>> existing operations?  Should they override promiscuous mode?  None of
>>> this has been specified.
>>
>> Promiscuous mode is exactly the issue this feature is intended for.  I'm
>> not familiar with the solarflare device but Intel HW promiscuous mode is
>> only promiscuous on the physical port, not on the VEB.  So a packet sent
>> from a VF will not be captured by the PF across the VEB unless the MAC
>> and VLAN filters have been programmed into the HW.
>
> Yes, I get it.  The hardware bridge needs to know more about the address
> configuration on the host than the driver is getting at the moment.
>
>> So you may not need
>> the feature for your devices but it is required for Intel devices.
>
> Well we don't have the hardware bridge but that means each VF driver
> needs to know whether to fall back to the software bridge.  The net
> driver needs much the same additional information.
>
>> And
>> it's a fairly simple request, just allow -1 to indicate that the target
>> of the filter requests is for the PF itself.  Using the already existing
>> set_rx_mode function wont' work because the PF driver will look at it
>> and figure it's in promiscuous mode anyway, so it won't set the filters
>> into the HW.  At least that is how it is in the case of our HW and
>> driver.  Again, the behavior of your HW and driver is unknown to me and
>> thus you may not require this feature.
>
> What concerns me is that this seems to be a workaround rather than a fix
> for over-use of promiscuous mode, and it changes the semantics of
> filtering modes in ways that haven't been well-specified.

I feel the opposite is true.  It allows a known set of receive filters 
so that you don't have to use promiscuous mode, which cuts down on 
overhead from processing packets the upper layer stack isn't really 
interested in.

>
> What if there's a software bridge between two net devices corresponding
> to separate physical ports, so that they really need to be promiscuous?
> What if the administrator runs tcpdump and really wants the (PF) net
> device to be promiscuous?

I don't believe there is anything in this patch set that removes 
promiscuous mode operation as it is commonly used.  Perhaps I've missed 
something.

>
> These cases shouldn't break because of VF acceleration.

I don't see how they would in the case of Intel HW.  And these new ops 
to set rx filters are something that Intel HW needs because it 
implements a VEB that is *not* a learning bridge and we don't want it to 
be a learning bridge because of security concerns.  It is better for our 
requirements to be allowed to set the MAC/VLAN filters that we want a VF 
to be able to see.

> Or at least we
> should make a conscious and documented decision that 'promiscuous'
> doesn't mean that if you enable it on your network adapter.

Again, I don't know of any plans to change anything relating to putting 
a device in promiscuous mode or changing the semantics of what 
promiscuous mode means.

- Greg
