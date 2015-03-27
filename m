From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/6] i40e/i40evf: implement KR2 support
Date: Fri, 27 Mar 2015 03:02:47 -0700
Message-ID: <1427450573-13945-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1427450573-13945-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Piotr Raczynski <piotr.raczynski@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:13066 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752036AbbC0KDG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Mar 2015 06:03:06 -0400
In-Reply-To: <1427450573-13945-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The new devices need a new device ID some other defines to
handle the new 20G speed for KR2.

Change-ID: I03f717e364afe59657e8c9ce5ffaad856b4b21df
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Piotr Raczynski <piotr.raczynski@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c   |  2 ++
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c  | 16 ++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_main.c     |  4 ++++
 drivers/net/ethernet/intel/i40e/i40e_type.h     |  1 +
 drivers/net/ethernet/intel/i40evf/i40e_common.c |  1 +
 drivers/net/ethernet/intel/i40evf/i40e_type.h   |  3 ++-
 6 files changed, 26 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index d9f1fcb..b7cacde 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -51,6 +51,7 @@ static i40e_status i40e_set_mac_type(struct i40e_hw *hw)
 		case I40E_DEV_ID_QSFP_B:
 		case I40E_DEV_ID_QSFP_C:
 		case I40E_DEV_ID_10G_BASE_T:
+		case I40E_DEV_ID_20G_KR2:
 			hw->mac.type = I40E_MAC_XL710;
 			break;
 		case I40E_DEV_ID_VF:
@@ -841,6 +842,7 @@ static enum i40e_media_type i40e_get_media_type(struct i40e_hw *hw)
 	case I40E_PHY_TYPE_10GBASE_KX4:
 	case I40E_PHY_TYPE_10GBASE_KR:
 	case I40E_PHY_TYPE_40GBASE_KR4:
+	case I40E_PHY_TYPE_20GBASE_KR2:
 		media = I40E_MEDIA_TYPE_BACKPLANE;
 		break;
 	case I40E_PHY_TYPE_SGMII:
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index b7d0aaa..c848b18 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -274,6 +274,12 @@ static void i40e_get_settings_link_up(struct i40e_hw *hw,
 	case I40E_PHY_TYPE_40GBASE_LR4:
 		ecmd->supported = SUPPORTED_40000baseLR4_Full;
 		break;
+	case I40E_PHY_TYPE_20GBASE_KR2:
+		ecmd->supported = SUPPORTED_Autoneg |
+				  SUPPORTED_20000baseKR2_Full;
+		ecmd->advertising = ADVERTISED_Autoneg |
+				    ADVERTISED_20000baseKR2_Full;
+		break;
 	case I40E_PHY_TYPE_10GBASE_KX4:
 		ecmd->supported = SUPPORTED_Autoneg |
 				  SUPPORTED_10000baseKX4_Full;
@@ -353,6 +359,9 @@ static void i40e_get_settings_link_up(struct i40e_hw *hw,
 		/* need a SPEED_40000 in ethtool.h */
 		ethtool_cmd_speed_set(ecmd, 40000);
 		break;
+	case I40E_LINK_SPEED_20GB:
+		ethtool_cmd_speed_set(ecmd, SPEED_20000);
+		break;
 	case I40E_LINK_SPEED_10GB:
 		ethtool_cmd_speed_set(ecmd, SPEED_10000);
 		break;
@@ -418,6 +427,11 @@ static void i40e_get_settings_link_down(struct i40e_hw *hw,
 		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_100MB)
 			ecmd->advertising |= ADVERTISED_100baseT_Full;
 		break;
+	case I40E_DEV_ID_20G_KR2:
+		/* backplane 20G */
+		ecmd->supported = SUPPORTED_20000baseKR2_Full;
+		ecmd->advertising = ADVERTISED_20000baseKR2_Full;
+		break;
 	default:
 		/* all the rest are 10G/1G */
 		ecmd->supported = SUPPORTED_10000baseT_Full |
@@ -633,6 +647,8 @@ static int i40e_set_settings(struct net_device *netdev,
 	    advertise & ADVERTISED_10000baseKX4_Full ||
 	    advertise & ADVERTISED_10000baseKR_Full)
 		config.link_speed |= I40E_LINK_SPEED_10GB;
+	if (advertise & ADVERTISED_20000baseKR2_Full)
+		config.link_speed |= I40E_LINK_SPEED_20GB;
 	if (advertise & ADVERTISED_40000baseKR4_Full ||
 	    advertise & ADVERTISED_40000baseCR4_Full ||
 	    advertise & ADVERTISED_40000baseSR4_Full ||
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index bc87968..048d8ec 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -75,6 +75,7 @@ static const struct pci_device_id i40e_pci_tbl[] = {
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_QSFP_B), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_QSFP_C), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_10G_BASE_T), 0},
+	{PCI_VDEVICE(INTEL, I40E_DEV_ID_20G_KR2), 0},
 	/* required last entry */
 	{0, }
 };
@@ -4639,6 +4640,9 @@ static void i40e_print_link_message(struct i40e_vsi *vsi, bool isup)
 	case I40E_LINK_SPEED_40GB:
 		strlcpy(speed, "40 Gbps", SPEED_SIZE);
 		break;
+	case I40E_LINK_SPEED_20GB:
+		strncpy(speed, "20 Gbps", SPEED_SIZE);
+		break;
 	case I40E_LINK_SPEED_10GB:
 		strlcpy(speed, "10 Gbps", SPEED_SIZE);
 		break;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 83032d2..67c7bc9e9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -44,6 +44,7 @@
 #define I40E_DEV_ID_QSFP_B		0x1584
 #define I40E_DEV_ID_QSFP_C		0x1585
 #define I40E_DEV_ID_10G_BASE_T		0x1586
+#define I40E_DEV_ID_20G_KR2		0x1587
 #define I40E_DEV_ID_VF			0x154C
 #define I40E_DEV_ID_VF_HV		0x1571
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
index f07b9ff..39fcb1d 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -51,6 +51,7 @@ i40e_status i40e_set_mac_type(struct i40e_hw *hw)
 		case I40E_DEV_ID_QSFP_B:
 		case I40E_DEV_ID_QSFP_C:
 		case I40E_DEV_ID_10G_BASE_T:
+		case I40E_DEV_ID_20G_KR2:
 			hw->mac.type = I40E_MAC_XL710;
 			break;
 		case I40E_DEV_ID_VF:
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index eba6e4b..9c79cb6 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -44,7 +44,8 @@
 #define I40E_DEV_ID_QSFP_B		0x1584
 #define I40E_DEV_ID_QSFP_C		0x1585
 #define I40E_DEV_ID_10G_BASE_T		0x1586
-#define I40E_DEV_ID_VF		0x154C
+#define I40E_DEV_ID_20G_KR2		0x1587
+#define I40E_DEV_ID_VF			0x154C
 #define I40E_DEV_ID_VF_HV		0x1571
 
 #define i40e_is_40G_device(d)		((d) == I40E_DEV_ID_QSFP_A  || \
-- 
1.9.3
