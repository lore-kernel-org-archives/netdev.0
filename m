From: Greg Ungerer <gerg@linux-m68k.org>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: rework in-chip bridging
Date: Mon, 9 Oct 2017 13:23:43 +1000
Message-ID: <18a28b2b-3e59-77d1-961b-213171b98136@linux-m68k.org>
References: <ab86ad59-06af-b4ab-0bc6-dace73f04ef0@linux-m68k.org>
 <339d3e25-8262-d0c3-16f9-75fa9faa25dd@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from icp-osb-irony-out7.external.iinet.net.au ([203.59.1.107]:42202
        "EHLO icp-osb-irony-out7.external.iinet.net.au" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753885AbdJIDYb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Oct 2017 23:24:31 -0400
In-Reply-To: <339d3e25-8262-d0c3-16f9-75fa9faa25dd@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On 07/10/17 13:04, Florian Fainelli wrote:
> Le 10/03/17 à 23:20, Greg Ungerer a écrit :
>> On Wed, Mar 29, 2017 at 04:30:16PM -0400, Vivien Didelot wrote:
>>> All ports -- internal and external, for chips featuring a PVT -- have a
>>> mask restricting to which internal ports a frame is allowed to egress.
>>>
>>> Now that DSA exposes the number of ports and their bridge devices, it is
>>> possible to extract the code generating the VLAN map and make it generic
>>> so that it can be shared later with the cross-chip bridging code.
>>
>> This patch changes the behavior of interfaces on startup if they are
>> not part of a bridge.
>>
>> I have a board with a Marvell 6350 switch with a device tree that sets
>> up the 5 ports as lan1, lan2, lan3, lan4, wan. With kernels before
>> this patch (so linux-4.12 and older) after system startup I could do:
>>
>>   ifconfig lan1 192.168.0.1
>>
>> And then ping out that interface with no problems.
>>
>> After this patch is applied (effects linux-4.13 and newer) then the
>> ping fails:
>>
>>   PING 192.168.0.22 (192.168.0.22) 56(84) bytes of data.
>>   From 192.168.0.1 icmp_seq=1 Destination Host Unreachable
>>   From 192.168.0.1 icmp_seq=2 Destination Host Unreachable
>>   From 192.168.0.1 icmp_seq=3 Destination Host Unreachable
>>
>> If I incorporate an interface into a bridge then it all works ok.
>> So simply:
>>
>>   brctl addbr br0
>>   brctl addif br0 lan1
>>   ifconfig lan1 up
>>   ifconfig br0 192.168.0.1
>>
>> Then pings out work as expected. And if I now remove that lan1
>> interface from the bridge and use it alone again then it will
>> now work ok:
>>
>>   ifconfig br0 down
>>   brctl delif br0 lan1
>>   ifconfig lan1 192.168.0.1
>>
>> And that now pings ok.
>>
>> I fixed this with the attached patch. It is probably not the correct
>> approach, but it does restore the older behavior.
>>
>> What do you think?
> 
> This is strange, the dsa_switch_tree and its associated dsa_switch
> instances should be fully setup by the time ops->setup() is running in
> your driver but your patch suggests this may not be happening?

That is what I am seeing, yep.


> Are you using the new style Device Tree binding or the old style Device
> Tree binding out of curiosity?

This is my device tree fragment for the switch:

        dsa@0 {
                compatible = "marvell,dsa";
                #address-cells = <2>;
                #size-cells = <0>;

                dsa,ethernet = <&eth0>;
                dsa,mii-bus = <&mdio>;

                switch@0 {
                        #address-cells = <1>;
                        #size-cells = <0>;
                        reg = <0x11 0>;

                        port@0 {
                                reg = <0>;
                                label = "lan1";
                        };
                        port@1 {
                                reg = <1>;
                                label = "lan2";
                        };
                        port@2 {
                                reg = <2>;
                                label = "lan3";
                        };
                        port@3 {
                                reg = <3>;
                                label = "lan4";
                        };
                        port@4 {
                                reg = <4>;
                                label = "wan";
                        };
                        port@5 {
                                reg = <5>;
                                label = "cpu";
                        };
                };
         };

The board I am using is based around an Marvell Armada 370. This device tree
setup looks pretty similar to the other Marvell boards using marvell,dsa.

Regards
Greg



>>> Signed-off-by: Vivien Didelot <vivien.dide...@savoirfairelinux.com>
>>> ---
>>>  drivers/net/dsa/mv88e6xxx/chip.c | 53 ++++++++++++++++++++++++++--------------
>>>  1 file changed, 34 insertions(+), 19 deletions(-)
>>>
>>> diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
>>> index b114bf8e6a11..e5165831e8b5 100644
>>> --- a/drivers/net/dsa/mv88e6xxx/chip.c
>>> +++ b/drivers/net/dsa/mv88e6xxx/chip.c
>>> @@ -1123,27 +1123,42 @@ static int mv88e6xxx_set_eee(struct dsa_switch *ds, int 
>>> port,
>>>         return err;
>>>  }
>>>  
>>> +static u16 mv88e6xxx_port_vlan(struct mv88e6xxx_chip *chip, int dev, int port)
>>> +{
>>> +       struct dsa_switch *ds = NULL;
>>> +       struct net_device *br;
>>> +       u16 pvlan;
>>> +       int i;
>>> +
>>> +       if (dev < DSA_MAX_SWITCHES)
>>> +               ds = chip->ds->dst->ds[dev];
>>> +
>>> +       /* Prevent frames from unknown switch or port */
>>> +       if (!ds || port >= ds->num_ports)
>>> +               return 0;
>>> +
>>> +       /* Frames from DSA links and CPU ports can egress any local port */
>>> +       if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port))
>>> +               return mv88e6xxx_port_mask(chip);
>>> +
>>> +       br = ds->ports[port].bridge_dev;
>>> +       pvlan = 0;
>>> +
>>> +       /* Frames from user ports can egress any local DSA links and CPU ports,
>>> +        * as well as any local member of their bridge group.
>>> +        */
>>> +       for (i = 0; i < mv88e6xxx_num_ports(chip); ++i)
>>> +               if (dsa_is_cpu_port(chip->ds, i) ||
>>> +                   dsa_is_dsa_port(chip->ds, i) ||
>>> +                   (br && chip->ds->ports[i].bridge_dev == br))
>>> +                       pvlan |= BIT(i);
>>> +
>>> +       return pvlan;
>>> +}
>>> +
>>>  static int _mv88e6xxx_port_based_vlan_map(struct mv88e6xxx_chip *chip, int 
>>> port)
>>>  {
>>> -       struct dsa_switch *ds = chip->ds;
>>> -       struct net_device *bridge = ds->ports[port].bridge_dev;
>>> -       u16 output_ports = 0;
>>> -       int i;
>>> -
>>> -       /* allow CPU port or DSA link(s) to send frames to every port */
>>> -       if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)) {
>>> -               output_ports = ~0;
>>> -       } else {
>>> -               for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
>>> -                       /* allow sending frames to every group member */
>>> -                       if (bridge && ds->ports[i].bridge_dev == bridge)
>>> -                               output_ports |= BIT(i);
>>> -
>>> -                       /* allow sending frames to CPU port and DSA link(s) */
>>> -                       if (dsa_is_cpu_port(ds, i) || dsa_is_dsa_port(ds, i))
>>> -                               output_ports |= BIT(i);
>>> -               }
>>> -       }
>>> +       u16 output_ports = mv88e6xxx_port_vlan(chip, chip->ds->index, port);
>>>  
>>>         /* prevent frames from going back out of the port they came in on */
>>>         output_ports &= ~BIT(port);
>>> -- 
>>
> 
> 
