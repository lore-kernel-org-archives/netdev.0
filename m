From: Gary Thomas <gary@mlbassoc.com>
Subject: Re: Marvell 88E609x switch?
Date: Fri, 27 Feb 2009 06:27:25 -0700
Message-ID: <49A7EA3D.8070800@mlbassoc.com>
References: <49A5B877.8080403@mlbassoc.com> <20090226151107.GN17040@xi.wantstofly.org> <49A6B991.2090703@mlbassoc.com> <20090226155726.GO17040@xi.wantstofly.org> <49A73E00.7050406@mlbassoc.com> <20090227011903.GS17040@xi.wantstofly.org> <49A7DBA2.8060605@mlbassoc.com> <49A7DFC0.9050601@mlbassoc.com> <20090227125305.GW17040@xi.wantstofly.org> <49A7E87D.5090203@mlbassoc.com> <20090227132319.GY17040@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 137-67-76-76.skybeam.com ([76.76.67.137]:5946 "EHLO
	mail.chez-thomas.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1757221AbZB0N1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 08:27:41 -0500
In-Reply-To: <20090227132319.GY17040@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert Buytenhek wrote:
> On Fri, Feb 27, 2009 at 06:19:57AM -0700, Gary Thomas wrote:
> 
>>>>>>>>>>>>> Is there support for this device anywhere?  In particular,
>>>>>>>>>>>>> the M88E6095 switch.
>>>>>>>>>>>> Not at the moment, but it should be easy enough to add.  If your
>>>>>>>>>>>> board already runs on 2.6.28+, I can whip up some patches for you
>>>>>>>>>>>> to try from the docs I have for that part.
>>>>>>>>>>> That would be much appreciated, thanks.
>>>>>>>>>> I noticed that the 6095/6095F are quite similar to the 6131 as far
>>>>>>>>>> as the register set goes.  So something along these lines (hacky
>>>>>>>>>> patch, breaks 6131, not for mainline) might just work to detect
>>>>>>>>>> single 6095s (cascading DSA chips is something that needs more work,
>>>>>>>>>> let's get the single-chip case working first).
>>>>>>>>>>
>>>>>>>>>> The other thing you'll need to do is create dsa platform devices
>>>>>>>>>> for your switch chips, a la how it's done in arch/arm/mach-orion5x/
>>>>>>>>>> or arch/arm/mach-kirkwood/ for example -- you need to pass in a struct
>>>>>>>>>> device * for your network device, a struct device * for your mii bus,
>>>>>>>>>> the switch MII address on the MII bus, and names of the individual
>>>>>>>>>> ports (where you'll specify "cpu" for the port on the switch chip that
>>>>>>>>>> the CPU is connected to).
>>>>>>>>>>
>>>>>>>>>> Let me know if this works.
>>>>>>>>> Thanks, I'll give it a try.  It will take a little effort
>>>>>>>>> to get setup as I have to work within the open firmware
>>>>>>>>> structure (that's how all the various components are
>>>>>>>>> specified).
>>>>>>>> Right, we don't have OF bindings yet.  I guess this would make sense
>>>>>>>> to do generically at some point, since there are quite a few PPC
>>>>>>>> platforms with DSA switch chips.
>>>>>>> Here's what I tried - (patch attached) - a trulyhorrible hack,
>>>>>>> but I've not figured out how to get the correct device pointers
>>>>>>> from the OF world yet.  The boot log shows that it's trying, but
>>>>>>> I don't see the DSA layer (M88E690x driver) doing the MII indirection
>>>>>>> that's needed for this device.
>>>>>>>
>>>>>>> I'm probably not starting it up correctly, but I think I followed
>>>>>>> the examples you cited.  Any ideas?
>>>>>> "indirection needed for this device" -- does that mean that your
>>>>>> switch chip is configured to use the multi-chip addressing mode?
>>>>>> (It looks like it, as most of the MII addresses return ffff in
>>>>>> their ID registers.)  If yes, you should set ->sw_addr to whatever
>>>>>> MII address the chip has been assigned.
>>>>> Much better, my switch seems to be found now.
>>>>>
>>>>>   Distributed Switch Architecture driver version 0.1
>>>>>   gfar_mdio_read(cf9db400, 1, 0) = 1811
>>>>>   gfar_mdio_write(cf9db400, 1, 0, 9a03) = 0
>>>>>   gfar_mdio_read(cf9db400, 1, 0) = 1a03
>>>>>   gfar_mdio_read(cf9db400, 1, 1) = 953
>>>>>   mv88e6131_probe(cf9db400, 1) = 2387
>>>>>   eth0: detected a Marvell 88E6095/88E6095F switch
>>>>>      ...
>>>>>   root@ppc_target:~ ls /sys/bus/mdio_bus/devices/
>>>>>   24520:01:00  24520:01:02  24520:01:04  24520:01:06
>>>>>   24520:01:01  24520:01:03  24520:01:05  24520:01:07
>>>>>
>>>>> However, the network subsystem still can't locate it.  It may be
>>>>> a complication of the OF stuff and how the [gianfar] network
>>>>> device knows what PHY to look at.
>>>>>
>>>>>   starting network interfaces...
>>>>>   24520:01 not found
>>>>>   eth0: Could not attach to PHY
>>>>>
>>>>> Also, how do I specify the [implicit] route within the switch
>>>>> that connects '24520:01:00' to the CPU port '24520:01:0A' (if
>>>>> there was such a thing)?  My boot loader has configured the
>>>>> switch for this path - I've not looked through the log to see
>>>>> what the DSA layer did.
>>>>>
>>>>> Thanks for your help
>>>> Trying the simple/obvious did not work so well:
>>>>   Distributed Switch Architecture driver version 0.1
>>>>   mv88e6131_probe(cf9db400, 1) = 2387
>>>>   eth0: detected a Marvell 88E6095/88E6095F switch
>>>>   dsa slave smi: probed
>>>>   lan1.2: 24520:01:00 already attached
>>>>   Unable to handle kernel paging request for data at address 0x00000024
>>> What did you do here?
>> I just tried to force it by making it probe '24520:01:00'
>> instead of '24520:01'
>>
>>> Also, can you show me what you're filling the dsa platform data
>>> structure with?
>> struct dsa_platform_data _switch_data = {
>>     .port_names[0]  = "lan1.1",
>>     .port_names[1]  = "lan1.2",
>>     .port_names[2]  = "lan1.3",
>>     .port_names[3]  = "lan1.4",
>>     .port_names[4]  = "lan1.5",
>>     .port_names[5]  = "lan1.6",
>>     .port_names[6]  = "lan1.7",
>>     .port_names[7]  = "lan1.8",
>>     .port_names[10]  = "cpu",
>>     .sw_addr = 1,
>> };
> 
> Just this should do the trick.  So what's not working -- are the
> interfaces not showing up?  Or packet RX/TX isn't working?  Or
> something else?

It won't let me bring up eth0 (my scripts try to run DHCP):
  starting network interfaces...
  24520:01 not found
  eth0: Could not attach to PHY
  ip: SIOCSIFFLAGS: No such device

As for the other devices, they do show up if I let eth0 try to
attach to the PHY:

root@ppc_target:~ cat /proc/net/dev
Inter-|   Receive                                                |  Transmit
 face |bytes    packets errs drop fifo frame compressed multicast|bytes    packets errs drop fifo colls carrier compresse
d
    lo:       0       0    0    0    0     0          0         0        0       0    0    0    0     0       0
0
  eth0:       0       0    0    0    0     0          0         0        0       0    0    0    0     0       0
0
  eth1:       0       0    0    0    0     0          0         0        0       0    0    0    0     0       0
0
lan1.1:       0       0    0    0    0     0          0         0        0       0    0    0    0     0       0
0
lan1.2:       0       0    0    0    0     0          0         0        0       0    0    0    0     0       0
0
lan1.3:       0       0    0    0    0     0          0         0        0       0    0    0    0     0       0
0
lan1.4:       0       0    0    0    0     0          0         0        0       0    0    0    0     0       0
0
lan1.5:       0       0    0    0    0     0          0         0        0       0    0    0    0     0       0
0
lan1.6:       0       0    0    0    0     0          0         0        0       0    0    0    0     0       0
0
lan1.7:       0       0    0    0    0     0          0         0        0       0    0    0    0     0       0
0
lan1.8:       0       0    0    0    0     0          0         0        0       0    0    0    0     0       0
0

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
------------------------------------------------------------
Gary Thomas                 |  Consulting for the
MLB Associates              |    Embedded world
------------------------------------------------------------
