From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 3/8] net: phy: Allow PHY devices to identify
 themselves as Ethernet switches
Date: Thu, 30 Apr 2015 11:04:01 -0700
Message-ID: <55426E91.5000101@gmail.com>
References: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com> <1430359064-23454-4-git-send-email-f.fainelli@gmail.com> <20150430125658.GB22831@lunn.ch> <55425AB3.2040908@gmail.com> <20150430171630.GE18874@lunn.ch> <55426868.8020606@gmail.com> <20150430174837.GB1476@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	cphealy@gmail.com, mathieu@codeaurora.org, jonasj76@gmail.com,
	andrey.volkov@nexvision.fr, Chris.Packham@alliedtelesis.co.nz
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:34140 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145AbbD3SEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 14:04:14 -0400
Received: by pdbqa5 with SMTP id qa5so67830021pdb.1
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 11:04:13 -0700 (PDT)
In-Reply-To: <20150430174837.GB1476@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/04/15 10:48, Andrew Lunn wrote:
> On Thu, Apr 30, 2015 at 10:37:44AM -0700, Florian Fainelli wrote:
>> On 30/04/15 10:16, Andrew Lunn wrote:
>>>>> Hi Florian
>>>>>
>>>>> I have another two use cases for fixed_phy which i'm thinking about
>>>>> implementing soon. Both require putting a fixed_phy into DSA port
>>>>> properties in DT.
>>>>>
>>>>> The first is when the CPU ethernet and the switch don't have the same
>>>>> speed capabilities. At the moment, the switch driver configures the
>>>>> CPU port to its maximum speed. But i know of a board coming soon with
>>>>> gigabit switch ports, but the CPU Ethernet is only fast Ethernet.
>>>>
>>>> With the patch after, if your switch is MDIO connected to your host, you
>>>> could make that happen easily, since the read_status() callback would
>>>> only be invoked for the CPU port from the CPU Ethernet MAC driver
>>>> (that's the theory).
>>>
>>> I'm not sure i get what you are saying.
>>>
>>> What we currently have is:
>>>
>>> CPU ETH->fixed_phy                      Switch port CPU
>>> |                                       |
>>> +---------------------------------------+
>>>
>>> and what i'm thinking we want is:
>>>
>>> CPU ETH->fixed_phy          fixed_phy <-Switch port CPU
>>> |                                       |
>>> +---------------------------------------+
>>>
>>> So that when setting up the switch side of the link, i can read from
>>> the switch ports fixed_phy how the port should be configured.
>>
>> I see, but it still seems to me like these fixed PHY devices could be
>> eliminated completely only, and only if your switch is MDIO connected,
>> because then this becomes this:
>>
>> CPU ETH -> PHY driver <- CPU port of the switch
>>
>> and the PHY driver provided by your switch gives you the correct link
>> parameters for both ends, right?
> 
> Are you suggesting this phy driver sat in the middle effectively
> performs auto negotiation in both directions? It sees what both sides
> offer and then gives back the highest common setting?

Yes, that's what I would be tempted to do.

> 
>> If you do not have a MDIO switch, or something we could discover the
>> link parameters from, then a fixed PHY has to be used, and it seems to
>> me like we should have some sort of generic code doing that in DSA
>> today: try to find a 'fixed-link' subnode (or old 5-tuple property) in
>> the device tree node pointed at by dsa,ethernet, read these and feed
>> them back to the DSA switch driver such that link parameters can be
>> properly configured?
> 
> I don't think it should come from dsa,ethernet. Think of the case of
> two CPU ports? It is a property of the cpu port(s).

True. That part actually should work correctly, except for the CPU port
for which we do not parse any of these properties, see below.

>  
>> Feels like whatever we decide there is definitively something missing
>> today though, either the Ethernet MAC does not have the hooks to get the
>> parameters, or the switch has hardcoded them...
> 
> Agreed. And we should also try to include into the picture how we code
> with fixed phy configurations on normal ports, e.g. SFP modules. Maybe
> we don't need anything special for CPU and DSA ports, we solve it for
> all types of ports.

So right now, for any port you can utilize standard PHY-related or
fixed-PHY related properties, for instance this is what I use on a
BCM7445 which has the following setup:

- Port 0 has an internal gigabit PHY on dsa,mii-bus
- Port 1 is connected to an external BCM53125 switch
- Port 7 is connected to an internal MoCA PHY, whose link comes from a
special interrupt
- Port 8 is CPU

So today, the only thing we are missing is giving the CPU port some link
information, but we could probably utilize a 'fixed-link' property for
that maybe?

                        ethernet_switch@0 {
                                #address-cells = <0x2>;
                                #size-cells = <0x0>;
                                brcm,num-acb-queues = <0x40>;
                                brcm,num-gphy = <0x1>;
                                brcm,num-rgmii-ports = <0x2>;
                                compatible = "brcm,bcm7445-switch-v4.0",
"brcm,bcm53012";
                                dsa,ethernet = <0x1d>;
                                dsa,mii-bus = <0x1e>;
                                reg = <0x0 0x40000 0x40000 0x110 0x40340
0x30 0x40380 0x30 0x40400 0x34 0x40600 0x208>;
                                reg-names = "core", "reg", "intrl2_0",
"intrl2_1", "fcb", "acb";
                                interrupts = <0x0 0x18 0x0 0x0 0x19 0x0>;
                                interrupt-names = "switch_0", "switch_1";
                                brcm,fcb-pause-override;
                                brcm,acb-packets-inflight;
                                clocks = <0x1f 0x20>;
                                clock-names = "sw_switch", "sw_switch_mdiv";

                                switch@0 {
                                        #address-cells = <0x1>;
                                        #size-cells = <0x0>;
                                        reg = <0x0 0x0>;

                                        port@0 {
                                                phy-mode = "internal";
                                                phy-handle = <0x8f>;
                                                linux,phandle = <0x8d>;
                                                phandle = <0x8d>;
                                                reg = <0x0>;
                                                label = "gphy";
                                        };

                                        port@1 {
                                                phy-mode = "rgmii-txid";
                                                phy-handle = <0x91>;
                                                linux,phandle = <0x90>;
                                                phandle = <0x90>;
                                                reg = <0x1>;
                                                label = "rgmii_1";
                                        };

                                        port@2 {
                                                phy-mode = "rgmii-txid";
                                                fixed-link = <0x2 0x1
0x3e8 0x0 0x0>;
                                                linux,phandle = <0x92>;
                                                phandle = <0x92>;
                                                reg = <0x2>;
                                                label = "rgmii_2";
                                        };

                                        port@7 {
                                                phy-mode = "moca";
                                                fixed-link = <0x7 0x1
0x3e8 0x0 0x0>;
                                                linux,phandle = <0x93>;
                                                phandle = <0x93>;
                                                reg = <0x7>;
                                                label = "moca";
                                        };

                                        port@8 {
                                                linux,phandle = <0x94>;
                                                phandle = <0x94>;
                                                reg = <0x8>;
                                                label = "cpu";
                                        };
                                };
                        };

/                       mdio@403c0 {
                                reg = <0x403c0 0x8 0x40300 0x18>;
                                #address-cells = <0x0>;
                                #size-cells = <0x1>;
                                compatible = "brcm,bcm7445-mdio-v4.0",
"brcm,unimac-mdio";
                                reg-names = "mdio", "mdio_indir_rw";
                                linux,phandle = <0x1e>;
                                phandle = <0x1e>;

                                phy0: ethernet-phy@0 {
                                        linux,phandle = <0x91>;
                                        phandle = <0x91>;
                                        device_type = "ethernet-phy";
                                        max-speed = <0x3e8>;
                                        reg = <0x0>;
                                        compatible = "brcm,bcm53125",
"ethernet-phy-ieee802.3-c22";
                                };

                                phy5: ethernet-phy@5 {
                                        linux,phandle = <0x8f>;
                                        phandle = <0x8f>;
                                        clock-names = "sw_gphy";
                                        clocks = <0x8e>;
                                        device_type = "ethernet-phy";
                                        max-speed = <0x3e8>;
                                        reg = <0x5>;
                                        compatible = "brcm,28nm-gphy",
"ethernet-phy-ieee802.3-c22";
                                };
                        };
-- 
Florian
