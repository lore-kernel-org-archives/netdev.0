From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: DSA vs. SWTICHDEV ?
Date: Wed, 30 Nov 2016 11:39:15 -0800
Message-ID: <3fe33f33-da0d-5d55-42e7-405e9122579e@gmail.com>
References: <1480495831.3563.135.camel@infinera.com>
 <20161130135257.GC18716@lunn.ch> <1480516241.3563.142.camel@infinera.com>
 <20161130152503.GE21645@lunn.ch> <1480523716.3563.144.camel@infinera.com>
 <20161130165500.GH21645@lunn.ch> <1480527852.3563.146.camel@infinera.com>
 <922521a8-3a33-bbc4-2e07-2b946590c829@gmail.com>
 <1480531441.3563.148.camel@infinera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joakim Tjernlund <Joakim.Tjernlund@infinera.com>,
        "andrew@lunn.ch" <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:35746 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754166AbcK3TjS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 14:39:18 -0500
Received: by mail-pg0-f50.google.com with SMTP id p66so85311662pga.2
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 11:39:17 -0800 (PST)
In-Reply-To: <1480531441.3563.148.camel@infinera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/30/2016 10:44 AM, Joakim Tjernlund wrote:
> On Wed, 2016-11-30 at 10:10 -0800, Florian Fainelli wrote:
>> On 11/30/2016 09:44 AM, Joakim Tjernlund wrote:
>>> On Wed, 2016-11-30 at 17:55 +0100, Andrew Lunn wrote:
>>>>> This is an embedded system with several boards in a subrack.
>>>>> Each board has eth I/F connected to a switch to communicate with each other.
>>>>> One of the board will also house the actual switch device and manage the switch.
>>>>> Then the normal app just communicates over the physical eth I/F like any other board
>>>>> in the system. There is a "manage switch app" which brings the switch up and partition
>>>>> phys VLANs etc. (each phys I/F would be a a separate domain so no loop)
>>>>
>>>> So you are planning on throwing away the "manage switch app", and just
>>>> use standard linux networking commands? That is what switchdev is all
>>>> about really, throwing away the vendor SDK for the switch, making a
>>>> switch just a bunch on interfaces on the host which you manage as
>>>> normal interfaces.
>>>
>>> Something like that. I need to run routing protocols on the switch I/Fs and egress
>>> pkgs on selected switch I/Fs bypassing ARP, just like DSA does with its vendor
>>> tags.
>>>
>>>>
>>>>> I guess I could skip the phys I/F and have the switch app create a virtual eth0 I/F over PCIe
>>>>
>>>> No need to create this interface. It will exist if you go the
>>>> switchdev route.
>>>>
>>>>>>> And switchdev can do all this over PCIe instead? Can you have a
>>>>>>> switch tree in switchdev too?
>>>>>>
>>>>>> Mellonex says so, but i don't think they have actually implemented it.
>>>>>
>>>>> Not impl. any of DSAs features? What can you do with a Mellonex switch then?
>>>>
>>>> They don't have a tree of switches, as far as i know. Just a single
>>>> switch. But DSA does support a tree of switches, that is what the D in
>>>> DSA means, distributed. And there are a couple of boards which have 2
>>>> to 4 switches in a tree.
>>>
>>> We might have a tree as well so now I really wonder: Given we write a
>>> proper switchdev driver, can it support switchtrees without touching
>>> switchdev infra structure? If not I guess we will attach a physical
>>> eth I/F to the switch and use both DSA and switchdev to support both trees
>>> and HW offload. 
>>
>> switchdev in itself really is the glue layer between the networking
>> stack and how to push specific objects down to the Ethernet switch
>> driver, and that Ethernet switch driver. Switchdev does not enforce a
>> specific network device driver model object, and just provides standard
>> hooks for your network devices to register with switchdev in order to
>> push/receive offloads. DSA on the other hand, utilizes switchdev to get
>> notifications about offloads from the networking stack, but also exposes
>> a clearly and well defined Ethernet switch device driver model, as
>> Andrew described, it creates per-port network devices, binds the ports
>> to their PHYs (built-in, or external), and also takes care of
>> encapsulating/decapsulating the switch specific tagging protocol.
> 
> Lets see, switchdev is mainly for offloading L2/L3 into HW and does NOT create
> virtual I/F(one for each phys sw port) so if my only goal is to offload I don't
> need DSA? (How do one create routes if no virtual I/Fs I wonder ..) 

