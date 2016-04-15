From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Subject: Re: [PATCH] net: phy: Ensure the state machine is called when phy is
 UP
Date: Fri, 15 Apr 2016 22:56:13 +0200
Message-ID: <20160415205613.GE25196@piout.net>
References: <1460750172-7796-1-git-send-email-alexandre.belloni@free-electrons.com>
 <57114AA4.5080803@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:41796 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750765AbcDOU4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 16:56:16 -0400
Content-Disposition: inline
In-Reply-To: <57114AA4.5080803@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/04/2016 at 13:10:12 -0700, Florian Fainelli wrote :
> On 15/04/16 12:56, Alexandre Belloni wrote:
> > Commit d5c3d84657db ("net: phy: Avoid polling PHY with
> > PHY_IGNORE_INTERRUPTS") removed the last polling done on the phy. Since
> > then, the last actual poll done on the phy happens PHY_STATE_TIME seconds
> > (that is actually one second) after registering the phy. If the interface
> > is not UP by that time, any previous IRQ indicating the link is up is
> > ignored. Moreover, nothing will start the autonegociation so the phy will
> > simply change from READY to UP and never actually go to RUNNING.
> 
> What do you mean by that? phy_start() will start auto-negotiation.
> 

In my case, it doesn't because it switches the state from PHY_READY to
PHY_UP but phy_state_machine() is never called afterwards.

> > The one second delay explains why the issue is not seen when booting from
> > NFS or when the interface is configured at boot time.
> > 
> > To solve that, ensure the state machine is called as soon as the state
> > changes from READY to UP.
> 
> The fix may be good, but I would like to see which driver are you
> observing this with? Also, having a capture of the PHY state machine
> with debug prints enabled could help us figure out the sequence of
> events leading to what you observed.
> 

I'm using a macb with a Micrel KSZ8081.

Trace without my patch:
libphy: MACB_mii_bus: probed
macb f8020000.ethernet eth0: Cadence GEM rev 0x00020120 at 0xf8020000 irq 27 (fc:c2:3d:0c:6e:05)
Micrel KSZ8081 or KSZ8091 f8020000.etherne:01: attached PHY driver [Micrel KSZ8081 or KSZ8091] (mii_bus:phy_addr=f8020000.etherne:01, irq=171)
Micrel KSZ8081 or KSZ8091 f8020000.etherne:01: PHY state change READY -> READY
[...]
Micrel KSZ8081 or KSZ8091 f8020000.etherne:01: PHY state change READY -> READY
[...]
# ifconfig eth0 up
IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready


With my patch:
libphy: MACB_mii_bus: probed
macb f8020000.ethernet eth0: Cadence GEM rev 0x00020120 at 0xf8020000 irq 27 (fc:c2:3d:0c:6e:05)
Micrel KSZ8081 or KSZ8091 f8020000.etherne:01: attached PHY driver [Micrel KSZ8081 or KSZ8091] (mii_bus:phy_addr=f8020000.etherne:01, irq=171)
Micrel KSZ8081 or KSZ8091 f8020000.etherne:01: PHY state change READY -> READY
[...]
Micrel KSZ8081 or KSZ8091 f8020000.etherne:01: PHY state change READY -> READY
[...]
# ifconfig eth0 up
IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
Micrel KSZ8081 or KSZ8091 f8020000.etherne:01: PHY state change UP -> AN
Micrel KSZ8081 or KSZ8091 f8020000.etherne:01: PHY state change AN -> NOLINK
macb f8020000.ethernet eth0: link up (100/Full)
Micrel KSZ8081 or KSZ8091 f8020000.etherne:01: PHY state change CHANGELINK -> RUNNING
IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready



> Assuming you might be using the macb driver, I see a race condition in
> how macb_probe() registers for its MDIO bus and probes for the PHY,
> after calling register_netdev(), which is something that is not good,
> because as soon as register_netdev() is called, an in-kernel notifier
> can start opening the device for use before you have returned...
> 

Well, I'm not sure  I'm running into that because phy_start() is only called
once I open the interface from userspace.


-- 
Alexandre Belloni, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
