From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/11] ixgbe: remove return code for functions that always return 0
Date: Thu, 29 Sep 2011 22:24:44 -0700
Message-ID: <1317360291-5576-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317360291-5576-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:2856 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753808Ab1I3FY5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Sep 2011 01:24:57 -0400
In-Reply-To: <1317360291-5576-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Since ixgbe_raise_i2c_clk() can never return anything else than 0
this patch removes it's return value and all checks for it.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c |   30 +++++++------------------
 1 files changed, 9 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index cf3c227..9a56fd7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -39,7 +39,7 @@ static s32 ixgbe_clock_out_i2c_byte(struct ixgbe_hw *hw, u8 data);
 static s32 ixgbe_get_i2c_ack(struct ixgbe_hw *hw);
 static s32 ixgbe_clock_in_i2c_bit(struct ixgbe_hw *hw, bool *data);
 static s32 ixgbe_clock_out_i2c_bit(struct ixgbe_hw *hw, bool data);
-static s32 ixgbe_raise_i2c_clk(struct ixgbe_hw *hw, u32 *i2cctl);
+static void ixgbe_raise_i2c_clk(struct ixgbe_hw *hw, u32 *i2cctl);
 static void ixgbe_lower_i2c_clk(struct ixgbe_hw *hw, u32 *i2cctl);
 static s32 ixgbe_set_i2c_data(struct ixgbe_hw *hw, u32 *i2cctl, bool data);
 static bool ixgbe_get_i2c_data(u32 *i2cctl);
@@ -1420,19 +1420,15 @@ static void ixgbe_i2c_stop(struct ixgbe_hw *hw)
  **/
 static s32 ixgbe_clock_in_i2c_byte(struct ixgbe_hw *hw, u8 *data)
 {
-	s32 status = 0;
 	s32 i;
 	bool bit = 0;
 
 	for (i = 7; i >= 0; i--) {
-		status = ixgbe_clock_in_i2c_bit(hw, &bit);
+		ixgbe_clock_in_i2c_bit(hw, &bit);
 		*data |= bit << i;
-
-		if (status != 0)
-			break;
 	}
 
-	return status;
+	return 0;
 }
 
 /**
@@ -1473,16 +1469,14 @@ static s32 ixgbe_clock_out_i2c_byte(struct ixgbe_hw *hw, u8 data)
  **/
 static s32 ixgbe_get_i2c_ack(struct ixgbe_hw *hw)
 {
-	s32 status;
+	s32 status = 0;
 	u32 i = 0;
 	u32 i2cctl = IXGBE_READ_REG(hw, IXGBE_I2CCTL);
 	u32 timeout = 10;
 	bool ack = 1;
 
-	status = ixgbe_raise_i2c_clk(hw, &i2cctl);
+	ixgbe_raise_i2c_clk(hw, &i2cctl);
 
-	if (status != 0)
-		goto out;
 
 	/* Minimum high period of clock is 4us */
 	udelay(IXGBE_I2C_T_HIGH);
@@ -1508,7 +1502,6 @@ static s32 ixgbe_get_i2c_ack(struct ixgbe_hw *hw)
 	/* Minimum low period of clock is 4.7 us */
 	udelay(IXGBE_I2C_T_LOW);
 
-out:
 	return status;
 }
 
@@ -1521,10 +1514,9 @@ out:
  **/
 static s32 ixgbe_clock_in_i2c_bit(struct ixgbe_hw *hw, bool *data)
 {
-	s32 status;
 	u32 i2cctl = IXGBE_READ_REG(hw, IXGBE_I2CCTL);
 
-	status = ixgbe_raise_i2c_clk(hw, &i2cctl);
+	ixgbe_raise_i2c_clk(hw, &i2cctl);
 
 	/* Minimum high period of clock is 4us */
 	udelay(IXGBE_I2C_T_HIGH);
@@ -1537,7 +1529,7 @@ static s32 ixgbe_clock_in_i2c_bit(struct ixgbe_hw *hw, bool *data)
 	/* Minimum low period of clock is 4.7 us */
 	udelay(IXGBE_I2C_T_LOW);
 
-	return status;
+	return 0;
 }
 
 /**
@@ -1554,7 +1546,7 @@ static s32 ixgbe_clock_out_i2c_bit(struct ixgbe_hw *hw, bool data)
 
 	status = ixgbe_set_i2c_data(hw, &i2cctl, data);
 	if (status == 0) {
-		status = ixgbe_raise_i2c_clk(hw, &i2cctl);
+		ixgbe_raise_i2c_clk(hw, &i2cctl);
 
 		/* Minimum high period of clock is 4us */
 		udelay(IXGBE_I2C_T_HIGH);
@@ -1579,10 +1571,8 @@ static s32 ixgbe_clock_out_i2c_bit(struct ixgbe_hw *hw, bool data)
  *
  *  Raises the I2C clock line '0'->'1'
  **/
-static s32 ixgbe_raise_i2c_clk(struct ixgbe_hw *hw, u32 *i2cctl)
+static void ixgbe_raise_i2c_clk(struct ixgbe_hw *hw, u32 *i2cctl)
 {
-	s32 status = 0;
-
 	*i2cctl |= IXGBE_I2C_CLK_OUT;
 
 	IXGBE_WRITE_REG(hw, IXGBE_I2CCTL, *i2cctl);
@@ -1590,8 +1580,6 @@ static s32 ixgbe_raise_i2c_clk(struct ixgbe_hw *hw, u32 *i2cctl)
 
 	/* SCL rise time (1000ns) */
 	udelay(IXGBE_I2C_T_RISE);
-
-	return status;
 }
 
 /**
-- 
1.7.6.2
