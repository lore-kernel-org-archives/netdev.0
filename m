From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2] i40e: Fix i40e_print_features() VEB mode output
Date: Thu,  3 Dec 2015 04:20:57 -0800
Message-ID: <1449145257-110262-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	sergei.shtylyov@cogentembedded.com, shannon.nelson@intel.com
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:57377 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755277AbbLCMVA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 07:21:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Commit 7fd89545f337 ("i40e: remove BUG_ON from feature string building")
added defective output when I40E_FLAG_VEB_MODE_ENABLED was set in
function i40e_print_features.

Fix it.

Miscellanea:

- Remove unnecessary string variable
- Add space before not after fixed strings
- Use kmalloc not kzalloc
- Don't initialize i to 0, use result of first snprintf

Reported-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Signed-off-by: Joe Perches <joe@perches.com>
---
v2: fixed patch conflicts when trying to apply to my next-queue tree
    (dev-queue branch), also fixed "Noticed-by" to the more acceptable
    "Reported-by"

 drivers/net/ethernet/intel/i40e/i40e_main.c | 42 +++++++++++++----------------
 1 file changed, 19 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 70a61bc..ad8cc14 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -10369,52 +10369,48 @@ static int i40e_setup_pf_filter_control(struct i40e_pf *pf)
 static void i40e_print_features(struct i40e_pf *pf)
 {
 	struct i40e_hw *hw = &pf->hw;
-	char *buf, *string;
-	int i = 0;
+	char *buf;
+	int i;
 
-	string = kzalloc(INFO_STRING_LEN, GFP_KERNEL);
-	if (!string) {
-		dev_err(&pf->pdev->dev, "Features string allocation failed\n");
+	buf = kmalloc(INFO_STRING_LEN, GFP_KERNEL);
+	if (!buf)
 		return;
-	}
-
-	buf = string;
 
-	i += snprintf(&buf[i], REMAIN(i), "Features: PF-id[%d] ", hw->pf_id);
+	i = snprintf(buf, INFO_STRING_LEN, "Features: PF-id[%d]", hw->pf_id);
 #ifdef CONFIG_PCI_IOV
-	i += snprintf(&buf[i], REMAIN(i), "VFs: %d ", pf->num_req_vfs);
+	i += snprintf(&buf[i], REMAIN(i), " VFs: %d", pf->num_req_vfs);
 #endif
-	i += snprintf(&buf[i], REMAIN(i), "VSIs: %d QP: %d RX: %s ",
+	i += snprintf(&buf[i], REMAIN(i), " VSIs: %d QP: %d RX: %s",
 		      pf->hw.func_caps.num_vsis,
 		      pf->vsi[pf->lan_vsi]->num_queue_pairs,
 		      pf->flags & I40E_FLAG_RX_PS_ENABLED ? "PS" : "1BUF");
 
 	if (pf->flags & I40E_FLAG_RSS_ENABLED)
-		i += snprintf(&buf[i], REMAIN(i), "RSS ");
+		i += snprintf(&buf[i], REMAIN(i), " RSS");
 	if (pf->flags & I40E_FLAG_FD_ATR_ENABLED)
-		i += snprintf(&buf[i], REMAIN(i), "FD_ATR ");
+		i += snprintf(&buf[i], REMAIN(i), " FD_ATR");
 	if (pf->flags & I40E_FLAG_FD_SB_ENABLED) {
-		i += snprintf(&buf[i], REMAIN(i), "FD_SB ");
-		i += snprintf(&buf[i], REMAIN(i), "NTUPLE ");
+		i += snprintf(&buf[i], REMAIN(i), " FD_SB");
+		i += snprintf(&buf[i], REMAIN(i), " NTUPLE");
 	}
 	if (pf->flags & I40E_FLAG_DCB_CAPABLE)
-		i += snprintf(&buf[i], REMAIN(i), "DCB ");
+		i += snprintf(&buf[i], REMAIN(i), " DCB");
 #if IS_ENABLED(CONFIG_VXLAN)
-	i += snprintf(&buf[i], REMAIN(i), "VxLAN ");
+	i += snprintf(&buf[i], REMAIN(i), " VxLAN");
 #endif
 	if (pf->flags & I40E_FLAG_PTP)
-		i += snprintf(&buf[i], REMAIN(i), "PTP ");
+		i += snprintf(&buf[i], REMAIN(i), " PTP");
 #ifdef I40E_FCOE
 	if (pf->flags & I40E_FLAG_FCOE_ENABLED)
-		i += snprintf(&buf[i], REMAIN(i), "FCOE ");
+		i += snprintf(&buf[i], REMAIN(i), " FCOE");
 #endif
 	if (pf->flags & I40E_FLAG_VEB_MODE_ENABLED)
-		i += snprintf(&buf[i], REMAIN(i), "VEPA ");
+		i += snprintf(&buf[i], REMAIN(i), " VEB");
 	else
-		buf += sprintf(buf, "VEPA ");
+		i += snprintf(&buf[i], REMAIN(i), " VEPA");
 
-	dev_info(&pf->pdev->dev, "%s\n", string);
-	kfree(string);
+	dev_info(&pf->pdev->dev, "%s\n", buf);
+	kfree(buf);
 	WARN_ON(i > INFO_STRING_LEN);
 }
 
-- 
2.5.0
