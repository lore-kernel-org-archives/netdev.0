From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 3/5] be2net: fix to get max VFs supported from
 adapter
Date: Wed, 6 Apr 2011 23:08:17 -0500
Message-ID: <20110407040817.GA4215@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:55054 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750941Ab1DGEIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 00:08:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The user supplied num_vfs value need not be compared
against a static BE_MAX_VF, but can be checked against
the actual VFs that the device can support.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_main.c |   22 ++++++++++++++--------
 1 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 4910055..9d6982a 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1947,7 +1947,20 @@ static void be_sriov_enable(struct be_adapter *adapter)
 	be_check_sriov_fn_type(adapter);
 #ifdef CONFIG_PCI_IOV
 	if (be_physfn(adapter) && num_vfs) {
-		int status;
+		int status, pos;
+		u16 nvfs;
+
+		pos = pci_find_ext_capability(adapter->pdev,
+						PCI_EXT_CAP_ID_SRIOV);
+		pci_read_config_word(adapter->pdev,
+					pos + PCI_SRIOV_TOTAL_VF, &nvfs);
+
+		if (num_vfs > nvfs) {
+			dev_info(&adapter->pdev->dev,
+					"Device supports %d VFs and not %d\n",
+					nvfs, num_vfs);
+			num_vfs = nvfs;
+		}
 
 		status = pci_enable_sriov(adapter->pdev, num_vfs);
 		adapter->sriov_enabled = status ? false : true;
@@ -3281,13 +3294,6 @@ static int __init be_init_module(void)
 		rx_frag_size = 2048;
 	}
 
-	if (num_vfs > 32) {
-		printk(KERN_WARNING DRV_NAME
-			" : Module param num_vfs must not be greater than 32."
-			"Using 32\n");
-		num_vfs = 32;
-	}
-
 	return pci_register_driver(&be_driver);
 }
 module_init(be_init_module);
-- 
1.7.1

