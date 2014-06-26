From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V2 1/3] pktgen: document tuning for max NIC
	performance
Date: Thu, 26 Jun 2014 13:16:27 +0200
Message-ID: <20140626111622.23576.26881.stgit@dragon>
References: <20140626111549.23576.90201.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>, zoltan.kiss@citrix.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4238 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755679AbaFZLRA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2014 07:17:00 -0400
In-Reply-To: <20140626111549.23576.90201.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using pktgen I'm seeing the ixgbe driver "push-back", due TX ring
running full.  Thus, the TX ring is artificially limiting pktgen.
(Diagnose via "ethtool -S", look for "tx_restart_queue" or "tx_busy"
counters.)

Using ixgbe, the real reason behind the TX ring running full, is due
to TX ring not being cleaned up fast enough. The ixgbe driver combines
TX+RX ring cleanups, and the cleanup interval is affected by the
ethtool --coalesce setting of parameter "rx-usecs".

Do not increase the default NIC TX ring buffer or default cleanup
interval.  Instead simply document that pktgen needs special NIC
tuning for maximum packet per sec performance.

Performance results with pktgen with clone_skb=100000.
TX ring size 512 (default), adjusting "rx-usecs":
 (Single CPU performance, E5-2630, ixgbe)
 - 3935002 pps - rx-usecs:  1 (irqs:  9346)
 - 5132350 pps - rx-usecs: 10 (irqs: 99157)
 - 5375111 pps - rx-usecs: 20 (irqs: 50154)
 - 5454050 pps - rx-usecs: 30 (irqs: 33872)
 - 5496320 pps - rx-usecs: 40 (irqs: 26197)
 - 5502510 pps - rx-usecs: 50 (irqs: 21527)

TX ring size adjusting (ethtool -G), "rx-usecs==1" (default):
 - 3935002 pps - tx-size:  512
 - 5354401 pps - tx-size:  768
 - 5356847 pps - tx-size: 1024
 - 5327595 pps - tx-size: 1536
 - 5356779 pps - tx-size: 2048
 - 5353438 pps - tx-size: 4096

Notice after commit 6f25cd47d (pktgen: fix xmit test for BQL enabled
devices) pktgen uses netif_xmit_frozen_or_drv_stopped() and ignores
the BQL "stack" pause (QUEUE_STATE_STACK_XOFF) flag.  This allow us to put
more pressure on the TX ring buffers.

It is the ixgbe_maybe_stop_tx() call that stops the transmits, and
pktgen respecting this in the call to netif_xmit_frozen_or_drv_stopped(txq).

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 Documentation/networking/pktgen.txt |   28 ++++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/pktgen.txt b/Documentation/networking/pktgen.txt
index 0e30c78..0dffc6e 100644
--- a/Documentation/networking/pktgen.txt
+++ b/Documentation/networking/pktgen.txt
@@ -24,6 +24,34 @@ For monitoring and control pktgen creates:
         /proc/net/pktgen/ethX
 
 
+Tuning NIC for max performance
+==============================
+
+The default NIC setting are (likely) not tuned for pktgen's artificial
+overload type of benchmarking, as this could hurt the normal use-case.
+
+Specifically increasing the TX ring buffer in the NIC:
+ # ethtool -G ethX tx 1024
+
+A larger TX ring can improve pktgen's performance, while it can hurt
+in the general case, 1) because the TX ring buffer might get larger
+than the CPUs L1/L2 cache, 2) because it allow more queueing in the
+NIC HW layer (which is bad for bufferbloat).
+
+One should be careful to conclude, that packets/descriptors in the HW
+TX ring cause delay.  Drivers usually delay cleaning up the
+ring-buffers (for various performance reasons), thus packets stalling
+the TX ring, might just be waiting for cleanup.
+
+This cleanup issues is specifically the case, for the driver ixgbe
+(Intel 82599 chip).  This driver (ixgbe) combine TX+RX ring cleanups,
+and the cleanup interval is affected by the ethtool --coalesce setting
+of parameter "rx-usecs".
+
+For ixgbe use e.g "30" resulting in approx 33K interrupts/sec (1/30*10^6):
+ # ethtool -C ethX rx-usecs 30
+
+
 Viewing threads
 ===============
 /proc/net/pktgen/kpktgend_0 
