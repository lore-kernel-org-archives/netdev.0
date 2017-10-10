From: Greg Ungerer <gerg@linux-m68k.org>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: rework in-chip bridging
Date: Tue, 10 Oct 2017 15:02:55 +1000
Message-ID: <d4eca55e-2806-f7d3-6a1d-33a529995ad8@linux-m68k.org>
References: <ab86ad59-06af-b4ab-0bc6-dace73f04ef0@linux-m68k.org>
 <339d3e25-8262-d0c3-16f9-75fa9faa25dd@gmail.com>
 <18a28b2b-3e59-77d1-961b-213171b98136@linux-m68k.org>
 <d2e2e8b4-e28f-a6ea-9031-d5b12f467231@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from icp-osb-irony-out8.external.iinet.net.au ([203.59.1.225]:21760
        "EHLO icp-osb-irony-out8.external.iinet.net.au" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750950AbdJJFC5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 01:02:57 -0400
In-Reply-To: <d2e2e8b4-e28f-a6ea-9031-d5b12f467231@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/10/17 14:00, Florian Fainelli wrote:
> Le 10/08/17 à 20:23, Greg Ungerer a écrit :
>> On 07/10/17 13:04, Florian Fainelli wrote:
>>> Le 10/03/17 à 23:20, Greg Ungerer a écrit :
>>>> On Wed, Mar 29, 2017 at 04:30:16PM -0400, Vivien Didelot wrote:
>>>>> All ports -- internal and external, for chips featuring a PVT -- have a
>>>>> mask restricting to which internal ports a frame is allowed to egress.
>>>>>
>>>>> Now that DSA exposes the number of ports and their bridge devices, it is
>>>>> possible to extract the code generating the VLAN map and make it generic
>>>>> so that it can be shared later with the cross-chip bridging code.
>>>>
>>>> This patch changes the behavior of interfaces on startup if they are
>>>> not part of a bridge.
>>>>
>>>> I have a board with a Marvell 6350 switch with a device tree that sets
>>>> up the 5 ports as lan1, lan2, lan3, lan4, wan. With kernels before
>>>> this patch (so linux-4.12 and older) after system startup I could do:
>>>>
>>>>   ifconfig lan1 192.168.0.1
>>>>
>>>> And then ping out that interface with no problems.
>>>>
>>>> After this patch is applied (effects linux-4.13 and newer) then the
>>>> ping fails:
>>>>
>>>>   PING 192.168.0.22 (192.168.0.22) 56(84) bytes of data.
>>>>   From 192.168.0.1 icmp_seq=1 Destination Host Unreachable
>>>>   From 192.168.0.1 icmp_seq=2 Destination Host Unreachable
>>>>   From 192.168.0.1 icmp_seq=3 Destination Host Unreachable
>>>>
>>>> If I incorporate an interface into a bridge then it all works ok.
>>>> So simply:
>>>>
>>>>   brctl addbr br0
>>>>   brctl addif br0 lan1
>>>>   ifconfig lan1 up
>>>>   ifconfig br0 192.168.0.1
>>>>
>>>> Then pings out work as expected. And if I now remove that lan1
>>>> interface from the bridge and use it alone again then it will
>>>> now work ok:
>>>>
>>>>   ifconfig br0 down
>>>>   brctl delif br0 lan1
>>>>   ifconfig lan1 192.168.0.1
>>>>
>>>> And that now pings ok.
>>>>
>>>> I fixed this with the attached patch. It is probably not the correct
>>>> approach, but it does restore the older behavior.
>>>>
>>>> What do you think?
>>>
>>> This is strange, the dsa_switch_tree and its associated dsa_switch
>>> instances should be fully setup by the time ops->setup() is running in
>>> your driver but your patch suggests this may not be happening?
>>
>> That is what I am seeing, yep.
>>
>>
>>> Are you using the new style Device Tree binding or the old style Device
>>> Tree binding out of curiosity?
>>
>> This is my device tree fragment for the switch:
>>
>>         dsa@0 {
>>                 compatible = "marvell,dsa";
>>                 #address-cells = <2>;
>>                 #size-cells = <0>;
>>
>>                 dsa,ethernet = <&eth0>;
>>                 dsa,mii-bus = <&mdio>;
>>
>>                 switch@0 {
>>                         #address-cells = <1>;
>>                         #size-cells = <0>;
>>                         reg = <0x11 0>;
>>
>>                         port@0 {
>>                                 reg = <0>;
>>                                 label = "lan1";
>>                         };
>>                         port@1 {
>>                                 reg = <1>;
>>                                 label = "lan2";
>>                         };
>>                         port@2 {
>>                                 reg = <2>;
>>                                 label = "lan3";
>>                         };
>>                         port@3 {
>>                                 reg = <3>;
>>                                 label = "lan4";
>>                         };
>>                         port@4 {
>>                                 reg = <4>;
>>                                 label = "wan";
>>                         };
>>                         port@5 {
>>                                 reg = <5>;
>>                                 label = "cpu";
>>                         };
>>                 };
>>          };
>>
>> The board I am using is based around an Marvell Armada 370. This device tree
>> setup looks pretty similar to the other Marvell boards using marvell,dsa.
> 
> This is the old Device Tree binding which goes through an unfortunately
> different code path while initializing all the dsa_switch_tree and
> dsa_switch structures, while we should definitively look into fixing
> this, would you mind trying to update your board using something similar
> to this commit:
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=4cb2ec8cad8c82cd7cfd19edcacd846861d6e703

Ok, converted the devicetree to use this form of dsa setup.
Does not show the problem, on first boot lan1 works properly.


> This would make you go through net/dsa/dsa2.c which is what most of us
> usually test. In the meantime we should probably start issuing warning
> messages when people use the old Device Tree binding to encourage them
> to migrate other.

Yeah, I had not noticed that the devicetree dsa setup had changed, I
have been using my devicetree for quite a few kernel versions.

Regards
Greg
