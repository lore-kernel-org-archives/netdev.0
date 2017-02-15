From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC 2/2] net: emac: add support for device-tree based PHY
 discovery and setup
Date: Tue, 14 Feb 2017 16:24:01 -0800
Message-ID: <6e08f766-8651-09a6-09f8-42cf7997770c@gmail.com>
References: <f57a340f615991ed2771d8af4b1a908dec436a5e.1486333475.git.chunkeey@googlemail.com>
 <d696cd93-120d-e23f-3cce-5c3b64c7dc31@gmail.com>
 <2122984.F6mzWerJKz@debian64> <2409103.Lage0nq55N@debian64>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Christian Lamparter <chunkeey@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Ivan Mikhaylov <ivan@de.ibm.com>,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33744 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750943AbdBOAYF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 19:24:05 -0500
Received: by mail-it0-f65.google.com with SMTP id e137so8135993itc.0
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2017 16:24:04 -0800 (PST)
In-Reply-To: <2409103.Lage0nq55N@debian64>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/14/2017 04:16 PM, Christian Lamparter wrote:
> On Tuesday, February 14, 2017 12:38:42 AM CET Christian Lamparter wrote:
>>>>>> diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
>>>>>> --- a/drivers/net/ethernet/ibm/emac/core.c
>>>>>> +++ b/drivers/net/ethernet/ibm/emac/core.c
>>>>>> @@ -2420,6 +2421,179 @@ static int emac_read_uint_prop(struct device_node *np, const char *name,
>>>>>> [...] 
>>>>>> +static int emac_mii_bus_reset(struct mii_bus *bus)
>>>>>> +{
>>>>>> +	struct emac_instance *dev = netdev_priv(bus->priv);
>>>>>> +
>>>>>> +	emac_mii_reset_phy(&dev->phy);
>>>>>
>>>>> This seems wrong, emac_mii_reset_phy() does a BMCR software reset, which
>>>>> PHYLIB is already going to do (phy_init_hw), yet you do this here at the
>>>>> MDIO bus level towards a specify PHY, whereas this should be affecting
>>>>> the MDIO bus itself (and/or *all* PHY child devices for quirks).
>>>> Ah, this is a good point. The emac driver has a emac_reset() function
>>>> that does disable and enabled the phy clocks. That said, this is already
>>>> done by the emac driver during init too. So if I added it, the bus is
>>>> reset twice (since it doesn't hurt - I added it back).
>>>>
>>>> The emac_mii_phy_reset() was added because of the Meraki MX60(W).
>>>> This is because Cisco's bootloader disables the switch port 
>>>> (probably to prevent WAN<->LAN leakage during boot)
>>>>
>>>> [bootlog from the MX60(W)]
>>>> |Disabling port 0
>>>> |Disabling port 1
>>>> |Disabling port 2
>>>> |Disabling port 3
>>>> |ENET Speed is 1000 Mbps - FULL duplex connection (EMAC0)
>>>>
>>>> Without emac_mii_reset_phy(), the mdiobus_scan() function, which
>>>> is called by mdiobus_register will fail with -ENODEV.
>>>> | /plb/opb/ethernet@ef600c00: failed to attach dt phy (-19).
>>>> This is because get_phy_id() will "mostly read mostly Fs" and abort.
>>>
>>> Is the PHY just powered down by chance (BMCR_PWRDN set?) and resetting
>>> it implicitly clears the power down that seems to be what is going on.
>>
>> Yes, the PHY is just in the BMCR_PDOWN state. I can do the same
>> on the WNDR4700, by messing with u-boot:
>>
>> | => mii write 0 0 0x0800
>> | => mii dump
>> | 0.     (ffff)                 -- PHY control register --
>> |  (8000:8000) 0.15    =     1    reset
>> |  (4000:4000) 0.14    =     1    loopback
>> |  (2040:2040) 0. 6,13 =   b11    speed selection = ??? Mbps
>> |  (1000:1000) 0.12    =     1    A/N enable
>> |  (0800:0800) 0.11    =     1    power-down
>> |  (0400:0400) 0.10    =     1    isolate
>> |  (0200:0200) 0. 9    =     1    restart A/N
>> |  (0100:0100) 0. 8    =     1    duplex = full
>> |  (0080:0080) 0. 7    =     1    collision test enable
>> |  (003f:003f) 0. 5- 0 =    63    (reserved)
>>
>> On the Meraki, the port disabled by the bootloader. 
>> The reset is still needed.
>>
>>> Keep in mind that MDIO address 16 is the switch's pseudo PHY address
>>> here, so if you are telling PHYLIB to probe for that address and you
>>> don't get the expected MII_PHYSID1/2 value in return, that usually means
>>> that there was a PHY fixup registered to intercept these reads and make
>>> us return the switch's unique identifier. Reading from the switch's
>>> pseudo PHY at address 16 registers 2/3 (MII_PHYSID1/2) is not guaranteed
>>> to return the switch's unique identifer.
>>>
>>> With a MDIO device driver this won't happen because you will be probed
>>> by address, and you can read any switch register you want to and from
>>> there move on with the initialization.
>>>
>>>>
>>>>
>>>> With emac_mii_reset_phy() in place, it gets detected:
>>>> | switch0: Atheros AR8327 rev. 4 switch registered on emac_mdio
>>>>
>>>> Furthermore, this is probably not the only device which need it.
>>>> Currently, emac's own phy.c code does call emac_mii_reset_phy() 
>>>> as well as part of its probe procedure.
>>>> <http://lxr.free-electrons.com/source/drivers/net/ethernet/ibm/emac/phy.c#L522>
>>>>
>>>> Ideally, we would like to reset only the ports which are registered in the DT.
>>>
>>> Which you would get for free if you did extend qca8k to support the
>>> 8327, because qca8k does implicitly tell the DSA layer to register a
>>> dsa_slave_mii_bus which will probe and attach to per-port built-in PHYs
>>> and that happens only for the ports enabled on your specific board.
>> No, the Meraki and the modified WNDR4700 still refuse to work. Just >one<
>> of the phys at address 0-4 need to be powered down to get the following
>> error:
>> [    4.425618] DSA: switch 0 0 parsed
>> [    4.429034] DSA: tree 0 parsed
>> [    4.435416] qca8k: probe of 4ef600c00.ethern:10 failed with error -5
>>
>> I'll report back, what exactly is causing the error in this case.
> Ok, the -EIO error is coming from this line:
> <http://lxr.free-electrons.com/source/drivers/net/phy/phy_device.c?v=4.9#L496>
> 
> get_phy_id() gets called as part of mdiobus_register() in dsa_ds_apply()
> <http://lxr.free-electrons.com/source/net/dsa/dsa2.c?v=4.9#L322> which is
> called as part of the dsa_switch_register().
> 
> So, is there a good place to reset the switch/ports? Sure,
> doing it in qca8k has the advantage that we know it's 5 ports.
> However, I'm wondering, if the dsa or phy driver the right
> place for this?
> 
> Note: behind the mdiobus_read() at 
> <http://lxr.free-electrons.com/source/drivers/net/phy/phy_device.c?v=4.9#L494>
> is emac's emac_mdio_read does returning -EREMOTEIO. I don't see that hiding
> the error code behind a return 0xffff will help much:
> ---
> For example I disabled just phy2:
> | Generic PHY 4ef600c00.ethern:00: attached PHY driver [Generic PHY] (mii_bus:phy_addr=4ef600c00.ethern:00, irq=-1)
> | Generic PHY dsa-0.0:01: attached PHY driver [Generic PHY] (mii_bus:phy_addr=dsa-0.0:01, irq=-1)
> | qca8k 4ef600c00.ethern:10 lan2: no phy at 2
> | qca8k 4ef600c00.ethern:10 lan2: failed to connect to phy2: -19
> | emac 4ef600c00.ethernet eth0: error -19 setting up slave phy
> | qca8k 4ef600c00.ethern:10: Failed to create slave 3: -19
> | Generic PHY dsa-0.0:03: attached PHY driver [Generic PHY] (mii_bus:phy_addr=dsa-0.0:03, irq=-1)
> | Generic PHY dsa-0.0:04: attached PHY driver [Generic PHY] (mii_bus:phy_addr=dsa-0.0:04, irq=-1)
> 
> And as a result: the switch "lost" the port.
> 
> When I tried to unbind the "faulty" switch in order to reset it
> and rebind:
> 
> root@LEDE:/sys/bus/mdio_bus/drivers/qca8k# echo 4ef600c00.ethern:10 > unbind 
> [ 2435.970104] Unable to handle kernel paging request for data at address 0x00000050
> [ 2435.977580] Faulting instruction address: 0xc0359ae8
> [ 2435.982532] Oops: Kernel access of bad area, sig: 11 [#1]
> [ 2435.987901] WNDR4700 Platform
> [ 2436.116263] CPU: 0 PID: 663 Comm: ash Not tainted 4.9.8 #0
> [ 2436.121729] task: cf974000 task.stack: ce42a000
> [ 2436.126238] NIP: c0359ae8 LR: c036a534 CTR: c029b338
> [ 2436.131180] REGS: ce42bd10 TRAP: 0300   Not tainted  (4.9.8)
> [ 2436.136811] MSR: 00029000 <CE,EE,ME>[ 2436.140260]   CR: 24002288  XER: 00000000
> [ 2436.144251] DEAR: 00000050 ESR: 00000000 
> GPR00: c036a534 ce42bdc0 cf974000 cfb02800 c03f5553 00000000 cf9e19e0 00000001 
> GPR08: cf9e1b00 00000040 00000000 00000001 00780100 00000000 00000000 00000000 
> GPR16: 00000000 00000000 10060000 1005cf90 b79a2495 1005cf70 b7a354c4 00000000 
> GPR24: cfaf2508 00000001 cfaf24fc cfffbca8 cfaf228c 00000003 cfaf2400 cfb02800 
> NIP [c0359ae8] dsa_slave_destroy+0x28/0x78
> [ 2436.180491] LR [c036a534] dsa_dst_unapply.part.7+0xa4/0xb70
> [ 2436.186033] Call Trace:
> [ 2436.188475] [ce42bdc0] [c0359c48] dsa_port_is_cpu+0x1c/0x50 (unreliable)
> [ 2436.195161] [ce42bdd0] [c036a534] dsa_dst_unapply.part.7+0xa4/0xb70
> [ 2436.201409] [ce42be00] [c0359d60] dsa_unregister_switch+0x3c/0x60
> [ 2436.207485] [ce42be20] [c0238a18] mdio_remove+0x24/0x40
> [ 2436.212701] [ce42be30] [c01c6544] __device_release_driver+0xa4/0x13c
> [ 2436.219034] [ce42be40] [c01c6604] device_release_driver+0x28/0x40
> [ 2436.225107] [ce42be50] [c01c4c94] unbind_store+0x6c/0xac
> [ 2436.230417] [ce42be70] [c00f8838] kernfs_fop_write+0x128/0x1ac
> [ 2436.236247] [ce42be90] [c00a8ce4] __vfs_write+0x28/0x134
> [ 2436.241542] [ce42bef0] [c00a9a00] vfs_write+0xd0/0x17c
> [ 2436.246665] [ce42bf10] [c00aa758] SyS_write+0x4c/0xa4
> [ 2436.251705] [ce42bf40] [c000a848] ret_from_syscall+0x0/0x3c
> [ 2436.257266] --- interrupt: c01 at 0xb7a0edc0
> [ 2436.257266]     LR = 0xb7a00df0
> [ 2436.264631] Instruction dump:
> [ 2436.267597] 38210030 4e800020 7c0802a6 9421fff0 bfc10008 7c7f1b78 90010014 892304e8 
> [ 2436.275397] 814304e4 39290004 55292036 7d2a4a14 <83c90010> 4bf46641 807f04ec 2f830000 
> [ 2436.283367] ---[ end trace e5787cb2a55a0fbd ]---
> [ 2436.289726] 
> [ 2437.291295] Kernel panic - not syncing: Fatal exception
> 
> The panic is caused by dsa_slave_create() not clearing the dangling
> ds->ports[port].netdev pointer. The function dsa_user_port_unapply()
> relies on it being NULL in order to skip unregistered entries.

Fixed that just recently:

https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=382e1eea2d983cd2343482c6a638f497bb44a636

and I am currently in the process of making the bind/unbind working
(without having the PHY detached from the network device), but that's a
stretch, and requires a ton of mucking around with driver references,
current state machine state, target state machine state etc...

Candidate patches for that are located here if you want:

https://github.com/ffainelli/linux/commit/e7e99a9ab998952b9f18e6e396779bb58626e9a5
https://github.com/ffainelli/linux/commit/e005be050cd876189f39c5a89fffa70ee8d6c512

> ---
> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> index 09fc3e9462c1..0dae29eb95d6 100644
> --- a/net/dsa/slave.c
> +++ b/net/dsa/slave.c
> @@ -1460,6 +1460,7 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
>  	ret = dsa_slave_phy_setup(p, slave_dev);
>  	if (ret) {
>  		netdev_err(master, "error %d setting up slave phy\n", ret);
> +		ds->ports[port].netdev = NULL;
>  		unregister_netdev(slave_dev);
>  		free_netdev(slave_dev);
>  		return ret;
> ---
> 
> Thanks,
> Christian
> 


-- 
Florian
