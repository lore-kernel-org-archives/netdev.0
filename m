From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/9] e1000e: Separate signaling for link check/link up
Date: Tue, 10 Oct 2017 10:21:34 -0700
Message-ID: <20171010172139.77914-5-jeffrey.t.kirsher@intel.com>
References: <20171010172139.77914-1-jeffrey.t.kirsher@intel.com>
Cc: Benjamin Poirier <bpoirier@suse.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:6195 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932497AbdJJRWB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Oct 2017 13:22:01 -0400
In-Reply-To: <20171010172139.77914-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Poirier <bpoirier@suse.com>

Lennart reported the following race condition:

\ e1000_watchdog_task
    \ e1000e_has_link
        \ hw->mac.ops.check_for_link() === e1000e_check_for_copper_link
            /* link is up */
            mac->get_link_status = false;

                            /* interrupt */
                            \ e1000_msix_other
                                hw->mac.get_link_status = true;

        link_active = !hw->mac.get_link_status
        /* link_active is false, wrongly */

This problem arises because the single flag get_link_status is used to
signal two different states: link status needs checking and link status is
down.

Avoid the problem by using the return value of .check_for_link to signal
the link status to e1000e_has_link().

Reported-by: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/mac.c    | 11 ++++++++---
 drivers/net/ethernet/intel/e1000e/netdev.c |  2 +-
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/mac.c b/drivers/net/ethernet/intel/e1000e/mac.c
index b322011ec282..f457c5703d0c 100644
--- a/drivers/net/ethernet/intel/e1000e/mac.c
+++ b/drivers/net/ethernet/intel/e1000e/mac.c
@@ -410,6 +410,9 @@ void e1000e_clear_hw_cntrs_base(struct e1000_hw *hw)
  *  Checks to see of the link status of the hardware has changed.  If a
  *  change in link status has been detected, then we read the PHY registers
  *  to get the current speed/duplex if link exists.
+ *
+ *  Returns a negative error code (-E1000_ERR_*) or 0 (link down) or 1 (link
+ *  up).
  **/
 s32 e1000e_check_for_copper_link(struct e1000_hw *hw)
 {
@@ -423,7 +426,7 @@ s32 e1000e_check_for_copper_link(struct e1000_hw *hw)
 	 * Change or Rx Sequence Error interrupt.
 	 */
 	if (!mac->get_link_status)
-		return 0;
+		return 1;
 
 	/* First we want to see if the MII Status Register reports
 	 * link.  If so, then we want to get the current speed/duplex
@@ -461,10 +464,12 @@ s32 e1000e_check_for_copper_link(struct e1000_hw *hw)
 	 * different link partner.
 	 */
 	ret_val = e1000e_config_fc_after_link_up(hw);
-	if (ret_val)
+	if (ret_val) {
 		e_dbg("Error configuring flow control\n");
+		return ret_val;
+	}
 
-	return ret_val;
+	return 1;
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index a740de6a30b0..0a5f95ab0d3c 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5081,7 +5081,7 @@ static bool e1000e_has_link(struct e1000_adapter *adapter)
 	case e1000_media_type_copper:
 		if (hw->mac.get_link_status) {
 			ret_val = hw->mac.ops.check_for_link(hw);
-			link_active = !hw->mac.get_link_status;
+			link_active = ret_val > 0;
 		} else {
 			link_active = true;
 		}
-- 
2.14.2
