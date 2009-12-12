From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 3/3] Fix 82598 premature copper PHY link indicatation
Date: Fri, 11 Dec 2009 23:52:01 -0800
Message-ID: <20091212075200.10952.13217.stgit@localhost.localdomain>
References: <20091212075120.10952.98484.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:38803 "EHLO
	QMTA04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757106AbZLLHwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2009 02:52:13 -0500
In-Reply-To: <20091212075120.10952.98484.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>

Fix 82598 copper link issue, where the phy prematurely indicates link
before it is ready to process packets. The new function looks for phy
link and indicates that, when it is available. If phy is not ready
within few seconds of MAC indicating link, the function will return
failure which translates to link down indication

Signed-off-by:  Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82598.c |   38 ++++++++++++++++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_type.h  |    2 ++
 2 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index e2d5343..1cc91f8 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -510,6 +510,40 @@ static s32 ixgbe_start_mac_link_82598(struct ixgbe_hw *hw,
 }
 
 /**
+ *  ixgbe_validate_link_ready - Function looks for phy link
+ *  @hw: pointer to hardware structure
+ *
+ *  Function indicates success when phy link is available. If phy is not ready
+ *  within 5 seconds of MAC indicating link, the function returns error.
+ **/
+static s32 ixgbe_validate_link_ready(struct ixgbe_hw *hw)
+{
+	u32 timeout;
+	u16 an_reg;
+
+	if (hw->device_id != IXGBE_DEV_ID_82598AT2)
+		return 0;
+
+	for (timeout = 0;
+	     timeout < IXGBE_VALIDATE_LINK_READY_TIMEOUT; timeout++) {
+		hw->phy.ops.read_reg(hw, MDIO_STAT1, MDIO_MMD_AN, &an_reg);
+
+		if ((an_reg & MDIO_AN_STAT1_COMPLETE) &&
+		    (an_reg & MDIO_STAT1_LSTATUS))
+			break;
+
+		mdelay(100);
+	}
+
+	if (timeout == IXGBE_VALIDATE_LINK_READY_TIMEOUT) {
+		hw_dbg(hw, "Link was indicated but link is down\n");
+		return IXGBE_ERR_LINK_SETUP;
+	}
+
+	return 0;
+}
+
+/**
  *  ixgbe_check_mac_link_82598 - Get link/speed status
  *  @hw: pointer to hardware structure
  *  @speed: pointer to link speed
@@ -589,6 +623,10 @@ static s32 ixgbe_check_mac_link_82598(struct ixgbe_hw *hw,
 	else
 		*speed = IXGBE_LINK_SPEED_1GB_FULL;
 
+	if ((hw->device_id == IXGBE_DEV_ID_82598AT2) && (*link_up == true) &&
+	    (ixgbe_validate_link_ready(hw) != 0))
+		*link_up = false;
+
 	/* if link is down, zero out the current_mode */
 	if (*link_up == false) {
 		hw->fc.current_mode = ixgbe_fc_none;
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index f3e8d52..84650c6 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -841,6 +841,8 @@
 #define IXGBE_MPVC      0x04318
 #define IXGBE_SGMIIC    0x04314
 
+#define IXGBE_VALIDATE_LINK_READY_TIMEOUT 50
+
 /* Omer CORECTL */
 #define IXGBE_CORECTL           0x014F00
 /* BARCTRL */

