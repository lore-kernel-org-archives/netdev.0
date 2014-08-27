From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/11] i40e: Add checks and message for Qualified Module info
Date: Wed, 27 Aug 2014 02:26:42 -0700
Message-ID: <1409131606-15011-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1409131606-15011-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:64393 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932307AbaH0J0y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2014 05:26:54 -0400
In-Reply-To: <1409131606-15011-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch adds a check during handle_link_event for unqualified
module when link is down and there is a module plugged.  If found,
print a message.

Change-ID: Ibd8666d77d3044c2a3dd4d762d3ae9ac6e18e943
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 712a23b..172f756 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4480,6 +4480,13 @@ static int i40e_up_complete(struct i40e_vsi *vsi)
 		netif_carrier_on(vsi->netdev);
 	} else if (vsi->netdev) {
 		i40e_print_link_message(vsi, false);
+		/* need to check for qualified module here*/
+		if ((pf->hw.phy.link_info.link_info &
+			I40E_AQ_MEDIA_AVAILABLE) &&
+		    (!(pf->hw.phy.link_info.an_info &
+			I40E_AQ_QUALIFIED_MODULE)))
+			netdev_err(vsi->netdev,
+				   "the driver failed to link because an unqualified module was detected.");
 	}
 
 	/* replay FDIR SB filters */
@@ -5492,6 +5499,13 @@ static void i40e_handle_link_event(struct i40e_pf *pf,
 	memcpy(&pf->hw.phy.link_info_old, hw_link_info,
 	       sizeof(pf->hw.phy.link_info_old));
 
+	/* check for unqualified module, if link is down */
+	if ((status->link_info & I40E_AQ_MEDIA_AVAILABLE) &&
+	    (!(status->an_info & I40E_AQ_QUALIFIED_MODULE)) &&
+	    (!(status->link_info & I40E_AQ_LINK_UP)))
+		dev_err(&pf->pdev->dev,
+			"The driver failed to link because an unqualified module was detected.\n");
+
 	/* update link status */
 	hw_link_info->phy_type = (enum i40e_aq_phy_type)status->phy_type;
 	hw_link_info->link_speed = (enum i40e_aq_link_speed)status->link_speed;
-- 
1.9.3
