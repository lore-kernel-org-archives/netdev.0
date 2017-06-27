From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 13/14] nfp: allocate a private workqueue for driver work
Date: Tue, 27 Jun 2017 00:50:27 -0700
Message-ID: <20170627075028.4009-14-jakub.kicinski@netronome.com>
References: <20170627075028.4009-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34764 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752338AbdF0HvR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 03:51:17 -0400
Received: by mail-pf0-f177.google.com with SMTP id s66so12615901pfs.1
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 00:51:17 -0700 (PDT)
In-Reply-To: <20170627075028.4009-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we grab pf->lock around pci_enable_sriov() we can no longer
safely queue work which may also grab that lock onto system workqueue.
pci_enable_sriov() will flush system workqueue as part to wait for VF
probing.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_main.c     | 9 +++++++++
 drivers/net/ethernet/netronome/nfp/nfp_main.h     | 4 ++++
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c | 2 +-
 3 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.c b/drivers/net/ethernet/netronome/nfp/nfp_main.c
index a0f3df8572d6..d67969d3e484 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.c
@@ -376,6 +376,12 @@ static int nfp_pci_probe(struct pci_dev *pdev,
 	pci_set_drvdata(pdev, pf);
 	pf->pdev = pdev;
 
+	pf->wq = alloc_workqueue("nfp-%s", 0, 2, pci_name(pdev));
+	if (!pf->wq) {
+		err = -ENOMEM;
+		goto err_pci_priv_unset;
+	}
+
 	pf->cpp = nfp_cpp_from_nfp6000_pcie(pdev);
 	if (IS_ERR_OR_NULL(pf->cpp)) {
 		err = PTR_ERR(pf->cpp);
@@ -445,6 +451,8 @@ static int nfp_pci_probe(struct pci_dev *pdev,
 	kfree(pf->hwinfo);
 	nfp_cpp_free(pf->cpp);
 err_disable_msix:
+	destroy_workqueue(pf->wq);
+err_pci_priv_unset:
 	pci_set_drvdata(pdev, NULL);
 	mutex_destroy(&pf->lock);
 	devlink_free(devlink);
@@ -477,6 +485,7 @@ static void nfp_pci_remove(struct pci_dev *pdev)
 	if (pf->fw_loaded)
 		nfp_fw_unload(pf);
 
+	destroy_workqueue(pf->wq);
 	pci_set_drvdata(pdev, NULL);
 	kfree(pf->hwinfo);
 	nfp_cpp_free(pf->cpp);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.h b/drivers/net/ethernet/netronome/nfp/nfp_main.h
index edc14dc78674..a08cfba7e68e 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.h
@@ -89,6 +89,7 @@ struct nfp_rtsym_table;
  * @num_vnics:		Number of vNICs spawned
  * @vnics:		Linked list of vNIC structures (struct nfp_net)
  * @ports:		Linked list of port structures (struct nfp_port)
+ * @wq:			Workqueue for running works which need to grab @lock
  * @port_refresh_work:	Work entry for taking netdevs out
  * @lock:		Protects all fields which may change after probe
  */
@@ -131,7 +132,10 @@ struct nfp_pf {
 
 	struct list_head vnics;
 	struct list_head ports;
+
+	struct workqueue_struct *wq;
 	struct work_struct port_refresh_work;
+
 	struct mutex lock;
 };
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 4d22e1cc013e..c85a2f18c4df 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -682,7 +682,7 @@ void nfp_net_refresh_port_table(struct nfp_port *port)
 
 	set_bit(NFP_PORT_CHANGED, &port->flags);
 
-	schedule_work(&pf->port_refresh_work);
+	queue_work(pf->wq, &pf->port_refresh_work);
 }
 
 int nfp_net_refresh_eth_port(struct nfp_port *port)
-- 
2.11.0
