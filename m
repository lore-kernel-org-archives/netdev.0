From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'fixes-jgarzik' branch of wireless-2.6
Date: Thu, 20 Dec 2007 10:54:02 -0500
Message-ID: <20071220155402.GG3139@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4314 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758135AbXLTQ2v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 11:28:51 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff,

Here are a few more for 2.6.24...please let me know if there are any
problems!

Thanks,

John

P.S.  The rtl8187 USB ID is already in your upstream branch -- I'm sure
it would seem like a fix if it was the ID for your wireless stick. :-)

---

Individual patches are available here:

	http://www.kernel.org//pub/linux/kernel/people/linville/wireless-2.6/fixes-jgarzik

---

The following changes since commit 82d29bf6dc7317aeb0a3a13c2348ca8591965875:
  Linus Torvalds (1):
        Linux 2.6.24-rc5

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-jgarzik

Matthias Mueller (1):
      rtl8187: Add USB ID for Sitecom WL-168 v1 001

Michael Wu (1):
      p54: add Kconfig description

Reinette Chatre (1):
      ipw2200: prevent alloc of unspecified size on stack

Zhu Yi (1):
      iwlwifi: fix possible priv->mutex deadlock during suspend

 drivers/net/wireless/Kconfig                |   51 +++++++++++++++++++++++++++
 drivers/net/wireless/ipw2200.c              |   13 ++++++-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   18 +++-------
 drivers/net/wireless/iwlwifi/iwl4965-base.c |   18 +++-------
 drivers/net/wireless/rtl8187_dev.c          |    2 +
 5 files changed, 75 insertions(+), 27 deletions(-)

diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index 2b733c5..7bdf9da 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -586,15 +586,66 @@ config ADM8211
 config P54_COMMON
 	tristate "Softmac Prism54 support"
 	depends on MAC80211 && WLAN_80211 && FW_LOADER && EXPERIMENTAL
+	---help---
+	  This is common code for isl38xx based cards.
+	  This module does nothing by itself - the USB/PCI frontends
+	  also need to be enabled in order to support any devices.
+
+	  These devices require softmac firmware which can be found at
+	  http://prism54.org/
+
+	  If you choose to build a module, it'll be called p54common.
 
 config P54_USB
 	tristate "Prism54 USB support"
 	depends on P54_COMMON && USB
 	select CRC32
+	---help---
+	  This driver is for USB isl38xx based wireless cards.
+	  These are USB based adapters found in devices such as:
+
+	  3COM 3CRWE254G72
+	  SMC 2862W-G
+	  Accton 802.11g WN4501 USB
+	  Siemens Gigaset USB
+	  Netgear WG121
+	  Netgear WG111
+	  Medion 40900, Roper Europe
+	  Shuttle PN15, Airvast WM168g, IOGear GWU513
+	  Linksys WUSB54G
+	  Linksys WUSB54G Portable
+	  DLink DWL-G120 Spinnaker
+	  DLink DWL-G122
+	  Belkin F5D7050 ver 1000
+	  Cohiba Proto board
+	  SMC 2862W-G version 2
+	  U.S. Robotics U5 802.11g Adapter
+	  FUJITSU E-5400 USB D1700
+	  Sagem XG703A
+	  DLink DWL-G120 Cohiba
+	  Spinnaker Proto board
+	  Linksys WUSB54AG
+	  Inventel UR054G
+	  Spinnaker DUT
+
+	  These devices require softmac firmware which can be found at
+	  http://prism54.org/
+
+	  If you choose to build a module, it'll be called p54usb.
 
 config P54_PCI
 	tristate "Prism54 PCI support"
 	depends on P54_COMMON && PCI
