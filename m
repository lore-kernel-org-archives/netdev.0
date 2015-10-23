From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/17] i40e: Fix VEB/VEPA bridge mode mismatch issue
Date: Fri, 23 Oct 2015 06:17:45 -0700
Message-ID: <1445606279-19345-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445606279-19345-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:13278 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751874AbbJWNSR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 09:18:17 -0400
In-Reply-To: <1445606279-19345-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>

Fix i40e_is_vsi_uplink_mode_veb to check if bridge is actually
in VEB mode before allowing LB in the add VSI routine, instead of
unconditionally returning VEB bridge mode.

Change-ID: I162397b1bdd02367735fe9baaeb51465be2a3ce9
Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index d05254c..f22ded5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8741,12 +8741,22 @@ int i40e_is_vsi_uplink_mode_veb(struct i40e_vsi *vsi)
 		return 1;
 
 	veb = pf->veb[vsi->veb_idx];
+	if (!veb) {
+		dev_info(&pf->pdev->dev,
+			 "There is no veb associated with the bridge\n");
+		return -ENOENT;
+	}
+
 	/* Uplink is a bridge in VEPA mode */
-	if (veb && (veb->bridge_mode & BRIDGE_MODE_VEPA))
+	if (veb->bridge_mode & BRIDGE_MODE_VEPA) {
 		return 0;
+	} else {
+		/* Uplink is a bridge in VEB mode */
+		return 1;
+	}
 
-	/* Uplink is a bridge in VEB mode */
-	return 1;
+	/* VEPA is now default bridge, so return 0 */
+	return 0;
 }
 
 /**
-- 
2.4.3
