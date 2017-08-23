From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [EXT] Re: [PATCH net-next 03/18] net: mvpp2: set the SMI PHY
 address when connecting to the PHY
Date: Wed, 23 Aug 2017 14:34:24 +0200
Message-ID: <20170823123424.GA28612@lunn.ch>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
 <20170724134848.19330-4-antoine.tenart@free-electrons.com>
 <20170726160806.GF12049@lunn.ch>
 <20170728014905.GC24728@kwain>
 <20170728042153.GH18666@lunn.ch>
 <f6d8907b057241c7a72da0a0255cfd23@IL-EXCH01.marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "jason@lakedaemon.net" <jason@lakedaemon.net>,
        "gregory.clement@free-electrons.com"
        <gregory.clement@free-electrons.com>,
        "sebastian.hesselbarth@gmail.com" <sebastian.hesselbarth@gmail.com>,
        "thomas.petazzoni@free-electrons.com"
        <thomas.petazzoni@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>,
        "linux@armlinux.org.uk" <linux@armlinux.org.uk>,
        "mw@semihalf.com" <mw@semihalf.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>
To: Stefan Chulski <stefanc@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40888 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753915AbdHWMei (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Aug 2017 08:34:38 -0400
Content-Disposition: inline
In-Reply-To: <f6d8907b057241c7a72da0a0255cfd23@IL-EXCH01.marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 2. Auto-Negotiation with PHY devices connected to the GMAC ports.
> The device uses a standard master Serial Management Interface for reading from/writing to the PHY
> registers. In addition, the PHY polling unit performs Auto-Negotiation status update with PHY devices attached
> to the Network ports via the Master SMI Interface.
> The device polls the Status register of each PHY in a round-robin manner.
> If the device detects a change in the link from down to up on 1 of the ports, it performs a series of
> register reads from the PHY and updates the Auto-Negotiation results in the device's registers. The
> Port MAC Status register is updated with these results only if Auto-Negotiation is enabled.

Hi Stefan

That is what i was afraid off.

How clever is this phy polling hardware? e.g. Say somebody reads the
PHY temperature sensor:

commit 0b04680fdae464ee51409b8cb36005f6ef8bd689
Author: Andrew Lunn <andrew@lunn.ch>
Date:   Fri Jan 20 01:37:49 2017 +0100

    phy: marvell: Add support for temperature sensor
    
    Some Marvell PHYs have an inbuilt temperature sensor. Add hwmon
    support for this sensor.
    
    There are two different variants. The simpler, older chips have a 5
    degree accuracy. The newer devices have 1 degree accuracy.
    
    Signed-off-by: Andrew Lunn <andrew@lunn.ch>
    Signed-off-by: David S. Miller <davem@davemloft.net>


This requires changing the PHY page to 0x1a. Any reads the polling
unit does at that time are going to get registers from page 0x1a, not
0x0.

And there are other examples where the page may change,
e.g. configuring WOL, LEDs. Cable test is not yet supported, but it is
on my todo list.

In order to safely read/write the PHY, you need to hold the PHY mutex.
Unless the hardware is very smart, please don't enable this. Let the
phylib and the appropriate PHY driver do the work.

       Andrew
