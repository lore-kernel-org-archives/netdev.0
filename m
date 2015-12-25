From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 00/28] DSA: Restructure probing
Date: Sat, 26 Dec 2015 00:41:26 +0100
Message-ID: <20151225234126.GA11083@lunn.ch>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
 <567B07CB.5080308@gmail.com>
 <20151223223303.GD25485@lunn.ch>
 <567B2A89.7000803@gmail.com>
 <20151224125812.GB29139@lunn.ch>
 <567CA01F.6010604@gmail.com>
 <20151225113123.GA7422@lunn.ch>
 <567DBC73.9040104@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: narmstrong@baylibre.com, vivien.didelot@savoirfairelinux.com,
	netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49628 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754676AbbLYXl3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Dec 2015 18:41:29 -0500
Content-Disposition: inline
In-Reply-To: <567DBC73.9040104@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I am not really questioning whether the abstraction is working, this
> clearly does, what I am wondering is if the use of the component
> framework requires us to have master and slaves be implemented as strict
> platform devices, or if we have a choice in how we mix things together,
> like master is a platform device, but slaves could be I2C, SPI client or
> even platform devices themselves? That was not quite obvious to me by
> looking at the patches, sorry.

Slaves can be any sort of device. From what i've seen with GPU usage,
they are sometimes i2c devices, e.g. HDMI and audio framers. The way i
use slaves in the patches, is that all they need is a struct device
and an of node for matching to the master. The master also needs a
struct device. It makes no difference if these struct device are
embedded in a plaform_device, an struct i2c_client, struct phy_device
etc.

> >> mdio_bus@deadbeef {
> >> 	compatible = "acme,mdiobus";
> >> 	..
> >> 	switch0@0 {
> >> 		compatible = "marvell,mv88e6131";
> >> 		reg = <0>;
> >> 		dsa,addr = <1>;
> > 
> > This is not sufficient. It does not tell you which DSA cluster this
> > switch belongs to.
> 
> Would it work if we added an additional digit which is the cluster id or
> do you need a node grouping switches in a cluster with each other like
> you proposed in patch 20?

There is one cluster property at the moment, dsa,ethernet. So we could
actually use that as the cluster identifier, if we assume each cluster
has its own host ethernet.

> 
> The question being mostly, if we have the cluster id, address/index in
> switch tree, and a double linked list using phandles, is that good
> enough to figure out a topology or shall we really have nodes and
> sub-nodes with that (we would still need a list one linked list of
> phandles to figure out which ports are "dsa").

The dsa ports tell us how switches are interconnected. So once we have
all the switches we can determine the topology. What is not so clear
yet is how you know you have all the switches. The binding i proposed
meant the dsa platform device had a complete list of switch devices it
needed to form the cluster. With the distributed binding you are
suggesting, i don't see an easy way we can build the list of slave
devices.

> > Making MDIO controlled switches hang of MDIO can be done, but it does
> > require some bigger changes to the mdio code. I will need to look at
> > this again, but i think it starts in of_mdiobus_register_phy() which
> > needs to look a the compatibility field, and do something different to
> > phy_device_register(). mdio_unregister() will also need some work,
> > since it only expects phy devices on the mdio bus.
> 
> Correct, and this is really where I would start before we go on with the
> probing restructuring, because that could impact how the new DSA binding
> will have to be (re)defined. Right now, converting the Marvell drivers
> into individual platform devices is kind of a temporary solution because
> we do not have have a proper MDIO device model which is not a PHY.

Agreed. So i guess this is the next thing to work on.

> There are lots of good patches in this series that should probably be
> merged right away since they are all improvements.

Care to make a list of which you think should be submitted now?

Thanks
	Andrew
