From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] igb: re-use igb_ptp_reset in igb_ptp_init
Date: Wed, 29 Jun 2016 14:32:56 -0700
Message-ID: <1467235982-55437-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1467235982-55437-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:58211 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751550AbcF2VdI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 17:33:08 -0400
In-Reply-To: <1467235982-55437-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Modify igb_ptp_init to take advantage of igb_ptp_reset, and remove
duplicated work that was occurring in both igb_ptp_reset and
igb_ptp_init.

In total, resetting the TSAUXC register, and resetting the system time
both happen in igb_ptp_reset already. igb_ptp_reset now also takes care
of starting the delayed work item for overflow checks, as well.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |  3 +-
 drivers/net/ethernet/intel/igb/igb_ptp.c  | 48 +++++++++++--------------------
 2 files changed, 18 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index ef3d642..750a5d8 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2027,7 +2027,8 @@ void igb_reset(struct igb_adapter *adapter)
 	wr32(E1000_VET, ETHERNET_IEEE_VLAN_TYPE);
 
 	/* Re-enable PTP, where applicable. */
-	igb_ptp_reset(adapter);
+	if (adapter->ptp_flags & IGB_PTP_ENABLED)
+		igb_ptp_reset(adapter);
 
 	igb_get_phy_info(hw);
 }
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 88d367d..907c225 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -1043,6 +1043,13 @@ int igb_ptp_set_ts_config(struct net_device *netdev, struct ifreq *ifr)
 		-EFAULT : 0;
 }
 
+/**
+ * igb_ptp_init - Initialize PTP functionality
+ * @adapter: Board private structure
+ *
+ * This function is called at device probe to initialize the PTP
+ * functionality.
+ */
 void igb_ptp_init(struct igb_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
@@ -1065,8 +1072,6 @@ void igb_ptp_init(struct igb_adapter *adapter)
 		adapter->cc.mask = CYCLECOUNTER_MASK(64);
 		adapter->cc.mult = 1;
 		adapter->cc.shift = IGB_82576_TSYNC_SHIFT;
-		/* Dial the nominal frequency. */
-		wr32(E1000_TIMINCA, INCPERIOD_82576 | INCVALUE_82576);
 		adapter->ptp_flags |= IGB_PTP_OVERFLOW_CHECK;
 		break;
 	case e1000_82580:
@@ -1086,8 +1091,6 @@ void igb_ptp_init(struct igb_adapter *adapter)
 		adapter->cc.mask = CYCLECOUNTER_MASK(IGB_NBITS_82580);
 		adapter->cc.mult = 1;
 		adapter->cc.shift = 0;
-		/* Enable the timer functions by clearing bit 31. */
-		wr32(E1000_TSAUXC, 0x0);
 		adapter->ptp_flags |= IGB_PTP_OVERFLOW_CHECK;
 		break;
 	case e1000_i210:
@@ -1113,46 +1116,24 @@ void igb_ptp_init(struct igb_adapter *adapter)
 		adapter->ptp_caps.settime64 = igb_ptp_settime_i210;
 		adapter->ptp_caps.enable = igb_ptp_feature_enable_i210;
 		adapter->ptp_caps.verify = igb_ptp_verify_pin;
-		/* Enable the timer functions by clearing bit 31. */
-		wr32(E1000_TSAUXC, 0x0);
 		break;
 	default:
 		adapter->ptp_clock = NULL;
 		return;
 	}
 
-	wrfl();
-
 	spin_lock_init(&adapter->tmreg_lock);
 	INIT_WORK(&adapter->ptp_tx_work, igb_ptp_tx_work);
 
-	/* Initialize the clock and overflow work for devices that need it. */
-	if ((hw->mac.type == e1000_i210) || (hw->mac.type == e1000_i211)) {
-		struct timespec64 ts = ktime_to_timespec64(ktime_get_real());
-
-		igb_ptp_settime_i210(&adapter->ptp_caps, &ts);
-	} else {
-		timecounter_init(&adapter->tc, &adapter->cc,
-				 ktime_to_ns(ktime_get_real()));
-	}
-
-	if (adapter->ptp_flags & IGB_PTP_OVERFLOW_CHECK) {
+	if (adapter->ptp_flags & IGB_PTP_OVERFLOW_CHECK)
 		INIT_DELAYED_WORK(&adapter->ptp_overflow_work,
 				  igb_ptp_overflow_check);
 
-		schedule_delayed_work(&adapter->ptp_overflow_work,
-				      IGB_SYSTIM_OVERFLOW_PERIOD);
-	}
-
-	/* Initialize the time sync interrupts for devices that support it. */
-	if (hw->mac.type >= e1000_82580) {
-		wr32(E1000_TSIM, TSYNC_INTERRUPTS);
-		wr32(E1000_IMS, E1000_IMS_TS);
-	}
-
 	adapter->tstamp_config.rx_filter = HWTSTAMP_FILTER_NONE;
 	adapter->tstamp_config.tx_type = HWTSTAMP_TX_OFF;
 
+	igb_ptp_reset(adapter);
+
 	adapter->ptp_clock = ptp_clock_register(&adapter->ptp_caps,
 						&adapter->pdev->dev);
 	if (IS_ERR(adapter->ptp_clock)) {
@@ -1205,9 +1186,6 @@ void igb_ptp_reset(struct igb_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	unsigned long flags;
 
-	if (!(adapter->ptp_flags & IGB_PTP_ENABLED))
-		return;
-
 	/* reset the tstamp_config */
 	igb_ptp_set_timestamp_mode(adapter, &adapter->tstamp_config);
 
@@ -1244,4 +1222,10 @@ void igb_ptp_reset(struct igb_adapter *adapter)
 	}
 out:
 	spin_unlock_irqrestore(&adapter->tmreg_lock, flags);
+
+	wrfl();
+
+	if (adapter->ptp_flags & IGB_PTP_OVERFLOW_CHECK)
+		schedule_delayed_work(&adapter->ptp_overflow_work,
+				      IGB_SYSTIM_OVERFLOW_PERIOD);
 }
-- 
2.5.5
