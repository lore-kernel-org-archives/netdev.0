From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH net-26 3/5] cxgb4vf: Behave properly when CONFIG_DEBUG_FS isn't defined ...
Date: Fri, 11 Feb 2011 17:00:21 -0800
Message-ID: <1297472423-15672-4-git-send-email-leedom@chelsio.com>
References: <1297472423-15672-1-git-send-email-leedom@chelsio.com>
Cc: davem@davemloft.net, Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:7495 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757830Ab1BLBA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 20:00:27 -0500
In-Reply-To: <1297472423-15672-1-git-send-email-leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When CONFIG_DEBUG_FS we get "ERR_PTR()"s back from the debugfs routines
instead of NULL.  Use the right predicates to check for this.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb4vf/cxgb4vf_main.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
index b12c169..daac6ed 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -2064,7 +2064,7 @@ static int __devinit setup_debugfs(struct adapter *adapter)
 {
 	int i;
 
-	BUG_ON(adapter->debugfs_root == NULL);
+	BUG_ON(IS_ERR_OR_NULL(adapter->debugfs_root));
 
 	/*
 	 * Debugfs support is best effort.
@@ -2085,7 +2085,7 @@ static int __devinit setup_debugfs(struct adapter *adapter)
  */
 static void cleanup_debugfs(struct adapter *adapter)
 {
-	BUG_ON(adapter->debugfs_root == NULL);
+	BUG_ON(IS_ERR_OR_NULL(adapter->debugfs_root));
 
 	/*
 	 * Unlike our sister routine cleanup_proc(), we don't need to remove
@@ -2724,11 +2724,11 @@ static int __devinit cxgb4vf_pci_probe(struct pci_dev *pdev,
 	/*
 	 * Set up our debugfs entries.
 	 */
-	if (cxgb4vf_debugfs_root) {
+	if (!IS_ERR_OR_NULL(cxgb4vf_debugfs_root)) {
 		adapter->debugfs_root =
 			debugfs_create_dir(pci_name(pdev),
 					   cxgb4vf_debugfs_root);
-		if (adapter->debugfs_root == NULL)
+		if (IS_ERR_OR_NULL(adapter->debugfs_root))
 			dev_warn(&pdev->dev, "could not create debugfs"
 				 " directory");
 		else
@@ -2783,7 +2783,7 @@ static int __devinit cxgb4vf_pci_probe(struct pci_dev *pdev,
 	 */
 
 err_free_debugfs:
-	if (adapter->debugfs_root) {
+	if (!IS_ERR_OR_NULL(adapter->debugfs_root)) {
 		cleanup_debugfs(adapter);
 		debugfs_remove_recursive(adapter->debugfs_root);
 	}
@@ -2852,7 +2852,7 @@ static void __devexit cxgb4vf_pci_remove(struct pci_dev *pdev)
 		/*
 		 * Tear down our debugfs entries.
 		 */
-		if (adapter->debugfs_root) {
+		if (!IS_ERR_OR_NULL(adapter->debugfs_root)) {
 			cleanup_debugfs(adapter);
 			debugfs_remove_recursive(adapter->debugfs_root);
 		}
@@ -2940,12 +2940,12 @@ static int __init cxgb4vf_module_init(void)
 
 	/* Debugfs support is optional, just warn if this fails */
 	cxgb4vf_debugfs_root = debugfs_create_dir(KBUILD_MODNAME, NULL);
-	if (!cxgb4vf_debugfs_root)
+	if (IS_ERR_OR_NULL(cxgb4vf_debugfs_root))
 		printk(KERN_WARNING KBUILD_MODNAME ": could not create"
 		       " debugfs entry, continuing\n");
 
 	ret = pci_register_driver(&cxgb4vf_driver);
-	if (ret < 0)
+	if (ret < 0 && !IS_ERR_OR_NULL(cxgb4vf_debugfs_root))
 		debugfs_remove(cxgb4vf_debugfs_root);
 	return ret;
 }
-- 
1.7.0.4

