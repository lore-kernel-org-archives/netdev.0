From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] i40e: When in promisc mode apply promisc mode to Tx Traffic as well
Date: Thu, 18 Feb 2016 01:04:11 -0800
Message-ID: <1455786252-71881-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455786252-71881-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:14291 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1425731AbcBRJEl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 04:04:41 -0500
In-Reply-To: <1455786252-71881-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

In MFP mode particularly when we were setting the PF VSI in limited
promiscuous, the HW switch was still mirroring the outgoing packets
from other VSIs (VF/VMdq) onto the PF VSI.

With this new bit set, the mirroring doesn't happen any more and so
we are in limited promiscuous on the PF VSI in MFP which is similar
to defport.

An API check is not required, since this bit is reserved for FW API
version < 1.5

Also update copyright year in file headers.

Change-ID: I9840cb95f11dde733d943cb03ce84f68b9611bc8
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h   | 3 ++-
 drivers/net/ethernet/intel/i40e/i40e_common.c       | 9 ++++++++-
 drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h | 3 ++-
 3 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
index 5699299..bb7ecbb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
  *
  * Intel Ethernet Controller XL710 Family Linux Driver
- * Copyright(c) 2013 - 2014 Intel Corporation.
+ * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -1087,6 +1087,7 @@ struct i40e_aqc_set_vsi_promiscuous_modes {
 #define I40E_AQC_SET_VSI_PROMISC_BROADCAST	0x04
 #define I40E_AQC_SET_VSI_DEFAULT		0x08
 #define I40E_AQC_SET_VSI_PROMISC_VLAN		0x10
+#define I40E_AQC_SET_VSI_PROMISC_TX		0x8000
 	__le16	seid;
 #define I40E_AQC_VSI_PROM_CMD_SEID_MASK		0x3FF
 	__le16	vlan_tag;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 354e36c..f923933 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -1952,12 +1952,19 @@ i40e_status i40e_aq_set_vsi_unicast_promiscuous(struct i40e_hw *hw,
 	i40e_fill_default_direct_cmd_desc(&desc,
 					i40e_aqc_opc_set_vsi_promiscuous_modes);
 
-	if (set)
+	if (set) {
 		flags |= I40E_AQC_SET_VSI_PROMISC_UNICAST;
+		if (((hw->aq.api_maj_ver == 1) && (hw->aq.api_min_ver >= 5)) ||
+		    (hw->aq.api_maj_ver > 1))
+			flags |= I40E_AQC_SET_VSI_PROMISC_TX;
+	}
 
 	cmd->promiscuous_flags = cpu_to_le16(flags);
 
 	cmd->valid_flags = cpu_to_le16(I40E_AQC_SET_VSI_PROMISC_UNICAST);
+	if (((hw->aq.api_maj_ver >= 1) && (hw->aq.api_min_ver >= 5)) ||
+	    (hw->aq.api_maj_ver > 1))
+		cmd->valid_flags |= cpu_to_le16(I40E_AQC_SET_VSI_PROMISC_TX);
 
 	cmd->seid = cpu_to_le16(seid);
 	status = i40e_asq_send_command(hw, &desc, NULL, 0, cmd_details);
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
index ed963bc..815e481 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
  *
  * Intel Ethernet Controller XL710 Family Linux Virtual Function Driver
- * Copyright(c) 2013 - 2014 Intel Corporation.
+ * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -1084,6 +1084,7 @@ struct i40e_aqc_set_vsi_promiscuous_modes {
 #define I40E_AQC_SET_VSI_PROMISC_BROADCAST	0x04
 #define I40E_AQC_SET_VSI_DEFAULT		0x08
 #define I40E_AQC_SET_VSI_PROMISC_VLAN		0x10
+#define I40E_AQC_SET_VSI_PROMISC_TX		0x8000
 	__le16	seid;
 #define I40E_AQC_VSI_PROM_CMD_SEID_MASK		0x3FF
 	__le16	vlan_tag;
-- 
2.5.0
