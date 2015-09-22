From: Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Subject: [PATCH v2 0/9] Phy, mdiobus, and netdev struct device fixes
Date: Tue, 22 Sep 2015 17:17:10 +0100
Message-ID: <20150922161710.GA21084@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>,
	Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Li Yang <leoli-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Michal Simek <michal.simek-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Robert Richter <rric-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Soren Brinkmann <soren.brinkmann-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	Sunil Goutham <sgoutham-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
	Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is the second version of the series, with the comments David had
on the first patch fixed up.  Original series description with updated
diffstat below.

While looking at the DSA code, I noticed we have a
of_find_net_device_by_node(), and it looks like users of that are
similarly buggy - it looks like net/dsa/dsa.c is the only user.  Fix
that too.

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
 net/core/net-sysfs.c                              |  9 ++++
 net/dsa/dsa.c                                     | 41 ++++++++++++---
 14 files changed, 199 insertions(+), 51 deletions(-)

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
