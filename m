From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v3 0/9] Phy, mdiobus, and netdev struct device fixes
Date: Fri, 25 Sep 2015 00:33:03 +0100
Message-ID: <20150924233303.GJ21513@n2100.arm.linux.org.uk>
References: <20150924191754.GC21513@n2100.arm.linux.org.uk>
 <20150924215731.GE20825@lunn.ch>
 <20150924221541.GF21513@n2100.arm.linux.org.uk>
 <20150924225033.GI20825@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	David Miller <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	devicetree@vger.kernel.org, Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <rric@kernel.org>,
	Frank Rowand <frowand.list@gmail.com>,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	Rob Herring <robh+dt@kernel.org>,
	Michal Simek <michal.simek@xilinx.com>, netdev@vger.kernel.org,
	Soren Brinkmann <soren.brinkmann@xilinx.com>,
	Iyappan Subramanian <isubramanian@apm.com>,
	Grant Likely <grant.likely@linaro.org>,
	Li Yang <leoli@freescale.com>,
	Keyur Chudgar <kchudgar@apm.com>,
	linux-arm-kernel@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:45501 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753043AbbIXXdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 19:33:25 -0400
Content-Disposition: inline
In-Reply-To: <20150924225033.GI20825@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 25, 2015 at 12:50:33AM +0200, Andrew Lunn wrote:
> > Thanks for testing.  Please could you confirm whether the same behaviour
> > is observed without the patches, just to make absolutely sure that isn't
> > a regression.
> 
> So i tested this now.
> 
> I have two FEC interfaces. One i my main access interface, and the
> second is used by DSA to access switches. With your patches, the
> module Used by count is equal to the number of interfaces which are
> up.
> 
> Without your patches, the count is always 0.

That will be as a result of the MDIO bus module refcounting patch -
"phy: fix mdiobus module safety".  The code prior to that patch was
totally useless and ineffectual - it might as well not even have
been present, because it would never have any effect.  bus_module
would always be NULL in phy_attach_direct().

While my change makes the code start to work as originally intended,
it's still unsafe: there's nothing to stop you manually unbinding the
driver providing the MDIO bus from the struct device.  The driver
will then free the resources it claimed in its probe function, which
may include the MMIO mapping for the MDIO bus accessor functions.

If the accessors are then called, despite keeping the mdio bus, phy,
etc data structures properly refcounted, the kernel will oops when
the (many) MDIO bus drivers hit the free'd MMIO mapping.  This is,
unfortunately, just another pre-existing bug in this code.

To stop that, we need some way to say "this MDIO bus has been removed,
prevent further access" and that needs to be done in a race free way.
Right now, that doesn't exist.

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
