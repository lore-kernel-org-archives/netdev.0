From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] i40e: Display error message if module does not meet thermal requirements
Date: Fri,  6 Oct 2017 10:57:21 -0700
Message-ID: <20171006175727.868-10-jeffrey.t.kirsher@intel.com>
References: <20171006175727.868-1-jeffrey.t.kirsher@intel.com>
Cc: Filip Sadowski <filip.sadowski@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:41314 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752592AbdJFR5v (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Oct 2017 13:57:51 -0400
In-Reply-To: <20171006175727.868-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Filip Sadowski <filip.sadowski@intel.com>

This patch causes error message to be displayed when NIC detects
insertion of module that does not meet thermal requirements.

Signed-off-by: Filip Sadowski <filip.sadowski@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h             |  1 +
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |  1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 24 +++++++++++++++++-----
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    |  1 +
 4 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index c78448daa7a1..4dc6d43f8812 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -451,6 +451,7 @@ struct i40e_pf {
 #define I40E_FLAG_CLIENT_RESET			BIT_ULL(54)
 #define I40E_FLAG_TEMP_LINK_POLLING		BIT_ULL(55)
 #define I40E_FLAG_CLIENT_L2_CHANGE		BIT_ULL(56)
+#define I40E_FLAG_LINK_DOWN_ON_CLOSE_ENABLED	BIT_ULL(57)
 #define I40E_FLAG_LEGACY_RX			BIT_ULL(58)
 #define I40E_FLAG_SOURCE_PRUNING_DISABLED	BIT_ULL(59)
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
index 50c5a4c630b8..a8f65aed5421 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
@@ -1772,6 +1772,7 @@ enum i40e_aq_phy_type {
 	I40E_PHY_TYPE_25GBASE_SR		= 0x21,
 	I40E_PHY_TYPE_25GBASE_LR		= 0x22,
 	I40E_PHY_TYPE_MAX,
+	I40E_PHY_TYPE_NOT_SUPPORTED_HIGH_TEMP	= 0xFD,
 	I40E_PHY_TYPE_EMPTY			= 0xFE,
 	I40E_PHY_TYPE_DEFAULT			= 0xFF,
 };
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 628101bb08d4..3d6d6a283327 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6558,12 +6558,26 @@ static void i40e_handle_link_event(struct i40e_pf *pf,
 	 */
 	i40e_link_event(pf);
 
-	/* check for unqualified module, if link is down */
-	if ((status->link_info & I40E_AQ_MEDIA_AVAILABLE) &&
-	    (!(status->an_info & I40E_AQ_QUALIFIED_MODULE)) &&
-	    (!(status->link_info & I40E_AQ_LINK_UP)))
+	/* Check if module meets thermal requirements */
+	if (status->phy_type == I40E_PHY_TYPE_NOT_SUPPORTED_HIGH_TEMP) {
 		dev_err(&pf->pdev->dev,
-			"The driver failed to link because an unqualified module was detected.\n");
+			"Rx/Tx is disabled on this device because the module does not meet thermal requirements.\n");
+		dev_err(&pf->pdev->dev,
+			"Refer to the Intel(R) Ethernet Adapters and Devices User Guide for a list of supported modules.\n");
+	} else {
+		/* check for unqualified module, if link is down, suppress
+		 * the message if link was forced to be down.
+		 */
+		if ((status->link_info & I40E_AQ_MEDIA_AVAILABLE) &&
+		    (!(status->an_info & I40E_AQ_QUALIFIED_MODULE)) &&
+		    (!(status->link_info & I40E_AQ_LINK_UP)) &&
+		    (!(pf->flags & I40E_FLAG_LINK_DOWN_ON_CLOSE_ENABLED))) {
+			dev_err(&pf->pdev->dev,
+				"Rx/Tx is disabled on this device because an unsupported SFP module type was detected.\n");
+			dev_err(&pf->pdev->dev,
+				"Refer to the Intel(R) Ethernet Adapters and Devices User Guide for a list of supported modules.\n");
+		}
+	}
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
index dc6fc8b1bc79..60c892f559b9 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
@@ -1768,6 +1768,7 @@ enum i40e_aq_phy_type {
 	I40E_PHY_TYPE_25GBASE_SR		= 0x21,
 	I40E_PHY_TYPE_25GBASE_LR		= 0x22,
 	I40E_PHY_TYPE_MAX,
+	I40E_PHY_TYPE_NOT_SUPPORTED_HIGH_TEMP	= 0xFD,
 	I40E_PHY_TYPE_EMPTY			= 0xFE,
 	I40E_PHY_TYPE_DEFAULT			= 0xFF,
 };
-- 
2.14.2
