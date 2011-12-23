From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/9] ixgbe: add support functions for gathering thermal data sensor
Date: Fri, 23 Dec 2011 01:09:15 -0800
Message-ID: <1324631357-31789-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1324631357-31789-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:28623 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753775Ab1LWJJY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Dec 2011 04:09:24 -0500
In-Reply-To: <1324631357-31789-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Some 82599 adapters contain thermal data that we can get to via
an i2c interface.  These functions provide support to get at that
data.  A following patch will export this data.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |  150 +++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h |   13 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h   |   38 ++++++
 3 files changed, 201 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index a3aa633..05aa156 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -3526,3 +3526,153 @@ void ixgbe_clear_tx_pending(struct ixgbe_hw *hw)
 	IXGBE_WRITE_REG(hw, IXGBE_GCR_EXT, gcr_ext);
 	IXGBE_WRITE_REG(hw, IXGBE_HLREG0, hlreg0);
 }
+
+static const u8 ixgbe_emc_temp_data[4] = {
+	IXGBE_EMC_INTERNAL_DATA,
+	IXGBE_EMC_DIODE1_DATA,
+	IXGBE_EMC_DIODE2_DATA,
+	IXGBE_EMC_DIODE3_DATA
+};
+static const u8 ixgbe_emc_therm_limit[4] = {
+	IXGBE_EMC_INTERNAL_THERM_LIMIT,
+	IXGBE_EMC_DIODE1_THERM_LIMIT,
+	IXGBE_EMC_DIODE2_THERM_LIMIT,
+	IXGBE_EMC_DIODE3_THERM_LIMIT
+};
+
+/**
+ *  ixgbe_get_thermal_sensor_data - Gathers thermal sensor data
+ *  @hw: pointer to hardware structure
+ *  @data: pointer to the thermal sensor data structure
+ *
+ *  Returns the thermal sensor data structure
+ **/
+s32 ixgbe_get_thermal_sensor_data_generic(struct ixgbe_hw *hw)
+{
+	s32 status = 0;
+	u16 ets_offset;
+	u16 ets_cfg;
+	u16 ets_sensor;
+	u8  num_sensors;
+	u8  sensor_index;
+	u8  sensor_location;
+	u8  i;
+	struct ixgbe_thermal_sensor_data *data = &hw->mac.thermal_sensor_data;
+
+	/* Only support thermal sensors attached to 82599 physical port 0 */
+	if ((hw->mac.type != ixgbe_mac_82599EB) ||
+	     (IXGBE_READ_REG(hw, IXGBE_STATUS) & IXGBE_STATUS_LAN_ID_1)) {
+		status = IXGBE_NOT_IMPLEMENTED;
+		goto out;
+	}
+
+	status = hw->eeprom.ops.read(hw, IXGBE_ETS_CFG, &ets_offset);
+	if (status)
+		goto out;
+
+	if ((ets_offset == 0x0000) || (ets_offset == 0xFFFF)) {
+		status = IXGBE_NOT_IMPLEMENTED;
+		goto out;
+	}
+
+	status = hw->eeprom.ops.read(hw, ets_offset, &ets_cfg);
+	if (status)
+		goto out;
+
+	if (((ets_cfg & IXGBE_ETS_TYPE_MASK) >> IXGBE_ETS_TYPE_SHIFT)
+	    != IXGBE_ETS_TYPE_EMC) {
+		status = IXGBE_NOT_IMPLEMENTED;
+		goto out;
+	}
+
+	num_sensors = (ets_cfg & IXGBE_ETS_NUM_SENSORS_MASK);
+	if (num_sensors > IXGBE_MAX_SENSORS)
+		num_sensors = IXGBE_MAX_SENSORS;
+
+	for (i = 0; i < num_sensors; i++) {
+		status = hw->eeprom.ops.read(hw, (ets_offset + 1 + i),
+					     &ets_sensor);
+		if (status)
+			goto out;
+
+		sensor_index = ((ets_sensor & IXGBE_ETS_DATA_INDEX_MASK) >>
+				IXGBE_ETS_DATA_INDEX_SHIFT);
+		sensor_location = ((ets_sensor & IXGBE_ETS_DATA_LOC_MASK) >>
+				   IXGBE_ETS_DATA_LOC_SHIFT);
+
+		if (sensor_location != 0) {
+			status = hw->phy.ops.read_i2c_byte(hw,
+					ixgbe_emc_temp_data[sensor_index],
+					IXGBE_I2C_THERMAL_SENSOR_ADDR,
+					&data->sensor[i].temp);
+		if (status)
+			goto out;
+		}
+	}
+out:
+	return status;
+}
+
+/**
+ * ixgbe_init_thermal_sensor_thresh_generic - Inits thermal sensor thresholds
+ * @hw: pointer to hardware structure
+ *
+ * Inits the thermal sensor thresholds according to the NVM map
+ * and save off the threshold and location values into mac.thermal_sensor_data
+ **/
+s32 ixgbe_init_thermal_sensor_thresh_generic(struct ixgbe_hw *hw)
+{
+	s32 status = 0;
+	u16 ets_offset;
+	u16 ets_cfg;
+	u16 ets_sensor;
+	u8  low_thresh_delta;
+	u8  num_sensors;
+	u8  sensor_index;
+	u8  sensor_location;
+	u8  therm_limit;
+	u8  i;
+	struct ixgbe_thermal_sensor_data *data = &hw->mac.thermal_sensor_data;
+
+	memset(data, 0, sizeof(struct ixgbe_thermal_sensor_data));
+
+	/* Only support thermal sensors attached to 82599 physical port 0 */
+	if ((hw->mac.type != ixgbe_mac_82599EB) ||
+	    (IXGBE_READ_REG(hw, IXGBE_STATUS) & IXGBE_STATUS_LAN_ID_1))
+		return IXGBE_NOT_IMPLEMENTED;
+
+	hw->eeprom.ops.read(hw, IXGBE_ETS_CFG, &ets_offset);
+	if ((ets_offset == 0x0000) || (ets_offset == 0xFFFF))
+		return IXGBE_NOT_IMPLEMENTED;
+
+	hw->eeprom.ops.read(hw, ets_offset, &ets_cfg);
+	if (((ets_cfg & IXGBE_ETS_TYPE_MASK) >> IXGBE_ETS_TYPE_SHIFT)
+	    != IXGBE_ETS_TYPE_EMC)
+		return IXGBE_NOT_IMPLEMENTED;
+
+	low_thresh_delta = ((ets_cfg & IXGBE_ETS_LTHRES_DELTA_MASK) >>
+			     IXGBE_ETS_LTHRES_DELTA_SHIFT);
+	num_sensors = (ets_cfg & IXGBE_ETS_NUM_SENSORS_MASK);
+
+	for (i = 0; i < num_sensors; i++) {
+		hw->eeprom.ops.read(hw, (ets_offset + 1 + i), &ets_sensor);
+		sensor_index = ((ets_sensor & IXGBE_ETS_DATA_INDEX_MASK) >>
+				IXGBE_ETS_DATA_INDEX_SHIFT);
+		sensor_location = ((ets_sensor & IXGBE_ETS_DATA_LOC_MASK) >>
+				   IXGBE_ETS_DATA_LOC_SHIFT);
+		therm_limit = ets_sensor & IXGBE_ETS_DATA_HTHRESH_MASK;
+
+		hw->phy.ops.write_i2c_byte(hw,
+			ixgbe_emc_therm_limit[sensor_index],
+			IXGBE_I2C_THERMAL_SENSOR_ADDR, therm_limit);
+
+		if ((i < IXGBE_MAX_SENSORS) && (sensor_location != 0)) {
+			data->sensor[i].location = sensor_location;
+			data->sensor[i].caution_thresh = therm_limit;
+			data->sensor[i].max_op_thresh = therm_limit -
+							low_thresh_delta;
+		}
+	}
+	return status;
+}
+
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
index 863f9c1..876c7f3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
@@ -105,6 +105,19 @@ void ixgbe_clear_tx_pending(struct ixgbe_hw *hw);
 void ixgbe_set_rxpba_generic(struct ixgbe_hw *hw, int num_pb,
 			     u32 headroom, int strategy);
 
