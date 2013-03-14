From: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH v2 net-next 10/22] cxgb4: Disable SR-IOV support for PF4-7 for T5
Date: Thu, 14 Mar 2013 20:38:56 +0530
Message-ID: <1363273748-25330-11-git-send-email-vipul@chelsio.com>
References: <1363273748-25330-1-git-send-email-vipul@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org,
	JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	naresh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	arvindb-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, abhishek-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1363273748-25330-1-git-send-email-vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Santosh Rastapur <santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>

All T5 adapters will only support VFs on PF0-3 despite the ability of the
hardware to support them on PF4-7.  This keeps our T4 and T5 adapters more
similar which simplifies host driver software.

Signed-off-by: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
v2: Replaced #ifdef with portable interface wmb in ring_tx_db

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

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
