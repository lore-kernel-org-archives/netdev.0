From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] catch up device stats when multicast > total frames
Date: Tue, 5 Aug 2008 07:50:18 -0400
Message-ID: <20080805115018.GB22123@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nhorman@tuxdriver.com, e1000-devel@lists.sourceforge.net,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, john.ronciak@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4109 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758931AbYHELuv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Aug 2008 07:50:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey-
	REcently observed a problem wherein, if a BMC or other IPMI device is
attached to a NIC, multicast frames can be consumed by the aformentioned device
without ever being seen by the driver.  Since multicast frames are counted in
the hardware and the total frame counter is counted in the driver napi routine,
its possible to have a condition in which the number of received multicast
frames exceeds the total number of frames.  This patch re-aligns those values on
receive, so that the total frame count is always at least as large as the
received frame count.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 e1000_main.c |    6 ++++++
 1 file changed, 6 insertions(+)


diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 59579b1..66afee8 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3761,6 +3761,8 @@ e1000_update_stats(struct e1000_adapter *adapter)
 	/* Fill out the OS statistics structure */
 	adapter->net_stats.multicast = adapter->stats.mprc;
 	adapter->net_stats.collisions = adapter->stats.colc;
+	if (adapter->net_stats.rx_packets < adapter->net_stats.multicast)
+		adapter->net_stats.rx_packets = adapter->net_stats.multicast;
 
 	/* Rx Errors */
 
@@ -4347,6 +4349,8 @@ next_desc:
 		adapter->alloc_rx_buf(adapter, rx_ring, cleaned_count);
 
 	adapter->total_rx_packets += total_rx_packets;
+	if (adapter->total_rx_packets < adapter->net_stats.multicast)
+		adapter->total_rx_packets = adapter->net_stats.multicast;
 	adapter->total_rx_bytes += total_rx_bytes;
 	adapter->net_stats.rx_bytes += total_rx_bytes;
 	adapter->net_stats.rx_packets += total_rx_packets;
@@ -4536,6 +4540,8 @@ next_desc:
 		adapter->alloc_rx_buf(adapter, rx_ring, cleaned_count);
 
 	adapter->total_rx_packets += total_rx_packets;
+	if (adapter->total_rx_packets < adapter->net_stats.multicast)
+		adapter->total_rx_packets = adapter->net_stats.multicast;
 	adapter->total_rx_bytes += total_rx_bytes;
 	adapter->net_stats.rx_bytes += total_rx_bytes;
 	adapter->net_stats.rx_packets += total_rx_packets;
-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
