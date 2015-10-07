From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 16/18] i40e: Additional checks for CEE APP priority validity
Date: Wed,  7 Oct 2015 15:47:10 -0700
Message-ID: <1444258032-41476-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:27522 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753650AbbJGWrY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2015 18:47:24 -0400
In-Reply-To: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

The firmware has added additional status information to allow software
to determine if the APP priority for FCoE/iSCSI/FIP is valid or not in
CEE DCBX mode.

This patch adds to support those additional checks and will only add
applications to the software table that have oper and sync bits set
without any error.

Change-ID: I0a76c52427dadf97d4dba4538a3068d05e4eb56b
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_dcb.c | 48 ++++++++++++++++++++----------
 1 file changed, 33 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_dcb.c b/drivers/net/ethernet/intel/i40e/i40e_dcb.c
index 90de46a..9aee35d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_dcb.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_dcb.c
@@ -531,37 +531,55 @@ static void i40e_cee_to_dcb_config(
 	dcbcfg->pfc.pfcenable = cee_cfg->oper_pfc_en;
 	dcbcfg->pfc.pfccap = I40E_MAX_TRAFFIC_CLASS;
 
-	status = (tlv_status & I40E_AQC_CEE_APP_STATUS_MASK) >>
-		  I40E_AQC_CEE_APP_STATUS_SHIFT;
+	i = 0;
+	status = (tlv_status & I40E_AQC_CEE_FCOE_STATUS_MASK) >>
+		  I40E_AQC_CEE_FCOE_STATUS_SHIFT;
 	err = (status & I40E_TLV_STATUS_ERR) ? 1 : 0;
 	sync = (status & I40E_TLV_STATUS_SYNC) ? 1 : 0;
 	oper = (status & I40E_TLV_STATUS_OPER) ? 1 : 0;
-	/* Add APPs if Error is False and Oper/Sync is True */
+	/* Add FCoE APP if Error is False and Oper/Sync is True */
 	if (!err && sync && oper) {
-		/* CEE operating configuration supports FCoE/iSCSI/FIP only */
-		dcbcfg->numapps = I40E_CEE_OPER_MAX_APPS;
-
 		/* FCoE APP */
-		dcbcfg->app[0].priority =
+		dcbcfg->app[i].priority =
 			(app_prio & I40E_AQC_CEE_APP_FCOE_MASK) >>
 			 I40E_AQC_CEE_APP_FCOE_SHIFT;
-		dcbcfg->app[0].selector = I40E_APP_SEL_ETHTYPE;
-		dcbcfg->app[0].protocolid = I40E_APP_PROTOID_FCOE;
+		dcbcfg->app[i].selector = I40E_APP_SEL_ETHTYPE;
+		dcbcfg->app[i].protocolid = I40E_APP_PROTOID_FCOE;
+		i++;
+	}
 
+	status = (tlv_status & I40E_AQC_CEE_ISCSI_STATUS_MASK) >>
+		  I40E_AQC_CEE_ISCSI_STATUS_SHIFT;
+	err = (status & I40E_TLV_STATUS_ERR) ? 1 : 0;
+	sync = (status & I40E_TLV_STATUS_SYNC) ? 1 : 0;
+	oper = (status & I40E_TLV_STATUS_OPER) ? 1 : 0;
+	/* Add iSCSI APP if Error is False and Oper/Sync is True */
+	if (!err && sync && oper) {
 		/* iSCSI APP */
-		dcbcfg->app[1].priority =
+		dcbcfg->app[i].priority =
 			(app_prio & I40E_AQC_CEE_APP_ISCSI_MASK) >>
 			 I40E_AQC_CEE_APP_ISCSI_SHIFT;
-		dcbcfg->app[1].selector = I40E_APP_SEL_TCPIP;
-		dcbcfg->app[1].protocolid = I40E_APP_PROTOID_ISCSI;
+		dcbcfg->app[i].selector = I40E_APP_SEL_TCPIP;
+		dcbcfg->app[i].protocolid = I40E_APP_PROTOID_ISCSI;
+		i++;
+	}
 
+	status = (tlv_status & I40E_AQC_CEE_FIP_STATUS_MASK) >>
+		  I40E_AQC_CEE_FIP_STATUS_SHIFT;
+	err = (status & I40E_TLV_STATUS_ERR) ? 1 : 0;
+	sync = (status & I40E_TLV_STATUS_SYNC) ? 1 : 0;
+	oper = (status & I40E_TLV_STATUS_OPER) ? 1 : 0;
+	/* Add FIP APP if Error is False and Oper/Sync is True */
+	if (!err && sync && oper) {
 		/* FIP APP */
-		dcbcfg->app[2].priority =
+		dcbcfg->app[i].priority =
 			(app_prio & I40E_AQC_CEE_APP_FIP_MASK) >>
 			 I40E_AQC_CEE_APP_FIP_SHIFT;
-		dcbcfg->app[2].selector = I40E_APP_SEL_ETHTYPE;
-		dcbcfg->app[2].protocolid = I40E_APP_PROTOID_FIP;
+		dcbcfg->app[i].selector = I40E_APP_SEL_ETHTYPE;
+		dcbcfg->app[i].protocolid = I40E_APP_PROTOID_FIP;
+		i++;
 	}
+	dcbcfg->numapps = i;
 }
 
 /**
-- 
2.4.3
