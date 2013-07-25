From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [patch net-next v4 4/4] igb/igbvf: implement ndo_get_phys_port_id
Date: Thu, 25 Jul 2013 12:58:30 -0700
Message-ID: <51F18366.2040306@gmail.com>
References: <1374757385-10875-1-git-send-email-jiri@resnulli.us>    <1374757385-10875-5-git-send-email-jiri@resnulli.us>    <51F14F9F.1010703@intel.com>   <1374770653.3058.9.camel@bwh-desktop.uk.level5networks.com>   <51F167A6.808@intel.com>  <1374778266.3058.15.camel@bwh-desktop.uk.level5networks.com>  <51F1769E.3050906@intel.com> <1374779745.3058.24.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org, Narendra_K@Dell.com,
	john.r.fastabend@intel.com, or.gerlitz@gmail.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com,
	tushar.n.dave@intel.com, matthew.vick@intel.com,
	mitch.a.williams@intel.com, vyasevic@redhat.com, amwang@redhat.com,
	johannes@sipsolutions.net
To: Ben Hutchings <bhutchings@solarflare.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:37518 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756524Ab3GYT7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 15:59:43 -0400
Received: by mail-ob0-f171.google.com with SMTP id tb18so2481113obb.2
        for <netdev@vger.kernel.org>; Thu, 25 Jul 2013 12:59:43 -0700 (PDT)
In-Reply-To: <1374779745.3058.24.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/25/2013 12:15 PM, Ben Hutchings wrote:
> On Thu, 2013-07-25 at 12:03 -0700, Alexander Duyck wrote:
>> On 07/25/2013 11:51 AM, Ben Hutchings wrote:
>>> On Thu, 2013-07-25 at 11:00 -0700, Alexander Duyck wrote:
>>>> On 07/25/2013 09:44 AM, Ben Hutchings wrote:
>>>>> On Thu, 2013-07-25 at 09:17 -0700, Alexander Duyck wrote:
>>>>>> On 07/25/2013 06:03 AM, Jiri Pirko wrote:
>>>>>>> @@ -1982,6 +2001,21 @@ static s32 igb_init_i2c(struct igb_adapter *adapter)
>>>>>>>   	return status;
>>>>>>>   }
>>>>>>>
>>>>>>> +static void igb_compute_phys_port_id(struct igb_adapter *adapter)
>>>>>>> +{
>>>>>>> +	adapter->phys_port_id = *((u32 *) adapter->netdev->dev_addr);
>>>>>>> +	adapter->phys_port_id ^= *((u32 *) adapter->netdev->dev_addr + 4);
>>>>>>> +	adapter->phys_port_id ^= (long) adapter;
>>>>>>> +	adapter->phys_port_id ^= (long) adapter->hw.hw_addr;
>>>>>>> +	adapter->phys_port_id ^= (long) adapter->hw.flash_address;
>>>>>>> +	adapter->phys_port_id ^= (u32) adapter->hw.io_base;
>>>>>>> +	adapter->phys_port_id ^= adapter->hw.device_id;
>>>>>>> +	adapter->phys_port_id ^= adapter->hw.subsystem_vendor_id;
>>>>>>> +	adapter->phys_port_id ^= adapter->hw.subsystem_device_id;
>>>>>>> +	adapter->phys_port_id ^= adapter->hw.vendor_id;
>>>>>>> +	adapter->phys_port_id ^= adapter->hw.revision_id;
>>>>> I didn't look at Jiri's patch initially, but... what's wrong with using
>>>>> the MAC address from NVRAM (should already be in netdev->perm_addr)?
>>>>> That's what I'm expecting to do for the SFC9000 family in sfc.
>>>>>
>>>>>>> +}
>>>>>>> +
>>>>>>>   /**
>>>>>>>    *  igb_probe - Device Initialization Routine
>>>>>>>    *  @pdev: PCI device information struct
>>>>>> I really think this bit here should be standardized and made available
>>>>>> to all drivers.
>>>>> [...]
>>>>>
>>>>> I think it's a bad example and should not be used in any drivers!
>>>>>
>>>>> Ben.
>>>>>
>>>> I agree.  That is why the second paragraph started listing what was
>>>> wrong with this implementation.  What I said was meant in the more
>>>> general sense that whatever solution should be used should be the same
>>>> across multiple drivers, not up to each driver to compute.
>>> I would love to know how you think this can be done generically.  If it
>>> can then we don't need the driver operation at all.
>>>
>>> Ben.
>>>
>>
>> Well like you mentioned, you could just pull this out out of
>> netdev->perm_addr.  You don't need to have anything driver specific as
>> long as that is the field you are using generic netdev or pci_dev
>> attributes to do the identification.
>
> For a PF driver that never shares the port with another PF, yes.  There
> are a handful of those drivers so it might be worth sharing an
> implementation that uses perm_addr, but it's so trivial...
>
>> All you need is something that
>> uniquely identifies the device in the system correct?
>
> The spec is that it is universally unique.  I don't know who's going to
> need that property but I think it's achievable since each physical port
> normally has at least one globally unique MAC address assigned at
> manufacturing time.
>
>> For that matter
>> it seems like you could probably just pull the domain, bus, device, and
>> function number out of the PCI device and that would probably work as
>> well as long as you cannot somehow have PFs running inside of guests.
>
> Some NICs have multiple PFs for the same port, and those could be
> assigned to guest VMs.
>
> All VF drivers would need some way to get the port ID, and that can't be
> done generically from inside a guest VM.
>
> Ben.
>

I doubt you'll be able to think up a way to do this generically as Ben
points out. But also no reason for the complicated hash just use the
perm address of the PF and if you have multiple PFs elect one of the
n perm address to be the stand-in for the unique one.

.John

-- 
John Fastabend         Intel Corporation