+#define IXGBE_I2C_THERMAL_SENSOR_ADDR	0xF8
+#define IXGBE_EMC_INTERNAL_DATA		0x00
+#define IXGBE_EMC_INTERNAL_THERM_LIMIT	0x20
+#define IXGBE_EMC_DIODE1_DATA		0x01
+#define IXGBE_EMC_DIODE1_THERM_LIMIT	0x19
+#define IXGBE_EMC_DIODE2_DATA		0x23
+#define IXGBE_EMC_DIODE2_THERM_LIMIT	0x1A
+#define IXGBE_EMC_DIODE3_DATA		0x2A
+#define IXGBE_EMC_DIODE3_THERM_LIMIT	0x30
+
+s32 ixgbe_get_thermal_sensor_data_generic(struct ixgbe_hw *hw);
+s32 ixgbe_init_thermal_sensor_thresh_generic(struct ixgbe_hw *hw);
+
 #define IXGBE_WRITE_REG(a, reg, value) writel((value), ((a)->hw_addr + (reg)))
 
 #ifndef writeq
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 7c5817f..c5fba00 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -109,6 +109,26 @@
 #define IXGBE_I2C_CLK_OUT   0x00000002
 #define IXGBE_I2C_DATA_IN   0x00000004
 #define IXGBE_I2C_DATA_OUT  0x00000008
