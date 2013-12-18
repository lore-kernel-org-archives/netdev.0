From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/5] e1000e: fix compiler warnings
Date: Tue, 17 Dec 2013 23:19:43 -0800
Message-ID: <1387351186-23389-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1387351186-23389-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: David Ertman <davidx.m.ertman@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:58137 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751251Ab3LRHTt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 02:19:49 -0500
In-Reply-To: <1387351186-23389-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ertman <davidx.m.ertman@intel.com>

This patch is to fix a compiler warning of __bad_udelay due to a value
of >999 being passed as a parameter to udelay() in the function
e1000e_phy_has_link_generic().  This affects the gcc compiler when
it is given a flag of -O3 and the icc compiler.

This patch is also making the change from mdelay() to msleep() in the
same function, since it was determined though code inspection that this
function is never called in atomic context.

Signed-off-by: David Ertman <davidx.m.ertman@intel.com>
Acked-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/phy.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index da2be59..20e71f4 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -1757,19 +1757,23 @@ s32 e1000e_phy_has_link_generic(struct e1000_hw *hw, u32 iterations,
 		 * it across the board.
 		 */
 		ret_val = e1e_rphy(hw, MII_BMSR, &phy_status);
-		if (ret_val)
+		if (ret_val) {
 			/* If the first read fails, another entity may have
 			 * ownership of the resources, wait and try again to
 			 * see if they have relinquished the resources yet.
 			 */
-			udelay(usec_interval);
+			if (usec_interval >= 1000)
+				msleep(usec_interval / 1000);
+			else
+				udelay(usec_interval);
+		}
 		ret_val = e1e_rphy(hw, MII_BMSR, &phy_status);
 		if (ret_val)
 			break;
 		if (phy_status & BMSR_LSTATUS)
 			break;
 		if (usec_interval >= 1000)
-			mdelay(usec_interval / 1000);
+			msleep(usec_interval / 1000);
 		else
 			udelay(usec_interval);
 	}
-- 
1.8.3.1
