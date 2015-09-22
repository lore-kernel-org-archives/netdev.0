From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: dsa: actually force the speed on the CPU port
Date: Tue, 22 Sep 2015 03:18:54 +0200
Message-ID: <20150922011854.GB20288@lunn.ch>
References: <E1Ze7vP-00073u-57@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40909 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757437AbbIVB1D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Sep 2015 21:27:03 -0400
Content-Disposition: inline
In-Reply-To: <E1Ze7vP-00073u-57@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 21, 2015 at 09:42:59PM +0100, Russell King wrote:
> Commit 54d792f257c6 ("net: dsa: Centralise global and port setup
> code into mv88e6xxx.") merged in the 4.2 merge window broke the link
> speed forcing for the CPU port of Marvell DSA switches.  The original
> code was:
> 
>         /* MAC Forcing register: don't force link, speed, duplex
>          * or flow control state to any particular values on physical
>          * ports, but force the CPU port and all DSA ports to 1000 Mb/s
>          * full duplex.
>          */
>         if (dsa_is_cpu_port(ds, p) || ds->dsa_port_mask & (1 << p))
>                 REG_WRITE(addr, 0x01, 0x003e);
>         else
>                 REG_WRITE(addr, 0x01, 0x0003);
> 
> but the new code does a read-modify-write:
> 
>                 reg = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_PCS_CTRL);
>                 if (dsa_is_cpu_port(ds, port) ||
>                     ds->dsa_port_mask & (1 << port)) {
>                         reg |= PORT_PCS_CTRL_FORCE_LINK |
>                                 PORT_PCS_CTRL_LINK_UP |
>                                 PORT_PCS_CTRL_DUPLEX_FULL |
>                                 PORT_PCS_CTRL_FORCE_DUPLEX;
>                         if (mv88e6xxx_6065_family(ds))
>                                 reg |= PORT_PCS_CTRL_100;
>                         else
>                                 reg |= PORT_PCS_CTRL_1000;
> 
> The link speed in the PCS control register is a two bit field.  Forcing
> the link speed in this way doesn't ensure that the bit field is set to
> the correct value - on the hardware I have here, the speed bitfield
> remains set to 0x03, resulting in the speed not being forced to gigabit.
> 
> We must clear both bits before forcing the link speed.
> 
> Fixes: 54d792f257c6 ("net: dsa: Centralise global and port setup code into mv88e6xxx.")
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Acked-by: Andrew Lunn <andrew@lunn.ch>

Thanks for fixing this Russell

       Andrew
