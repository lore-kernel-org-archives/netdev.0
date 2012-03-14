From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/7] ixgbe: Replace eitr_low and eitr_high with static values in ixgbe_update_itr
Date: Wed, 14 Mar 2012 00:55:22 -0700
Message-ID: <1331711726-9439-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1331711726-9439-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:47737 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757865Ab2CNHzb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Mar 2012 03:55:31 -0400
In-Reply-To: <1331711726-9439-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

There isn't much point in using variables to store the values of eitr_low
and eitr_high since they are not user changeable.  As such I am replacing
them with the constants 10 and 20 in order to avoid any confusion on what
the values actually are.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    4 ----
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   21 ++++++++-------------
 2 files changed, 8 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 03175cb..f069c1b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -511,10 +511,6 @@ struct ixgbe_adapter {
 #endif /* IXGBE_FCOE */
 	u32 wol;
 
-	/* Interrupt Throttle Rate */
-	u16 eitr_low;
-	u16 eitr_high;
-
 	u16 bd_number;
 
 	u16 eeprom_verh;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index ac35324..71ced43 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1782,20 +1782,19 @@ enum latency_range {
 static void ixgbe_update_itr(struct ixgbe_q_vector *q_vector,
 			     struct ixgbe_ring_container *ring_container)
 {
-	u64 bytes_perint;
-	struct ixgbe_adapter *adapter = q_vector->adapter;
 	int bytes = ring_container->total_bytes;
 	int packets = ring_container->total_packets;
 	u32 timepassed_us;
+	u64 bytes_perint;
 	u8 itr_setting = ring_container->itr;
 
 	if (packets == 0)
 		return;
 
 	/* simple throttlerate management
-	 *    0-20MB/s lowest (100000 ints/s)
-	 *   20-100MB/s low   (20000 ints/s)
-	 *  100-1249MB/s bulk (8000 ints/s)
+	 *   0-10MB/s   lowest (100000 ints/s)
+	 *  10-20MB/s   low    (20000 ints/s)
+	 *  20-1249MB/s bulk   (8000 ints/s)
 	 */
 	/* what was last interrupt timeslice? */
 	timepassed_us = q_vector->itr >> 2;
@@ -1803,17 +1802,17 @@ static void ixgbe_update_itr(struct ixgbe_q_vector *q_vector,
 
 	switch (itr_setting) {
 	case lowest_latency:
-		if (bytes_perint > adapter->eitr_low)
+		if (bytes_perint > 10)
 			itr_setting = low_latency;
 		break;
 	case low_latency:
-		if (bytes_perint > adapter->eitr_high)
+		if (bytes_perint > 20)
 			itr_setting = bulk_latency;
-		else if (bytes_perint <= adapter->eitr_low)
+		else if (bytes_perint <= 10)
 			itr_setting = lowest_latency;
 		break;
 	case bulk_latency:
-		if (bytes_perint <= adapter->eitr_high)
+		if (bytes_perint <= 20)
 			itr_setting = low_latency;
 		break;
 	}
@@ -5239,10 +5238,6 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	adapter->rx_itr_setting = 1;
 	adapter->tx_itr_setting = 1;
 
-	/* set defaults for eitr in MegaBytes */
-	adapter->eitr_low = 10;
-	adapter->eitr_high = 20;
-
 	/* set default ring sizes */
 	adapter->tx_ring_count = IXGBE_DEFAULT_TXD;
 	adapter->rx_ring_count = IXGBE_DEFAULT_RXD;
-- 
1.7.7.6
