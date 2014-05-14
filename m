From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 2/5] ixgbe: increase default TX ring buffer to 1024
Date: Wed, 14 May 2014 16:17:48 +0200
Message-ID: <20140514141748.20309.83121.stgit@dragon>
References: <20140514141545.20309.28343.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Robert Olsson <robert@herjulf.se>,
	Ben Greear <greearb@candelatech.com>,
	John Fastabend <john.r.fastabend@intel.com>, danieltt@kth.se,
	zhouzhouyi@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51078 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752525AbaENOSW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 10:18:22 -0400
In-Reply-To: <20140514141545.20309.28343.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using pktgen I'm seeing the ixgbe driver "push-back", due TX ring
running full.  Thus, the TX ring is artificially limiting pktgen.

Diagnose via "ethtool -S", look for "tx_restart_queue" or "tx_busy"
counters.

Increasing the TX ring buffer should be done carefully, as it comes at
a higher memory cost, which can also negatively influence performance.
E.g. ring buffer array of struct ixgbe_tx_buffer (current size 48bytes)
increase from 512*48=24576bytes to 1024*48=49152bytes which is larger
than the L1 data cache (32KB on my E5-2630), thus increasing the L1->L2
cache-references.

Adjusting the TX ring buffer (TXSZ) measured over 10 sec with ifpps
 (single CPU performance, ixgbe 10Gbit/s, E5-2630)
 * cmd: ethtool -G eth8 tx $TXSZ
 * 3,930,065 pps -- TXSZ= 512
 * 5,312,249 pps -- TXSZ= 768
 * 5,362,722 pps -- TXSZ=1024
 * 5,361,390 pps -- TXSZ=1536
 * 5,362,439 pps -- TXSZ=2048
 * 5,359,744 pps -- TXSZ=4096

Choosing size 1024 because for the next optimizations 768 is not
enough.

Notice after commit 6f25cd47d (pktgen: fix xmit test for BQL enabled
devices) pktgen uses netif_xmit_frozen_or_drv_stopped() and ignores
the BQL "stack" pause (QUEUE_STATE_STACK_XOFF) flag.  This allow us to put
more pressure on the TX ring buffers.

It is the ixgbe_maybe_stop_tx() call that stops the transmits, and
pktgen respecting this in the call to netif_xmit_frozen_or_drv_stopped(txq).

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 drivers/net/ethernet/intel/ixgbe/ixgbe.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index c688c8a..bf078fe 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -63,7 +63,7 @@
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 /* TX/RX descriptor defines */
-#define IXGBE_DEFAULT_TXD		    512
+#define IXGBE_DEFAULT_TXD		   1024
 #define IXGBE_DEFAULT_TX_WORK		    256
 #define IXGBE_MAX_TXD			   4096
 #define IXGBE_MIN_TXD			     64
