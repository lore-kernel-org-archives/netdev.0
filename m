From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/6] mlxsw: reg: Add definition of temperature management registers
Date: Thu, 26 Nov 2015 12:03:30 +0100
Message-ID: <1448535813-14882-4-git-send-email-jiri@resnulli.us>
References: <1448535813-14882-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:33288 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752119AbbKZLDk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 06:03:40 -0500
Received: by wmec201 with SMTP id c201so25796169wme.0
        for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 03:03:38 -0800 (PST)
In-Reply-To: <1448535813-14882-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add definition of MTCAP and MTMP registers which provide access to
temperature sensors.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 111 ++++++++++++++++++++++++++++++
 1 file changed, 111 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index fc6839d..459e0490 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -2087,6 +2087,113 @@ static inline void mlxsw_reg_hpkt_pack(char *payload, u8 action, u16 trap_id)
 	mlxsw_reg_hpkt_ctrl_set(payload, MLXSW_REG_HPKT_CTRL_PACKET_DEFAULT);
 }
 
+/* MTCAP - Management Temperature Capabilities
+ * -------------------------------------------
+ * This register exposes the capabilities of the device and
+ * system temperature sensing.
+ */
+#define MLXSW_REG_MTCAP_ID 0x9009
+#define MLXSW_REG_MTCAP_LEN 0x08
+
+static const struct mlxsw_reg_info mlxsw_reg_mtcap = {
+	.id = MLXSW_REG_MTCAP_ID,
+	.len = MLXSW_REG_MTCAP_LEN,
+};
+
+/* reg_mtcap_sensor_count
+ * Number of sensors supported by the device.
+ * This includes the QSFP module sensors (if exists in the QSFP module).
+ * Access: RO
+ */
+MLXSW_ITEM32(reg, mtcap, sensor_count, 0x00, 0, 7);
+
+/* MTMP - Management Temperature
+ * -----------------------------
+ * This register controls the settings of the temperature measurements
+ * and enables reading the temperature measurements. Note that temperature
+ * is in 0.125 degrees Celsius.
+ */
+#define MLXSW_REG_MTMP_ID 0x900A
+#define MLXSW_REG_MTMP_LEN 0x20
+
+static const struct mlxsw_reg_info mlxsw_reg_mtmp = {
+	.id = MLXSW_REG_MTMP_ID,
+	.len = MLXSW_REG_MTMP_LEN,
+};
+
+/* reg_mtmp_sensor_index
+ * Sensors index to access.
+ * 64-127 of sensor_index are mapped to the SFP+/QSFP modules sequentially
+ * (module 0 is mapped to sensor_index 64).
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, mtmp, sensor_index, 0x00, 0, 7);
+
+/* Convert to milli degrees Celsius */
+#define MLXSW_REG_MTMP_TEMP_TO_MC(val) (val * 125)
+
+/* reg_mtmp_temperature
+ * Temperature reading from the sensor. Reading is in 0.125 Celsius
+ * degrees units.
+ * Access: RO
+ */
+MLXSW_ITEM32(reg, mtmp, temperature, 0x04, 0, 16);
+
+/* reg_mtmp_mte
+ * Max Temperature Enable - enables measuring the max temperature on a sensor.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, mtmp, mte, 0x08, 31, 1);
+
+/* reg_mtmp_mtr
+ * Max Temperature Reset - clears the value of the max temperature register.
+ * Access: WO
+ */
+MLXSW_ITEM32(reg, mtmp, mtr, 0x08, 30, 1);
+
+/* reg_mtmp_max_temperature
+ * The highest measured temperature from the sensor.
+ * When the bit mte is cleared, the field max_temperature is reserved.
+ * Access: RO
+ */
+MLXSW_ITEM32(reg, mtmp, max_temperature, 0x08, 0, 16);
+
+#define MLXSW_REG_MTMP_SENSOR_NAME_SIZE 8
+
+/* reg_mtmp_sensor_name
+ * Sensor Name
+ * Access: RO
+ */
+MLXSW_ITEM_BUF(reg, mtmp, sensor_name, 0x18, MLXSW_REG_MTMP_SENSOR_NAME_SIZE);
+
+static inline void mlxsw_reg_mtmp_pack(char *payload, u8 sensor_index,
+				       bool max_temp_enable,
+				       bool max_temp_reset)
+{
+	MLXSW_REG_ZERO(mtmp, payload);
+	mlxsw_reg_mtmp_sensor_index_set(payload, sensor_index);
+	mlxsw_reg_mtmp_mte_set(payload, max_temp_enable);
+	mlxsw_reg_mtmp_mtr_set(payload, max_temp_reset);
+}
+
+static inline void mlxsw_reg_mtmp_unpack(char *payload, unsigned int *p_temp,
+					 unsigned int *p_max_temp,
+					 char *sensor_name)
+{
+	u16 temp;
+
+	if (p_temp) {
+		temp = mlxsw_reg_mtmp_temperature_get(payload);
+		*p_temp = MLXSW_REG_MTMP_TEMP_TO_MC(temp);
+	}
+	if (p_max_temp) {
+		temp = mlxsw_reg_mtmp_temperature_get(payload);
+		*p_max_temp = MLXSW_REG_MTMP_TEMP_TO_MC(temp);
+	}
+	if (sensor_name)
+		mlxsw_reg_mtmp_sensor_name_memcpy_from(payload, sensor_name);
+}
+
 /* MLCR - Management LED Control Register
  * --------------------------------------
  * Controls the system LEDs.
@@ -2449,6 +2556,10 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "HTGT";
 	case MLXSW_REG_HPKT_ID:
 		return "HPKT";
+	case MLXSW_REG_MTCAP_ID:
+		return "MTCAP";
+	case MLXSW_REG_MTMP_ID:
+		return "MTMP";
 	case MLXSW_REG_MLCR_ID:
 		return "MLCR";
 	case MLXSW_REG_SBPR_ID:
-- 
1.9.3
