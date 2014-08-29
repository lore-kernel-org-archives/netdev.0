From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] ixgbevf: introduce delay for checking VFLINKS on 82599
Date: Fri, 29 Aug 2014 02:30:18 -0700
Message-ID: <1409304620-23251-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1409304620-23251-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53242 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752074AbaH2Jaa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2014 05:30:30 -0400
In-Reply-To: <1409304620-23251-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

VFLINKS.LINKUP bit tends to flap when a DA or SFP+ cable is disconnected.
It can take up to 500 usecs for the LINKUP bit to be correct.

This patch resolves the issue by introducing a delay for 82599 VFs of at
least 500 usecs to make sure the VFLINKS value is correct.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/vf.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index 4d44d64..9cddd56 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -434,6 +434,21 @@ static s32 ixgbevf_check_mac_link_vf(struct ixgbe_hw *hw,
 	if (!(links_reg & IXGBE_LINKS_UP))
 		goto out;
 
+	/* for SFP+ modules and DA cables on 82599 it can take up to 500usecs
+	 * before the link status is correct
+	 */
+	if (mac->type == ixgbe_mac_82599_vf) {
+		int i;
+
+		for (i = 0; i < 5; i++) {
+			udelay(100);
+			links_reg = IXGBE_READ_REG(hw, IXGBE_VFLINKS);
+
+			if (!(links_reg & IXGBE_LINKS_UP))
+				goto out;
+		}
+	}
+
 	switch (links_reg & IXGBE_LINKS_SPEED_82599) {
 	case IXGBE_LINKS_SPEED_10G_82599:
 		*speed = IXGBE_LINK_SPEED_10GB_FULL;
-- 
1.9.3
