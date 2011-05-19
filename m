From: David Decotigny <decot@google.com>
Subject: [PATCH 1/6] forcedeth: Improve stats counters
Date: Wed, 18 May 2011 17:14:35 -0700
Message-ID: <1305764080-24853-1-git-send-email-decot@google.com>
Cc: kernel-net-upstream@google.com, Mandeep Baines <msb@google.com>,
	David Decotigny <decot@google.com>
To: "David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mandeep Baines <msb@google.com>

Rx byte count was off; instead use the hardware's count.  Tx packet
count was counting pre-TSO packets; instead count on-the-wire packets.
Report hardware dropped frame count as rx_fifo_errors.

- The count of transmitted packets reported by the forcedeth driver
  reports pre-TSO (TCP Segmentation Offload) packet counts and not the
  count of the number of packets sent on the wire. This change fixes
  the forcedeth driver to report the correct count. Fixed the code by
  copying the count stored in the NIC H/W to the value reported by the
  driver.

- Count rx_drop_frame errors as rx_fifo_errors:
  We see a lot of rx_drop_frame errors if we disable the rx bottom-halves
  for too long.  Normally, rx_fifo_errors would be counted in this case.
  The rx_drop_frame error count is private to forcedeth and is not
  reported by ifconfig or sysfs.  The rx_fifo_errors count is currently
  unused in the forcedeth driver.  It is reported by ifconfig as overruns.
  This change reports rx_drop_frame errors as rx_fifo_errors.


Signed-off-by: David Decotigny <decot@google.com>
---
 drivers/net/forcedeth.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index d09e8b0..895471d 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -1684,6 +1684,7 @@ static void nv_get_hw_stats(struct net_device *dev)
 		np->estats.tx_pause += readl(base + NvRegTxPause);
 		np->estats.rx_pause += readl(base + NvRegRxPause);
 		np->estats.rx_drop_frame += readl(base + NvRegRxDropFrame);
+		np->estats.rx_errors_total += np->estats.rx_drop_frame;
 	}
 
 	if (np->driver_data & DEV_HAS_STATISTICS_V3) {
@@ -1708,11 +1709,14 @@ static struct net_device_stats *nv_get_stats(struct net_device *dev)
 		nv_get_hw_stats(dev);
 
 		/* copy to net_device stats */
+		dev->stats.tx_packets = np->estats.tx_packets;
+		dev->stats.rx_bytes = np->estats.rx_bytes;
 		dev->stats.tx_bytes = np->estats.tx_bytes;
 		dev->stats.tx_fifo_errors = np->estats.tx_fifo_errors;
 		dev->stats.tx_carrier_errors = np->estats.tx_carrier_errors;
 		dev->stats.rx_crc_errors = np->estats.rx_crc_errors;
 		dev->stats.rx_over_errors = np->estats.rx_over_errors;
+		dev->stats.rx_fifo_errors = np->estats.rx_drop_frame;
 		dev->stats.rx_errors = np->estats.rx_errors_total;
 		dev->stats.tx_errors = np->estats.tx_errors_total;
 	}
-- 
1.7.3.1
