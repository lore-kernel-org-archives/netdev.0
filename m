From: Dan Carpenter <error27@gmail.com>
Subject: [patch] iwl: cleanup: remove unneeded error handling
Date: Wed, 28 Apr 2010 11:01:15 +0200
Message-ID: <20100428090115.GF29093@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zhu Yi <yi.zhu@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Samuel Ortiz <samuel.ortiz@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is just a cleanup and doesn't change how the code works.

debugfs_create_dir() and debugfs_create_file() return an error pointer 
(-ENODEV) if CONFIG_DEBUG_FS is not enabled, otherwise if an error occurs
they return NULL.  This is how they are implemented and what it says in 
the DebugFS documentation.  DebugFS can not be compiled as a module.  

As a result, we only need to check for error pointers and particularly 
-ENODEV one time to know that DebugFS is enabled.  This patch keeps the 
first check for error pointers and removes the rest. 

The other reason for this patch, is that it silences some Smatch warnings.
Smatch sees the condition "(result != -ENODEV)" and assumes that it's 
possible for "result" to equal -ENODEV.  If it were possible it would lead
to an error pointer dereference.  But since it's not, we can just remove
the check.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/wireless/iwmc3200wifi/debugfs.c b/drivers/net/wireless/iwmc3200wifi/debugfs.c
index cbb81be..10eeeeb 100644
--- a/drivers/net/wireless/iwmc3200wifi/debugfs.c
+++ b/drivers/net/wireless/iwmc3200wifi/debugfs.c
@@ -438,40 +438,10 @@ int iwm_debugfs_init(struct iwm_priv *iwm)
 	snprintf(devdir, sizeof(devdir), "%s", wiphy_name(iwm_to_wiphy(iwm)));
 
 	iwm->dbg.devdir = debugfs_create_dir(devdir, iwm->dbg.rootdir);
-	result = PTR_ERR(iwm->dbg.devdir);
-	if (IS_ERR(iwm->dbg.devdir) && (result != -ENODEV)) {
-		IWM_ERR(iwm, "Couldn't create devdir: %d\n", result);
-		goto error;
-	}
-
 	iwm->dbg.dbgdir = debugfs_create_dir("debug", iwm->dbg.devdir);
-	result = PTR_ERR(iwm->dbg.dbgdir);
-	if (IS_ERR(iwm->dbg.dbgdir) && (result != -ENODEV)) {
-		IWM_ERR(iwm, "Couldn't create dbgdir: %d\n", result);
-		goto error;
-	}
-
 	iwm->dbg.rxdir = debugfs_create_dir("rx", iwm->dbg.devdir);
-	result = PTR_ERR(iwm->dbg.rxdir);
-	if (IS_ERR(iwm->dbg.rxdir) && (result != -ENODEV)) {
-		IWM_ERR(iwm, "Couldn't create rx dir: %d\n", result);
-		goto error;
-	}
-
 	iwm->dbg.txdir = debugfs_create_dir("tx", iwm->dbg.devdir);
-	result = PTR_ERR(iwm->dbg.txdir);
-	if (IS_ERR(iwm->dbg.txdir) && (result != -ENODEV)) {
-		IWM_ERR(iwm, "Couldn't create tx dir: %d\n", result);
-		goto error;
-	}
-
 	iwm->dbg.busdir = debugfs_create_dir("bus", iwm->dbg.devdir);
-	result = PTR_ERR(iwm->dbg.busdir);
-	if (IS_ERR(iwm->dbg.busdir) && (result != -ENODEV)) {
-		IWM_ERR(iwm, "Couldn't create bus dir: %d\n", result);
-		goto error;
-	}
-
 	if (iwm->bus_ops->debugfs_init) {
 		result = iwm->bus_ops->debugfs_init(iwm, iwm->dbg.busdir);
 		if (result < 0) {
@@ -480,27 +450,15 @@ int iwm_debugfs_init(struct iwm_priv *iwm)
 		}
 	}
 
-
 	iwm->dbg.dbg_level = IWM_DL_NONE;
 	iwm->dbg.dbg_level_dentry =
 		debugfs_create_file("level", 0200, iwm->dbg.dbgdir, iwm,
 				    &fops_iwm_dbg_level);
-	result = PTR_ERR(iwm->dbg.dbg_level_dentry);
-	if (IS_ERR(iwm->dbg.dbg_level_dentry) && (result != -ENODEV)) {
-		IWM_ERR(iwm, "Couldn't create dbg_level: %d\n", result);
-		goto error;
-	}
-
 
 	iwm->dbg.dbg_modules = IWM_DM_DEFAULT;
 	iwm->dbg.dbg_modules_dentry =
 		debugfs_create_file("modules", 0200, iwm->dbg.dbgdir, iwm,
 				    &fops_iwm_dbg_modules);
-	result = PTR_ERR(iwm->dbg.dbg_modules_dentry);
-	if (IS_ERR(iwm->dbg.dbg_modules_dentry) && (result != -ENODEV)) {
-		IWM_ERR(iwm, "Couldn't create dbg_modules: %d\n", result);
-		goto error;
-	}
 
 	for (i = 0; i < __IWM_DM_NR; i++)
 		add_dbg_module(iwm->dbg, iwm_debug_module[i].name,
@@ -509,39 +467,18 @@ int iwm_debugfs_init(struct iwm_priv *iwm)
 	iwm->dbg.txq_dentry = debugfs_create_file("queues", 0200,
 						  iwm->dbg.txdir, iwm,
 						  &iwm_debugfs_txq_fops);
-	result = PTR_ERR(iwm->dbg.txq_dentry);
-	if (IS_ERR(iwm->dbg.txq_dentry) && (result != -ENODEV)) {
-		IWM_ERR(iwm, "Couldn't create tx queue: %d\n", result);
-		goto error;
-	}
 
 	iwm->dbg.tx_credit_dentry = debugfs_create_file("credits", 0200,
 						   iwm->dbg.txdir, iwm,
 						   &iwm_debugfs_tx_credit_fops);
-	result = PTR_ERR(iwm->dbg.tx_credit_dentry);
-	if (IS_ERR(iwm->dbg.tx_credit_dentry) && (result != -ENODEV)) {
-		IWM_ERR(iwm, "Couldn't create tx credit: %d\n", result);
-		goto error;
-	}
 
 	iwm->dbg.rx_ticket_dentry = debugfs_create_file("tickets", 0200,
 						  iwm->dbg.rxdir, iwm,
 						  &iwm_debugfs_rx_ticket_fops);
-	result = PTR_ERR(iwm->dbg.rx_ticket_dentry);
-	if (IS_ERR(iwm->dbg.rx_ticket_dentry) && (result != -ENODEV)) {
-		IWM_ERR(iwm, "Couldn't create rx ticket: %d\n", result);
-		goto error;
-	}
 
 	iwm->dbg.fw_err_dentry = debugfs_create_file("last_fw_err", 0200,
 						     iwm->dbg.dbgdir, iwm,
 						     &iwm_debugfs_fw_err_fops);
-	result = PTR_ERR(iwm->dbg.fw_err_dentry);
-	if (IS_ERR(iwm->dbg.fw_err_dentry) && (result != -ENODEV)) {
-		IWM_ERR(iwm, "Couldn't create last FW err: %d\n", result);
-		goto error;
-	}
-
 
 	return 0;
 
