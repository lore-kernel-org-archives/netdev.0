From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH net-next 10/22] cxgb4: Disable SR-IOV support for PF4-7 for T5
Date: Tue, 12 Mar 2013 17:16:22 +0530
Message-ID: <1363088794-31453-11-git-send-email-vipul@chelsio.com>
References: <1363088794-31453-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com,
	JBottomley@parallels.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	naresh@chelsio.com, divy@chelsio.com, santosh@chelsio.com,
	arvindb@chelsio.com, abhishek@chelsio.com,
	Vipul Pandya <vipul@chelsio.com>
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:29498 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932072Ab3CLLxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 07:53:08 -0400
In-Reply-To: <1363088794-31453-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Santosh Rastapur <santosh@chelsio.com>

All T5 adapters will only support VFs on PF0-3 despite the ability of the
hardware to support them on PF4-7.  This keeps our T4 and T5 adapters more
similar which simplifies host driver software.

Signed-off-by: Vipul Pandya <vipul@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |    8 ++++----
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   21 ++++++---------------
 2 files changed, 10 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 45b18bd..681804b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -534,11 +534,11 @@ enum chip_type {
 
 #ifdef CONFIG_PCI_IOV
 
-/* T4 - 4 PFs support SRIOV
- * T5 - 8 PFs support SRIOV
+/* T4 supports SRIOV on PF0-3 and T5 on PF0-7.  However, the Serial
+ * Configuration initialization for T5 only has SR-IOV functionality enabled
+ * on PF0-3 in order to simplify everything.
  */
-#define NUM_OF_PF_WITH_SRIOV_T4 4
-#define NUM_OF_PF_WITH_SRIOV_T5 8
+#define NUM_OF_PF_WITH_SRIOV 4
 
 #endif
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index c502e36..a59bb23 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -360,14 +360,13 @@ static bool vf_acls;
 module_param(vf_acls, bool, 0644);
 MODULE_PARM_DESC(vf_acls, "if set enable virtualization L2 ACL enforcement");
 
-/* Since T5 has more num of PFs, using NUM_OF_PF_WITH_SRIOV_T5
- * macro as num_vf array size
+/* Configure the number of PCI-E Virtual Function which are to be instantiated
+ * on SR-IOV Capable Physical Functions.
  */
-static unsigned int num_vf[NUM_OF_PF_WITH_SRIOV_T5];
+static unsigned int num_vf[NUM_OF_PF_WITH_SRIOV];
 
 module_param_array(num_vf, uint, NULL, 0644);
-MODULE_PARM_DESC(num_vf,
-		 "number of VFs for each of PFs 0-3 for T4 and PFs 0-7 for T5");
+MODULE_PARM_DESC(num_vf, "number of VFs for each of PFs 0-3");
 #endif
 
 /*
@@ -4633,10 +4632,8 @@ static int adap_init0_no_config(struct adapter *adapter, int reset)
 	 */
 	{
 		int pf, vf;
-		int max_no_pf = is_t4(adapter->chip) ? NUM_OF_PF_WITH_SRIOV_T4 :
-				NUM_OF_PF_WITH_SRIOV_T5;
 
-		for (pf = 0; pf < max_no_pf; pf++) {
+		for (pf = 0; pf < ARRAY_SIZE(num_vf); pf++) {
 			if (num_vf[pf] <= 0)
 				continue;
 
@@ -5483,9 +5480,6 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct port_info *pi;
 	bool highdma = false;
 	struct adapter *adapter = NULL;
-#ifdef CONFIG_PCI_IOV
-	int max_no_pf;
-#endif
 
 	printk_once(KERN_INFO "%s - version %s\n", DRV_DESC, DRV_VERSION);
 
@@ -5704,10 +5698,7 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 sriov:
 #ifdef CONFIG_PCI_IOV
-	max_no_pf = is_t4(adapter->chip) ? NUM_OF_PF_WITH_SRIOV_T4 :
-			NUM_OF_PF_WITH_SRIOV_T5;
-
-	if (func < max_no_pf && num_vf[func] > 0)
+	if (func < ARRAY_SIZE(num_vf) && num_vf[func] > 0)
 		if (pci_enable_sriov(pdev, num_vf[func]) == 0)
 			dev_info(&pdev->dev,
 				 "instantiated %u virtual functions\n",
-- 
1.7.1
