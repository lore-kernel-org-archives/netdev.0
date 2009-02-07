From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 05/26] igb: add link check function
Date: Sat, 07 Feb 2009 01:16:24 -0800
Message-ID: <20090207091624.15697.89569.stgit@lost.foo-projects.org>
References: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.westchester.pa.mail.comcast.net ([76.96.62.48]:59430
	"EHLO QMTA05.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752328AbZBGJQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 04:16:45 -0500
In-Reply-To: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Add a link check function to contain all activities related to verifying
that the link is present.  The current approach is a bit cludgy and needs
to be cleaned up.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   59 +++++++++++++++++++++++++++++++-------------
 1 files changed, 42 insertions(+), 17 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 13b10ba..b59088e 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2261,6 +2261,46 @@ static void igb_update_phy_info(unsigned long data)
 }
 
 /**
+ * igb_has_link - check shared code for link and determine up/down
+ * @adapter: pointer to driver private info
+ **/
+static bool igb_has_link(struct igb_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	bool link_active = false;
+	s32 ret_val = 0;
+
+	/* get_link_status is set on LSC (link status) interrupt or
+	 * rx sequence error interrupt.  get_link_status will stay
+	 * false until the e1000_check_for_link establishes link
+	 * for copper adapters ONLY
+	 */
+	switch (hw->phy.media_type) {
+	case e1000_media_type_copper:
+		if (hw->mac.get_link_status) {
+			ret_val = hw->mac.ops.check_for_link(hw);
+			link_active = !hw->mac.get_link_status;
+		} else {
+			link_active = true;
+		}
+		break;
+	case e1000_media_type_fiber:
+		ret_val = hw->mac.ops.check_for_link(hw);
+		link_active = !!(rd32(E1000_STATUS) & E1000_STATUS_LU);
+		break;
+	case e1000_media_type_internal_serdes:
+		ret_val = hw->mac.ops.check_for_link(hw);
+		link_active = hw->mac.serdes_has_link;
+		break;
+	default:
+	case e1000_media_type_unknown:
+		break;
+	}
+
+	return link_active;
+}
+
+/**
  * igb_watchdog - Timer Call-back
  * @data: pointer to adapter cast into an unsigned long
  **/
@@ -2285,25 +2325,10 @@ static void igb_watchdog_task(struct work_struct *work)
 	s32 ret_val;
 	int i;
 
-	if ((netif_carrier_ok(netdev)) &&
-	    (rd32(E1000_STATUS) & E1000_STATUS_LU))
+	link = igb_has_link(adapter);
+	if ((netif_carrier_ok(netdev)) && link)
 		goto link_up;
 
-	ret_val = hw->mac.ops.check_for_link(&adapter->hw);
-	if ((ret_val == E1000_ERR_PHY) &&
-	    (hw->phy.type == e1000_phy_igp_3) &&
-	    (rd32(E1000_CTRL) &
-	     E1000_PHY_CTRL_GBE_DISABLE))
-		dev_info(&adapter->pdev->dev,
-			 "Gigabit has been disabled, downgrading speed\n");
-
-	if ((hw->phy.media_type == e1000_media_type_internal_serdes) &&
-	    !(rd32(E1000_TXCW) & E1000_TXCW_ANE))
-		link = mac->serdes_has_link;
-	else
-		link = rd32(E1000_STATUS) &
-				      E1000_STATUS_LU;
-
 	if (link) {
 		if (!netif_carrier_ok(netdev)) {
 			u32 ctrl;

