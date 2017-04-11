From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC net-next] of: mdio: Honor hints from MDIO bus drivers
Date: Tue, 11 Apr 2017 16:23:25 -0700
Message-ID: <6de72d4c-5634-f3d6-5bfd-fcc0acda0b83@gmail.com>
References: <20170410214258.9409-1-f.fainelli@gmail.com>
 <8ef102a4-22e5-def8-b50e-04f84b5849d7@gmail.com>
 <20170411231424.GA6174@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "open list:OPEN FIRMWARE AND FLATTENED DEVICE TREE"
        <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170411231424.GA6174-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/11/2017 04:14 PM, Andrew Lunn wrote:
>> To give some more background and rational for this change.
>>
>> On a platform where we have a parent MDIO bus, backed by the
>> mdio-bcm-unimac.c driver, we also register a slave MII bus (through
>> net/dsa/dsa2.c) which is parented to this UniMAC MDIO bus through an
>> assignment of of_node. This slave MII bus is created in order to
>> intercept reads/writes to problematic addresses (e.g: that clashes with
>> another piece of hardware).
>>
>> This means that the slave DSA MII bus inherits all child nodes from the
>> originating master MII bus. This also means that when the slave MII bus
>> is probed via of_mdiobus_register(), we probe the same devices twice:
>> once through the master, another time through the slave.
> 
> Ah, O.K. This makes more sense. On the hardware i have, we get three
> deep in MDIO busses. We have the FEC mdio bus. On top of that we have
> a gpio-mux-mdio, and on top of that we have the mv88e6xxx mdio
> bus. And i've never seen issues.
> 
> So your real problem here is you have two mdio busses using the same
> device tree properties. I would actually say that is just plain
> broken.

>From a Device Tree/HW representation perspective, we do have the
external BCM53125 switch physically attached to the 7445/7278
SWITCH_MDIO bus (backed by mdio-bcm-unimac) so in that regard the
representation is correct. There is also an integrated Gigabit PHY
(bcm7xxx) which is attached to that bus.

>From a SW perspective though, we want to talk to the integrated Gigabit
PHY using mdio-bcm-unimac but talk to the external BCM53125 switch using
the slave MII bus created by the bcm_sf2 driver in order to create an
isolation. We need to inherit some of the parent (mdio-bcm-unimac) child
DT nodes (such as the BCM53125), but not the GPHY. The easiest solution
I found was to use this patch.

Using mdiobus_register() instead of of_mdiobus_register() was
considered, but then, the child BCM53125 has no more "visbility" into
the OF world at all, and it matters, because this switch is also driven
via a DSA switch driver and its Ethernet data-path is connected to one
port of the bcm_sf2 switch..

Thankfully the HW bug was fixed eventually ;)
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
