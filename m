From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 00/29] ioatdma: towards raid support
Date: Thu, 03 Sep 2009 19:30:30 -0700
Message-ID: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-raid@vger.kernel.org, netdev@vger.kernel.org,
	maciej.sosnowski@intel.com
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932529AbZIDCa3@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The v3.2 version of the Intel(R) QuickData Technology specification adds
support for raid5 and raid6 offloads.  The v3.2 implementation, like v3,
reuses the same basic dma descriptor ring mechanism that was introduced
for v2 devices.  At the same time v3.2 breaks some assumptions of the
existing driver with the addition of mechanisms like extended
descriptors and interrupt-driven completion callbacks as specified by
the async_tx/raid-offload implementation.

The current driver blurs the lines between v1, v2, and v3 making it
difficult to append raid functionality without modifying legacy code
paths.  The primary goal of this patchset is to refactor and isolate the
legacy (v1/v2) code paths from feature additions going forward by
migrating hardware version specific code to hardware version specific
files.  It also takes the opportunity to perform some cleanups and
optimizations.  For example, the conversion from a linked list to a
ring-buffer for the v2/v3 descriptor ring makes the code more readable
and reduces the size of the software descriptor from 136-bytes to
88-bytes with all the fields needed for NET_DMA fitting into one
cacheline.

One robustness fix required by the raid code is the ability to poll for
a descriptor while the channel is experiencing an "out of descriptors"
condition.  This has been added for the v2/v3 ring implementation.

This cleanup is available via git at:

   git://git.kernel.org/pub/scm/linux/kernel/git/djbw/async_tx.git ioat-refactor

It will hit -next shortly.

The driver is used by net/ when CONFIG_NET_DMA=y, and will be used by
drivers/md/ (after the raid extensions) when CONFIG_ASYNC_TX_DMA=y.
Hence the Cc: of netdev and linux-raid.

Regards,
Dan

---

Dan Williams (29):
      ioat: move to drivers/dma/ioat/
      ioat: move definitions to dma.h
      ioat: convert ioat_probe to pcim/devm
      ioat: cleanup some long deref chains and 80 column collisions
      ioat: kill function prototype ifdef guards
      ioat: split ioat_dma_probe into core/version-specific routines
      ioat: fix type mismatch for ->dmacount
      ioat: define descriptor control bit-field
      ioat1: move descriptor allocation from submit to prep
      ioat: fix self test interrupts
      ioat: prepare the code for ioat[12]_dma_chan split
      ioat2,3: convert to a true ring buffer
      ioat1: kill unused unmap parameters
      ioat: add some dev_dbg() calls
      ioat: cleanup completion status reads
      ioat: ignore reserved bits for chancnt and xfercap
      ioat: preserve chanctrl bits when re-arming interrupts
      ioat: ___devinit annotate the initialization paths
      ioat1: trim ioat_dma_desc_sw
      ioat: switch watchdog and reset handler from workqueue to timer
      ioat2,3: dynamically resize descriptor ring
      net_dma: poll for a descriptor after allocation failure
      dw_dmac: implement a private tx_list
      fsldma: implement a private tx_list
      iop-adma: implement a private tx_list
      ioat: implement a private tx_list
      mv_xor: implement a private tx_list
      dmaengine: kill tx_list
      ioat2,3: cacheline align software descriptor allocations

 arch/arm/include/asm/hardware/iop_adma.h           |    2 +
 drivers/dma/Makefile                               |    3 +-
 drivers/dma/dmaengine.c                            |    1 -
 drivers/dma/dw_dmac.c                              |   19 +-
 drivers/dma/dw_dmac_regs.h                         |    1 +
 drivers/dma/fsldma.c                               |    7 +-
 drivers/dma/fsldma.h                               |    1 +
 drivers/dma/ioat/Makefile                          |    2 +
 drivers/dma/{ioat_dca.c => ioat/dca.c}             |   13 +-
 drivers/dma/ioat/dma.c                             | 1140 +++++++++++++
 drivers/dma/ioat/dma.h                             |  307 ++++
 drivers/dma/ioat/dma_v2.c                          |  883 ++++++++++
 drivers/dma/ioat/dma_v2.h                          |  147 ++
 drivers/dma/{ioatdma_hw.h => ioat/hw.h}            |   45 +-
 drivers/dma/{ioat.c => ioat/pci.c}                 |  163 +-
 .../dma/{ioatdma_registers.h => ioat/registers.h}  |   34 +-
 drivers/dma/ioat_dma.c                             | 1741 --------------------
 drivers/dma/ioatdma.h                              |  165 --
 drivers/dma/iop-adma.c                             |    9 +-
 drivers/dma/iovlock.c                              |   10 +
 drivers/dma/mv_xor.c                               |    7 +-
 drivers/dma/mv_xor.h                               |    4 +-
 include/linux/dmaengine.h                          |    3 -
 23 files changed, 2647 insertions(+), 2060 deletions(-)
 create mode 100644 drivers/dma/ioat/Makefile
 rename drivers/dma/{ioat_dca.c => ioat/dca.c} (98%)
 create mode 100644 drivers/dma/ioat/dma.c
 create mode 100644 drivers/dma/ioat/dma.h
 create mode 100644 drivers/dma/ioat/dma_v2.c
 create mode 100644 drivers/dma/ioat/dma_v2.h
 rename drivers/dma/{ioatdma_hw.h => ioat/hw.h} (67%)
 rename drivers/dma/{ioat.c => ioat/pci.c} (62%)
 rename drivers/dma/{ioatdma_registers.h => ioat/registers.h} (91%)
 delete mode 100644 drivers/dma/ioat_dma.c
 delete mode 100644 drivers/dma/ioatdma.h
