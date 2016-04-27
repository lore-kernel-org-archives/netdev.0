From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 08/14] i40e: Add device capability which defines if update is available
Date: Wed, 27 Apr 2016 13:15:47 -0700
Message-ID: <1461788153-12869-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461788153-12869-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Michal Kosiarz <michal.kosiarz@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:1226 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753358AbcD0UQa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2016 16:16:30 -0400
In-Reply-To: <1461788153-12869-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kosiarz <michal.kosiarz@intel.com>

Add device capability which defines if update is available and security
check is needed during update process.

Change-ID: I380787c878275e1df18b39198df3ee3666342282
Signed-off-by: Michal Kosiarz <michal.kosiarz@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h   | 1 +
 drivers/net/ethernet/intel/i40e/i40e_common.c       | 6 ++++++
 drivers/net/ethernet/intel/i40e/i40e_type.h         | 5 +++++
 drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h | 1 +
 drivers/net/ethernet/intel/i40evf/i40e_type.h       | 5 +++++
 5 files changed, 18 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
index 8d5c65a..5179b3b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
@@ -429,6 +429,7 @@ struct i40e_aqc_list_capabilities_element_resp {
 #define I40E_AQ_CAP_ID_SDP		0x0062
 #define I40E_AQ_CAP_ID_MDIO		0x0063
 #define I40E_AQ_CAP_ID_WSR_PROT		0x0064
+#define I40E_AQ_CAP_ID_NVM_MGMT		0x0080
 #define I40E_AQ_CAP_ID_FLEX10		0x00F1
 #define I40E_AQ_CAP_ID_CEM		0x00F2
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index f3c1d88..34e86f5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -3138,6 +3138,12 @@ static void i40e_parse_discover_capabilities(struct i40e_hw *hw, void *buff,
 			p->wr_csr_prot = (u64)number;
 			p->wr_csr_prot |= (u64)logical_id << 32;
 			break;
+		case I40E_AQ_CAP_ID_NVM_MGMT:
+			if (number & I40E_NVM_MGMT_SEC_REV_DISABLED)
+				p->sec_rev_disabled = true;
+			if (number & I40E_NVM_MGMT_UPDATE_DISABLED)
+				p->update_disabled = true;
+			break;
 		default:
 			break;
 		}
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index bb57cd9..8aa14aa 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -275,6 +275,11 @@ struct i40e_hw_capabilities {
 #define I40E_FLEX10_STATUS_DCC_ERROR	0x1
 #define I40E_FLEX10_STATUS_VC_MODE	0x2
 
+	bool sec_rev_disabled;
+	bool update_disabled;
+#define I40E_NVM_MGMT_SEC_REV_DISABLED	0x1
+#define I40E_NVM_MGMT_UPDATE_DISABLED	0x2
+
 	bool mgmt_cem;
 	bool ieee_1588;
 	bool iwarp;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
index aad8d62..1bcb8cf 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
@@ -426,6 +426,7 @@ struct i40e_aqc_list_capabilities_element_resp {
 #define I40E_AQ_CAP_ID_SDP		0x0062
 #define I40E_AQ_CAP_ID_MDIO		0x0063
 #define I40E_AQ_CAP_ID_WSR_PROT		0x0064
+#define I40E_AQ_CAP_ID_NVM_MGMT		0x0080
 #define I40E_AQ_CAP_ID_FLEX10		0x00F1
 #define I40E_AQ_CAP_ID_CEM		0x00F2
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index b720713..bfc97c2 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -258,6 +258,11 @@ struct i40e_hw_capabilities {
 #define I40E_FLEX10_STATUS_DCC_ERROR	0x1
 #define I40E_FLEX10_STATUS_VC_MODE	0x2
 
+	bool sec_rev_disabled;
+	bool update_disabled;
+#define I40E_NVM_MGMT_SEC_REV_DISABLED	0x1
+#define I40E_NVM_MGMT_UPDATE_DISABLED	0x2
+
 	bool mgmt_cem;
 	bool ieee_1588;
 	bool iwarp;
-- 
2.5.5
