From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [ipw3945-devel] 2.6.24-rc5-mm1 -- INFO: possible circular
	locking dependency	detected -- pm-suspend/5800 is trying to acquire lock
Date: Wed, 19 Dec 2007 10:58:02 +0800
Message-ID: <1198033082.2857.303.camel@debian.sh.intel.com>
References: <a44ae5cd0712180603v2a37023dj714a8500c14c08de@mail.gmail.com>
	 <1197986886.4885.156.camel@johannes.berg>
	 <a44ae5cd0712180641n15ceae8bp977efe9a5b45e6bc@mail.gmail.com>
	 (sfid-20071218_144150_051683_83D9589E)  <1197989826.4885.169.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-FK830ol8qJSWEzXFA0oQ"
Cc: Miles Lane <miles.lane@gmail.com>, Len Brown <len.brown@intel.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	ipw3945-devel@lists.sourceforge.net,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:30171 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751672AbXLSC6I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2007 21:58:08 -0500
In-Reply-To: <1197989826.4885.169.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-FK830ol8qJSWEzXFA0oQ
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Tue, 2007-12-18 at 15:57 +0100, Johannes Berg wrote:
> Thanks. This is a bug in iwlwifi.
> 
> The problem is actually another case where my workqueue debugging with
> lockdep is triggering a warning :))
> 
> Here's the thing:
> 
> iwl3945_cancel_deferred_work does 
> 
> cancel_delayed_work_sync(&priv->init_alive_start);
> 
> (which is the "(&(&priv->init_alive_start)->work)" lock)
> 
> but it is called from within a locked section of
> mutex_lock(&priv->mutex); (locked from iwl3945_pci_suspend)
> 
> On the other hand, the task that runs from the init_alive_start
> workqueue is iwl3945_bg_init_alive_start() which will lock the same
> mutex.
> 
> So the deadlock condition is that you can be in
> cancel_delayed_work_sync() above while the mutex is locked, and be
> waiting for iwl_3945_bg_init_alive_start() which tries to lock the
> mutex.

Thanks for the analysis.

Miles, please try the attached patch. I'll send a patch for both 3945
and 4965 to linux-wireless later.

Thanks,
-yi

--=-FK830ol8qJSWEzXFA0oQ
Content-Disposition: attachment; filename=fix-3945-deadlock-susp.patch
Content-Type: text/x-patch; name=fix-3945-deadlock-susp.patch; charset=GB2312
Content-Transfer-Encoding: 7bit

diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 88cf035..f0303e8 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -6355,8 +6355,6 @@ static void __iwl3945_down(struct iwl3945_priv *priv)
 	/* Unblock any waiting calls */
 	wake_up_interruptible_all(&priv->wait_command_queue);
 
-	iwl3945_cancel_deferred_work(priv);
-
 	/* Wipe out the EXIT_PENDING status bit if we are not actually
 	 * exiting the module */
 	if (!exit_pending)
@@ -6431,6 +6429,8 @@ static void iwl3945_down(struct iwl3945_priv *priv)
 	mutex_lock(&priv->mutex);
 	__iwl3945_down(priv);
 	mutex_unlock(&priv->mutex);
+
+	iwl3945_cancel_deferred_work(priv);
 }
 
 #define MAX_HW_RESTARTS 5
@@ -8739,10 +8739,9 @@ static void iwl3945_pci_remove(struct pci_dev *pdev)
 
 	IWL_DEBUG_INFO("*** UNLOAD DRIVER ***\n");
 
-	mutex_lock(&priv->mutex);
 	set_bit(STATUS_EXIT_PENDING, &priv->status);
-	__iwl3945_down(priv);
-	mutex_unlock(&priv->mutex);
+
+	iwl3945_down(priv);
 
 	/* Free MAC hash list for ADHOC */
 	for (i = 0; i < IWL_IBSS_MAC_HASH_SIZE; i++) {
@@ -8801,12 +8800,10 @@ static int iwl3945_pci_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct iwl3945_priv *priv = pci_get_drvdata(pdev);
 
-	mutex_lock(&priv->mutex);
-
 	set_bit(STATUS_IN_SUSPEND, &priv->status);
 
 	/* Take down the device; powers it off, etc. */
-	__iwl3945_down(priv);
+	iwl3945_down(priv);
 
 	if (priv->mac80211_registered)
 		ieee80211_stop_queues(priv->hw);
@@ -8815,8 +8812,6 @@ static int iwl3945_pci_suspend(struct pci_dev *pdev, pm_message_t state)
 	pci_disable_device(pdev);
 	pci_set_power_state(pdev, PCI_D3hot);
 
-	mutex_unlock(&priv->mutex);
-
 	return 0;
 }
 
@@ -8874,8 +8869,6 @@ static int iwl3945_pci_resume(struct pci_dev *pdev)
 
 	printk(KERN_INFO "Coming out of suspend...\n");
 
-	mutex_lock(&priv->mutex);
-
 	pci_set_power_state(pdev, PCI_D0);
 	err = pci_enable_device(pdev);
 	pci_restore_state(pdev);
@@ -8889,7 +8882,6 @@ static int iwl3945_pci_resume(struct pci_dev *pdev)
 	pci_write_config_byte(pdev, 0x41, 0x00);
 
 	iwl3945_resume(priv);
-	mutex_unlock(&priv->mutex);
 
 	return 0;
 }

--=-FK830ol8qJSWEzXFA0oQ--

