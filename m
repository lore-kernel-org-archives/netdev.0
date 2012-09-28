From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 4/4] be2net: fixup log messages
Date: Fri, 28 Sep 2012 20:09:44 +0530
Message-ID: <e698cd68-540d-4a7a-bd76-2e9c73ddf19c@CMEXHTCAS2.ad.emulex.com>
References: <1348843184-22214-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:39495 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758455Ab2I1PDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 11:03:33 -0400
In-Reply-To: <1348843184-22214-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added and modified a few log messages mostly in probe path.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    3 ++
 drivers/net/ethernet/emulex/benet/be_main.c |   34 ++++++++++++++++++++++----
 2 files changed, 31 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 46a19af..af60bb2 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -2425,6 +2425,9 @@ int be_cmd_req_native_mode(struct be_adapter *adapter)
 		struct be_cmd_resp_set_func_cap *resp = embedded_payload(wrb);
 		adapter->be3_native = le32_to_cpu(resp->cap_flags) &
 					CAPABILITY_BE3_NATIVE_ERX_API;
+		if (!adapter->be3_native)
+			dev_warn(&adapter->pdev->dev,
+				 "adapter not in advanced mode\n");
 	}
 err:
 	mutex_unlock(&adapter->mbox_lock);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 4855dd6..6accb0c 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1896,6 +1896,8 @@ static int be_tx_qs_create(struct be_adapter *adapter)
 			return status;
 	}
 
+	dev_info(&adapter->pdev->dev, "created %d TX queue(s)\n",
+		 adapter->num_tx_qs);
 	return 0;
 }
 
@@ -1946,10 +1948,9 @@ static int be_rx_cqs_create(struct be_adapter *adapter)
 			return rc;
 	}
 
-	if (adapter->num_rx_qs != MAX_RX_QS)
-		dev_info(&adapter->pdev->dev,
-			"Created only %d receive queues\n", adapter->num_rx_qs);
-
+	dev_info(&adapter->pdev->dev,
+		 "created %d RSS queue(s) and 1 default RX queue\n",
+		 adapter->num_rx_qs - 1);
 	return 0;
 }
 
@@ -2187,6 +2188,7 @@ static void be_msix_enable(struct be_adapter *adapter)
 {
 #define BE_MIN_MSIX_VECTORS		1
 	int i, status, num_vec, num_roce_vec = 0;
+	struct device *dev = &adapter->pdev->dev;
 
 	/* If RSS queues are not used, need a vec for default RX Q */
 	num_vec = min(be_num_rss_want(adapter), num_online_cpus());
@@ -2211,6 +2213,8 @@ static void be_msix_enable(struct be_adapter *adapter)
 				num_vec) == 0)
 			goto done;
 	}
+
+	dev_warn(dev, "MSIx enable failed\n");
 	return;
 done:
 	if (be_roce_supported(adapter)) {
@@ -2224,6 +2228,7 @@ done:
 		}
 	} else
 		adapter->num_msix_vec = num_vec;
+	dev_info(dev, "enabled %d MSI-x vector(s)\n", adapter->num_msix_vec);
 	return;
 }
 
@@ -3797,6 +3802,23 @@ static bool be_reset_required(struct be_adapter *adapter)
 	return be_find_vfs(adapter, ENABLED) > 0 ? false : true;
 }
 
+static char *mc_name(struct be_adapter *adapter)
+{
+	if (adapter->function_mode & FLEX10_MODE)
+		return "FLEX10";
+	else if (adapter->function_mode & VNIC_MODE)
+		return "vNIC";
+	else if (adapter->function_mode & UMC_ENABLED)
+		return "UMC";
+	else
+		return "";
+}
+
+static inline char *func_name(struct be_adapter *adapter)
+{
+	return be_physfn(adapter) ? "PF" : "VF";
+}
+
 static int __devinit be_probe(struct pci_dev *pdev,
 			const struct pci_device_id *pdev_id)
 {
@@ -3901,8 +3923,8 @@ static int __devinit be_probe(struct pci_dev *pdev,
 
 	be_cmd_query_port_name(adapter, &port_name);
 
-	dev_info(&pdev->dev, "%s: %s port %c\n", netdev->name, nic_name(pdev),
-		 port_name);
+	dev_info(&pdev->dev, "%s: %s %s port %c\n", nic_name(pdev),
+		 func_name(adapter), mc_name(adapter), port_name);
 
 	return 0;
 
-- 
1.7.4
