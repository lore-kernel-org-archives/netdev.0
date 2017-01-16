From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v3 06/10] net: dsa: Migrate to
 device_find_class()
Date: Mon, 16 Jan 2017 12:01:02 -0800
Message-ID: <912e6143-c67a-d909-2a6c-939de79efc5d@gmail.com>
References: <20170114214713.28109-1-f.fainelli@gmail.com>
 <20170114214713.28109-7-f.fainelli@gmail.com>
 <20170115110628.GF26374@kroah.com>
 <fc247aeb-a8d6-5ba9-c26d-cb057a5ac34d@gmail.com>
 <20170115173949.GA19268@kroah.com>
 <a9ea1f45-b9a5-d840-68e0-9bf9bc7a6598@gmail.com>
 <20170115191632.GD5643@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Greg KH <gregkh@linuxfoundation.org>, netdev@vger.kernel.org,
        Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Russell King <linux@armlinux.org.uk>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        "moderated list:ARM SUB-ARCHITECTURES"
        <linux-arm-kernel@lists.infradead.org>,
        open list <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34055 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750834AbdAPUBG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 15:01:06 -0500
In-Reply-To: <20170115191632.GD5643@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/15/2017 11:16 AM, Andrew Lunn wrote:
>>> What exactly is the relationship between these devices (a ascii-art tree
>>> or sysfs tree output might be nice) so I can try to understand what is
>>> going on here.
> 
> Hi Greg, Florian
> 
> A few diagrams and trees which might help understand what is going on.
> 
> The first diagram comes from the 2008 patch which added all this code:
> 
>             +-----------+       +-----------+
>             |           | RGMII |           |
>             |           +-------+           +------ 1000baseT MDI ("WAN")
>             |           |       |  6-port   +------ 1000baseT MDI ("LAN1")
>             |    CPU    |       |  ethernet +------ 1000baseT MDI ("LAN2")
>             |           |MIImgmt|  switch   +------ 1000baseT MDI ("LAN3")
>             |           +-------+  w/5 PHYs +------ 1000baseT MDI ("LAN4")
>             |           |       |           |
>             +-----------+       +-----------+
> 
> We have an ethernet switch and a host CPU. The switch is connected to
> the CPU in two different ways. RGMII allows us to get Ethernet frames
> from the CPU into the switch. MIImgmt, is the management bus normally
> used for Ethernet PHYs, but Marvell switches also use it for Managing
> switches.
> 
> The diagram above is the simplest setup. You can have multiple
> Ethernet switches, connected together via switch ports. Each switch
> has its own MIImgmt connect to the CPU, but there is only one RGMII
> link.
> 
> When this code was designed back in 2008, it was decided to represent
> this is a platform device, and it has a platform_data, which i have
> slightly edited to keep it simple:
> 
> struct dsa_platform_data {
>         /*
>          * Reference to a Linux network interface that connects
>          * to the root switch chip of the tree.
>          */
>         struct device   *netdev;
> 
>         /*
>          * Info structs describing each of the switch chips
>          * connected via this network interface.
>          */
>         int             nr_chips;
>         struct dsa_chip_data    *chip;
> };
> 
> This netdev is the CPU side of the RGMII interface.
> 
> Each switch has a dsa_chip_data, again edited:
> 
> struct dsa_chip_data {
>         /*
>          * How to access the switch configuration registers.
>          */
>         struct device   *host_dev;
>         int             sw_addr;
> ...
> }
> 
> The host_dev is the CPU side of the MIImgmt, and we have the address
> the switch is using on the bus.
> 
> During probe of this platform device, we need to get from the
> struct device *netdev to a struct net_device *dev.
> 
> So the code looks in the device net class to find the device
> 
> |   |   |   |-- f1074000.ethernet
> |   |   |   |   |-- deferred_probe
> |   |   |   |   |-- driver -> ../../../../../bus/platform/drivers/mvneta
> |   |   |   |   |-- driver_override
> |   |   |   |   |-- modalias
> |   |   |   |   |-- net
> |   |   |   |   |   `-- eth1
> |   |   |   |   |       |-- addr_assign_type
> |   |   |   |   |       |-- address
> |   |   |   |   |       |-- addr_len
> |   |   |   |   |       |-- broadcast
> |   |   |   |   |       |-- carrier
> |   |   |   |   |       |-- carrier_changes
> |   |   |   |   |       |-- deferred_probe
> |   |   |   |   |       |-- device -> ../../../f1074000.ethernet
> 
> and then use container_of() to get the net_device.
> 
> Similarly, the code needs to get from struct device *host_dev to a struct mii_bus *.
> 
> |   |   |   |-- f1072004.mdio
> |   |   |   |   |-- deferred_probe
> |   |   |   |   |-- driver -> ../../../../../bus/platform/drivers/orion-mdio
> |   |   |   |   |-- driver_override
> |   |   |   |   |-- mdio_bus
> |   |   |   |   |   `-- f1072004.mdio-mi
> |   |   |   |   |       |-- deferred_probe
> |   |   |   |   |       |-- device -> ../../../f1072004.mdio
> 

Thanks Andrew! Greg, does that make it clearer how these devices
references are used, do you still think the way this is done is wrong,
too cautious, or valid?
-- 
Florian
