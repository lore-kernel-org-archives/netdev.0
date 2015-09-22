From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 17/17] ixgbe: Enable bit-banging mode on X550
Date: Tue, 22 Sep 2015 16:54:36 -0700
Message-ID: <1442966076-14359-18-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442966076-14359-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:50474 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935083AbbIVXyp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2015 19:54:45 -0400
In-Reply-To: <1442966076-14359-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Set the bit banging mode in the hardware when performing bit banging
I2C operations on X550. Also control the output enable on both the
clock and data lines.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c | 65 +++++++++++++++++++++++++++-
 1 file changed, 63 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index 2b238ca..315f059 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -1952,11 +1952,14 @@ s32 ixgbe_write_i2c_byte_generic_unlocked(struct ixgbe_hw *hw, u8 byte_offset,
  *  @hw: pointer to hardware structure
  *
  *  Sets I2C start condition (High -> Low on SDA while SCL is High)
+ *  Set bit-bang mode on X550 hardware.
  **/
 static void ixgbe_i2c_start(struct ixgbe_hw *hw)
 {
 	u32 i2cctl = IXGBE_READ_REG(hw, IXGBE_I2CCTL(hw));
 
+	i2cctl |= IXGBE_I2C_BB_EN(hw);
+
 	/* Start condition must begin with data and clock high */
 	ixgbe_set_i2c_data(hw, &i2cctl, 1);
 	ixgbe_raise_i2c_clk(hw, &i2cctl);
@@ -1981,10 +1984,15 @@ static void ixgbe_i2c_start(struct ixgbe_hw *hw)
  *  @hw: pointer to hardware structure
  *
  *  Sets I2C stop condition (Low -> High on SDA while SCL is High)
+ *  Disables bit-bang mode and negates data output enable on X550
+ *  hardware.
  **/
 static void ixgbe_i2c_stop(struct ixgbe_hw *hw)
 {
 	u32 i2cctl = IXGBE_READ_REG(hw, IXGBE_I2CCTL(hw));
+	u32 data_oe_bit = IXGBE_I2C_DATA_OE_N_EN(hw);
+	u32 clk_oe_bit = IXGBE_I2C_CLK_OE_N_EN(hw);
+	u32 bb_en_bit = IXGBE_I2C_BB_EN(hw);
 
 	/* Stop condition must begin with data low and clock high */
 	ixgbe_set_i2c_data(hw, &i2cctl, 0);
@@ -1997,6 +2005,13 @@ static void ixgbe_i2c_stop(struct ixgbe_hw *hw)
 
 	/* bus free time between stop and start (4.7us)*/
 	udelay(IXGBE_I2C_T_BUF);
+
+	if (bb_en_bit || data_oe_bit || clk_oe_bit) {
+		i2cctl &= ~bb_en_bit;
+		i2cctl |= data_oe_bit | clk_oe_bit;
+		IXGBE_WRITE_REG(hw, IXGBE_I2CCTL(hw), i2cctl);
+		IXGBE_WRITE_FLUSH(hw);
+	}
 }
 
 /**
@@ -2044,6 +2059,7 @@ static s32 ixgbe_clock_out_i2c_byte(struct ixgbe_hw *hw, u8 data)
 	/* Release SDA line (set high) */
 	i2cctl = IXGBE_READ_REG(hw, IXGBE_I2CCTL(hw));
 	i2cctl |= IXGBE_I2C_DATA_OUT(hw);
+	i2cctl |= IXGBE_I2C_DATA_OE_N_EN(hw);
 	IXGBE_WRITE_REG(hw, IXGBE_I2CCTL(hw), i2cctl);
 	IXGBE_WRITE_FLUSH(hw);
 
@@ -2058,15 +2074,21 @@ static s32 ixgbe_clock_out_i2c_byte(struct ixgbe_hw *hw, u8 data)
  **/
 static s32 ixgbe_get_i2c_ack(struct ixgbe_hw *hw)
 {
+	u32 data_oe_bit = IXGBE_I2C_DATA_OE_N_EN(hw);
 	s32 status = 0;
 	u32 i = 0;
 	u32 i2cctl = IXGBE_READ_REG(hw, IXGBE_I2CCTL(hw));
 	u32 timeout = 10;
 	bool ack = true;
 
+	if (data_oe_bit) {
+		i2cctl |= IXGBE_I2C_DATA_OUT(hw);
+		i2cctl |= data_oe_bit;
+		IXGBE_WRITE_REG(hw, IXGBE_I2CCTL(hw), i2cctl);
+		IXGBE_WRITE_FLUSH(hw);
+	}
 	ixgbe_raise_i2c_clk(hw, &i2cctl);
 
-
 	/* Minimum high period of clock is 4us */
 	udelay(IXGBE_I2C_T_HIGH);
 
@@ -2104,7 +2126,14 @@ static s32 ixgbe_get_i2c_ack(struct ixgbe_hw *hw)
 static s32 ixgbe_clock_in_i2c_bit(struct ixgbe_hw *hw, bool *data)
 {
 	u32 i2cctl = IXGBE_READ_REG(hw, IXGBE_I2CCTL(hw));
+	u32 data_oe_bit = IXGBE_I2C_DATA_OE_N_EN(hw);
 
+	if (data_oe_bit) {
+		i2cctl |= IXGBE_I2C_DATA_OUT(hw);
+		i2cctl |= data_oe_bit;
+		IXGBE_WRITE_REG(hw, IXGBE_I2CCTL(hw), i2cctl);
+		IXGBE_WRITE_FLUSH(hw);
+	}
 	ixgbe_raise_i2c_clk(hw, &i2cctl);
 
 	/* Minimum high period of clock is 4us */
@@ -2159,13 +2188,20 @@ static s32 ixgbe_clock_out_i2c_bit(struct ixgbe_hw *hw, bool data)
  *  @i2cctl: Current value of I2CCTL register
  *
  *  Raises the I2C clock line '0'->'1'
+ *  Negates the I2C clock output enable on X550 hardware.
  **/
 static void ixgbe_raise_i2c_clk(struct ixgbe_hw *hw, u32 *i2cctl)
 {
+	u32 clk_oe_bit = IXGBE_I2C_CLK_OE_N_EN(hw);
 	u32 i = 0;
 	u32 timeout = IXGBE_I2C_CLOCK_STRETCHING_TIMEOUT;
 	u32 i2cctl_r = 0;
 
+	if (clk_oe_bit) {
+		*i2cctl |= clk_oe_bit;
+		IXGBE_WRITE_REG(hw, IXGBE_I2CCTL(hw), *i2cctl);
+	}
+
 	for (i = 0; i < timeout; i++) {
 		*i2cctl |= IXGBE_I2C_CLK_OUT(hw);
 		IXGBE_WRITE_REG(hw, IXGBE_I2CCTL(hw), *i2cctl);
@@ -2185,11 +2221,13 @@ static void ixgbe_raise_i2c_clk(struct ixgbe_hw *hw, u32 *i2cctl)
  *  @i2cctl: Current value of I2CCTL register
  *
  *  Lowers the I2C clock line '1'->'0'
+ *  Asserts the I2C clock output enable on X550 hardware.
  **/
 static void ixgbe_lower_i2c_clk(struct ixgbe_hw *hw, u32 *i2cctl)
 {
 
 	*i2cctl &= ~IXGBE_I2C_CLK_OUT(hw);
+	*i2cctl &= ~IXGBE_I2C_CLK_OE_N_EN(hw);
 
 	IXGBE_WRITE_REG(hw, IXGBE_I2CCTL(hw), *i2cctl);
 	IXGBE_WRITE_FLUSH(hw);
@@ -2205,13 +2243,17 @@ static void ixgbe_lower_i2c_clk(struct ixgbe_hw *hw, u32 *i2cctl)
  *  @data: I2C data value (0 or 1) to set
  *
  *  Sets the I2C data bit
+ *  Asserts the I2C data output enable on X550 hardware.
  **/
 static s32 ixgbe_set_i2c_data(struct ixgbe_hw *hw, u32 *i2cctl, bool data)
 {
+	u32 data_oe_bit = IXGBE_I2C_DATA_OE_N_EN(hw);
+
 	if (data)
 		*i2cctl |= IXGBE_I2C_DATA_OUT(hw);
 	else
 		*i2cctl &= ~IXGBE_I2C_DATA_OUT(hw);
+	*i2cctl &= ~data_oe_bit;
 
 	IXGBE_WRITE_REG(hw, IXGBE_I2CCTL(hw), *i2cctl);
 	IXGBE_WRITE_FLUSH(hw);
@@ -2219,6 +2261,14 @@ static s32 ixgbe_set_i2c_data(struct ixgbe_hw *hw, u32 *i2cctl, bool data)
 	/* Data rise/fall (1000ns/300ns) and set-up time (250ns) */
 	udelay(IXGBE_I2C_T_RISE + IXGBE_I2C_T_FALL + IXGBE_I2C_T_SU_DATA);
 
+	if (!data)	/* Can't verify data in this case */
+		return 0;
+	if (data_oe_bit) {
+		*i2cctl |= data_oe_bit;
+		IXGBE_WRITE_REG(hw, IXGBE_I2CCTL(hw), *i2cctl);
+		IXGBE_WRITE_FLUSH(hw);
+	}
+
 	/* Verify data was set correctly */
 	*i2cctl = IXGBE_READ_REG(hw, IXGBE_I2CCTL(hw));
 	if (data != ixgbe_get_i2c_data(hw, i2cctl)) {
@@ -2235,9 +2285,19 @@ static s32 ixgbe_set_i2c_data(struct ixgbe_hw *hw, u32 *i2cctl, bool data)
  *  @i2cctl: Current value of I2CCTL register
  *
  *  Returns the I2C data bit value
+ *  Negates the I2C data output enable on X550 hardware.
  **/
 static bool ixgbe_get_i2c_data(struct ixgbe_hw *hw, u32 *i2cctl)
 {
+	u32 data_oe_bit = IXGBE_I2C_DATA_OE_N_EN(hw);
+
+	if (data_oe_bit) {
+		*i2cctl |= data_oe_bit;
+		IXGBE_WRITE_REG(hw, IXGBE_I2CCTL(hw), *i2cctl);
+		IXGBE_WRITE_FLUSH(hw);
+		udelay(IXGBE_I2C_T_FALL);
+	}
+
 	if (*i2cctl & IXGBE_I2C_DATA_IN(hw))
 		return true;
 	return false;
@@ -2252,10 +2312,11 @@ static bool ixgbe_get_i2c_data(struct ixgbe_hw *hw, u32 *i2cctl)
  **/
 static void ixgbe_i2c_bus_clear(struct ixgbe_hw *hw)
 {
-	u32 i2cctl = IXGBE_READ_REG(hw, IXGBE_I2CCTL(hw));
+	u32 i2cctl;
 	u32 i;
 
 	ixgbe_i2c_start(hw);
+	i2cctl = IXGBE_READ_REG(hw, IXGBE_I2CCTL(hw));
 
 	ixgbe_set_i2c_data(hw, &i2cctl, 1);
 
-- 
2.4.3
