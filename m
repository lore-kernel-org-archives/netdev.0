From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH v5 00/13] net: mv643xx_eth DT support and fixes
Date: Wed, 29 May 2013 21:32:42 +0200
Message-ID: <1369855975-21489-1-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:56257 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966032Ab3E2TdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 15:33:10 -0400
In-Reply-To: <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set picks up work by Florian Fainelli bringing full DT
support to mv643xx_eth and Marvell SoCs using it.

The current v5 patch set drops 1:1 compatibiliy with PPC binding
for two reasons:
(a) PPC parses DT nodes in arch/ppc/sysdev and creates non-DT
    platform_devices itself,
(b) property and node naming for new ethernet devices is slightly
    different ("phy" vs "phy-handle", "marvell," prefix)

Anyway, the two bindings are functionally compatible and PPC bindings
can be converted if desireable. The patch set if fully bisectable and
care has been taken to (a) not reparse on PPC platforms, (b) allow to
use platform_device based registration even if on CONFIG_OF. Not tested
is double registration issues, i.e. if DT nodes are provided but legacy
registration it not yet removed. This double registration should lead
to either non-DT or DT registered device fail on already claimed
ressources.

Also this patch set picks up the opportunity to fix some repeatedly
reported issues with modular mvmdio/mv643xx_eth loading, unloading,
and reloading. It has been tested on SolidRun CuBox (Dove) and
Seagate Dockstar, QNAP, and USI Topkick (Kirkwood) by me or Andrew
Lunn.

Patch 1 fixes an issue introduced with switch to separate mvmdio
driver, where detaching mv643xx_eth from a phy will not stop the
phy state machine and finally dereference the already removed network
device. Using phy_disconnect properly stops the phy state machine
before detaching from it. Perhaps, this patch should go back in
stable (most likely 3.9 only) if mvmdio separation patch went in
there.

Patch 2 makes use of managed devm_ioremap for the last remaining
non-managed resource.

Patches 3-4 prepare DT support for mv643xx_eth by adding a phy_node
pointer to platform_data and exploiting that phy_node when attaching
to a phy.

Patch 5 adds a Kirkwood specific workaround for PORT_SERIAL_CTRL1
register which is reset to loopback mode when clocks are gated.

Patch 6 introduces DT parsing support for mv643xx_eth by adding a
match table for marvell,orion-eth and marvell,kirkwood-eth to the
shared driver and adding a platform_device for each of its child
nodes.

Patches 7-9 add corresponding device tree nodes to Marvell Dove,
Kirkwood, and Orion5x including all boards. Where known, also
the PHY compatible string has been set to what is reported in the
boards boot loader.

Patches 10, 11-12, and 14 finally remove all legacy platform_device
based registration from Dove, Kirkwood, and Orion5x DT setup. For
Kirkwood also now obsolete board specific setup is removed from
common DT board setup, Kconfig, Makefile, and kirkwood_defconfig.

For the patches above I suggest to take Patches 1-6 through David
Miller's branch, and Patches 7-12 through Jason Cooper's when the
former have appeared on mainline linux. The patch set has been based
on v3.10-rc3.

Overall Changelog:
v4->v5: v5 drops Kirkwood MAC address workaround by using DT
  property because OF API does not allow to modify properties
  easily. Instead the current workaround by not gating ge clocks
  is kept. The OF property workaround is postponed until some
  easy to use of_set_property is available.

