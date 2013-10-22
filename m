From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 05/14] i40e: debugfs fixups
Date: Tue, 22 Oct 2013 07:22:28 -0700
Message-ID: <1382451757-9817-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1382451757-9817-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:37103 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753411Ab3JVOWw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Oct 2013 10:22:52 -0400
In-Reply-To: <1382451757-9817-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

debugfs fixes for issues found by coverity.

This issue was identified by the coverity checker, reported by Hannes Frederic
Sowa.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Hannes Frederic Sowa <hannes@stressinduktion.org>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 38 ++++++++++++++++++--------
 1 file changed, 26 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 19e248f..304f39d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -2019,21 +2019,35 @@ static const struct file_operations i40e_dbg_netdev_ops_fops = {
  **/
 void i40e_dbg_pf_init(struct i40e_pf *pf)
 {
-	struct dentry *pfile __attribute__((unused));
+	struct dentry *pfile;
 	const char *name = pci_name(pf->pdev);
+	const struct device *dev = &pf->pdev->dev;
 
 	pf->i40e_dbg_pf = debugfs_create_dir(name, i40e_dbg_root);
-	if (pf->i40e_dbg_pf) {
-		pfile = debugfs_create_file("command", 0600, pf->i40e_dbg_pf,
-					    pf, &i40e_dbg_command_fops);
-		pfile = debugfs_create_file("dump", 0600, pf->i40e_dbg_pf, pf,
-					    &i40e_dbg_dump_fops);
-		pfile = debugfs_create_file("netdev_ops", 0600, pf->i40e_dbg_pf,
-					    pf, &i40e_dbg_netdev_ops_fops);
-	} else {
-		dev_info(&pf->pdev->dev,
-			 "debugfs entry for %s failed\n", name);
-	}
+	if (!pf->i40e_dbg_pf)
+		return;
+
+	pfile = debugfs_create_file("command", 0600, pf->i40e_dbg_pf, pf,
+				    &i40e_dbg_command_fops);
+	if (!pfile)
+		goto create_failed;
+
+	pfile = debugfs_create_file("dump", 0600, pf->i40e_dbg_pf, pf,
+				    &i40e_dbg_dump_fops);
+	if (!pfile)
+		goto create_failed;
+
+	pfile = debugfs_create_file("netdev_ops", 0600, pf->i40e_dbg_pf, pf,
+				    &i40e_dbg_netdev_ops_fops);
+	if (!pfile)
+		goto create_failed;
+
+	return;
+
+create_failed:
+	dev_info(dev, "debugfs dir/file for %s failed\n", name);
+	debugfs_remove_recursive(pf->i40e_dbg_pf);
+	return;
 }
 
 /**
-- 
1.8.3.1
