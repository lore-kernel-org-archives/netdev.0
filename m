From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/14] igb: Fix i354 88E1112 PHY on RCC boards using AutoMediaDetect
Date: Fri, 17 Jul 2015 07:25:23 -0700
Message-ID: <1437143123-5031-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1437143123-5031-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Todd Fujinaka <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:19520 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757934AbbGQOZh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jul 2015 10:25:37 -0400
In-Reply-To: <1437143123-5031-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Todd Fujinaka <todd.fujinaka@intel.com>

e1000_check_for_link_media_swap() checks PHY page 0 for copper and PHY
page 1 for "other" (fiber) link. The switch back from page 1 to page 0
happened too soon, before e1000_check_for_link_82575() is executed, and
link on fiber (other) was never detected. Check for link while still on
the proper PHY page.

Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index b0182dd..d192569 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -139,10 +139,6 @@ static s32 igb_check_for_link_media_swap(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	/* reset page to 0 */
-	ret_val = phy->ops.write_reg(hw, E1000_M88E1112_PAGE_ADDR, 0);
-	if (ret_val)
-		return ret_val;
 
 	if (data & E1000_M88E1112_STATUS_LINK)
 		port = E1000_MEDIA_PORT_OTHER;
@@ -151,8 +147,20 @@ static s32 igb_check_for_link_media_swap(struct e1000_hw *hw)
 	if (port && (hw->dev_spec._82575.media_port != port)) {
 		hw->dev_spec._82575.media_port = port;
 		hw->dev_spec._82575.media_changed = true;
+	}
+
+	if (port == E1000_MEDIA_PORT_COPPER) {
+		/* reset page to 0 */
+		ret_val = phy->ops.write_reg(hw, E1000_M88E1112_PAGE_ADDR, 0);
+		if (ret_val)
+			return ret_val;
+		igb_check_for_link_82575(hw);
 	} else {
-		ret_val = igb_check_for_link_82575(hw);
+		igb_check_for_link_82575(hw);
+		/* reset page to 0 */
+		ret_val = phy->ops.write_reg(hw, E1000_M88E1112_PAGE_ADDR, 0);
+		if (ret_val)
+			return ret_val;
 	}
 
 	return 0;
-- 
2.4.3
