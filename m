From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/14] igb: Add message when malformed packets detected by hw
Date: Thu, 24 Jul 2014 06:13:15 -0700
Message-ID: <1406207604-31653-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1406207604-31653-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:36503 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759124AbaGXNOF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2014 09:14:05 -0400
In-Reply-To: <1406207604-31653-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch adds a check and prints the error cause register value when
the hardware detects a malformed packet.  This is a very unlikely
scenario but has been seen occasionally, so printing the message to
assist the user.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_regs.h |  1 +
 drivers/net/ethernet/intel/igb/igb_main.c   | 25 +++++++++++++++++++++++++
 2 files changed, 26 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/e1000_regs.h b/drivers/net/ethernet/intel/igb/e1000_regs.h
index f5ba4e4..6f0490d 100644
--- a/drivers/net/ethernet/intel/igb/e1000_regs.h
+++ b/drivers/net/ethernet/intel/igb/e1000_regs.h
@@ -355,6 +355,7 @@
 #define E1000_UTA       0x0A000 /* Unicast Table Array - RW */
 #define E1000_IOVTCL    0x05BBC /* IOV Control Register */
 #define E1000_TXSWC     0x05ACC /* Tx Switch Control */
+#define E1000_LVMMC	0x03548 /* Last VM Misbehavior cause */
 /* These act per VF so an array friendly macro is used */
 #define E1000_P2VMAILBOX(_n)   (0x00C00 + (4 * (_n)))
 #define E1000_VMBMEM(_n)       (0x00800 + (64 * (_n)))
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 4d2dc17..bd8de67 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -4167,6 +4167,26 @@ static bool igb_thermal_sensor_event(struct e1000_hw *hw, u32 event)
 }
 
 /**
+ *  igb_check_lvmmc - check for malformed packets received
+ *  and indicated in LVMMC register
+ *  @adapter: pointer to adapter
+ **/
+static void igb_check_lvmmc(struct igb_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 lvmmc;
+
+	lvmmc = rd32(E1000_LVMMC);
+	if (lvmmc) {
+		if (unlikely(net_ratelimit())) {
+			netdev_warn(adapter->netdev,
+				    "malformed Tx packet detected and dropped, LVMMC:0x%08x\n",
+				    lvmmc);
+		}
+	}
+}
+
+/**
  *  igb_watchdog - Timer Call-back
  *  @data: pointer to adapter cast into an unsigned long
  **/
@@ -4361,6 +4381,11 @@ static void igb_watchdog_task(struct work_struct *work)
 	igb_spoof_check(adapter);
 	igb_ptp_rx_hang(adapter);
 
+	/* Check LVMMC register on i350/i354 only */
+	if ((adapter->hw.mac.type == e1000_i350) ||
+	    (adapter->hw.mac.type == e1000_i354))
+		igb_check_lvmmc(adapter);
+
 	/* Reset the timer */
 	if (!test_bit(__IGB_DOWN, &adapter->state)) {
 		if (adapter->flags & IGB_FLAG_NEED_LINK_UPDATE)
-- 
1.9.3
