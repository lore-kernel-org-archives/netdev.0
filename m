From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] igb: introduce ptp_flags variable and use it to replace IGB_FLAG_PTP
Date: Wed, 29 Jun 2016 14:32:54 -0700
Message-ID: <1467235982-55437-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1467235982-55437-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:37786 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751830AbcF2VdH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 17:33:07 -0400
In-Reply-To: <1467235982-55437-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Upcoming patches will introduce new PTP specific flags. To avoid
cluttering the normal flags variable, introduce PTP specific "ptp_flags"
variable for this purpose, and move IGB_FLAG_PTP to become
IGB_PTP_ENABLED.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h     | 5 ++++-
 drivers/net/ethernet/intel/igb/igb_ptp.c | 7 ++++---
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index b9609af..1e18a9e 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -445,6 +445,7 @@ struct igb_adapter {
 	unsigned long ptp_tx_start;
 	unsigned long last_rx_ptp_check;
 	unsigned long last_rx_timestamp;
+	unsigned int ptp_flags;
 	spinlock_t tmreg_lock;
 	struct cyclecounter cc;
 	struct timecounter tc;
@@ -474,12 +475,14 @@ struct igb_adapter {
 	u16 eee_advert;
 };
 
+/* flags controlling PTP/1588 function */
+#define IGB_PTP_ENABLED		BIT(0)
+
 #define IGB_FLAG_HAS_MSI		BIT(0)
 #define IGB_FLAG_DCA_ENABLED		BIT(1)
 #define IGB_FLAG_QUAD_PORT_A		BIT(2)
 #define IGB_FLAG_QUEUE_PAIRS		BIT(3)
 #define IGB_FLAG_DMAC			BIT(4)
-#define IGB_FLAG_PTP			BIT(5)
 #define IGB_FLAG_RSS_FIELD_IPV4_UDP	BIT(6)
 #define IGB_FLAG_RSS_FIELD_IPV6_UDP	BIT(7)
 #define IGB_FLAG_WOL_SUPPORTED		BIT(8)
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index f097c5a..504102b 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -684,6 +684,7 @@ void igb_ptp_rx_hang(struct igb_adapter *adapter)
 	u32 tsyncrxctl = rd32(E1000_TSYNCRXCTL);
 	unsigned long rx_event;
 
+	/* Other hardware uses per-packet timestamps */
 	if (hw->mac.type != e1000_82576)
 		return;
 
@@ -1156,7 +1157,7 @@ void igb_ptp_init(struct igb_adapter *adapter)
 	} else {
 		dev_info(&adapter->pdev->dev, "added PHC on %s\n",
 			 adapter->netdev->name);
-		adapter->flags |= IGB_FLAG_PTP;
+		adapter->ptp_flags |= IGB_PTP_ENABLED;
 	}
 }
 
@@ -1194,7 +1195,7 @@ void igb_ptp_stop(struct igb_adapter *adapter)
 		ptp_clock_unregister(adapter->ptp_clock);
 		dev_info(&adapter->pdev->dev, "removed PHC on %s\n",
 			 adapter->netdev->name);
-		adapter->flags &= ~IGB_FLAG_PTP;
+		adapter->ptp_flags &= ~IGB_PTP_ENABLED;
 	}
 }
 
@@ -1209,7 +1210,7 @@ void igb_ptp_reset(struct igb_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	unsigned long flags;
 
-	if (!(adapter->flags & IGB_FLAG_PTP))
+	if (!(adapter->ptp_flags & IGB_PTP_ENABLED))
 		return;
 
 	/* reset the tstamp_config */
-- 
2.5.5
