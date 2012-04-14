From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/6] ixgbe: add I2C clock stretching
Date: Sat, 14 Apr 2012 02:16:31 -0700
Message-ID: <1334394991-5839-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1334394991-5839-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:21304 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752948Ab2DNJQh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Apr 2012 05:16:37 -0400
In-Reply-To: <1334394991-5839-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch adds support for I2C clock stretching which is required per
SFF-8636.  Customers with passive DA cables implement clock stretching
would fail without this patch.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c  |   20 ++++++++++++++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |    1 +
 2 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index bf9f82f..2411770 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -1582,13 +1582,21 @@ static s32 ixgbe_clock_out_i2c_bit(struct ixgbe_hw *hw, bool data)
  **/
 static void ixgbe_raise_i2c_clk(struct ixgbe_hw *hw, u32 *i2cctl)
 {
-	*i2cctl |= IXGBE_I2C_CLK_OUT;
-
-	IXGBE_WRITE_REG(hw, IXGBE_I2CCTL, *i2cctl);
-	IXGBE_WRITE_FLUSH(hw);
+	u32 i = 0;
+	u32 timeout = IXGBE_I2C_CLOCK_STRETCHING_TIMEOUT;
+	u32 i2cctl_r = 0;
 
-	/* SCL rise time (1000ns) */
-	udelay(IXGBE_I2C_T_RISE);
+	for (i = 0; i < timeout; i++) {
+		*i2cctl |= IXGBE_I2C_CLK_OUT;
+		IXGBE_WRITE_REG(hw, IXGBE_I2CCTL, *i2cctl);
+		IXGBE_WRITE_FLUSH(hw);
+		/* SCL rise time (1000ns) */
+		udelay(IXGBE_I2C_T_RISE);
+
+		i2cctl_r = IXGBE_READ_REG(hw, IXGBE_I2CCTL);
+		if (i2cctl_r & IXGBE_I2C_CLK_IN)
+			break;
+	}
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index ffa6679..4acd9e6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -110,6 +110,7 @@
 #define IXGBE_I2C_CLK_OUT   0x00000002
 #define IXGBE_I2C_DATA_IN   0x00000004
 #define IXGBE_I2C_DATA_OUT  0x00000008
+#define IXGBE_I2C_CLOCK_STRETCHING_TIMEOUT	500
 
 /* Interrupt Registers */
 #define IXGBE_EICR      0x00800
-- 
1.7.7.6
