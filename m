From: Shuah Khan <shuah.kh-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] wireless: Convert mwifiex/pcie to dev_pm_ops from legacy pm ops
Date: Tue,  2 Jul 2013 09:24:35 -0600
Message-ID: <1372778675-2909-1-git-send-email-shuah.kh@samsung.com>
Cc: Shuah Khan <shuah.kh-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	shuahkhan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: bzhao-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Convert the mwifiex/pci driver to use dev_pm_ops for power management and
remove Legacy PM handling. This change re-uses existing suspend and resume
interfaces for dev_pm_ops.

Signed-off-by: Shuah Khan <shuah.kh-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/wireless/mwifiex/pcie.c |   34 ++++++++++++++++++++++++++++------
 1 file changed, 28 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/mwifiex/pcie.c b/drivers/net/wireless/mwifiex/pcie.c
index 20c9c4c..b169318 100644
--- a/drivers/net/wireless/mwifiex/pcie.c
+++ b/drivers/net/wireless/mwifiex/pcie.c
@@ -85,7 +85,7 @@ static bool mwifiex_pcie_ok_to_access_hw(struct mwifiex_adapter *adapter)
  * If already not suspended, this function allocates and sends a host
  * sleep activate request to the firmware and turns off the traffic.
  */
-static int mwifiex_pcie_suspend(struct pci_dev *pdev, pm_message_t state)
+static int __mwifiex_pcie_suspend(struct pci_dev *pdev)
 {
 	struct mwifiex_adapter *adapter;
 	struct pcie_service_card *card;
@@ -112,6 +112,13 @@ static int mwifiex_pcie_suspend(struct pci_dev *pdev, pm_message_t state)
 	return 0;
 }
 
+static int mwifiex_pcie_suspend(struct device *dev)
+{
+	struct pci_dev *pdev = to_pci_dev(dev);
+
+	return __mwifiex_pcie_suspend(pdev);
+}
+
 /*
  * Kernel needs to suspend all functions separately. Therefore all
  * registered functions must have drivers with suspend and resume
@@ -120,7 +127,7 @@ static int mwifiex_pcie_suspend(struct pci_dev *pdev, pm_message_t state)
  * If already not resumed, this function turns on the traffic and
  * sends a host sleep cancel request to the firmware.
  */
-static int mwifiex_pcie_resume(struct pci_dev *pdev)
+static int __mwifiex_pcie_resume(struct pci_dev *pdev)
 {
 	struct mwifiex_adapter *adapter;
 	struct pcie_service_card *card;
@@ -150,6 +157,13 @@ static int mwifiex_pcie_resume(struct pci_dev *pdev)
 
 	return 0;
 }
+
+static int mwifiex_pcie_resume(struct device *dev)
+{
+	struct pci_dev *pdev = to_pci_dev(dev);
+
+	return __mwifiex_pcie_resume(pdev);
+}
 #endif
 
 /*
@@ -213,7 +227,7 @@ static void mwifiex_pcie_remove(struct pci_dev *pdev)
 	if (user_rmmod) {
 #ifdef CONFIG_PM
 		if (adapter->is_suspended)
-			mwifiex_pcie_resume(pdev);
+			__mwifiex_pcie_resume(pdev);
 #endif
 
 		for (i = 0; i < adapter->priv_num; i++)
@@ -249,6 +263,14 @@ static DEFINE_PCI_DEVICE_TABLE(mwifiex_ids) = {
 
 MODULE_DEVICE_TABLE(pci, mwifiex_ids);
 
+#ifdef CONFIG_PM
+/* Power Management Hooks */
+static const struct dev_pm_ops mwifiex_pcie_pm_ops = {
+	.suspend = mwifiex_pcie_suspend,
+	.resume = mwifiex_pcie_resume,
+};
+#endif
+
 /* PCI Device Driver */
 static struct pci_driver __refdata mwifiex_pcie = {
 	.name     = "mwifiex_pcie",
@@ -256,9 +278,9 @@ static struct pci_driver __refdata mwifiex_pcie = {
 	.probe    = mwifiex_pcie_probe,
 	.remove   = mwifiex_pcie_remove,
 #ifdef CONFIG_PM
-	/* Power Management Hooks */
-	.suspend  = mwifiex_pcie_suspend,
-	.resume   = mwifiex_pcie_resume,
+	.driver   = {
+		.pm = &mwifiex_pcie_pm_ops,
+	},
 #endif
 };
 
-- 
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
