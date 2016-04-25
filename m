From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] ixgbe: Add register wait for slow links
Date: Mon, 25 Apr 2016 05:44:19 -0700
Message-ID: <1461588269-128728-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461588269-128728-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:40700 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754628AbcDYMoe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2016 08:44:34 -0400
In-Reply-To: <1461588269-128728-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Use a new register to wait for previous register writes to complete
before issuing a register read. This is needed when slower links
are in use.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 21 +++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |  1 +
 2 files changed, 22 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 657e999..517f06e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -371,6 +371,27 @@ u32 ixgbe_read_reg(struct ixgbe_hw *hw, u32 reg)
 
 	if (ixgbe_removed(reg_addr))
 		return IXGBE_FAILED_READ_REG;
+	if (unlikely(hw->phy.nw_mng_if_sel &
+		     IXGBE_NW_MNG_IF_SEL_ENABLE_10_100M)) {
+		struct ixgbe_adapter *adapter;
+		int i;
+
+		for (i = 0; i < 200; ++i) {
+			value = readl(reg_addr + IXGBE_MAC_SGMII_BUSY);
+			if (likely(!value))
+				goto writes_completed;
+			if (value == IXGBE_FAILED_READ_REG) {
+				ixgbe_remove_adapter(hw);
+				return IXGBE_FAILED_READ_REG;
+			}
+			udelay(5);
+		}
+
+		adapter = hw->back;
+		e_warn(hw, "register writes incomplete %08x\n", value);
+	}
+
+writes_completed:
 	value = readl(reg_addr + reg);
 	if (unlikely(value == IXGBE_FAILED_READ_REG))
 		ixgbe_check_remove(hw, reg);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index ba3b837..29a1c42 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -1131,6 +1131,7 @@ struct ixgbe_thermal_sensor_data {
 #define IXGBE_XPCSS     0x04290
 #define IXGBE_MFLCN     0x04294
 #define IXGBE_SERDESC   0x04298
+#define IXGBE_MAC_SGMII_BUSY 0x04298
 #define IXGBE_MACS      0x0429C
 #define IXGBE_AUTOC     0x042A0
 #define IXGBE_LINKS     0x042A4
-- 
2.5.5
