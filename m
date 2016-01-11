From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next v4 06/10] netdev: add netdevice notifier type to
 trigger a reprogramming of offloads
Date: Mon, 11 Jan 2016 12:46:38 -0800
Message-ID: <CALx6S365gfktShmyiXbGnCvOOsgQTQdVFnML-rxEwmtZ6egPgA@mail.gmail.com>
References: <1452352052-27574-1-git-send-email-hannes@stressinduktion.org>
	<1452352052-27574-7-git-send-email-hannes@stressinduktion.org>
	<CALx6S357fYzhCRHsPAjX+NH+5Wc1tnUuNwcZ5oy3WiAMASjOEA@mail.gmail.com>
	<5691439F.5090500@stressinduktion.org>
	<CALx6S37rhc+xiOZfk2F4=AXWK4jxu7BP3VMBjSCFoOMjLdLaZw@mail.gmail.com>
	<56918F1E.8080600@stressinduktion.org>
	<CALx6S341SP0XN-iBGeR_MXyu3LoYmXBsCBguDcwc26CVvF3Gtw@mail.gmail.com>
	<56939C00.3060801@stressinduktion.org>
	<CALx6S360oG5sLCmCx=UExeFU_n9dpxM8vEL=DZ-n13HSvf1Q4g@mail.gmail.com>
	<5693FAEB.8080506@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jesse Gross <jesse@kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:37101 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932180AbcAKUqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 15:46:39 -0500
