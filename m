From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] hns3: fix unused function warning
Date: Mon,  7 Aug 2017 12:41:53 +0200
Message-ID: <20170807104230.3564976-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "Wei Hu (Xavier)" <xavier.huwei@huawei.com>,
        lipeng <lipeng321@huawei.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Without CONFIG_PCI_IOV, we get a harmless warning about an
unused function:

drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c:2273:13: error: 'hclge_disable_sriov' defined but not used [-Werror=unused-function]

The #ifdefs in this driver are obviously wrong, so this just
removes them and uses an IS_ENABLED() check that does the same
thing correctly in a more readable way.

Fixes: 46a3df9f9718 ("net: hns3: Add HNS3 Acceleration Engine & Compatibility Layer Support")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.c    | 27 ++++++++++------------
 1 file changed, 12 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index 3611991689bc..7440e85b607c 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -2272,19 +2272,17 @@ static void hclge_service_task(struct work_struct *work)
 
 static void hclge_disable_sriov(struct hclge_dev *hdev)
 {
-#ifdef CONFIG_PCI_IOV
-		/* If our VFs are assigned we cannot shut down SR-IOV
-		 * without causing issues, so just leave the hardware
-		 * available but disabled
-		 */
-		if (pci_vfs_assigned(hdev->pdev)) {
-			dev_warn(&hdev->pdev->dev,
-				 "disabling driver while VFs are assigned\n");
-			return;
-		}
+	/* If our VFs are assigned we cannot shut down SR-IOV
+	 * without causing issues, so just leave the hardware
+	 * available but disabled
+	 */
+	if (pci_vfs_assigned(hdev->pdev)) {
+		dev_warn(&hdev->pdev->dev,
+			 "disabling driver while VFs are assigned\n");
+		return;
+	}
 
-		pci_disable_sriov(hdev->pdev);
-#endif
+	pci_disable_sriov(hdev->pdev);
 }
 
 struct hclge_vport *hclge_get_vport(struct hnae3_handle *handle)
@@ -4182,9 +4180,8 @@ static void hclge_uninit_ae_dev(struct hnae3_ae_dev *ae_dev)
 
 	set_bit(HCLGE_STATE_DOWN, &hdev->state);
 
-#ifdef CONFIG_PCI_IOV
-	hclge_disable_sriov(hdev);
-#endif
+	if (IS_ENABLED(CONFIG_PCI_IOV))
+		hclge_disable_sriov(hdev);
 
 	if (hdev->service_timer.data)
 		del_timer_sync(&hdev->service_timer);
-- 
2.9.0
