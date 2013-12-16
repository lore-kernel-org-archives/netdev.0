From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 01/12] i40e: fix up some of the ethtool connection reporting
Date: Mon, 16 Dec 2013 01:38:47 -0800
Message-ID: <1387186738-13666-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1387186738-13666-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Shannon Nelson <shannon.nelson@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10462 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751624Ab3LPJjG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 04:39:06 -0500
In-Reply-To: <1387186738-13666-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Get some more reasonable information reported back out to ethtool
for the different types of connections supported.

Change-Id: I57b153f86b9cdd04ad7cb5bf7d1c45873c196a7a
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 32 +++++++++++++++++++-------
 drivers/net/ethernet/intel/i40e/i40e_type.h    |  4 ++++
 2 files changed, 28 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index fd3e379..eb34375 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -193,32 +193,48 @@ static int i40e_get_settings(struct net_device *netdev,
 		ecmd->supported = SUPPORTED_10000baseKR_Full;
 		ecmd->advertising = ADVERTISED_10000baseKR_Full;
 		break;
-	case I40E_PHY_TYPE_10GBASE_T:
 	default:
-		ecmd->supported = SUPPORTED_10000baseT_Full;
-		ecmd->advertising = ADVERTISED_10000baseT_Full;
+		if (i40e_is_40G_device(hw->device_id)) {
+			ecmd->supported = SUPPORTED_40000baseSR4_Full;
+			ecmd->advertising = ADVERTISED_40000baseSR4_Full;
+		} else {
+			ecmd->supported = SUPPORTED_10000baseT_Full;
+			ecmd->advertising = ADVERTISED_10000baseT_Full;
+		}
 		break;
 	}
 
-	/* for now just say autoneg all the time */
 	ecmd->supported |= SUPPORTED_Autoneg;
+	ecmd->advertising |= ADVERTISED_Autoneg;
+	ecmd->autoneg = ((hw_link_info->an_info & I40E_AQ_AN_COMPLETED) ?
+			  AUTONEG_ENABLE : AUTONEG_DISABLE);
 
-	if (hw->phy.media_type == I40E_MEDIA_TYPE_BACKPLANE) {
+	switch (hw->phy.media_type) {
+	case I40E_MEDIA_TYPE_BACKPLANE:
 		ecmd->supported |= SUPPORTED_Backplane;
 		ecmd->advertising |= ADVERTISED_Backplane;
 		ecmd->port = PORT_NONE;
-	} else if (hw->phy.media_type == I40E_MEDIA_TYPE_BASET) {
+		break;
+	case I40E_MEDIA_TYPE_BASET:
 		ecmd->supported |= SUPPORTED_TP;
 		ecmd->advertising |= ADVERTISED_TP;
 		ecmd->port = PORT_TP;
-	} else if (hw->phy.media_type == I40E_MEDIA_TYPE_DA) {
+		break;
+	case I40E_MEDIA_TYPE_DA:
+	case I40E_MEDIA_TYPE_CX4:
 		ecmd->supported |= SUPPORTED_FIBRE;
 		ecmd->advertising |= ADVERTISED_FIBRE;
 		ecmd->port = PORT_DA;
-	} else {
+		break;
+	case I40E_MEDIA_TYPE_FIBER:
 		ecmd->supported |= SUPPORTED_FIBRE;
 		ecmd->advertising |= ADVERTISED_FIBRE;
 		ecmd->port = PORT_FIBRE;
+		break;
+	case I40E_MEDIA_TYPE_UNKNOWN:
+	default:
+		ecmd->port = PORT_OTHER;
+		break;
 	}
 
 	ecmd->transceiver = XCVR_EXTERNAL;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 8ae6445..72a6028 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -49,6 +49,10 @@
 #define I40E_VF_DEVICE_ID		0x154C
 #define I40E_VF_HV_DEVICE_ID		0x1571
 
+#define i40e_is_40G_device(d)		((d) == I40E_QSFP_A_DEVICE_ID  || \
+					 (d) == I40E_QSFP_B_DEVICE_ID  || \
+					 (d) == I40E_QSFP_C_DEVICE_ID)
+
 #define I40E_FW_API_VERSION_MAJOR  0x0001
 #define I40E_FW_API_VERSION_MINOR  0x0000
 
-- 
1.8.3.1
