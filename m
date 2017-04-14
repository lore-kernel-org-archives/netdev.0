From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Subject: Re: How to debug DMAR errors?
Date: Fri, 14 Apr 2017 09:41:04 -0700
Message-ID: <884e0ae5-f9a2-734d-b46c-5b22678fbe6d@candelatech.com>
References: <a21d8845-ae8d-fae0-b1b4-7bf6751b04b5@candelatech.com>
 <CAKgT0UcEKTsc6-tSHXMHFybnE4NQASKWHziq2SV+spOCLJGH-g@mail.gmail.com>
 <fdbc5502-e388-b614-4f09-fa7de9a4f40e@candelatech.com>
 <CAKgT0UcPCMvs2OFkWGTs_TbKoxkLcnxjodroMDo82W4ptCfu3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAKgT0UcPCMvs2OFkWGTs_TbKoxkLcnxjodroMDo82W4ptCfu3Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 04/14/2017 09:24 AM, Alexander Duyck wrote:
> On Fri, Apr 14, 2017 at 9:19 AM, Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org> wrote:
>>
>>
>> On 04/14/2017 08:45 AM, Alexander Duyck wrote:
>>>
>>> On Thu, Apr 13, 2017 at 11:12 AM, Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
>>> wrote:
>>>>
>>>> Hello,
>>>>
>>>> I have been seeing a regular occurrence of DMAR errors, looking something
>>>> like this when testing my ath10k driver/firmware under some specific
>>>> loads
>>>> (maximum receive of 512 byte frames in AP mode):
>>>>
>>>> DMAR: DRHD: handling fault status reg 3
>>>> DMAR: [DMA Read] Request device [05:00.0] fault addr fd99f000 [fault
>>>> reason
>>>> 06] PTE Read access is not set
>>>> ath10k_pci 0000:05:00.0: firmware crashed! (uuid
>>>> 594b1393-ae35-42b5-9dec-74ff0c6791ff)
>>>>
>>>> So, I am wondering if there is any way I can get more information about
>>>> what
>>>> this fd99f000 address
>>>> is?
>>>>
>>>> Once this problem hits, the entire OS locks hard (not even sysrq-boot
>>>> will
>>>> do anything),
>>>> so I guess I would need the DMAR logic to print out more info on that
>>>> address somehow.
>>>>
>>>> Thanks,
>>>> Ben
>>>
>>>
>>> There isn't much more info to give you. The problem is that the device
>>> at 5:00.0 attempted to read at fd99f000 even though it didn't have
>>> permissions. In response this should trigger a PCI Master Abort
>>> message to that function. It looks like the firmware for the device
>>> doesn't handle that and so that is likely why things got hung.
>>>
>>> Really you would need to interrogate the ath10k_pci to see if there
>>> is/was a mapping somewhere for that address and what it was supposed
>>> to be used for.
>>
>>
>> I'm working on a hook in DMAR logic to call into ath10k_pci when the
>> error is seen, so the ath10k can dump debug info, including recent DMA
>> addresses.
>>
>> My code is an awful hack so far, but if someone could add a clean way to
>> register
>> DMAR error callbacks, I think that would be very welcome.  It might could
>> tie into
>> automated dma map/unmap debugging logic, and at the least, someone could
>> write custom debugging callbacks
>> for the driver(s) in question.
>>
>> Thanks,
>> Ben
>>
>
> You might look at coding up something to add pci_error_handlers for
> the pci_driver in the ath10k_pci driver. The PCI Master Abort should
> trigger an error that you could then capture in the driver and handle
> at least dumping it via your own implementation of the error handlers.
> If nothing else I suspect there are probably some sort of descriptor
> rings you could probably dump. I'm suspecting this is some sort of Tx
> issue since the problem was a read fault, but I suppose there are
> other paths in the driver that might trigger DMA read requests.

This is a thick firmware driver, so the firmware could also be screwing up
and accessing something it should not.  There are some existing work-arounds
in it to deal with sketchy behaviour already, maybe more are needed.

Anyway, once I added the debugging code, I didn't see it crash again, so
might be a while before I know more.

Thanks,
Ben

>
> - Alex
>

-- 
Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Candela Technologies Inc  http://www.candelatech.com
