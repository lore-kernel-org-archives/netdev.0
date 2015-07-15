From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 03/16] i40e/i40evf: Update Flex-10 related device/function capabilities
Date: Tue, 14 Jul 2015 18:30:27 -0700
Message-ID: <1436923840-24455-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1436923840-24455-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Pawel Orlowski <pawel.orlowski@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:22319 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752066AbbGOBap (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jul 2015 21:30:45 -0400
In-Reply-To: <1436923840-24455-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pawel Orlowski <pawel.orlowski@intel.com>

The Flex10 device/function capability has been upgraded to include
information needed to support Flex-10 configurations. This patch adds new
fields to the i40e_hw_capabilities structure and updates
i40e_parse_discover_capabilities functions to extract them from the AQ
response. Naming convention has changed to use flex10 mode instead of
existing mfp_mode_1.

Change-ID: I305dd888866985a30293acb3fb14fa43ca6b79ea
Signed-off-by: Pawel Orlowski <pawel.orlowski@intel.com>
Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 24 +++++++++++++++++++-----
 drivers/net/ethernet/intel/i40e/i40e_main.c   |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_type.h   | 12 +++++++++++-
 drivers/net/ethernet/intel/i40evf/i40e_type.h | 12 +++++++++++-
 4 files changed, 42 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 0bae22d..0703222 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -2391,7 +2391,7 @@ i40e_aq_erase_nvm_exit:
 #define I40E_DEV_FUNC_CAP_MSIX_VF	0x44
 #define I40E_DEV_FUNC_CAP_FLOW_DIRECTOR	0x45
 #define I40E_DEV_FUNC_CAP_IEEE_1588	0x46
-#define I40E_DEV_FUNC_CAP_MFP_MODE_1	0xF1
+#define I40E_DEV_FUNC_CAP_FLEX10	0xF1
 #define I40E_DEV_FUNC_CAP_CEM		0xF2
 #define I40E_DEV_FUNC_CAP_IWARP		0x51
 #define I40E_DEV_FUNC_CAP_LED		0x61
@@ -2416,6 +2416,7 @@ static void i40e_parse_discover_capabilities(struct i40e_hw *hw, void *buff,
 	u32 valid_functions, num_functions;
 	u32 number, logical_id, phys_id;
 	struct i40e_hw_capabilities *p;
+	u8 major_rev;
 	u32 i = 0;
 	u16 id;
 
@@ -2433,6 +2434,7 @@ static void i40e_parse_discover_capabilities(struct i40e_hw *hw, void *buff,
 		number = le32_to_cpu(cap->number);
 		logical_id = le32_to_cpu(cap->logical_id);
 		phys_id = le32_to_cpu(cap->phys_id);
+		major_rev = cap->major_rev;
 
 		switch (id) {
 		case I40E_DEV_FUNC_CAP_SWITCH_MODE:
@@ -2507,9 +2509,21 @@ static void i40e_parse_discover_capabilities(struct i40e_hw *hw, void *buff,
 		case I40E_DEV_FUNC_CAP_MSIX_VF:
 			p->num_msix_vectors_vf = number;
 			break;
-		case I40E_DEV_FUNC_CAP_MFP_MODE_1:
-			if (number == 1)
-				p->mfp_mode_1 = true;
+		case I40E_DEV_FUNC_CAP_FLEX10:
+			if (major_rev == 1) {
+				if (number == 1) {
+					p->flex10_enable = true;
+					p->flex10_capable = true;
+				}
+			} else {
+				/* Capability revision >= 2 */
+				if (number & 1)
+					p->flex10_enable = true;
+				if (number & 2)
+					p->flex10_capable = true;
+			}
+			p->flex10_mode = logical_id;
+			p->flex10_status = phys_id;
 			break;
 		case I40E_DEV_FUNC_CAP_CEM:
 			if (number == 1)
@@ -2557,7 +2571,7 @@ static void i40e_parse_discover_capabilities(struct i40e_hw *hw, void *buff,
 	/* Software override ensuring FCoE is disabled if npar or mfp
 	 * mode because it is not supported in these modes.
 	 */
-	if (p->npar_enable || p->mfp_mode_1)
+	if (p->npar_enable || p->flex10_enable)
 		p->fcoe = false;
 
 	/* count the enabled ports (aka the "not disabled" ports) */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index b5fc654..ed6fc52 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7685,7 +7685,7 @@ static int i40e_sw_init(struct i40e_pf *pf)
 	}
 
 	/* MFP mode enabled */
-	if (pf->hw.func_caps.npar_enable || pf->hw.func_caps.mfp_mode_1) {
+	if (pf->hw.func_caps.npar_enable || pf->hw.func_caps.flex10_enable) {
 		pf->flags |= I40E_FLAG_MFP_ENABLED;
 		dev_info(&pf->pdev->dev, "MFP mode Enabled\n");
 		if (i40e_get_npar_bw_setting(pf))
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 350c5ee..220371e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -213,7 +213,17 @@ struct i40e_hw_capabilities {
 	bool dcb;
 	bool fcoe;
 	bool iscsi; /* Indicates iSCSI enabled */
-	bool mfp_mode_1;
+	bool flex10_enable;
+	bool flex10_capable;
+	u32  flex10_mode;
+#define I40E_FLEX10_MODE_UNKNOWN	0x0
+#define I40E_FLEX10_MODE_DCC		0x1
+#define I40E_FLEX10_MODE_DCI		0x2
+
+	u32 flex10_status;
+#define I40E_FLEX10_STATUS_DCC_ERROR	0x1
+#define I40E_FLEX10_STATUS_VC_MODE	0x2
+
 	bool mgmt_cem;
 	bool ieee_1588;
 	bool iwarp;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 068813d..3969c65 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -213,7 +213,17 @@ struct i40e_hw_capabilities {
 	bool dcb;
 	bool fcoe;
 	bool iscsi; /* Indicates iSCSI enabled */
-	bool mfp_mode_1;
+	bool flex10_enable;
+	bool flex10_capable;
+	u32  flex10_mode;
+#define I40E_FLEX10_MODE_UNKNOWN	0x0
+#define I40E_FLEX10_MODE_DCC		0x1
+#define I40E_FLEX10_MODE_DCI		0x2
+
+	u32 flex10_status;
+#define I40E_FLEX10_STATUS_DCC_ERROR	0x1
+#define I40E_FLEX10_STATUS_VC_MODE	0x2
+
 	bool mgmt_cem;
 	bool ieee_1588;
 	bool iwarp;
-- 
2.4.3
