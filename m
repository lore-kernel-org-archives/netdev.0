From: James Chapman <jchapman@katalix.com>
Subject: Re: Network device driver with PPP
Date: Sat, 01 Mar 2008 12:08:48 +0000
Message-ID: <47C94750.8060006@katalix.com>
References: <3415E2A2AB26944B9159CDB22001004D024DA732@nestea.sierrawireless.local> <1204164955.26292.5.camel@localhost.localdomain> <47C67E67.70604@katalix.com> <3415E2A2AB26944B9159CDB22001004D024DA7DC@nestea.sierrawireless.local> <47C81E9C.4050903@katalix.com> <3415E2A2AB26944B9159CDB22001004D0252D1B7@nestea.sierrawireless.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org
To: Kevin Lloyd <klloyd@sierrawireless.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:33140 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755149AbYCAMI4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Mar 2008 07:08:56 -0500
In-Reply-To: <3415E2A2AB26944B9159CDB22001004D0252D1B7@nestea.sierrawireless.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kevin Lloyd wrote:
> James Chapman wrote:
>>> Actually we provide a method for the driver to obtain the
>>> username/password information needed for the CHAP authentication so
> in
>>> theory the driver has the information needed to create the
> connection.
>>> I'm not sure how it would go about setting the DNS and IP addresses,
> but
>>> that's a separate issue further down the road.
>> Can you explain why you need the driver to be involved in any of this?
> I'm trying to evaluate what level of consistency can be maintained for
> our drivers across operating systems and whether there is precedence for
> such a design. Looking like it's not going to happen...

If your goal is to have your driver submitted upstream, it needs to fit 
the Linux infrastructure. Use existing kernel subsystems where they 
exist. Avoid OS abstraction wrappers too.

>> Control protocols live in userspace, datapath in the kernel.
> Okay. I have a question about the datapath actually: If I have a serial
> device and I establish a connection with pppd does it configure the
> generic ppp driver to talk to the ttyUSBx port and then route the
> control (e.g. NCP and LCP) packets to /dev/ppp for control by pppd and
> the data (IP) packets somewhere else? 

It depends.

pppd creates a ppp network interface. This is exactly the same as all 
other network interfaces in the system (eth0 etc) in that data packets 
pass from/to the device to/from the kernel network subsystems. Data 
packets arriving on your PPP interface can be delivered without any 
involvement from pppd.

If the PPP packet is to be encapsulated (e.g. PPPoATM, PPPoE) then 
things are more complicated. A kernel device driver does the 
encapsulation (drivers/net/pppoatm.c, drivers/net/pppoe.c) and a pppd 
plugin interfaces with that driver in order to send/receive PPP control 
packets. The kernel's ppp core separates PPP control and data packets.

However, some protocols don't have a pppox driver or corresponding 
userspace pppd plugin (e.g. PPTP). In these cases, pppd uses pseudo tty 
devices and copies data packets to/from it in userspace. Data packets 
are delivered to a pppd "data pump" which inserts or removes the 
encapsulation before passing it on. This can be quicker to implement but 
is obviously suboptimal because userspace copies all data and does all 
the protocol encapsulation/decapsulation work.

> Also is it pppd that directly sets
> up the network interface in ifconfig? I'm a little confused/lost here...

Yes. Though ifconfig is just one userspace app that can list network 
devices.

>> Can't you implement a private interface to your kernel driver so that
>> userspace can ask it for the username/password and userspace then
> starts
>> pppd with those parameters?
> Yes I suppose I could do that, how would you recommend approaching this,
> ioctl?

It depends on your device driver. If it can have a private driver ioctl 
handler, ioctl is simplest.

> Also, is Documentation\networking\ppp_generic.txt up-to-date (says
> edited 2002) or is there a better resource explaining ppp architecture
> on Linux?

The PPP APIs have been stable for a long time.


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

