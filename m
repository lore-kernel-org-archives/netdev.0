From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: [PATCH V3] iwlwifi: add basic runtime PM support
Date: Wed, 11 Jan 2012 09:05:11 +0800
Message-ID: <4F0CE047.9070005@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: wey-yi.w.guy@intel.com, Johannes Berg <johannes@sipsolutions.net>,
	ilw@linux.intel.com
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59495 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932585Ab2AKBFN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jan 2012 20:05:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This simple patch adds open/close based runtime PM support to the iwlwifi driver.
Namely, make the driver suspend the device after shutting down the interface and
resume the device when activating the interface. In my test, suspending the device
can save about 0.4 watt power. The shortcoming is that the device no longer generate
rfkill changes interrupt, but it may have some value for systems that use software
rfkill. The feature is disabled by default.

Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
---
 drivers/net/wireless/iwlwifi/iwl-agn.c    |   21 +++++++++++++++++++--
 drivers/net/wireless/iwlwifi/iwl-pci.c    |   22 +++++++++++++++++++++-
 drivers/net/wireless/iwlwifi/iwl-shared.h |    1 +
 3 files changed, 41 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index e0e9a3d..2d1f890a 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -38,6 +38,7 @@
 #include <linux/firmware.h>
 #include <linux/etherdevice.h>
 #include <linux/if_arp.h>
+#include <linux/pm_runtime.h>
 
 #include <net/mac80211.h>
 
@@ -1755,6 +1756,8 @@ static int iwlagn_mac_start(struct ieee80211_hw *hw)
 	struct iwl_priv *priv = hw->priv;
 	int ret;
 
+	pm_runtime_get_sync(bus(priv)->dev);
+
 	IWL_DEBUG_MAC80211(priv, "enter\n");
 
 	/* we should be verifying the device is ready to be opened */
@@ -1762,7 +1765,7 @@ static int iwlagn_mac_start(struct ieee80211_hw *hw)
 	ret = __iwl_up(priv);
 	mutex_unlock(&priv->shrd->mutex);
 	if (ret)
-		return ret;
+		goto out;
 
 	IWL_DEBUG_INFO(priv, "Start UP work done.\n");
 
@@ -1774,7 +1777,10 @@ static int iwlagn_mac_start(struct ieee80211_hw *hw)
 
 	priv->is_open = 1;
 	IWL_DEBUG_MAC80211(priv, "leave\n");
-	return 0;
+	ret = 0;
+out:
+	pm_runtime_put(bus(priv)->dev);
+	return ret;
 }
 
 static void iwlagn_mac_stop(struct ieee80211_hw *hw)
@@ -1786,6 +1792,8 @@ static void iwlagn_mac_stop(struct ieee80211_hw *hw)
 	if (!priv->is_open)
 		return;
 
+	pm_runtime_get_sync(bus(priv)->dev);
+
 	priv->is_open = 0;
 
 	iwl_down(priv);
@@ -1798,6 +1806,8 @@ static void iwlagn_mac_stop(struct ieee80211_hw *hw)
 	iwl_enable_rfkill_int(priv);
 
 	IWL_DEBUG_MAC80211(priv, "leave\n");
+
+	pm_runtime_put(bus(priv)->dev);
 }
 
 #ifdef CONFIG_PM_SLEEP
@@ -3557,3 +3567,10 @@ module_param_named(no_sleep_autoadjust, iwlagn_mod_params.no_sleep_autoadjust,
 MODULE_PARM_DESC(no_sleep_autoadjust,
 		 "don't automatically adjust sleep level "
 		 "according to maximum network latency (default: true)");
+
+module_param_named(runtime_pm, iwlagn_mod_params.runtime_pm, bool, S_IRUGO);
+MODULE_PARM_DESC(runtime_pm,
+		 "enable open/close based runtime power management, this "
+		 "feature can make HW rfkill unusable (default: disabled)");
+
+
diff --git a/drivers/net/wireless/iwlwifi/iwl-pci.c b/drivers/net/wireless/iwlwifi/iwl-pci.c
index 1800029..541f3e6 100644
--- a/drivers/net/wireless/iwlwifi/iwl-pci.c
+++ b/drivers/net/wireless/iwlwifi/iwl-pci.c
@@ -63,6 +63,7 @@
 #include <linux/module.h>
 #include <linux/pci.h>
 #include <linux/pci-aspm.h>
+#include <linux/pm_runtime.h>
 
 #include "iwl-bus.h"
 #include "iwl-io.h"
@@ -465,6 +466,8 @@ static int iwl_pci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	err = iwl_probe(bus, &trans_ops_pcie, cfg);
 	if (err)
 		goto out_disable_msi;
+
+	pm_runtime_put_noidle(&pdev->dev);
 	return 0;
 
 out_disable_msi:
@@ -487,6 +490,8 @@ static void __devexit iwl_pci_remove(struct pci_dev *pdev)
 	struct pci_dev *pci_dev = IWL_BUS_GET_PCI_DEV(bus);
 	struct iwl_shared *shrd = bus->shrd;
 
+	pm_runtime_get_noresume(&pdev->dev);
+
 	iwl_remove(shrd->priv);
 
 	pci_disable_msi(pci_dev);
@@ -534,7 +539,22 @@ static int iwl_pci_resume(struct device *device)
 	return iwl_trans_resume(shrd->trans);
 }
 
-static SIMPLE_DEV_PM_OPS(iwl_dev_pm_ops, iwl_pci_suspend, iwl_pci_resume);
+
+static int iwl_pci_runtime_idle(struct device *dev)
+{
+	struct pci_dev *pdev = to_pci_dev(dev);
+	struct iwl_bus *bus = pci_get_drvdata(pdev);
+	struct iwl_shared *shrd = bus->shrd;
+
+	if (iwlagn_mod_params.runtime_pm &&
+	    !test_bit(STATUS_ALIVE, &shrd->status))
+		return 0;
+
+	return -EBUSY;
+}
+
+static UNIVERSAL_DEV_PM_OPS(iwl_dev_pm_ops, iwl_pci_suspend,
+			iwl_pci_resume, iwl_pci_runtime_idle);
 
 #define IWL_PM_OPS	(&iwl_dev_pm_ops)
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-shared.h b/drivers/net/wireless/iwlwifi/iwl-shared.h
index 14eaf37..a570e0d 100644
--- a/drivers/net/wireless/iwlwifi/iwl-shared.h
+++ b/drivers/net/wireless/iwlwifi/iwl-shared.h
@@ -152,6 +152,7 @@ struct iwl_mod_params {
 	bool bt_ch_announce;
 	int wanted_ucode_alternative;
 	bool auto_agg;
+	bool runtime_pm;
 };
 
 /**
-- 
1.7.7.5
