From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/4] i40e: Fix configure TCs after initial DCB disable
Date: Thu, 27 Oct 2016 14:27:55 -0700
Message-ID: <1477603677-39957-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1477603677-39957-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: David Ertman <david.m.ertman@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:58108 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1032333AbcJ0V2A (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Oct 2016 17:28:00 -0400
In-Reply-To: <1477603677-39957-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ertman <david.m.ertman@intel.com>

in commit a036244c068612a43fa8c0f33a0eb4daa4d8dba0 a fix
was put into place to avoid a kernel panic when a non-
supported traffic class configuration was put into place
and then lldp was enabled/disabled on the link partner
switch.  This fix caused it to be necessary to
unload/reload the driver to reenable DCB once a supported
TC config was in place.

The root cause of the original panic was that the function
i40e_pf_get_default_tc was allowing for a default TC other
than TC 0, and only TC 0 is supported as a default.

This patch removes the get_default_tc function and replaces
it with a #define since there is only one TC supported as
a default.

Change-Id: I448371974e946386d0a7718d73668b450b7c72ef
Signed-off-by: Dave Ertman <david.m.ertman@intel.com>
Tested-by: Ronald Bynoe <ronald.j.bynoe@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |  1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c | 31 ++++-------------------------
 2 files changed, 5 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 2030d7c..6d61e44 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -92,6 +92,7 @@
 #define I40E_AQ_LEN			256
 #define I40E_AQ_WORK_LIMIT		66 /* max number of VFs + a little */
 #define I40E_MAX_USER_PRIORITY		8
+#define I40E_DEFAULT_TRAFFIC_CLASS	BIT(0)
 #define I40E_DEFAULT_MSG_ENABLE		4
 #define I40E_QUEUE_WAIT_RETRY_LIMIT	10
 #define I40E_INT_NAME_STR_LEN		(IFNAMSIZ + 16)
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index ac1faee..050d005 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4641,29 +4641,6 @@ static u8 i40e_pf_get_num_tc(struct i40e_pf *pf)
 }
 
 /**
- * i40e_pf_get_default_tc - Get bitmap for first enabled TC
- * @pf: PF being queried
- *
- * Return a bitmap for first enabled traffic class for this PF.
- **/
-static u8 i40e_pf_get_default_tc(struct i40e_pf *pf)
-{
-	u8 enabled_tc = pf->hw.func_caps.enabled_tcmap;
-	u8 i = 0;
-
-	if (!enabled_tc)
-		return 0x1; /* TC0 */
-
-	/* Find the first enabled TC */
-	for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++) {
-		if (enabled_tc & BIT(i))
-			break;
-	}
-
-	return BIT(i);
-}
-
-/**
  * i40e_pf_get_pf_tc_map - Get bitmap for enabled traffic classes
  * @pf: PF being queried
  *
@@ -4673,7 +4650,7 @@ static u8 i40e_pf_get_tc_map(struct i40e_pf *pf)
 {
 	/* If DCB is not enabled for this PF then just return default TC */
 	if (!(pf->flags & I40E_FLAG_DCB_ENABLED))
-		return i40e_pf_get_default_tc(pf);
+		return I40E_DEFAULT_TRAFFIC_CLASS;
 
 	/* SFP mode we want PF to be enabled for all TCs */
 	if (!(pf->flags & I40E_FLAG_MFP_ENABLED))
@@ -4683,7 +4660,7 @@ static u8 i40e_pf_get_tc_map(struct i40e_pf *pf)
 	if (pf->hw.func_caps.iscsi)
 		return i40e_get_iscsi_tc_map(pf);
 	else
-		return i40e_pf_get_default_tc(pf);
+		return I40E_DEFAULT_TRAFFIC_CLASS;
 }
 
 /**
@@ -5029,7 +5006,7 @@ static void i40e_dcb_reconfigure(struct i40e_pf *pf)
 		if (v == pf->lan_vsi)
 			tc_map = i40e_pf_get_tc_map(pf);
 		else
-			tc_map = i40e_pf_get_default_tc(pf);
+			tc_map = I40E_DEFAULT_TRAFFIC_CLASS;
 #ifdef I40E_FCOE
 		if (pf->vsi[v]->type == I40E_VSI_FCOE)
 			tc_map = i40e_get_fcoe_tc_map(pf);
@@ -5717,7 +5694,7 @@ static int i40e_handle_lldp_event(struct i40e_pf *pf,
 	u8 type;
 
 	/* Not DCB capable or capability disabled */
-	if (!(pf->flags & I40E_FLAG_DCB_ENABLED))
+	if (!(pf->flags & I40E_FLAG_DCB_CAPABLE))
 		return ret;
 
 	/* Ignore if event is not for Nearest Bridge */
-- 
2.7.4
