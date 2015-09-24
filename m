From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v3 0/9] Phy, mdiobus, and netdev struct device fixes
Date: Thu, 24 Sep 2015 23:15:41 +0100
Message-ID: <20150924221541.GF21513@n2100.arm.linux.org.uk>
References: <20150924191754.GC21513@n2100.arm.linux.org.uk>
 <20150924215731.GE20825@lunn.ch>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150924215731.GE20825@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 24, 2015 at 11:57:31PM +0200, Andrew Lunn wrote:
> Hi Russell
> 
> I tested both of these with my board. It is a Freescale Vybrid, using
> the FEC ethernet driver, and i have three switches attached, using
> mdio-mux to give three mdio busses.
> 
> No obvious regressions, my board boots, the switches are all present
> and correct. I built the FEC driver as a module, and it won't unload:
> 
>  kernel:unregister_netdevice: waiting for eth1 to become free. Usage count = 1
> unregister_netdevice: waiting for eth1 to become free. Usage count = 1
> 
> i assume because DSA holds a reference. I've not tried a fully module
> build, DSA has issues with that.
> 
> Tested-by: Andrew Lunn <andrew@lunn.ch>

Thanks for testing.  Please could you confirm whether the same behaviour
is observed without the patches, just to make absolutely sure that isn't
a regression.

However, I think you are correct - I'm unable to locate where in the
DSA code:
- dst->master_dev's dev_hold() is undone (hence a reference left)
- dst is freed - dsa_probe() allocates it using kzalloc(), but
  dsa_remove() and it's children don't free this structure.

There's no notifier which detects whether the underlying device has
gone away - it registers a netdev notifier (dsa_slave_netdevice_event)
but this only deals with slave devices, not the master device.

Thanks.

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
