From: Gary Thomas <gary@mlbassoc.com>
Subject: Re: Marvell 88E609x switch?
Date: Fri, 27 Feb 2009 05:42:40 -0700
Message-ID: <49A7DFC0.9050601@mlbassoc.com>
References: <49A49C06.90908@mlbassoc.com> <20090225131550.GA24996@xi.wantstofly.org> <49A5B877.8080403@mlbassoc.com> <20090226151107.GN17040@xi.wantstofly.org> <49A6B991.2090703@mlbassoc.com> <20090226155726.GO17040@xi.wantstofly.org> <49A73E00.7050406@mlbassoc.com> <20090227011903.GS17040@xi.wantstofly.org> <49A7DBA2.8060605@mlbassoc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 137-67-76-76.skybeam.com ([76.76.67.137]:5571 "EHLO
	mail.chez-thomas.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751626AbZB0Mmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 07:42:54 -0500
In-Reply-To: <49A7DBA2.8060605@mlbassoc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gary Thomas wrote:
> Lennert Buytenhek wrote:
>> On Thu, Feb 26, 2009 at 06:12:32PM -0700, Gary Thomas wrote:
>>
>>>>>>>>> Is there support for this device anywhere?  In particular,
>>>>>>>>> the M88E6095 switch.
>>>>>>>> Not at the moment, but it should be easy enough to add.  If your
>>>>>>>> board already runs on 2.6.28+, I can whip up some patches for you
>>>>>>>> to try from the docs I have for that part.
>>>>>>> That would be much appreciated, thanks.
>>>>>> I noticed that the 6095/6095F are quite similar to the 6131 as far
>>>>>> as the register set goes.  So something along these lines (hacky
>>>>>> patch, breaks 6131, not for mainline) might just work to detect
>>>>>> single 6095s (cascading DSA chips is something that needs more work,
>>>>>> let's get the single-chip case working first).
>>>>>>
>>>>>> The other thing you'll need to do is create dsa platform devices
>>>>>> for your switch chips, a la how it's done in arch/arm/mach-orion5x/
>>>>>> or arch/arm/mach-kirkwood/ for example -- you need to pass in a struct
>>>>>> device * for your network device, a struct device * for your mii bus,
>>>>>> the switch MII address on the MII bus, and names of the individual
>>>>>> ports (where you'll specify "cpu" for the port on the switch chip that
>>>>>> the CPU is connected to).
>>>>>>
>>>>>> Let me know if this works.
>>>>> Thanks, I'll give it a try.  It will take a little effort
>>>>> to get setup as I have to work within the open firmware
>>>>> structure (that's how all the various components are
>>>>> specified).
>>>> Right, we don't have OF bindings yet.  I guess this would make sense
>>>> to do generically at some point, since there are quite a few PPC
>>>> platforms with DSA switch chips.
>>> Here's what I tried - (patch attached) - a trulyhorrible hack,
>>> but I've not figured out how to get the correct device pointers
>>> from the OF world yet.  The boot log shows that it's trying, but
>>> I don't see the DSA layer (M88E690x driver) doing the MII indirection
>>> that's needed for this device.
>>>
>>> I'm probably not starting it up correctly, but I think I followed
>>> the examples you cited.  Any ideas?
>> "indirection needed for this device" -- does that mean that your
>> switch chip is configured to use the multi-chip addressing mode?
>> (It looks like it, as most of the MII addresses return ffff in
>> their ID registers.)  If yes, you should set ->sw_addr to whatever
>> MII address the chip has been assigned.
> 
> Much better, my switch seems to be found now.
> 
>   Distributed Switch Architecture driver version 0.1
>   gfar_mdio_read(cf9db400, 1, 0) = 1811
>   gfar_mdio_write(cf9db400, 1, 0, 9a03) = 0
>   gfar_mdio_read(cf9db400, 1, 0) = 1a03
>   gfar_mdio_read(cf9db400, 1, 1) = 953
>   mv88e6131_probe(cf9db400, 1) = 2387
>   eth0: detected a Marvell 88E6095/88E6095F switch
>      ...
>   root@ppc_target:~ ls /sys/bus/mdio_bus/devices/
>   24520:01:00  24520:01:02  24520:01:04  24520:01:06
>   24520:01:01  24520:01:03  24520:01:05  24520:01:07
> 
> However, the network subsystem still can't locate it.  It may be
> a complication of the OF stuff and how the [gianfar] network
> device knows what PHY to look at.
> 
>   starting network interfaces...
>   24520:01 not found
>   eth0: Could not attach to PHY
> 
> Also, how do I specify the [implicit] route within the switch
> that connects '24520:01:00' to the CPU port '24520:01:0A' (if
> there was such a thing)?  My boot loader has configured the
> switch for this path - I've not looked through the log to see
> what the DSA layer did.
> 
> Thanks for your help
> 

Trying the simple/obvious did not work so well:
  Distributed Switch Architecture driver version 0.1
  mv88e6131_probe(cf9db400, 1) = 2387
  eth0: detected a Marvell 88E6095/88E6095F switch
  dsa slave smi: probed
  lan1.2: 24520:01:00 already attached
  Unable to handle kernel paging request for data at address 0x00000024
  Faulting instruction address: 0xc019e584
  Oops: Kernel access of bad area, sig: 11 [#1]
  ASP8347E
  Modules linked in:
  NIP: c019e584 LR: c019e570 CTR: c018a734
  REGS: cf821c40 TRAP: 0300   Not tainted  (2.6.28-svn4872-dirty)
  MSR: 00009032 <EE,ME,IR,DR>  CR: 22000024  XER: 20000000
  DAR: 00000024, DSISR: 20000000
  TASK = cf81f900[1] 'swapper' THREAD: cf820000
  GPR00: 00000001 cf821cf0 cf81f900 cf9ff200 00001697 ffffffff c018aeec 00004000
  GPR08: 00000001 00000000 00003fff cf9ff200 82000022 7e700000 00050000 00019edc
  GPR16: fffffffd 00050000 00043514 00044320 000434e8 c0362e88 c02f8f9c cf854800
  GPR24: cf8549c0 00000001 00000001 c0362e88 cf854800 cf9ff3b8 cf9f9b80 cf9ff200
  NIP [c019e584] phy_start_aneg+0x34/0xcc
  LR [c019e570] phy_start_aneg+0x20/0xcc
  Call Trace:
  [cf821cf0] [c019ff0c] phy_attach+0x140/0x148 (unreliable)
  [cf821d10] [c025ae3c] dsa_slave_create+0x16c/0x1ac
  [cf821d30] [c025aa9c] dsa_probe+0x428/0x454
  [cf821d70] [c0193cc4] platform_drv_probe+0x20/0x30
  [cf821d80] [c0192ae0] driver_probe_device+0xb4/0x1e8
  [cf821da0] [c0192cb8] __driver_attach+0xa4/0xa8
  [cf821dc0] [c0192278] bus_for_each_dev+0x5c/0xa4
  [cf821df0] [c01928fc] driver_attach+0x24/0x34
  [cf821e00] [c0191b90] bus_add_driver+0x1d8/0x24c
  [cf821e20] [c0192ed8] driver_register+0x70/0x160
  [cf821e40] [c0193f94] platform_driver_register+0xac/0xbc
  [cf821e50] [c0339828] dsa_init_module+0x18/0x28
  [cf821e60] [c0003874] do_one_initcall+0x38/0x194
  [cf821fc0] [c031a178] kernel_init+0x94/0x100
  [cf821ff0] [c0010df8] kernel_thread+0x4c/0x68

Ideas?

-- 
------------------------------------------------------------
Gary Thomas                 |  Consulting for the
MLB Associates              |    Embedded world
------------------------------------------------------------
