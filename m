From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH net-next] igb: mark PM functions as __maybe_unused
Date: Thu, 27 Apr 2017 21:09:52 +0200
Message-ID: <20170427191007.1990964-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jacob Keller <jacob.e.keller@intel.com>,
        Todd Fujinaka <todd.fujinaka@intel.com>,
        Yury Kylulin <yury.kylulin@intel.com>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.74]:57187 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756310AbdD0TJv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 15:09:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new wake function is only used by the suspend/resume handlers that
are defined in inside of an #ifdef, which can cause this harmless
warning:

drivers/net/ethernet/intel/igb/igb_main.c:7988:13: warning: 'igb_deliver_wake_packet' defined but not used [-Wunused-function]

Removing the #ifdef, instead using a __maybe_unused annotation
simplifies the code and avoids the warning.

Fixes: b90fa8763560 ("igb: Enable reading of wake up packet")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 18 +++++-------------
 1 file changed, 5 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 1cf74aa4ebd9..2d5bdb1fd37d 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -191,10 +191,7 @@ static int igb_disable_sriov(struct pci_dev *dev);
 static int igb_pci_disable_sriov(struct pci_dev *dev);
 #endif
 
-#ifdef CONFIG_PM
-#ifdef CONFIG_PM_SLEEP
 static int igb_suspend(struct device *);
-#endif
 static int igb_resume(struct device *);
 static int igb_runtime_suspend(struct device *dev);
 static int igb_runtime_resume(struct device *dev);
@@ -204,7 +201,6 @@ static const struct dev_pm_ops igb_pm_ops = {
 	SET_RUNTIME_PM_OPS(igb_runtime_suspend, igb_runtime_resume,
 			igb_runtime_idle)
 };
-#endif
 static void igb_shutdown(struct pci_dev *);
 static int igb_pci_sriov_configure(struct pci_dev *dev, int num_vfs);
 #ifdef CONFIG_IGB_DCA
@@ -8015,9 +8011,7 @@ static void igb_deliver_wake_packet(struct net_device *netdev)
 	netif_rx(skb);
 }
 
-#ifdef CONFIG_PM
-#ifdef CONFIG_PM_SLEEP
-static int igb_suspend(struct device *dev)
+static int __maybe_unused igb_suspend(struct device *dev)
 {
 	int retval;
 	bool wake;
@@ -8036,9 +8030,8 @@ static int igb_suspend(struct device *dev)
 
 	return 0;
 }
-#endif /* CONFIG_PM_SLEEP */
 
-static int igb_resume(struct device *dev)
+static int __maybe_unused igb_resume(struct device *dev)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
 	struct net_device *netdev = pci_get_drvdata(pdev);
@@ -8092,7 +8085,7 @@ static int igb_resume(struct device *dev)
 	return err;
 }
 
-static int igb_runtime_idle(struct device *dev)
+static int __maybe_unused igb_runtime_idle(struct device *dev)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
 	struct net_device *netdev = pci_get_drvdata(pdev);
@@ -8104,7 +8097,7 @@ static int igb_runtime_idle(struct device *dev)
 	return -EBUSY;
 }
 
-static int igb_runtime_suspend(struct device *dev)
+static int __maybe_unused igb_runtime_suspend(struct device *dev)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
 	int retval;
@@ -8124,11 +8117,10 @@ static int igb_runtime_suspend(struct device *dev)
 	return 0;
 }
 
-static int igb_runtime_resume(struct device *dev)
+static int __maybe_unused igb_runtime_resume(struct device *dev)
 {
 	return igb_resume(dev);
 }
-#endif /* CONFIG_PM */
 
 static void igb_shutdown(struct pci_dev *pdev)
 {
-- 
2.9.0
