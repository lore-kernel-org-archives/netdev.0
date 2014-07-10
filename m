From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH v4 net-next 0/4] Network driver for Armada 375 SoC
Date: Thu, 10 Jul 2014 16:52:12 -0300
Message-ID: <1405021936-28658-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: David Miller <davem@davemloft.net>,
	Jason Cooper <jason@lakedaemon.net>,
	Marcin Wojtas <mw@semihalf.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:58510 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752622AbaGJTxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 15:53:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,

This is the fourth round of the Armada 375 network support patchset. I've
tried to address all the feedback provided for last version and I hope the
driver looks better now.

If there's nothing else to fix, we'd like to merge this for v3.17. The first
patch should go through the network tree, and the other patches through
the mvebu tree.

Thanks a lot for all the great review, and feel free to comment some more!

Changes from v3:

  * Further optimization of the MTU, MAC and ring parameter change to make
    it smoothier.

  * Lots of cleanups in the parser configuration code, most of them addressing
    the feedback from Francois. This include fixing: missing curly braces,
    excessive parenthesis, excessive scope, and making several functions
    more readable.

  * Removed the Rx/Tx queue number module parameter. There's no reason to
    use any other than the default hardware-defined value.

Changes from v2:

  * Reworked mvpp2_prs_tcam_first_free() as suggested by Joe and Francois,
    to have a single loop instead of two.

  * Replaced mvpp2_cpu_interrupts_enable/disable(pp, cpu) with one function
    that enables/disable interrupts on all the CPUs at once.

  * Factor out Tx descriptor DMA unmap + descriptor put sequence to have
    more readable code, as suggested by Francois.

  * Remove redundant netif_running() checks in the ingress and egress path,
    as suggested by Francois.

  * Reworked ring parameter, MTU and MAC address setting to produce a
    more gentle modification of the parameter, and have a fallback in the
    event of a failure.

  * Fixed a percpu memory leak on error path, also noted by Francois.

  * Removed the usage of the legacy net_device irq field, requested by
    Francois.

  * Removed the unneeded multiple Tx port support. It was hardcoded to a single
    Tx port in the previous version so we decided to drop it and simplify the
    code.

  * Optimize the on_each_cpu() calls to clear the sent counters and the
    TX_DONE pkts coalescing setting. on_each_cpu is expensive so it's better
    to minize the calls to it.

Changes from v1:

  * Marcin Wojtas is the author of the driver, so I fixed authorship
    for patch 1/3:
    "ethernet: Add new driver for Marvell Armada 375 network unit"

This patchset adds a new network driver to support the network controller
in Armada 375 SoC.

The network interfaces share a common hardware unit called Packet Processor,
which contains a common register space and per-port register spaces.
    
The new network unit has different RXQ and TXQ management. The ports
associate so-called per-port "logical queues" which are mapped to "physical
queues". The latter are shared among the ports.

Fo the egress part, the mapping for each port is predefined by hardware.
The egress path incorporates so-called aggregation queues (one per CPU),
from where the data is passed to the physical queues and then via prefetch
buffer to the TxDMA.
    
The ingress path has a Parser and Classifier (PnC) and a Buffer Manager (BM)
whose usage is obligatory. We are only implementing a simple configuration
for the Parser and Classifier, yet the code is considerably large.
    
This network unit has other optional features like xPON, WoL, Hardware
Forwarding, and more. This initial commit doesn't provide support for these.
    
The mvpp2 network driver has been written by Marcin Wojtas and then reviewed
and cleaned up by Ezequiel Garcia.

Ezequiel Garcia (2):
  ARM: mvebu: Add support for the network controller in Armada 375 SoC
  ARM: mvebu: Enable the network controller in Armada 375 DB board

Marcin Wojtas (2):
  ethernet: Add new driver for Marvell Armada 375 network unit
  ARM: mvebu: enable Armada 375 network driver in mvebu_v7_defconfig

 .../devicetree/bindings/net/marvell-pp2.txt        |   61 +
 arch/arm/boot/dts/armada-375-db.dts                |   26 +
 arch/arm/boot/dts/armada-375.dtsi                  |   31 +
 arch/arm/configs/mvebu_v7_defconfig                |    1 +
 drivers/net/ethernet/marvell/Kconfig               |    8 +
 drivers/net/ethernet/marvell/Makefile              |    1 +
 drivers/net/ethernet/marvell/mvpp2.c               | 6393 ++++++++++++++++++++
 7 files changed, 6521 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/marvell-pp2.txt
 create mode 100644 drivers/net/ethernet/marvell/mvpp2.c

-- 
1.9.1
