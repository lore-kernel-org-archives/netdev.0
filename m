From: Tom Herbert <tom@herbertland.com>
Subject: Re: Checksum offload queries
Date: Wed, 9 Dec 2015 10:00:52 -0800
Message-ID: <CALx6S34+j0xQk7gfwOa9adBc3fkjhTJG366eDcT81AzKnWCrLA@mail.gmail.com>
References: <5665A848.9010001@solarflare.com>
	<20151207.143848.2158761076110518741.davem@davemloft.net>
	<5666EC4B.40800@solarflare.com>
	<20151208.120654.2127200076257822677.davem@davemloft.net>
	<56681B18.3030200@solarflare.com>
	<CALx6S357W+HXp4S8+tveKrqJ3-2XrZsKmBTvxZVHdwF93UWkOw@mail.gmail.com>
	<566864C0.6020204@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:34119 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752877AbbLISAx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 13:00:53 -0500
Received: by ioir85 with SMTP id r85so68122866ioi.1
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 10:00:53 -0800 (PST)
In-Reply-To: <566864C0.6020204@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 9, 2015 at 9:28 AM, Edward Cree <ecree@solarflare.com> wrote:
> On 09/12/15 16:01, Tom Herbert wrote:
>> On Wed, Dec 9, 2015 at 4:14 AM, Edward Cree <ecree@solarflare.com> > wrote: >> Convincing hardware designers to go the HW_CSUM way and only fill >> in the inner checksum, when their current approach can fill in >> both inner and outer checksums (though admittedly only for the >> protocols the hardware knows about), might be difficult. >> > But again, NETIF_F_IP[V6]_CSUM and NETIF_F_HW_CSUM describe > capabilities._not_ the interface. The interface currently allows only > one checksum to be offloaded at time, if we want to be able to > offload two checksums then the interface needs to be changed-- > probably something like defining a new capability like > NETIF_F_HW_2CSUMS, adding another csum_start,csum_offset pair into > the sk_buff.
> Which only pushes the problem onto when someone wants to nest
> encapsulations.  (I heard you like tunnels, so I put a tunnel in your
> tunnel so you can encapsulate while you encapsulate.)
> Or to put it another way, 2 isn't a number; the only numbers are 0, 1
> and infinity ;)
> Perhaps in practice 2 csums would be enough, for now.  But isn't the
> whole point of the brave new world of generic checksums that it should
> be future-proof?
>
If there is a need then we can add an arbitrary number. But no one has
proven there is a need, however we do have a real need for checksum
offload outside of the narrow uses of  NETIF_F_IP[V6]_CSUM.

>> The stack will need to be modified also wherever CHECKSUM_PARTIAL is > handled.
> Naturally.
>
>> If your device is trying do offload more than one checksum on its own > accord without being asked to do so by the stack it is doing the > wrong thing!
> From the stack's perspective: yes, it is doing the wrong thing.  (I've
> been discussing with colleagues today how we could change that, and I
> think we can, but it involves having _three_ hardware TXQs per kernel
> queue, instead of the two we have now...)
> But from the outside perspective, the system as a whole isn't doing
> anything bad - the packet going on the network is valid and just
> happens to have both inner and outer checksums filled in.  Is there a
> good reason _why_ the stack forbids a device to do this?  (Sure, it's
> not necessary, and makes the hardware more complex.  But the hardware's
> already been made, and it's not a *completely* useless thing to do...)
>
That is not at all true. If the stack has set up VXLAN RCO and the
device decides to set the inner checksum itself then the checksum will
be bad. The checksum interface is very specific please read it
carefully (sk_buff.h), if the driver/device thinks it is smarter than
the stack and tries to do set its own rules on how checksum offload
works then things will eventually break miserably.
