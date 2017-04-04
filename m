From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 03/14] nfp: add mutex protection for the port list
Date: Tue,  4 Apr 2017 16:12:24 -0700
Message-ID: <20170404231235.32027-4-jakub.kicinski@netronome.com>
References: <20170404231235.32027-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:33666 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754665AbdDDXM5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 19:12:57 -0400
Received: by mail-pg0-f51.google.com with SMTP id x125so164961099pgb.0
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 16:12:56 -0700 (PDT)
In-Reply-To: <20170404231235.32027-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We will want to unregister netdevs after their port got reconfigured.
For that we need to make sure manipulations of port list from the
port reconfiguration flow will not race with driver's .remove()
callback.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_main.c     |  3 +--
 drivers/net/ethernet/netronome/nfp/nfp_main.h     |  3 +++
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c | 19 +++++++++++++++++--
 3 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.c b/drivers/net/ethernet/netronome/nfp/nfp_main.c
index dedac720fb29..96266796fd09 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.c
@@ -385,8 +385,7 @@ static void nfp_pci_remove(struct pci_dev *pdev)
 {
 	struct nfp_pf *pf = pci_get_drvdata(pdev);
 
-	if (!list_empty(&pf->ports))
-		nfp_net_pci_remove(pf);
+	nfp_net_pci_remove(pf);
 
 	nfp_pcie_sriov_disable(pdev);
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.h b/drivers/net/ethernet/netronome/nfp/nfp_main.h
index bb15a5724bf7..b7ceec9a5783 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.h
@@ -42,6 +42,7 @@
 #include <linux/list.h>
 #include <linux/types.h>
 #include <linux/msi.h>
+#include <linux/mutex.h>
 #include <linux/pci.h>
 
 struct dentry;
@@ -67,6 +68,7 @@ struct nfp_eth_table;
  * @num_ports:		Number of adapter ports app firmware supports
  * @num_netdevs:	Number of netdevs spawned
  * @ports:		Linked list of port structures (struct nfp_net)
+ * @port_lock:		Protects @ports, @num_ports, @num_netdevs
  */
 struct nfp_pf {
 	struct pci_dev *pdev;
@@ -92,6 +94,7 @@ struct nfp_pf {
 	unsigned int num_netdevs;
 
 	struct list_head ports;
+	struct mutex port_lock;
 };
 
 extern struct pci_driver nfp_netvf_pci_driver;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 1644954f52cd..4d602b1ddc90 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -481,17 +481,22 @@ int nfp_net_pci_probe(struct nfp_pf *pf)
 	int stride;
 	int err;
 
+	mutex_init(&pf->port_lock);
+
 	/* Verify that the board has completed initialization */
 	if (!nfp_is_ready(pf->cpp)) {
 		nfp_err(pf->cpp, "NFP is not ready for NIC operation.\n");
 		return -EINVAL;
 	}
 
+	mutex_lock(&pf->port_lock);
 	pf->num_ports = nfp_net_pf_get_num_ports(pf);
 
 	ctrl_bar = nfp_net_pf_map_ctrl_bar(pf);
-	if (!ctrl_bar)
-		return pf->fw_loaded ? -EINVAL : -EPROBE_DEFER;
+	if (!ctrl_bar) {
+		err = pf->fw_loaded ? -EINVAL : -EPROBE_DEFER;
+		goto err_unlock;
+	}
 
 	nfp_net_get_fw_version(&fw_ver, ctrl_bar);
 	if (fw_ver.resv || fw_ver.class != NFP_NET_CFG_VERSION_CLASS_GENERIC) {
@@ -565,6 +570,8 @@ int nfp_net_pci_probe(struct nfp_pf *pf)
 	if (err)
 		goto err_clean_ddir;
 
+	mutex_unlock(&pf->port_lock);
+
 	return 0;
 
 err_clean_ddir:
@@ -574,6 +581,8 @@ int nfp_net_pci_probe(struct nfp_pf *pf)
 	nfp_cpp_area_release_free(pf->tx_area);
 err_ctrl_unmap:
 	nfp_cpp_area_release_free(pf->ctrl_area);
+err_unlock:
+	mutex_unlock(&pf->port_lock);
 	return err;
 }
 
@@ -581,6 +590,10 @@ void nfp_net_pci_remove(struct nfp_pf *pf)
 {
 	struct nfp_net *nn;
 
+	mutex_lock(&pf->port_lock);
+	if (list_empty(&pf->ports))
+		goto out;
+
 	list_for_each_entry(nn, &pf->ports, port_list) {
 		nfp_net_debugfs_dir_clean(&nn->debugfs_dir);
 
@@ -597,4 +610,6 @@ void nfp_net_pci_remove(struct nfp_pf *pf)
 	nfp_cpp_area_release_free(pf->rx_area);
 	nfp_cpp_area_release_free(pf->tx_area);
 	nfp_cpp_area_release_free(pf->ctrl_area);
+out:
+	mutex_unlock(&pf->port_lock);
 }
-- 
2.11.0
