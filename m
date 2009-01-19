From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: 802.1Q support?
Date: Mon, 19 Jan 2009 10:14:46 +0100
Message-ID: <20090119091446.GC17124@xi.wantstofly.org>
References: <200901121148.26905.rgetz@blackfin.uclinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Robin Getz <rgetz@blackfin.uclinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:38971 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754556AbZASJOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 04:14:48 -0500
Content-Disposition: inline
In-Reply-To: <200901121148.26905.rgetz@blackfin.uclinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 12, 2009 at 11:48:26AM -0500, Robin Getz wrote:

> I'm trying to understand the "standard" way to control a switch which supports 
> VLAN.
> 
> Pick any one of:
>  
> Infineon XWAY ADM6999 (eight-port 10/100 plus one MII) 
> http://www.infineon.com/cms/en/product/channel.html?channel=ff80808112ab681d0112ab68ce8d0043
>  
> Micrel MS8993M (2 port 10/100 plus one MII)
> http://www.micrel.com/_PDF/Ethernet/ks8993m_pb.pdf 
>  
> Broadcom BCM5325E (five port 10/100 plus one MII)
> http://www.broadcom.com/collateral/pb/5325E-PB00-R.pdf
>  
> Realtek (five port 10/100 plus one MII) 
> http://www1.futureelectronics.com/doc/REALTEK%20SEMICONDUCTOR/Realtek%20Semiconductor%20RTL8306SD-GR.pdf
>  
> They all have multiple MAC/PHYs which are exposed to the wire, and a single 
> MII interface - which normally connects directly to a SOC's MII/MAC.

The DSA subsystem in the mainline kernel (net/dsa) needs three things:

1. A way to initialise and configure the switch chip.

2. A way to tell, for packets received from the switch, which
   physical interface this packet came from.

3. A way to tell the switch to transmit packets out a certain
   physical interface.

All switch chips currently supported use MDIO accesses for (1), but at
least some of the chips also support configuration by sending the
commands via specially crafted ethernet frames (which would be easy to
add support for), or you can use SPI, or toggle GPIOs, or whatever you
want.

(2) and (3) are typically done by adding a couple of bytes to the
ethernet packet.  Marvell switches support at least four different
methods (three of them implemented), Micrel switches have their own
method, Broadcom switches probably have their own method, etc.  Note
that you're not limited to conveying this info in the packet payload
-- as long as you provide a packet transmit function and have a way
of delivering received packets to the right hook, you can use any
method you want, including specifying the physical port number in
the packet DMA descriptor, reading/writing the physical port number
to a special register, etc.


> I would have thought that there would be separate drivers for these in the 
> phylib, but I didn't find anything that looked like it would work. (or expose 
> the right interface (all the vendor specific VLAN registers) so I can program 
> them properly from userspace)...

phylib isn't the right place, IMHO, since the switch isn't necessarily
configured via MDIO (or even attached to MDIO).
