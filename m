From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: DSA vs. SWTICHDEV ?
Date: Wed, 30 Nov 2016 10:10:52 -0800
Message-ID: <922521a8-3a33-bbc4-2e07-2b946590c829@gmail.com>
References: <1480495831.3563.135.camel@infinera.com>
 <20161130135257.GC18716@lunn.ch> <1480516241.3563.142.camel@infinera.com>
 <20161130152503.GE21645@lunn.ch> <1480523716.3563.144.camel@infinera.com>
 <20161130165500.GH21645@lunn.ch> <1480527852.3563.146.camel@infinera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joakim Tjernlund <Joakim.Tjernlund@infinera.com>,
        "andrew@lunn.ch" <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:36584 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753112AbcK3SKz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 13:10:55 -0500
Received: by mail-pg0-f53.google.com with SMTP id f188so84232674pgc.3
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 10:10:55 -0800 (PST)
In-Reply-To: <1480527852.3563.146.camel@infinera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/30/2016 09:44 AM, Joakim Tjernlund wrote:
> On Wed, 2016-11-30 at 17:55 +0100, Andrew Lunn wrote:
>>> This is an embedded system with several boards in a subrack.
>>> Each board has eth I/F connected to a switch to communicate with each other.
>>> One of the board will also house the actual switch device and manage the switch.
>>> Then the normal app just communicates over the physical eth I/F like any other board
>>> in the system. There is a "manage switch app" which brings the switch up and partition
>>> phys VLANs etc. (each phys I/F would be a a separate domain so no loop)
>>
>> So you are planning on throwing away the "manage switch app", and just
>> use standard linux networking commands? That is what switchdev is all
>> about really, throwing away the vendor SDK for the switch, making a
>> switch just a bunch on interfaces on the host which you manage as
>> normal interfaces.
> 
> Something like that. I need to run routing protocols on the switch I/Fs and egress
> pkgs on selected switch I/Fs bypassing ARP, just like DSA does with its vendor
> tags.
> 
>>
>>> I guess I could skip the phys I/F and have the switch app create a virtual eth0 I/F over PCIe
>>
>> No need to create this interface. It will exist if you go the
>> switchdev route.
>>
>>>>> And switchdev can do all this over PCIe instead? Can you have a
>>>>> switch tree in switchdev too?
>>>>
>>>> Mellonex says so, but i don't think they have actually implemented it.
>>>
>>> Not impl. any of DSAs features? What can you do with a Mellonex switch then?
>>
>> They don't have a tree of switches, as far as i know. Just a single
>> switch. But DSA does support a tree of switches, that is what the D in
>> DSA means, distributed. And there are a couple of boards which have 2
>> to 4 switches in a tree.
> 
> We might have a tree as well so now I really wonder: Given we write a
> proper switchdev driver, can it support switchtrees without touching
> switchdev infra structure? If not I guess we will attach a physical
> eth I/F to the switch and use both DSA and switchdev to support both trees
> and HW offload. 

switchdev in itself really is the glue layer between the networking
stack and how to push specific objects down to the Ethernet switch
driver, and that Ethernet switch driver. Switchdev does not enforce a
specific network device driver model object, and just provides standard
hooks for your network devices to register with switchdev in order to
push/receive offloads. DSA on the other hand, utilizes switchdev to get
notifications about offloads from the networking stack, but also exposes
a clearly and well defined Ethernet switch device driver model, as
Andrew described, it creates per-port network devices, binds the ports
to their PHYs (built-in, or external), and also takes care of
encapsulating/decapsulating the switch specific tagging protocol.

We should probably put that in some crystal clear sentence somewhere in
Documentation/networking/ but switchdev and DSA are complementary and
not competitors, they just do not tackle the problems from the same angle.

> 
>>
>> I think this is partially down to market segments. Mellonex market is
>> top of rack switches. High port count, very high bandwidth. DSA is
>> more wireless access points, set top boxes, generally up to 7 ports of
>> 1Gbps and a few custom embedded products which need more ports, so
>> build a tree of switches.
> 
> We have on an existing board with a BCM ROBO switch with lots of ports(>24),
> managed over SPI. Looking at BCM DSA tag code it looks like it only supports
> some 8 ports or so. I still have to find out if this is a limitation in BCM tagging
> protocol or if just not impl. in DSA yet.

Oh cool, can you share the model by chance? I suspect the tagging format
of that switch is going to be different than what net/dsa/tag_brcm.c, so
feel free to add something NET_DSA_TAG_BRCM8B (for 8 bytes) or something
like that.

Note that DSA currently hardcodes the maximum number of ports to 14
(DSA_MAX_PORTS), but this should obviously be something dynamically
determined based on probing the switch device.

Can you also evaluate if using drivers/net/dsa/b53/ would work for you?
My hope would be that they preserved the register compatibility here,
but since this has a large number of ports, it may have completely
offset most registers.

BTW, there is #linuxswitch on Freenode if you want to chat!
-- 
Florian
