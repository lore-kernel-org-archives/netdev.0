From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/9] igb: Add support functions to access thermal data.
Date: Sat,  9 Jun 2012 01:20:55 -0700
Message-ID: <1339230063-12545-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1339230063-12545-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:40735 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751913Ab2FIIVI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jun 2012 04:21:08 -0400
In-Reply-To: <1339230063-12545-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

Some i350 devices contain thermal data that we can get to via an i2c
interface.  These functions provide support to get at that data.  A
following patch will export this data.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c   |  655 +++++++++++++++++++++++-
 drivers/net/ethernet/intel/igb/e1000_82575.h   |   31 ++
 drivers/net/ethernet/intel/igb/e1000_defines.h |   15 +-
 drivers/net/ethernet/intel/igb/e1000_hw.h      |   16 +
 drivers/net/ethernet/intel/igb/e1000_regs.h    |   15 +
 5 files changed, 730 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index e650839..9623833 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -2256,6 +2256,660 @@ out:
 	return ret_val;
 }
 
+/**
+ *  igb_set_i2c_bb - Enable I2C bit-bang
+ *  @hw: pointer to the HW structure
+ *
+ *  Enable I2C bit-bang interface
+ *
+ **/
+s32 igb_set_i2c_bb(struct e1000_hw *hw)
+{
+	s32 ret_val = E1000_SUCCESS;
+	u32 ctrl_ext, i2cparams;
+
+	ctrl_ext = rd32(E1000_CTRL_EXT);
+	ctrl_ext |= E1000_CTRL_I2C_ENA;
+	wr32(E1000_CTRL_EXT, ctrl_ext);
+	wrfl();
+
+	i2cparams = rd32(E1000_I2CPARAMS);
+	i2cparams |= E1000_I2CBB_EN;
+	i2cparams |= E1000_I2C_DATA_OE_N;
+	i2cparams |= E1000_I2C_CLK_OE_N;
+	wr32(E1000_I2CPARAMS, i2cparams);
+	wrfl();
+
+	return ret_val;
+}
+
+/**
+ *  igb_get_i2c_data - Reads the I2C SDA data bit
+ *  @hw: pointer to hardware structure
+ *  @i2cctl: Current value of I2CCTL register
+ *
+ *  Returns the I2C data bit value
+ **/
+static bool igb_get_i2c_data(u32 *i2cctl)
+{
+	bool data;
+
+	if (*i2cctl & E1000_I2C_DATA_IN)
+		data = 1;
+	else
+		data = 0;
+
+	return data;
+}
+
+/**
+ *  igb_set_i2c_data - Sets the I2C data bit
+ *  @hw: pointer to hardware structure
+ *  @i2cctl: Current value of I2CCTL register
+ *  @data: I2C data value (0 or 1) to set
+ *
+ *  Sets the I2C data bit
+ **/
+static s32 igb_set_i2c_data(struct e1000_hw *hw, u32 *i2cctl, bool data)
+{
+	s32 status = E1000_SUCCESS;
+
+	if (data)
+		*i2cctl |= E1000_I2C_DATA_OUT;
+	else
+		*i2cctl &= ~E1000_I2C_DATA_OUT;
+
+	*i2cctl &= ~E1000_I2C_DATA_OE_N;
+	*i2cctl |= E1000_I2C_CLK_OE_N;
+	wr32(E1000_I2CPARAMS, *i2cctl);
+	wrfl();
+
+	/* Data rise/fall (1000ns/300ns) and set-up time (250ns) */
+	udelay(E1000_I2C_T_RISE + E1000_I2C_T_FALL + E1000_I2C_T_SU_DATA);
+
+	*i2cctl = rd32(E1000_I2CPARAMS);
+	if (data != igb_get_i2c_data(i2cctl)) {
+		status = E1000_ERR_I2C;
+		hw_dbg("Error - I2C data was not set to %X.\n", data);
+	}
+
+	return status;
+}
+
+/**
+ *  igb_raise_i2c_clk - Raises the I2C SCL clock
+ *  @hw: pointer to hardware structure
+ *  @i2cctl: Current value of I2CCTL register
+ *
+ *  Raises the I2C clock line '0'->'1'
+ **/
+static void igb_raise_i2c_clk(struct e1000_hw *hw, u32 *i2cctl)
+{
+	*i2cctl |= E1000_I2C_CLK_OUT;
+	*i2cctl &= ~E1000_I2C_CLK_OE_N;
+	wr32(E1000_I2CPARAMS, *i2cctl);
+	wrfl();
+
+	/* SCL rise time (1000ns) */
+	udelay(E1000_I2C_T_RISE);
+}
+
+/**
+ *  igb_lower_i2c_clk - Lowers the I2C SCL clock
+ *  @hw: pointer to hardware structure
+ *  @i2cctl: Current value of I2CCTL register
+ *
+ *  Lowers the I2C clock line '1'->'0'
+ **/
+static void igb_lower_i2c_clk(struct e1000_hw *hw, u32 *i2cctl)
+{
+
+	*i2cctl &= ~E1000_I2C_CLK_OUT;
+	*i2cctl &= ~E1000_I2C_CLK_OE_N;
+	wr32(E1000_I2CPARAMS, *i2cctl);
+	wrfl();
+
+	/* SCL fall time (300ns) */
+	udelay(E1000_I2C_T_FALL);
+}
+
+/**
+ *  igb_clock_out_i2c_bit - Clocks in/out one bit via I2C data/clock
+ *  @hw: pointer to hardware structure
+ *  @data: data value to write
+ *
+ *  Clocks out one bit via I2C data/clock
+ **/
+static s32 igb_clock_out_i2c_bit(struct e1000_hw *hw, bool data)
+{
+	s32 status;
+	u32 i2cctl = rd32(E1000_I2CPARAMS);
+
+	status = igb_set_i2c_data(hw, &i2cctl, data);
+	if (status == E1000_SUCCESS) {
+		igb_raise_i2c_clk(hw, &i2cctl);
+
+		/* Minimum high period of clock is 4us */
+		udelay(E1000_I2C_T_HIGH);
+
+		igb_lower_i2c_clk(hw, &i2cctl);
+
+		/* Minimum low period of clock is 4.7 us.
+		 * This also takes care of the data hold time.
+		 */
+		udelay(E1000_I2C_T_LOW);
+	} else {
+		status = E1000_ERR_I2C;
+		hw_dbg("I2C data was not set to %X\n", data);
+	}
+
+	return status;
+}
+
+/**
+ *  igb_clock_out_i2c_byte - Clocks out one byte via I2C
+ *  @hw: pointer to hardware structure
+ *  @data: data byte clocked out
+ *
+ *  Clocks out one byte data via I2C data/clock
+ **/
+static s32 igb_clock_out_i2c_byte(struct e1000_hw *hw, u8 data)
+{
+	s32 status = E1000_SUCCESS;
+	s32 i;
+	u32 i2cctl;
+	bool bit = 0;
+
+	for (i = 7; i >= 0; i--) {
+		bit = (data >> i) & 0x1;
+		status = igb_clock_out_i2c_bit(hw, bit);
+
+		if (status != E1000_SUCCESS)
+			break;
+	}
+
+	/* Release SDA line (set high) */
+	i2cctl = rd32(E1000_I2CPARAMS);
+
+	i2cctl |= E1000_I2C_DATA_OE_N;
+	wr32(E1000_I2CPARAMS, i2cctl);
+	wrfl();
+
+	return status;
+}
+
+/**
+ *  igb_get_i2c_ack - Polls for I2C ACK
+ *  @hw: pointer to hardware structure
+ *
+ *  Clocks in/out one bit via I2C data/clock
+ **/
+static s32 igb_get_i2c_ack(struct e1000_hw *hw)
+{
+	s32 status = E1000_SUCCESS;
+	u32 i = 0;
+	u32 i2cctl = rd32(E1000_I2CPARAMS);
+	u32 timeout = 10;
+	bool ack = true;
+
+	igb_raise_i2c_clk(hw, &i2cctl);
+
+	/* Minimum high period of clock is 4us */
+	udelay(E1000_I2C_T_HIGH);
+
+	/* Wait until SCL returns high */
+	for (i = 0; i < timeout; i++) {
+		udelay(1);
+		i2cctl = rd32(E1000_I2CPARAMS);
+		if (i2cctl & E1000_I2C_CLK_IN)
+			break;
+	}
+	if (!(i2cctl & E1000_I2C_CLK_IN))
+		return E1000_ERR_I2C;
+
+	ack = igb_get_i2c_data(&i2cctl);
+	if (ack) {
+		hw_dbg("I2C ack was not received.\n");
+		status = E1000_ERR_I2C;
+	}
+
+	igb_lower_i2c_clk(hw, &i2cctl);
+
+	/* Minimum low period of clock is 4.7 us */
+	udelay(E1000_I2C_T_LOW);
+
+	return status;
+}
+
+/**
+ *  igb_clock_in_i2c_bit - Clocks in one bit via I2C data/clock
+ *  @hw: pointer to hardware structure
+ *  @data: read data value
+ *
+ *  Clocks in one bit via I2C data/clock
+ **/
+static s32 igb_clock_in_i2c_bit(struct e1000_hw *hw, bool *data)
+{
+	u32 i2cctl = rd32(E1000_I2CPARAMS);
+
+	igb_raise_i2c_clk(hw, &i2cctl);
+
+	/* Minimum high period of clock is 4us */
+	udelay(E1000_I2C_T_HIGH);
+
+	i2cctl = rd32(E1000_I2CPARAMS);
+	*data = igb_get_i2c_data(&i2cctl);
+
+	igb_lower_i2c_clk(hw, &i2cctl);
+
+	/* Minimum low period of clock is 4.7 us */
+	udelay(E1000_I2C_T_LOW);
+
+	return E1000_SUCCESS;
+}
+
+/**
+ *  igb_clock_in_i2c_byte - Clocks in one byte via I2C
+ *  @hw: pointer to hardware structure
+ *  @data: data byte to clock in
+ *
+ *  Clocks in one byte data via I2C data/clock
+ **/
+static s32 igb_clock_in_i2c_byte(struct e1000_hw *hw, u8 *data)
+{
+	s32 i;
+	bool bit = 0;
+
+	*data = 0;
+	for (i = 7; i >= 0; i--) {
+		igb_clock_in_i2c_bit(hw, &bit);
+		*data |= bit << i;
+	}
+
+	return E1000_SUCCESS;
+}
+
+/**
+ *  igb_i2c_stop - Sets I2C stop condition
+ *  @hw: pointer to hardware structure
+ *
+ *  Sets I2C stop condition (Low -> High on SDA while SCL is High)
+ **/
+static void igb_i2c_stop(struct e1000_hw *hw)
+{
+	u32 i2cctl = rd32(E1000_I2CPARAMS);
+
+	/* Stop condition must begin with data low and clock high */
+	igb_set_i2c_data(hw, &i2cctl, 0);
+	igb_raise_i2c_clk(hw, &i2cctl);
+
+	/* Setup time for stop condition (4us) */
+	udelay(E1000_I2C_T_SU_STO);
+
+	igb_set_i2c_data(hw, &i2cctl, 1);
+
+	/* bus free time between stop and start (4.7us)*/
+	udelay(E1000_I2C_T_BUF);
+}
+
+/**
+ *  igb_i2c_start - Sets I2C start condition
+ *  @hw: pointer to hardware structure
+ *
+ *  Sets I2C start condition (High -> Low on SDA while SCL is High)
+ **/
+static void igb_i2c_start(struct e1000_hw *hw)
+{
+	u32 i2cctl = rd32(E1000_I2CPARAMS);
+
+	/* Start condition must begin with data and clock high */
+	igb_set_i2c_data(hw, &i2cctl, 1);
+	igb_raise_i2c_clk(hw, &i2cctl);
+
+	/* Setup time for start condition (4.7us) */
+	udelay(E1000_I2C_T_SU_STA);
+
+	igb_set_i2c_data(hw, &i2cctl, 0);
+
+	/* Hold time for start condition (4us) */
+	udelay(E1000_I2C_T_HD_STA);
+
+	igb_lower_i2c_clk(hw, &i2cctl);
+
+	/* Minimum low period of clock is 4.7 us */
+	udelay(E1000_I2C_T_LOW);
+
+}
+
+/**
+ *  igb_read_i2c_byte_generic - Reads 8 bit word over I2C
+ *  @hw: pointer to hardware structure
+ *  @byte_offset: byte offset to read
+ *  @dev_addr: device address
+ *  @data: value read
+ *
+ *  Performs byte read operation over I2C interface at
+ *  a specified device address.
+ **/
+s32 igb_read_i2c_byte_generic(struct e1000_hw *hw, u8 byte_offset,
+				u8 dev_addr, u8 *data)
+{
+	s32 status = E1000_SUCCESS;
+	u32 max_retry = 10;
+	u32 retry = 1;
+	u16 swfw_mask = 0;
+
+	bool nack = true;
+
+	swfw_mask = E1000_SWFW_PHY0_SM;
+
+	do {
+		if (hw->mac.ops.acquire_swfw_sync(hw, swfw_mask)
+		    != E1000_SUCCESS) {
+			status = E1000_ERR_SWFW_SYNC;
+			goto read_byte_out;
+		}
+
+		igb_i2c_start(hw);
+
+		/* Device Address and write indication */
+		status = igb_clock_out_i2c_byte(hw, dev_addr);
+		if (status != E1000_SUCCESS)
+			goto fail;
+
+		status = igb_get_i2c_ack(hw);
+		if (status != E1000_SUCCESS)
+			goto fail;
+
+		status = igb_clock_out_i2c_byte(hw, byte_offset);
+		if (status != E1000_SUCCESS)
+			goto fail;
+
+		status = igb_get_i2c_ack(hw);
+		if (status != E1000_SUCCESS)
+			goto fail;
+
+		igb_i2c_start(hw);
+
+		/* Device Address and read indication */
+		status = igb_clock_out_i2c_byte(hw, (dev_addr | 0x1));
+		if (status != E1000_SUCCESS)
+			goto fail;
+
+		status = igb_get_i2c_ack(hw);
+		if (status != E1000_SUCCESS)
+			goto fail;
+
+		status = igb_clock_in_i2c_byte(hw, data);
+		if (status != E1000_SUCCESS)
+			goto fail;
+
+		status = igb_clock_out_i2c_bit(hw, nack);
+		if (status != E1000_SUCCESS)
+			goto fail;
+
+		igb_i2c_stop(hw);
+		break;
+
+fail:
+		hw->mac.ops.release_swfw_sync(hw, swfw_mask);
+		mdelay(100);
+		igb_i2c_bus_clear(hw);
+		retry++;
+		if (retry < max_retry)
+			hw_dbg("I2C byte read error - Retrying.\n");
+		else
+			hw_dbg("I2C byte read error.\n");
+
+	} while (retry < max_retry);
+
+	hw->mac.ops.release_swfw_sync(hw, swfw_mask);
+
+read_byte_out:
+
+	return status;
+}
+
+/**
+ *  igb_write_i2c_byte_generic - Writes 8 bit word over I2C
+ *  @hw: pointer to hardware structure
+ *  @byte_offset: byte offset to write
+ *  @dev_addr: device address
+ *  @data: value to write
+ *
+ *  Performs byte write operation over I2C interface at
+ *  a specified device address.
+ **/
+s32 igb_write_i2c_byte_generic(struct e1000_hw *hw, u8 byte_offset,
+				 u8 dev_addr, u8 data)
+{
+	s32 status = E1000_SUCCESS;
+	u32 max_retry = 1;
+	u32 retry = 0;
+	u16 swfw_mask = 0;
+
+	swfw_mask = E1000_SWFW_PHY0_SM;
+
+	if (hw->mac.ops.acquire_swfw_sync(hw, swfw_mask) != E1000_SUCCESS) {
+		status = E1000_ERR_SWFW_SYNC;
+		goto write_byte_out;
+	}
+
+	do {
+		igb_i2c_start(hw);
+
+		status = igb_clock_out_i2c_byte(hw, dev_addr);
+		if (status != E1000_SUCCESS)
+			goto fail;
+
+		status = igb_get_i2c_ack(hw);
+		if (status != E1000_SUCCESS)
+			goto fail;
+
+		status = igb_clock_out_i2c_byte(hw, byte_offset);
+		if (status != E1000_SUCCESS)
+			goto fail;
+
+		status = igb_get_i2c_ack(hw);
+		if (status != E1000_SUCCESS)
+			goto fail;
+
+		status = igb_clock_out_i2c_byte(hw, data);
+		if (status != E1000_SUCCESS)
+			goto fail;
+
+		status = igb_get_i2c_ack(hw);
+		if (status != E1000_SUCCESS)
+			goto fail;
+
+		igb_i2c_stop(hw);
+		break;
+
+fail:
+		igb_i2c_bus_clear(hw);
+		retry++;
+		if (retry < max_retry)
+			hw_dbg("I2C byte write error - Retrying.\n");
+		else
+			hw_dbg("I2C byte write error.\n");
+	} while (retry < max_retry);
+
+	hw->mac.ops.release_swfw_sync(hw, swfw_mask);
+
+write_byte_out:
+
+	return status;
+}
+
+/**
+ *  igb_i2c_bus_clear - Clears the I2C bus
+ *  @hw: pointer to hardware structure
+ *
+ *  Clears the I2C bus by sending nine clock pulses.
+ *  Used when data line is stuck low.
+ **/
+void igb_i2c_bus_clear(struct e1000_hw *hw)
+{
+	u32 i2cctl = rd32(E1000_I2CPARAMS);
+	u32 i;
+
+	igb_i2c_start(hw);
+
+	igb_set_i2c_data(hw, &i2cctl, 1);
+
+	for (i = 0; i < 9; i++) {
+		igb_raise_i2c_clk(hw, &i2cctl);
+
+		/* Min high period of clock is 4us */
+		udelay(E1000_I2C_T_HIGH);
+
+		igb_lower_i2c_clk(hw, &i2cctl);
+
+		/* Min low period of clock is 4.7us*/
+		udelay(E1000_I2C_T_LOW);
+	}
+
+	igb_i2c_start(hw);
+
+	/* Put the i2c bus back to default state */
+	igb_i2c_stop(hw);
+}
+
+static const u8 e1000_emc_temp_data[4] = {
+	E1000_EMC_INTERNAL_DATA,
+	E1000_EMC_DIODE1_DATA,
+	E1000_EMC_DIODE2_DATA,
+	E1000_EMC_DIODE3_DATA
+};
+static const u8 e1000_emc_therm_limit[4] = {
+	E1000_EMC_INTERNAL_THERM_LIMIT,
+	E1000_EMC_DIODE1_THERM_LIMIT,
+	E1000_EMC_DIODE2_THERM_LIMIT,
+	E1000_EMC_DIODE3_THERM_LIMIT
+};
+
+/**
+ *  igb_get_thermal_sensor_data_generic - Gathers thermal sensor data
+ *  @hw: pointer to hardware structure
+ *
+ *  Updates the temperatures in mac.thermal_sensor_data
+ **/
+s32 igb_get_thermal_sensor_data_generic(struct e1000_hw *hw)
+{
+	s32 status = E1000_SUCCESS;
+	u16 ets_offset;
+	u16 ets_cfg;
+	u16 ets_sensor;
+	u8  num_sensors;
+	u8  sensor_index;
+	u8  sensor_location;
+	u8  i;
+	struct e1000_thermal_sensor_data *data = &hw->mac.thermal_sensor_data;
+
+	if ((hw->mac.type != e1000_i350) || (hw->bus.func != 0))
+		return E1000_NOT_IMPLEMENTED;
+
+	data->sensor[0].temp = (rd32(E1000_THMJT) & 0xFF);
+
+	/* Return the internal sensor only if ETS is unsupported */
+	hw->nvm.ops.read(hw, NVM_ETS_CFG, 1, &ets_offset);
+	if ((ets_offset == 0x0000) || (ets_offset == 0xFFFF))
+		return status;
+
+	hw->nvm.ops.read(hw, ets_offset, 1, &ets_cfg);
+	if (((ets_cfg & NVM_ETS_TYPE_MASK) >> NVM_ETS_TYPE_SHIFT)
+	    != NVM_ETS_TYPE_EMC)
+		return E1000_NOT_IMPLEMENTED;
+
+	num_sensors = (ets_cfg & NVM_ETS_NUM_SENSORS_MASK);
+	if (num_sensors > E1000_MAX_SENSORS)
+		num_sensors = E1000_MAX_SENSORS;
+
+	for (i = 1; i < num_sensors; i++) {
+		hw->nvm.ops.read(hw, (ets_offset + i), 1, &ets_sensor);
+		sensor_index = ((ets_sensor & NVM_ETS_DATA_INDEX_MASK) >>
+				NVM_ETS_DATA_INDEX_SHIFT);
+		sensor_location = ((ets_sensor & NVM_ETS_DATA_LOC_MASK) >>
+				   NVM_ETS_DATA_LOC_SHIFT);
+
+		if (sensor_location != 0)
+			hw->phy.ops.read_i2c_byte(hw,
+					e1000_emc_temp_data[sensor_index],
+					E1000_I2C_THERMAL_SENSOR_ADDR,
+					&data->sensor[i].temp);
+	}
+	return status;
+}
+
+/**
+ *  igb_init_thermal_sensor_thresh_generic - Sets thermal sensor thresholds
+ *  @hw: pointer to hardware structure
+ *
+ *  Sets the thermal sensor thresholds according to the NVM map
+ *  and save off the threshold and location values into mac.thermal_sensor_data
+ **/
+s32 igb_init_thermal_sensor_thresh_generic(struct e1000_hw *hw)
+{
+	s32 status = E1000_SUCCESS;
+	u16 ets_offset;
+	u16 ets_cfg;
+	u16 ets_sensor;
+	u8  low_thresh_delta;
+	u8  num_sensors;
+	u8  sensor_index;
+	u8  sensor_location;
+	u8  therm_limit;
+	u8  i;
+	struct e1000_thermal_sensor_data *data = &hw->mac.thermal_sensor_data;
+
+	if ((hw->mac.type != e1000_i350) || (hw->bus.func != 0))
+		return E1000_NOT_IMPLEMENTED;
+
+	memset(data, 0, sizeof(struct e1000_thermal_sensor_data));
+
+	data->sensor[0].location = 0x1;
+	data->sensor[0].caution_thresh =
+		(rd32(E1000_THHIGHTC) & 0xFF);
+	data->sensor[0].max_op_thresh =
+		(rd32(E1000_THLOWTC) & 0xFF);
+
+	/* Return the internal sensor only if ETS is unsupported */
+	hw->nvm.ops.read(hw, NVM_ETS_CFG, 1, &ets_offset);
+	if ((ets_offset == 0x0000) || (ets_offset == 0xFFFF))
+		return status;
+
+	hw->nvm.ops.read(hw, ets_offset, 1, &ets_cfg);
+	if (((ets_cfg & NVM_ETS_TYPE_MASK) >> NVM_ETS_TYPE_SHIFT)
+	    != NVM_ETS_TYPE_EMC)
+		return E1000_NOT_IMPLEMENTED;
+
+	low_thresh_delta = ((ets_cfg & NVM_ETS_LTHRES_DELTA_MASK) >>
+			    NVM_ETS_LTHRES_DELTA_SHIFT);
+	num_sensors = (ets_cfg & NVM_ETS_NUM_SENSORS_MASK);
+
+	for (i = 1; i <= num_sensors; i++) {
+		hw->nvm.ops.read(hw, (ets_offset + i), 1, &ets_sensor);
+		sensor_index = ((ets_sensor & NVM_ETS_DATA_INDEX_MASK) >>
+				NVM_ETS_DATA_INDEX_SHIFT);
+		sensor_location = ((ets_sensor & NVM_ETS_DATA_LOC_MASK) >>
+				   NVM_ETS_DATA_LOC_SHIFT);
+		therm_limit = ets_sensor & NVM_ETS_DATA_HTHRESH_MASK;
+
+		hw->phy.ops.write_i2c_byte(hw,
+			e1000_emc_therm_limit[sensor_index],
+			E1000_I2C_THERMAL_SENSOR_ADDR,
+			therm_limit);
+
+		if ((i < E1000_MAX_SENSORS) && (sensor_location != 0)) {
+			data->sensor[i].location = sensor_location;
+			data->sensor[i].caution_thresh = therm_limit;
+			data->sensor[i].max_op_thresh = therm_limit -
+							low_thresh_delta;
+		}
+	}
+	return status;
+}
+
 static struct e1000_mac_operations e1000_mac_ops_82575 = {
 	.init_hw              = igb_init_hw_82575,
 	.check_for_link       = igb_check_for_link_82575,
@@ -2283,4 +2937,3 @@ const struct e1000_info e1000_82575_info = {
 	.phy_ops = &e1000_phy_ops_82575,
 	.nvm_ops = &e1000_nvm_ops_82575,
 };
-
diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.h b/drivers/net/ethernet/intel/igb/e1000_82575.h
index e85c453..2e6a441 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.h
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.h
@@ -258,4 +258,35 @@ void igb_vmdq_set_replication_pf(struct e1000_hw *, bool);
 u16 igb_rxpbs_adjust_82580(u32 data);
 s32 igb_set_eee_i350(struct e1000_hw *);
 
+#define E1000_I2C_THERMAL_SENSOR_ADDR	0xF8
+#define E1000_EMC_INTERNAL_DATA		0x00
+#define E1000_EMC_INTERNAL_THERM_LIMIT	0x20
+#define E1000_EMC_DIODE1_DATA		0x01
+#define E1000_EMC_DIODE1_THERM_LIMIT	0x19
+#define E1000_EMC_DIODE2_DATA		0x23
+#define E1000_EMC_DIODE2_THERM_LIMIT	0x1A
+#define E1000_EMC_DIODE3_DATA		0x2A
+#define E1000_EMC_DIODE3_THERM_LIMIT	0x30
+
+s32 igb_get_thermal_sensor_data_generic(struct e1000_hw *hw);
+s32 igb_init_thermal_sensor_thresh_generic(struct e1000_hw *hw);
+
+/* I2C SDA and SCL timing parameters for standard mode */
+#define E1000_I2C_T_HD_STA	4
+#define E1000_I2C_T_LOW		5
+#define E1000_I2C_T_HIGH	4
+#define E1000_I2C_T_SU_STA	5
+#define E1000_I2C_T_HD_DATA	5
+#define E1000_I2C_T_SU_DATA	1
+#define E1000_I2C_T_RISE	1
+#define E1000_I2C_T_FALL	1
+#define E1000_I2C_T_SU_STO	4
+#define E1000_I2C_T_BUF		5
+
+s32 igb_set_i2c_bb(struct e1000_hw *hw);
+s32 igb_read_i2c_byte_generic(struct e1000_hw *hw, u8 byte_offset,
+				u8 dev_addr, u8 *data);
+s32 igb_write_i2c_byte_generic(struct e1000_hw *hw, u8 byte_offset,
+				 u8 dev_addr, u8 data);
+void igb_i2c_bus_clear(struct e1000_hw *hw);
 #endif
diff --git a/drivers/net/ethernet/intel/igb/e1000_defines.h b/drivers/net/ethernet/intel/igb/e1000_defines.h
index ec7e4fe..fed5746 100644
--- a/drivers/net/ethernet/intel/igb/e1000_defines.h
+++ b/drivers/net/ethernet/intel/igb/e1000_defines.h
@@ -460,7 +460,8 @@
 #define E1000_ERR_INVALID_ARGUMENT  16
 #define E1000_ERR_NO_SPACE          17
 #define E1000_ERR_NVM_PBA_SECTION   18
-#define E1000_ERR_INVM_VALUE_NOT_FOUND	19
+#define E1000_ERR_INVM_VALUE_NOT_FOUND 19
+#define E1000_ERR_I2C               20
 
 /* Loop limit on how long we wait for auto-negotiation to complete */
 #define COPPER_LINK_UP_LIMIT              10
@@ -645,6 +646,18 @@
 #define NVM_LED_1_CFG              0x001C
 #define NVM_LED_0_2_CFG            0x001F
 
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
index c2a51dc..837a274 100644
--- a/drivers/net/ethernet/intel/igb/e1000_hw.h
+++ b/drivers/net/ethernet/intel/igb/e1000_hw.h
@@ -342,6 +342,8 @@ struct e1000_phy_operations {
 	s32  (*set_d0_lplu_state)(struct e1000_hw *, bool);
 	s32  (*set_d3_lplu_state)(struct e1000_hw *, bool);
 	s32  (*write_reg)(struct e1000_hw *, u32, u16);
+	s32 (*read_i2c_byte)(struct e1000_hw *, u8, u8, u8 *);
+	s32 (*write_i2c_byte)(struct e1000_hw *, u8, u8, u8);
 };
 
 struct e1000_nvm_operations {
@@ -354,6 +356,19 @@ struct e1000_nvm_operations {
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
@@ -399,6 +414,7 @@ struct e1000_mac_info {
 	bool report_tx_early;
 	bool serdes_has_link;
 	bool tx_pkt_filtering;
+	struct e1000_thermal_sensor_data thermal_sensor_data;
 };
 
 struct e1000_phy_info {
diff --git a/drivers/net/ethernet/intel/igb/e1000_regs.h b/drivers/net/ethernet/intel/igb/e1000_regs.h
index 35d1e4f..b446079 100644
--- a/drivers/net/ethernet/intel/igb/e1000_regs.h
+++ b/drivers/net/ethernet/intel/igb/e1000_regs.h
@@ -75,6 +75,15 @@
 #define E1000_FCRTL    0x02160  /* Flow Control Receive Threshold Low - RW */
 #define E1000_FCRTH    0x02168  /* Flow Control Receive Threshold High - RW */
 #define E1000_FCRTV    0x02460  /* Flow Control Refresh Timer Value - RW */
+#define E1000_I2CPARAMS        0x0102C /* SFPI2C Parameters Register - RW */
+#define E1000_I2CBB_EN      0x00000100  /* I2C - Bit Bang Enable */
+#define E1000_I2C_CLK_OUT   0x00000200  /* I2C- Clock */
+#define E1000_I2C_DATA_OUT  0x00000400  /* I2C- Data Out */
+#define E1000_I2C_DATA_OE_N 0x00000800  /* I2C- Data Output Enable */
+#define E1000_I2C_DATA_IN   0x00001000  /* I2C- Data In */
+#define E1000_I2C_CLK_OE_N  0x00002000  /* I2C- Clock Output Enable */
+#define E1000_I2C_CLK_IN    0x00004000  /* I2C- Clock In */
+#define E1000_I2C_CLK_STRETCH_DIS  0x00008000 /* I2C- Dis Clk Stretching */
 
 /* IEEE 1588 TIMESYNCH */
 #define E1000_TSYNCRXCTL 0x0B620 /* Rx Time Sync Control register - RW */
@@ -121,6 +130,12 @@
 
 /* Split and Replication RX Control - RW */
 #define E1000_RXPBS    0x02404  /* Rx Packet Buffer Size - RW */
+/* Thermal sensor configuration and status registers */
+#define E1000_THMJT	0x08100 /* Junction Temperature */
+#define E1000_THLOWTC	0x08104 /* Low Threshold Control */
+#define E1000_THMIDTC	0x08108 /* Mid Threshold Control */
+#define E1000_THHIGHTC	0x0810C /* High Threshold Control */
+#define E1000_THSTAT	0x08110 /* Thermal Sensor Status */
 /*
  * Convenience macros
  *
-- 
1.7.10.2
