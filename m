From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 1/8] igb: simplify and clean up igb_enable_mas()
Date: Mon,  4 May 2015 02:40:20 -0700
Message-ID: <1430732427-29984-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1430732427-29984-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Todd Fujinaka <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:53718 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751463AbbEDJkt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2015 05:40:49 -0400
In-Reply-To: <1430732427-29984-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Todd Fujinaka <todd.fujinaka@intel.com>

igb_enable_mas() should only be called for the 82575 and has no clear
return so changing it to void. Also simplify the odd conditional
expression.

Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 27 +++++++--------------------
 1 file changed, 7 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 8457d03..e636646 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1834,31 +1834,19 @@ void igb_reinit_locked(struct igb_adapter *adapter)
  *
  * @adapter: adapter struct
  **/
-static s32 igb_enable_mas(struct igb_adapter *adapter)
+static void igb_enable_mas(struct igb_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	u32 connsw;
-	s32 ret_val = 0;
-
-	connsw = rd32(E1000_CONNSW);
-	if (!(hw->phy.media_type == e1000_media_type_copper))
-		return ret_val;
+	u32 connsw = rd32(E1000_CONNSW);
 
 	/* configure for SerDes media detect */
-	if (!(connsw & E1000_CONNSW_SERDESD)) {
+	if ((hw->phy.media_type == e1000_media_type_copper) &&
+	    (!(connsw & E1000_CONNSW_SERDESD))) {
 		connsw |= E1000_CONNSW_ENRGSRC;
 		connsw |= E1000_CONNSW_AUTOSENSE_EN;
 		wr32(E1000_CONNSW, connsw);
 		wrfl();
-	} else if (connsw & E1000_CONNSW_SERDESD) {
-		/* already SerDes, no need to enable anything */
-		return ret_val;
-	} else {
-		netdev_info(adapter->netdev,
-			"MAS: Unable to configure feature, disabling..\n");
-		adapter->flags &= ~IGB_FLAG_MAS_ENABLE;
 	}
-	return ret_val;
 }
 
 void igb_reset(struct igb_adapter *adapter)
@@ -1978,10 +1966,9 @@ void igb_reset(struct igb_adapter *adapter)
 		adapter->ei.get_invariants(hw);
 		adapter->flags &= ~IGB_FLAG_MEDIA_RESET;
 	}
-	if (adapter->flags & IGB_FLAG_MAS_ENABLE) {
-		if (igb_enable_mas(adapter))
-			dev_err(&pdev->dev,
-				"Error enabling Media Auto Sense\n");
+	if ((mac->type == e1000_82575) &&
+	    (adapter->flags & IGB_FLAG_MAS_ENABLE)) {
+		igb_enable_mas(adapter);
 	}
 	if (hw->mac.ops.init_hw(hw))
 		dev_err(&pdev->dev, "Hardware Error\n");
-- 
2.1.0