+#define IXGBE_I2C_THERMAL_SENSOR_ADDR   0xF8
+#define IXGBE_EMC_INTERNAL_DATA         0x00
+#define IXGBE_EMC_INTERNAL_THERM_LIMIT  0x20
+#define IXGBE_EMC_DIODE1_DATA           0x01
+#define IXGBE_EMC_DIODE1_THERM_LIMIT    0x19
+#define IXGBE_EMC_DIODE2_DATA           0x23
+#define IXGBE_EMC_DIODE2_THERM_LIMIT    0x1A
+
+#define IXGBE_MAX_SENSORS               3
+
+struct ixgbe_thermal_diode_data {
+	u8 location;
+	u8 temp;
+	u8 caution_thresh;
+	u8 max_op_thresh;
+};
+
+struct ixgbe_thermal_sensor_data {
+	 struct ixgbe_thermal_diode_data sensor[IXGBE_MAX_SENSORS];
+};
 
 /* Interrupt Registers */
 #define IXGBE_EICR      0x00800
@@ -1674,6 +1694,21 @@ enum {
 #define IXGBE_PBANUM0_PTR       0x15
 #define IXGBE_PBANUM1_PTR       0x16
 #define IXGBE_FREE_SPACE_PTR    0X3E
+
+/* External Thermal Sensor Config */
+#define IXGBE_ETS_CFG                   0x26
+#define IXGBE_ETS_LTHRES_DELTA_MASK     0x07C0
+#define IXGBE_ETS_LTHRES_DELTA_SHIFT    6
+#define IXGBE_ETS_TYPE_MASK             0x0038
+#define IXGBE_ETS_TYPE_SHIFT            3
+#define IXGBE_ETS_TYPE_EMC              0x000
+#define IXGBE_ETS_NUM_SENSORS_MASK      0x0007
+#define IXGBE_ETS_DATA_LOC_MASK         0x3C00
+#define IXGBE_ETS_DATA_LOC_SHIFT        10
+#define IXGBE_ETS_DATA_INDEX_MASK       0x0300
+#define IXGBE_ETS_DATA_INDEX_SHIFT      8
+#define IXGBE_ETS_DATA_HTHRESH_MASK     0x00FF
+
 #define IXGBE_SAN_MAC_ADDR_PTR  0x28
 #define IXGBE_DEVICE_CAPS       0x2C
 #define IXGBE_SERIAL_NUMBER_MAC_ADDR 0x11
@@ -2767,6 +2802,8 @@ struct ixgbe_mac_operations {
 
 	/* Manageability interface */
 	s32 (*set_fw_drv_ver)(struct ixgbe_hw *, u8, u8, u8, u8);
+	s32 (*get_thermal_sensor_data)(struct ixgbe_hw *);
+	s32 (*init_thermal_sensor_thresh)(struct ixgbe_hw *hw);
 };
 
 struct ixgbe_phy_operations {
@@ -2824,6 +2861,7 @@ struct ixgbe_mac_info {
 	bool                            orig_link_settings_stored;
 	bool                            autotry_restart;
 	u8                              flags;
+	struct ixgbe_thermal_sensor_data  thermal_sensor_data;
 };
 
 struct ixgbe_phy_info {
-- 
1.7.7.4
