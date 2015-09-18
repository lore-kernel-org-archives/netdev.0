From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: [PATCH 0/7] Phy and mdiobus fixes
Date: Fri, 18 Sep 2015 10:46:25 +0100
Message-ID: <20150918094625.GB21084@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devicetree@vger.kernel.org, Frank Rowand <frowand.list@gmail.com>,
	Grant Likely <grant.likely@linaro.org>,
	Iyappan Subramanian <isubramanian@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, Li Yang <leoli@freescale.com>,
	Michal Simek <michal.simek@xilinx.com>, netdev@vger.kernel.org,
	Robert Richter <rric@kernel.org>,
	Rob Herring <robh+dt@kernel.org>,
	=?iso-8859-1?Q?S=F6ren?= Brinkmann <soren.brinkmann@xilinx.com>,
	Sunil Goutham <sgoutham@cavium.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:57535 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752131AbbIRJqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 05:46:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

While looking at the phy code, I identified a number of weaknesses
where refcounting on device structures was being leaked, where
modules could be removed while in-use, and where the fixed-phy could
end up having unintended consequences caused by incorrect calls to
fixed_phy_update_state().

This patch series resolves those issues, some of which were discovered
with testing on an Armada 388 board.  Not all patches are fully tested,
particularly the one which touches several network drivers.

When resolving the struct device refcounting problems, several different
solutions were considered before settling on the implementation here -
one of the considerations was to avoid touching many network drivers.
The solution here is:

	phy_attach*() - takes a refcount
	phy_detach*() - drops the phy_attach refcount

Provided drivers always attach and detach their phys, which they should
already be doing, this should change nothing, even if they leak a refcount.

	of_phy_find_device() and of_* functions which use that take
	a refcount.  Arrange for this refcount to be dropped once
	the phy is attached.

This is the reason why the previous change is important - we can't drop
this refcount taken by of_phy_find_device() until something else holds
a reference on the device.  This resolves the leaked refcount caused by
using of_phy_connect() or of_phy_attach().

Even without the above changes, these drivers are leaking by calling
of_phy_find_device().  These drivers are addressed by adding the
appropriate release of that refcount.

The mdiobus code also suffered from the same kind of leak, but thankfully
this only happened in one place - the mdio-mux code.

I also found that the try_module_get() in the phy layer code was utterly
useless: phydev->dev.driver was guaranteed to always be NULL, so
try_module_get() was always being called with a NULL argument.  I proved
this with my SFP code, which declares its own MDIO bus - the module use
count was never incremented irrespective of how I set the MDIO bus up.
This allowed the MDIO bus code to be removed from the kernel while there
were still PHYs attached to it.

One other bug was discovered: while using in-band-status with mvneta, it
was found that if a real phy is attached with in-band-status enabled,
and another ethernet interface is using the fixed-phy infrastructure, the
interface using the fixed-phy infrastructure is configured according to
the other interface using the in-band-status - which is caused by the
fixed-phy code not verifying that the phy_device passed in is actually
a fixed-phy device, rather than a real MDIO phy.

Lastly, having mdio_bus reversing phy_device_register() internals seems
like a layering violation - it's trivial to move that code to the phy
device layer.

 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c    | 23 ++++++---
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 19 +++++++
 drivers/net/ethernet/freescale/gianfar.c          |  6 ++-
 drivers/net/ethernet/freescale/ucc_geth.c         |  8 ++-
 drivers/net/ethernet/marvell/mvneta.c             |  2 +
 drivers/net/ethernet/xilinx/xilinx_emaclite.c     |  2 +
 drivers/net/phy/fixed_phy.c                       |  2 +-
 drivers/net/phy/mdio-mux.c                        | 19 ++++---
 drivers/net/phy/mdio_bus.c                        | 24 ++++++---
 drivers/net/phy/phy_device.c                      | 62 ++++++++++++++++++-----
 drivers/of/of_mdio.c                              | 27 ++++++++--
 include/linux/phy.h                               |  6 ++-
 12 files changed, 156 insertions(+), 44 deletions(-)

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
