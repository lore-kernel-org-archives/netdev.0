From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next,V2] Add LAN9352 Ethernet Driver
Date: Tue, 16 Feb 2016 21:21:52 +0100
Message-ID: <20160216202152.GB2558@lunn.ch>
References: <90A7E81AE28BAE4CBDDB3B35F187D264402EF4A2@CHN-SV-EXMX02.mchp-main.com>
 <20160211215523.GE26333@lunn.ch>
 <90A7E81AE28BAE4CBDDB3B35F187D264402EF5AC@CHN-SV-EXMX02.mchp-main.com>
 <20160212171113.GC13273@lunn.ch>
 <90A7E81AE28BAE4CBDDB3B35F187D264402EFAF5@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Bryan.Whitehead@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47722 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756010AbcBPUV4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 15:21:56 -0500
Content-Disposition: inline
In-Reply-To: <90A7E81AE28BAE4CBDDB3B35F187D264402EFAF5@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So you mean mdiobus_scan()
http://lxr.free-electrons.com/source/drivers/net/phy/mdio_bus.c#L349

actually finds three PHY devices. Two are real phys with magnetics and
somewhere to attach a copper cable, and one is virtual.

This is non-obvious. I think it would be good to add some ASCII art to
the binding documentation to explain what this device looks like, and
which address on the MDIO bus maps to what phy.

There is also the issue of which way around is this phy. Typically in
a DSA setup you have:

      +-----------+       +-----------+
      |           | RGMII |           |
      |           +-------+           +------ 1000baseT MDI ("WAN")
      |           |       |  6-port   +------ 1000baseT MDI ("LAN1")
      |    CPU    |       |  ethernet +------ 1000baseT MDI ("LAN2")
      |           |MIImgmt|  switch   +------ 1000baseT MDI ("LAN3")
      |           +-------+  w/5 PHYs +------ 1000baseT MDI ("LAN4")
      |           |       |           |
      +-----------+       +-----------+

Each MDI port has a phy on it. These are your two real PHYs.

Another possible setup, but not very frequently seen is:

      +-----------+                        +-----------+
      |           | RGMII             RGMII|           |
      |           +-------PHY -- PHY ------+           +------ 1000baseT MDI ("WAN")
      |           |                        |  6-port   +------ 1000baseT MDI ("LAN1")
      |    CPU    |                        |  ethernet +------ 1000baseT MDI ("LAN2")
      |           |    MIImgmt             |  switch   +------ 1000baseT MDI ("LAN3")
      |           +------------------------+  w/5 PHYs +------ 1000baseT MDI ("LAN4")
      |           |                        |           |
      +-----------+                        +-----------+

In this setup, you have a short copper section between the two PHYs
copper ports, and the MAC side is connected to a MAC, be it the CPU
MAC or the switch MAC.

The switch you are talking about only has one of these PHYs. Does it
connect to the CPU MAC or the switch MAC? What use is that? Does the
link status tell you anything? Can it be down? Auto negotiation is
meaningless, since there is no link partner. Can you change the speed
to 10/half? What does ethtool show for this phy?

I think we need to understand this PHY before deciding if we need to
include it in the driver model or not. It is so odd, it might be
better to ignore it.

Thanks
	Andrew
