From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 05/14] nfp: add port state refresh
Date: Tue,  4 Apr 2017 16:12:26 -0700
Message-ID: <20170404231235.32027-6-jakub.kicinski@netronome.com>
References: <20170404231235.32027-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:35086 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755279AbdDDXM6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 19:12:58 -0400
Received: by mail-pg0-f54.google.com with SMTP id 81so165144345pgh.2
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 16:12:58 -0700 (PDT)
In-Reply-To: <20170404231235.32027-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We will need a way of refreshing port state for link settings
get/set.  For get we need to refresh port speed and type.

When settings are changed the reconfiguration may require
reboot before it's effective.  Unregister netdevs affected
by reconfiguration from a workqueue.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_main.h     |  3 +
 drivers/net/ethernet/netronome/nfp/nfp_net.h      |  1 +
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c | 89 +++++++++++++++++++++--
 3 files changed, 85 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.h b/drivers/net/ethernet/netronome/nfp/nfp_main.h
index b7ceec9a5783..b57de047b002 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.h
@@ -44,6 +44,7 @@
 #include <linux/msi.h>
 #include <linux/mutex.h>
 #include <linux/pci.h>
+#include <linux/workqueue.h>
 
 struct dentry;
 struct pci_dev;
@@ -69,6 +70,7 @@ struct nfp_eth_table;
  * @num_netdevs:	Number of netdevs spawned
  * @ports:		Linked list of port structures (struct nfp_net)
  * @port_lock:		Protects @ports, @num_ports, @num_netdevs
+ * @port_refresh_work:	Work entry for taking netdevs out
  */
 struct nfp_pf {
 	struct pci_dev *pdev;
@@ -94,6 +96,7 @@ struct nfp_pf {
 	unsigned int num_netdevs;
 
 	struct list_head ports;
+	struct work_struct port_refresh_work;
 	struct mutex port_lock;
 };
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 91e963b5104f..052db9208fbb 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -813,6 +813,7 @@ struct nfp_net_dp *nfp_net_clone_dp(struct nfp_net *nn);
 int nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *new);
 
 bool nfp_net_link_changed_read_clear(struct nfp_net *nn);
+void nfp_net_refresh_port_config(struct nfp_net *nn);
 
 #ifdef CONFIG_NFP_DEBUG
 void nfp_net_debugfs_create(void);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 4d602b1ddc90..8e975c36877c 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -47,6 +47,7 @@
 #include <linux/pci_regs.h>
 #include <linux/msi.h>
 #include <linux/random.h>
+#include <linux/rtnetlink.h>
 
 #include "nfpcore/nfp.h"
 #include "nfpcore/nfp_cpp.h"
@@ -468,6 +469,82 @@ nfp_net_pf_spawn_netdevs(struct nfp_pf *pf,
 	return err;
 }
 
+static void nfp_net_pci_remove_finish(struct nfp_pf *pf)
+{
+	nfp_net_debugfs_dir_clean(&pf->ddir);
+
+	nfp_net_irqs_disable(pf->pdev);
+	kfree(pf->irq_entries);
+
+	nfp_cpp_area_release_free(pf->rx_area);
+	nfp_cpp_area_release_free(pf->tx_area);
+	nfp_cpp_area_release_free(pf->ctrl_area);
+}
+
+static void nfp_net_refresh_netdevs(struct work_struct *work)
+{
+	struct nfp_pf *pf = container_of(work, struct nfp_pf,
+					 port_refresh_work);
+	struct nfp_net *nn, *next;
+
+	mutex_lock(&pf->port_lock);
+
+	/* Check for nfp_net_pci_remove() racing against us */
+	if (list_empty(&pf->ports))
+		goto out;
+
+	list_for_each_entry_safe(nn, next, &pf->ports, port_list) {
+		if (!nn->eth_port) {
+			nfp_warn(pf->cpp, "Warning: port %d not present after reconfig\n",
+				 nn->eth_port->eth_index);
+			continue;
+		}
+		if (!nn->eth_port->override_changed)
+			continue;
+
+		nn_warn(nn, "Port config changed, unregistering. Reboot required before port will be operational again.\n");
+
+		nfp_net_debugfs_dir_clean(&nn->debugfs_dir);
+		nfp_net_netdev_clean(nn->dp.netdev);
+
+		list_del(&nn->port_list);
+		pf->num_netdevs--;
+		nfp_net_netdev_free(nn);
+	}
+
+	if (list_empty(&pf->ports))
+		nfp_net_pci_remove_finish(pf);
+out:
+	mutex_unlock(&pf->port_lock);
+}
+
+void nfp_net_refresh_port_config(struct nfp_net *nn)
+{
+	struct nfp_pf *pf = pci_get_drvdata(nn->pdev);
+	struct nfp_eth_table *old_table;
+
+	ASSERT_RTNL();
+
+	old_table = pf->eth_tbl;
+
+	list_for_each_entry(nn, &pf->ports, port_list)
+		nfp_net_link_changed_read_clear(nn);
+
+	pf->eth_tbl = nfp_eth_read_ports(pf->cpp);
+	if (!pf->eth_tbl) {
+		pf->eth_tbl = old_table;
+		nfp_err(pf->cpp, "Error refreshing port config!\n");
+		return;
+	}
+
+	list_for_each_entry(nn, &pf->ports, port_list)
+		nn->eth_port = nfp_net_find_port(pf, nn->eth_port->eth_index);
+
+	kfree(old_table);
+
+	schedule_work(&pf->port_refresh_work);
+}
+
 /*
  * PCI device functions
  */
@@ -481,6 +558,7 @@ int nfp_net_pci_probe(struct nfp_pf *pf)
 	int stride;
 	int err;
 
+	INIT_WORK(&pf->port_refresh_work, nfp_net_refresh_netdevs);
 	mutex_init(&pf->port_lock);
 
 	/* Verify that the board has completed initialization */
@@ -602,14 +680,9 @@ void nfp_net_pci_remove(struct nfp_pf *pf)
 
 	nfp_net_pf_free_netdevs(pf);
 
-	nfp_net_debugfs_dir_clean(&pf->ddir);
-
-	nfp_net_irqs_disable(pf->pdev);
-	kfree(pf->irq_entries);
-
-	nfp_cpp_area_release_free(pf->rx_area);
-	nfp_cpp_area_release_free(pf->tx_area);
-	nfp_cpp_area_release_free(pf->ctrl_area);
+	nfp_net_pci_remove_finish(pf);
 out:
 	mutex_unlock(&pf->port_lock);
+
+	cancel_work_sync(&pf->port_refresh_work);
 }
-- 
2.11.0
