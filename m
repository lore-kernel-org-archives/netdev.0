From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] ixgbe: fix SFF data dumps of SFP+ modules
Date: Mon, 29 Jul 2013 05:52:03 -0700
Message-ID: <1375102331-23905-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1375102331-23905-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:38183 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753745Ab3G2Mwb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jul 2013 08:52:31 -0400
In-Reply-To: <1375102331-23905-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch fixes several issues with the previous implementation of the
SFF data dump of SFP+ modules:

- removed the __IXGBE_READ_I2C flag - I2C access locking is handled in the
  HW specific routines

- fixed the read loop to read data from ee->offset to ee->len

- the reads fail if __IXGBE_IN_SFP_INIT is set in the process - this is
  needed because on some HW I2C operations can take long time and disrupt
  the SFP and link detection process

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Reported-by: Ben Hutchings <bhutchings@solarflare.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |  1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 73 ++++++------------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  4 --
 3 files changed, 18 insertions(+), 60 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 7be725c..d882278 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -754,7 +754,6 @@ enum ixgbe_state_t {
 	__IXGBE_DOWN,
 	__IXGBE_SERVICE_SCHED,
 	__IXGBE_IN_SFP_INIT,
-	__IXGBE_READ_I2C,
 };
 
 struct ixgbe_cb {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index ae58a92..da1ea28 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2910,33 +2910,21 @@ static int ixgbe_get_module_info(struct net_device *dev,
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 status;
 	u8 sff8472_rev, addr_mode;
-	int ret_val = 0;
 	bool page_swap = false;
 
-	/* avoid concurent i2c reads */
-	while (test_bit(__IXGBE_IN_SFP_INIT, &adapter->state))
-		msleep(100);
-
-	/* used by the service task */
-	set_bit(__IXGBE_READ_I2C, &adapter->state);
-
 	/* Check whether we support SFF-8472 or not */
 	status = hw->phy.ops.read_i2c_eeprom(hw,
 					     IXGBE_SFF_SFF_8472_COMP,
 					     &sff8472_rev);
-	if (status != 0) {
-		ret_val = -EIO;
-		goto err_out;
-	}
+	if (status != 0)
+		return -EIO;
 
 	/* addressing mode is not supported */
 	status = hw->phy.ops.read_i2c_eeprom(hw,
 					     IXGBE_SFF_SFF_8472_SWAP,
 					     &addr_mode);
-	if (status != 0) {
-		ret_val = -EIO;
-		goto err_out;
-	}
+	if (status != 0)
+		return -EIO;
 
 	if (addr_mode & IXGBE_SFF_ADDRESSING_MODE) {
 		e_err(drv, "Address change required to access page 0xA2, but not supported. Please report the module type to the driver maintainers.\n");
@@ -2953,9 +2941,7 @@ static int ixgbe_get_module_info(struct net_device *dev,
 		modinfo->eeprom_len = ETH_MODULE_SFF_8472_LEN;
 	}
 
-err_out:
-	clear_bit(__IXGBE_READ_I2C, &adapter->state);
-	return ret_val;
+	return 0;
 }
 
 static int ixgbe_get_module_eeprom(struct net_device *dev,
@@ -2969,48 +2955,25 @@ static int ixgbe_get_module_eeprom(struct net_device *dev,
 	int i = 0;
 	int ret_val = 0;
 
-	/* ixgbe_get_module_info is called before this function in all
-	 * cases, so we do not need any checks we already do above,
-	 * and can trust ee->len to be a known value.
-	 */
+	if (ee->len == 0)
+		return -EINVAL;
 
-	while (test_bit(__IXGBE_IN_SFP_INIT, &adapter->state))
-		msleep(100);
-	set_bit(__IXGBE_READ_I2C, &adapter->state);
+	for (i = ee->offset; i < ee->len; i++) {
+		/* I2C reads can take long time */
+		if (test_bit(__IXGBE_IN_SFP_INIT, &adapter->state))
+			return -EBUSY;
 
-	/* Read the first block, SFF-8079 */
-	for (i = 0; i < ETH_MODULE_SFF_8079_LEN; i++) {
-		status = hw->phy.ops.read_i2c_eeprom(hw, i, &databyte);
-		if (status != 0) {
-			/* Error occured while reading module */
+		if (i < ETH_MODULE_SFF_8079_LEN)
+			status  = hw->phy.ops.read_i2c_eeprom(hw, i, &databyte);
+		else
+			status = hw->phy.ops.read_i2c_sff8472(hw, i, &databyte);
+
+		if (status != 0)
 			ret_val = -EIO;
-			goto err_out;
-		}
-		data[i] = databyte;
-	}
 
-	/* If the second block is requested, check if SFF-8472 is supported. */
-	if (ee->len == ETH_MODULE_SFF_8472_LEN) {
-		if (data[IXGBE_SFF_SFF_8472_COMP] == IXGBE_SFF_SFF_8472_UNSUP)
-			return -EOPNOTSUPP;
-
-		/* Read the second block, SFF-8472 */
-		for (i = ETH_MODULE_SFF_8079_LEN;
-		     i < ETH_MODULE_SFF_8472_LEN; i++) {
-			status = hw->phy.ops.read_i2c_sff8472(hw,
-				i - ETH_MODULE_SFF_8079_LEN, &databyte);
-			if (status != 0) {
-				/* Error occured while reading module */
-				ret_val = -EIO;
-				goto err_out;
-			}
-			data[i] = databyte;
-		}
+		data[i - ee->offset] = databyte;
 	}
 
-err_out:
-	clear_bit(__IXGBE_READ_I2C, &adapter->state);
-
 	return ret_val;
 }
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 6a2b7a0..3aff87e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5833,10 +5833,6 @@ static void ixgbe_sfp_detection_subtask(struct ixgbe_adapter *adapter)
 	    !(adapter->flags2 & IXGBE_FLAG2_SFP_NEEDS_RESET))
 		return;
 
-	/* concurent i2c reads are not supported */
-	if (test_bit(__IXGBE_READ_I2C, &adapter->state))
-		return;
-
 	/* someone else is in init, wait until next service event */
 	if (test_and_set_bit(__IXGBE_IN_SFP_INIT, &adapter->state))
 		return;
-- 
1.7.11.7
