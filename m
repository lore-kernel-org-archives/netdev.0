From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Network cooling device and how to control NIC speed on thermal
 condition
Date: Tue, 25 Apr 2017 09:23:01 -0700
Message-ID: <2c1e823f-29c8-1cf6-4923-ddb1f1e09891@gmail.com>
References: <CAHKzcEMQPQzg6PYCSuv7Ufad+4AZ2gnqMgz3-VH5NTeb_pv4zQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Waldemar Rymarkiewicz <waldemar.rymarkiewicz@gmail.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:34241 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S980647AbdDYQXE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 12:23:04 -0400
In-Reply-To: <CAHKzcEMQPQzg6PYCSuv7Ufad+4AZ2gnqMgz3-VH5NTeb_pv4zQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 04/25/2017 01:36 AM, Waldemar Rymarkiewicz wrote:
> Hi,
> 
> I am not much aware of linux networking architecture so I'd like to
> ask first before will start to dig into the code. Appreciate any
> feedback.
> 
> I am looking on Linux thermal framework and on how to cool down the
> system effectively when it hits thermal condition. Already existing
> cooling methods cpu_cooling and clock_cooling are good. However, I
> wanted to go further and dynamically control also a switch ports'
> speed based on thermal condition. Lowering speed means less power,
> less power means lower temp.
> 
> Is there any in-kernel interface to configure switch port/NIC from other driver?

Well, there is mostly under the form of notifiers though. For instance
there are lots of devices that do converged FCoE/RoCE/Ethernet that have
a two headed set of drivers, one for normal ethernet, and another one
for RDMA/IB for instance. To some extent stacked devices (VLAN, bond,
team, etc.) also call back down into their lower device, but in an
abstracted way, at the net_device level of course (layering).

> 
> Is there any mechanism to power save, when port/interface is not
> really used (not much or low data traffic), embedded in networking
> stack  or is it a task for NIC driver itself ?

The thing we did (currently out of tree) in the Starfighter 2 switch
driver (drivers/net/dsa/bcm_sf2.c) is that any time a port is brought
up/down (a port = a network device) we recalculate the switch core
clock, and we also resize the buffers and that yields to a little bit of
power savings  here and there. I don't recall the numbers from the top
of my head, but it was significant enough our HW designers convinced me
into doing it ;)

> 
> I was thinking to create net_cooling device similarly to cpu_cooling
> device which cool down the system scaling down cpu freq.  net_cooling
> could lower down interface speed (or tune more parameters to achieve
> ).  Do you thing could this work form networking stack perspective?

This sounds like a good idea, but it could be very tricky to get right,
because even if you can somehow throttle your transmit activity (since
the host is in control), you can't do that without being disruptive to
the receive path (or not as effectively).

Unlike any kind of host driven activity: CPU run queue, block devices,
USB etc. (SPI, I2C and so on when no using slave driven interrupts) you
cannot simply apply a "duty cycle" pattern where you turn on your HW
just enough of time that is needed for you to set it up for transfer,
signal transfer completion and go back to sleep. Networking needs to be
able to asynchronously receive packets in a way that is usually not
predictable although it could be for very specific workloads though.

Another thing is that there is still a fair amount of energy that needs
to be spent in maintaining the link, and the HW design may be entirely
clocked based on the link speed. Depending on the HW architecture (store
and forward, cut through etc.) there would still be a cost associated
with maintaining RAMs in a state where they are operational and so on.

You could imagine writing a queuing discipline driver that would
throttle transmission based on temperature sensors present in your NIC,
you could definitively do this in a way that is completely device driver
agnostic by using Linux's thermal framework trip point and temperature
notifications.

For reception, if you are okay with dropping some packets, you could
implement something similar, but chances are that your NIC would still
need to receive packets, be able to fully process them before SW drops
them, at which point, you have a myriad of solutions about how not to
process incoming traffic.

Hope this helps

> 
> Any pointers  to the code or a doc highly appreciated.
> 
> Thanks,
> /Waldek
> 


-- 
Florian
