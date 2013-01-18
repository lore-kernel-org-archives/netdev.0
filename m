From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/12] igb: Add support functions to access thermal data.
Date: Fri, 18 Jan 2013 07:04:41 -0800
Message-ID: <1358521487-28610-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1358521487-28610-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:2759 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756171Ab3ARPE4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2013 10:04:56 -0500
In-Reply-To: <1358521487-28610-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

Some of our devices have internal sensors for reporting thermal data.
This patch creates the interface to the sensors for exporting via sysfs.
Subsequent patch will actually export the data.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.h   |  9 ++++++++-
 drivers/net/ethernet/intel/igb/e1000_defines.h | 12 ++++++++++++
 drivers/net/ethernet/intel/igb/e1000_hw.h      | 14 ++++++++++++++
 drivers/net/ethernet/intel/igb/e1000_regs.h    |  8 ++++++++
 4 files changed, 42 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.h b/drivers/net/ethernet/intel/igb/e1000_82575.h
index 67bd9f9..caf6abf 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.h
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.h
@@ -266,5 +266,12 @@ u16 igb_rxpbs_adjust_82580(u32 data);
 s32 igb_set_eee_i350(struct e1000_hw *);
 
 #define E1000_I2C_THERMAL_SENSOR_ADDR	0xF8
-
+#define E1000_EMC_INTERNAL_DATA		0x00
+#define E1000_EMC_INTERNAL_THERM_LIMIT	0x20
+#define E1000_EMC_DIODE1_DATA		0x01
+#define E1000_EMC_DIODE1_THERM_LIMIT	0x19
+#define E1000_EMC_DIODE2_DATA		0x23
+#define E1000_EMC_DIODE2_THERM_LIMIT	0x1A
+#define E1000_EMC_DIODE3_DATA		0x2A
+#define E1000_EMC_DIODE3_THERM_LIMIT	0x30
 #endif
diff --git a/drivers/net/ethernet/intel/igb/e1000_defines.h b/drivers/net/ethernet/intel/igb/e1000_defines.h
index 446678e..9b7ef93 100644
--- a/drivers/net/ethernet/intel/igb/e1000_defines.h
+++ b/drivers/net/ethernet/intel/igb/e1000_defines.h
@@ -675,6 +675,18 @@
 #define NVM_COMB_VER_SHFT               8
 #define NVM_VER_INVALID            0xFFFF
 #define NVM_ETRACK_SHIFT               16
+#define NVM_ETS_CFG			0x003E
+#define NVM_ETS_LTHRES_DELTA_MASK	0x07C0
+#define NVM_ETS_LTHRES_DELTA_SHIFT	6
+#define NVM_ETS_TYPE_MASK		0x0038
+#define NVM_ETS_TYPE_SHIFT		3
+#define NVM_ETS_TYPE_EMC		0x000
+#define NVM_ETS_NUM_SENSORS_MASK	0x0007
+#define NVM_ETS_DATA_LOC_MASK		0x3C00
+#define NVM_ETS_DATA_LOC_SHIFT		10
+#define NVM_ETS_DATA_INDEX_MASK		0x0300
+#define NVM_ETS_DATA_INDEX_SHIFT	8
+#define NVM_ETS_DATA_HTHRESH_MASK	0x00FF
 
 #define E1000_NVM_CFG_DONE_PORT_0  0x040000 /* MNG config cycle done */
 #define E1000_NVM_CFG_DONE_PORT_1  0x080000 /* ...for second port */
diff --git a/drivers/net/ethernet/intel/igb/e1000_hw.h b/drivers/net/ethernet/intel/igb/e1000_hw.h
index 75312ba..837a274 100644
--- a/drivers/net/ethernet/intel/igb/e1000_hw.h
+++ b/drivers/net/ethernet/intel/igb/e1000_hw.h
@@ -356,6 +356,19 @@ struct e1000_nvm_operations {
 	s32  (*valid_led_default)(struct e1000_hw *, u16 *);
 };
 
+#define E1000_MAX_SENSORS		3
+
+struct e1000_thermal_diode_data {
+	u8 location;
+	u8 temp;
+	u8 caution_thresh;
+	u8 max_op_thresh;
+};
+
+struct e1000_thermal_sensor_data {
+	struct e1000_thermal_diode_data sensor[E1000_MAX_SENSORS];
+};
+
 struct e1000_info {
 	s32 (*get_invariants)(struct e1000_hw *);
 	struct e1000_mac_operations *mac_ops;
@@ -401,6 +414,7 @@ struct e1000_mac_info {
 	bool report_tx_early;
 	bool serdes_has_link;
 	bool tx_pkt_filtering;
+	struct e1000_thermal_sensor_data thermal_sensor_data;
 };
 
 struct e1000_phy_info {
diff --git a/drivers/net/ethernet/intel/igb/e1000_regs.h b/drivers/net/ethernet/intel/igb/e1000_regs.h
index 31c3e2f..889de26 100644
--- a/drivers/net/ethernet/intel/igb/e1000_regs.h
+++ b/drivers/net/ethernet/intel/igb/e1000_regs.h
@@ -132,6 +132,14 @@
 
 /* Split and Replication RX Control - RW */
 #define E1000_RXPBS    0x02404  /* Rx Packet Buffer Size - RW */
+
+/* Thermal sensor configuration and status registers */
+#define E1000_THMJT	0x08100 /* Junction Temperature */
+#define E1000_THLOWTC	0x08104 /* Low Threshold Control */
+#define E1000_THMIDTC	0x08108 /* Mid Threshold Control */
+#define E1000_THHIGHTC	0x0810C /* High Threshold Control */
+#define E1000_THSTAT	0x08110 /* Thermal Sensor Status */
+
 /*
  * Convenience macros
  *
-- 
1.7.11.7
