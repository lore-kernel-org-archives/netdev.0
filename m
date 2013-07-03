From: Shuah Khan <shuah.kh@samsung.com>
Subject: [PATCH] wireless: Convert mwifiex/pcie to dev_pm_ops from legacy pm_ops
Date: Wed,  3 Jul 2013 10:47:10 -0600
Message-ID: <1372870030-2596-1-git-send-email-shuah.kh@samsung.com>
Cc: Shuah Khan <shuah.kh@samsung.com>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	shuahkhan@gmail.com
To: bzhao@marvell.com, linville@tuxdriver.com, rjw@sisk.pl,
	hauke@hauke-m.de, lars@metafoo.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert the mwifiex/pci driver to use dev_pm_ops for power management and
remove Legacy PM handling. This change re-uses existing suspend and resume
interfaces for dev_pm_ops, and changes CONFIG_PM ifdefs to CONFIG_PM_SLEEP
as the driver does not support run-time PM.

Signed-off-by: Shuah Khan <shuah.kh@samsung.com>
---
 drivers/net/wireless/mwifiex/pcie.c |   26 +++++++++++++++++---------
 1 file changed, 17 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/mwifiex/pcie.c b/drivers/net/wireless/mwifiex/pcie.c
index 20c9c4c..4a57eb4 100644
--- a/drivers/net/wireless/mwifiex/pcie.c
+++ b/drivers/net/wireless/mwifiex/pcie.c
@@ -76,7 +76,7 @@ static bool mwifiex_pcie_ok_to_access_hw(struct mwifiex_adapter *adapter)
 	return false;
 }
 
-#ifdef CONFIG_PM
+#ifdef CONFIG_PM_SLEEP
 /*
  * Kernel needs to suspend all functions separately. Therefore all
  * registered functions must have drivers with suspend and resume
@@ -85,11 +85,12 @@ static bool mwifiex_pcie_ok_to_access_hw(struct mwifiex_adapter *adapter)
  * If already not suspended, this function allocates and sends a host
  * sleep activate request to the firmware and turns off the traffic.
  */
-static int mwifiex_pcie_suspend(struct pci_dev *pdev, pm_message_t state)
+static int mwifiex_pcie_suspend(struct device *dev)
 {
 	struct mwifiex_adapter *adapter;
 	struct pcie_service_card *card;
 	int hs_actived;
+	struct pci_dev *pdev = to_pci_dev(dev);
 
 	if (pdev) {
 		card = (struct pcie_service_card *) pci_get_drvdata(pdev);
@@ -120,10 +121,11 @@ static int mwifiex_pcie_suspend(struct pci_dev *pdev, pm_message_t state)
  * If already not resumed, this function turns on the traffic and
  * sends a host sleep cancel request to the firmware.
  */
-static int mwifiex_pcie_resume(struct pci_dev *pdev)
+static int mwifiex_pcie_resume(struct device *dev)
 {
 	struct mwifiex_adapter *adapter;
 	struct pcie_service_card *card;
+	struct pci_dev *pdev = to_pci_dev(dev);
 
 	if (pdev) {
 		card = (struct pcie_service_card *) pci_get_drvdata(pdev);
@@ -211,9 +213,9 @@ static void mwifiex_pcie_remove(struct pci_dev *pdev)
 	wait_for_completion(&adapter->fw_load);
 
 	if (user_rmmod) {
-#ifdef CONFIG_PM
+#ifdef CONFIG_PM_SLEEP
 		if (adapter->is_suspended)
-			mwifiex_pcie_resume(pdev);
+			mwifiex_pcie_resume(&pdev->dev);
 #endif
 
 		for (i = 0; i < adapter->priv_num; i++)
@@ -249,16 +251,22 @@ static DEFINE_PCI_DEVICE_TABLE(mwifiex_ids) = {
 
 MODULE_DEVICE_TABLE(pci, mwifiex_ids);
 
+#ifdef CONFIG_PM_SLEEP
+/* Power Management Hooks */
+static SIMPLE_DEV_PM_OPS(mwifiex_pcie_pm_ops, mwifiex_pcie_suspend,
+				mwifiex_pcie_resume);
+#endif
+
 /* PCI Device Driver */
 static struct pci_driver __refdata mwifiex_pcie = {
 	.name     = "mwifiex_pcie",
 	.id_table = mwifiex_ids,
 	.probe    = mwifiex_pcie_probe,
 	.remove   = mwifiex_pcie_remove,
-#ifdef CONFIG_PM
-	/* Power Management Hooks */
-	.suspend  = mwifiex_pcie_suspend,
-	.resume   = mwifiex_pcie_resume,
+#ifdef CONFIG_PM_SLEEP
+	.driver   = {
+		.pm = &mwifiex_pcie_pm_ops,
+	},
 #endif
 };
 
-- 
1.7.10.4
