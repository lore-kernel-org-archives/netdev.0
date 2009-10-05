From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 04/15] igb: add locking to reads of the i2c
	interface
Date: Mon, 05 Oct 2009 09:32:27 -0700
Message-ID: <20091005163226.32487.91764.stgit@localhost.localdomain>
References: <20091005163058.32487.10125.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.emeryville.ca.mail.comcast.net ([76.96.30.96]:37364 "EHLO
	QMTA09.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753964AbZJEQek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 12:34:40 -0400
In-Reply-To: <20091005163058.32487.10125.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The current implementation of sgmii support isn't correctly locking the
interfaces for reads/writes.  This change pulls the read/write
functionality out of 82575.c and moves it to phy.c.  In addition it
replaces the implementation in 82575.c with one that uses locking around
the relocated i2c interface calls.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c |   85 ++++++++----------------------------
 drivers/net/igb/e1000_phy.c   |   97 +++++++++++++++++++++++++++++++++++++++++
 drivers/net/igb/e1000_phy.h   |    2 +
 3 files changed, 119 insertions(+), 65 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index 65b9000..7897181 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -277,45 +277,23 @@ static void igb_release_phy_82575(struct e1000_hw *hw)
 static s32 igb_read_phy_reg_sgmii_82575(struct e1000_hw *hw, u32 offset,
 					  u16 *data)
 {
-	struct e1000_phy_info *phy = &hw->phy;
-	u32 i, i2ccmd = 0;
+	s32 ret_val = -E1000_ERR_PARAM;
 
 	if (offset > E1000_MAX_SGMII_PHY_REG_ADDR) {
 		hw_dbg("PHY Address %u is out of range\n", offset);
-		return -E1000_ERR_PARAM;
+		goto out;
 	}
 
-	/*
-	 * Set up Op-code, Phy Address, and register address in the I2CCMD
-	 * register.  The MAC will take care of interfacing with the
-	 * PHY to retrieve the desired data.
-	 */
-	i2ccmd = ((offset << E1000_I2CCMD_REG_ADDR_SHIFT) |
-		  (phy->addr << E1000_I2CCMD_PHY_ADDR_SHIFT) |
-		  (E1000_I2CCMD_OPCODE_READ));
+	ret_val = hw->phy.ops.acquire(hw);
+	if (ret_val)
+		goto out;
 
-	wr32(E1000_I2CCMD, i2ccmd);
+	ret_val = igb_read_phy_reg_i2c(hw, offset, data);
 
-	/* Poll the ready bit to see if the I2C read completed */
-	for (i = 0; i < E1000_I2CCMD_PHY_TIMEOUT; i++) {
-		udelay(50);
-		i2ccmd = rd32(E1000_I2CCMD);
-		if (i2ccmd & E1000_I2CCMD_READY)
-			break;
-	}
-	if (!(i2ccmd & E1000_I2CCMD_READY)) {
-		hw_dbg("I2CCMD Read did not complete\n");
-		return -E1000_ERR_PHY;
-	}
-	if (i2ccmd & E1000_I2CCMD_ERROR) {
-		hw_dbg("I2CCMD Error bit set\n");
-		return -E1000_ERR_PHY;
-	}
-
-	/* Need to byte-swap the 16-bit value. */
-	*data = ((i2ccmd >> 8) & 0x00FF) | ((i2ccmd << 8) & 0xFF00);
+	hw->phy.ops.release(hw);
 
-	return 0;
+out:
+	return ret_val;
 }
 
 /**
@@ -330,47 +308,24 @@ static s32 igb_read_phy_reg_sgmii_82575(struct e1000_hw *hw, u32 offset,
 static s32 igb_write_phy_reg_sgmii_82575(struct e1000_hw *hw, u32 offset,
 					   u16 data)
 {
-	struct e1000_phy_info *phy = &hw->phy;
-	u32 i, i2ccmd = 0;
-	u16 phy_data_swapped;
+	s32 ret_val = -E1000_ERR_PARAM;
+
 
 	if (offset > E1000_MAX_SGMII_PHY_REG_ADDR) {
 		hw_dbg("PHY Address %d is out of range\n", offset);
-		return -E1000_ERR_PARAM;
+		goto out;
 	}
 
-	/* Swap the data bytes for the I2C interface */
-	phy_data_swapped = ((data >> 8) & 0x00FF) | ((data << 8) & 0xFF00);
+	ret_val = hw->phy.ops.acquire(hw);
+	if (ret_val)
+		goto out;
 
-	/*
-	 * Set up Op-code, Phy Address, and register address in the I2CCMD
-	 * register.  The MAC will take care of interfacing with the
-	 * PHY to retrieve the desired data.
-	 */
-	i2ccmd = ((offset << E1000_I2CCMD_REG_ADDR_SHIFT) |
-		  (phy->addr << E1000_I2CCMD_PHY_ADDR_SHIFT) |
-		  E1000_I2CCMD_OPCODE_WRITE |
-		  phy_data_swapped);
-
-	wr32(E1000_I2CCMD, i2ccmd);
-
-	/* Poll the ready bit to see if the I2C read completed */
-	for (i = 0; i < E1000_I2CCMD_PHY_TIMEOUT; i++) {
-		udelay(50);
-		i2ccmd = rd32(E1000_I2CCMD);
-		if (i2ccmd & E1000_I2CCMD_READY)
-			break;
-	}
-	if (!(i2ccmd & E1000_I2CCMD_READY)) {
-		hw_dbg("I2CCMD Write did not complete\n");
-		return -E1000_ERR_PHY;
-	}
-	if (i2ccmd & E1000_I2CCMD_ERROR) {
-		hw_dbg("I2CCMD Error bit set\n");
-		return -E1000_ERR_PHY;
-	}
+	ret_val = igb_write_phy_reg_i2c(hw, offset, data);
 
-	return 0;
+	hw->phy.ops.release(hw);
+
+out:
+	return ret_val;
 }
 
 /**
diff --git a/drivers/net/igb/e1000_phy.c b/drivers/net/igb/e1000_phy.c
index ee46060..d4c928c 100644
--- a/drivers/net/igb/e1000_phy.c
+++ b/drivers/net/igb/e1000_phy.c
@@ -239,6 +239,103 @@ out:
 }
 
 /**
+ *  igb_read_phy_reg_i2c - Read PHY register using i2c
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to be read
+ *  @data: pointer to the read data
+ *
+ *  Reads the PHY register at offset using the i2c interface and stores the
+ *  retrieved information in data.
+ **/
+s32 igb_read_phy_reg_i2c(struct e1000_hw *hw, u32 offset, u16 *data)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	u32 i, i2ccmd = 0;
+
+
+	/*
+	 * Set up Op-code, Phy Address, and register address in the I2CCMD
+	 * register.  The MAC will take care of interfacing with the
+	 * PHY to retrieve the desired data.
+	 */
+	i2ccmd = ((offset << E1000_I2CCMD_REG_ADDR_SHIFT) |
+	          (phy->addr << E1000_I2CCMD_PHY_ADDR_SHIFT) |
+	          (E1000_I2CCMD_OPCODE_READ));
+
+	wr32(E1000_I2CCMD, i2ccmd);
+
+	/* Poll the ready bit to see if the I2C read completed */
+	for (i = 0; i < E1000_I2CCMD_PHY_TIMEOUT; i++) {
+		udelay(50);
+		i2ccmd = rd32(E1000_I2CCMD);
+		if (i2ccmd & E1000_I2CCMD_READY)
+			break;
+	}
+	if (!(i2ccmd & E1000_I2CCMD_READY)) {
+		hw_dbg("I2CCMD Read did not complete\n");
+		return -E1000_ERR_PHY;
+	}
+	if (i2ccmd & E1000_I2CCMD_ERROR) {
+		hw_dbg("I2CCMD Error bit set\n");
+		return -E1000_ERR_PHY;
+	}
+
+	/* Need to byte-swap the 16-bit value. */
+	*data = ((i2ccmd >> 8) & 0x00FF) | ((i2ccmd << 8) & 0xFF00);
+
+	return 0;
+}
+
+/**
+ *  igb_write_phy_reg_i2c - Write PHY register using i2c
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to write to
+ *  @data: data to write at register offset
+ *
+ *  Writes the data to PHY register at the offset using the i2c interface.
+ **/
+s32 igb_write_phy_reg_i2c(struct e1000_hw *hw, u32 offset, u16 data)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	u32 i, i2ccmd = 0;
+	u16 phy_data_swapped;
+
+
+	/* Swap the data bytes for the I2C interface */
+	phy_data_swapped = ((data >> 8) & 0x00FF) | ((data << 8) & 0xFF00);
+
+	/*
+	 * Set up Op-code, Phy Address, and register address in the I2CCMD
+	 * register.  The MAC will take care of interfacing with the
+	 * PHY to retrieve the desired data.
+	 */
+	i2ccmd = ((offset << E1000_I2CCMD_REG_ADDR_SHIFT) |
+	          (phy->addr << E1000_I2CCMD_PHY_ADDR_SHIFT) |
+	          E1000_I2CCMD_OPCODE_WRITE |
+	          phy_data_swapped);
+
+	wr32(E1000_I2CCMD, i2ccmd);
+
+	/* Poll the ready bit to see if the I2C read completed */
+	for (i = 0; i < E1000_I2CCMD_PHY_TIMEOUT; i++) {
+		udelay(50);
+		i2ccmd = rd32(E1000_I2CCMD);
+		if (i2ccmd & E1000_I2CCMD_READY)
+			break;
+	}
+	if (!(i2ccmd & E1000_I2CCMD_READY)) {
+		hw_dbg("I2CCMD Write did not complete\n");
+		return -E1000_ERR_PHY;
+	}
+	if (i2ccmd & E1000_I2CCMD_ERROR) {
+		hw_dbg("I2CCMD Error bit set\n");
+		return -E1000_ERR_PHY;
+	}
+
+	return 0;
+}
+
+/**
  *  igb_read_phy_reg_igp - Read igp PHY register
  *  @hw: pointer to the HW structure
  *  @offset: register offset to be read
diff --git a/drivers/net/igb/e1000_phy.h b/drivers/net/igb/e1000_phy.h
index ebe4b61..4c49803 100644
--- a/drivers/net/igb/e1000_phy.h
+++ b/drivers/net/igb/e1000_phy.h
@@ -61,6 +61,8 @@ s32  igb_write_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 data);
 s32  igb_phy_has_link(struct e1000_hw *hw, u32 iterations,
 				u32 usec_interval, bool *success);
 s32  igb_phy_init_script_igp3(struct e1000_hw *hw);
+s32  igb_read_phy_reg_i2c(struct e1000_hw *hw, u32 offset, u16 *data);
+s32  igb_write_phy_reg_i2c(struct e1000_hw *hw, u32 offset, u16 data);
 
 /* IGP01E1000 Specific Registers */
 #define IGP01E1000_PHY_PORT_CONFIG        0x10 /* Port Config */

