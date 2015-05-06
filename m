From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH v2 net-next 7/9] be2net: use be_virtfn() instead of !be_physfn()
Date: Wed,  6 May 2015 05:30:38 -0400
Message-ID: <1430904640-31918-8-git-send-email-sathya.perla@avagotech.com>
References: <1430904640-31918-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:51843 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752381AbbEFJmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 05:42:47 -0400
In-Reply-To: <1430904640-31918-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

Use be_virtfn() to determine a VF instead of !be_physfn() for better
readability.

Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |  4 ++--
 drivers/net/ethernet/emulex/benet/be_main.c | 11 ++++++-----
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 095b1dc..f03ec2d 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1458,7 +1458,7 @@ int be_cmd_if_create(struct be_adapter *adapter, u32 cap_flags, u32 en_flags,
 		*if_handle = le32_to_cpu(resp->interface_id);
 
 		/* Hack to retrieve VF's pmac-id on BE3 */
-		if (BE3_chip(adapter) && !be_physfn(adapter))
+		if (BE3_chip(adapter) && be_virtfn(adapter))
 			adapter->pmac_id[0] = le32_to_cpu(resp->pmac_id);
 	}
 	return status;
@@ -3271,7 +3271,7 @@ static bool be_is_wol_excluded(struct be_adapter *adapter)
 {
 	struct pci_dev *pdev = adapter->pdev;
 
-	if (!be_physfn(adapter))
+	if (be_virtfn(adapter))
 		return true;
 
 	switch (pdev->subsystem_device) {
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 5d60ba0..e88683c 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3110,7 +3110,7 @@ fail:
 	dev_warn(dev, "MSIx enable failed\n");
 
 	/* INTx is not supported in VFs, so fail probe if enable_msix fails */
-	if (!be_physfn(adapter))
+	if (be_virtfn(adapter))
 		return num_vec;
 	return 0;
 }
@@ -3157,7 +3157,7 @@ static int be_irq_register(struct be_adapter *adapter)
 		if (status == 0)
 			goto done;
 		/* INTx is not supported for VF */
-		if (!be_physfn(adapter))
+		if (be_virtfn(adapter))
 			return status;
 	}
 
@@ -3838,8 +3838,9 @@ static void BEx_get_resources(struct be_adapter *adapter,
 	 *    *only* if it is RSS-capable.
 	 */
 	if (BE2_chip(adapter) || use_sriov ||  (adapter->port_num > 1) ||
-	    !be_physfn(adapter) || (be_is_mc(adapter) &&
-	    !(adapter->function_caps & BE_FUNCTION_CAPS_RSS))) {
+	    be_virtfn(adapter) ||
+	    (be_is_mc(adapter) &&
+	     !(adapter->function_caps & BE_FUNCTION_CAPS_RSS))) {
 		res->max_tx_qs = 1;
 	} else if (adapter->function_caps & BE_FUNCTION_CAPS_SUPER_NIC) {
 		struct be_resources super_nic_res = {0};
@@ -5286,7 +5287,7 @@ static void be_unmap_pci_bars(struct be_adapter *adapter)
 
 static int db_bar(struct be_adapter *adapter)
 {
-	if (lancer_chip(adapter) || !be_physfn(adapter))
+	if (lancer_chip(adapter) || be_virtfn(adapter))
 		return 0;
 	else
 		return 4;
-- 
2.2.0
