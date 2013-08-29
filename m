From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 07/10] ixgbe: fix SFF data dumps of SFP+ modules from an offset
Date: Thu, 29 Aug 2013 03:50:03 -0700
Message-ID: <1377773406-24851-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1377773406-24851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:56411 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756023Ab3H2Kub (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Aug 2013 06:50:31 -0400
In-Reply-To: <1377773406-24851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch fixes the read loop for the I2C data to account for the offset.

Also includes a whitespace cleanup and removes ret_val as it is not needed.

CC: Ben Hutchings <bhutchings@solarflare.com>
Reported-by: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index b6f1592..2d0308e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2946,28 +2946,27 @@ static int ixgbe_get_module_eeprom(struct net_device *dev,
 	u32 status = IXGBE_ERR_PHY_ADDR_INVALID;
 	u8 databyte = 0xFF;
 	int i = 0;
-	int ret_val = 0;
 
 	if (ee->len == 0)
 		return -EINVAL;
 
-	for (i = ee->offset; i < ee->len; i++) {
+	for (i = ee->offset; i < ee->offset + ee->len; i++) {
 		/* I2C reads can take long time */
 		if (test_bit(__IXGBE_IN_SFP_INIT, &adapter->state))
 			return -EBUSY;
 
 		if (i < ETH_MODULE_SFF_8079_LEN)
-			status  = hw->phy.ops.read_i2c_eeprom(hw, i, &databyte);
+			status = hw->phy.ops.read_i2c_eeprom(hw, i, &databyte);
 		else
 			status = hw->phy.ops.read_i2c_sff8472(hw, i, &databyte);
 
 		if (status != 0)
-			ret_val = -EIO;
+			return -EIO;
 
 		data[i - ee->offset] = databyte;
 	}
 
-	return ret_val;
+	return 0;
 }
 
 static const struct ethtool_ops ixgbe_ethtool_ops = {
-- 
1.8.3.1