Sebastian Hesselbarth (13):
  net: mv643xx_eth: use phy_disconnect instead of phy_detach
  net: mv643xx_eth: use managed devm_ioremap for port registers
  net: mv643xx_eth: add phy_node to platform_data struct
  net: mv643xx_eth: use of_phy_connect if phy_node present
  net: mv643xx_eth: proper initialization for Kirkwood SoCs
  net: mv643xx_eth: add DT parsing support
  ARM: dove: add gigabit ethernet and mvmdio device tree nodes
  ARM: kirkwood: add gigabit ethernet and mvmdio device tree nodes
  ARM: orion5x: add gigabit ethernet and mvmdio device tree nodes
  ARM: dove: remove legacy mv643xx_eth setup
  ARM: kirkwood: remove legacy clk alias for mv643xx_eth
  ARM: kirkwood: remove redundant DT board files
  ARM: orion5x: remove legacy mv643xx_eth board setup

 .../devicetree/bindings/net/marvell-orion-net.txt  |   85 +++++++++
 arch/arm/boot/dts/dove-cubox.dts                   |    7 +
 arch/arm/boot/dts/dove.dtsi                        |   35 ++++
 arch/arm/boot/dts/kirkwood-cloudbox.dts            |   16 ++
 arch/arm/boot/dts/kirkwood-dnskw.dtsi              |   16 ++
 arch/arm/boot/dts/kirkwood-dockstar.dts            |   17 ++
 arch/arm/boot/dts/kirkwood-dreamplug.dts           |   28 +++
 arch/arm/boot/dts/kirkwood-goflexnet.dts           |   16 ++
 .../arm/boot/dts/kirkwood-guruplug-server-plus.dts |   30 +++
 arch/arm/boot/dts/kirkwood-ib62x0.dts              |   16 ++
 arch/arm/boot/dts/kirkwood-iconnect.dts            |   16 ++
 arch/arm/boot/dts/kirkwood-iomega_ix2_200.dts      |   24 +++
 arch/arm/boot/dts/kirkwood-is2.dts                 |    2 +
 arch/arm/boot/dts/kirkwood-km_kirkwood.dts         |   16 ++
 arch/arm/boot/dts/kirkwood-lsxl.dtsi               |   28 +++
 arch/arm/boot/dts/kirkwood-mplcec4.dts             |   27 +++
 .../boot/dts/kirkwood-netgear_readynas_duo_v2.dts  |   16 ++
 arch/arm/boot/dts/kirkwood-ns2-common.dtsi         |   16 ++
 arch/arm/boot/dts/kirkwood-ns2.dts                 |    2 +
 arch/arm/boot/dts/kirkwood-ns2lite.dts             |    2 +
 arch/arm/boot/dts/kirkwood-ns2max.dts              |    2 +
 arch/arm/boot/dts/kirkwood-ns2mini.dts             |    2 +
 arch/arm/boot/dts/kirkwood-openblocks_a6.dts       |   16 ++
 arch/arm/boot/dts/kirkwood-topkick.dts             |   16 ++
 arch/arm/boot/dts/kirkwood-ts219-6281.dts          |    4 +-
 arch/arm/boot/dts/kirkwood-ts219-6282.dts          |    4 +-
 arch/arm/boot/dts/kirkwood-ts219.dtsi              |   16 ++
 arch/arm/boot/dts/kirkwood.dtsi                    |   52 ++++++
 .../dts/orion5x-lacie-ethernet-disk-mini-v2.dts    |   17 ++
 arch/arm/boot/dts/orion5x.dtsi                     |   29 +++
 arch/arm/configs/kirkwood_defconfig                |   16 --
 arch/arm/mach-dove/board-dt.c                      |    9 -
 arch/arm/mach-kirkwood/Kconfig                     |  117 ------------
 arch/arm/mach-kirkwood/Makefile                    |   16 --
 arch/arm/mach-kirkwood/board-dnskw.c               |    7 -
 arch/arm/mach-kirkwood/board-dockstar.c            |   32 ----
 arch/arm/mach-kirkwood/board-dreamplug.c           |   35 ----
 arch/arm/mach-kirkwood/board-dt.c                  |   64 +------
 arch/arm/mach-kirkwood/board-goflexnet.c           |   34 ----
 arch/arm/mach-kirkwood/board-guruplug.c            |   33 ----
 arch/arm/mach-kirkwood/board-ib62x0.c              |   29 ---
 arch/arm/mach-kirkwood/board-iconnect.c            |   10 -
 arch/arm/mach-kirkwood/board-iomega_ix2_200.c      |   34 ----
 arch/arm/mach-kirkwood/board-km_kirkwood.c         |   44 -----
 arch/arm/mach-kirkwood/board-lsxl.c                |   16 --
 arch/arm/mach-kirkwood/board-mplcec4.c             |   14 --
 arch/arm/mach-kirkwood/board-ns2.c                 |   35 ----
 arch/arm/mach-kirkwood/board-openblocks_a6.c       |   26 ---
 arch/arm/mach-kirkwood/board-readynas.c            |    6 -
 arch/arm/mach-kirkwood/board-ts219.c               |   13 --
 arch/arm/mach-kirkwood/board-usi_topkick.c         |   29 ---
 arch/arm/mach-orion5x/edmini_v2-setup.c            |   10 -
 drivers/net/ethernet/marvell/mv643xx_eth.c         |  194 ++++++++++++++++++--
 include/linux/mv643xx_eth.h                        |    2 +
 54 files changed, 754 insertions(+), 644 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/marvell-orion-net.txt
 delete mode 100644 arch/arm/mach-kirkwood/board-dockstar.c
 delete mode 100644 arch/arm/mach-kirkwood/board-dreamplug.c
 delete mode 100644 arch/arm/mach-kirkwood/board-goflexnet.c
 delete mode 100644 arch/arm/mach-kirkwood/board-guruplug.c
 delete mode 100644 arch/arm/mach-kirkwood/board-ib62x0.c
 delete mode 100644 arch/arm/mach-kirkwood/board-iomega_ix2_200.c
 delete mode 100644 arch/arm/mach-kirkwood/board-km_kirkwood.c
 delete mode 100644 arch/arm/mach-kirkwood/board-ns2.c
 delete mode 100644 arch/arm/mach-kirkwood/board-openblocks_a6.c
 delete mode 100644 arch/arm/mach-kirkwood/board-usi_topkick.c
---
Cc: David Miller <davem@davemloft.net>
Cc: Lennert Buytenhek <buytenh@wantstofly.org>
Cc: Jason Cooper <jason@lakedaemon.net>
Cc: Andrew Lunn <andrew@lunn.ch>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: netdev@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-kernel@vger.kernel.org
-- 
1.7.10.4
