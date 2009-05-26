From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/4] igb: Record host memory receive overflow in
	net_stats
Date: Tue, 26 May 2009 16:50:48 -0700
Message-ID: <20090526235048.28231.66889.stgit@localhost.localdomain>
References: <20090526234958.28231.16894.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesper Dangaard Brouer <hawk@comx.dk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.westchester.pa.mail.comcast.net ([76.96.62.56]:42071
	"EHLO QMTA06.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757684AbZEZXvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 19:51:03 -0400
In-Reply-To: <20090526234958.28231.16894.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <hawk@comx.dk>

Based on previous patch from Jesper Dangaard Brouer.

The RNBC (Receive No Buffers Count) register for the 82576, indicate
that frames were received when there were no available buffers in host
memory to store those frames (receive descriptor head and tail
pointers were equal).  The packet is still received by the NIC if
there is space in the FIFO on the NIC.

As the RNBC value is not a packet drop, the driver stores this value
in net_stats.rx_fifo_errors to indicate that there were no system
buffers available for the incoming packet.  Actual dropped packets
are counted in the MPC value.

Saving the stats in dev->net_stats makes it visible via
/proc/net/dev as "fifo", and thus viewable to ifconfig
as "overruns" and 'netstat -i' as "RX-OVR".

The Receive No Buffers Count (RNBC) can already be queried by
ethtool -S as "rx_no_buffer_count".

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Jesper Dangaard Brouer <hawk@comx.dk>
---

 drivers/net/igb/igb_ethtool.c |    1 +
 drivers/net/igb/igb_main.c    |   10 ++++++++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 2ae98f9..9598ac0 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -64,6 +64,7 @@ static const struct igb_stats igb_gstrings_stats[] = {
 	{ "rx_crc_errors", IGB_STAT(stats.crcerrs) },
 	{ "rx_frame_errors", IGB_STAT(net_stats.rx_frame_errors) },
 	{ "rx_no_buffer_count", IGB_STAT(stats.rnbc) },
+	{ "rx_queue_drop_packet_count", IGB_STAT(net_stats.rx_fifo_errors) },
 	{ "rx_missed_errors", IGB_STAT(stats.mpc) },
 	{ "tx_aborted_errors", IGB_STAT(stats.ecol) },
 	{ "tx_carrier_errors", IGB_STAT(stats.tncrs) },
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 4ae8133..8e93750 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3590,6 +3590,7 @@ void igb_update_stats(struct igb_adapter *adapter)
 
 	if (hw->mac.type != e1000_82575) {
 		u32 rqdpc_tmp;
+		u64 rqdpc_total = 0;
 		int i;
 		/* Read out drops stats per RX queue.  Notice RQDPC (Receive
 		 * Queue Drop Packet Count) stats only gets incremented, if
@@ -3602,9 +3603,18 @@ void igb_update_stats(struct igb_adapter *adapter)
 		for (i = 0; i < adapter->num_rx_queues; i++) {
 			rqdpc_tmp = rd32(E1000_RQDPC(i)) & 0xFFF;
 			adapter->rx_ring[i].rx_stats.drops += rqdpc_tmp;
+			rqdpc_total += adapter->rx_ring[i].rx_stats.drops;
 		}
+		adapter->net_stats.rx_fifo_errors = rqdpc_total;
 	}
 
+	/* Note RNBC (Receive No Buffers Count) is an not an exact
+	 * drop count as the hardware FIFO might save the day.  Thats
+	 * one of the reason for saving it in rx_fifo_errors, as its
+	 * potentially not a true drop.
+	 */
+	adapter->net_stats.rx_fifo_errors += adapter->stats.rnbc;
+
 	/* RLEC on some newer hardware can be incorrect so build
 	 * our own version based on RUC and ROC */
 	adapter->net_stats.rx_errors = adapter->stats.rxerrc +

