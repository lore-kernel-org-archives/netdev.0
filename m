From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [patch] iwl: cleanup: remove unneeded error handling
Date: Thu, 29 Apr 2010 10:12:14 +0800
Message-ID: <1272507134.14773.4339.camel@debian>
References: <20100428090115.GF29093@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Ortiz, Samuel" <samuel.ortiz@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <error27@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100428090115.GF29093@bicker>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-04-28 at 17:01 +0800, Dan Carpenter wrote:
> This is just a cleanup and doesn't change how the code works.
> 
> debugfs_create_dir() and debugfs_create_file() return an error pointer 
> (-ENODEV) if CONFIG_DEBUG_FS is not enabled, otherwise if an error occurs
> they return NULL.  This is how they are implemented and what it says in 
> the DebugFS documentation.  DebugFS can not be compiled as a module.  
> 
> As a result, we only need to check for error pointers and particularly 
> -ENODEV one time to know that DebugFS is enabled.  This patch keeps the 
> first check for error pointers and removes the rest. 
> 
> The other reason for this patch, is that it silences some Smatch warnings.
> Smatch sees the condition "(result != -ENODEV)" and assumes that it's 
> possible for "result" to equal -ENODEV.  If it were possible it would lead
> to an error pointer dereference.  But since it's not, we can just remove
> the check.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Thanks. But looks like you missed the one in if_sdio_debugfs_init().

I don't think we even need to check -ENODEV ourselves because if
DEBUG_FS is not compiled in, all the debugfs utility functions will
become no-op.

Signed-off-by: Dan Carpenter <error27@gmail.com>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>

