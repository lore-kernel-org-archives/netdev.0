From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 0/5] RFS hardware acceleration (v3)
Date: Wed, 19 Jan 2011 20:59:47 +0000
Message-ID: <1295470787.11126.82.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	linux-kernel <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Tom Herbert <therbert@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series extends RFS to use hardware RX filters where
available.  Depending on the number of hardware RX queues and their
IRQs' affinity, this should reduce the need for IPIs or at least get
packets delivered to the right NUMA node.

The first patch implements IRQ affinity notifiers, based on the outline
that Thomas Gleixner wrote in response to the previous version of this
patch series.  This has been updated based on Thomas's previous comments.

The second patch is a generalisation of the CPU affinity reverse-
mapping, plus functions to maintain such a mapping based on the new IRQ
affinity notifiers.  This has been updated based on Eric Dumazet's
comments.

The remaining patches add the RFS acceleration hooks and an
implementation in the sfc driver.  I have changed the sfc driver's
strategy for reclaiming entries in the filter table entry from the
previous version.  The table can now be scanned at the end of each NAPI
polling interval, based on the rate at which filters are being added.
However, I haven't yet constructed a good test case that involves
turnover of flows so I have yet to settle on a good strategy for this.

Ben.

Ben Hutchings (5):
  genirq: Add IRQ affinity notifiers
  lib: cpu_rmap: CPU affinity reverse-mapping
  net: RPS: Enable hardware acceleration of RFS
  sfc: Limit filter search depth further for performance hints (i.e.
    RFS)
  sfc: Implement hardware acceleration of RFS

 drivers/net/sfc/efx.c        |   49 ++++++++-
 drivers/net/sfc/efx.h        |   16 +++
 drivers/net/sfc/filter.c     |  107 ++++++++++++++++-
 drivers/net/sfc/net_driver.h |    3 +
 include/linux/cpu_rmap.h     |   73 ++++++++++++
 include/linux/interrupt.h    |   31 +++++
 include/linux/irqdesc.h      |    3 +
 include/linux/netdevice.h    |   33 +++++-
 kernel/irq/manage.c          |   82 +++++++++++++
 lib/Kconfig                  |    4 +
 lib/Makefile                 |    2 +
 lib/cpu_rmap.c               |  269 ++++++++++++++++++++++++++++++++++++++++++
 net/Kconfig                  |    6 +
 net/core/dev.c               |   97 ++++++++++++++-
 14 files changed, 760 insertions(+), 15 deletions(-)
 create mode 100644 include/linux/cpu_rmap.h
 create mode 100644 lib/cpu_rmap.c

-- 
1.7.3.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
