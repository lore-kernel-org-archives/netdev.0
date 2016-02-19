From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next,V2] Add LAN9352 Ethernet Driver
Date: Fri, 19 Feb 2016 21:14:15 +0100
Message-ID: <20160219201415.GA9884@lunn.ch>
References: <20160216203625.GC2558@lunn.ch>
 <20160216.154358.164326104187806534.davem@davemloft.net>
 <90A7E81AE28BAE4CBDDB3B35F187D264402EFB5D@CHN-SV-EXMX02.mchp-main.com>
 <20160216.155244.2052910262411568012.davem@davemloft.net>
 <90A7E81AE28BAE4CBDDB3B35F187D264402EFB82@CHN-SV-EXMX02.mchp-main.com>
 <20160216221536.GB6033@lunn.ch>
 <90A7E81AE28BAE4CBDDB3B35F187D264402F0018@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, f.fainelli@gmail.com, netdev@vger.kernel.org
To: Bryan.Whitehead@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52798 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1428546AbcBSUOV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2016 15:14:21 -0500
Content-Disposition: inline
In-Reply-To: <90A7E81AE28BAE4CBDDB3B35F187D264402F0018@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 19, 2016 at 07:29:46PM +0000, Bryan.Whitehead@microchip.com wrote:
> > From: Andrew Lunn [mailto:andrew@lunn.ch]
> > Sent: Tuesday, February 16, 2016 5:16 PM
> > 
> > You are already 1/2 way to a DSA driver, since you have a MAC driver. So i
> > agree with David, do it right and add a simple DSA driver.
> > 
> Andrew,
> 
> I've done a little research on DSA.
> I've read Documentation/networking/dsa/dsa.txt
> And I've looked over some examples in drivers/net/dsa/
> 
> It appears there are about 40 functions to implement.

For a minimal driver, you need a lot less. mv88e6060.c is a standalone
DSA driver and has 5 functions. 250 lines of code. You will also need
a new tag implementation, named something like net/dsa/tag_lan935x.c,
but that is only two functions.

> I see examples from only 2 manufacturers, and they average more than
> 2000 lines of code.

These are more fully featured switches, and the drivers do more than
the minimum. You should be aiming for your first submission to be a
minimal driver. Expose two ports, with a PHY each, send and receive
frames on each port.

Latter patches can add more features, like EEE, MIB counters, hardware
bridging of the ports, 802.1Q, reading and writing the EEPROM
etc. These are all optional features you can add later.

> I'm not yet sure how it attaches to the underlying Ethernet driver.

The DSA core does that for you. If you look at the device tree
binding:

        dsa@0 {
                compatible = "marvell,dsa";
                #address-cells = <2>;
                #size-cells = <0>;

                interrupts = <10>;
                dsa,ethernet = <&ethernet0>;

So this says which Ethernet interface to use. net/dsa/dsa.c will
create a slave interface per external port of your switch. This slave
is a netdev. Frames transmitted by this slave are fed through the tag
code to add additional headers/trailers, and then passed to this
ethernet device. Frames received by the ethernet again through the tag
code, stripping off any headers/trails and demuxing to the correct
slave.

> And I have no idea how I would test it at the end. 

The whole concept behind this is that the ports of the switch
behaviour like normal network interfaces. So test it the same way you
test an linux ethernet driver. ping, iperf, ethtool, etc. And add some
tests using a linux bridge.
 
> Given these issues, it will be hard to sell it to my manager.

With time, you can expect to see more switch chips gaining mainline
support. There is interest in implementing a DSA driver for the
Micrel/Kendin KS8995M and KSZ8864RMN chips, for example, which i think
are in the same or similar market segment as the lan935x devices.
 
> If it can be partly implemented, which parts should be implemented first?

I would suggest you first understand what the tag_ files are about,
and look at implementing for the lan935x. The datasheet talks about a
special VLAN tag with bits 0 and 1 indicating the outgoing port, if
bit 3 is zero. Then do a minimal driver, equivalent to
mv88e6060.c. FYI the datasheet of this device is publicly available.

	     Andrew