+	---help---
+	  This driver is for PCI isl38xx based wireless cards.
+	  This driver supports most devices that are supported by the
+	  fullmac prism54 driver plus many devices which are not
+	  supported by the fullmac driver/firmware.
+
+	  This driver requires softmac firmware which can be found at
+	  http://prism54.org/
+
+	  If you choose to build a module, it'll be called p54pci.
 
 source "drivers/net/wireless/iwlwifi/Kconfig"
 source "drivers/net/wireless/hostap/Kconfig"
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 54f44e5..38ce8ee 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -1233,9 +1233,19 @@ static ssize_t show_event_log(struct device *d,
 {
 	struct ipw_priv *priv = dev_get_drvdata(d);
 	u32 log_len = ipw_get_event_log_len(priv);
-	struct ipw_event log[log_len];
+	u32 log_size;
+	struct ipw_event *log;
 	u32 len = 0, i;
 
+	/* not using min() because of its strict type checking */
+	log_size = PAGE_SIZE / sizeof(*log) > log_len ?
+			sizeof(*log) * log_len : PAGE_SIZE;
+	log = kzalloc(log_size, GFP_KERNEL);
+	if (!log) {
+		IPW_ERROR("Unable to allocate memory for log\n");
+		return 0;
+	}
+	log_len = log_size / sizeof(*log);
 	ipw_capture_event_log(priv, log_len, log);
 
 	len += snprintf(buf + len, PAGE_SIZE - len, "%08X", log_len);
@@ -1244,6 +1254,7 @@ static ssize_t show_event_log(struct device *d,
 				"\n%08X%08X%08X",
 				log[i].time, log[i].event, log[i].data);
 	len += snprintf(buf + len, PAGE_SIZE - len, "\n");
+	kfree(log);
 	return len;
 }
 
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 4bdf237..5c67b5b 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -6243,8 +6243,6 @@ static void __iwl_down(struct iwl_priv *priv)
 	/* Unblock any waiting calls */
 	wake_up_interruptible_all(&priv->wait_command_queue);
 
-	iwl_cancel_deferred_work(priv);
-
 	/* Wipe out the EXIT_PENDING status bit if we are not actually
 	 * exiting the module */
 	if (!exit_pending)
@@ -6319,6 +6317,8 @@ static void iwl_down(struct iwl_priv *priv)
 	mutex_lock(&priv->mutex);
 	__iwl_down(priv);
 	mutex_unlock(&priv->mutex);
+
+	iwl_cancel_deferred_work(priv);
 }
 
 #define MAX_HW_RESTARTS 5
@@ -8577,10 +8577,9 @@ static void iwl_pci_remove(struct pci_dev *pdev)
 
 	IWL_DEBUG_INFO("*** UNLOAD DRIVER ***\n");
 
-	mutex_lock(&priv->mutex);
 	set_bit(STATUS_EXIT_PENDING, &priv->status);
-	__iwl_down(priv);
-	mutex_unlock(&priv->mutex);
+
+	iwl_down(priv);
 
 	/* Free MAC hash list for ADHOC */
 	for (i = 0; i < IWL_IBSS_MAC_HASH_SIZE; i++) {
@@ -8639,12 +8638,10 @@ static int iwl_pci_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct iwl_priv *priv = pci_get_drvdata(pdev);
 
-	mutex_lock(&priv->mutex);
-
 	set_bit(STATUS_IN_SUSPEND, &priv->status);
 
 	/* Take down the device; powers it off, etc. */
-	__iwl_down(priv);
+	iwl_down(priv);
 
 	if (priv->mac80211_registered)
 		ieee80211_stop_queues(priv->hw);
@@ -8653,8 +8650,6 @@ static int iwl_pci_suspend(struct pci_dev *pdev, pm_message_t state)
 	pci_disable_device(pdev);
 	pci_set_power_state(pdev, PCI_D3hot);
 
-	mutex_unlock(&priv->mutex);
-
 	return 0;
 }
 
@@ -8712,8 +8707,6 @@ static int iwl_pci_resume(struct pci_dev *pdev)
 
 	printk(KERN_INFO "Coming out of suspend...\n");
 
-	mutex_lock(&priv->mutex);
-
 	pci_set_power_state(pdev, PCI_D0);
 	err = pci_enable_device(pdev);
 	pci_restore_state(pdev);
