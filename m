From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v4 06/10] netdev: add netdevice notifier type to
 trigger a reprogramming of offloads
Date: Mon, 11 Jan 2016 22:09:03 +0100
Message-ID: <569419EF.5090709@stressinduktion.org>
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
 <CALx6S365gfktShmyiXbGnCvOOsgQTQdVFnML-rxEwmtZ6egPgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jesse Gross <jesse@kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:60329 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759922AbcAKVJH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 16:09:07 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 8341E20D38
	for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 16:09:06 -0500 (EST)
In-Reply-To: <CALx6S365gfktShmyiXbGnCvOOsgQTQdVFnML-rxEwmtZ6egPgA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

On 11.01.2016 21:46, Tom Herbert wrote:
> On Mon, Jan 11, 2016 at 10:56 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> I consider the offloading interface work in progress:
>>
> I consider it a closed interface. New devices should implement
> protocol generic offloads so that we don't need to extend the protocol
> specific offload interfaces any further. We do need to break the
> dependency between drivers and VXLAN but that can be done without any
> additional APIs.

I am totally with you here.

The reason why I did this series is that I don't want to have vxlan and 
geneve modules autoloaded when I modprobe any of those drivers which 
implement ndo_add_*_port and use the current style of callbacks. So I 
think this is a step to reduce this entanglement already. I solely 
switch from vxlan_get_rx_port and geneve_get_rx_port to 
netdev_refresh_offloads.

>> I agree this interface can be much improved. But this series focuses on
>> firstly removing the dependency on the modules without changing too much
>> otherwise. No new callback is added just two ones are migrated into one.
>>
>> Currently drivers don't handle a list of all ports, they discard new ones as
>> soon as they don't fit into the hardware anymore (mostly only one). So
>> currently the state is not completely replicated in the drivers. We could
>> call the ndo_add_*_ports again after we deleted some ports and try to
>> refresh from the core kernel side. I think instead of adding this logic to
>> all drivers to fix this, it is easier to callback into the kernel instead of
>> adding this logic to almost all network drivers.
>>
> Almost all network drivers??? I count only nine that are setting
> .ndo_add_vxlan_port.

I was referring to the drivers which already implement ndo_add_{vxlan, 
geneve}_port, of course. Sorry for not being specific enough here. All 
the other drivers don't need to be considered at all.

>> Lot's of drivers refresh the ports list by calling ndo_open function again
>> because of error recovery or resuming and thus get a new port list (here
>> some drivers actually currently increment the refcounter for already
>> installed ports by mistake and I am looking into how to fix this, probably
>> by throwing away the list of currently installed port numbers first and then
>> refreshing all ports). It is even worse: it seems drivers actually increment
>> the port refcounter by mistake when you change ring settings (or other
>> settings causing a device reset) after installing the vxlan offload.
>>
>> I agree it would be great to get away with the callback completely but I
>> haven't yet fully figured out how error handling should be done then. It
>> seems also not useful to put the error handling in the ndo_add_*_port
>> functions as most simply configure the structs and call a worker afterwards
>> to process them. So the correct propagation of errors can also be tricky.
>>
>> I just don't want to mess with the state in the current drivers but as a
>> first step remove the dependency.
>>
>> The reason why I want to keep the callback is that without completely
>> understanding the rest of problems I don't know if we need it or not.
>>
> It is true that the drivers are all over the board on how they
> implement this. They need to be fixed regardless (as you point ref
> counting is a mess). A new notifier does not address this and just
> maintains what is a bad model in the first place. Inflicting more
> complexity into core APIs for this simply isn't justified, let's try
> to fix the drivers in question.

I think we have a core entanglement between the drivers that offload 
vxlan and geneve to the tunnel modules which is hurting most right now 
without dealing too much with the offloading API.

As net-next is closed now do you think the series which I actually send 
hopefully in time is still worth being considered to at least get the 
autoloading fixed. It just replaces the callback by a different callback 
which does not depend on the modules.

Quite some drivers need to be touched by that (which implement those 
offloads) and I am not sure if requesting a new port list from the 
kernel in case of error conditions and the reinitialization of the NIC 
during its UP operation without state is still the way to go and easier 
to implement. It feels that we have to add more code to the drivers 
otherwise. By looking at the current code it might make sense to just 
remove the reference counting and ask the kernel to just send down the 
list of new ports.

As soon as an interface for generic offloads is found it can be favored 
by the kernel stack and the vxlan specific code can be ifdefed out and 
later on removed as soon as all features are adequately replaced by the 
generic offloading interface.

Does that make sense?

Thanks,
Hannes
