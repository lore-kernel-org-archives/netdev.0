From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 00/39] merge request for WiMAX kernel stack and i2400m driver v2
Date: Thu, 27 Nov 2008 12:14:30 +0100
Message-ID: <00E41CD2-3C1B-4B39-8720-698DBC236CE8@holtmann.org>
References: <cover.1227691434.git.inaky@linux.intel.com> <1227783281.3809.78.camel@johannes.berg>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Inaky Perez-Gonzalez <inaky@linux.intel.com>,
	netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:54078 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007AbYK0LOm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 06:14:42 -0500
In-Reply-To: <1227783281.3809.78.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johannes,

> Thanks for this work. I don't personally have much of an interest in
> wimax, so I don't really care what you do, so take things I have said
> and will say with a grain of salt. It's not my intention to say  
> "you've
> done it all wrong", but more to offer observations on how these things
> were done in wifi and how it went all wrong there, requiring a  
> complete
> rewrite recently.
>
> Conceptually, I think wimax is now at a point where wifi was many  
> years
> ago with the first wireless drivers: everything was full-mac, wext
> ioctls were written to go directly to the driver. Then ipw2x00 came
> along, more functionality was moved to the host (yes, you say this  
> won't
> happen with wimax, but I think it will, eventually, if wimax gets to  
> be
> popular enough. never say never), and wext got more messy. Wext even  
> was
> defining actual operations, as undefined as they often were, you're  
> not
> even doing that.

some parts of the WiMAX specification are still undergoing re-writes  
and we really don't know for sure what is coming. We just have to  
start somewhere.

> They will surely apply to any wimax device, or to a soft wimax stack  
> if
> that should ever happen. And for those commands that don't, it's  
> easy to
> see whether or not a device supports them and use different, possibly
> more generic, ones; say a device doesn't support scanning, it'll  
> surely
> support connecting if you know the network already.
>
> Conceptually, I'm not sure you should call the wimax stack a "stack"  
> at
> all, so far it seems more like a "transport" that really should be  
> part
> of the driver. It's not defining any *wimax* commands, but it's only
> defining the transport for those *driver-specific* commands.
>
> This is the biggest issue I see here. I don't see how the stack helps
> anyone implement a driver for a new device. Sure, they won't have to
> come up with a new transport, write less lines of generic netlink  
> code,
> but ultimately that's not the hard part, the hard part is getting the
> relevant operations right etc.

The idea is to make the WiMAX subsystem more generic and create  
something similar to what we have with mac80211/cfg80211 and also  
inside Bluetooth. This is the common starting point and next step is  
to move functionality that has been identified as generic and common  
from the driver into the subsystem.

I prefer if we do this development inside the kernel tree instead of  
externally. One big thing we should have learned from mac80211 is that  
developing a full stack outside the kernel source tree is not really  
working out. We should apply the same model as we did for ext4 or what  
Greg is doing with his staging tree.

>> So the current abstraction layer provides a low-level WiMAX API with
>> means for resetting, monitoring state changes, controlling rfkill and
>> sending messages to the driver (in a driver specific format) back and
>> forth (more on this below). The documentation in include/net/wimax.h
>> provides more information.
>
> This really means you're putting the actual "driver", the piece that
> does the hardware abstraction, into userspace. And in a binary daemon
> even, afaict. This was quickly shot down with ipw3945/4965, not sure  
> why
> nobody has cared here so far. Maybe because you're actually planning  
> to
> open source that part.

It has been open source since quite some time now at linuxwimax.org  
(exception are some tiny binary pieces).

>> The driver for the 2400m sits below the stack, providing the back end
>> operations to drive control (reset, rfkill, message passing) and
>> feeding it state change information. On the other side, the 2400m
>> driver connects to netdev, where it emulates an ethernet device (*1).
>
> Couldn't the stack provide more functionality here? Somewhere else you
> speak of using ethernet vs. rawip, couldn't the stack do that
> translation, possibly even allowing both rawip and ethernet to  
> coexist,
> or be switchable at runtime if you have a working dhcp client?

Either we do Ethernet framing or a pure IP device. I am for the pure  
IP device with a separate ARP header (which we managed to get  
allocated). Wrapping everything into Ethernet only because dhclient is  
broken is not an answer. An alternate option would be a point-to-point  
device like the HSO driver or PPP is using. However then the usage of  
DHCP becomes a lot more trickier. Don't ask me why WiMAX decided to go  
for DHCP and not did the IP stuff in-band.

Regards

Marcel

