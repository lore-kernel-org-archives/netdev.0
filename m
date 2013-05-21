From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH v4 00/12] net: mv643xx_eth DT support and fixes
Date: Tue, 21 May 2013 18:41:38 +0200
Message-ID: <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1367854420-8006-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Jason Cooper <jason@lakedaemon.net>,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 linuxppc-dev@lists.ozlabs.org, David Miller <davem@davemloft.net>,
 Lennert Buytenhek <buytenh@wantstofly.org>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1367854420-8006-1-git-send-email-sebastian.hesselbarth@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This patch set picks up work by Florian Fainelli bringing full DT
support to mv643xx_eth and Marvell SoCs using it.

The current v4 patch set drops 1:1 compatibiliy with PPC binding
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
Seagate Dockstar (Kirkwood) so far.

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

Patch 5 introduces DT parsing support for mv643xx_eth by adding a
match table to the shared driver and adding a platform_device for
each of its child nodes.

Patches 6-8 add corresponding device tree nodes to Marvell Dove,
Kirkwood, and Orion5x including all boards. Where known, also
the PHY compatible string has been set to what is reported in the
boards boot loader.

Patches 9, 10-11, and 12 finally remove all legacy platform_device
based registration from Dove, Kirkwood, and Orion5x DT setup. For
Kirkwood also now obsolete board specific setup is removed from
common DT board setup, Kconfig, Makefile, and kirkwood_defconfig.

For the patches above I suggest to take Patches 1-5 through David
Miller's branch, and Patches 6-12 through Jason Cooper's when they
have appeared on mainline linux. The patch set has been based on
todays net-next, if I shall rebase them on any other branch please
name it.

Sebastian Hesselbarth (12):
  net: mv643xx_eth: use phy_disconnect instead of phy_detach
  net: mv643xx_eth: use managed devm_ioremap for port registers
  net: mv643xx_eth: add phy_node to platform_data struct
  net: mv643xx_eth: use of_phy_connect if phy_node present
  net: mv643xx_eth: add DT parsing support
  ARM: dove: add gigabit ethernet and mvmdio device tree nodes
  ARM: kirkwood: add gigabit ethernet and mvmdio device tree nodes
  ARM: orion5x: add gigabit ethernet and mvmdio device tree nodes
  ARM: dove: remove legacy mv643xx_eth setup
  ARM: kirkwood: remove legacy clk alias for mv643xx_eth
  ARM: kirkwood: remove redundant DT board files
  ARM: orion5x: remove legacy mv643xx_eth board setup

 .../devicetree/bindings/net/marvell-orion-net.txt  |   83 +++++++++
 arch/arm/boot/dts/dove-cubox.dts                   |    7 +
 arch/arm/boot/dts/dove.dtsi                        |   35 ++++
 arch/arm/boot/dts/kirkwood-cloudbox.dts            |   16 ++
 arch/arm/boot/dts/kirkwood-dnskw.dtsi              |   16 ++
 arch/arm/boot/dts/kirkwood-dockstar.dts            |   17 ++
 arch/arm/boot/dts/kirkwood-dreamplug.dts           |   28 +++
 arch/arm/boot/dts/kirkwood-goflexnet.dts           |   16 ++
 .../arm/boot/dts/kirkwood-guruplug-server-plus.dts |   30 ++++
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
 arch/arm/boot/dts/orion5x.dtsi                     |   29 ++++
 arch/arm/configs/kirkwood_defconfig                |   16 --
 arch/arm/mach-dove/board-dt.c                      |    9 -
 arch/arm/mach-kirkwood/Kconfig                     |  117 -------------
 arch/arm/mach-kirkwood/Makefile                    |   16 --
 arch/arm/mach-kirkwood/board-dnskw.c               |    7 -
 arch/arm/mach-kirkwood/board-dockstar.c            |   32 ----
 arch/arm/mach-kirkwood/board-dreamplug.c           |   35 ----
 arch/arm/mach-kirkwood/board-dt.c                  |   40 -----
 arch/arm/mach-kirkwood/board-goflexnet.c           |   34 ----
 arch/arm/mach-kirkwood/board-guruplug.c            |   33 ----
 arch/arm/mach-kirkwood/board-ib62x0.c              |   29 ----
 arch/arm/mach-kirkwood/board-iconnect.c            |   10 --
 arch/arm/mach-kirkwood/board-iomega_ix2_200.c      |   34 ----
 arch/arm/mach-kirkwood/board-km_kirkwood.c         |   44 -----
 arch/arm/mach-kirkwood/board-lsxl.c                |   16 --
 arch/arm/mach-kirkwood/board-mplcec4.c             |   14 --
 arch/arm/mach-kirkwood/board-ns2.c                 |   35 ----
 arch/arm/mach-kirkwood/board-openblocks_a6.c       |   26 ---
 arch/arm/mach-kirkwood/board-readynas.c            |    6 -
 arch/arm/mach-kirkwood/board-ts219.c               |   13 --
 arch/arm/mach-kirkwood/board-usi_topkick.c         |   29 ----
 arch/arm/mach-orion5x/edmini_v2-setup.c            |   10 --
 drivers/net/ethernet/marvell/mv643xx_eth.c         |  182 ++++++++++++++++++--
 include/linux/mv643xx_eth.h                        |    2 +
 54 files changed, 739 insertions(+), 621 deletions(-)
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
