From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 04/15] i40e: remove BUG_ON from feature string building
Date: Wed, 25 Nov 2015 10:21:08 -0800
Message-ID: <1448475679-57194-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1448475679-57194-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:36304 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751871AbbKYSVX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Nov 2015 13:21:23 -0500
In-Reply-To: <1448475679-57194-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

There's really no reason to kill the kernel thread just because of a
little info string. This reworks the code to use snprintf's limiting to
assure that the string is never too long, and WARN_ON to still put out
a warning that we might want to look at the feature list length.

Prompted by a recent Linus diatribe.

Change-ID: If52ba5ca1c2344d8bf454a31bbb805eb5d2c5802
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 34 +++++++++++++++--------------
 1 file changed, 18 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 7715c54..7a4595a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -10111,10 +10111,12 @@ static int i40e_setup_pf_filter_control(struct i40e_pf *pf)
 }
 
 #define INFO_STRING_LEN 255
+#define REMAIN(__x) (INFO_STRING_LEN - (__x))
 static void i40e_print_features(struct i40e_pf *pf)
 {
 	struct i40e_hw *hw = &pf->hw;
 	char *buf, *string;
+	int i = 0;
 
 	string = kzalloc(INFO_STRING_LEN, GFP_KERNEL);
 	if (!string) {
@@ -10124,42 +10126,42 @@ static void i40e_print_features(struct i40e_pf *pf)
 
 	buf = string;
 
-	buf += sprintf(string, "Features: PF-id[%d] ", hw->pf_id);
+	i += snprintf(&buf[i], REMAIN(i), "Features: PF-id[%d] ", hw->pf_id);
 #ifdef CONFIG_PCI_IOV
-	buf += sprintf(buf, "VFs: %d ", pf->num_req_vfs);
+	i += snprintf(&buf[i], REMAIN(i), "VFs: %d ", pf->num_req_vfs);
 #endif
-	buf += sprintf(buf, "VSIs: %d QP: %d RX: %s ",
-		       pf->hw.func_caps.num_vsis,
-		       pf->vsi[pf->lan_vsi]->num_queue_pairs,
-		       pf->flags & I40E_FLAG_RX_PS_ENABLED ? "PS" : "1BUF");
+	i += snprintf(&buf[i], REMAIN(i), "VSIs: %d QP: %d RX: %s ",
+		      pf->hw.func_caps.num_vsis,
+		      pf->vsi[pf->lan_vsi]->num_queue_pairs,
+		      pf->flags & I40E_FLAG_RX_PS_ENABLED ? "PS" : "1BUF");
 
 	if (pf->flags & I40E_FLAG_RSS_ENABLED)
-		buf += sprintf(buf, "RSS ");
+		i += snprintf(&buf[i], REMAIN(i), "RSS ");
 	if (pf->flags & I40E_FLAG_FD_ATR_ENABLED)
-		buf += sprintf(buf, "FD_ATR ");
+		i += snprintf(&buf[i], REMAIN(i), "FD_ATR ");
 	if (pf->flags & I40E_FLAG_FD_SB_ENABLED) {
-		buf += sprintf(buf, "FD_SB ");
-		buf += sprintf(buf, "NTUPLE ");
+		i += snprintf(&buf[i], REMAIN(i), "FD_SB ");
+		i += snprintf(&buf[i], REMAIN(i), "NTUPLE ");
 	}
 	if (pf->flags & I40E_FLAG_DCB_CAPABLE)
-		buf += sprintf(buf, "DCB ");
+		i += snprintf(&buf[i], REMAIN(i), "DCB ");
 #if IS_ENABLED(CONFIG_VXLAN)
-	buf += sprintf(buf, "VxLAN ");
+	i += snprintf(&buf[i], REMAIN(i), "VxLAN ");
 #endif
 	if (pf->flags & I40E_FLAG_PTP)
-		buf += sprintf(buf, "PTP ");
+		i += snprintf(&buf[i], REMAIN(i), "PTP ");
 #ifdef I40E_FCOE
 	if (pf->flags & I40E_FLAG_FCOE_ENABLED)
-		buf += sprintf(buf, "FCOE ");
+		i += snprintf(&buf[i], REMAIN(i), "FCOE ");
 #endif
 	if (pf->flags & I40E_FLAG_VEB_MODE_ENABLED)
-		buf += sprintf(buf, "VEB ");
+		i += snprintf(&buf[i], REMAIN(i), "VEPA ");
 	else
 		buf += sprintf(buf, "VEPA ");
 
-	BUG_ON(buf > (string + INFO_STRING_LEN));
 	dev_info(&pf->pdev->dev, "%s\n", string);
 	kfree(string);
+	WARN_ON(i > INFO_STRING_LEN);
 }
 
 /**
-- 
2.5.0
