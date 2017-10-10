From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/9] e1000e: Fix error path in link detection
Date: Tue, 10 Oct 2017 10:21:31 -0700
Message-ID: <20171010172139.77914-2-jeffrey.t.kirsher@intel.com>
References: <20171010172139.77914-1-jeffrey.t.kirsher@intel.com>
Cc: Benjamin Poirier <bpoirier@suse.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:11575 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932560AbdJJRWB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Oct 2017 13:22:01 -0400
In-Reply-To: <20171010172139.77914-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Poirier <bpoirier@suse.com>

In case of error from e1e_rphy(), the loop will exit early and "success"
will be set to true erroneously.

Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/phy.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index d78d47b41a71..86ff0969efb6 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -1744,6 +1744,7 @@ s32 e1000e_phy_has_link_generic(struct e1000_hw *hw, u32 iterations,
 	s32 ret_val = 0;
 	u16 i, phy_status;
 
+	*success = false;
 	for (i = 0; i < iterations; i++) {
 		/* Some PHYs require the MII_BMSR register to be read
 		 * twice due to the link bit being sticky.  No harm doing
@@ -1763,16 +1764,16 @@ s32 e1000e_phy_has_link_generic(struct e1000_hw *hw, u32 iterations,
 		ret_val = e1e_rphy(hw, MII_BMSR, &phy_status);
 		if (ret_val)
 			break;
-		if (phy_status & BMSR_LSTATUS)
+		if (phy_status & BMSR_LSTATUS) {
+			*success = true;
 			break;
+		}
 		if (usec_interval >= 1000)
 			msleep(usec_interval / 1000);
 		else
 			udelay(usec_interval);
 	}
 
-	*success = (i < iterations);
-
 	return ret_val;
 }
 
-- 
2.14.2
