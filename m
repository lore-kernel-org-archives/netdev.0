From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: create drivers/net/mdio and move mdio drivers into it
Date: Sun, 19 Feb 2017 21:42:20 -0800
Message-ID: <dfde5fbd-e4de-7b6d-37a6-dba1720cc3d9@gmail.com>
References: <8729016553E3654398EA69218DA29EEF15A7E753@cnshjmbx02>
 <afdb9ff7-afa9-47b0-0e84-396080fe0867@gmail.com>
 <8729016553E3654398EA69218DA29EEF15A807CA@cnshjmbx02>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "cugyly@163.com" <cugyly@163.com>
To: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>,
        "David S . Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:34633 "EHLO
        mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750776AbdBTFmx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 00:42:53 -0500
Received: by mail-qk0-f173.google.com with SMTP id s186so86811519qkb.1
        for <netdev@vger.kernel.org>; Sun, 19 Feb 2017 21:42:26 -0800 (PST)
In-Reply-To: <8729016553E3654398EA69218DA29EEF15A807CA@cnshjmbx02>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 02/19/2017 09:23 PM, YUAN Linyu wrote:
> 1. the main issue is mdio driver mixed with phy driver/ethernet driver.

You can have a standalone MDIO bus driver located anywhere you want in
the kernel tree. See drivers/net/ethernet/marvell/mvmdio.c for an example.

> 2. move them together, it's easy to maintain, add, delete or optimization(we can do it step by step).

It may be easier, but whenever you make API changes, you need to make
sure they cover every user in tree. So half convinced about this
argument here.

> 
> 3. another idea is bind mdio device to network device

You would have to be more specific about what you want to do here. If
the MDIO device is e.g: a switch, what we recommend doing is provide a
fixed-link node that describes how the Ethernet MAC and the switch's
CPU/management ports are connected (that way the MAC always "sees" the
link as UP, running with a specific speed and duplex).

If this is a different kind of MDIO device, e.g: an USB/PCIe/SATA PHY,
there is no network device associated with those.

> 4. support mdio auto probe phy device.

That's already the case, even in a Device Tree enabled system if you
omit to provide a "reg" property for child nodes, the bus is
automatically scanned.

> For 3, 4 can take device tree as example,
> Current,
> 			ethernet@e4000 {
> 				phy-handle = <&rgmii_phy1>;
> 				phy-connection-type = "rgmii";
> 			};
> 
> 			ethernet@e6000 {
> 				phy-handle = <&rgmii_phy2>;
> 				phy-connection-type = "rgmii";
> 			};
> 
> 			mdio@fc000 {
> 				rgmii_phy1: ethernet-phy@1 {
> 					reg = <0x1>;
> 				};
> 				rgmii_phy2: ethernet-phy@2 {
> 					reg = <0x2>;
> 				};
> 			};
> After change,
> 			ethernet@e4000 {
> 				mdio-handle = <&mdio>;
> 				phy-reg = <0x1>;
> 				phy-connection-type = "rgmii";
> 			};

This is not providing anything more than the current representation, and
in fact, it's actually counter to the Device Tree representation where
nodes should be relative to their parent and describe their address with
standard properties (reg) which are to be interpreted relative to their
parent's node #address-cells and #size-cells properties. You are also
introducing two new properties (phy-reg) and (mdio-handle) which both
introduce an incompatible binding...

Seriously, what problem do you really want to solve that we can't do
today? It may just be easier to send patches and have all of us review them.


> 
> 			ethernet@e6000 {
> 				mdio-handle = <&mdio>;
> 				phy-handle = <&rgmii_phy2>;
> 				phy-connection-type = "rgmii";
> 			};
> 
> 			mdio: mdio@fc000 {
> 			    reg = <xxx>;
> 			};
> 
> 
>> -----Original Message-----
>> From: Florian Fainelli [mailto:f.fainelli@gmail.com]
>> Sent: Monday, February 20, 2017 1:03 PM
>> To: YUAN Linyu; David S . Miller; Andrew Lunn
>> Cc: netdev@vger.kernel.org; cugyly@163.com
>> Subject: Re: create drivers/net/mdio and move mdio drivers into it
>>
>>
>>
>> On 02/19/2017 04:20 PM, YUAN Linyu wrote:
>>> Hi,
>>>
>>> I have an idea to create drivers/net/mdio and move mdio
>> drivers(drivers/net/phy/mdio-* | drivers/net/ethernet/xxx/mdio-yyy | ) into it.
>>>
>>> Do you think it is acceptable ?
>>
>> What problem are you trying to fix by doing such a move? Moving files
>> around mean that making stable backports are going to be much more painful.
>>
>> So without further explanation, does not sound like such a great idea.
>> --
>> Florian

-- 
Florian
