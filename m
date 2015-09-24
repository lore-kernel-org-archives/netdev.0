From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/18] ixgbe: Limit SFP polling rate
Date: Wed, 23 Sep 2015 23:59:30 -0700
Message-ID: <1443077981-55791-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443077981-55791-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:48624 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932626AbbIXG7z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2015 02:59:55 -0400
In-Reply-To: <1443077981-55791-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Reduce the frequency of polling for SFP modules. Because the
service task sometimes runs at high rates, we can poll for
SFPs too often. When an SFP is not present, the I2C timeouts
that result are very costly. So, prevent SFP polling from
being done more than once every two seconds. To reduce latency,
the poll time is cleared in a couple of cases to permit the
next service task execution to poll the SFP module.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      | 2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 8 ++++++++
 2 files changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index a699c99..dda0f67 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -594,6 +594,7 @@ struct ixgbe_mac_addr {
 
 /* default to trying for four seconds */
 #define IXGBE_TRY_LINK_TIMEOUT (4 * HZ)
+#define IXGBE_SFP_POLL_JIFFIES (2 * HZ)	/* SFP poll every 2 seconds */
 
 /* board specific private data structure */
 struct ixgbe_adapter {
@@ -707,6 +708,7 @@ struct ixgbe_adapter {
 
 	u32 link_speed;
 	bool link_up;
+	unsigned long sfp_poll_time;
 	unsigned long link_check_timeout;
 
 	struct timer_list service_timer;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 369204c..9986be5 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2509,6 +2509,7 @@ static void ixgbe_check_sfp_event(struct ixgbe_adapter *adapter, u32 eicr)
 		IXGBE_WRITE_REG(hw, IXGBE_EICR, eicr_mask);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state)) {
 			adapter->flags2 |= IXGBE_FLAG2_SFP_NEEDS_RESET;
+			adapter->sfp_poll_time = 0;
 			ixgbe_service_event_schedule(adapter);
 		}
 	}
@@ -4804,6 +4805,7 @@ static void ixgbe_sfp_link_config(struct ixgbe_adapter *adapter)
 		adapter->flags2 |= IXGBE_FLAG2_SEARCH_FOR_SFP;
 
 	adapter->flags2 |= IXGBE_FLAG2_SFP_NEEDS_RESET;
+	adapter->sfp_poll_time = 0;
 }
 
 /**
@@ -6709,10 +6711,16 @@ static void ixgbe_sfp_detection_subtask(struct ixgbe_adapter *adapter)
 	    !(adapter->flags2 & IXGBE_FLAG2_SFP_NEEDS_RESET))
 		return;
 
+	if (adapter->sfp_poll_time &&
+	    time_after(adapter->sfp_poll_time, jiffies))
+		return; /* If not yet time to poll for SFP */
+
 	/* someone else is in init, wait until next service event */
 	if (test_and_set_bit(__IXGBE_IN_SFP_INIT, &adapter->state))
 		return;
 
+	adapter->sfp_poll_time = jiffies + IXGBE_SFP_POLL_JIFFIES - 1;
+
 	err = hw->phy.ops.identify_sfp(hw);
 	if (err == IXGBE_ERR_SFP_NOT_SUPPORTED)
 		goto sfp_out;
-- 
2.4.3