switchdev does not create network devices per-se, but a driver utilizing
switchdev should do that instead. How packet transmission/reception
works on these network devices is outside of the scope of switchdev.

> 
> DSA then does create virt. I/Fs and manages switch trees, to actually tx pkg it needs
> a phys I/F using vendor specific tags(for PCIe connected switches I can envision using
> the PCIe connection instead).

DSA can operate without a tag (DSA_TAG_PROTO_NONE) but the general idea
is that the management entity, in order to properly identify which
per-port network device is sending traffic to/from, needs some kind of
tag. Its most rudimentary form can be a per-port VLAN ID, but ideally a
proper switch tag (EDSA, DSA, Broadcom tag) is better suited for that.

The "master" network device in DSA is just a normal Ethernet interface
which receives these tags, and transmits then to the managemenet/CPU
port of the switch it is attached to.

> 
> Who is the master when using both DSA and switchdev w.r.t initil conf/bring up of switch?
> configuring VLANs?

You start with all ports being all segregated and just able to talk to
the CPU/management port. If you are in a switch tree (distributed), then
the uplinks between the switches should make such traffic pass through
all the way to the management port. In order to configure VLANs, you
need to create a bridge device, and then use "bridge vlan ..." to
configure the VLAN member ship of ports.

> 
>>
>> We should probably put that in some crystal clear sentence somewhere in
>> Documentation/networking/ but switchdev and DSA are complementary and
>> not competitors, they just do not tackle the problems from the same angle.
> 
> Yes :)
> 
>>
>>>
>>>>
>>>> I think this is partially down to market segments. Mellonex market is
>>>> top of rack switches. High port count, very high bandwidth. DSA is
>>>> more wireless access points, set top boxes, generally up to 7 ports of
>>>> 1Gbps and a few custom embedded products which need more ports, so
>>>> build a tree of switches.
>>>
>>> We have on an existing board with a BCM ROBO switch with lots of ports(>24),
>>> managed over SPI. Looking at BCM DSA tag code it looks like it only supports
>>> some 8 ports or so. I still have to find out if this is a limitation in BCM tagging
>>> protocol or if just not impl. in DSA yet.
>>
>> Oh cool, can you share the model by chance? I suspect the tagging format
> 
> I think it is an BCM5322

OK, so this one is actually capable of supporting something that is a
real distributed architecture design, cool! The format of the tag is way
different than what net/dsa/tag_brcm.c supports today, and it also
requires a lot more help from the networking stack with respect to
unicast/broadcast/multicast since you need to adjust the opcode of the
tag accordingly. Nothing that cannot be supported though.

> 
>> of that switch is going to be different than what net/dsa/tag_brcm.c, so
>> feel free to add something NET_DSA_TAG_BRCM8B (for 8 bytes) or something
>> like that.
> 
> I will have to look at that, don't have an docs handy.

The device looks largely register compatible with the definitions in
drivers/net/dsa/b53/b53_regs.h with a few notable exceptions:

- port control overrides B53_PORT_CTRL are not at offset 0 + (port
number), but A0 + port number
- link status summary in the status page is slightly offset down

But for the most part, in particular the ARL and VLAN pages, seems like
b53 would not require too much conditionals to get this switch to work.

> 
>>
>> Note that DSA currently hardcodes the maximum number of ports to 14
>> (DSA_MAX_PORTS), but this should obviously be something dynamically
>> determined based on probing the switch device.
>>
>> Can you also evaluate if using drivers/net/dsa/b53/ would work for you?
>> My hope would be that they preserved the register compatibility here,
>> but since this has a large number of ports, it may have completely
>> offset most registers.
> 
> I will have a look, I sure want to try out DSA/switchdev on existing boards if I can :)

Good!
-- 
Florian
