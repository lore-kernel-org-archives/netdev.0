From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH net-next 00/10] Proposal for a API set for HW Buffer management
Date: Tue, 12 Jan 2016 20:10:24 +0100
Message-ID: <1452625834-22166-1-git-send-email-gregory.clement@free-electrons.com>
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Willy Tarreau <w@1wt.eu>, Arnd Bergmann <arnd@arndb.de>
To: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

A few weeks ago Marcin proposed a patch set including the support of
the buffer management for mvneta:
http://marc.info/?l=linux-netdev&m=144817888806131&w=2

He was asked to propose helpers in order to have common code taking
core of the hardware buffer manager. As Marcin was busy on other
topics we agreed that I would take care of it. After a few weeks, here
it is a first proposal.

The set of helpers is pretty small because I encountered issues while
trying writing more optimized helpers. The current implementation
provide a hwbm_pool structure which represents a pool with very
general members to define it: such as the number of buffers and the
size of the buffers. The structure also has a private member allowing
adding driver specific data and also a constructor called during the
allocation of a buffer.

The 3 helpers are:

- hwbm_pool_refill which allocates a new buffer and adds it in the
pool. If a constructor is provided in the hwbm_pool struct then it
will call it just after the allocation. The purpose of this
constructor is to do the hardware specific job such as informing the
hardware buffer manager of the new buffer.

- hwbm_pool_add which grows the amount of buffer in a given pool.

- hwbm_buf_free which frees a buffer calling the appropriate function
(skb_free_frag or kfree) depending of the size of the buffers of the
pool.

* At the beginning I hoped to be able to use kmem_cache objects for the
buffers pool. Indeed, for a given pool the size of the buffers is
fixed and the purpose of a SLAB allocator is to create caches, which
contains a set of objects of the same size.

However, in order to free an object from a cache we need to have a
reference to this one. As freeing the buffer is done most of the time
outside the driver there is no more reference to the cache the buffer
belonged. One solution would be to look for the buffer address in each
pool to find the slab cache, but I fear that the cost would be too
high. However, I didn't try it and maybe walking through a sorting
list would be a solution.

* I also though to add call to a ndo_free_buffer function inside the
skb_free_head. This callback would be responsible of freeing the data
buffer and in under certain circumstances with the help of a hardware
buffer manager it would only put back the buffer into the pool. Thanks
to this it would remove the cost of an allocation and of a free.

But there again we need to have a reference to the pool the buffer
belonged.



I am waiting for your feedback to consolidate this "framework".

For this RFC the interesting patches are the last 2 ones: "net:
mvneta: Use the new hwbm framework" and "net: Add a hardware buffer
management helper API". The other patches of the series are here to
let people testing the series on an Armada XP or an Armada 38x based
board.

Thanks,

Gregory

Gregory CLEMENT (3):
  bus: mvenus-mbus: Fix size test for mvebu_mbus_get_dram_win_info
  net: Add a hardware buffer management helper API
  net: mvneta: Use the new hwbm framework

Marcin Wojtas (7):
  bus: mvebu-mbus: provide api for obtaining IO and DRAM window
    information
  ARM: mvebu: enable SRAM support in mvebu_v7_defconfig
  net: mvneta: bm: add support for hardware buffer management
  ARM: mvebu: add buffer manager nodes to armada-38x.dtsi
  ARM: mvebu: enable buffer manager support on Armada 38x boards
  ARM: mvebu: add buffer manager nodes to armada-xp.dtsi
  ARM: mvebu: enable buffer manager support on Armada XP boards

 .../bindings/net/marvell-armada-370-neta.txt       |  19 +-
 .../devicetree/bindings/net/marvell-neta-bm.txt    |  49 +++
 arch/arm/boot/dts/armada-385-db-ap.dts             |  20 +-
 arch/arm/boot/dts/armada-388-db.dts                |  17 +-
 arch/arm/boot/dts/armada-388-gp.dts                |  17 +-
 arch/arm/boot/dts/armada-38x.dtsi                  |  18 +
 arch/arm/boot/dts/armada-xp-db.dts                 |  19 +-
 arch/arm/boot/dts/armada-xp-gp.dts                 |  19 +-
 arch/arm/boot/dts/armada-xp.dtsi                   |  18 +
 arch/arm/configs/mvebu_v7_defconfig                |   1 +
 drivers/bus/mvebu-mbus.c                           |  51 +++
 drivers/net/ethernet/marvell/Kconfig               |  14 +
 drivers/net/ethernet/marvell/Makefile              |   1 +
 drivers/net/ethernet/marvell/mvneta.c              | 407 +++++++++++++++--
 drivers/net/ethernet/marvell/mvneta_bm.c           | 486 +++++++++++++++++++++
 drivers/net/ethernet/marvell/mvneta_bm.h           | 162 +++++++
 include/linux/mbus.h                               |   3 +
 include/net/hwbm.h                                 |  19 +
 net/core/Makefile                                  |   2 +-
 net/core/hwbm.c                                    |  78 ++++
 20 files changed, 1364 insertions(+), 56 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/marvell-neta-bm.txt
 create mode 100644 drivers/net/ethernet/marvell/mvneta_bm.c
 create mode 100644 drivers/net/ethernet/marvell/mvneta_bm.h
 create mode 100644 include/net/hwbm.h
 create mode 100644 net/core/hwbm.c

-- 
2.5.0
