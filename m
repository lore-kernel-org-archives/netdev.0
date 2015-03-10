From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: RFC: dsa: add support for multiple CPU ports
Date: Tue, 10 Mar 2015 20:21:01 +0100
Message-ID: <20150310192101.GD10838@lunn.ch>
References: <20150310190129.GB5636@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux@roeck-us.net, jogo@openwrt.org,
	f.fainelli@gmail.com
To: Mathieu Olivari <mathieu@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57075 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752964AbbCJTYX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 15:24:23 -0400
Content-Disposition: inline
In-Reply-To: <20150310190129.GB5636@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 10, 2015 at 12:01:29PM -0700, Mathieu Olivari wrote:
> Hi all,
> 
> I???m writing a DSA driver for some QCA network switches already supported in
> OpenWrt using swconfig. They connect to the CPU using MDIO for configuration,
> and xMII ports for data. The main difference with what is supported comes from
> the fact that most of these switches actually have multiple xMII connections to
> the same CPU. Something like this:
> (extending the picture from http://lwn.net/Articles/302333/)
> 
> 	+-----------+       +-----------+
> 	|           | RGMII |           |
> 	|       eth0+-------+           +------ 1000baseT MDI ("WAN")
> 	|        wan|       |  7-port   +------ 1000baseT MDI ("LAN1")
> 	|   CPU     |       |  ethernet +------ 1000baseT MDI ("LAN2")
> 	|           | RGMII |  switch   +------ 1000baseT MDI ("LAN3")
> 	|       eth1+-------+  w/5 PHYs +------ 1000baseT MDI ("LAN4")
> 	|        lan|       |           |
> 	+-----------+       +-----------+
> 	          |   MDIO     |
> 	          \------------/
> 
> In a typical configuration, we configure the switch to isolate WAN & LAN from
> each other.

Hi Mathieu

By default, all DSA ports are isolated from each other. If you want to
join them together you need to setup a bridge and add the ports to the
bridge. There are patches being worked on to push this bridge state
down into the hardware, so the hardware will then bridge across these
ports, rather than having to do it in software. So long as you don't
add WAN to the bridge, it will be kept isolated.

I had a different solution in mind for multiple CPU ports. I've no
idea if it actually works though, i've not had time to investigate.
It would actually put the host CPU ports into a switch trunk, and use
team/bond driver on the host. You then get one logical 2Gbp link to
the switch and run DSA over that.

There have also been some patches to create trunks, but they were for
normal ports, not CPU ports. They should however be a good starting
point for what the switch driver needs to do to create a trunk towards
the CPU.

I think this scheme might also work without having to change the DSA
binding. There is nothing in the binding documentation that there can
only be one CPU port. So if two or more are found, the DSA framework
can do the trunking setup.

    Andrew
