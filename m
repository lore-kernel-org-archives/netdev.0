From: Martin Fuzzey <mfuzzey@gmail.com>
Subject: Re: [RFC PATCH] Ethtool style in kernel network driver configuration.
Date: Sun, 14 Jun 2009 20:39:58 +0200
Message-ID: <4A3543FE.2010500@gmail.com>
References: <ba4215e10906120519o35358caducfdd253c9f8d8bd2@mail.gmail.com>	<20090612.170128.213931980.davem@davemloft.net>	<4A334E7A.5020805@gmail.com> <20090613.000729.118500646.davem@davemloft.net>
Reply-To: mfuzzey@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, nico@cam.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:63013 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754900AbZFNSkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jun 2009 14:40:03 -0400
Received: by ewy6 with SMTP id 6so4420794ewy.37
        for <netdev@vger.kernel.org>; Sun, 14 Jun 2009 11:40:04 -0700 (PDT)
In-Reply-To: <20090613.000729.118500646.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Martin Fuzzey <mfuzzey@gmail.com>
> Date: Sat, 13 Jun 2009 09:00:10 +0200
>
>   
>> But please reply to the rest of that message, in particular explain why,
>> having publicly stated you would accept an implementation of Nicolas'
>> idea, you are now back pedaling.
>>     
>
> I misunderstood the problem, thanks for asking me to clarify
> this.
>
> I thought the issue was the "in the environment where his devices
> would be used" he wanted to force a certain link speed and duplex
> setting.  In that case, forcing the link via ethtool is appropriate
> because it's an attribute of where the device is connected.
>
> But the situation is different, the physical hardware has a limitation
> and know of this belongs, or should be described, in the driver
> somehow.
>   
Actually it's both.
I think you are mixing up the problem _I_ am having (on my broken board)
and the range of problems _this patch_ is intended to address.

As is explained in the patch header the patch allows unmodified network
drivers to be configured using their ethtool interface in _two_ manners :

1) From the kernel command line
2) From kernel code (typically the board setup code)

Maybe however I didn't make the different use cases of these two methods
sufficiently clear.

_Command line configuration_

This is _not_ intended to be used to work around broken hardware but
indeed to be used to configure the device for the network environment in
which it will be used when autonegotiation cannot be used for some
reason. This is thus the same use case as userspace ethtool.

The kernel already has command line configuration for the IP layer
(static IP address, DHCP etc) so this can just be viewed as extending
this to a lower layer in the network stack.

All of this (both the link layer and the IP configuration) _could _ be
done from userspace initram FS or whatever but in embedded situations it
really is very useful to be able to do it from the kernel command line.
While I have never used this facility on workstations or servers I use
it on embedded boards _every day_ (and I suspect the same holds form
many / most embedded developpers). Note that were command line
configuration for the IP layer not available the NFS root + static IP
case would be particularly awkward to handle (as it would require a
different initramfs for every board to ensure unique IPs).

A concrete usecase for this is when a (fully working) device supporting
with 10/100 link speeds needs to be forced to a lower speed for testing
purposes [for example because it will be deployed to a site only having
a 10Mbps network but it needs to be tested in the lab with a simple
10/100 non manageable switch].

The users of this facility are not necesarilly developpers but could be
testers etc (as all they need to do is change a parameter in the boot
loader).


_ programmatic interface _

This method is intended to work around broken _boards_ (not drivers -
which should of course be fixed, nor _chips_ which should be
disactivated in the driver).

It enables the developper of the board setup code to force certain link
parameters.
In this manner the board setup code centralises knowledge about the
board (GPIOs, chip addresses, and any networking workarounds required).

Since it is called from code:

1) It is indeed a case of kernel _code_ not configuration doing the work
around
2) The activation of the workaround may be conditional (for example
based on reading the board revision number from hardware)


The patch allows the kernel to be configured with just one or both of
these methods as desired. For example on my broken board I am only using
the programmatic method at the moment (after testing the command line
method of course).

Hope this clarifies things.

Martin

