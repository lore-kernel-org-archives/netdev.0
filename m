From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/14] i40e: get media type during link info
Date: Fri,  6 Dec 2013 18:17:12 -0800
Message-ID: <1386382643-29055-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386382643-29055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Shannon Nelson <shannon.nelson@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:64593 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754039Ab3LGCR2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 21:17:28 -0500
In-Reply-To: <1386382643-29055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Set the media type in the hardware structure, based
on the external connection type.

Add Direct Attach to the type of media reported by ethtool.

Change-Id: I4ad2f5bf882766d6e737fac4477abf049491b3b3
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c  | 47 ++++++++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c |  4 +++
 drivers/net/ethernet/intel/i40e/i40e_type.h    |  1 +
 3 files changed, 52 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 9e868ea..2cc01c2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -267,6 +267,52 @@ i40e_status i40e_validate_mac_addr(u8 *mac_addr)
 }
 
 /**
+ * i40e_get_media_type - Gets media type
+ * @hw: pointer to the hardware structure
+ **/
+static enum i40e_media_type i40e_get_media_type(struct i40e_hw *hw)
+{
+	enum i40e_media_type media;
+
+	switch (hw->phy.link_info.phy_type) {
+	case I40E_PHY_TYPE_10GBASE_SR:
+	case I40E_PHY_TYPE_10GBASE_LR:
+	case I40E_PHY_TYPE_40GBASE_SR4:
+	case I40E_PHY_TYPE_40GBASE_LR4:
+		media = I40E_MEDIA_TYPE_FIBER;
+		break;
+	case I40E_PHY_TYPE_100BASE_TX:
+	case I40E_PHY_TYPE_1000BASE_T:
+	case I40E_PHY_TYPE_10GBASE_T:
+		media = I40E_MEDIA_TYPE_BASET;
+		break;
+	case I40E_PHY_TYPE_10GBASE_CR1_CU:
+	case I40E_PHY_TYPE_40GBASE_CR4_CU:
+	case I40E_PHY_TYPE_10GBASE_CR1:
+	case I40E_PHY_TYPE_40GBASE_CR4:
+	case I40E_PHY_TYPE_10GBASE_SFPP_CU:
+		media = I40E_MEDIA_TYPE_DA;
+		break;
+	case I40E_PHY_TYPE_1000BASE_KX:
+	case I40E_PHY_TYPE_10GBASE_KX4:
+	case I40E_PHY_TYPE_10GBASE_KR:
+	case I40E_PHY_TYPE_40GBASE_KR4:
+		media = I40E_MEDIA_TYPE_BACKPLANE;
+		break;
+	case I40E_PHY_TYPE_SGMII:
+	case I40E_PHY_TYPE_XAUI:
+	case I40E_PHY_TYPE_XFI:
+	case I40E_PHY_TYPE_XLAUI:
+	case I40E_PHY_TYPE_XLPPI:
+	default:
+		media = I40E_MEDIA_TYPE_UNKNOWN;
+		break;
+	}
+
+	return media;
+}
+
+/**
  * i40e_pf_reset - Reset the PF
  * @hw: pointer to the hardware structure
  *
@@ -499,6 +545,7 @@ i40e_status i40e_aq_get_link_info(struct i40e_hw *hw,
 
 	/* update link status */
 	hw_link_info->phy_type = (enum i40e_aq_phy_type)resp->phy_type;
+	hw->phy.media_type = i40e_get_media_type(hw);
 	hw_link_info->link_speed = (enum i40e_aq_link_speed)resp->link_speed;
 	hw_link_info->link_info = resp->link_info;
 	hw_link_info->an_info = resp->an_info;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 8f5d538..7fb669b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -211,6 +211,10 @@ static int i40e_get_settings(struct net_device *netdev,
 		ecmd->supported |= SUPPORTED_TP;
 		ecmd->advertising |= ADVERTISED_TP;
 		ecmd->port = PORT_TP;
+	} else if (hw->phy.media_type == I40E_MEDIA_TYPE_DA) {
+		ecmd->supported |= SUPPORTED_FIBRE;
+		ecmd->advertising |= ADVERTISED_FIBRE;
+		ecmd->port = PORT_DA;
 	} else {
 		ecmd->supported |= SUPPORTED_FIBRE;
 		ecmd->advertising |= ADVERTISED_FIBRE;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index fdad028..88b37e0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -134,6 +134,7 @@ enum i40e_media_type {
 	I40E_MEDIA_TYPE_BASET,
 	I40E_MEDIA_TYPE_BACKPLANE,
 	I40E_MEDIA_TYPE_CX4,
+	I40E_MEDIA_TYPE_DA,
 	I40E_MEDIA_TYPE_VIRTUAL
 };
 
-- 
1.8.3.1
