From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2] vlan: only create special VLAN 0 once
Date: Wed, 08 Jun 2011 00:50:41 +0200
Message-ID: <4DEEAB41.1020306@trash.net>
References: <20110603200738.GA24804@midget.suse.cz> <20110605.142823.1727360496050285755.davem@davemloft.net> <4DEE4107.1080706@trash.net> <20110607164136.GB5018@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	pedro.netdev@dondevamos.com
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62953 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752646Ab1FGWuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2011 18:50:54 -0400
In-Reply-To: <20110607164136.GB5018@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07.06.2011 18:41, Jiri Bohac wrote:
> On Tue, Jun 07, 2011 at 05:17:27PM +0200, Patrick McHardy wrote:
>> On 05.06.2011 23:28, David Miller wrote:
>>> I am pretty sure that the hardware device driver methods that
>>> implement ndo_vlan_rx_add_vid() assume that the device is up.
>>> Because most drivers completely reset the chip when the
>>> interface is brought up and this will likely clear out the
>>> VLAN ID tables in the chip.
>>>
>>
>> Good point.
>>
>> I don't think this approach works very well at all since
>> some drivers don't do incremental updates, but iterate over
>> the registered VLAN group when constructing filters. The
>> group is not created until the first real VLAN device is
>> registered however.
>>
>> Based on a quick grep (may have missed some):
>>
>> - via_velocity, mlx4, starfire: will do nothing
>>
>> - benet, igb, vxge, igbvf, ixgbevf, e1000e: would oops on
>>   rx_kill_vid due to unnecessary vlan_group_set_device()
> 
> which approach do you mean? David's or mine? I suppose you mean
> David's, because I did not call rx_kill_vid().

Neither, the approach how adding VID 0 was implemented. At
least the first list of drivers mentioned above will do
nothing, the second one would oops if we removed the VID
on NETDEV_DOWN without adding a real VLAN device.

>> The assumption of the drivers that a VLAN group exists
>> before the first VID is configured is reasonable in my
>> opinion, a lot of them also don't even configure VLAN
>> filtering until the VLAN group is registered.
> 
> So this is broken already since ad1afb00 :(

Exactly.

> The assumption broke the bonding driver and this got fixed by
> f35188fa, btw.
> 
>> So I think a good solution would be to make sure all
>> drivers don't enable VLAN filtering before the first
>> VLAN is actually registered and do the automatic
>> registration of VID 0 once the first real VLAN device
>> is created.
> 
> But this behaviour is not what was intended by ad1afb00.
> The VID 0 needs to be registered by default, to make 8021p work.
> Even without any real VLAN devices created.

I'm not sure what exactly you're referring to. HW VLAN filters
are (or should be) usually only activated when the first
VLAN device is registered, so this change has no effect.

If drivers behave that way *and* the VID 0 is only registered
automatically when the first real device is configured,
this should provide the desired behaviour.