diff --git a/drivers/net/wireless/iwmc3200wifi/bus.h b/drivers/net/wireless/iwmc3200wifi/bus.h
index 836663e..62edd58 100644
--- a/drivers/net/wireless/iwmc3200wifi/bus.h
+++ b/drivers/net/wireless/iwmc3200wifi/bus.h
@@ -31,7 +31,7 @@ struct iwm_if_ops {
 	int (*disable)(struct iwm_priv *iwm);
 	int (*send_chunk)(struct iwm_priv *iwm, u8* buf, int count);
 
-	int (*debugfs_init)(struct iwm_priv *iwm, struct dentry *parent_dir);
+	void (*debugfs_init)(struct iwm_priv *iwm, struct dentry *parent_dir);
 	void (*debugfs_exit)(struct iwm_priv *iwm);
 
 	const char *umac_name;
diff --git a/drivers/net/wireless/iwmc3200wifi/debug.h b/drivers/net/wireless/iwmc3200wifi/debug.h
index e35c9b6..f98bf12 100644
--- a/drivers/net/wireless/iwmc3200wifi/debug.h
+++ b/drivers/net/wireless/iwmc3200wifi/debug.h
@@ -113,10 +113,10 @@ struct iwm_debugfs {
 };
 
 #ifdef CONFIG_IWM_DEBUG
-int iwm_debugfs_init(struct iwm_priv *iwm);
+void iwm_debugfs_init(struct iwm_priv *iwm);
 void iwm_debugfs_exit(struct iwm_priv *iwm);
 #else
-static inline int iwm_debugfs_init(struct iwm_priv *iwm)
+static inline void iwm_debugfs_init(struct iwm_priv *iwm)
 {
 	return 0;
 }
diff --git a/drivers/net/wireless/iwmc3200wifi/debugfs.c b/drivers/net/wireless/iwmc3200wifi/debugfs.c
index 7244413..53b0b77 100644
--- a/drivers/net/wireless/iwmc3200wifi/debugfs.c
+++ b/drivers/net/wireless/iwmc3200wifi/debugfs.c
@@ -48,12 +48,11 @@ static struct {
 
 #define add_dbg_module(dbg, name, id, initlevel) 	\
 do {							\
-	struct dentry *d;				\
 	dbg.dbg_module[id] = (initlevel);		\
-	d = debugfs_create_x8(name, 0600, dbg.dbgdir,	\
-			     &(dbg.dbg_module[id]));	\
-	if (!IS_ERR(d))					\
-		dbg.dbg_module_dentries[id] = d;        \
+	dbg.dbg_module_dentries[id] =			\
+		debugfs_create_x8(name, 0600,		\
+				dbg.dbgdir,		\
+				&(dbg.dbg_module[id]));	\
 } while (0)
 
 static int iwm_debugfs_u32_read(void *data, u64 *val)
@@ -423,89 +422,29 @@ static const struct file_operations iwm_debugfs_fw_err_fops = {
 	.read =		iwm_debugfs_fw_err_read,
 };
 
-int iwm_debugfs_init(struct iwm_priv *iwm)
+void iwm_debugfs_init(struct iwm_priv *iwm)
 {
-	int i, result;
-	char devdir[16];
+	int i;
 
 	iwm->dbg.rootdir = debugfs_create_dir(KBUILD_MODNAME, NULL);
-	result = PTR_ERR(iwm->dbg.rootdir);
-	if (!result || IS_ERR(iwm->dbg.rootdir)) {
-		if (result == -ENODEV) {
-			IWM_ERR(iwm, "DebugFS (CONFIG_DEBUG_FS) not "
-				"enabled in kernel config\n");
-			result = 0;	/* No debugfs support */
-		}
-		IWM_ERR(iwm, "Couldn't create rootdir: %d\n", result);
-		goto error;
-	}
-
-	snprintf(devdir, sizeof(devdir), "%s", wiphy_name(iwm_to_wiphy(iwm)));
-
-	iwm->dbg.devdir = debugfs_create_dir(devdir, iwm->dbg.rootdir);
-	result = PTR_ERR(iwm->dbg.devdir);
-	if (IS_ERR(iwm->dbg.devdir) && (result != -ENODEV)) {
-		IWM_ERR(iwm, "Couldn't create devdir: %d\n", result);
-		goto error;
-	}
-
+	iwm->dbg.devdir = debugfs_create_dir(wiphy_name(iwm_to_wiphy(iwm)),
+					     iwm->dbg.rootdir);
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
-	if (iwm->bus_ops->debugfs_init) {
-		result = iwm->bus_ops->debugfs_init(iwm, iwm->dbg.busdir);
-		if (result < 0) {
-			IWM_ERR(iwm, "Couldn't create bus entry: %d\n", result);
-			goto error;
-		}
-	}
-
+	if (iwm->bus_ops->debugfs_init)
+		iwm->bus_ops->debugfs_init(iwm, iwm->dbg.busdir);
 
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
@@ -514,44 +453,15 @@ int iwm_debugfs_init(struct iwm_priv *iwm)
 	iwm->dbg.txq_dentry = debugfs_create_file("queues", 0200,
 						  iwm->dbg.txdir, iwm,
 						  &iwm_debugfs_txq_fops);
-	result = PTR_ERR(iwm->dbg.txq_dentry);
-	if (IS_ERR(iwm->dbg.txq_dentry) && (result != -ENODEV)) {
-		IWM_ERR(iwm, "Couldn't create tx queue: %d\n", result);
-		goto error;
-	}
-
 	iwm->dbg.tx_credit_dentry = debugfs_create_file("credits", 0200,
 						   iwm->dbg.txdir, iwm,
 						   &iwm_debugfs_tx_credit_fops);
-	result = PTR_ERR(iwm->dbg.tx_credit_dentry);
-	if (IS_ERR(iwm->dbg.tx_credit_dentry) && (result != -ENODEV)) {
-		IWM_ERR(iwm, "Couldn't create tx credit: %d\n", result);
-		goto error;
-	}
-
 	iwm->dbg.rx_ticket_dentry = debugfs_create_file("tickets", 0200,
 						  iwm->dbg.rxdir, iwm,
 						  &iwm_debugfs_rx_ticket_fops);
-	result = PTR_ERR(iwm->dbg.rx_ticket_dentry);
-	if (IS_ERR(iwm->dbg.rx_ticket_dentry) && (result != -ENODEV)) {
-		IWM_ERR(iwm, "Couldn't create rx ticket: %d\n", result);
-		goto error;
-	}
-
 	iwm->dbg.fw_err_dentry = debugfs_create_file("last_fw_err", 0200,
 						     iwm->dbg.dbgdir, iwm,
 						     &iwm_debugfs_fw_err_fops);
-	result = PTR_ERR(iwm->dbg.fw_err_dentry);
-	if (IS_ERR(iwm->dbg.fw_err_dentry) && (result != -ENODEV)) {
-		IWM_ERR(iwm, "Couldn't create last FW err: %d\n", result);
-		goto error;
-	}
-
-
-	return 0;
-
- error:
-	return result;
 }
 
 void iwm_debugfs_exit(struct iwm_priv *iwm)
diff --git a/drivers/net/wireless/iwmc3200wifi/sdio.c b/drivers/net/wireless/iwmc3200wifi/sdio.c
index 1eafd6d..1acea37 100644
--- a/drivers/net/wireless/iwmc3200wifi/sdio.c
+++ b/drivers/net/wireless/iwmc3200wifi/sdio.c
@@ -366,21 +366,13 @@ static const struct file_operations iwm_debugfs_sdio_fops = {
 	.read =		iwm_debugfs_sdio_read,
 };
 
-static int if_sdio_debugfs_init(struct iwm_priv *iwm, struct dentry *parent_dir)
+static void if_sdio_debugfs_init(struct iwm_priv *iwm, struct dentry *parent_dir)
 {
-	int result;
 	struct iwm_sdio_priv *hw = iwm_to_if_sdio(iwm);
 
 	hw->cccr_dentry = debugfs_create_file("cccr", 0200,
 					      parent_dir, iwm,
 					      &iwm_debugfs_sdio_fops);
-	result = PTR_ERR(hw->cccr_dentry);
-	if (IS_ERR(hw->cccr_dentry) && (result != -ENODEV)) {
-		IWM_ERR(iwm, "Couldn't create CCCR entry: %d\n", result);
-		return result;
-	}
-
-	return 0;
 }
 
 static void if_sdio_debugfs_exit(struct iwm_priv *iwm)
@@ -440,11 +432,7 @@ static int iwm_sdio_probe(struct sdio_func *func,
 	hw = iwm_private(iwm);
 	hw->iwm = iwm;
 
-	ret = iwm_debugfs_init(iwm);
-	if (ret < 0) {
-		IWM_ERR(iwm, "Debugfs registration failed\n");
-		goto if_free;
-	}
+	iwm_debugfs_init(iwm);
 
 	sdio_set_drvdata(func, hw);
 
@@ -473,7 +461,6 @@ static int iwm_sdio_probe(struct sdio_func *func,
 	destroy_workqueue(hw->isr_wq);
  debugfs_exit:
 	iwm_debugfs_exit(iwm);
- if_free:
 	iwm_if_free(iwm);
 	return ret;
 }
