From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 06/14] net: dsa: Add support for hardware monitoring
Date: Thu, 23 Oct 2014 11:43:22 -0700
Message-ID: <20141023184322.GA24281@roeck-us.net>
References: <1414037002-25528-1-git-send-email-linux@roeck-us.net>
 <1414037002-25528-7-git-send-email-linux@roeck-us.net>
 <CAGVrzcYjPJWai9bxkh+WRrEEAzBKBd-LQm7zDeeouxngr_v9SQ@mail.gmail.com>
 <54488CE1.2000106@roeck-us.net>
 <20141023134706.GB25190@lunn.ch>
 <20141023162754.GA21343@roeck-us.net>
 <20141023165459.GE25190@lunn.ch>
 <20141023173847.GA22988@roeck-us.net>
 <20141023180357.GG25190@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:42999 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932833AbaJWSnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 14:43:33 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1XhNMD-001kMu-3B
	for netdev@vger.kernel.org; Thu, 23 Oct 2014 18:43:33 +0000
Content-Disposition: inline
In-Reply-To: <20141023180357.GG25190@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 23, 2014 at 08:03:57PM +0200, Andrew Lunn wrote:
> > No, I am not saying that. The hwmon device's parent device will tell,
> > which is how it works for all other hwmon devices.
> 
> O.K, so parent is important.
> 
> > Not really. Again, the parent device provides that information. libsensors,
> > which is the preferred way of accessing sensors information from user space,
> > provides the parent device instance as part of the logical sensor device
> > name. In this case, the names will end up being dsa-isa-0000, dsa-isa-0001,
> > and so on. With your added tags it would be dsa.0.0-isa-0000, dsa.0.1-isa-0001,
> > and so on. I don't see how this would add any value.
> 
> isa is the name of the ethernet device? Why is it not eth0? Most

isa is just an internal name made up by libsensors, and pretty much just
indicates something like "neither i2c nor spi". It is mostly historic,
but nowadays almost part of the ABI. It is made up by user space,
based on the parent device type, not by the kernel.

> Marvell SoCs used in WiFi Access Points have multiple ethernet
> interfaces, so i would hope the parent actually identifies which
> ethernet interface it is hanging off.
> 
> Now consider the example in
> 
> http://lxr.free-electrons.com/source/Documentation/devicetree/bindings/net/dsa/dsa.txt
> 
> We have two switches hanging off one ethernet interface. What will the > naming look like in this case?
> 
Ah, that is a good question. You are right, the parent will be the same
for both of those switches but should be unique. Hmm ...

> The Marvell DSA tagging scheme allows you to have 16 switches hanging
> off one ethernet interface. How is the naming going to work then,
> especially if there is a mixture of switch chips, some with
> temperature sensors, and some without?
> 
The ones without sensor would not create a hwmon device, so that should
not be an issue. You are right, the other use cases are more tricky.

> What would really help is if each switch has a device in the linux
> device model. The hwmon parent would then be the switch device. The
> EEPROM would then hang off the switch device, not an interface on the
> switch device, etc.

Good point. Unfortunately that is not the case.

You have convinced me that 'dsa' as hwmon attribute name is insufficient,
so let's see what we have.

- the parent network device in dst->master_netdev
- the dsa device in 'parent'
- the host device in host_dev
- the switch index in 'index'

First question is what should be the parent device. We have three to
choose from. Should it be the parent network device or the dsa device ?
The dsa device seems like a better choice to me, but I am open to
suggestions. A problem with choosing the network device as parent
may be that this device could by itself have a temperature sensor
(some Intel and broadcom Ethernet chips have that), which could
cause confusion.

Second is what to choose for the hwmon device 'name' attribute.
'dsa' is not sufficient, but what to choose instead ? dsa.X or dsa_X,
where X is the switch index ? At this point I am open to suggestions.
Note that we can not use the name returned from the switch probe
functions as it may contain spaces and other invalid characters.
Including the ethernet device name (eg as in eth0_dsa_0) may also be
problematic if it can contain '-', which is illegal for hwmon devices.

Thanks,
Guenter
