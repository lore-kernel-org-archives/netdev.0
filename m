From: Dan Williams <dan.j.williams@intel.com>
Subject: [GIT PULL, resend] async_tx/dmaengine update for 2.6.29
Date: Fri, 09 Jan 2009 08:16:47 -0700
Message-ID: <1231514207.26794.1.camel@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Haavard Skinnemoen <hskinnemoen@atmel.com>,
	Maciej Sosnowski <maciej.sosnowski@intel.com>,
	g.liakhovetski@gmx.de, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, Sascha Hauer <s.hauer@pengutronix.de>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:30129 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751753AbZAIPRD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 10:17:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Linus, please pull from:

  git://git.kernel.org/pub/scm/linux/kernel/git/djbw/async_tx.git next

...to receive:

0) More code removed than added

1) Channel allocation rework
The dmaengine subsystem collects and advertises dma channels for two
classes of users in the kernel, memory-to-memory offload and traditional
device-to-memory DMA.  The original design was driven by the
memory-to-memory case and is starting to show its limitations now that
more device-to-memory DMA users are appearing.  The primary difference
between the two classes is that memory-to-memory offload is very
amenable to channel sharing and is tolerant of dynamic channel changes.
Compare this to the device-to-memory case where a channel must be
dedicated to a device and may have platform-specific reasons why it
cannot talk to a different device.

This rework allows channels to be targeted to a public mem-to-mem pool
or be reserved for an exclusive (private) dev-to-mem allocation.

2) Fixes for dmaengine
Stephen Hemminger pointed out that the dmaengine sysfs implementation
was broken.  It now has a proper ->release() routine.

3) Fixes for ioat
The previous channel allocation scheme covered a shutdown bug.

4) Fixes for iop-adma
Some devm fixups, and module removal enablement.

These commits have been in linux-next since mid December, although I bit
the bullet and rebased recently to cover a git-bisect breakage case.
This was caused by net-next-2.6.git moving a routine that was deleted by
this branch. Thanks to Stephen Rothwell for pointing this out.

Thanks!
Dan

---

Dan Williams (22):
      async_tx, dmaengine: document channel allocation and api rework
      dmaengine: remove dependency on async_tx
      dmaengine: up-level reference counting to the module level
      dmaengine: centralize channel allocation, introduce dma_find_channel
      dmaengine: provide a common 'issue_pending_all' implementation
      net_dma: convert to dma_find_channel
      dmaengine: introduce dma_request_channel and private channels
      dmatest: convert to dma_request_channel
      atmel-mci: convert to dma_request_channel and down-level dma_slave
      dmaengine: replace dma_async_client_register with dmaengine_get
      dmaengine: kill struct dma_client and supporting infrastructure
      dmaengine: remove 'bigref' infrastructure
      dmaengine: kill enum dma_state_client
      iop-adma: let devm do its job, don't duplicate free
      iop-adma: kill debug BUG_ON
      iop-adma: enable module removal
      ioat: do not perform removal actions at shutdown
      dmaengine: add a release for dma class devices and dependent infrastructure
      dmaengine: use idr for registering dma device numbers
      dmaengine: advertise all channels on a device to dma_filter_fn
      dmaengine: bump initcall level to arch_initcall
      ioat: fix self test for multi-channel case

 Documentation/crypto/async-tx-api.txt |   96 ++---
 Documentation/dmaengine.txt           |    1 +
 arch/avr32/include/asm/atmel-mci.h    |    6 +-
 arch/avr32/mach-at32ap/at32ap700x.c   |   15 +-
 crypto/async_tx/async_tx.c            |  350 +---------------
 drivers/dca/dca-core.c                |    2 +-
 drivers/dma/Kconfig                   |    2 -
 drivers/dma/dmaengine.c               |  778 ++++++++++++++++++++++++---------
 drivers/dma/dmatest.c                 |  129 ++----
 drivers/dma/dw_dmac.c                 |  119 +++---
 drivers/dma/fsldma.c                  |    5 +-
 drivers/dma/ioat.c                    |   92 ++---
 drivers/dma/ioat_dma.c                |   18 +-
 drivers/dma/iop-adma.c                |   30 +--
 drivers/dma/mv_xor.c                  |   11 +-
 drivers/mmc/host/atmel-mci.c          |  103 ++----
 include/linux/async_tx.h              |   17 +-
 include/linux/dmaengine.h             |  181 +++------
 include/linux/dw_dmac.h               |   31 +-
 include/linux/netdevice.h             |    3 -
 include/net/netdma.h                  |   11 -
 net/core/dev.c                        |  149 +------
 net/ipv4/tcp.c                        |    5 +-
 net/ipv4/tcp_input.c                  |    2 +-
 net/ipv4/tcp_ipv4.c                   |    2 +-
 net/ipv6/tcp_ipv6.c                   |    2 +-
 26 files changed, 900 insertions(+), 1260 deletions(-)
 create mode 100644 Documentation/dmaengine.txt



