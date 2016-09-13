From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 3/3] net-next: dsa: add new driver for qca8xxx family
Date: Tue, 13 Sep 2016 15:14:08 +0200
Message-ID: <20160913131408.GE15332@lunn.ch>
References: <1473669337-21221-1-git-send-email-john@phrozen.org>
 <1473669337-21221-4-git-send-email-john@phrozen.org>
 <20160913012304.GC3585@lunn.ch>
 <5c028659-db7e-9a98-7ec1-1e2d19d135f9@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        qsdk-review@qca.qualcomm.com
To: John Crispin <john@phrozen.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5c028659-db7e-9a98-7ec1-1e2d19d135f9@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 13, 2016 at 11:40:43AM +0200, John Crispin wrote:
> 
> 
> On 13/09/2016 03:23, Andrew Lunn wrote:
> > So lets see if i have this right.
> > 
> > Port 0 has no internal phy.
> > Port 1 has an internal PHY at MDIO address 0.
> > Port 2 has an internal PHY at MDIO address 1.
> > ...
> > Port 5 has an internal PHY ad MDIO address 4.
> > Port 6 has no internal PHY.
> 
> Hi Andrew
> 
> correct. port 0 is the cpu port. I initially thought that port6 can also
> be used as te cpu port but there are various places in the datasheet
> stating that the cpu port is 0.

O.K, please correct the comments in the code, and make this clear in
the device tree binding.

> in some of the reference designs, port6
> is wired to a 2nd gmac of the cpu and in those cases port 6 is then
> hardwired to port 5 of the switch and called wan. right now the driver
> does not support this feature.

Hum, why not?

brctl addbr br1
brctl addif br1 port5
brctl addif br1 port6

They are just ports on a switch, so bridge them together.

> ok, i will simply substract 1 from the phy_addr inside the mdio
> callbacks. this would make the code more readable and make the DT
> binding compliant with the ePAPR spec.

It does however need well commenting. It is setting a trap for anybody
who puts an external PHY on port 6. If they access that PHY via these
functions, the address is off by one.

This is the first silicon vendor who made their MDIO addresses for
PHYs illogical. So i'm thinking we maybe should add a new function to
dsa_switch_ops.

	/* Return the MDIO address for the PHY for this port. */
        int     (*phy_port_map(struct dsa_switch *ds, int port);

This should return the MDIO address for integrated PHYs only, or
-ENODEV if the port does not have an integrated PHY. For an external
PHY, a phy-handle should be used. This phy_port_map() is used in
dsa_slave_phy_setup(). But dsa_slave_phy_setup() is already too
complex, so it needs doing with care.

	 Andrew
