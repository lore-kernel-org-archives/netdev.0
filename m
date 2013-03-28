From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/12] e1000e: additional error handling on PHY register accesses
Date: Thu, 28 Mar 2013 02:00:04 -0700
Message-ID: <1364461215-7793-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1364461215-7793-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:20438 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751087Ab3C1JAV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Mar 2013 05:00:21 -0400
In-Reply-To: <1364461215-7793-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

PHY reads/writes via the MDIC register could potentially return results
from a previous PHY register access.  If that happens, the offset in the
returned results will be that of the previous access and if that is
different from the expected offset, log a debug message and error out.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/defines.h |  1 +
 drivers/net/ethernet/intel/e1000e/phy.c     | 12 ++++++++++++
 2 files changed, 13 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/defines.h b/drivers/net/ethernet/intel/e1000e/defines.h
index b7c664f..a6aeb19 100644
--- a/drivers/net/ethernet/intel/e1000e/defines.h
+++ b/drivers/net/ethernet/intel/e1000e/defines.h
@@ -788,6 +788,7 @@
 	GG82563_REG(194, 18) /* Inband Control */
 
 /* MDI Control */
+#define E1000_MDIC_REG_MASK	0x001F0000
 #define E1000_MDIC_REG_SHIFT 16
 #define E1000_MDIC_PHY_SHIFT 21
 #define E1000_MDIC_OP_WRITE  0x04000000
diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index 60dbf02..cbb310f 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -178,6 +178,12 @@ s32 e1000e_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
 		e_dbg("MDI Error\n");
 		return -E1000_ERR_PHY;
 	}
+	if (((mdic & E1000_MDIC_REG_MASK) >> E1000_MDIC_REG_SHIFT) != offset) {
+		e_dbg("MDI Read offset error - requested %d, returned %d\n",
+		      offset,
+		      (mdic & E1000_MDIC_REG_MASK) >> E1000_MDIC_REG_SHIFT);
+		return -E1000_ERR_PHY;
+	}
 	*data = (u16)mdic;
 
 	/* Allow some time after each MDIC transaction to avoid
@@ -236,6 +242,12 @@ s32 e1000e_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
 		e_dbg("MDI Error\n");
 		return -E1000_ERR_PHY;
 	}
+	if (((mdic & E1000_MDIC_REG_MASK) >> E1000_MDIC_REG_SHIFT) != offset) {
+		e_dbg("MDI Write offset error - requested %d, returned %d\n",
+		      offset,
+		      (mdic & E1000_MDIC_REG_MASK) >> E1000_MDIC_REG_SHIFT);
+		return -E1000_ERR_PHY;
+	}
 
 	/* Allow some time after each MDIC transaction to avoid
 	 * reading duplicate data in the next MDIC transaction.
-- 
1.7.11.7
