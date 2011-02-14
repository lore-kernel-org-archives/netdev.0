From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH net-26 2/4] cxgb4vf: Behave properly when CONFIG_DEBUG_FS isn't defined ...
Date: Mon, 14 Feb 2011 14:56:23 -0800
Message-ID: <1297724185-27452-3-git-send-email-leedom@chelsio.com>
References: <1297724185-27452-1-git-send-email-leedom@chelsio.com>
Cc: davem@davemloft.net, Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:26850 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752105Ab1BNW43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 17:56:29 -0500
In-Reply-To: <1297724185-27452-1-git-send-email-leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When CONFIG_DEBUG_FS we get "ERR_PTR()"s back from the debugfs routines
instead of NULL.  Use the right predicates to check for this.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb4vf/cxgb4vf_main.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
index 072b64e..2be1088 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -2040,7 +2040,7 @@ static int __devinit setup_debugfs(struct adapter *adapter)
 {
 	int i;
 
-	BUG_ON(adapter->debugfs_root == NULL);
+	BUG_ON(IS_ERR_OR_NULL(adapter->debugfs_root));
 
 	/*
 	 * Debugfs support is best effort.
@@ -2061,7 +2061,7 @@ static int __devinit setup_debugfs(struct adapter *adapter)
  */
 static void cleanup_debugfs(struct adapter *adapter)
 {
-	BUG_ON(adapter->debugfs_root == NULL);
+	BUG_ON(IS_ERR_OR_NULL(adapter->debugfs_root));
 
 	/*
 	 * Unlike our sister routine cleanup_proc(), we don't need to remove
@@ -2700,11 +2700,11 @@ static int __devinit cxgb4vf_pci_probe(struct pci_dev *pdev,
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
@@ -2759,7 +2759,7 @@ static int __devinit cxgb4vf_pci_probe(struct pci_dev *pdev,
 	 */
 
 err_free_debugfs:
-	if (adapter->debugfs_root) {
+	if (!IS_ERR_OR_NULL(adapter->debugfs_root)) {
 		cleanup_debugfs(adapter);
 		debugfs_remove_recursive(adapter->debugfs_root);
 	}
@@ -2828,7 +2828,7 @@ static void __devexit cxgb4vf_pci_remove(struct pci_dev *pdev)
 		/*
 		 * Tear down our debugfs entries.
 		 */
-		if (adapter->debugfs_root) {
+		if (!IS_ERR_OR_NULL(adapter->debugfs_root)) {
 			cleanup_debugfs(adapter);
 			debugfs_remove_recursive(adapter->debugfs_root);
 		}
@@ -2916,12 +2916,12 @@ static int __init cxgb4vf_module_init(void)
 
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

