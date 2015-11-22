From: Marcin Wojtas <mw@semihalf.com>
Subject: [PATCH 00/13] mvneta Buffer Management and enhancements
Date: Sun, 22 Nov 2015 08:53:46 +0100
Message-ID: <1448178839-3541-1-git-send-email-mw@semihalf.com>
Cc: davem@davemloft.net, linux@arm.linux.org.uk,
	sebastian.hesselbarth@gmail.com, andrew@lunn.ch,
	jason@lakedaemon.net, thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, simon.guinot@sequanux.org,
	nadavh@marvell.com, alior@marvell.com, xswang@marvell.com,
	myair@marvell.com, nitroshift@yahoo.com, mw@semihalf.com,
	jaz@semihalf.com, tn@semihalf.com
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f51.google.com ([209.85.215.51]:34138 "EHLO
	mail-lf0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954AbbKVHxr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Nov 2015 02:53:47 -0500
Received: by lffu14 with SMTP id u14so91374814lff.1
        for <netdev@vger.kernel.org>; Sat, 21 Nov 2015 23:53:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Hereby I submit a patchset that introduces various fixes and support
for new features and enhancements to the mvneta driver:

1. First three patches are minimal fixes, stable-CC'ed.

2. Suspend to ram ('s2ram') support. Due to some stability problems
Thomas Petazzoni's patches did not get merged yet, but I used them for
verification. Contrary to wfi mode ('standby' - linux does not
differentiate between them, so same routines are used) all registers'
contents are lost due to power down, so the configuration has to be
fully reconstructed during resume.

3. Optimisations - concatenating TX descriptors' flush, basing on
xmit_more support and combined approach for finalizing egress processing.
Thanks to HR timer buffers can be released with small latency, which is
good for low transfer and small queues. Along with the timer, coalescing
irqs are used, whose threshold could be increased back to 15.

4. Buffer manager (BM) support with two preparatory commits. As it is a
separate block, common for all network ports, a new driver is introduced,
which configures it and exposes API to the main network driver. It is
throughly described in binding documentation and commit log. Please note,
that enabling per-port BM usage is done using phandle and the data passed
in mvneta_bm_probe. It is designed for usage of on-demand device probe
and dev_set/get_drvdata, however it's awaiting merge to linux-next.
Therefore, deferring probe is not used - if something goes wrong (same
in case of errors during changing MTU or suspend/resume cycle) mvneta
driver falls back to software buffer management and works in a regular way.

Known issues:
- problems with obtaining all mapped buffers from internal SRAM, when
destroying the buffer pointer pool
- problems with unmapping chunk of SRAM during driver removal
Above do not have an impact on the operation, as they are called during
driver removal or in error path.

5. Enable BM on Armada XP and 38X development boards - those ones and
A370 I could check on my own. In all cases they survived night-long
linerate iperf. Also tests were performed with A388 SoC working as a
network bridge between two packet generators. They showed increase of
maximum processed 64B packets by ~20k (~555k packets with BM enabled
vs ~535 packets without BM). Also when pushing 1500B-packets with a
line rate achieved, CPU load decreased from around 25% without BM vs
18-20% with BM.

I'm looking forward to any remarks and comments.

Best regards,
Marcin Wojtas

Marcin Wojtas (12):
  net: mvneta: add configuration for MBUS windows access protection
  net: mvneta: enable IP checksum with jumbo frames for Armada 38x on
    Port0
  net: mvneta: fix bit assignment in MVNETA_RXQ_CONFIG_REG
  net: mvneta: enable suspend/resume support
  net: mvneta: enable mixed egress processing using HR timer
  bus: mvebu-mbus: provide api for obtaining IO and DRAM window
    information
  ARM: mvebu: enable SRAM support in mvebu_v7_defconfig
  net: mvneta: bm: add support for hardware buffer management
  ARM: mvebu: add buffer manager nodes to armada-38x.dtsi
  ARM: mvebu: enable buffer manager support on Armada 38x boards
  ARM: mvebu: add buffer manager nodes to armada-xp.dtsi
  ARM: mvebu: enable buffer manager support on Armada XP boards

Simon Guinot (1):
  net: mvneta: add xmit_more support

 .../bindings/net/marvell-armada-370-neta.txt       |  19 +-
 .../devicetree/bindings/net/marvell-neta-bm.txt    |  49 ++
 arch/arm/boot/dts/armada-385-db-ap.dts             |  20 +-
 arch/arm/boot/dts/armada-388-db.dts                |  17 +-
 arch/arm/boot/dts/armada-388-gp.dts                |  17 +-
 arch/arm/boot/dts/armada-38x.dtsi                  |  20 +-
 arch/arm/boot/dts/armada-xp-db.dts                 |  19 +-
 arch/arm/boot/dts/armada-xp-gp.dts                 |  19 +-
 arch/arm/boot/dts/armada-xp.dtsi                   |  18 +
 arch/arm/configs/mvebu_v7_defconfig                |   1 +
 drivers/bus/mvebu-mbus.c                           |  51 ++
 drivers/net/ethernet/marvell/Kconfig               |  14 +
 drivers/net/ethernet/marvell/Makefile              |   1 +
 drivers/net/ethernet/marvell/mvneta.c              | 660 +++++++++++++++++++--
 drivers/net/ethernet/marvell/mvneta_bm.c           | 642 ++++++++++++++++++++
 drivers/net/ethernet/marvell/mvneta_bm.h           | 171 ++++++
 include/linux/mbus.h                               |   3 +
 17 files changed, 1677 insertions(+), 64 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/marvell-neta-bm.txt
 create mode 100644 drivers/net/ethernet/marvell/mvneta_bm.c
 create mode 100644 drivers/net/ethernet/marvell/mvneta_bm.h

-- 
1.8.3.1
