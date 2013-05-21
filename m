From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/12] igb: Add update to last_rx_timestamp in Rx rings
Date: Tue, 21 May 2013 15:03:13 -0700
Message-ID: <1369173800-20326-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1369173800-20326-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:53264 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753299Ab3EUWD3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 May 2013 18:03:29 -0400
In-Reply-To: <1369173800-20326-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

In order to support a more accurate check for a PTP Rx hang where the
device can no longer timestamp received packets, we need to update, per
ring, when the last Rx timestamp was. Because of how the PTP Rx hang logic
works, the current logic is valid, but properly updating the ring variable
increases the accuracy of the check.

Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h      | 9 +++++++--
 drivers/net/ethernet/intel/igb/igb_main.c | 2 +-
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 9d6c075..a905707 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -514,13 +514,18 @@ extern void igb_ptp_rx_rgtstamp(struct igb_q_vector *q_vector,
 extern void igb_ptp_rx_pktstamp(struct igb_q_vector *q_vector,
 				unsigned char *va,
 				struct sk_buff *skb);
-static inline void igb_ptp_rx_hwtstamp(struct igb_q_vector *q_vector,
+static inline void igb_ptp_rx_hwtstamp(struct igb_ring *rx_ring,
 				       union e1000_adv_rx_desc *rx_desc,
 				       struct sk_buff *skb)
 {
 	if (igb_test_staterr(rx_desc, E1000_RXDADV_STAT_TS) &&
 	    !igb_test_staterr(rx_desc, E1000_RXDADV_STAT_TSIP))
-		igb_ptp_rx_rgtstamp(q_vector, skb);
+		igb_ptp_rx_rgtstamp(rx_ring->q_vector, skb);
+
+	/* Update the last_rx_timestamp timer in order to enable watchdog check
+	 * for error case of latched timestamp on a dropped packet.
+	 */
+	rx_ring->last_rx_timestamp = jiffies;
 }
 
 extern int igb_ptp_hwtstamp_ioctl(struct net_device *netdev,
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 64cbe0d..2c8f7e0 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6622,7 +6622,7 @@ static void igb_process_skb_fields(struct igb_ring *rx_ring,
 
 	igb_rx_checksum(rx_ring, rx_desc, skb);
 
-	igb_ptp_rx_hwtstamp(rx_ring->q_vector, rx_desc, skb);
+	igb_ptp_rx_hwtstamp(rx_ring, rx_desc, skb);
 
 	if ((dev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
 	    igb_test_staterr(rx_desc, E1000_RXD_STAT_VP)) {
-- 
1.7.11.7