@@ -8727,7 +8720,6 @@ static int iwl_pci_resume(struct pci_dev *pdev)
 	pci_write_config_byte(pdev, 0x41, 0x00);
 
 	iwl_resume(priv);
-	mutex_unlock(&priv->mutex);
 
 	return 0;
 }
diff --git a/drivers/net/wireless/iwlwifi/iwl4965-base.c b/drivers/net/wireless/iwlwifi/iwl4965-base.c
index 8f85564..ed148ea 100644
--- a/drivers/net/wireless/iwlwifi/iwl4965-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl4965-base.c
@@ -6598,8 +6598,6 @@ static void __iwl_down(struct iwl_priv *priv)
 	/* Unblock any waiting calls */
 	wake_up_interruptible_all(&priv->wait_command_queue);
 
-	iwl_cancel_deferred_work(priv);
-
 	/* Wipe out the EXIT_PENDING status bit if we are not actually
 	 * exiting the module */
 	if (!exit_pending)
@@ -6674,6 +6672,8 @@ static void iwl_down(struct iwl_priv *priv)
 	mutex_lock(&priv->mutex);
 	__iwl_down(priv);
 	mutex_unlock(&priv->mutex);
+
+	iwl_cancel_deferred_work(priv);
 }
 
 #define MAX_HW_RESTARTS 5
@@ -9171,10 +9171,9 @@ static void iwl_pci_remove(struct pci_dev *pdev)
 
 	IWL_DEBUG_INFO("*** UNLOAD DRIVER ***\n");
 
-	mutex_lock(&priv->mutex);
 	set_bit(STATUS_EXIT_PENDING, &priv->status);
-	__iwl_down(priv);
-	mutex_unlock(&priv->mutex);
+
+	iwl_down(priv);
 
 	/* Free MAC hash list for ADHOC */
 	for (i = 0; i < IWL_IBSS_MAC_HASH_SIZE; i++) {
@@ -9233,12 +9232,10 @@ static int iwl_pci_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct iwl_priv *priv = pci_get_drvdata(pdev);
 
-	mutex_lock(&priv->mutex);
-
 	set_bit(STATUS_IN_SUSPEND, &priv->status);
 
 	/* Take down the device; powers it off, etc. */
-	__iwl_down(priv);
+	iwl_down(priv);
 
 	if (priv->mac80211_registered)
 		ieee80211_stop_queues(priv->hw);
@@ -9247,8 +9244,6 @@ static int iwl_pci_suspend(struct pci_dev *pdev, pm_message_t state)
 	pci_disable_device(pdev);
 	pci_set_power_state(pdev, PCI_D3hot);
 
-	mutex_unlock(&priv->mutex);
-
 	return 0;
 }
 
@@ -9306,8 +9301,6 @@ static int iwl_pci_resume(struct pci_dev *pdev)
 
 	printk(KERN_INFO "Coming out of suspend...\n");
 
-	mutex_lock(&priv->mutex);
-
 	pci_set_power_state(pdev, PCI_D0);
 	err = pci_enable_device(pdev);
 	pci_restore_state(pdev);
@@ -9321,7 +9314,6 @@ static int iwl_pci_resume(struct pci_dev *pdev)
 	pci_write_config_byte(pdev, 0x41, 0x00);
 
 	iwl_resume(priv);
-	mutex_unlock(&priv->mutex);
 
 	return 0;
 }
diff --git a/drivers/net/wireless/rtl8187_dev.c b/drivers/net/wireless/rtl8187_dev.c
index e454ae8..bd1ab3b 100644
--- a/drivers/net/wireless/rtl8187_dev.c
+++ b/drivers/net/wireless/rtl8187_dev.c
@@ -38,6 +38,8 @@ static struct usb_device_id rtl8187_table[] __devinitdata = {
 	{USB_DEVICE(0x0846, 0x6a00)},
 	/* HP */
 	{USB_DEVICE(0x03f0, 0xca02)},
+	/* Sitecom */
+	{USB_DEVICE(0x0df6, 0x000d)},
 	{}
 };
 
-- 
John W. Linville
linville@tuxdriver.com
