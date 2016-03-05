From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH v3 net-next 0/9] API set for HW Buffer management
Date: Sat,  5 Mar 2016 18:16:52 +0100
Message-ID: <1457198221-21752-1-git-send-email-gregory.clement@free-electrons.com>
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Willy Tarreau <w@1wt.eu>, Timor Kardashov <timork@marvell.com>,
	Sebastian Careba <nitroshift@yahoo.com>
To: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:43311 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750702AbcCERRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2016 12:17:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a third version of an API set for HW Buffer management that I
initially submit here:
http://thread.gmane.org/gmane.linux.kernel/2125152

Since the last version I took into account David's remarks:

- I made a HWBM and a SWBM version of the mvneta_rx() function in
  order to reduce the the conditional code. I kept a condition inside
  the mvneta_poll because specializing this function would have means
  duplicating 95% of the code.
- I put back the register_netdev() call at the end of the
  mvneta_probe() function. In order to have a uniq ID for each port I
  just used a global variable in the driver.

I also added a fix from Marcin in the "net: mvneta: bm: add support
for hardware buffer management" patch:
- "when dropping packets, only buffer pointers passed from BM to
  descriptors have to be returned to the pool. In submitted version
  after closing the port and mvneta_rxq_deinit(), it was very likely
  that a lot of fake buffers are added to the pool, because all
  descriptors took part in iteration."

Finally, I also removed the select MVNETA_BM from the Kconfig, it will
let the user the choice to use not use it if they want.

For the record in the previous version I made the following changes:
v1 -> v2

- The hardware buffer management helpers are no more built by default
  and now depend on a hidden config symbol which has to be selected
  by the driver if needed
- The hwbm_pool_refill() and hwbm_pool_add() now receive a gfp_t as
  argument allowing the caller to specify the flag it needs.
- buf_num is now tested to ensure there is no wrapping
- A spinlock has been added to protect the hwbm_pool_add() function in
  SMP or irq context.
- used pr_warn instead of pr_debug in case of errors.
- fixed the mvneta implementation by returning the buffer to the pool
  at various place instead of ignoring it.
- Squashed "bus: mvenus-mbus: Fix size test for
   mvebu_mbus_get_dram_win_info" into bus: mvebu-mbus: provide api for
   obtaining IO and DRAM window information.
- Added my signed-otf-by on all the patches as submitter of the series.
- Renamed the dts patches with the pattern "ARM: dts: platform:"
- Removed the patch "ARM: mvebu: enable SRAM support in
  mvebu_v7_defconfig" of this series and already applied it
- Modified the order of the patches.

In order to ease the test the branch mvneta-BM-framework-v3 is
available at git@github.com:MISL-EBU-System-SW/mainline-public.git.

Thanks,

Gregory

Gregory CLEMENT (3):
  ARM: dts: armada-xp-openblocks-ax3-4: Add BM support
  net: add a hardware buffer management helper API
  net: mvneta: Use the new hwbm framework

Marcin Wojtas (6):
  ARM: dts: armada-38x: add buffer manager nodes
  ARM: dts: armada-38x: enable buffer manager support on Armada 38x
    boards
  ARM: dts: armada-xp: add buffer manager nodes
  ARM: dts: armada-xp: enable buffer manager support on Armada XP boards
  bus: mvebu-mbus: provide api for obtaining IO and DRAM window
    information
  net: mvneta: bm: add support for hardware buffer management

 .../bindings/net/marvell-armada-370-neta.txt       |  19 +-
 .../devicetree/bindings/net/marvell-neta-bm.txt    |  49 ++
 arch/arm/boot/dts/armada-385-db-ap.dts             |  20 +-
 arch/arm/boot/dts/armada-388-clearfog.dts          |   6 +
 arch/arm/boot/dts/armada-388-db.dts                |  17 +-
 arch/arm/boot/dts/armada-388-gp.dts                |  17 +-
 .../arm/boot/dts/armada-38x-solidrun-microsom.dtsi |  15 +-
 arch/arm/boot/dts/armada-38x.dtsi                  |  18 +
 arch/arm/boot/dts/armada-xp-db.dts                 |  19 +-
 arch/arm/boot/dts/armada-xp-gp.dts                 |  19 +-
 arch/arm/boot/dts/armada-xp-openblocks-ax3-4.dts   |  19 +-
 arch/arm/boot/dts/armada-xp.dtsi                   |  18 +
 drivers/bus/mvebu-mbus.c                           |  52 ++
 drivers/net/ethernet/marvell/Kconfig               |  14 +
 drivers/net/ethernet/marvell/Makefile              |   1 +
 drivers/net/ethernet/marvell/mvneta.c              | 525 +++++++++++++++++++--
 drivers/net/ethernet/marvell/mvneta_bm.c           | 486 +++++++++++++++++++
 drivers/net/ethernet/marvell/mvneta_bm.h           | 162 +++++++
 include/linux/mbus.h                               |   3 +
 include/net/hwbm.h                                 |  21 +
 net/Kconfig                                        |   3 +
 net/core/Makefile                                  |   1 +
 net/core/hwbm.c                                    |  87 ++++
 23 files changed, 1539 insertions(+), 52 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/marvell-neta-bm.txt
 create mode 100644 drivers/net/ethernet/marvell/mvneta_bm.c
 create mode 100644 drivers/net/ethernet/marvell/mvneta_bm.h
 create mode 100644 include/net/hwbm.h
 create mode 100644 net/core/hwbm.c

-- 
2.5.0