Received: by mail-ig0-f170.google.com with SMTP id h5so78602439igh.0
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 12:46:38 -0800 (PST)
In-Reply-To: <5693FAEB.8080506@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 11, 2016 at 10:56 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On 11.01.2016 17:09, Tom Herbert wrote:
>>
>> On Mon, Jan 11, 2016 at 4:11 AM, Hannes Frederic Sowa
>> <hannes@stressinduktion.org> wrote:
>>>
>>> On 10.01.2016 18:16, Tom Herbert wrote:
>>>>
>>>>
>>>> On Sat, Jan 9, 2016 at 2:52 PM, Hannes Frederic Sowa <
>>>> hannes@stressinduktion.org> wrote:
>>>>>
>>>>>
>>>>> On 09.01.2016 23:27, Tom Herbert wrote:
>>>>>>
>>>>>>
>>>>>>
>>>>>> On Sat, Jan 9, 2016 at 9:30 AM, Hannes Frederic Sowa
>>>>>> <hannes@stressinduktion.org> wrote:
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>> On 09.01.2016 18:25, Tom Herbert wrote:
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>> On Sat, Jan 9, 2016 at 7:07 AM, Hannes Frederic Sowa
>>>>>>>> <hannes@stressinduktion.org> wrote:
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>
>>>>>>>>> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>>>>>>>>> ---
>>>>>>>>> include/linux/netdevice.h | 1 +
>>>>>>>>> 1 file changed, 1 insertion(+)
>>>>>>>>>
>>>>>>>>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>>>>>>>>> index 8d8e5ca951b493..9750e46760695d 100644
>>>>>>>>> --- a/include/linux/netdevice.h
>>>>>>>>> +++ b/include/linux/netdevice.h
>>>>>>>>> @@ -2183,6 +2183,7 @@ struct netdev_lag_lower_state_info {
>>>>>>>>> #define NETDEV_BONDING_INFO 0x0019
>>>>>>>>> #define NETDEV_PRECHANGEUPPER 0x001A
>>>>>>>>> #define NETDEV_CHANGELOWERSTATE 0x001B
>>>>>>>>> +#define NETDEV_REFRESH_OFFLOADS 0x001C
>>>>>>>>>
>>>>>>>> Per previous discussion we don't want to generalize this current
>>>>>>>> offload interface. Can we just NETDEV_UP as the notifier?
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>> The problem with only using NETDEV_UP/REGISTER is that some drivers
>>>>>>> need
>>>>>>> to
>>>>>>> reconfigure their offloads during operation while keeping the
>>>>>>> netdevice
>>>>>>> in
>>>>>>> UP state. One example is ixgbe. This was my first idea also.
>>>>>>>
>>>>>> It's configuration. Just get it once and save the port number(s) in
>>>>>> the driver. Configure the device only when
>>>>>> IXGBE_FLAG_VXLAN_OFFLOAD_CAPABLE is set.
>>>>>
>>>>>
>>>>>
>>>>>
>>>>> I don't see much value that each driver has to hold a database of ports
>>>>> to
>>>>> offload, the kernel knows much better and can easily be queried via
>>>>> this
>>>>> mechanism.
>>>>>
>>>>> This is not only about ixgbe, but also about benet, which f.e. needs
>>>>> the
>>>>> list of offloads available again during resume. Of course, drivers can
>>>>> do
>>>>> their own stateful handling of ports, but this seems to much more
>>>>> generate
>>>>> problems. I rather would like to see more logic moved into the core and
>>>>
>>>>
>>>> less
>>>>>
>>>>>
>>>>> code in the drivers.
>>>>>
>>>> All the drivers that support VXLAN already save the ports in a stateful
>>>> fashion. Some support a single port, some and array, some a list. The
>>>> only
>>>> question is whether they bother to save the information when the offload
>>>> feature is disabled. ixgbe does not for instance, but it looks like
>>>> fm10k
>>>> does since it doesn't check any feature flags. Fixing those that don't
>>>> save
>>>> the information all the times should be straightforward.
>>>
>>>
>>>
>>> Yes, would probably be straight forward to add another list plus extra
>>> reference counting and maybe a lock, but I don't see why we need to
>>> duplicate the policy in the drivers? I personally think ixgbe does ok in
>>> this regard.
>>>
>> Again, to reiterate, _all_ the drivers that support VXLAN already save
>> the ports in a stateful fashion. Adding a new notifier is unnecessary
>> and makes things more complicated, not less. Also to reiterate, this
>> is not generic functionality that the driver is providing; we should
>> not need to add anything for this into the core APIs outside of the
>> two ndo functions that already exist.
>
>
> I consider the offloading interface work in progress:
>
I consider it a closed interface. New devices should implement
protocol generic offloads so that we don't need to extend the protocol
specific offload interfaces any further. We do need to break the
dependency between drivers and VXLAN but that can be done without any
additional APIs.

> I agree this interface can be much improved. But this series focuses on
> firstly removing the dependency on the modules without changing too much
> otherwise. No new callback is added just two ones are migrated into one.
>
> Currently drivers don't handle a list of all ports, they discard new ones as
> soon as they don't fit into the hardware anymore (mostly only one). So
> currently the state is not completely replicated in the drivers. We could
> call the ndo_add_*_ports again after we deleted some ports and try to
> refresh from the core kernel side. I think instead of adding this logic to
> all drivers to fix this, it is easier to callback into the kernel instead of
> adding this logic to almost all network drivers.
>
Almost all network drivers??? I count only nine that are setting
.ndo_add_vxlan_port.

> Lot's of drivers refresh the ports list by calling ndo_open function again
> because of error recovery or resuming and thus get a new port list (here
> some drivers actually currently increment the refcounter for already
> installed ports by mistake and I am looking into how to fix this, probably
> by throwing away the list of currently installed port numbers first and then
> refreshing all ports). It is even worse: it seems drivers actually increment
> the port refcounter by mistake when you change ring settings (or other
> settings causing a device reset) after installing the vxlan offload.
>
> I agree it would be great to get away with the callback completely but I
> haven't yet fully figured out how error handling should be done then. It
> seems also not useful to put the error handling in the ndo_add_*_port
> functions as most simply configure the structs and call a worker afterwards
> to process them. So the correct propagation of errors can also be tricky.
>
> I just don't want to mess with the state in the current drivers but as a
> first step remove the dependency.
>
> The reason why I want to keep the callback is that without completely
> understanding the rest of problems I don't know if we need it or not.
>
It is true that the drivers are all over the board on how they
implement this. They need to be fixed regardless (as you point ref
counting is a mess). A new notifier does not address this and just
maintains what is a bad model in the first place. Inflicting more
complexity into core APIs for this simply isn't justified, let's try
to fix the drivers in question.

> Thoughts?
>
> Thanks,
> Hannes
>
